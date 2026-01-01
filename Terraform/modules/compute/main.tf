data "aws_ami" "ecs_optimized_amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  
}
resource "aws_launch_template" "Task13-Launch-Template-Zaeem" {
  name_prefix   = "Task13-Launch-Template-Zaeem-"
  image_id      = data.aws_ami.ecs_optimized_amazon_linux_2.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.instance_security_group_id]
    delete_on_termination       = true
  }


  user_data = base64encode(<<EOF
              #!/bin/bash
              echo ECS_CLUSTER=Task13-ECS-Cluster-Zaeem >> /etc/ecs/ecs.config

              EOF
              )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Task13-Instance-Zaeem"
    }
  }
  
}

resource "aws_autoscaling_group" "Task13-ASG-Zaeem" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  launch_template {
    id      = aws_launch_template.Task13-Launch-Template-Zaeem.id
    version = "$Latest"
  }
  vpc_zone_identifier = [var.public_subnetA_id, var.public_subnetB_id]

  tag {
    key                 = "Name"
    value               = "Task13-Instance-Zaeem"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
  
}