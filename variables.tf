variable "log_bucket_name" {
  description = "Name of the S3 bucket used to store account log data."
  type        = string
}

variable "log_bucket_force_destroy" {
  description = "Whether to allow deletion of the log bucket even when it is not empty."
  type        = bool
  default     = false
}

variable "log_bucket_versioning_enabled" {
  description = "Whether to keep object versions in the log bucket so overwrites and deletes are recoverable."
  type        = bool
  default     = true
}

variable "enable_s3_account_public_access_block" {
  description = "Whether to enable the account-wide S3 public access block. Disable only if this account intentionally serves public S3 content."
  type        = bool
  default     = true
}

variable "minimum_password_length" {
  description = "Minimum length required for IAM user passwords."
  type        = number
  default     = 14

  validation {
    condition     = var.minimum_password_length >= 8
    error_message = "minimum_password_length must be at least 8."
  }
}

variable "require_symbols" {
  description = "Whether IAM user passwords must contain a symbol."
  type        = bool
  default     = true
}

variable "require_numbers" {
  description = "Whether IAM user passwords must contain a number."
  type        = bool
  default     = true
}

variable "require_uppercase_characters" {
  description = "Whether IAM user passwords must contain an uppercase character."
  type        = bool
  default     = true
}

variable "require_lowercase_characters" {
  description = "Whether IAM user passwords must contain a lowercase character."
  type        = bool
  default     = true
}

variable "max_password_age" {
  description = "Number of days before an IAM user password expires. Zero disables expiry."
  type        = number
  default     = 90

  validation {
    condition     = var.max_password_age >= 0 && var.max_password_age <= 1095
    error_message = "max_password_age must be between 0 and 1095 days."
  }
}

variable "password_reuse_prevention" {
  description = "Number of previous IAM user passwords that may not be reused. Zero disables reuse prevention."
  type        = number
  default     = 24

  validation {
    condition     = var.password_reuse_prevention >= 0 && var.password_reuse_prevention <= 24
    error_message = "password_reuse_prevention must be between 0 and 24."
  }
}

variable "allow_users_to_change_password" {
  description = "Whether IAM users may change their own password. Required for password expiry to be usable without administrator involvement."
  type        = bool
  default     = true
}

variable "enable_ebs_encryption_by_default" {
  description = "Whether to enable EBS encryption by default in the region."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the log bucket."
  type        = map(string)
  default     = {}
}
