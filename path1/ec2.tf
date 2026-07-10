resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
            #!/bin/bash
            dnf install -y java-1.8.0-amazon-corretto
            EOF

  metadata_options {
    http_tokens = "required"  
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "cicd-challenge-ec2-instance"
    Path = "path1"
  }
}