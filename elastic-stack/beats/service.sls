{% from "elastic-stack/beats/map.jinja" import beats with context %}

{% for service in beats.services %}
{{ service }}_service:
  service.running:
    - name: {{ service }}
    - enable: True
{% endfor %}
