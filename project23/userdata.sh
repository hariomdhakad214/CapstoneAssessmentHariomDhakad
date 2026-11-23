#!/bin/bash
set -uo pipefail

exec > >(tee -a /var/log/user-data.log /dev/console) 2>&1

echo "===== Starting IAM role test setup ====="

export DEBIAN_FRONTEND=noninteractive

for attempt in 1 2 3; do
    if apt-get update -y && apt-get install -y unzip curl; then
        break
    fi
    sleep 10
done

# Install AWS CLI v2. No credentials are configured anywhere on this server.
curl -fsSL -o /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

export AWS_DEFAULT_REGION=${region}
BUCKET=${bucket}
REPORT=/tmp/cli-test-output.txt

# Retry until the role credentials are available from the instance metadata service
for attempt in 1 2 3 4 5 6; do
    if aws sts get-caller-identity > /dev/null 2>&1; then
        break
    fi
    sleep 10
done

{
    echo "=== CLI TEST OUTPUT: IAM ROLE BASED ACCESS ==="
    echo "Run on: $(hostname) at $(date -u +%FT%TZ)"
    echo
    echo "--- 1. No access keys on this server ---"
    echo "AWS_ environment variables with keys: $(env | grep -c '^AWS_ACCESS_KEY_ID\|^AWS_SECRET_ACCESS_KEY')"
    echo "Credentials file present: $(test -e /root/.aws/credentials && echo yes || echo no)"
    echo
    echo "--- 2. Who am I? (aws sts get-caller-identity) ---"
    aws sts get-caller-identity 2>&1
    echo
    echo "--- 3. ALLOWED: list the bucket (aws s3 ls s3://$BUCKET/) ---"
    aws s3 ls "s3://$BUCKET/" 2>&1
    echo
    echo "--- 4. ALLOWED: read an object (aws s3 cp s3://$BUCKET/hello.txt -) ---"
    aws s3 cp "s3://$BUCKET/hello.txt" - 2>&1
    echo
    echo "--- 5. ALLOWED: write an object under uploads/ ---"
    echo "written by the EC2 role at $(date -u +%FT%TZ)" | aws s3 cp - "s3://$BUCKET/uploads/from-ec2.txt" 2>&1
    echo
    echo "--- 6. DENIED: list all buckets in the account (aws s3 ls) ---"
    aws s3 ls 2>&1
    echo
    echo "--- 7. DENIED: delete an object (aws s3 rm) ---"
    aws s3 rm "s3://$BUCKET/hello.txt" 2>&1
    echo
    echo "--- 8. DENIED: write outside uploads/ ---"
    echo "x" | aws s3 cp - "s3://$BUCKET/not-allowed.txt" 2>&1
    echo
    echo "=== END OF TEST OUTPUT ==="
} > "$REPORT" 2>&1

# Save the report where it can be read with the CLI, and print it to the boot log
aws s3 cp "$REPORT" "s3://$BUCKET/reports/cli-test-output.txt" 2>&1
cat "$REPORT"

echo "===== USER-DATA COMPLETED ====="
