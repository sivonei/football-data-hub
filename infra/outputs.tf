# outputs.tf - Values displayed after terraform apply

output "bastion_public_ip" {
  description = "Public IP of Azure Bastion - use this to connect to VMs"
  value       = module.network.bastion_public_ip
}

output "vm1_private_ip" {
  description = "Private IP of VM-1 - API + Redis primary"
  value       = module.compute.vm1_private_ip
}

output "vm2_private_ip" {
  description = "Private IP of VM-2 - API + Redis replica"
  value       = module.compute.vm2_private_ip
}

output "vm3_private_ip" {
  description = "Private IP of VM-3 - Prometheus + Grafana"
  value       = module.compute.vm3_private_ip
}

output "grafana_tunnel_command" {
  description = "SSH tunnel command to access Grafana in the browser"
  value       = "ssh -L 3000:10.0.2.4:3000 azureuser@${module.network.bastion_public_ip} -i ~/.ssh/eve"
}

output "ssh_vm1" {
  description = "SSH command to connect to VM-1 via Bastion"
  value       = "az network bastion ssh --name ${var.project_name}-bastion --resource-group ${var.project_name}-rg --target-ip-address 10.0.1.4 --auth-type ssh-key --username azureuser --ssh-key ~/.ssh/eve"
}

output "ssh_vm2" {
  description = "SSH command to connect to VM-2 via Bastion"
  value       = "az network bastion ssh --name ${var.project_name}-bastion --resource-group ${var.project_name}-rg --target-ip-address 10.0.1.5 --auth-type ssh-key --username azureuser --ssh-key ~/.ssh/eve"
}

output "ssh_vm3" {
  description = "SSH command to connect to VM-3 via Bastion"
  value       = "az network bastion ssh --name ${var.project_name}-bastion --resource-group ${var.project_name}-rg --target-ip-address 10.0.2.4 --auth-type ssh-key --username azureuser --ssh-key ~/.ssh/eve"
}