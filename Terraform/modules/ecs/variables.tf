variable "instance_security_group_id" {
    description = "The security group ID to associate with the ALB."
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

variable "target_group_arn" {
    description = "The ARN of the target group for the ALB."
    type        = string
}

variable "asg_arn" {
  
}

variable "efs_id" {
  
}

variable "efs_ap_id" {
  
}

variable "exec_role_arn" {
  
}

variable "task_role_arn" {
  
}

variable "image_tag" {
  
}