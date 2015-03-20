{% from "adagios/map.jinja" import adagios, config with context %}

deps:
  pkg.installed:
    - names: ['python-pip', 'python-dev']
  pip.installed:
    - names:
        - pynag
        - django==1.5
        - simplejson
        - adagios
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
