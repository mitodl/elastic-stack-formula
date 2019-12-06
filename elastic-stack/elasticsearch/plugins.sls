{% from "elastic-stack/elasticsearch/map.jinja" import elasticsearch with context %}
{% set commands = {'install': 'install -b', 'remove': 'remove'} %}

include:
  - .service

{% for plugin in salt.pillar.get('elastic_stack:elasticsearch:plugins', []) %}
{% for command in commands %}
{{ command }}_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin {{ commands[command] }} {{ plugin.get('location', plugin.name) }}
    - watch_in:
        - service: elasticsearch_service
{% endfor %}
{% endfor %}
