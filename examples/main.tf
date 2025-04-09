provider "spacelift" {}

terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

module "spacelift_stacks" {
  source = "../modules/spacelift_stacks"
  stacks = {
    ansible_ec2_inventory = {
      repo         = "spacelift_ansible_examples"
      branch       = "main"
      project_root = "configurations/ansible"
      description  = "Ansible stack that uses an terraform generated inventory"
      labels       = ["ansible", "ansibleTerraform"]
      before_init = ["echo \"$INSTANCE_JSON\" | jq -r 'to_entries | group_by(.value.env) | .[] as $group | \"[\" + $group[0].value.env + \"]\\n\" + ($group | map(.value.public_dns) | join(\"\\n\")) + \"\\n\"' > /mnt/workspace/ansible_inventory.ini",
        "aws ssm get-parameter --region eu-west-1 --name '/dev/ssh/private_key' --with-decryption --query 'Parameter.Value' --output text > /mnt/workspace/id_rsa_ansible",
        "python3 -m pip install boto3 --break-system-packages",
        "chmod 600 /mnt/workspace/id_rsa_ansible"
      ]
      before_apply     = ["python3 -m pip install boto3 --break-system-packages", "chmod 600 /mnt/workspace/id_rsa_ansible"]
      ansible_playbook = ["disk_threshold.yaml"]
    }
    terraform_ec2 = {
      repo         = "spacelift_ansible_examples"
      branch       = "main"
      project_root = "configurations/ec2"
      description  = "terraform stack that creates ec2 instances"
      labels       = ["terraform", "ansibleTerraform"]
    }
    terraform_network = {
      repo         = "spacelift_ansible_examples"
      branch       = "main"
      project_root = "configurations/network"
      description  = "terraform stack that creates a network"
      labels       = ["terraform", "ansibleTerraform"]
    }
  }
  integrations = {
    ansible_integration = {
      integration_id = var.integration_id
      stack_name     = "ansible_ec2_inventory"
    }
    ec2_integration = {
      integration_id = var.integration_id
      stack_name     = "terraform_ec2"
    }
    network_integration = {
      integration_id = var.integration_id
      stack_name     = "terraform_network"
    }

  }
  contexts = {}
  env_vars = {
    ansible_cfg = {
      name           = "ANSIBLE_CONFIG"
      value          = "/mnt/workspace/source/configurations/ansible/ansible.cfg"
      stack_name     = "ansible_ec2_inventory"
      add_to_context = false
    }
  }
  stack_dependencies = {
    ec2_ansible = {
      stack_parent = "terraform_ec2"
      stack_child  = "ansible_ec2_inventory"
    }
    network_ec2 = {
      stack_parent = "terraform_network"
      stack_child  = "terraform_ec2"
    }

  }
  dependency_variables = {
    var1 = {
      dependency_name = "ec2_ansible"
      output_name     = "instance_info"
      input_name      = "INSTANCE_JSON"
    }
    var2 = {
      dependency_name = "network_ec2"
      output_name     = "subnet_ids"
      input_name      = "TF_VAR_subnet_ids"
    }
  }
}
