resource "tls_private_key" "p_key" {
  algorithm = "RSA"
}


resource "aws_key_pair" "task5-key" {
  key_name   = "task5-key"
  public_key = tls_private_key.p_key.public_key_openssh
}

# resource "local_file" "task2-key" {
#   content =   tls_private_key.p_key.private_key_pem
#   filename = "task2-key.pem"
# }

resource "null_resource" "save_key_pair" {
  provisioner "local-exec" {
    command = "echo ${tls_private_key.p_key.private_key_pem} > task5-key.pem"
  }
}

# Provisioning instance
resource "aws_instance" "webServerOS" {
  ami                    = "ami-090fa75af13c156b4"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.task5-key.key_name
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.efs_firewall.id]

  tags = {
    Name = "myefsos"
  }

}

output "webServerIP" {
  value = aws_instance.webServerOS.public_ip
}
