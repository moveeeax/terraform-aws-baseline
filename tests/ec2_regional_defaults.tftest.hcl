# Run with: terraform test  (needs Terraform/OpenTofu >= 1.7 for mock_provider)
#
# Covers the regional EC2 settings: EBS snapshot and AMI block public access,
# and the instance metadata (IMDS) defaults for new instances.
mock_provider "aws" {}

variables {
  log_bucket_name = "unit-test-account-logs"
}

run "snapshot_and_ami_public_sharing_is_blocked_by_default" {
  assert {
    condition     = length(aws_ebs_snapshot_block_public_access.this) == 1 && aws_ebs_snapshot_block_public_access.this[0].state == "block-all-sharing"
    error_message = "EBS snapshot block public access must default to block-all-sharing."
  }

  assert {
    condition     = length(aws_ec2_image_block_public_access.this) == 1 && aws_ec2_image_block_public_access.this[0].state == "block-new-sharing"
    error_message = "AMI block public access must default to block-new-sharing."
  }

  assert {
    condition     = output.ebs_snapshot_block_public_access_state == "block-all-sharing"
    error_message = "ebs_snapshot_block_public_access_state must report the managed state."
  }

  assert {
    condition     = output.ec2_image_block_public_access_state == "block-new-sharing"
    error_message = "ec2_image_block_public_access_state must report the managed state."
  }
}

run "snapshot_block_mode_is_configurable" {
  variables {
    ebs_snapshot_block_public_access = "block-new-sharing"
  }

  assert {
    condition     = aws_ebs_snapshot_block_public_access.this[0].state == "block-new-sharing"
    error_message = "ebs_snapshot_block_public_access must be passed through to the resource."
  }
}

run "snapshot_and_ami_blocks_can_be_left_unmanaged" {
  variables {
    ebs_snapshot_block_public_access = null
    ec2_image_block_public_access    = false
  }

  assert {
    condition     = length(aws_ebs_snapshot_block_public_access.this) == 0 && length(aws_ec2_image_block_public_access.this) == 0
    error_message = "Null / false must not create the snapshot or AMI block public access resources."
  }

  assert {
    condition     = output.ebs_snapshot_block_public_access_state == null && output.ec2_image_block_public_access_state == null
    error_message = "State outputs must be null when the settings are unmanaged."
  }
}

run "new_instances_default_to_imdsv2" {
  assert {
    condition     = length(aws_ec2_instance_metadata_defaults.this) == 1
    error_message = "Instance metadata defaults must be managed by default."
  }

  assert {
    condition     = aws_ec2_instance_metadata_defaults.this[0].http_tokens == "required"
    error_message = "http_tokens must default to required (IMDSv2 only)."
  }

  assert {
    condition     = aws_ec2_instance_metadata_defaults.this[0].http_put_response_hop_limit == 2
    error_message = "The hop limit must default to 2 so containers on the instance can still reach IMDSv2."
  }

  assert {
    condition     = aws_ec2_instance_metadata_defaults.this[0].instance_metadata_tags == "disabled"
    error_message = "Instance tags must not be exposed through IMDS by default."
  }

  assert {
    condition     = aws_ec2_instance_metadata_defaults.this[0].http_endpoint == "no-preference"
    error_message = "http_endpoint must default to no-preference."
  }

  assert {
    condition     = output.instance_metadata_defaults.http_tokens == "required"
    error_message = "instance_metadata_defaults output must report the managed values."
  }
}

run "partial_instance_metadata_defaults_keep_the_other_defaults" {
  variables {
    instance_metadata_defaults = {
      http_put_response_hop_limit = 1
    }
  }

  assert {
    condition     = aws_ec2_instance_metadata_defaults.this[0].http_put_response_hop_limit == 1
    error_message = "An explicit hop limit must be passed through."
  }

  assert {
    condition     = aws_ec2_instance_metadata_defaults.this[0].http_tokens == "required"
    error_message = "Setting one field must not drop the IMDSv2 default for the others."
  }
}

run "instance_metadata_defaults_can_be_left_unmanaged" {
  variables {
    instance_metadata_defaults = null
  }

  assert {
    condition     = length(aws_ec2_instance_metadata_defaults.this) == 0
    error_message = "instance_metadata_defaults = null must not create the resource."
  }

  assert {
    condition     = output.instance_metadata_defaults == null
    error_message = "instance_metadata_defaults output must be null when unmanaged."
  }
}
