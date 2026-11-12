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

run "rejects_unknown_ebs_snapshot_block_public_access_mode" {
  command = plan

  variables {
    ebs_snapshot_block_public_access = "block-everything"
  }

  expect_failures = [var.ebs_snapshot_block_public_access]
}

# The issue sketch used "no-access"; the EC2 API only accepts
# enabled | disabled | no-preference for instance_metadata_tags.
run "rejects_invalid_instance_metadata_tags" {
  command = plan

  variables {
    instance_metadata_defaults = {
      instance_metadata_tags = "no-access"
    }
  }

  expect_failures = [var.instance_metadata_defaults]
}

run "rejects_invalid_http_tokens" {
  command = plan

  variables {
    instance_metadata_defaults = {
      http_tokens = "v2"
    }
  }

  expect_failures = [var.instance_metadata_defaults]
}

run "rejects_out_of_range_hop_limit" {
  command = plan

  variables {
    instance_metadata_defaults = {
      http_put_response_hop_limit = 65
    }
  }

  expect_failures = [var.instance_metadata_defaults]
}

run "rejects_zero_hop_limit" {
  command = plan

  variables {
    instance_metadata_defaults = {
      http_put_response_hop_limit = 0
    }
  }

  expect_failures = [var.instance_metadata_defaults]
}

run "accepts_no_preference_hop_limit" {
  command = plan

  variables {
    instance_metadata_defaults = {
      http_put_response_hop_limit = -1
    }
  }
}
