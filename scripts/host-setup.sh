#!/usr/bin/env bash
set -e

echo "🔹 Checking required tools..."

install_if_missing() {
    if ! command -v $1 >/dev/null 2>&1; then
        echo "❌ $1 not found. Installing..."
        $2
    else
        echo "✅ $1 already installed."
    fi
}

# Update package list
sudo apt update -y

# --------------------------
# Basic tools
# --------------------------
install_if_missing make "sudo apt install -y make"
install_if_missing curl "sudo apt install -y curl"
install_if_missing unzip "sudo apt install -y unzip"

# --------------------------
# Multipass
# --------------------------
install_if_missing multipass "sudo snap install multipass --classic"

# --------------------------
# Terraform (HashiCorp Recommended)
# --------------------------
if ! command -v terraform >/dev/null 2>&1; then
    echo "Installing Terraform..."
    sudo apt install -y gnupg software-properties-common
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update -y
    sudo apt install -y terraform
else
    echo "✅ Terraform already installed."
fi

# --------------------------
# Ansible
# --------------------------
install_if_missing ansible "sudo apt install -y ansible"

echo "✅ Host setup complete."
terraform version | head -n 1
ansible --version | head -n 1
multipass version
