# terraform-aws-baseline

Terraform module that applies a small [AWS](https://aws.amazon.com/) account
landing-zone baseline. It creates an encrypted, private log bucket, sets a
strong IAM account password policy and enables EBS encryption by default,
giving new accounts sane security defaults in one place.

## Usage

```hcl
module "baseline" {
  source = "github.com/cybercapybara/terraform-aws-baseline"

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

| Name                               | Description                                             | Type          | Default   | Required |
|------------------------------------|---------------------------------------------------------|---------------|-----------|:--------:|
| `log_bucket_name`                  | Name of the account log bucket.                         | `string`      | n/a       |   yes    |
| `log_bucket_force_destroy`         | Allow deletion of a non-empty log bucket.               | `bool`        | `false`   |    no    |
| `minimum_password_length`          | Minimum IAM user password length.                       | `number`      | `14`      |    no    |
| `require_symbols`                  | Require a symbol in passwords.                           | `bool`        | `true`    |    no    |
| `require_numbers`                  | Require a number in passwords.                           | `bool`        | `true`    |    no    |
| `require_uppercase_characters`     | Require an uppercase character in passwords.             | `bool`        | `true`    |    no    |
| `require_lowercase_characters`     | Require a lowercase character in passwords.              | `bool`        | `true`    |    no    |
| `max_password_age`                 | Days before a password expires. Zero disables expiry.   | `number`      | `90`      |    no    |
| `enable_ebs_encryption_by_default` | Enable EBS encryption by default in the region.         | `bool`        | `true`    |    no    |
| `tags`                             | Tags applied to the log bucket.                         | `map(string)` | `{}`      |    no    |

## Outputs

| Name                                | Description                                        |
|-------------------------------------|----------------------------------------------------|
| `log_bucket_id`                     | Name of the log bucket.                            |
| `log_bucket_arn`                    | ARN of the log bucket.                             |
| `password_policy_expire_passwords`  | Whether the password policy expires passwords.     |
| `ebs_encryption_by_default_enabled` | Whether EBS encryption by default is enabled.      |

## License

[MIT](LICENSE)
