variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for networking resources"
  type        = string
  default     = "nsphere-networking-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Germany West Central"
}
