terraform_options = rm -rfv .terraform/modules && terraform init && terraform $(filter-out $@,$(MAKECMDGOALS))

.PHONY: help fmt validate-all organizations identity cross-account-iam shared-services production sandbox

help:
	@echo "Available targets:"
	@echo "  make fmt                     Format all Terraform files"
	@echo "  make validate-all            Initialize and validate all stacks"
	@echo ""
	@echo "  make organizations plan      Plan organizations stack"
	@echo "  make organizations apply     Apply organizations stack"
	@echo "  make identity plan           Plan identity stack"
	@echo "  make identity apply          Apply identity stack"
	@echo "  make cross-account-iam plan  Plan cross-account IAM stack"
	@echo "  make cross-account-iam apply Apply cross-account IAM stack"
	@echo "  make shared-services plan    Plan shared-services stack"
	@echo "  make shared-services apply   Apply shared-services stack"
	@echo "  make production plan         Plan production stack"
	@echo "  make production apply        Apply production stack"
	@echo "  make sandbox plan            Plan sandbox stack"
	@echo "  make sandbox apply           Apply sandbox stack"

fmt:
	terraform fmt -recursive

validate-all:
	cd aws/organizations/management/organizations && terraform init -backend=false && terraform validate
	cd aws/organizations/management/identity && terraform init -backend=false && terraform validate
	cd aws/organizations/management/cross-account-iam && terraform init -backend=false && terraform validate
	cd aws/organizations/management/shared-services && terraform init -backend=false && terraform validate
	cd aws/organizations/workloads/production && terraform init -backend=false && terraform validate
	cd aws/organizations/workloads/sandbox && terraform init -backend=false && terraform validate

organizations:
	cd aws/organizations/management/organizations; $(terraform_options)

identity:
	cd aws/organizations/management/identity; $(terraform_options)

cross-account-iam:
	cd aws/organizations/management/cross-account-iam; $(terraform_options)

shared-services:
	cd aws/organizations/management/shared-services; $(terraform_options)

production:
	cd aws/organizations/workloads/production; $(terraform_options)

sandbox:
	cd aws/organizations/workloads/sandbox; $(terraform_options)
