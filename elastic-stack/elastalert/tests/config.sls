{% from "elasticsearch/elastalert/map.jinja" import elastalert, elastalert_init with context %}

test_elastalert_config_file_present:
  testinfra.file:
    - name: /etc/elastalert/config.yaml
    - exists: True
    - is_file: True

{% set rules = salt.pillar.get('elasticsearch:elastalert:rules', [])  %}
{% if rules %}
test_elastalert_rules_directory_present:
  testinfra.file:
    - name: {{ elastalert.settings.rules_folder }}
    - exists: True
    - is_directory: True

{% for rule in rules %}
test_elastalert_rule_{{ rule.name }}_present:
  testinfra.file:
    - name: {{ elastalert.settings.rules_folder }}/{{ rule.name }}.yaml
    - exists: True
    - is_file: True
{% endfor %}
{% endif %}
