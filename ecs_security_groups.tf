
resource "aws_security_group" "cue_ecs_sg" {
  name   = "cue-ecs-security-group"
  vpc_id = aws_vpc.cue_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "cue-ecs-security-group"
    Project = "cue"
    Env     = "prod"
  }
}
