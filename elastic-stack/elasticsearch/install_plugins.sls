{# This state is included by upgrade.sls in order to perform the
   plugin installation after the removal of plugins and upgrade of the
   Elasticsearch package. #}

{% set ENVIRONMENT = salt.environ.get('ENVIRONMENT') %}
{% set plugins = salt.pillar.get('elastic_stack:elasticsearch:plugins', []) %}

install_elasticsearch_plugins:
  salt.function:
    - tgt: "G@roles:elasticsearch and G@environment:{{ ENVIRONMENT }}"
    - name: cmd.run
    - arg:
      {% for plugin in plugins %}
      - /usr/share/elasticsearch/bin/elasticsearch-plugin install -b {{ plugin }}
      {% endfor %}
