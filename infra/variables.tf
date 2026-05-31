# variables.tf - Global variables for the Football Data Hub infrastructure

variable "project_name" {
  description = "Name of the project, used to name all resources"
  type        = string
  default     = "football-data-hub"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "spaincentral"
}

variable "vm_size" {
  description = "Size of the Azure VMs"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used to access the VMs"
  type        = string
  default     = "~/.ssh/eve.pub"
}