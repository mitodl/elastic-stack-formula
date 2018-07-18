{% from "elastic-stack/kibana/map.jinja" import kibana with context %}

include:
    - .service

create_kibana_directory:
  file.directory:
    - name: /etc/kibana
    - makedirs: True

configure_kibana:
  file.managed:
    - name: /etc/kibana/kibana.yml
    - contents: |
        {{ kibana.config | yaml(False) | indent(8) }}
    - require:
        - file: create_kibana_directory

ensure_kibana_ssl_directory:
  file.directory:
    - name: {{ kibana.ssl_directory }}
    - makedirs: True
{% if salt.grains.get('init') == 'systemd' %}
add_node_environment_variables:
  file.managed:
    - name: /etc/systemd/system/kibana.service.d/kibana_env.conf
    - makedirs: True
    - contents: |
        [Service]
        {% for env in kibana.kibana_env %}
        Environment='{{ env }}'
        {% endfor %}

reload_kibana_systemd_units:
  cmd.wait:
    - name: systemctl daemon-reload
    - watch:
        - file: add_node_environment_variables
{% elif salt.grains.get('init') == 'upstart' %}
add_node_environment_variables:
  file.blockreplace:
    - name: /etc/init.d/kibana
    - marker_start: '  # Setup any environmental stuff beforehand'
    - marker_end: '  # Run the program!'
    - content: |
        {% for env in kibana.kibana_env %}
        export {{ env }}
        {% endfor %}
{% endif %}
