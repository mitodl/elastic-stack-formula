{% from "elastic-stack/kibana/map.jinja" import kibana with context %}
{% set version = salt.pillar.get('elastic_stack:version') %}

include:
  - elastic-stack.repository

install_kibana:
  pkg.installed:
    - name: kibana
    - version: {{ version }}
    - reload_modules: True
    - update: True
    - require:
      - pkgrepo: configure_elastic_stack_package_repo
