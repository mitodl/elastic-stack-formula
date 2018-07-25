{% from "elasticsearch/map.jinja" import elasticsearch, elasticsearch_repo with context %}
{% set heap_max = salt.grains.get('mem_total', 0) // 2 %}
{% set heap_size = heap_max if heap_max < 31744 else 31744 %}

test_elasticsearch_repository_configured:
  testinfra.file:
    - name: /etc/apt/sources.list
    - contains:
        parameter: {{ elasticsearch.pkg_repo_url }}
        expected: True
        comparison: is_

test_elasticsearch_config_file:
  testinfra.file:
    - name: {{ elasticsearch.conf_file }}
    - exists: True

test_elasticsearch_cluster_name:
  testinfra.file:
    - name: {{ elasticsearch.conf_folder }}/elasticsearch.yml
    - contains:
        parameter: "cluster.name: {{ elasticsearch.configuration_settings['cluster.name'] }}"
        expected: True
        comparison: is_

test_elasticsearch_recovery_time:
  testinfra.file:
    - name: {{ elasticsearch.conf_folder }}/elasticsearch.yml
    - contains:
        parameter: "gateway.recover_after_time: {{ elasticsearch.configuration_settings['gateway.recover_after_time'] }}"
        expected: True
        comparison: is_

test_elasticsearch_log_directory:
  testinfra.file:
    - name: {{ elasticsearch.log_folder }}
    - is_dir: True
    - exists: True

test_elasticsearch_env_file:
  testinfra.file:
    - name: {{ elasticsearch.env_file }}
    - exists: True
    - contains:
        {% if elasticsearch.elastic_stack %}
        parameter: 'ES_JAVA_OPTS="-Xms{{ heap_size }}m -Xmx{{ heap_size }}m"'
        {% else %}
        parameter: 'ES_HEAP_SIZE={{ heap_size }}m'
        {% endif %}
        expected: True
        comparison: is_

# Add test for IO scheduler

test_elasticsearch_swapiness:
  testinfra.file:
    - name: /etc/fstab
    - exists: True
    - contains:
        {% if elasticsearch.disable_swap %}
        parameter: 'swap'
        expected: False
        {% else %}
        parameter: 'vm.swappiness = 1'
        expected: True
        {% endif %}
        comparison: is_

test_elasticsearch_file_descriptor_limit:
  testinfra.file:
    - name: /etc/sysctl.conf
    - exists: True
    - contains:
        parameter: "fs.file_max={{ elasticsearch.fd_limit }}"
        expected: True
        comparison: is_

test_elasticsearch_max_map_count:
  testinfra.file:
    - name: /etc/sysctl.conf
    - exists: True
    - contains:
        parameter: "vm.max_map_count={{ elasticsearch.max_map_count }}"
        expected: True
        comparison: is_
