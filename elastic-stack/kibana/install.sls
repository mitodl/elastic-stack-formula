{% from "elastic-stack/kibana/map.jinja" import kibana with context %}

include:
  - elastic-stack.repository

install_kibana:
  pkg.installed:
    - pkgs: {{ kibana.pkgs }}
    - reload_modules: True
    - update: True
    - require:
      - pkgrepo: configure_elastic_stack_package_repo
