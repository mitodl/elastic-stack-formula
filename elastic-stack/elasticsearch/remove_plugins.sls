{# This state is included by upgrade.sls in order to perform the
   plugin removal before the installation of the Elasticsearch package
   and installation of plugins. #}

{% set ENVIRONMENT = salt.environ.get('ENVIRONMENT') %}
{% set plugins = salt.pillar.get('elastic_stack:elasticsearch:plugins', []) %}

remove_elasticsearch_plugins:
  salt.function:
    - tgt: "G@roles:elasticsearch and G@environment:{{ ENVIRONMENT }}"
    - name: cmd.run
    - arg:
      {% for plugin in plugins %}
      - /usr/share/elasticsearch/bin/elasticsearch-plugin remove {{ plugin }}
      {% endfor %}
