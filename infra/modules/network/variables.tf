# variables.tf - Input variables for the network module

variable "project_name" {
  description = "Project name used to name network resources"
  type        = string
}

variable "location" {
  description = "Azure region where network resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where network will be created"
  type        = string
}