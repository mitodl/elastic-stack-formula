{% from "elastic-stack/kibana/map.jinja" import kibana with context %}

include:
    - .service

create_kibana_directory:
  file.directory:
    - name: /etc/kibana
    - makedirs: True

ensure_writability_of_kibana_log:
  file.managed:
    - name: /var/log/kibana.log
    - user: kibana
    - group: kibana
    - mode: 0640

configure_kibana:
  file.managed:
    - name: /etc/kibana/kibana.yml
    - contents: |
        {{ kibana.config | yaml(False) | indent(8) }}
    - require:
        - file: create_kibana_directory
    - onchanges_in:
        - service: kibana_service

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
    - onchanges_in:
        - service: kibana_service

reload_kibana_systemd_units:
  cmd.wait:
    - name: systemctl daemon-reload
    - onchanges:
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
    - onchanges_in:
        - service: kibana_service
{% endif %}
