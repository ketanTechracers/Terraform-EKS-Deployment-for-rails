# To Enable CloudWatch Logs for resource manipulation alerts
resource "aws_cloudwatch_log_group" "cloudwatch_logs" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30
}

# The main cluster resource
resource "aws_eks_cluster" "demo" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.terraform_eks_demo_cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.terraform_eks_demo_cluster.id}"]
    subnet_ids         = "${aws_subnet.demo[*].id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.terraform_eks_demo_cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.terraform_eks_demo_cluster-AmazonEKSServicePolicy",
    "aws_cloudwatch_log_group.cloudwatch_logs"
  ]
}

resource "aws_iam_role" "terraform_eks_demo_cluster" {
  name = "terraform-eks-terraform_eks_demo_cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "terraform_eks_demo_cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.terraform_eks_demo_cluster.name}"
}

resource "aws_iam_role_policy_attachment" "terraform_eks_demo_cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.terraform_eks_demo_cluster.name}"
}

resource "aws_security_group" "terraform_eks_demo_cluster" {
  name        = "terraform-eks-terraform_eks_demo_cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.demo.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_security_group_rule" "terraform_eks_demo_cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.terraform_eks_demo_cluster.id}"
  source_security_group_id = "${aws_security_group.demo-node.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "terraform_eks_demo_cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]  # Work stations to whitelist that can access cluster APIs
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.terraform_eks_demo_cluster.id}"
  to_port           = 443
  type              = "ingress"
}
