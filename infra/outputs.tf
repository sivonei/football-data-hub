# outputs.tf - Values displayed after terraform apply
# Shows the IP addresses needed to access the VMs

output "vm1_public_ip" {
  description = "Public IP of VM-1 - API + Redis primary"
  value       = module.compute.vm1_public_ip
}

output "vm2_public_ip" {
  description = "Public IP of VM-2 - API + Redis replica"
  value       = module.compute.vm2_public_ip
}

output "vm3_public_ip" {
  description = "Public IP of VM-3 - Prometheus + Grafana"
  value       = module.compute.vm3_public_ip
}

output "vm1_private_ip" {
  description = "Private IP of VM-1 - used for internal communication"
  value       = module.compute.vm1_private_ip
}

output "vm2_private_ip" {
  description = "Private IP of VM-2 - used for internal communication"
  value       = module.compute.vm2_private_ip
}

output "vm3_private_ip" {
  description = "Private IP of VM-3 - used for internal communication"
  value       = module.compute.vm3_private_ip
}

output "ssh_connection" {
  description = "SSH commands to connect to each VM"
  value = {
    vm1 = "ssh azureuser@${module.compute.vm1_public_ip} -i ~/.ssh/eve"
    vm2 = "ssh azureuser@${module.compute.vm2_public_ip} -i ~/.ssh/eve"
    vm3 = "ssh azureuser@${module.compute.vm3_public_ip} -i ~/.ssh/eve"
  }
}