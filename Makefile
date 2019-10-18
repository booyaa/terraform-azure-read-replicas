.PHONY: setup build deploy clean upload terraform_apply

azure.tfvars:
	@echo 'owner="YOUR_NAME"' > azure.tfvars
	@echo 'location="AZURE_LOCATION"' >> azure.tfvars
	@echo 'admin_login="PSQL_ADMIN_LOGIN"' >> azure.tfvars
	@echo 'admin_password="PSQL_ADMIN_PASS"' >> azure.tfvars

setup: azure.tfvars

build:
	@test -f azure.tfvars || (echo 'run `make setup` and update values in azure.tfvars' && exit -1)
	@terraform init
	@terraform plan -var-file azure.tfvars -out out.plan

deploy: 
	@test -f azure.tfvars || (echo 'run `make setup` and update values in azure.tfvars' && exit -1)
	@terraform apply out.plan

clean:
	@test -f azure.tfvars || (echo 'run `make setup` and update values in azure.tfvars' && exit -1)
	terraform destroy -var-file azure.tfvars

