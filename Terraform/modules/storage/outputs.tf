output "efs_id" {
  value = aws_efs_file_system.Task13-EFS-Zaeem.id
}

output "efs_ap_id" {
  value = aws_efs_access_point.Task13-EFS-AP-Zaeem.id
}

output "efs_arn" {
  value = aws_efs_file_system.Task13-EFS-Zaeem.arn
}

output "codepipeline_bucket" {
  value = aws_s3_bucket.Task13-CodePipeline-Bucket-Zaeem.bucket
}