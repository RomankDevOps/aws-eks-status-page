#!/bin/bash

echo "⚠️  Initiating Full Infrastructure Teardown ⚠️"

# Step 1: Delete the NGINX ingress service first to ensure the AWS Load Balancer is destroyed
echo "Cleaning up AWS Load Balancers..."
kubectl delete svc ingress-nginx-controller -n ingress-nginx --ignore-not-found=true

# Step 2: Let Terraform destroy the Helm charts
echo "Destroying Helm Releases..."
terraform destroy -target="helm_release.status_page_app" -target="helm_release.ingress_nginx" -auto-approve

# Step 3: Destroy the EKS cluster, VPC, and remaining AWS resources
echo "Destroying AWS Infrastructure..."
terraform destroy -auto-approve

echo "✅ Clean-up complete. The Reaper Bot has nothing left to destroy."
