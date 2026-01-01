resource "aws_ecs_cluster" "Task13-ECS-Cluster-Zaeem" {
  name = "Task13-ECS-Cluster-Zaeem"
  
}

resource "aws_ecs_task_definition" "Task13-ECS-Task-Definition-Zaeem" {
  family                   = "Task13-ECS-Task-Definition-Zaeem"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "256"
  execution_role_arn       = var.exec_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "NodeJS-App"
      image     = "880958245574.dkr.ecr.us-west-2.amazonaws.com/task13/zaeem:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "efs-storage"
          containerPath = "/mnt/efs"
          readOnly      = false
        }
      ]
    }
      
  ])

  volume {
    name = "efs-storage"

    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_ap_id
      }
    }
  }

  tags = {
    Name = "Task13-ECS-Task-Definition-Zaeem"
  }
}

resource "aws_ecs_capacity_provider" "Task13-ECS-Capacity-Provider-Zaeem" {
  name = "Task13-ECS-Capacity-Provider-Zaeem"

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.asg_arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 2
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }

    managed_termination_protection = "DISABLED"
  }
  
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.Task13-ECS-Cluster-Zaeem.name

  capacity_providers = [aws_ecs_capacity_provider.Task13-ECS-Capacity-Provider-Zaeem.name]

  default_capacity_provider_strategy {
    base              = 2
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.Task13-ECS-Capacity-Provider-Zaeem.name
  }
}

resource "aws_ecs_service" "Task13-ECS-Service-Zaeem" {
  name            = "Task13-ECS-Service-Zaeem"
  cluster         = aws_ecs_cluster.Task13-ECS-Cluster-Zaeem.id
  task_definition = aws_ecs_task_definition.Task13-ECS-Task-Definition-Zaeem.arn
  desired_count   = 2
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "NodeJS-App"
    container_port   = 5000
  }

  tags = {
    Name = "Task13-ECS-Service-Zaeem"
  }
  
}

