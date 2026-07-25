# Run with: terraform test
#
# These tests use `mock_provider`, which needs Terraform >= 1.7 (or OpenTofu
# >= 1.7). The module itself still only requires >= 1.5 -- the newer version is
# a test-time requirement only, so `required_version` is deliberately not bumped.
mock_provider "aws" {}

variables {
  log_bucket_name = "unit-test-account-logs"
}

run "log_bucket_is_private_and_encrypted" {
  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.logs.block_public_acls,
      aws_s3_bucket_public_access_block.logs.block_public_policy,
      aws_s3_bucket_public_access_block.logs.ignore_public_acls,
      aws_s3_bucket_public_access_block.logs.restrict_public_buckets,
    ])
    error_message = "The log bucket must have every public access block setting enabled."
  }

  assert {
    condition = anytrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.logs.rule :
      anytrue([
        for sse in rule.apply_server_side_encryption_by_default :
        sse.sse_algorithm == "AES256"
      ])
    ])
    error_message = "The log bucket must be encrypted at rest."
  }

  assert {
    condition     = aws_s3_bucket.logs.force_destroy == false
    error_message = "force_destroy must default to false so logs are not silently discarded."
  }
}

run "log_bucket_versioning_is_on_by_default" {
  assert {
    condition     = aws_s3_bucket_versioning.logs.versioning_configuration[0].status == "Enabled"
    error_message = "Log bucket versioning must default to Enabled so log overwrites and deletes are recoverable."
  }
}

run "log_bucket_denies_plaintext_http" {
  assert {
    condition = anytrue([
      for s in jsondecode(aws_s3_bucket_policy.logs.policy).Statement :
      s.Effect == "Deny"
      && s.Action == "s3:*"
      && try(s.Condition.Bool["aws:SecureTransport"], null) == "false"
    ])
    error_message = "The log bucket policy must deny all s3 actions where aws:SecureTransport is false."
  }

  assert {
    condition     = length(jsondecode(aws_s3_bucket_policy.logs.policy).Statement) == 1
    error_message = "The log bucket policy must contain only the deny-insecure-transport statement."
  }

  assert {
    condition = alltrue([
      for s in jsondecode(aws_s3_bucket_policy.logs.policy).Statement :
      length(s.Resource) == 2
    ])
    error_message = "The deny statement must cover both the bucket and its objects."
  }
}

run "account_public_access_block_is_on_by_default" {
  assert {
    condition     = length(aws_s3_account_public_access_block.this) == 1
    error_message = "The account-wide S3 public access block must be created by default."
  }

  assert {
    condition = alltrue([
      aws_s3_account_public_access_block.this[0].block_public_acls,
      aws_s3_account_public_access_block.this[0].block_public_policy,
      aws_s3_account_public_access_block.this[0].ignore_public_acls,
      aws_s3_account_public_access_block.this[0].restrict_public_buckets,
    ])
    error_message = "Every account-wide public access block setting must be enabled."
  }
}

run "account_public_access_block_can_be_opted_out" {
  variables {
    enable_s3_account_public_access_block = false
  }

  assert {
    condition     = length(aws_s3_account_public_access_block.this) == 0
    error_message = "Setting enable_s3_account_public_access_block = false must not create the resource."
  }
}

run "password_policy_defaults_are_strong" {
  assert {
    condition     = aws_iam_account_password_policy.this.minimum_password_length >= 14
    error_message = "Default minimum password length must be at least 14."
  }

  assert {
    condition     = aws_iam_account_password_policy.this.password_reuse_prevention == 24
    error_message = "Password reuse prevention must default to 24, the AWS maximum."
  }

  assert {
    condition     = aws_iam_account_password_policy.this.allow_users_to_change_password
    error_message = "Users must be allowed to change their own password, otherwise expiry locks them out."
  }

  assert {
    condition = alltrue([
      aws_iam_account_password_policy.this.require_symbols,
      aws_iam_account_password_policy.this.require_numbers,
      aws_iam_account_password_policy.this.require_uppercase_characters,
      aws_iam_account_password_policy.this.require_lowercase_characters,
    ])
    error_message = "All password complexity requirements must default to true."
  }

  assert {
    condition     = aws_iam_account_password_policy.this.max_password_age == 90
    error_message = "Passwords must expire by default."
  }
}

run "ebs_encryption_is_on_by_default" {
  assert {
    condition     = aws_ebs_encryption_by_default.this.enabled
    error_message = "EBS encryption by default must be enabled."
  }
}
