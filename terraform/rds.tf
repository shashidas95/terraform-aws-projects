/*
rds.tf
1. rds resource
2. security group 
	     - 3306
          security group => tf_ec2_sg
          cidr block=> [“local ip”]
3. output

*/

resource "aws_db_instance" "tf_rds_instance" {
  allocated_storage    = 10
  db_name              = "shashi_demo"
  identifier           = "multi-tier-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = true
  vpc_security_group_ids = [ aws_security_group.tf_rds_sg.id ]
}
resource "aws_db_subnet_group" "main" {
  name       = "new-db-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]  # Use private subnets
  description = "My database subnet group"
}
resource "aws_security_group" "tf_rds_sg" {
  name        = "allow_mysql"
  description = "Allow mysql traffic"
  vpc_id      = aws_vpc.main.id//"vpc-00a0e3c64adf1f8f6"//default vpc id

  ingress {
  description      = "Allow MySQL from EC2"
  from_port        = 3306
  to_port          = 3306
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"] //local ip 
  security_groups = [aws_security_group.tf_ec2_sg.id]// EC2 instance security group ID
}
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
locals {
  rds_endpoint = element(split(":", aws_db_instance.tf_rds_instance.endpoint),0)
}
output "rds_endpoint" {
  value =  local.rds_endpoint
}
output "db_username" {
  value = aws_db_instance.tf_rds_instance.username
}
