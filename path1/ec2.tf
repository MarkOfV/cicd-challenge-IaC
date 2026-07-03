resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids        = [aws_security_group.web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true
  
  metadata_options {
      http_tokens = "required"  
    }

  tags = {
    Name = "cicd-challenge-ec2-instance"
    Path = "path1"
  }
}