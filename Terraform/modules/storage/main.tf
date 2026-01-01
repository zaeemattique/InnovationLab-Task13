resource "aws_efs_file_system" "Task13-EFS-Zaeem" {
  creation_token = "Task13-EFS-Zaeem"

  tags = {
    Name = "Task13-EFS-Zaeem"
  }
  
}

resource "aws_efs_access_point" "Task13-EFS-AP-Zaeem" {
  file_system_id = aws_efs_file_system.Task13-EFS-Zaeem.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/"

    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = "Task13-EFS-AP-Zaeem"
  }
  
}

resource "aws_efs_mount_target" "Task13-EFS-MT-PrivateA-Zaeem" {
  file_system_id  = aws_efs_file_system.Task13-EFS-Zaeem.id
  subnet_id       = var.private_subnetA_id
  security_groups = [var.efs_security_group_id]
  
}

resource "aws_efs_mount_target" "Task13-EFS-MT-PrivateB-Zaeem" {
  file_system_id  = aws_efs_file_system.Task13-EFS-Zaeem.id
  subnet_id       = var.private_subnetB_id
  security_groups = [var.efs_security_group_id]
  
}

resource "aws_s3_bucket" "Task13-CodePipeline-Bucket-Zaeem" {
  bucket = "task13-codepipeline-bucket-zaeem"
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.Task13-CodePipeline-Bucket-Zaeem.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}