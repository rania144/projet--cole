provider "aws" {
  region = "us-east-1" 
}

# Créer un VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# # Générer une paire de clés SSH
# resource "tls_private_key" "connexion" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # Importer la clé publique dans AWS
# resource "aws_key_pair" "connexion" {
#   key_name   = "connexion"
#   public_key = tls_private_key.connexion.public_key_openssh
# }

# # Sauvegarder la clé privée dans un fichier local
# resource "local_file" "private_key" {
#   content  = tls_private_key.connexion.private_key_pem
#   filename = "${path.module}/connexion.pem"
#   file_permission = "0600"
# }

