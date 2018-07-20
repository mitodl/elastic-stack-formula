{% from "elastic-stack/beats/map.jinja" import beats with context %}

include:
  - .service

{% for agent, settings in beats.agents.items() %}
manage_configuration_for_{{ agent }}:
  file.managed:
    - name: /etc/{{ agent }}/{{ agent }}.yml
    - contents: |
        {{ settings.config|yaml(False)|indent(8) }}
    - onchanges_in:
        - service: {{ agent }}_service

{% for module, module_config in settings.modules.items() %}
configure_{{ module }}_module_for_{{ agent }}:
  cmd.run:
    - name: /usr/share/{{ agent }}/bin/{{ agent }} modules enable {{ module }}
    - cwd: /etc/{{ agent }}
  file.managed:
    - name: /etc/{{ agent }}/modules.d/{{ module }}.yml
    - contents: |
        {{ module_config|yaml(False)|indent(8) }}
    - onchanges_in:
        - service: {{ agent }}_service
{% endfor %}
{% endfor %}
