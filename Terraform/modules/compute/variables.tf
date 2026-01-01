variable "instance_security_group_id" {
  description = "The security group ID to associate with the compute instances."
  type        = string
  
}

variable "public_subnetA_id" {
  description = "The ID of the public subnet A."
  type        = string
  
} 
variable "public_subnetB_id" {
  description = "The ID of the public subnet B."
  type        = string
  
}

variable "ecs_instance_profile_name" {
  description = "The name of the ECS instance profile."
  type        = string
  
}