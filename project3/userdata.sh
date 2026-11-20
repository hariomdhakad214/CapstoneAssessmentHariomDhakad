#!/bin/bash
set -Eeuo pipefail

exec > >(tee -a /var/log/user-data.log) 2>&1

trap 'rc=$?; echo "USER-DATA FAILED: line $LINENO, exit code $rc"; exit "$rc"' ERR

echo "===== Starting CPU load setup ====="

export DEBIAN_FRONTEND=noninteractive

for attempt in 1 2 3; do
    if apt-get update -y; then
        break
    fi

    if [ "$attempt" -eq 3 ]; then
        echo "All package update attempts failed"
        exit 1
    fi

    sleep 10
done

apt-get install -y stress-ng

cat > /usr/local/bin/generate-load.sh <<'EOF'
#!/bin/bash
sleep ${load_delay_seconds}
stress-ng --cpu 0 --timeout ${load_duration_seconds}s
EOF

chmod +x /usr/local/bin/generate-load.sh

# Run the load in the background so cloud-init can finish
systemd-run --unit=cpu-load /usr/local/bin/generate-load.sh

echo "===== USER-DATA COMPLETED: load starts in ${load_delay_seconds}s for ${load_duration_seconds}s ====="
