VM_NAME=k3s

.PHONY: init apply bootstrap up destroy

init:
	cd terraform && terraform init

apply:
	cd terraform && terraform apply -auto-approve

bootstrap:
	./scripts/bootstrap-k3s.sh $(VM_NAME)

up: init apply bootstrap

logs:
	@echo "ℹ️  Multipass VM info:"
	@multipass info $(VM_NAME)

destroy:
	cd terraform && terraform destroy -auto-approve || true
