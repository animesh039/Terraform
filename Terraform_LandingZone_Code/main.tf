


``` hcl
resource "azurerm_resource_group" "rg-hub" {
  name = "rg-azt-hub-weu-01"
  location = "westeurope"
  tags = {
    "DeploymentDate" = "14052025"
  }
}
resource "azurerm_resource_group" "rg-tst" {
  name = "rg-azt-tst-weu-01"
  location = "westeurope"
  tags = {
    "DeploymentDate" = "14052025"
  }
}
resource "azurerm_resource_group" "rg-prd" {
  name = "rg-azt-prd-weu-01"
  location = "westeurope"
  tags = {
    "DeploymentDate" = "14052025"
  }
}
```
