# 🚀 Full-Stack Kubernetes Learning Project

A comprehensive microservices architecture project designed for learning Kubernetes concepts in production-like environments. This project implements enterprise-grade security, multi-layered protection, and automated workflows.

## 🏗️ Architecture Overview

### Multi-Machine Setup
- **Development Environment**: M2 Pro Mac (Code development)
- **Kubernetes Cluster**: M1 Mac with Rancher Desktop
- **Production Access**: Cloudflare tunnel + OAuth2 authentication

### Infrastructure Stack
```
Internet → Cloudflare (DDoS/WAF) → Tunnel → macOS Firewall → SSH Port Forward → Rancher Desktop → Traefik → Applications
```

### Core Services
- **Database**: PostgreSQL 15 with multi-database setup
- **Automation Platform**: n8n with MCP support and OAuth2
- **Ingress Controller**: Traefik with security middleware
- **Storage**: Persistent volumes with local-path provisioner
- **Security**: NetworkPolicies, RBAC, and multi-layer protection

## 📁 Project Structure

```
k8s-fullstack/
├── k8s/
│   ├── namespace.yaml              # Resource namespacing
│   ├── database/                   # PostgreSQL deployment
│   ├── n8n/                        # n8n automation platform
│   ├── traefik/                    # Ingress controller
│   ├── security/                   # Security configurations
│   ├── backend/                    # Future Go API services
│   └── frontend/                   # Future React applications
├── docs/                           # Documentation
├── scripts/                        # Automation scripts
├── .local-test/                    # Local development
└── environments/                   # Environment-specific configs
```

## 🎯 Learning Objectives

### Kubernetes Core Concepts
- **Pod Lifecycle Management**: Health checks, restart policies, resource limits
- **Service Discovery**: ClusterIP, NodePort, and Ingress routing  
- **StatefulSets vs Deployments**: Understanding stateful vs stateless applications
- **Storage Management**: PVCs, storage classes, and data persistence
- **Network Policies**: Inter-service communication and security isolation
- **RBAC**: Service accounts, roles, and security boundaries

### Microservices Architecture
- **Cross-Namespace Communication**: Service discovery with DNS
- **Configuration Management**: ConfigMaps, Secrets, and environment variables
- **Load Balancing**: kube-proxy mechanisms and traffic distribution
- **Health Monitoring**: Liveness and readiness probes

### Security Best Practices
- **Multi-Layer Security**: Cloudflare → Firewall → SSH → K8s → Application
- **OAuth2 Integration**: Modern authentication with Google OAuth
- **Network Isolation**: NetworkPolicies for service segmentation
- **Secret Management**: Secure handling of credentials and API keys

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (Rancher Desktop recommended)
- kubectl configured
- PostgreSQL client (optional, for testing)

### 1. Deploy Core Infrastructure
```bash
# Create namespaces
kubectl apply -f k8s/namespace.yaml

# Deploy PostgreSQL database
kubectl apply -f k8s/database/
```

### 2. Deploy Traefik Ingress Controller
```bash
kubectl apply -f k8s/traefik/
```

### 3. Deploy n8n Automation Platform
```bash
kubectl apply -f k8s/n8n/
```

### 4. Apply Security Policies
```bash
kubectl apply -f k8s/security/
```

## 🔐 Security Configuration

### Multi-Layer Protection
1. **Cloudflare Protection**: DDoS, WAF, and SSL/TLS termination
2. **System Firewall**: macOS Application Firewall enabled
3. **SSH Tunnel**: Encrypted port forwarding for secure access
4. **Network Policies**: K8s-level service isolation
5. **OAuth2 Authentication**: Google-based user authentication

### Security Checklist
- [x] Remove insecure services
- [x] Implement network isolation policies
- [x] Enable system firewall protection
- [x] Configure OAuth2 authentication
- [x] Use HTTPS with secure cookies
- [x] Implement RBAC for service accounts

## 📚 Learning Resources

### Documentation
- [Setup Guide](docs/setup.md) - Initial deployment instructions
- [Security Guide](docs/security-guide.md) - Complete security implementation
- [Deployment Order Guide](docs/k8s_deployment_order_guide.md) - Resource deployment sequence
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

## 🤝 Contributing

This project serves as a learning platform for Kubernetes and microservices architecture with focus on:

1. **Infrastructure as Code**: All configurations are version-controlled
2. **Security First**: Multiple layers of protection and modern authentication
3. **Production Readiness**: Real-world practices and enterprise patterns
4. **Documentation**: Comprehensive guides for learning and reference

---

**Project Focus**: Learning Kubernetes through practical implementation of a secure, scalable microservices architecture.
