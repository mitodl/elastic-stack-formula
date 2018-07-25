{% from "elastic-stack/elastalert/map.jinja" import elastalert, elastalert_init with context %}

include:
  - elastic-stack.elastalert.service
  - elastic-stack.elastalert.configure

install_elastalert_os_package_dependencies:
  pkg.installed:
    - pkgs: {{ elastalert.pkgs }}

remove_python_cryptography_system_package:
  pkg.removed:
    - name: python-cryptography

install_elastalert_package:
  pip.installed:
    - name: elastalert
    - upgrade: True
    - require:
        - pkg: install_elastalert_os_package_dependencies
    - require_in:
        - service: elastalert_service_running
