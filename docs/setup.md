# Setup Guide

## Prerequisites
- Kubernetes cluster (Rancher Desktop)
- kubectl configured
- Docker for building images (optional)

## Directory Structure
```
k8s-fullstack/
├── k8s/
│   ├── namespace.yaml
│   ├── database/          # PostgreSQL configurations
│   ├── backend/           # Go API configurations  
│   ├── frontend/          # Next.js configurations
│   └── monitoring/        # Monitoring stack
├── scripts/               # Deployment scripts
├── docs/                  # Documentation
└── environments/          # Environment-specific configs
```

## Initial Setup
1. Clone this repository
2. Make scripts executable: `chmod +x scripts/*.sh`
3. Deploy: `./scripts/deploy.sh`

## Updating Applications
When new versions are available:
1. Update image versions: `./scripts/update-version.sh frontend v1.0.1`
2. Apply changes: `kubectl apply -f k8s/frontend/`

## Monitoring
- Logs: `kubectl logs -f deployment/backend-api -n fullstack-app`
- Status: `kubectl get all -n fullstack-app`
- Events: `kubectl get events -n fullstack-app`
