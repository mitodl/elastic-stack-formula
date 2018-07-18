{% from "elastic_stack/kibana/map.jinja" import beats with context %}

include:
  - elastic_stack.repository

install_beats_agents:
  pkg.installed:
    - pkgs: {{ beats.pkgs }}
    - reload_modules: True
    - update: True
    - require:
      - pkgrepo: configure_elastic_stack_package_repo
