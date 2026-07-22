
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
* **Pros:**
     * **Simplicity:** We dont have to write any code for it.
     * **Speed:** terraform commands will be fast as state file is locally stored so it doesn't have to go somewhere to read the state file.
     * **No External Dependency:** As it is stored locally, so there is no dependency.
* **Cons:**
    * **Concurrency Issues:** If there are multiple team members working on the same environment, then the state files will be created on everyone's local laptop. So, other person will not be aware which resources got created and can't use the resources created by someone else as the state file is not the same.
    * **Lack of Collaboration:** Team members will not be able to extend the code or add more resources to the configuration file as the state file is not common and code is also on different laptops.
    * **Security Risks:** State file contains all the details of the infrastructure, and if it is kept in local laptop and it gets compromised then all the information about infra will be leaked.
    * **Risk of the Data Loss:** If we accidently deleted the state file, then the whole configuration file will be of no use. Though we have option to import the resources but that is difficult task.
    * **No State History:** There is no versioning of the state file if we keep it locally.

> **NOTE:** In Production, we use Remote State.

### Remote State (Backend):
* We can store the state file in remote storage which can be Azure Storage Account, AWS S3, Hashicorp Consul, Google Cloud Storage.
* **Benefits:**
     * **Concurrency and Collaboration:** Multiple people can work on same same state file and contribute in coding.
     * **State Locking:** Only one user can apply a change at a time and during this state file will be locked.
     * **Security and Access Control:** We can configure security and access control on the storage account.
     * **Disaster Recovery and Replication:** We can apply the benefits of storage account to state file as well.
     * **State History and Versioning:** We can enable versioning and history with the help of storage accounts.

### Remote State (Backend) Configuration:
##### Ways to configure Backend:
1. Backend Block:
``` hcl
terraform {
  backend "azurerm" {
    resource_group_name = "tfstate-rg"
    storage_account_name = "terraformstatestgacc01"
    container_name = "terraform-state"
    key = "prod.tfstate"                       --> name of the state file
  }
}
```
2. Command Line: Configure at Runtime
``` bash
terraform init -backend-config="resource_group_name=tfstate-rg" -backend-config="storage_account_name=terraformstatestgacc01" -backend-config="container_name=terraform-state" -backend-config="key=prod.tfstate"
```
3. Backend File: We can create a file .backend and store the backend details of different environments in different files.
* Create a file **prod.backend:**
``` hcl
resource_group_name = "tfstate-rg"
storage_account_name = "terraformstatestgacc01"
container_name = "terraform-state"
key = "prod.tfstate"
```
* The configuration in the terraform block will remain as it is but only the arguments and values will move to prod.backend file.
After that Run:
``` bash
terraform init -backend-config="prod.backend"
```

> **NOTE:** There can be a scenario where we want to create our resources in Azure and keep our state file in AWS OR we want to create our resources on Azure in different subscription and create our resources in different subscription. For this terraform has to be authenticated with the remote backend.

### Remote Backend Authentication Type for Azure.
##### Authentication Types:
1. **Access Key:** With access key also we have multiple ways to configure the authentication.
    * **User Principal via Azure CLI:** This is the default authentication mechanism which we were using till now. If we don't mention any authentication mechanism, then it will be used. So, whatever account we have logged in from the Azure CLI will be taken into consideration and from that account the storage account will try to authenticate. If permission is not there then account will not be accessible. For this to work make sure "Allow Storage Key Access" is Enabled from the Azure portal in the Storage account configuration.
    * **Service Principal via Client Secret:** This is not the default authentication mechanism, so we have to make some changes in the backend block to use this authentication method. This is mostly used in Pipeline.
``` hcl
terraform {
  backend "azurerm" {
    resource_group_name = "tfstate-rg"
    storage_account_name = "terraformstatestgacc01"
    container_name = "terraform-state"
    key = "prod.tfstate"
  }
}
```  
* **Service Principal via Client Certificate:**
* 
2. 
