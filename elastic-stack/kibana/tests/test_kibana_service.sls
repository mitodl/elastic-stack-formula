test_kibana_service_running:
  testinfra.service:
    - name: kibana
    - is_running: True
    - is_enabled: True

test_nginx_service_running:
  testinfra.service:
    - name: nginx
    - is_running: True
    - is_enabled: True
