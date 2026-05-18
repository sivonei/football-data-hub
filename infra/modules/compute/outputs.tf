# outputs.tf - Values exported by the compute module

output "vm1_private_ip" {
  description = "Private IP of VM-1 - API + Redis primary"
  value       = azurerm_network_interface.vm1.private_ip_address
}

output "vm2_private_ip" {
  description = "Private IP of VM-2 - API + Redis replica"
  value       = azurerm_network_interface.vm2.private_ip_address
}

output "vm3_private_ip" {
  description = "Private IP of VM-3 - Prometheus + Grafana"
  value       = azurerm_network_interface.vm3.private_ip_address
}