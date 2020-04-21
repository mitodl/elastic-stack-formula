{% from "elastic-stack/elastalert/map.jinja" import elastalert with context %}

include:
  - elastic-stack.elastalert.service
  - elastic-stack.elastalert.configure

create_elastalert_user:
  user.present:
    - name: {{ elastalert.user }}

install_elastalert_os_package_dependencies:
  pkg.installed:
    - pkgs: {{ elastalert.pkgs }}

remove_python_cryptography_system_package:
  pkg.removed:
    - name: python-cryptography

create_elastalert_virtualenv:
  virtualenv.managed:
    - name: /opt/elastalert
    - python: /usr/bin/python3
    - require:
        - pkg: install_elastalert_os_package_dependencies

install_elastalert_package:
  pip.installed:
    - name: elastalert
    - upgrade: True
    - require:
        - pkg: install_elastalert_os_package_dependencies
    - require_in:
        - service: elastalert_service_running
    - bin_env: /opt/elastalert
    - require:
        - virtualenv: create_elastalert_virtualenv

create_elastalert_runtime_directory:
  file.directory:
    - name: /var/run/elastalert/
    - user: {{ elastalert.user }}
    - group: {{ elastalert.user }}
