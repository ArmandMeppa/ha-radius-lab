#!/usr/bin/env bash
set -euo pipefail

VM_NAME="k3s"

echo "🚀 Deploying platform services..."


cd /home/ubuntu/ha-radius-lab

echo "🔧 Ensuring helm repo and deploying OpenLDAP..."

helm repo add helm-openldap https://jp-gouin.github.io/helm-openldap/ || true
helm repo update

# Ensure chart dependencies for the local wrapper chart are fetched
helm dependency update charts/openldap || true

helm upgrade --install openldap ./charts/openldap \
	-n ldap --create-namespace -f charts/openldap/values-dev.yaml --wait

echo "🔧 Deploying FreeRADIUS..."
helm upgrade --install freeradius ./charts/freeradius \
  -n radius --create-namespace -f charts/freeradius/values.yaml --wait

echo "✅ Platform services deployed (via helm)"
