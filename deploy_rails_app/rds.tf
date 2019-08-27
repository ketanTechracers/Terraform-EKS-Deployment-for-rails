resource "aws_db_instance" "rails_db_server" {
  allocated_storage      = "${var.db_allocated_storage}"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "${var.db_instance_type}"
  name                   = "mydb"
  username               = "${var.db_username}"
  password               = "${var.db_password}"
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = ["${aws_security_group.terraform_eks_demo_cluster.id}"]
}