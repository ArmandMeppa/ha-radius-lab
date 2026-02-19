#!/usr/bin/env bash
set -euo pipefail

VM_NAME="k3s"

echo "🚀 Deploying platform services..."


cd /home/ubuntu/ha-radius-lab && helmfile --environment dev apply


echo "✅ Platform services deployed"
