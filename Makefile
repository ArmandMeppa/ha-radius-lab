VM_NAME=k3s

.PHONY: init apply bootstrap up destroy

init:
	cd terraform && terraform init

apply:
	cd terraform && terraform apply -auto-approve

bootstrap:
	./scripts/bootstrap-k3s.sh $(VM_NAME)

deploy-platform:
	@echo "Mounting project directory if not already mounted..."
	@if ! multipass info k3s | grep -q '/home/ubuntu/ha-radius-lab'; then \
	  echo "Mounting project directory..."; \
	  multipass mount . k3s:/home/ubuntu/ha-radius-lab; \
	else \
	  echo "/home/ubuntu/ha-radius-lab already mounted"; \
	fi
	multipass exec k3s -- bash -c 'sudo chmod +x  /home/ubuntu/ha-radius-lab/scripts/m3-bootstrap.sh'
	multipass exec k3s -- bash -c '/home/ubuntu/ha-radius-lab/scripts/m3-bootstrap.sh'

up: init apply bootstrap deploy-platform

logs:
	@echo "ℹ️  Multipass VM info:"
	@multipass info $(VM_NAME)

destroy:
	cd terraform && terraform destroy -auto-approve || true
