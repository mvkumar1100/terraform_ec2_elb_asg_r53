provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "my_instance" {
  ami           = "ami-01816d07b1128cd2d" # Use the appropriate AMI ID
  instance_type = "t2.micro"
  key_name      = "vin123"
  tags = {
    Name = "ec2-terraform"
  }

}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["subnet-0a607cd7cc45a57da"] # Replace with your subnet ID
  #launch_configuration = aws_launch_configuration.lc.id
  launch_template {
    id = aws_launch_template.lt.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "lt" {
  image_id      = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  key_name      = "vin123"
}

resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-0a607cd7cc45a57da", "subnet-0538beb915967b117"]
}

resource "aws_route53_record" "dns" {
  zone_id = "Z01690411X4IAH3VN12EW" # Replace with your Route 53 hosted zone ID
  name    = "vinodxyz.com"
  type    = "A"

  alias {
    name                   = aws_lb.my_lb.dns_name
    zone_id                = aws_lb.my_lb.zone_id
    evaluate_target_health = false
  }
}

