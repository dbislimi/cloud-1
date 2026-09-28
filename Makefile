-include .env
TF_DIR = ./srcs/terraform
ANSIBLE_DIR = ./srcs/ansible
ANSIBLE_PLAYBOOK = playbook.yml
ANSIBLE_VAULT_PASS = .vault_password

all: deploy

deploy: terraform hosts ansible

terraform:
	terraform -chdir=$(TF_DIR) fmt --recursive
	terraform -chdir=$(TF_DIR) init
	terraform -chdir=$(TF_DIR) apply -auto-approve

hosts:
	@domain=$$(terraform -chdir=$(TF_DIR) output -raw domain_name) && \
	ip=$$(terraform -chdir=$(TF_DIR) output -raw load_balancer_ip) && [ -n "$$ip" ] && \
	curl -fsS "https://www.duckdns.org/update?domains=$${domain%.duckdns.org}&token=$(DUCKDNSTOKEN)&ip=$$ip"

ansible:
	cd ./srcs/ansible && ansible-galaxy collection install -r requirements.yml
	cd ./srcs/ansible && ansible-playbook $(ANSIBLE_PLAYBOOK) --vault-password-file $(ANSIBLE_VAULT_PASS)

clean:
	terraform -chdir=$(TF_DIR) destroy -auto-approve

off:
	terraform -chdir=$(TF_DIR) apply -var="desired_status=TERMINATED" -auto-approve

on:
	terraform -chdir=$(TF_DIR) apply -var="desired_status=RUNNING" -auto-approve

reboot: off on

re: clean all

.PHONY: all deploy terraform hosts ansible clean off on re reboot