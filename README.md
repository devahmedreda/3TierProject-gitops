# TaskMaster GitOps

Kubernetes manifests, ArgoCD configuration, and Terraform infrastructure for the TaskMaster 3-Tier application.

> **This is the GitOps repo.** ArgoCD watches the `k8s/` directory and auto-syncs changes to the EKS cluster.
> Application source code lives in [`taskmaster-app`](https://github.com/devahmedreda/taskmaster-app).

## Repository Structure

```
taskmaster-gitops/
├── k8s/                    # Kubernetes manifests (ArgoCD watches this)
│   ├── namespace.yaml
│   ├── backend.yaml        # Backend Deployment + Service
│   ├── frontend.yaml       # Frontend Deployment + Service
│   ├── mongodb.yaml        # MongoDB Deployment + Service + PVC
│   ├── mongo-configmap.yaml
│   └── mongosecret.yaml
├── argocd/
│   └── application.yaml    # ArgoCD Application definition
└── terraform/              # AWS Infrastructure as Code
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── vpc.tf
    ├── eks.tf
    ├── ecr.tf
    └── outputs.tf
```

## How It Works

```
Developer pushes code → taskmaster-app CI builds image → CI updates image tag here → ArgoCD syncs to EKS
```

1. Developer pushes code to [`taskmaster-app`](https://github.com/devahmedreda/taskmaster-app)
2. GitHub Actions CI builds Docker image and pushes to ECR
3. CI updates the image tag in `k8s/backend.yaml` or `k8s/frontend.yaml` in **this repo**
4. ArgoCD detects the change and auto-syncs the new deployment to EKS

## Infrastructure Setup

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## ArgoCD Setup

```bash
# Install ArgoCD on EKS
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Apply the ArgoCD Application
kubectl apply -f argocd/application.yaml
```
