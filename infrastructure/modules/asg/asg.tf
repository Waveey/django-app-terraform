resource "aws_security_group" "ec2" {
  name        = "${var.environment}-ec2-security-group"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id
  

  # Example ingress rule - adjust according to your needs
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Be more specific in production
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Be more specific in production
  }

  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Be more specific in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-ec2-security-group"
    Environment = var.environment
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.public_subnet_ids

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    timeout            = 5
    unhealthy_threshold = 2
  }
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.environment}-template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.ec2.id]
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = base64encode(<<-EOF
#!/bin/bash

# Update and install required packages
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo systemctl status docker
sudo usermod -aG docker ubuntu

# Install Nginx
apt-get install -y nginx

# Start and enable services
systemctl start docker
systemctl enable docker
systemctl start nginx
systemctl enable nginx

# Create a simple nginx configuration
cat <<'NGINX_CONF' > /etc/nginx/sites-available/default
server {
    listen 80;
    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_CONF

# Restart Nginx to apply changes
systemctl restart nginx
EOF
)


  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  # IMDSv2
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 20
      volume_type          = "gp3"
      encrypted            = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-instance"
      Environment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "main" {
  desired_capacity    = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  target_group_arns  = [aws_lb_target_group.main.arn]
  vpc_zone_identifier = var.public_subnet_ids  # Changed to Public subnets

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = {
      Name        = "${var.environment}-asg"
      Environment = var.environment
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Add autoscaling policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.environment}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.environment}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}
