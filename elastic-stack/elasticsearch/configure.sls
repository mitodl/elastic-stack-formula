{% from "elastic-stack/elasticsearch/map.jinja" import elasticsearch with context %}

include:
  - .service

# Create folder and set permissions
{% set conf_dir = elasticsearch.conf_folder %}
{% set log_dir = elasticsearch.log_folder %}

{% for dir in (conf_dir, log_dir) %}
create_directory{{ dir|replace('/', '_') }}to_ensure_proper_permissions:
  file.directory:
    - name: {{ dir }}
    - user: elasticsearch
    - group: elasticsearch
    - mode: 0700
    - makedirs: True
{% endfor %}

# Update the I/O scheduler if using SSD to improve write throughput https://www.elastic.co/guide/en/elasticsearch/guide/current/hardware.html
{% for device_name in salt.grains.get('SSDs') %}
update_io_scheduler_for_{{device_name}}:
  cmd.run:
    - name: echo noop | tee /sys/block/{{ device_name }}/queue/scheduler
{% endfor %}

# Update Heap Size according to available RAM https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html
{% set heap_max = salt.grains.get('mem_total', 0) // 2 %}
{% set heap_size = heap_max if heap_max < 31744 else 31744 %}
config_jvm_options:
  file.comment:
    - name: '{{ elasticsearch.conf_folder }}/jvm.options'
    - regex: '^-Xm[sx]\d\w'

update_elasticsearch_heap_size:
  file.replace:
    - name: {{ elasticsearch.env_file }}
    - pattern: '^#ES_JAVA_OPTS='
    - repl: 'ES_JAVA_OPTS="-Xms{{ heap_size }}m -Xmx{{ heap_size }}m"'
    - append_if_not_found: True
    - onchanges_in:
        - service: elasticsearch_service

update_elasticsearch_java_home:
  file.replace:
    - name: {{ elasticsearch.env_file }}
    - pattern: '^#JAVA_HOME='
    - repl: 'JAVA_HOME="{{ elasticsearch.java_home }}"'
    - append_if_not_found: True
    - onchanges_in:
        - service: elasticsearch_service

uncomment_elasticsearch_defaults:
  file.uncomment:
    - name: {{ elasticsearch.env_file }}
    - regex: (START_DAEMON|ES_USER|ES_GROUP|LOG_DIR|DATA_DIR|WORK_DIR|CONF_DIR|CONF_FILE|RESTART_ON_UPGRADE)

# Configure/disable swappiness https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration-memory.html
{% if elasticsearch.disable_swap %}
disable_swap_on_elasticsearch_node:
  cmd.run:
    - name: swapoff -a
  file.line:
    - name: /etc/fstab
    - content: ''
    - match: swap
    - mode: Delete
    - onchanges_in:
        - service: elasticsearch_service
{% else %}
set_swapiness_for_elasticsearch_node:
  cmd.run:
    - name: sysctl -w vm.swappiness=1
  file.append:
    - name: /etc/sysctl.conf
    - text: vm.swappiness = 1
    - onchanges_in:
        - service: elasticsearch_service
{% endif %}

# Up the count for file descriptors for Lucene https://www.elastic.co/guide/en/elasticsearch/reference/current/file-descriptors.html
update_sysctl_file_descriptor_limit:
  cmd.run:
    - name: sysctl -w fs.file-max={{ elasticsearch.fd_limit }}
  file.replace:
    - name: /etc/sysctl.conf
    - pattern: '^fs.file-max=.*'
    - repl: fs.file-max={{ elasticsearch.fd_limit }}
    - append_if_not_found: True
    - onchanges_in:
        - service: elasticsearch_service

update_elasticsearch_systemd_file_descriptor_limit:
  file.managed:
    - name: /etc/systemd/system/elasticsearch.service.d/fdlimit.conf
    - makedirs: True
    - contents: |
        [Service]
        LimitNOFILE={{ elasticsearch.fd_limit }}
    - onchanges_in:
        - service: elasticsearch_service

reload_elasticsearch_systemd_units:
  cmd.wait:
    - name: systemctl daemon-reload
    - onchanges:
        - file: update_elasticsearch_systemd_file_descriptor_limit

# Increase limits of mmap counts https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html
increase_max_map_count:
  cmd.run:
    - name: sysctl -w vm.max_map_count={{ elasticsearch.max_map_count }}
  file.append:
    - name: /etc/sysctl.conf
    - text: vm.max_map_count={{ elasticsearch.max_map_count }}
    - onchanges_in:
        - service: elasticsearch_service

configure_elasticsearch:
  file.managed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - contents: |
        {{ elasticsearch.configuration_settings | yaml(False) | indent(8) }}
    - makedirs: True
    - onchanges_in:
        - service: elasticsearch_service

{% for plugin, settings in salt.pillar.get('elastic_stack:elasticsearch:plugin_settings', {}).items() %}
configure_settings_for_{{ plugin }}:
  file.managed:
    - name: /etc/elasticsearch/{{ plugin }}.yml
    - contents: |
        {{ settings|yaml(False)|indent(8) }}
    - onchanges_in:
        - service: elasticsearch_service
{% endfor %}

set_elasticsearch_folder_permissions:
  file.directory:
    - name: /var/lib/elasticsearch
    - user: elasticsearch
    - group: elasticsearch
    - recurse:
        - user
        - group
    - onchanges_in:
        - service: elasticsearch_service

stop_elasticsearch_service:
  service.dead:
    - name: elasticsearch

start_elasticsearch_service:
  service.running:
    - name: elasticsearch

{% for template in
   salt.pillar.get('elastic_stack:elasticsearch:index_templates', []) %}
update_{{ template.name }}_template:
  elasticsearch.index_template_present:
    - name: {{ template.name }}
    - definition: {{ template.definition | tojson }}
    - check_definition: True
{% endfor %}
