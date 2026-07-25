# Run with: terraform test  (needs Terraform/OpenTofu >= 1.7 for mock_provider)
mock_provider "aws" {}

variables {
  log_bucket_name = "unit-test-account-logs"
}

run "rejects_short_minimum_password_length" {
  command = plan

  variables {
    minimum_password_length = 6
  }

  expect_failures = [var.minimum_password_length]
}

run "rejects_out_of_range_max_password_age" {
  command = plan

  variables {
    max_password_age = 2000
  }

  expect_failures = [var.max_password_age]
}

run "rejects_negative_max_password_age" {
  command = plan

  variables {
    max_password_age = -1
  }

  expect_failures = [var.max_password_age]
}

run "rejects_out_of_range_password_reuse_prevention" {
  command = plan

  variables {
    password_reuse_prevention = 25
  }

  expect_failures = [var.password_reuse_prevention]
}
