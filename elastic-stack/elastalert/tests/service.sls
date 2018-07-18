test_elastalert_service_running:
  testinfra.service:
    - name: elastalert
    - is_enabled: True
    - is_running: True
