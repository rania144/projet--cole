#!/bin/bash
sudo apt update
sudo apt install ansible-core -y
sudo apt install python3-mysqldb -y
sudo apt-get install mysql-client -y
mkdir /home/ubuntu/ansible
mkdir /home/ubuntu/.aws/
mv /home/ubuntu/credentials /home/ubuntu/.aws/
mv /home/ubuntu/docker.yml /home/ubuntu/inventory.ini /home/ubuntu/aws_ec2.yml /home/ubuntu/apache-php.yml /home/ubuntu/database.yml /home/ubuntu/apache2.conf /home/ubuntu/greenshop.conf /home/ubuntu/my.cnf /home/ubuntu/greenshop/ /home/ubuntu/greenshop_dump.sql /home/ubuntu/ansible
mv /home/ubuntu/connexion.pem /home/ubuntu/.ssh/connexion.pem
chmod 600 /home/ubuntu/.ssh/connexion.pem
