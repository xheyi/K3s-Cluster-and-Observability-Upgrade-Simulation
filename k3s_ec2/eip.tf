resource "aws_eip" "k3s_master" {
  domain = "vpc"

  tags = {
    Name = "k3s-master-eip"
  }
}

resource "aws_eip_association" "k3s_master" {
  instance_id   = aws_instance.k3s_master_node.id
  allocation_id = aws_eip.k3s_master.id
}