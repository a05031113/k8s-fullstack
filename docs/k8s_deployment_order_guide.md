# Kubernetes 部署順序重要性指南

## 🎯 概述

在 Kubernetes 中，資源部署的順序至關重要。錯誤的部署順序會導致 Pod 無法啟動、服務無法正常運作，甚至整個應用失敗。本指南詳細說明為什麼順序重要，以及如何正確部署。

## 📊 資源依賴關係圖

```
┌─────────────────┐
│   1. Namespace  │ ◄── 必須最先建立，提供資源邊界
└─────────────────┘
          │
          ▼
┌─────────────────┐
│   2. RBAC       │ ◄── ServiceAccount + 權限設定
│   (SA/Role)     │
└─────────────────┘
          │
          ▼
┌─────────────────┐
│ 3. ConfigMap/   │ ◄── 配置和認證資料
│    Secret       │
└─────────────────┘
          │
          ▼
┌─────────────────┐
│ 4. PVC/Storage  │ ◄── 持久化存儲（如果需要）
└─────────────────┘
          │
          ▼
┌─────────────────┐
│ 5. Deployment/  │ ◄── 應用工作負載
│    StatefulSet  │
└─────────────────┘
          │
          ▼
┌─────────────────┐
│ 6. Service      │ ◄── 網路服務暴露
└─────────────────┘
          │
          ▼
┌─────────────────┐
│ 7. Ingress      │ ◄── 外部訪問路由
└─────────────────┘
```

## 🚀 正確的部署順序

### 1. Namespace（基礎邊界）
```bash
kubectl apply -f namespace.yaml
```

**為什麼第一個？**
- 提供資源隔離和組織邊界
- 後續所有資源都需要指定 namespace
- 沒有 namespace，其他資源無法創建

**失敗症狀**：
```
error: the server could not find the requested resource (post namespaces)
```

### 2. RBAC 權限設定
```bash
kubectl apply -f rbac.yaml
```

**包含資源**：
- ServiceAccount
- ClusterRole / Role
- ClusterRoleBinding / RoleBinding

**為什麼在這裡？**
- Pod 需要以特定身份運行
- 應用可能需要訪問 K8s API
- 權限控制是安全的基礎

**失敗症狀**：
```
error: serviceaccounts "traefik" not found
```

### 3. ConfigMap 和 Secret
```bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
```

**為什麼在 Deployment 之前？**
- Pod 啟動時需要掛載配置檔案
- 環境變數需要從這些資源讀取
- 配置不存在，容器無法啟動

**失敗症狀**：
```
CreateContainerConfigError: configmap "app-config" not found
```

### 4. 持久化存儲（如果需要）
```bash
kubectl apply -f pvc.yaml
```

**為什麼在這裡？**
- StatefulSet 或有狀態應用需要持久化存儲
- Volume 必須在 Pod 啟動前就緒
- 存儲故障會導致 Pod 無法調度

**失敗症狀**：
```
FailedScheduling: persistentvolumeclaim "data-pvc" not found
```

### 5. 工作負載（Deployment/StatefulSet）
```bash
kubectl apply -f deployment.yaml
```

**為什麼在中間？**
- 依賴前面所有的基礎資源
- 創建實際運行的 Pod
- 是應用的核心組件

**失敗症狀**：
```
ImagePullBackOff, CrashLoopBackOff, CreateContainerError
```

### 6. Service（網路暴露）
```bash
kubectl apply -f service.yaml
```

**為什麼在 Deployment 之後？**
- Service 需要選擇已存在的 Pod
- 沒有 Pod，Service 沒有 endpoint
- 可以在 Pod 啟動後再暴露服務

**失敗症狀**：
```
service has no endpoints (Pod 不存在或標籤不匹配)
```

### 7. Ingress（外部訪問）
```bash
kubectl apply -f ingress.yaml
```

**為什麼最後？**
- 依賴 Service 存在
- 需要 Ingress Controller 運行
- 是對外暴露的最後一層

**失敗症狀**：
```
service "app-service" not found
```

## ❌ 常見錯誤順序和後果

