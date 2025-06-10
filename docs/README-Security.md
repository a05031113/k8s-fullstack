# K8s Fullstack Project - Database Security Guide

## 🛡️ 安全設置說明

本專案採用安全的密碼管理方式，**不會將任何敏感資訊提交到 GitHub**。

## 📁 檔案結構

```
k8s-fullstack/
├── .gitignore                                    # 排除敏感檔案
├── k8s/database/
│   ├── postgres-secret.template.yaml            # ✅ 模板檔案（可提交）
│   ├── postgres-secret.yaml                     # ❌ 敏感檔案（不提交）
│   ├── postgres-configmap.yaml                  # ✅ 配置檔案（可提交）
│   ├── postgres-pvc.yaml                        # ✅ 存儲配置（可提交）
│   ├── postgres-statefulset.yaml               # ✅ 部署配置（可提交）
│   └── postgres-service.yaml                   # ✅ 服務配置（可提交）
├── scripts/
│   └── generate-secret.sh                      # ✅ 密碼生成腳本（可提交）
└── .postgres-passwords.txt                     # ❌ 密碼記錄（不提交）
```

## 🚀 使用方式

### 方法 1: 自動生成密碼（推薦）

```bash
# 1. 進入專案目錄
cd /Users/yanghaoyu/Documents/k8s-fullstack

# 2. 執行密碼生成腳本
chmod +x scripts/generate-secret.sh
./scripts/generate-secret.sh

# 3. 檢查生成的檔案
ls -la k8s/database/postgres-secret.yaml
cat .postgres-passwords.txt
```

### 方法 2: 手動建立密碼

```bash
# 1. 複製模板檔案
cp k8s/database/postgres-secret.template.yaml k8s/database/postgres-secret.yaml

# 2. 生成 base64 編碼密碼
echo -n "your-admin-password" | base64
echo -n "your-n8n-password" | base64
echo -n "your-app-password" | base64

# 3. 編輯 postgres-secret.yaml，替換所有 REPLACE_WITH_BASE64_* 值
vim k8s/database/postgres-secret.yaml
```

## 🔐 密碼安全最佳實踐

### 生成強密碼：
```bash
# 生成 16 字符的隨機密碼
openssl rand -base64 20 | tr -d "=+/" | cut -c1-16

# 生成包含特殊字符的密碼
openssl rand -base64 24 | head -c 20
```

### 檢查密碼強度：
- 至少 12 個字符
- 包含大小寫字母、數字
- 避免字典詞彙
- 每個服務使用不同密碼

## 📋 部署檢查清單

在部署前確認：

- [ ] `.gitignore` 包含 `postgres-secret.yaml`
- [ ] `postgres-secret.yaml` 已生成且包含實際密碼
- [ ] `.postgres-passwords.txt` 已生成且妥善保管
- [ ] 沒有將敏感檔案加入 Git

```bash
# 檢查 Git 狀態
git status
# 確保 postgres-secret.yaml 和 .postgres-passwords.txt 不在列表中

# 檢查 .gitignore 是否生效
git check-ignore k8s/database/postgres-secret.yaml
# 應該顯示：k8s/database/postgres-secret.yaml
```

## 🚀 部署到 Kubernetes

```bash
# 1. 部署 namespace
kubectl apply -f k8s/namespace.yaml

# 2. 部署資料庫相關資源
kubectl apply -f k8s/database/

# 3. 檢查部署狀態
kubectl get all -n database
```

## 🔍 驗證部署

```bash
# 檢查 Secret 是否創建
kubectl get secrets -n database

# 檢查 PostgreSQL 是否正常啟動
kubectl logs postgres-0 -n database

# 測試資料庫連接
kubectl exec -it postgres-0 -n database -- psql -U admin -d postgres -c "\l"
```

## 🆘 故障排除

### Secret 沒有生成：
```bash
# 重新執行生成腳本
./scripts/generate-secret.sh
```

### 密碼不正確：
```bash
# 檢查 Secret 內容（base64 解碼）
kubectl get secret postgres-secret -n database -o jsonpath='{.data.admin-password}' | base64 -d
```

### ConfigMap 密碼不匹配：
```bash
# 重新執行生成腳本，它會自動同步密碼
./scripts/generate-secret.sh
```

## ⚠️ 安全警告

1. **絕對不要**將 `postgres-secret.yaml` 提交到 GitHub
2. **絕對不要**將 `.postgres-passwords.txt` 提交到 GitHub  
3. **定期更換**生產環境密碼
4. **妥善保管**密碼記錄檔案
5. **使用強密碼**且每個服務不同

## 🎯 生產環境建議

對於生產環境，建議使用：
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault
- Google Secret Manager
- Kubernetes External Secrets Operator

## 📞 支援

如果遇到安全相關問題：
1. 檢查 `.gitignore` 設置
2. 確認敏感檔案沒有被追蹤
3. 重新生成密碼和 Secret
4. 聯繫團隊安全負責人
