{% from "elastic-stack/map.jinja" import elastic_stack with context %}
{% set os_family = salt.grains.get('os_family') %}
{% set osfullname = salt.grains.get('osfullname') %}

{% if os_family == 'RedHat' %}
install_elastic_stack_gpg_key:
  cmd.run:
    - name: rpm --import {{ elastic_stack.gpg_key }}
    - require_in:
        - pkgrepo: configure_elastic_stack_package_repo
{% endif %}

configure_elastic_stack_package_repo:
  pkgrepo.managed:
    - humanname: Elastic Stack {{ elastic_stack.version }}
    {% if os_family == 'Debian' %}
    - name: deb {{ elastic_stack.pkg_repo_url }}/apt stable main
    - gpgkey: {{ elastic_stack.gpg_key }}
    - refresh_db: True
    {% elif os_family == 'RedHat' %}
    - name: {{ name }}
    - baseurl: {{ elastic_stack.pkg_repo_url }}/yum
    - gpgcheck: 1
    - enabled: 1
    {% endif %}
    - key_url: {{ elastic_stack.gpg_key }}

{% if osfullname == 'Debian' %}
configure_openjdk_repo:
    pkgrepo.managed:
    - humanname: 'OpenJDK'
    - name: {{ elastic_stack.openjdk_repo }}
    - enabled: True
    - refresh_db: True
    - require_in:
        - install_pkg_dependencies
{% endif %}
