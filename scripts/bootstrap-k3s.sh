#!/usr/bin/env bash
set -e

VM_NAME=${1:-k3s}

echo "🔹 Bootstrapping VM: $VM_NAME"

# -------------------------
# K3s
# -------------------------
multipass exec $VM_NAME -- bash -c '
if ! command -v k3s >/dev/null 2>&1; then
  echo "Installing k3s..."
  curl -sfL https://get.k3s.io | sh -

  echo "Configuring kubeconfig..."
  mkdir -p $HOME/.kube
  sudo cat /etc/rancher/k3s/k3s.yaml > $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  chmod 640 $HOME/.kube/config
else
  echo "k3s already installed."
fi
'

# -------------------------
# Helm
# -------------------------
multipass exec $VM_NAME -- bash -c '
if ! command -v helm >/dev/null 2>&1; then
  echo "Installing Helm..."
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod +x get_helm.sh
  ./get_helm.sh
  rm get_helm.sh
else
  echo "Helm already installed."
fi
'

# -------------------------
# K9s (optional)
# -------------------------
multipass exec $VM_NAME -- bash -c '
if ! command -v k9s >/dev/null 2>&1; then
  echo "Installing k9s..."
  curl -sS https://webinstall.dev/k9s | sh
  source ~/.config/envman/PATH.env
else
  echo "k9s already installed."
fi
'

# -------------------------
# Helmfile (idempotent installation)
# -------------------------
multipass exec $VM_NAME -- bash -c '
if ! command -v helmfile >/dev/null 2>&1; then
  echo "Installing Helmfile..."

  # Get latest release tag from GitHub API
  HELMFILE_LATEST=$(curl -s https://api.github.com/repos/helmfile/helmfile/releases/latest \
                   | grep "tag_name" \
                   | head -n 1 \
                   | awk -F ": " "{print \$2}" \
                   | tr -d "\",")
  
  # Download binary
  sudo curl -L "https://github.com/helmfile/helmfile/releases/download/${HELMFILE_LATEST}/helmfile_linux_amd64" \
    -o /usr/local/bin/helmfile

  sudo chmod +x /usr/local/bin/helmfile

  # Ensure helm-diff plugin is installed
  if ! helm plugin list | grep -q diff; then
    helm plugin install https://github.com/databus23/helm-diff
  fi

else
  echo "Helmfile already installed."
fi
'

echo "✅ Bootstrap complete for $VM_NAME"
