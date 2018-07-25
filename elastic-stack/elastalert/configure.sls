{% from "elastic-stack/elastalert/map.jinja" import elastalert, elastalert_init with context %}

include:
  - .service

{% set elastalert_addons = salt.pillar.get('elastic_stack:elastalert:addons', []) %}
{% if elastalert_addons %}
install_elastalert_addon_packages:
  pip.installed:
    - pkgs: {{ elastalert_addons }}
    - upgrade: True
{% endif %}

generate_elastalert_config_file:
  file.managed:
    - name: /etc/elastalert/config.yaml
    - makedirs: True
    - contents: |
        {{ elastalert.settings|yaml(False)|indent(8) }}
    - watch_in:
        - service: elastalert_service_running

{% for rule in salt.pillar.get('elastic_stack:elastalert:rules', [])  %}
generate_elastalert_rules_{{ rule.name }}_file:
  file.managed:
    - name: {{ elastalert.settings.rules_folder}}/{{ rule.name }}.yaml
    - makedirs: True
    - contents: |
        {{ rule.settings|yaml(False)|indent(8) }}
    - watch_in:
        - service: elastalert_service_running
{% endfor %}

create_elastalert_control_script:
  file.managed:
    - name: /usr/local/bin/elastalert.sh
    - source: salt://elastic-stack/elastalert/files/elastalert.sh
    - mode: 0755

define_elastalert_init_service:
  file.managed:
    - name: {{ elastalert_init.init_file }}
    - source: {{ elastalert_init.init_source }}
    - require:
        - file: create_elastalert_control_script
    - require_in:
        - service: elastalert_service_running

{% if elastalert.create_index %}
{% set ssl_arg = '--ssl' if elastalert.settings.use_ssl else '--no-ssl' %}
{% set auth_arg = '' if elastalert.settings.get('es_password') else '--no-auth' %}
generate_elastalert_status_index:
  cmd.run:
    - name: >-
        /usr/local/bin/elastalert-create-index
        --host {{ elastalert.settings.es_host }}
        --port {{ elastalert.settings.es_port }}
        {{ ssl_arg }} {{ auth_arg }}
        --url-prefix {{ elastalert.settings.get("es_url_prefix", "''") }}
        --index {{ elastalert.settings.writeback_index }}
        --old-index {{ elastalert.settings.get("old_writeback_index", "''") }}
{% endif %}
