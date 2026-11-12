output "log_bucket_id" {
  description = "Name of the log bucket."
  value       = aws_s3_bucket.logs.id
}

output "log_bucket_arn" {
  description = "ARN of the log bucket."
  value       = aws_s3_bucket.logs.arn
}

output "password_policy_expire_passwords" {
  description = "Whether the account password policy expires passwords."
  value       = aws_iam_account_password_policy.this.expire_passwords
}

output "log_bucket_versioning_status" {
  description = "Versioning status of the log bucket."
  value       = aws_s3_bucket_versioning.logs.versioning_configuration[0].status
}

output "s3_account_public_access_block_enabled" {
  description = "Whether the account-wide S3 public access block is managed by this module."
  value       = var.enable_s3_account_public_access_block
}

output "ebs_encryption_by_default_enabled" {
  description = "Whether EBS encryption by default is enabled in the region."
  value       = aws_ebs_encryption_by_default.this.enabled
}

output "ebs_snapshot_block_public_access_state" {
  description = "Block public access mode for EBS snapshots in the region, or null when unmanaged."
  value       = one(aws_ebs_snapshot_block_public_access.this[*].state)
}

output "ec2_image_block_public_access_state" {
  description = "Block public access state for AMIs in the region, or null when unmanaged."
  value       = one(aws_ec2_image_block_public_access.this[*].state)
}

output "instance_metadata_defaults" {
  description = "Instance metadata defaults applied in the region, or null when unmanaged."
  value = one([
    for d in aws_ec2_instance_metadata_defaults.this : {
      http_endpoint               = d.http_endpoint
      http_tokens                 = d.http_tokens
      http_put_response_hop_limit = d.http_put_response_hop_limit
      instance_metadata_tags      = d.instance_metadata_tags
    }
  ])
}
