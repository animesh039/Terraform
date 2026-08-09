
---

### Terraform Init:
* It will download the provider mentioned in the main.tf file.
* It will initialise our folder.
* terraform init

### Terraform Fmt:
* It is used to beautify the code.
* To format the code.
* terraform fmt
* terraform fmt --recursive

### Terraform Validate:
* Used to validate the terraform syntax only.
* terraform validate

### Terraform Plan:
* It is kind of dry-run.
* We can see what changes are going to be done if we apply the code, without applying it.
* It is always a good practice to run plan and carefully review it before applying the code.
* terraform plan

### Terraform Apply:
* This is the only command which actually makes changes in the Azure portal.
* With the terraform apply command also it will give the changes what is going to happen.
* terraform apply  --> Mostly used when doing manually
* terraform apply --auto-approve  --> Mostly used in CI/CD
* It will also create terraform.tfstate file, when it is run for the first time and gets updated in subsequent runs.

### Terraform Destroy:
* It is opposite to apply command.
* It will delete all the resources deployed through config file.
* Hardly used, only in sandbox environment.
* It is recommended not to use it in pipeline and use only manually by following 4 eye principle.


