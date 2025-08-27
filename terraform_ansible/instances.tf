# Créer un Load Balancer
resource "aws_lb" "load_balancer" {
  name               = "loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = [aws_subnet.public_subnet_load_balancer1.id,aws_subnet.public_subnet_load_balancer2.id]
  enable_deletion_protection = false

  tags = {
    Name = "load_balancer"
  }
}

# Créer une instance EC2 bastion
resource "aws_instance" "bastion" {
  ami           = "ami-084568db4383264d4" # Remplacez par l'AMI de votre choix
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_bastion.id
  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  associate_public_ip_address = true
  key_name      = "connexion"

    provisioner "file" {
    source     = "./data/"
    destination = "/home/ubuntu/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./connexion.pem")
      host        = self.public_ip
    }
  }

  user_data = file("userdata.sh")
  tags = {
    Name = "bastion"
  }
}

# Créer trois instances EC2
resource "aws_instance" "application" {
  count         = 3
  ami           = "ami-084568db4383264d4" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet1.id
  vpc_security_group_ids = [aws_security_group.application_security_group.id]
  associate_public_ip_address = false
  key_name      = "connexion"
  tags = {
    Name = "application-${count.index + 1}"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Créer un écouteur pour le Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.application[count.index].id
  port             = 80
}

resource "aws_db_instance" "mariadb" {
  db_subnet_group_name  = aws_db_subnet_group.default.name
  allocated_storage = 20
  storage_type     = "gp2"
  engine  = "mariadb"
  engine_version  = "10.5"
  instance_class  = "db.t3.micro"
  db_name = "greenshop"
  username   = "greenshop_user"
  password             = "your_secure_password"
  parameter_group_name = "default.mariadb10.5"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.bdd_security_group.id]
  tags = {
    Name = "mariadb-instance"
  }
}