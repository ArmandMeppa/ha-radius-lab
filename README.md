# HA Radius Lab

## Requirements

- multipass
- terraform
- ansible
- make

## Setup

- Set the host machine up

```bash
# Make the script executable
chmod +x ./scripts/host-setup.sh

# Launch the script
./scripts/host-setup.sh
```

- Provide and provision the k8s infra
```bash
make up
```

## Verify
```bash
make logs
```

## Destroy
```bash
make destroy
```
