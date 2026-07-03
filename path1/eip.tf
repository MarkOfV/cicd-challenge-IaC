resource "aws_eip" "app_eip" {
  domain = "vpc"
  instance = aws_instance.app.id

  tags = {
    Name = "app-eip"
    Path = "path1"
  }
}