# add some modifications to support shinken

include:
  - adagios

/etc/adagios/conf.d/shinken.conf:
  file.managed:
    - source: salt://adagios/files/etc/adagios/conf.d/shinken.conf
    - makedirs: True
    - mode: 444
    - require:
        - pip: deps


# adagios reloads config values often directly from adagios.conf, so these need to be changes there, not in conf.d

{% set shinken_overrides = {
  'livestatus_path': '/var/lib/shinken/live',
  'nagios_init_script': '/etc/init.d/shinken-arbiter',
  'nagios_binary': '/usr/bin/shinken'} %}

{% for k,v in shinken_overrides.items() %}
/etc/adagios/adagios.conf shinken {{k}}:
  file.replace:
    - name: /etc/adagios/adagios.conf
    - pattern: ^{{k}}\s?=.*
    - repl: "{{k}} = {{v if v in [True,False] else '\\"%s\\"' % v}}  # salt managed!"
    - require:
        - pip: deps
{% endfor %}
