clean_old_logs_cronjob:
  cron.present:
    - identifier: clean_old_logs
    - name: /usr/bin/find /usr/share/elasticsearch/logs -type f -name '*.gz' -mtime +30 -exec rm {} \; > /var/log/clean-es-logs.log 2>&1
    - user: root
    - minute: 0
    - hour: 0
