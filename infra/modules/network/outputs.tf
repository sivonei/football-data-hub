# outputs.tf - Values exported by the network module
# These values are used by the compute module to place VMs in the correct network

# Subnet ID - needed to attach VMs to the correct subnet
output "subnet_id" {
  description = "ID of the subnet where VMs will be placed"
  value       = azurerm_subnet.main.id
}

# NSG ID - needed to associate VMs with the security group
output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}