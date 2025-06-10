# Troubleshooting Guide

## Common Issues

### Pods Not Starting
```bash
# Check pod status
kubectl get pods -n fullstack-app

# Describe pod for events
kubectl describe pod <pod-name> -n fullstack-app

# Check logs
kubectl logs <pod-name> -n fullstack-app
```

### Image Pull Errors
```bash
# Check if image exists
docker pull ghcr.io/yourusername/frontend-app:v1.0

# Verify image name in deployment
kubectl get deployment frontend-app -n fullstack-app -o yaml | grep image
```

### Database Connection Issues
```bash
# Check database status
kubectl get all -n database

# Test database connection
kubectl exec -it deployment/postgres -n database -- psql -U myuser -d mydatabase
```

### Service Discovery Issues
```bash
# Check services
kubectl get svc -n fullstack-app
kubectl get svc -n database

# Test internal connectivity
kubectl exec -it deployment/backend-api -n fullstack-app -- nslookup postgres-service.database.svc.cluster.local
```

## Useful Commands
```bash
# Port forward for local testing
kubectl port-forward svc/frontend-service 3000:3000 -n fullstack-app

# Scale applications
kubectl scale deployment backend-api --replicas=3 -n fullstack-app

# Restart deployment
kubectl rollout restart deployment/backend-api -n fullstack-app

# View resource usage
kubectl top pods -n fullstack-app
```
