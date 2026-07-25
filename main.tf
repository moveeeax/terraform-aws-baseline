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

resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = var.minimum_password_length
  require_symbols                = var.require_symbols
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_lowercase_characters   = var.require_lowercase_characters
  max_password_age               = var.max_password_age
  password_reuse_prevention      = var.password_reuse_prevention
  allow_users_to_change_password = var.allow_users_to_change_password
}

resource "aws_ebs_encryption_by_default" "this" {
  enabled = var.enable_ebs_encryption_by_default
}
