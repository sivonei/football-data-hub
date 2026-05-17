# outputs.tf - Values exported by the compute module
# These values are used by main.tf to display VM IPs after the Terraform apply command.
# Outputs are a way to expose values from a module to be used in other parts of the configuration or for informational purposes.

# Export the public IP address of VM-1
# This IP is used to access the API and the primary Redis instance from outside the network.
output "vm1_public_ip" {
  description = "Public IP address of VM-1 (API + Redis primary)"
  value       = azurerm_public_ip.vm1.ip_address
}

# Export the public IP address of VM-2
# This IP is used to access the API and the Redis replica instance from outside the network.
output "vm2_public_ip" {
  description = "Public IP address of VM-2 (API + Redis replica)"
  value       = azurerm_public_ip.vm2.ip_address
}

# Export the public IP address of VM-3
# This IP is used to access monitoring tools like Prometheus and Grafana from outside the network.
output "vm3_public_ip" {
  description = "Public IP address of VM-3 (Prometheus + Grafana)"
  value       = azurerm_public_ip.vm3.ip_address
}

# Export the private IP address of VM-1
# This IP is used for internal communication within the virtual network, such as between VMs.
output "vm1_private_ip" {
  description = "Private IP address of VM-1 used for internal communication"
  value       = azurerm_network_interface.vm1.private_ip_address
}

# Export the private IP address of VM-2
# This IP is used for internal communication within the virtual network, such as between VMs.
output "vm2_private_ip" {
  description = "Private IP address of VM-2 used for internal communication"
  value       = azurerm_network_interface.vm2.private_ip_address
}

# Export the private IP address of VM-3
# This IP is used for internal communication within the virtual network, such as between VMs.
output "vm3_private_ip" {
  description = "Private IP address of VM-3 used for internal communication"
  value       = azurerm_network_interface.vm3.private_ip_address
}