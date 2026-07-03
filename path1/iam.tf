data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name = "cicd-challenge-ec2-role"
    Path = "path1"
  }  
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role   = aws_iam_role.ec2_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "cicd-challenge-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
  
  tags = {
    Path = "path1"
  }
}