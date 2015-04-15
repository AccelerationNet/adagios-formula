{% from "adagios/map.jinja" import adagios, config, web with context %}

include:
  - adagios

uwsgi:
  pip.installed: []

/etc/adagios/uwsgi.ini:
  file.managed:
    - source: salt://adagios/files/etc/adagios/uwsgi.ini
    - template: jinja
    - context: {{ web | yaml }}

adagio-web logs:
  file.directory:
    - name: {{ web.logdir }}
    - group: {{ web.group }}
    - mode: 775

adagio-web userdata:
  file.directory:
    - name: /var/lib/adagios/
    - group: {{ web.group }}
    - mode: 775

adagios-web:
  file.managed:
    - name: /etc/init/adagios.conf
    - source: salt://adagios/files/etc/init/adagios.conf.jinja
    - template: jinja
    - mode: 444
    - context: {{ web | yaml }}
    - require:
        - pip: deps
        - file: adagio-web logs
  service.running:
    - name: adagios
    - enable: True
    - watch:
        - file: adagios-web
        - file: /etc/adagios/*

/etc/nginx/adagios-uwsgi.conf:
  file.managed:
    - source: salt://adagios/files/etc/nginx/adagios-uwsgi.conf
    - mode: 444
