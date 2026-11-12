# terraform-aws-baseline

Terraform module that applies a small [AWS](https://aws.amazon.com/) account
landing-zone baseline. It creates an encrypted, private, versioned log bucket
that rejects plaintext HTTP, turns on the account-wide S3 public access block,
sets a strong IAM account password policy, enables EBS encryption by default,
blocks public sharing of EBS snapshots and AMIs, and makes new EC2 instances
default to IMDSv2, giving new accounts sane security defaults in one place.

> **Account-wide effects.** `aws_s3_account_public_access_block` and
> `aws_iam_account_password_policy` are singleton, account-scoped resources.
> Apply this module once per account, from one Terraform state, and do not run
> it alongside another module that manages the same two resources. If the
> account intentionally serves public S3 content, set
> `enable_s3_account_public_access_block = false`.
>
> **Regional effects.** EBS encryption by default, EBS snapshot and AMI block
> public access, and the instance metadata defaults are per-region settings of
> the account and apply to the provider's region. Use one module instance (or
> one provider alias) per region you want covered, and do not manage the same
> settings elsewhere.
>
> - `ebs_snapshot_block_public_access` defaults to `block-all-sharing`, which
>   also makes already-public snapshots private. Use `block-new-sharing` to
>   keep existing public snapshots public. Removing the setting (`null`) turns
>   blocking off in AWS.
> - `ec2_image_block_public_access` only blocks new public sharing; AMIs that
>   are already public stay public. Setting it to `false` stops managing it but
>   does not unblock it in AWS.
> - `instance_metadata_defaults` only affects instances launched after the
>   change that do not set their own `metadata_options`. The default requires
>   IMDSv2 tokens with a hop limit of 2 (so containers on the instance still
>   reach IMDS) and hides instance tags from IMDS. Setting it to `null` resets
>   every field to `no-preference`. Check that your AMIs and SDKs support
>   IMDSv2 before applying.

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
| aws       | >= 5.62  |

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
| `ebs_snapshot_block_public_access`      | EBS snapshot block public access mode: `block-all-sharing`, `block-new-sharing` or `unblocked`. `null` leaves it unmanaged. | `string` | `"block-all-sharing"` | no |
| `ec2_image_block_public_access`         | Block new public sharing of AMIs (`block-new-sharing`). `false` leaves it unmanaged. | `bool` | `true` | no |
| `instance_metadata_defaults`            | Regional IMDS defaults for new instances: `http_endpoint` (`enabled`/`disabled`/`no-preference`, default `no-preference`), `http_tokens` (`optional`/`required`/`no-preference`, default `required`), `http_put_response_hop_limit` (1-64 or -1, default `2`), `instance_metadata_tags` (`enabled`/`disabled`/`no-preference`, default `disabled`). `null` leaves them unmanaged. | `object` | `{}` | no |
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
| `ebs_snapshot_block_public_access_state` | EBS snapshot block public access mode, or `null` when unmanaged. |
| `ec2_image_block_public_access_state`    | AMI block public access state, or `null` when unmanaged.     |
| `instance_metadata_defaults`             | Applied instance metadata defaults, or `null` when unmanaged. |

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
