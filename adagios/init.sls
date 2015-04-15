{% from "adagios/map.jinja" import adagios, config, web with context %}

deps:
  pkg.installed:
    - names: {{adagios.packages}}
  # want some bug fixes in adagios, which needs a newer pynag
  pip.installed:
    - names:
        - "git+https://github.com/AccelerationNet/pynag.git@accel#egg=pynag"
        - django==1.6
        - simplejson
        - "git+https://github.com/AccelerationNet/adagios.git@accel#egg=adagios"
        - gunicorn
    - requre:
        - pkg: deps
  # pip-installing from git doesn't copy these files
  module.wait:
    - name: rsync.rsync
    - src: /usr/local/lib/python2.7/dist-packages/adagios/etc/
    - dst: /etc/
    - watch:
        - pip: deps

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


{% set pynag_overrides = salt['pillar.get']('adagios:pynag_overrides')%}

{% if pynag_overrides %}

/etc/adagios/conf.d/pynag_overrides.conf:
  file.managed:
    - source: salt://adagios/files/etc/adagios/conf.d/pynag_overrides.jinja.conf
    - template: jinja
    - makedirs: True
    - mode: 444
    - require:
        - pip: deps

{% endif %}
