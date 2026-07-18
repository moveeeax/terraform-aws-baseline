variable "log_bucket_name" {
  description = "Name of the S3 bucket used to store account log data."
  type        = string
}

variable "log_bucket_force_destroy" {
  description = "Whether to allow deletion of the log bucket even when it is not empty."
  type        = bool
  default     = false
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
