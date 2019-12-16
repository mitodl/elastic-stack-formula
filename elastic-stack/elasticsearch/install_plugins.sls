{# This state is included by upgrade.sls in order to perform the
   plugin installation after the removal of plugins and upgrade of the
   Elasticsearch package. #}

{% set ENVIRONMENT = salt.environ.get('ENVIRONMENT') %}
{% set plugins = salt.pillar.get('elastic_stack:elasticsearch:plugins', []) %}

{% for plugin in plugins %}
install_elasticsearch_{{ plugin.name }}_plugin:
  salt.function:
    - tgt: "G@roles:elasticsearch and G@environment:{{ ENVIRONMENT }}"
    - name: cmd.run
    - arg:
      - /usr/share/elasticsearch/bin/elasticsearch-plugin install -b {{ plugin.get('location', plugin.name) }}
{% endfor %}
