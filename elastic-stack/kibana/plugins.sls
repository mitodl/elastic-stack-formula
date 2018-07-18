{% from "elastic-stack/kibana/map.jinja" import kibana with context %}

include:
  - .service

{% for plugin in salt.pillar.get('kibana:plugins', {}) %}
install_{{ plugin.name }}_plugin:
  cmd.run:
    - name: /usr/share/kibana/bin/kibana-plugin install {{ plugin.get('location', plugin.name) }}
    - unless: "[ $(/usr/share/kibana/bin/kibana-plugin list | grep {{ plugin.name }} | wc -l) -eq 1 ]"
    - watch_in:
        - service: kibana_service

{% if plugin.get('config') %}
plugin_configuration_for_{{ plugin.name }}:
  file.append:
    - name: /etc/kibana/kibana.yml
    - text: |
        {{ plugin.config | yaml(False) | indent(8) }}
    - watch_in:
        - service: kibana_service
{% endif %}
{% endfor %}
