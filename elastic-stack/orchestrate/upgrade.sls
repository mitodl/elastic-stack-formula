{# USAGE:
    Set ENVIRONMENT to your architectural environment.

    Example:
      sudo -E ENVIRONMENT=operations-qa \
        salt-run state.orchestrate elastic_stack.orchestrate.upgrade
#}

{% set ENVIRONMENT = salt.environ.get('ENVIRONMENT') %}

stop_elasticsearch:
  salt.function:
    - tgt: "G@roles:elasticsearch and G@environment:{{ ENVIRONMENT }}"
    - name: service.stop
    - arg: elasticsearch

upgrade_elasticsearch:
  salt.state:
    - tgt: "G@roles:elasticsearch and G@environment:{{ ENVIRONMENT }}"
    - tgt_type: compound
    - sls:
      - elastic_stack.elasticsearch.remove_plugins
      - elastic_stack.elasticsearch.install
      - elastic_stack.elasticsearch.install_plugins
      - elastic_stack.elasticsearch.configure

upgrade_kibana:
  salt.state:
    - tgt: "G@roles:kibana and G@environment:{{ ENVIRONMENT }}"
    - tgt_type: compound
    - sls:
      - elastic_stack.kibana
