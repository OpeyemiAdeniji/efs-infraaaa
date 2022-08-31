#EFS creation
resource "aws_efs_file_system" "efs_storage" {
  creation_token   = "EFS for Backup"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "External Storage"
  }

  #   depends_on = [
  #     aws_security_group.efs_firewall,
  #     aws_instance.webServerOS
  #   ]
}


#mounting EFS
resource "aws_efs_mount_target" "efs1" {
  file_system_id  = aws_efs_file_system.efs_storage.id
  subnet_id       = aws_subnet.subnet.id
  security_groups = ["${aws_security_group.efs_firewall.id}"]


  depends_on = [
    aws_efs_file_system.efs_storage,
  ]
}

resource "null_resource" "configure_nfs" {
  depends_on = [aws_efs_mount_target.efs1]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.p_key.private_key_pem
    host        = aws_instance.webServerOS.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install amazon-efs-utils httpd php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
      "sudo setenforce 0",
      "sudo yum install nfs-utils -y",
      "sudo mount -t nfs4 ${aws_efs_file_system.efs_storage.dns_name}:/ /var/www/html",
      "sudo echo ${aws_efs_file_system.efs_storage.dns_name}:/ /var/www/html efs defaults_netdev 0 0 >> sudo /etc/fstab",
      "sudo git clone https://github.com/OpeyemiAdeniji/efs-infrastructure.git /var/www/html/",
    ]
  }
}
