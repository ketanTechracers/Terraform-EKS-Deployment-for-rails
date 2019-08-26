SHELL=/bin/bash

eks-cluster-up:
	terraform apply ./create_cluster

eks-cluster-down:
	terraform destroy ./create_cluster

rails-deployment-up:
	terraform apply ./deploy_rails_app
	echo "==== Rails Kubernetes setup complete on your cluster! ===="
	echo "* PODS RUNNING:"
	kubectl get pods

rails-deployment-down:
	terraform destroy ./deploy_rails_app

