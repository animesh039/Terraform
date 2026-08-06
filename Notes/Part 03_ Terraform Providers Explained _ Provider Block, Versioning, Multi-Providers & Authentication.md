
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
* **~>** Allows only the rightmost version component to increment. This format is referred to as the pessimistic constraint operator. For example, to allow new patch releases within a specific minor release, use the full version number:
     * ~> 1.0.4 Allows terraform to install 1.0.5 and 1.0.10 but not 1.1.0.
     * ~>1.1 Allows terraform to install 1.2 and 1.10 but not 2.0.

> **NOTE:** In most of the production use-case we are using ~> sign which is update the patch version and not major or minor version. Updating patch version doesn't introduce any breakthrough changes so it is safe to use it.


### Azure Provider Authentication Methods:
* What provider is doing, it is interacting with the Azure and to interact it has to authenticate with Azure, then only it will be able to deploy the resources in Azure.
* Even if we are using terraform portal to deploy the resources we have to login and based on the authentication and authorization we can create resources in Azure. Similarly if we are using terraform we have to authenticate with Azure and we have to use proper authentication method. There are multiple methods for terraform to authenticate with the Azure:
1. **Authenticating Using the Azure CLI:** This option is used when we are using terraform locally not by CI/CD. To deploy the resources from my laptop using terraform we can use Azure CLI. We are authentication Azure using the Azure CLI and terraform by default is using the Azure CLI mechanism to do the authentication from the terraform to Azure. It is the default mechanism for authentication and we don't have to mention anything. This was happening before 4.0 version of provider that the default subscription that we were choosing using the az cli was used to deploy the resources by default but after the version 4.0 of the provider, we have to mention the subscription ID in the provider block.
2. **Authenticating using Service Principal:** We will have the general provider block but with that we have to define the environment variable from the terminal. We can set this environment variable from anywhere else as well like CI/CD automation tools. If the terraform finds these values, then it will automatically use this mechanism to authenticate with the Azure cloud. Then we can use terraform init and plan to authenticate.
 ``` bash
export ARM_CLIENT_ID="xxxx"
export ARM_CLIENT_SECRET="xxxx"
export ARM_TENANT_ID="xxxx"
export ARM_SUBSCRIPTION_ID="xxxx"
```

3. **Authenticating using Service Principal:** We can also use the environment variable in the provider block as below. And then we don't have to configure the environment variable and we don't have to use az login. But if we are using this method, then we have to make sure that we are keeping the secrets in a more secure way as it is in a plain text in the code.

```hcl
terraform {
  required_providers {
    azurerm = {
      source = hashicorp/azurerm
      version ~> 3.70.0
    }
  }
}
provider "azurerm" {
  features {}
  client_id = "xxxx"
  client_secret = "xxxx"
  tenant_id = "xxxx"
  subscription_id = "xxxx"
}
```

4. **Authenticating to Azure using Managed Service Identity:** We can provide access to the service identity to the Azure.
5. **Authenticating to Azure using a Service Principal and a Client Certificate**
6. **Authenticating to Azure using OpenID Connect**

---

### Multiple Provider Configurations with Alias:
* Suppose we have a requirement to deploy some resources to Hub using one subscription and some to Spoke using other Subscription. We want to use the same same terraform config file to deploy resources to the Hub and Spoke Subscriptions. How to do that, as in the provider block we can use the subscription ID only once but here we have to use multi-subscription level deployment, then how to do it.

```hcl
terraform {
  required_providers {
    azurerm = {
      source = hashicorp/azurerm
      version = "4.14.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "aaaa"
  alias = "hub"
}
provider "azurerm" {
  features {}
  subscription_id = "bbbb"
  alias = "spoke1"
}
provider "azurerm" {
  features {}
  subscription_id = "ccc"
  alias = "spoke2"
}

resource "azurerm_resource_group" "hub_rg" {
  provider = azurerm.hub   --> This will make sure resource is deployed using Hub subscription

  name = "hub-resource-group"
  location = "westeurope"
}
resource "azurerm_resource_group" "hub_rg" {
  provider = azurerm.spoke1

  name = "spoke1-resource-group"
  location = "eastus2"
}
resource "azurerm_resource_group" "hub_rg" {
  provider = azurerm.spoke2

  name = "spoke2-resource-group"
  location = "eastus"
}
```
