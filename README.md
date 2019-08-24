# Terraform Deployment Of Rails app in EKS Cluster

## Intro

The configurations in the repository would create the required components for a Vanilla rails application and provision AWS components requiring the same.

## Prerequisites

- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) should be installed in your system
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) must be installed and your AWS credentials must be setup using command `aws configure`
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) must be pre-installed to use Kubernetes features.

## Components

Repository has two separate terraform configurations in this repository:

1. **`create_cluster`** : It contains Terraform configurations to create an EKS Cluster using Terraform and all the related VPC, Subnets, Internet Gateway, Security Groups, Associated IAM Roles and Policies. Creating an EKS using these configuration is totally optional.

*NOTE: There are other ways to create an EKS cluster like Using [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html) or By using AWS console. Our primary goal to add this configuration was to setup most of the things using Terraform.*

2. **`deploy_rails_app`**: This folder contains configurations to create the cluster components (like Kubernetes deployment, Pods, Service, Secrets) and other external AWS resources required for hosting the rails app like (RDS instance for DB, etc).

*NOTE: This configuration needs to run after you have created a cluster and your `kubectl` is pointing to the newly created cluster.*

To point your `kubectl` to target EKS cluster, you can look at [Creating kubeconfig instructions](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html) on official EKS docs.

The configurations mentioned here includes the following resources:
