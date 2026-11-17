output "master_public_ip" {
  value = aws_eip.k3s_master.public_ip
}