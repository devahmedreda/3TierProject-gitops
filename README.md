# TaskMaster GitOps
<img width="1024" height="1024" alt="aws-architecture" src="https://github.com/user-attachments/assets/81a8cf0f-6b5c-4580-9a29-c5495369d617" />

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
│   ├── application.yaml    # ArgoCD Application (app workloads)
│   └── monitoring.yaml     # ArgoCD Application (Prometheus + Grafana)
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

# Apply the ArgoCD Applications
kubectl apply -f argocd/application.yaml
kubectl apply -f argocd/monitoring.yaml
```

## Monitoring Stack

Cluster monitoring is managed by **ArgoCD** using `kube-prometheus-stack` Helm chart - fully GitOps.

ArgoCD auto-syncs the monitoring stack from `argocd/monitoring.yaml`, which includes:

| Component              | Purpose                      |
| ---------------------- | ---------------------------- |
| **Prometheus**         | Metrics collection & storage |
| **Grafana**            | Dashboards & visualization   |
| **Alertmanager**       | Alerting & notifications     |
| **Node Exporter**      | Host-level metrics           |
| **kube-state-metrics** | Kubernetes object metrics    |

### Accessing Dashboards

```bash
# Grafana (via LoadBalancer)
kubectl get svc -n monitoring kube-prometheus-stack-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Prometheus UI (port-forward)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Alertmanager UI (port-forward)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
```
