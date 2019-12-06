{% from "elastic-stack/elasticsearch/map.jinja" import elasticsearch with context %}
{% set osfullname = salt.grains.get('osfullname') %}
{% set version = salt.pillar.get('elastic_stack:version') %}

include:
    - elastic-stack.repository

install_pkg_dependencies:
  pkg.installed:
    - pkgs: {{ elasticsearch.pkg_deps }}
    - refresh: True

install_elasticsearch:
  pkg.installed:
    - name: elasticsearch
    - version: {{ version }}
    - refresh: True
    - skip_verify: {{ not elasticsearch.get('verify_package', True) }}
    - require:
        - pkgrepo: configure_elastic_stack_package_repo
        - pkg: install_pkg_dependencies
  file.directory:
    - name: /usr/share/elasticsearch
    - user: elasticsearch
    - group: elasticsearch
    - recurse:
        - user
        - group
