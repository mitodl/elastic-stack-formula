{% from "elasticsearch/elastalert/map.jinja" import elastalert, elastalert_init with context %}

test_elastalert_init_script_present:
  testinfra.file:
    - name: {{ elastalert_init.init_file }}
    - exists: True
    - is_file: True

test_elastalert_control_script_present:
  testinfra.file:
    - name: /usr/local/bin/elastalert.sh
    - exists: True
    - is_file: True
    - mode:
        expected: 493
        comparison: eq
