output "exec_role_arn" {
  value = aws_iam_role.Task13_Task_Execution_Role.arn
}

output "task_role_arn" {
    value = aws_iam_role.Task13_Task_Role.arn
  
}

output "ecs_instance_profile_name" {
  value = aws_iam_instance_profile.Task13_ECS_Instance_Profile.name
}

output "codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}