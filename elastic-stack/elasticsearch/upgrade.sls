{# USAGE:
    Set ENVIRONMENT to your architectural environment.
    Set ES_BASE_URL to your Elasticsearch URL.

    Example:
      sudo -E ENVIRONMENT=operations-qa \
        ES_BASE_URL=http://mycluster:9200 \
        salt-run state.orchestrate elastic_stack.orchestrate.upgrade
#}

{% set ENVIRONMENT = salt.environ.get('ENVIRONMENT') %}
{% set ES_BASE_URL = salt.environ.get('ES_BASE_URL') %}

disable_shard_allocation:
  http.query:
    name: http://{{ ES_BASE_URL }}/_cluster/settings
    method: PUT
    data: '{"persistent": {"cluster.routing.allocation.enable": "none"}}'
    header_dict:
      'Content-type': 'application/json'

upgrade_elasticsearch:
  salt.state:
    - tgt: "G@roles:elasticsearch and G@environment:{{ ENVIRONMENT }}"
    - tgt_type: compound
    - batch: 1
    - sls:
      - elastic_stack.elasticsearch.remove_plugins
      - elastic_stack.elasticsearch.install
      - elastic_stack.elasticsearch.install_plugins
      - elastic_stack.elasticsearch.configure

enable_shard_allocation:
  http.query:
    name: http://{{ ES_BASE_URL }}/_cluster/settings
    method: PUT
    data: '{"persistent": {"cluster.routing.allocation.enable": "all"}}'
    header_dict:
      'Content-type': 'application/json'

upgrade_kibana:
  salt.state:
    - tgt: "G@roles:kibana and G@environment:{{ ENVIRONMENT }}"
    - tgt_type: compound
    - sls:
      - elastic_stack.kibana
