TF_DIR = ./srcs/terraform
ANSIBLE_DIR = ./srcs/ansible
ANSIBLE_PLAYBOOK = playbook.yml
ANSIBLE_VAULT_PASS = .vault_password

all: deploy

deploy: terraform ansible

terraform:
	terraform -chdir=$(TF_DIR) init
	terraform -chdir=$(TF_DIR) apply -auto-approve

ansible:
	cd ./srcs/ansible && ansible-playbook $(ANSIBLE_PLAYBOOK) --vault-password-file $(ANSIBLE_VAULT_PASS)

clean:
	terraform -chdir=$(TF_DIR) destroy -auto-approve

off:
	terraform -chdir=$(TF_DIR) apply -var="desired_status=TERMINATED"

.PHONY: all deploy terraform ansible clean off