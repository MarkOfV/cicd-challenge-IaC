resource "aws_eip" "app_eip" {
  domain = "vpc"
  instance = aws_instance.app.id

  tags = {
    Name = "cicd-challenge-ec2-eip"
    Path = "path1"
  }
}