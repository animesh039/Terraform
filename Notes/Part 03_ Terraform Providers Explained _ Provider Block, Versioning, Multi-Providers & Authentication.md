
---

### Providers Overview:
* We have a resource block which is supposed to deploy a resource in Azure. Whenever we are writing a configuration in terraform, we are also writing a provider block. We are indicating where this resource block should execute or where it should go to deploy the resources.
* When we apply the terraform configuration, it will go to the Hashicorp registry where we have all the providers.
* There is a way in Azure to deploy the resources through API as well, apart from the Powershell, CLI or the Portal. We can also deploy the resources in Azure using the API calls. It is mentioned in Microsoft documentation, but it is very tedious process and not that user friendly. We have the URL, first we have to generate the Bearer token for authentication, then we provide all the header, body and all the required parameters. Then we make the POST API call, GET API call, if we want to update something then we do the PATCH, if we want to delete something then we do the DELETE call. But the format is not easy to remember, it's not easy to write and it's not that helpful.
* What Terraform does is that it has a provider which is also a plugin, where Terraform is converting the configuration file or the Hashicorp coding format to API format and it will just trigger the API call to the Microsoft Azure and it will deploy the resources. So, basically Terraform is converting from the way we are writing the code in Hashicorp language to the API call and trigger it. It also makes sure that the code is converted to proper API format with all the conditionals and trigger it.
* Terraform makes it simple to write the IAC in a simple format. So, whenever we are writing the code we have to mention which provider and which cloud we are going to use. Based on the cloud we are using, the provider comes into picture.
* Provider is a package and it has the version. Why do we have version for Providers?
    * Because the Azure APIs also have different versions. Lets assume that there are new things introduced in the Azure like a new field or something, they are updating the API calls. Similarly the provider version in terraform is also getting updated.
 
> **NOTE:** So, provider is a package which is helping to convert the terraform configuration file into the API call, triggering it and deploying the resources. Based on the provider we can decide which cloud we are working on.


### Providers Block:
* feature block is mandatory inside it, even though we are not using it.
``` hcl
provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  storage_use_azuread = true
  environment = "german"
} 
```
* By default, when VM is deleted OS disk is not deleted. If we want that whenever VM is deleted OS disk should also delete, so we can use that in feature block to overwrite the default settings. We can check the terraform documentation to check what arguments can be put in the provider block.
* terraform init will download the provider from terraform registry. Signed by Hashicorp means that it is the official provider. ".terraform" folder contains the provider. ".terraform.lock.hcl" contains the hash thumbprint of that particular provider just to make sure that the provider which we have downloaded is the authentic and genuine one. It also locks the version of provider which was downloaded so that it doesn't get changed when we are re-running the terraform init command. So, these two files are getting downloaded as soon as we are running terraform init.
* With the terraform provider version for Azure 4.0 and onwards, it requires the subscription ID od the subscription where we want to deploy the resources. Without the subscription ID we will not be able to do the terraform initialization.
* "terraform init" command will search for the provider block in terraform code and it will download and keep the provider the the folder.
* It is not advisable to put the ".terraform" folder to the Git repository as this is very large file and the push will not work as well because they have the size limitation of the per file to be uploaded. So, we can use .gitignore file to ignore it as whenever we are running the init command it will download it anyways. Also, it is advisable to add the ".terraform.lock.hcl" file into the Git repo as it will help to download the same version of provider during the next terraform init.
* We can also have more than one provider in the same terraform code. So , we can see that there are multiple registry folders under the providers folder which will contain different providers.
* Terraform provider exe file is basically a code which is connecting our cloud provider from the terraform.

### Providers Version Management:
* To manage the provider version, the very first thing which we have to write is the terraform setting block. In the terraform setting block we can manage settings like terraform related settings, we can also mention that which particular version of the provider we want and from which registry it should be downloaded just in case if we are not using the default registry of Hashicorp.

``` hcl
terraform {
  required_providers {
    azurerm = {
      source = hashicorp/azurerm
      version ~> 3.70.0
    }
  }
}
```
* Why are we using a version and why not the latest version?
    * Like any other application, the versioning here also is coming with new changes and there might be a possibility that those changes may be a break through changes which might impact our code and terraform configuration, which might impact the actual infra if we are not making it constant.
 
### Version Constraint:
* **=(or no operator)** Allows only one exact version number. Can't be combined with other versions.
* **!=** Excludes an exact version number.
* **>,>=,<,<=** Comparisons against a specified version, allowing versions for which the comparison is true. "Greater-than" requests newer versions, and "less-than" requests older versions.
* **~>** Allows only the rightmost version component to increment. This format is referred to as the pessimistic constraint operator. For example, to allow new patch releases within a specific minor release, use the full version number: ~> 1.0.4 Allows terraform to install 1.0.5 and 1.0.10 but not 1.1.0.  ~>1.1 Allows terraform to install 1.2 and 1.10 but not 2.0.
* 
