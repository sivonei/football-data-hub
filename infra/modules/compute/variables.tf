# variables.tf - Input variables for the compute module

variable "project_name" {
  description = "Project name used to name compute resources"
  type        = string
}

variable "location" {
  description = "Azure region where VMs will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where VMs will be created"
  type        = string
}

variable "subnet_app_id" {
  description = "ID of subnet-app where VM-1 and VM-2 will be placed"
  type        = string
}

variable "subnet_monitoring_id" {
  description = "ID of subnet-monitoring where VM-3 will be placed"
  type        = string
}

variable "vm_size" {
  description = "Size of the Azure VMs"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used to access the VMs"
  type        = string
}