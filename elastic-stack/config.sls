{% from "elastic-stack/map.jinja" import elastic_stack with context %}

include:
  - .install
  - .service

elastic-stack-config:
  file.managed:
    - name: {{ elastic_stack.conf_file }}
    - source: salt://elastic-stack/templates/conf.jinja
    - template: jinja
    - watch_in:
      - service: elastic-stack_service_running
    - require:
      - pkg: elastic-stack
