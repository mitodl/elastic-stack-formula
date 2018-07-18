test_elasticsearch_service_running:
  testinfra.service:
    - name: elasticsearch
    - is_running: True
    - is_enabled: True
