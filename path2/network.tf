
module "network" {
  source               = "../modules/network"
  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  name_prefix          = var.name_prefix
  path                 = var.path
  }


resource "aws_security_group" "web_sg" {
  name        = "${var.name_prefix}-web-sg-${var.path}"
  description = "Allow HTTP on 8080 and all outbound traffic"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "HTTP on 8080 from ALB only"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups= [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
   lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-web-sg-${var.path}"
    Path = var.path
  }
}

# ALB SG

resource "aws_security_group" "alb_sg" {
  name        = "${var.name_prefix}-alb-sg-${var.path}"
  description = "Allow HTTP from the internet to the ALB"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg-${var.path}"
    Path = var.path
  }
}
