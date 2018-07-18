{% from "elastic-stack/elasticsearch/map.jinja" import elasticsearch with context %}
{% set es_hosts = [] %}
{% for id, addr in salt.mine.get('roles:elasticsearch', 'network.ip_addrs', expr_form='grain') %}
{% do es_hosts.append(addr) %}
{% endfor %}

configure_cluster_unicast:
  file.replace:
    - name: /etc/elasticsearch/elasticsearch.yml
    - pattern: '^discovery.zen.ping.unicast_hosts:.*?$'
    - repl: 'discovery.zen.ping.unicast_hosts: {{ es_hosts | yaml() }}'
    - append_if_not_found: True
