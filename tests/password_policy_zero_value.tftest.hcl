# Run with: terraform test  (needs Terraform/OpenTofu >= 1.7 for mock_provider)
#
# The AWS IAM UpdateAccountPasswordPolicy API's valid range for both
# MaxPasswordAge and PasswordReusePrevention has a minimum of 1: passing a
# literal 0 is rejected with ValidationException. variables.tf documents 0 as
# "disable this", so the module must translate 0 into null (an omitted
# argument) rather than pass it through, or setting either variable to its
# documented "disable" value would fail at apply against real AWS.
#
# These assertions check the local values that feed the resource directly,
# not the mocked resource's own attributes: mock_provider fills an unset
# Optional+Computed int attribute with its type's zero value (0) by default,
# which would make "sent literal 0" and "omitted, then mock-filled with 0"
# indistinguishable if asserted on the resource itself.
mock_provider "aws" {}

variables {
  log_bucket_name = "unit-test-account-logs"
}

run "max_password_age_zero_becomes_null_not_a_rejected_literal_zero" {
  command = plan

  variables {
    max_password_age = 0
  }

  assert {
    condition     = local.max_password_age == null
    error_message = "max_password_age = 0 must be translated to null (omitted), not sent as literal 0 -- AWS's valid range is 1-1095 and rejects 0."
  }
}

run "password_reuse_prevention_zero_becomes_null_not_a_rejected_literal_zero" {
  command = plan

  variables {
    password_reuse_prevention = 0
  }

  assert {
    condition     = local.password_reuse_prevention == null
    error_message = "password_reuse_prevention = 0 must be translated to null (omitted), not sent as literal 0 -- AWS's valid range is 1-24 and rejects 0."
  }
}

run "nonzero_max_password_age_and_reuse_prevention_pass_through_unchanged" {
  command = plan

  variables {
    max_password_age          = 45
    password_reuse_prevention = 5
  }

  assert {
    condition     = local.max_password_age == 45
    error_message = "A nonzero max_password_age must be passed through unchanged."
  }

  assert {
    condition     = local.password_reuse_prevention == 5
    error_message = "A nonzero password_reuse_prevention must be passed through unchanged."
  }
}
