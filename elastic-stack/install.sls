{% from "elastic-stack/map.jinja" import elastic_stack with context %}

include:
  - .service

elastic-stack:
  pkg.installed:
    - pkgs: {{ elastic_stack.pkgs }}
    - require_in:
        - service: elastic-stack_service_running
