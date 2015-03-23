{% from "adagios/map.jinja" import adagios, config, web with context %}

deps:
  pkg.installed:
    - names: {{adagios.packages}}
  pip.installed:
    - names:
        - pynag
        - django==1.6
        - simplejson
        - adagios
        - gunicorn
    - requre:
        - pkg: deps

/etc/adagios/adagios.conf warn:
  file.prepend:
    - name: /etc/adagios/adagios.conf
    - text: "## This file is managed by salt!"
    - require:
        - pip: deps

{% for k,v in config.items() %}
/etc/adagios/adagios.conf {{k}}:
  file.replace:
    - name: /etc/adagios/adagios.conf
    - pattern: ^{{k}}\s?=.*
    - repl: "{{k}} = {{v if v in [True,False] else '\\"%s\\"' % v}}  # salt managed!"
    - require:
        - pip: deps
{% endfor %}

destination directory:
  file.directory:
    - name: {{config['destination_directory'] }}

destination directory included:
  file.append:
    - name: {{config['nagios_config'] }}
    - text: cfg_dir={{config['destination_directory'] }}


adagio-web logs:
  file.directory:
    - name: {{web.logdir}}
    - group: {{web.group}}
    - mode: 775

adagios-web:
  file.managed:
    - name: /etc/init/adagios.conf
    - source: salt://adagios/files/etc/init/adagios.conf.jinja
    - template: jinja
    - mode: 444
    - context:
{% for k,v in web.items() %}
        {{k}}: {{v}}
{% endfor %}
    - require:
        - pip: deps
        - file: adagio-web logs
  service.running:
    - name: adagios
    - enable: True
    - watch:
        - file: adagios-web
        - file: /etc/adagios/adagios.conf*
