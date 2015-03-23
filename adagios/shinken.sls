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
