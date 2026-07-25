# terraform-aws-baseline

Terraform module that applies a small [AWS](https://aws.amazon.com/) account
landing-zone baseline. It creates an encrypted, private, versioned log bucket
that rejects plaintext HTTP, turns on the account-wide S3 public access block,
sets a strong IAM account password policy and enables EBS encryption by
default, giving new accounts sane security defaults in one place.

> **Account-wide effects.** `aws_s3_account_public_access_block` and
> `aws_iam_account_password_policy` are singleton, account-scoped resources.
> Apply this module once per account, from one Terraform state, and do not run
> it alongside another module that manages the same two resources. If the
> account intentionally serves public S3 content, set
> `enable_s3_account_public_access_block = false`.

## Usage

```hcl
module "baseline" {
  source = "github.com/moveeeax/terraform-aws-baseline"

  log_bucket_name         = "acme-account-logs"
  minimum_password_length = 16

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

| Name                                    | Description                                                              | Type          | Default | Required |
|-----------------------------------------|--------------------------------------------------------------------------|---------------|---------|:--------:|
| `log_bucket_name`                       | Name of the account log bucket.                                          | `string`      | n/a     |   yes    |
| `log_bucket_force_destroy`              | Allow deletion of a non-empty log bucket.                                | `bool`        | `false` |    no    |
| `log_bucket_versioning_enabled`         | Keep object versions so log overwrites and deletes are recoverable.      | `bool`        | `true`  |    no    |
| `enable_s3_account_public_access_block` | Enable the account-wide S3 public access block.                          | `bool`        | `true`  |    no    |
| `minimum_password_length`               | Minimum IAM user password length (must be >= 8).                         | `number`      | `14`    |    no    |
| `require_symbols`                       | Require a symbol in passwords.                                           | `bool`        | `true`  |    no    |
| `require_numbers`                       | Require a number in passwords.                                           | `bool`        | `true`  |    no    |
| `require_uppercase_characters`          | Require an uppercase character in passwords.                             | `bool`        | `true`  |    no    |
| `require_lowercase_characters`          | Require a lowercase character in passwords.                              | `bool`        | `true`  |    no    |
| `max_password_age`                      | Days before a password expires, 0-1095. Zero disables expiry.            | `number`      | `90`    |    no    |
| `password_reuse_prevention`             | Previous passwords that may not be reused, 0-24. Zero disables.          | `number`      | `24`    |    no    |
| `allow_users_to_change_password`        | Let IAM users change their own password.                                 | `bool`        | `true`  |    no    |
| `enable_ebs_encryption_by_default`      | Enable EBS encryption by default in the region.                          | `bool`        | `true`  |    no    |
| `tags`                                  | Tags applied to the log bucket.                                          | `map(string)` | `{}`    |    no    |

## Outputs

| Name                                     | Description                                                  |
|------------------------------------------|--------------------------------------------------------------|
| `log_bucket_id`                          | Name of the log bucket.                                      |
| `log_bucket_arn`                         | ARN of the log bucket.                                       |
| `log_bucket_versioning_status`           | Versioning status of the log bucket.                         |
| `s3_account_public_access_block_enabled` | Whether the account-wide S3 public access block is managed.  |
| `password_policy_expire_passwords`       | Whether the password policy expires passwords.               |
| `ebs_encryption_by_default_enabled`      | Whether EBS encryption by default is enabled.                |

## Testing

The module ships a `terraform test` suite that runs against a mocked AWS
provider, so it needs no credentials and no network:

```sh
terraform init -backend=false
terraform test
```

`mock_provider` requires Terraform (or OpenTofu) >= 1.7. That is a test-time
requirement only; the module itself still supports >= 1.5.

## License

[MIT](LICENSE)
