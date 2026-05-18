# outputs.tf - Values exported by the network module
# Used by the compute module to place VMs in the correct subnets

output "subnet_app_id" {
  description = "ID of subnet-app where VM-1 and VM-2 will be placed"
  value       = azurerm_subnet.app.id
}

output "subnet_monitoring_id" {
  description = "ID of subnet-monitoring where VM-3 will be placed"
  value       = azurerm_subnet.monitoring.id
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

output "bastion_public_ip" {
  description = "Public IP of the Azure Bastion Host"
  value       = azurerm_public_ip.bastion.ip_address
}