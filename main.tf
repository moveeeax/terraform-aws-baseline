resource "aws_s3_bucket" "logs" {
  bucket        = var.log_bucket_name
  force_destroy = var.log_bucket_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Log data is append-only evidence: without versioning an overwrite or delete
# leaves no trace, which is exactly what an attacker clearing tracks relies on.
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = var.log_bucket_versioning_enabled ? "Enabled" : "Suspended"
  }
}

# The public access block above only stops the bucket from being made public.
# It does nothing about credentials or objects moving over plaintext HTTP, so
# deny anything that did not arrive over TLS.
resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })

  # The account-wide and bucket-level public access blocks reject bucket
  # policies they consider public while they are being applied, so pin the
  # ordering rather than relying on Terraform to guess it.
  depends_on = [
    aws_s3_bucket_public_access_block.logs,
    aws_s3_account_public_access_block.this,
  ]
}

# Account-level setting: this is what stops a *future* bucket in this account
# from being made public, independently of the per-bucket block above.
resource "aws_s3_account_public_access_block" "this" {
  count = var.enable_s3_account_public_access_block ? 1 : 0

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# The variables document 0 as "disable this", but the IAM
# UpdateAccountPasswordPolicy API rejects a literal 0 for both of these
# fields with ValidationException -- its valid range is a minimum of 1
# (1-1095 for MaxPasswordAge, 1-24 for PasswordReusePrevention). The only way
# to get the "never expire" / "no reuse prevention" behavior is to omit the
# argument entirely, so translate 0 into null rather than passing it straight
# through. Both arguments are Optional+Computed, so this reliably disables
# the setting when the policy is first created; flipping an already-nonzero
# value back to 0 later may not clear it on AWS's side in the same apply,
# since Terraform does not send an explicit "unset" for a null
# Optional+Computed attribute on update.
locals {
  max_password_age          = var.max_password_age > 0 ? var.max_password_age : null
  password_reuse_prevention = var.password_reuse_prevention > 0 ? var.password_reuse_prevention : null
}

resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = var.minimum_password_length
  require_symbols                = var.require_symbols
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_lowercase_characters   = var.require_lowercase_characters
  allow_users_to_change_password = var.allow_users_to_change_password
  max_password_age               = local.max_password_age
  password_reuse_prevention      = local.password_reuse_prevention
}

resource "aws_ebs_encryption_by_default" "this" {
  enabled = var.enable_ebs_encryption_by_default
}