### 錯誤 1：先部署 Deployment
```bash
# ❌ 錯誤做法
kubectl apply -f deployment.yaml  # ConfigMap 不存在
kubectl apply -f configmap.yaml   # 太晚了！
```

**後果**：
- Pod 卡在 `CreateContainerConfigError`
- 需要重新啟動 Pod 才能掛載配置
- 可能導致應用配置錯誤

### 錯誤 2：忘記建立 Namespace
```bash
# ❌ 錯誤做法
kubectl apply -f deployment.yaml  # 找不到 namespace
```

**後果**：
```
error: the namespace "app-namespace" not found
```

### 錯誤 3：Service 在 Pod 之前
```bash
# ❌ 錯誤做法（技術上可行但不理想）
kubectl apply -f service.yaml     # 沒有 endpoint
kubectl apply -f deployment.yaml  # Pod 啟動後才有 endpoint
```

**後果**：
- Service 暫時沒有可用的 endpoint
- 可能影響健康檢查和監控
- 增加故障排除複雜性

## ✅ 實踐建議

### 1. 使用腳本自動化
```bash
#!/bin/bash
# 按順序部署
kubectl apply -f 01-namespace.yaml
kubectl apply -f 02-rbac.yaml
kubectl apply -f 03-configmap.yaml
kubectl apply -f 04-secret.yaml
kubectl apply -f 05-pvc.yaml
kubectl apply -f 06-deployment.yaml
kubectl apply -f 07-service.yaml
kubectl apply -f 08-ingress.yaml
```

### 2. 使用 kubectl wait 等待就緒
```bash
# 等待 Deployment 就緒後再部署 Service
kubectl apply -f deployment.yaml
kubectl wait --for=condition=available deployment/app --timeout=300s
kubectl apply -f service.yaml
```

### 3. 使用 Kustomize 或 Helm
```yaml
# kustomization.yaml
resources:
- namespace.yaml
- rbac.yaml
- configmap.yaml
- deployment.yaml
- service.yaml
- ingress.yaml
```

### 4. 檔案命名慣例
```
01-namespace.yaml
02-rbac.yaml
03-configmap.yaml
04-secret.yaml
05-pvc.yaml
06-deployment.yaml
07-service.yaml
08-ingress.yaml
```

## 🔧 故障排除指南

### 檢查資源依賴
```bash
# 檢查 Pod 事件
kubectl describe pod <pod-name> -n <namespace>

# 檢查 Deployment 狀態
kubectl get deployments -n <namespace>

# 檢查 Service endpoint
kubectl get endpoints -n <namespace>
```

### 常用除錯指令
```bash
# 查看所有資源狀態
kubectl get all -n <namespace>

# 查看資源事件
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# 查看 Pod 日誌
kubectl logs -f deployment/<app> -n <namespace>
```

### 重新部署策略
```bash
# 刪除有問題的資源（從上往下）
kubectl delete ingress/<name> -n <namespace>
kubectl delete service/<name> -n <namespace>
kubectl delete deployment/<name> -n <namespace>

# 重新按順序部署
```

## 📚 學習重點

### 核心概念
1. **資源依賴**：理解 K8s 資源之間的依賴關係
2. **生命週期**：每種資源的創建和就緒時機
3. **故障隔離**：錯誤順序如何影響應用穩定性

### 最佳實踐
1. **總是從 Namespace 開始**
2. **配置先於應用**
3. **應用先於網路暴露**
4. **使用腳本自動化部署**
5. **添加適當的等待和檢查**

### 進階技巧
1. **使用 Helm Charts 管理複雜應用**
2. **利用 Kustomize 處理多環境配置**
3. **實施 GitOps 工作流**
4. **集成 CI/CD 管道**

## 🎯 總結

正確的部署順序是 Kubernetes 應用成功運行的基礎。遵循依賴關係，從基礎設施到應用，再到網路暴露，可以避免大多數部署問題。記住：**順序不只是建議，而是技術要求**。

建立良好的部署習慣和自動化腳本，能夠大大提高部署成功率和運維效率。