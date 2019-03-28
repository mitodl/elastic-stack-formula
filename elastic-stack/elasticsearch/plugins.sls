{% from "elastic-stack/elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - .service

{% for plugin in salt.pillar.get('elastic_stack:elasticsearch:plugins', []) %}
install_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin install -b {{ plugin.get('location', plugin.name) }}
    - unless: "[ $(/usr/share/elasticsearch/bin/elasticsearch-plugin list | grep {{ plugin.name }} | wc -l) -eq 1 ]"
    - watch_in:
        - service: elasticsearch_service
{% endfor %}
