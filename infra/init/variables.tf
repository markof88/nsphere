variable "environment" {
  description = "The environment name."
  type        = string
}

variable "initial_user_admin_object_id" {
  description = "Object ID of the user/service principal setting up the backend."
  type        = string
  
}

variable "subscription_id" {
  description = "The subscription ID to use"
  type        = string
}
