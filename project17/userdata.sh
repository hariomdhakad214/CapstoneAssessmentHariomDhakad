#!/bin/bash
set -Eeuo pipefail

exec > >(tee -a /var/log/user-data.log /dev/console) 2>&1

trap 'rc=$?; echo "USER-DATA FAILED: line $LINENO, exit code $rc"; exit "$rc"' ERR

echo "===== Starting CloudWatch agent setup ====="

export DEBIAN_FRONTEND=noninteractive

# Download and install the CloudWatch agent, retrying on network errors
for attempt in 1 2 3; do
    if curl -fsSL -o /tmp/amazon-cloudwatch-agent.deb \
        "https://amazoncloudwatch-agent-${region}.s3.${region}.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb"; then
        break
    fi

    if [ "$attempt" -eq 3 ]; then
        echo "Agent download failed"
        exit 1
    fi

    sleep 10
done

dpkg -i -E /tmp/amazon-cloudwatch-agent.deb

# Application that writes a log line every 5 seconds, with an ERROR every 6th line
cat > /usr/local/bin/log-generator.sh <<'EOF'
#!/bin/bash
count=0
while true; do
    count=$((count + 1))
    if [ $((count % 6)) -eq 0 ]; then
        echo "$(date -u +%FT%TZ) ERROR request $count failed: simulated error" >> /var/log/app.log
    else
        echo "$(date -u +%FT%TZ) INFO request $count processed successfully" >> /var/log/app.log
    fi
    sleep 5
done
EOF
chmod +x /usr/local/bin/log-generator.sh
touch /var/log/app.log

cat > /etc/systemd/system/log-generator.service <<'EOF'
[Unit]
Description=Sample application log generator

[Service]
ExecStart=/usr/local/bin/log-generator.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now log-generator

# Tell the agent which files to ship, and where
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOF'
{
  "agent": {
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/app.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/app.log"
          },
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}/syslog"
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

systemctl is-active amazon-cloudwatch-agent

echo "===== USER-DATA COMPLETED SUCCESSFULLY ====="
