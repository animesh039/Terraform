
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

### Local State File:
* Pros: Simplicity, Speed, No External Dependency.
* Cons:
    * **Concurrency Issues:** If there are multiple team members working on the same environment, then the state files will be created on everyone's local laptop. So, other person will not be aware which resources got created and can't use the resources created by someone else as the state file is not the same.
    * **Lack of Collaboration:** Team members will not be able to extend the code or add more resources to the configuration file as the state file is not common and code is also on different laptops.
    * **Security Risks:** State file contains all the details of the infrastructure, and if it is kept in local laptop and it gets compromised then all the information about infra will be leaked.
    * **Risk of the Data Loss:** If we accidently deleted the state file, then the whole configuration file will be of no use. Though we have option to import the resources but that is difficult task.
    * **No State History:** There is no versioning of the state file if we keep it locally.

