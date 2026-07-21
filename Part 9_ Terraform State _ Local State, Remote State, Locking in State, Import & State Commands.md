
### State File:
* State file is getting generated when we are running **terraform apply** command.
* State file consists all the information of terraform configuration. At the same time it will have all the information from Azure side as well. So, state file contains all the information from the terraform code side and the actual deployment side.
* State file is in json format.

### Relationship between Configuration File, State and Actual Infrastructure:
1. What would happen if only the Terraform Code is changed?
* Terraform will apply the changes to the actual infrastructure.

2. What would happen if only the state changed?
* Terraform will attempt to create the resources again during the apply process, but it will fail because the resources already exist.

3. What would happen if the actual infrastructure changed?
* Terraform will revert the manual changes made to the actual infrastructure and re-sync it with the code.



