{# This state is included by upgrade.sls in order to perform the
   plugin removal before the installation of the Elasticsearch package
   and installation of plugins. #}

{% set ENVIRONMENT = salt.environ.get('ENVIRONMENT') %}
{% set plugins = salt.pillar.get('elastic_stack:elasticsearch:plugins', []) %}

stop_elasticsearch:
  service.dead:
    name: elasticsearch

{% for plugin in plugins %}
remove_elasticsearch_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/elasticsearch-plugin remove {{ plugin.get('location', plugin.name) }}
{% endfor %}
