{% from "elasticsearch/map.jinja" import elasticsearch with context %}
{% for package in elasticsearch.pkgs %}
test_installed_{{ package }}:
  testinfra.package:
    - name: {{ package }}
    - is_installed: True
{% endfor %}
