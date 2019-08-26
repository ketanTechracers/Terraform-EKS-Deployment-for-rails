# Terraform Deployment Of Rails app in EKS Cluster

## Intro

The configurations in the repository would create the required components for a Vanilla rails application running in an AWS EKS Cluster and provision AWS components requiring the same. The Gitlab CI file also takes care of automating the build and deploy process.

## Prerequisites

- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) should be installed in your system
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) must be installed and your AWS credentials must be setup using command `aws configure`
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) must be pre-installed to use Kubernetes features.

## Commands

1. `make eks-up` : To create only the EKS cluster using Terraform
2. `make rails-up` : To spin up only the rails kubernetes component and related AWS resource
3. `make eks-down` : To destroy only the rails kubernetes component
4. `make rails-down` : To destroy only the EKS cluster using Terraform

*Note: Refer the `Makefile` to understand the related terraform commands fired internally*

## Components

Repository has two separate terraform configurations and a CI pipelike file in this repository:

### 1. `Create Cluster`
 
Folder `create_cluster` contains Terraform configurations to create an EKS Cluster using Terraform and all the related AWS Components. This configuration creates the following resources:

- EKS Cluster: AWS managed Kubernetes cluster of master servers
- AutoScaling Group containing 2 m4.large instances based on the latest EKS Amazon Linux 2 AMI: Operator managed Kuberneted worker nodes for running Kubernetes service deployments
- Associated VPC, Internet Gateway, Security Groups, and Subnets: Operator managed networking resources for the EKS Cluster and worker node instances
- Associated IAM Roles and Policies: Operator managed access resources for EKS and worker node instances

Creating an EKS using these configuration is totally optional.

*NOTE: There are other ways to create an EKS cluster like Using [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html) or By using AWS console. Our primary goal to add this configuration was to setup most of the things using Terraform.*

### 2. `Deploy Rails App`

Folder `deploy_rails_app` contains configurations to create the cluster components (like Kubernetes deployment, Pods, Service, Secrets) and other external AWS resources required for hosting the rails app like (RDS instance for DB, etc).

**IMPORTANT:**
- This configuration needs to run after you have created a cluster and your `kubectl` is pointing to the newly created cluster.
- In order for this terraform config to work you need to add the `deploy_rails_app/terraform.tfvars` file which is gitignored. A sample content of tfvars file is given in the repository.

To point your `kubectl` to target EKS cluster, you can look at [Creating kubeconfig instructions](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html) on official EKS docs.

The configurations mentioned here creates the following resources:

- An RDS instance for DB
- A Kubernetes Secret having sensitive information encrypted safely
- A Kuberenetes Deployment launching 2 Pods running rails app container within each of them
- A Load Balancer Service that balances the requests incoming between 2 rails instances

### 3. `CI/CD Pipeline`
- The CI/CD Pipeline is setup in `.gitlab-ci.yml` that runs Everytime the new code is merged in master branch
- Before it runs, the `terraform.tfvars` file's content must be configured as a secret ENV in gitlab CI dashboard. Below are the steps to do so:
  1. Export original `terraform.tfvars` file with base64 encoding by command `cat myfile.txt | base64`
  2. Copy result and insert it to Gitlab project settings
    `(Your project → Settings → CI/CD → Environment variables)`
- The Pipeline script will run as following:
  1. run all the unit tests
  2. build and push an updated docker image with updated tag
  3. Update that tag's info in `terraform.tfvars` file
  4. Roll out deployment in terraform with updated docker image


## Design Considerations

### 1. Externalize configurable parameters
- The configurable variables are bieng kept in file `terraform.tfvars` in each of the configuration folder.
- It is gitignored to never get the sensitive information up with codebase.
- This file would only be accesible to the Cluster Admin OR would be loaded as a secret in the CI/CD pipeline execution environment.

### 2. Safely Mounting Env Variables

- We have divided Env variables needed by rails app in two categories: `Sensitive` and `Non-sensitive` env variables.
- Sensitive env variables like passwods, keys, etc are loaded into Kubernetes cluster using [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/). It reduces the risk of accidental exposure even after deployment.
- The `Non-sensitive` env variables like port, rails_env, etc are loaded normally as a key value pair.
- Both types of variables are dynamically read from the `tfvars` file and injected into the Pods running rails app.

### 3. Securing the Ecosystem

- All the components of the ecosystem inside EKS and the related RDS are inside a single VPC.
- Inside the VPC, there's security group having only http and https port opened for the outside world. 
- A security rule named `demo-cluster-ingress-workstation-https` is also added to whitelist any given set of IP addresses that can access the https port
- The RDS instance is setup so that it only responds to request coming from the mentioned security group via `vpc_security_group_ids` param. This param only passes the security group in which our rails app instance are present.

### 4. Scalability and Monitoring
- The worker nodes in EKS cluster are set in an [Auto Scaling group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html). It enables you to use Amazon EC2 Auto Scaling features such as health check replacements and scaling policies.
- The rails app pods running inside the cluster are also auto-scalable using Kubernetes [Horizontal Pod Autoscalar](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). Whenever a pod's CPU utilization goes beyond a tolerable factor, it spins up a new pod too handle load.  
- [The CloudWatch Logs](https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) are enabled for resources in EKS to monitor any resource manipulation by the AWS admin owner.
