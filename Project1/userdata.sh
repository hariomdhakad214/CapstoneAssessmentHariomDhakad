#!/bin/bash
set -Eeuo pipefail

# Send output to both the log file and EC2 console
exec > >(tee -a /var/log/user-data.log /dev/console) 2>&1

# Report the exact line if a command fails
trap 'rc=$?; echo "USER-DATA FAILED: line $LINENO, exit code $rc"; exit "$rc"' ERR

echo "===== Starting web server setup ====="

export DEBIAN_FRONTEND=noninteractive

# Update package repositories, retrying up to three times
for attempt in 1 2 3; do
    if apt-get update -y; then
        echo "Package update successful"
        break
    fi

    echo "Package update failed: attempt $attempt"

    if [ "$attempt" -eq 3 ]; then
        echo "All package update attempts failed"
        exit 1
    fi

    sleep 10
done

# Install Apache
echo "Installing Apache..."
apt-get install -y apache2

# Enable and start Apache
echo "Starting Apache..."
systemctl enable --now apache2

# Create website
cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Terraform Web Server</title>
</head>
<body>
    <h1>Welcome to My AWS Web Server!</h1>
    <h2>Deployed using Terraform</h2>
    <p>Infrastructure as Code Project</p>
    <p>Successfully deployed on AWS EC2 using Terraform.</p>
</body>
</html>
EOF

# Verify Apache
systemctl is-active apache2

echo "===== USER-DATA COMPLETED SUCCESSFULLY ====="
