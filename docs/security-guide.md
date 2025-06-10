# K8s 全端專案安全配置指南

## 🎯 專案概述

本文件記錄了 K8s 全端學習專案的完整安全配置過程，從發現安全風險到最終實現多層防護的完整歷程。

## 🏗️ 最終架構

```
Internet → Cloudflare (DDoS/WAF) → Tunnel → macOS (防火牆) → SSH Port Forward → Rancher Desktop → Traefik → Applications
```

### 網路流向
- **外部域名**: `your-domain.com`
- **Cloudflare tunnel**: 指向 `your-server-ip`
- **SSH 端口轉發**: Port 80, 443
- **K8s 集群**: Rancher Desktop
- **Ingress Controller**: Traefik

## ⚠️ 發現的安全風險

### 🔴 高風險（已解決）
1. **無密碼 Traefik Dashboard**
   - **問題**: `traefik-system` namespace 暴露無密碼 Dashboard
   - **風險**: 可被外部訪問，洩露內部網路資訊
   - **解決**: 完全刪除不安全的 namespace

2. **不必要的測試服務**
   - **問題**: 測試服務對外暴露
   - **解決**: 刪除整個測試 namespace

### 🟡 中風險（已解決）
3. **缺乏網路隔離**
   - **問題**: 沒有 NetworkPolicy，服務間可任意通訊
   - **解決**: 實施跨 namespace 網路隔離政策

4. **防火牆未啟用**
   - **問題**: 系統防火牆關閉，缺少本地防護
   - **解決**: 啟用 Application Firewall 並允許必要服務

## 🛡️ 實施的安全措施

### 1. 清理危險服務
```bash
# 刪除不安全的服務
kubectl delete namespace unsafe-services

# 清理測試服務
kubectl delete namespace test-services
```

### 2. 實施網路隔離
```yaml
# NetworkPolicy 限制跨 namespace 通訊
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: fullstack-app
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    - namespaceSelector:
        matchLabels:
          name: fullstack-app
```

### 3. 啟用系統防火牆
```bash
# macOS Application Firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp on
```

### 4. 更新 Ingress 配置
- 從 wildcard `*` 改為特定域名
- 移除重複的 Ingress 資源
- 統一管理路由規則

### 5. 強化應用配置
- 啟用 OAuth2 用戶管理
- 正確設置 HTTPS 域名
- 配置安全 Cookie

## 🔒 多層安全防護

### Layer 1: Cloudflare 保護
- **DDoS 防護**: 自動阻擋攻擊流量
- **WAF**: Web 應用程式防火牆
- **SSL/TLS**: 端到端加密
- **Rate Limiting**: 請求頻率限制

### Layer 2: 系統防火牆
- **Application Firewall**: 控制應用網路訪問
- **允許清單**: 只允許授權的應用
- **自動防護**: 系統會詢問是否允許新連接

### Layer 3: SSH Port Forwarding
- **加密隧道**: 所有流量經過 SSH 加密
- **認證保護**: 需要 SSH 認證才能建立隧道
- **單點控制**: 集中管理所有端口轉發

### Layer 4: Kubernetes 網路隔離
- **NetworkPolicy**: 限制 Pod 間通訊
- **Namespace 隔離**: 邏輯分離不同服務
- **Service 控制**: 只暴露必要的服務

### Layer 5: 應用層認證
- **K8s API**: 需要客戶端憑證認證
- **OAuth2**: 現代認證整合
- **Ingress**: 只處理授權的路由

## 📊 安全檢查清單

### ✅ 已完成
- [x] 移除不安全的服務和配置
- [x] 實施網路隔離政策
- [x] 啟用系統防火牆
- [x] 配置 OAuth2 認證
- [x] 統一 Ingress 路由管理
- [x] 驗證多層防護有效性

### 🔍 定期檢查項目
```bash
# 1. 檢查 NodePort 服務
kubectl get svc -A | grep NodePort

# 2. 驗證 NetworkPolicy 生效
kubectl get networkpolicies -A

# 3. 確認防火牆狀態
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# 4. 檢查監聽端口
lsof -i -P | grep LISTEN

# 5. 驗證服務正常運作
curl -s https://your-domain.com | head -5
```

## 🎯 最佳實踐總結

### 設計原則
1. **最小權限原則**: 只開放必要的服務和端口
2. **深度防禦**: 多層安全措施，避免單點故障
3. **定期檢查**: 持續監控和驗證安全配置
4. **文件化**: 記錄所有安全決策和配置

### 學習要點
1. **K8s 安全不僅是集群內部**，還需考慮網路邊界
2. **NodePort 服務需要特別注意**，容易成為攻擊入口
3. **NetworkPolicy 是必要的**，預設的 K8s 網路過於開放
4. **系統防火牆仍然重要**，即使有應用層防護

## 🚀 後續擴展指引

### 添加新服務時的安全考量
1. **評估網路需求**: 是否需要特殊的網路配置
2. **檢查 NetworkPolicy**: 更新網路隔離規則
3. **配置認證**: 設置適當的認證機制
4. **測試安全性**: 驗證新服務不會引入風險

### 監控和告警
```bash
# 監控 K8s 資源變化
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# 檢查系統防火牆日誌
log show --predicate 'subsystem contains "com.apple.alf"' --info --last 1h
```

## 📈 安全成熟度評估

### 當前等級: 🟢 優秀
- **防護覆蓋**: 多層防護，無明顯漏洞
- **配置管理**: 文件化完整，可重現
- **認證機制**: 現代化認證
- **網路安全**: 適當的隔離和控制

### 可選的進階措施
- **監控告警系統**: 集成監控解決方案
- **證書管理**: 自動化 SSL 證書更新
- **備份策略**: 定期備份配置和資料
- **安全評估**: 定期安全檢查

## 💡 經驗總結

1. **安全是漸進式的過程**，不是一次性配置
2. **每個暴露的端口都是潛在風險**，需要仔細評估
3. **多層防護比單一強化更有效**
4. **文件化和檢查清單是維護安全的關鍵**
5. **現代認證方式提供更好的用戶體驗和安全性**

---

*本文件記錄了從發現安全風險到實現企業級安全配置的完整過程，可作為類似專案的參考指南。*
