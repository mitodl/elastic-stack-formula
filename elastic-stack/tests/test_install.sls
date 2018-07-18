{% from "elastic-stack/map.jinja" import elastic_stack with context %}

{% for pkg in elastic_stack.pkgs %}
test_{{pkg}}_is_installed:
  testinfra.package:
    - name: {{ pkg }}
    - is_installed: True
{% endfor %}
