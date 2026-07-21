init: fmt
	terraform init

on: init
	terraform apply

off:
	terraform apply -var="desired_status=TERMINATED"

destroy:
	terraform destroy

fmt:
	terraform fmt

.PHONY: init on off destroy fmt