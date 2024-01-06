resource "aws_vpc" "tfvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "tfsubnet01" {
  vpc_id                  = aws_vpc.tfvpc.id
  cidr_block              = var.subcidr
  availability_zone       = var.availabilityzone01
  map_public_ip_on_launch = true
}

resource "aws_subnet" "tfsubnet02" {
  vpc_id                  = aws_vpc.tfvpc.id
  cidr_block              = var.subcidr01
  availability_zone       = var.availabilityzone02
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.tfvpc.id
}

resource "aws_route_table" "rtr" {
  vpc_id = aws_vpc.tfvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }
}

resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.tfsubnet01.id
  route_table_id = aws_route_table.rtr.id
}

resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.tfsubnet02.id
  route_table_id = aws_route_table.rtr.id
}


resource "aws_security_group" "TFSGW" {
  name   = "sgw_tf"
  vpc_id = aws_vpc.tfvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "TFSGW"
  }

}


resource "aws_s3_bucket" "terraformBucket" {
  bucket = "terraformbucket-xyz"

}


resource "aws_instance" "instance01" {
  ami                    = var.ami_id
  instance_type          = var.inst_type
  subnet_id              = aws_subnet.tfsubnet01.id
  vpc_security_group_ids = [aws_security_group.TFSGW.id]
  user_data              = base64encode(file("filedata.sh"))

}

resource "aws_instance" "instance02" {
  ami                    = var.ami_id
  instance_type          = var.inst_type
  subnet_id              = aws_subnet.tfsubnet02.id
  vpc_security_group_ids = [aws_security_group.TFSGW.id]
  user_data              = base64encode(file("filedata1.sh"))

}

resource "aws_lb" "tfALB" {
  name               = "tffALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.TFSGW.id]
  subnets            = [aws_subnet.tfsubnet01.id, aws_subnet.tfsubnet02.id]

  enable_deletion_protection = false
}


resource "aws_lb_target_group" "tfTG" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tfvpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attchment01" {
  target_group_arn = aws_lb_target_group.tfTG.arn
  target_id        = aws_instance.instance01.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attachment02" {
  target_group_arn = aws_lb_target_group.tfTG.arn
  target_id        = aws_instance.instance02.id
  port             = 80
}

resource "aws_lb_listener" "tflistener" {
  load_balancer_arn = aws_lb.tfALB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfTG.arn
  }
}