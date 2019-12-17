{# USAGE:
    Set ES_BASE_URL to your Elasticsearch URL.
    Set ES_NODE_TARGET to the Salt target for your Elasticsearch node minions.

    Example:
      sudo -E \
        ES_BASE_URL=http://mycluster:9200 \
        ES_NODE_TARGET="elasticsearch-*" \
        salt-run state.orchestrate elastic_stack.elasticsearch.upgrade
#}

{% set ES_NODE_TARGET = salt.environ.get('ES_NODE_TARGET') %}
{% set ES_BASE_URL = salt.environ.get('ES_BASE_URL') %}

disable_shard_allocation:
  http.query:
    - name: http://{{ ES_BASE_URL }}/_cluster/settings
    - method: PUT
    - data: '{"persistent": {"cluster.routing.allocation.enable": "none"}}'
    - header_dict:
      'Content-type': 'application/json'

upgrade_elasticsearch:
  salt.state:
    - tgt: "{{ ES_NODE_TARGET }}"
    - batch: 1
    - sls:
      - elastic_stack.elasticsearch.remove_plugins
      - elastic_stack.elasticsearch.install
      - elastic_stack.elasticsearch.install_plugins
      - elastic_stack.elasticsearch.configure

enable_shard_allocation:
  http.query:
    - name: http://{{ ES_BASE_URL }}/_cluster/settings
    - method: PUT
    - data: '{"persistent": {"cluster.routing.allocation.enable": "all"}}'
    - header_dict:
      'Content-type': 'application/json'
