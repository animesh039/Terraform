output "output_public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "output_public_ip_address_id" {
  value = azurerm_public_ip.public_ip.id
}