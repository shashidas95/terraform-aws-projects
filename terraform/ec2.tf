resource "aws_instance" "tf_ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = "terraform-ec2"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.tf_ec2_sg.id]
  depends_on = [
  aws_db_instance.tf_rds_instance,
  aws_s3_object.tf_s3_object
]


  user_data = <<-EOF
            #!/bin/bash

            # Update and install dependencies
            sudo apt update -y
            sudo apt install -y git curl 

            # Install Node.js and npm correctly (use NodeSource)
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt install -y nodejs

            # Ensure /home/ubuntu exists
            sudo mkdir -p /home/ubuntu

            # Git clone the repository
            sudo git clone https://github.com/shashidas95/terraform-aws-projects.git /home/ubuntu/terraform-aws-projects
            cd /home/ubuntu/terraform-aws-projects/nodejs-mysql

            # Check Ownership and Permissions
            sudo chown -R ubuntu:ubuntu /home/ubuntu/terraform-aws-projects

            # Switch to ubuntu user and set up environment
            sudo -u ubuntu bash -c '
            cd /home/ubuntu/terraform-aws-projects/nodejs-mysql

            # Create .env file with placeholder environment variables
            echo "DB_HOST=${local.rds_endpoint}" > .env
            echo "DB_USER=${aws_db_instance.tf_rds_instance.username}" >> .env
            echo "DB_PASS=${aws_db_instance.tf_rds_instance.password}" >> .env
            echo "DB_NAME=${aws_db_instance.tf_rds_instance.db_name}" >> .env
            echo "TABLE_NAME=users" >> .env
            echo "PORT=3000" >> .env

            # Install dependencies
            npm install

            # Start the application
            nohup npm start &
            '  
  EOF

  user_data_replace_on_change = true

  tags = {
    Name = var.app_name
  }
}

resource "aws_security_group" "tf_ec2_sg" {
  name        = "Nodejs-server-sg"
  description = "Allow Http and ssh"
  vpc_id      = "vpc-00a0e3c64adf1f8f6" //default vpc id 
    ingress {
    description = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] //allow from all ips
  }
    ingress {
    description = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description = "TCP"
    from_port        = 3000 //for nodejs
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description      = "MySQL"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] // allow from all IPs
  }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
output "instance_public_ip" {
     value = aws_instance.tf_ec2_instance.public_ip
   }

output "instance_id" {
     value = aws_instance.tf_ec2_instance.id
   }

output "Permissions_for_ssh_connection" {
  value = "Ensure the SSH private key has correct permissions by running: chmod 400 ~/.ssh/terraform-ec2.pem"
}
output "ssh_to_ec2_instance" {
  value = "ssh -i ~/.ssh/terraform-ec2.pem ubuntu@${aws_instance.tf_ec2_instance.public_ip}"
}