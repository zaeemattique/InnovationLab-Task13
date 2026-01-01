##########################################################
# ECS EC2 Role
##########################################################
resource "aws_iam_role" "Task13_ECS_EC2_Role" {
  name = "Task13-ECS-EC2-Role-Zaeem"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "Task13_ECS_EC2_Role_Attach" {
  role       = aws_iam_role.Task13_ECS_EC2_Role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "Task13_ECS_Instance_Profile" {
  name = "Task13-ecs-instance-profile-Zaeem"
  role = aws_iam_role.Task13_ECS_EC2_Role.name
}

##########################################################
# ECS Task Execution Role
##########################################################
resource "aws_iam_role" "Task13_Task_Execution_Role" {
  name = "Task13-ecs-task-execution-role-Zaeem"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "Task13_Task_Execution_Attach" {
  role       = aws_iam_role.Task13_Task_Execution_Role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##########################################################
# ECS Task Role
##########################################################
resource "aws_iam_role" "Task13_Task_Role" {
  name = "Task13-ecs-task-role-Zaeem"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "Task13_Task_EFS_Policy" {
  name = "Task13-ecs-task-efs-policy-Zaeem"
  role = aws_iam_role.Task13_Task_Role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:DescribeFileSystems"
      ],
      Resource = var.efs_arn
    }]
  })
}

##########################################################
# CodePipeline Role
##########################################################
data "aws_iam_policy_document" "pipeline_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "Task13-CodePipeline-Role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_assume_role.json
}

resource "aws_iam_role_policy" "codepipeline_ecs_policy" {
  name = "Task13-CodePipeline-ECS-Policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "TaskDefinitionPermissions"
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Sid = "ECSServicePermissions"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService"
        ]
        # Replace YOUR_ACCOUNT_ID with your AWS account ID
        Resource = "arn:aws:ecs:*:880958245574:service/*/*"
      },
      {
        Sid = "ECSTagResource"
        Effect = "Allow"
        Action = "ecs:TagResource"
        Resource = "arn:aws:ecs:*:880958245574:task-definition/*:*"
        Condition = {
          StringEquals = {
            "ecs:CreateAction" = "RegisterTaskDefinition"
          }
        }
      },
      {
        Sid = "IamPassRolePermissions"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "arn:aws:iam::880958245574:role/*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = [
              "ecs.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.codepipeline_bucket}",
          "arn:aws:s3:::${var.codepipeline_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_s3_policy" {
  name = "Task13-CodePipeline-S3-Policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCodePipelineAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          "arn:aws:s3:::${var.codepipeline_bucket}",
          "arn:aws:s3:::${var.codepipeline_bucket}/*"
        ]
      }
    ]
  })
}


##########################################################
# CodeBuild Role
##########################################################
resource "aws_iam_role" "codebuild_role" {
  name = "Task13-CodeBuild-Role-Zaeem"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "Task13-CodeBuild-Policy"

  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # ECR pull/push
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "*"
      },

      # S3 artifacts
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.codepipeline_bucket}",
          "arn:aws:s3:::${var.codepipeline_bucket}/*"
        ]
      },

      # Logs
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

