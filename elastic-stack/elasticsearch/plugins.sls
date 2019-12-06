{% from "elastic-stack/elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - .service
  - .install

{% for plugin in salt.pillar.get('elastic_stack:elasticsearch:plugins', []) %}
remove_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin remove {{ plugin.get('location', plugin.name) }}
    - onchanges:
      - pkg: install_elasticsearch
    - require_in:
      - cmd: install_{{ plugin.name }}_plugin

install_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin install -b {{ plugin.get('location', plugin.name) }}
    - onchanges:
      - pkg: install_elasticsearch
    - watch_in:
        - service: elasticsearch_service
{% endfor %}
