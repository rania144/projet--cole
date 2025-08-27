# Créer des sous-réseau publics
resource "aws_subnet" "public_subnet_bastion" {

  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_bastion"
  }
}

resource "aws_subnet" "public_subnet_load_balancer1" {

  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_load_balancer1"
  }
}

resource "aws_subnet" "public_subnet_load_balancer2" {

  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_load_balancer2"
  }
}

# Créer un sous-réseau privé
resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.main.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "private_subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.main.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.5.0/24"

  tags = {
    Name = "private_subnet2"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

# Créer une passerelle Internet
resource "aws_internet_gateway" "igw_load_balancer" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw_load_balancer"
  }
}

# Créer une table de routage
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_load_balancer.id
  }
  tags = {
    Name = "load_balancer_route_table"
  }
}

# Associer les sous-réseaux publics à la table de routage
resource "aws_route_table_association" "public_load_balancer1" {
  subnet_id = aws_subnet.public_subnet_load_balancer1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "public_load_balancer2" {
  subnet_id = aws_subnet.public_subnet_load_balancer2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "public_bastion" {
  subnet_id = aws_subnet.public_subnet_bastion.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route.id
}

#Créer une elasticip et un NAT pour l'accès réseau vers l'extérieur
resource "aws_eip" "nat_eip" {}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id  = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_bastion.id

  tags = {
    Name = "nat_gateway"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}