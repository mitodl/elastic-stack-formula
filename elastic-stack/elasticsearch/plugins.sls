{% from "elastic-stack/elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - .service
  - .install

{% for plugin in salt.pillar.get('elastic_stack:elasticsearch:plugins', []) %}
install_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin remove {{ plugin.get('location', plugin.name) }}
    - onchanges: install_elasticsearch
    - watch_in:
      - service: elasticsearch_service
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin install -b {{ plugin.get('location', plugin.name) }}
    - onchanges: install_elasticsearch
    - watch_in:
        - service: elasticsearch_service
{% endfor %}
