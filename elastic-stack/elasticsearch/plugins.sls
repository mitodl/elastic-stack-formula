{% from "elastic-stack/elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - .service
  - .install

{% for plugin in salt.pillar.get('elastic_stack:elasticsearch:plugins', []) %}
remove_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin remove {{ plugin.get('location', plugin.name) }}
    - onlyif:
        - test -e /usr/share/elasticsearch/plugins/{{ plugin.name }}/{{ plugin.name }}*.jar
    - onchanges:
      - pkg: install_elasticsearch

install_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin install -b {{ plugin.get('location', plugin.name) }}
    - onchanges:
      - pkg: install_elasticsearch
    - require:
        - cmd: remove_{{ plugin.name }}_plugin
    - watch_in:
        - service: elasticsearch_service

set_permissions_on_{{plugin.name}}_plugin:
  cmd.run:
    - name: chgrp -R elasticsearch /etc/elasticsearch/{{ plugin.name }}
{% endfor %}
