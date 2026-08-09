resource "azurerm_resource_group" "rg-hub" {
  name = "rg-azt-hub-weu-01"
  location = "westeurope"
  tags = {
    DeploymentDate = timestamp()
    DeployedBy = "Terraform"
  }
  lifecycle {
    ignore_changes = [ tags["DeploymentDate"] ]
  }
}
resource "azurerm_resource_group" "rg-tst" {
  name = "rg-azt-tst-weu-01"
  location = "westeurope"
  tags = {
    DeploymentDate = timestamp()
    DeployedBy = "Terraform"
  }
  lifecycle {
    ignore_changes = [ tags["DeploymentDate"] ]
  }
}
resource "azurerm_resource_group" "rg-prd" {
  name = "rg-azt-prd-weu-01"
  location = "westeurope"
  tags = {
    DeploymentDate = timestamp()
    DeployedBy = "Terraform"
  }
  lifecycle {
    ignore_changes = [ tags["DeploymentDate"] ]
  }
}
resource "azurerm_network_security_group" "nsg-db-tst" {
  name = "nsg-db-tst-weu-01"
  location = azurerm_resource_group.rg-tst.location
  resource_group_name = azurerm_resource_group.rg-tst.name
}
resource "azurerm_network_security_group" "nsg-be-tst" {
  name = "nsg-be-tst-weu-01"
  location = azurerm_resource_group.rg-tst.location
  resource_group_name = azurerm_resource_group.rg-tst.name
}
resource "azurerm_network_security_group" "nsg-fe-tst" {
  depends_on = [azurerm_network_security_group.nsgnsg-be-tst, azurerm_network_security_group.nsgnsg-db-tst]
  name = "nsg-fe-tst-weu-01"
  location = azurerm_resource_group.rg-tst.location
  resource_group_name = azurerm_resource_group.rg-tst.name
}
resouece "azurerm_virtual_network" "vnet-tst" {
  name = "vnet-azt-tst-weu-01"
  location = azurerm_resource_group.rg-tst.location
  resource_group_name = azurerm_resource_group.rg-tst.name
  address_space = ["172.18.0.0/24"]
  subnet {
    name = "snet-db-tst-weu-01"
    address_prefixes = ["172.18.0.0/28"]
    security_group = azurerm_network_security_group.nsg-db-tst.id
  }
  subnet {
    name = "snet-be-tst-weu-01"
    address_prefixes = ["172.18.0.16/28"]
    security_group = azurerm_network_security_group.nsg-be-tst.id
  }
  subnet {
    name = "snet-fe-tst-weu-01"
    address_prefixes = ["172.18.0.48/28"]
    security_group = azurerm_network_security_group.nsg-fe-tst.id
  }
}
data "azurerm_key_vault" "hub-key-vault" {
  name = "mykeyvaultkv-azt-hub-weu-01"
  resource_group_name = "rg-azt-hub-weu-01"
}
data "azurerm_key_vault_secret" "vpn-shared-key" {
  name = "vpn-shared-key"
  key_vault_id = data.azurerm_key_vault.hub-key-vault.id
}

output "vnet-tst" {
  value = azurerm_virtual_network.vnet-tst.address_space
}
output "vpn-shared-key" {
  description = "VPN Shared Key"
  value = data.azurerm_key_vault_secret.vpn-shared-key.value
  sensitive = true
}
