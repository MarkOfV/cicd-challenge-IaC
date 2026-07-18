module "network" {
  source = "../modules/network"
}

resource "aws_security_group" "web_sg" {
  name        = "cicd-challenge-web-sg"
  description = "Allow HTTP on 8080 and all outbound traffic"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "HTTP on 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cicd-challenge-web-sg"
    Path = "path1"
  }
}