#!/bin/bash
set -Eeuo pipefail

exec > >(tee -a /var/log/user-data.log /dev/console) 2>&1

trap 'rc=$?; echo "USER-DATA FAILED: line $LINENO, exit code $rc"; exit "$rc"' ERR

echo "===== Starting workload setup ====="

export DEBIAN_FRONTEND=noninteractive

for attempt in 1 2 3; do
    if apt-get update -y; then
        break
    fi

    if [ "$attempt" -eq 3 ]; then
        echo "Package update failed"
        exit 1
    fi

    sleep 10
done

apt-get install -y stress-ng

# Repeating workload so the dashboard graphs rise and fall:
# 3 minutes of heavy CPU, then 2 minutes of rest, with a small download every 30 seconds for network traffic
cat > /usr/local/bin/workload.sh <<'EOF'
#!/bin/bash
(
    while true; do
        curl -s -o /dev/null https://archive.ubuntu.com/ubuntu/dists/noble/main/binary-amd64/Packages.gz
        sleep 30
    done
) &

while true; do
    stress-ng --cpu 0 --cpu-load 85 --timeout 180s
    sleep 120
done
EOF
chmod +x /usr/local/bin/workload.sh

cat > /etc/systemd/system/workload.service <<'EOF'
[Unit]
Description=Sample workload for the CloudWatch dashboard

[Service]
ExecStart=/usr/local/bin/workload.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now workload

echo "===== USER-DATA COMPLETED SUCCESSFULLY ====="
