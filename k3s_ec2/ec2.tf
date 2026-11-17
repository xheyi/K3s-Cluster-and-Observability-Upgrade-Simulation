data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "k3s_master_node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  iam_instance_profile = aws_iam_instance_profile.k3s_master_profile.name

  tags = {
    Name = "ks3-master-node"
  }

    user_data = <<-EOF
    #!/bin/bash

    apt-get update -y
    apt-get install -y curl awscli

    curl -sfL https://get.k3s.io |INSTALL_K3S_VERSION="v1.31.8+k3s1" sh -

    until [ -f /var/lib/rancher/k3s/server/node-token ]; do
      sleep 5
    done

    TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)

    aws ssm put-parameter \
        --name "/k3s/cluster/node-token" \
        --type "SecureString" \
        --value "$TOKEN" \
        --overwrite \
        --region eu-north-1
    EOF
}

resource "aws_instance" "k3s_worker_node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  iam_instance_profile = aws_iam_instance_profile.k3s_worker_profile.name


  user_data = templatefile("${path.module}/worker.sh", {
    master_ip = aws_instance.k3s_master_node.private_ip
  })

  tags = {
    Name = "k3s-worker-node"
  }
}