#!/bin/bash
set -Eeuo pipefail

exec > >(tee -a /var/log/user-data.log /dev/console) 2>&1

trap 'rc=$?; echo "USER-DATA FAILED: line $LINENO, exit code $rc"; exit "$rc"' ERR

echo "===== Starting web server setup ====="

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

apt-get install -y nginx

# IMDSv2 token, then read this server's own details so each page shows who answered
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Load Balanced App</title></head>
<body>
<h1>Hello from server ${server_number}</h1>
<p>Instance ID: $INSTANCE_ID</p>
<p>Availability Zone: $AZ</p>
</body>
</html>
EOF

systemctl enable --now nginx
systemctl is-active nginx

echo "===== USER-DATA COMPLETED SUCCESSFULLY ====="
