output "private_subnetA_id" {
  value = aws_subnet.Task13-Private-Subnet-A-Zaeem.id
}

output "private_subnetB_id" {
  value = aws_subnet.Task13-Private-Subnet-B-Zaeem.id
}

output "public_subnetA_id" {
  value = aws_subnet.Task13-Public-Subnet-A-Zaeem.id
}
output "public_subnetB_id" {
  value = aws_subnet.Task13-Public-Subnet-B-Zaeem.id
}

output "vpc_id" {
  value = aws_vpc.Task13-VPC-Zaeem.id
}

output "instance_security_group_id" {
  value = aws_security_group.Task13-EC2-SG-Zaeem.id
}

output "efs_sg_id" {
  value = aws_security_group.Task13-EFS-SG-Zaeem.id
}

output "alb_security_group_id" {
  value = aws_security_group.Task13-ALB-SG-Zaeem.id
}