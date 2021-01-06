resource "aws_alb" "cue_load_balancer" {
  name            = "cue-load-balancer"
  security_groups = [aws_security_group.cue_ecs_sg.id]
  subnets = [
    aws_subnet.cue_vpc_public_subnet_a.id,
    aws_subnet.cue_vpc_public_subnet_b.id
  ]

  tags = {
    Project = "cue"
    Env     = "prod"
  }
}

resource "aws_alb_target_group" "cue_ecs_target_group_web" {
  name     = "cue-ecs-target-group-web"
  port     = "5000"
  protocol = "HTTP"
  vpc_id   = aws_vpc.cue_vpc.id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags = {
    Project = "cue"
    Env     = "prod"
  }
}

resource "aws_alb_listener" "cue_alb_listener" {
  load_balancer_arn = aws_alb.cue_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.cue_ecs_target_group_web.arn
    type             = "forward"
  }
}
