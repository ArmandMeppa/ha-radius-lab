#!/usr/bin/env bash
set -e

VM_NAME=${1:-k3s}

echo "🔹 Bootstrapping VM: $VM_NAME"

# -------------------------
# Mount path to VM
# -------------------------
# if ! multipass info $VM_NAME | grep -q "Mounts:"; then
#   echo "Mounting current directory to $VM_NAME..."
#   multipass mount "$(pwd)" $VM_NAME:/home/ubuntu/ha-radius-lab
# else
#   echo "Directory already mounted to $VM_NAME."
# fi


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
  HELMFILE_INSTALL_PATH="/usr/local/bin/helmfile"
  HELMFILE_LATEST="1.2.3"
  HELMFILE_TAR="helmfile_${HELMFILE_LATEST}_linux_amd64.tar.gz"

  mkdir -p /tmp/helmfile
  cd /tmp/helmfile
  
  pwd

  # Download binary
  wget "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_LATEST}/helmfile_${HELMFILE_LATEST}_linux_amd64.tar.gz"

  sudo tar -xzf ./$HELMFILE_TAR

  sudo mv ./helmfile ${HELMFILE_INSTALL_PATH}
  sudo chmod +x ${HELMFILE_INSTALL_PATH}

  rm -rf /tmp/helmfile

  # Ensure helm-diff plugin is installed
  if ! helm plugin list | grep -q diff; then
    cd /home/ubuntu || echo "Home directory not found"
    helm plugin install https://github.com/databus23/helm-diff
  else
    echo "Helm diff plugin already installed."
  fi

else
  echo "Helmfile already installed."
fi
'

echo "✅ Bootstrap complete for $VM_NAME"
