{% from "elastic-stack/map.jinja" import elastic_stack with context %}

elastic-stack_service_running:
  service.running:
    - name: {{ elastic_stack.service }}
    - enable: True
