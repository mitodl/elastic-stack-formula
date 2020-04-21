{% from "elastic-stack/beats/map.jinja" import beats with context %}

include:
  - elastic-stack.repository

install_beats_agents:
  pkg.installed:
    - pkgs: {{ beats.pkgs|tojson }}
    - reload_modules: True
    - update: True
    - require:
      - pkgrepo: configure_elastic_stack_package_repo
