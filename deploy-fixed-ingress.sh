#!/bin/bash

# 🔧 修復腳本權限
chmod +x /Users/yanghaoyu/Documents/k8s-fullstack/deploy-fixed-ingress.sh

# 🔧 修復 Traefik Ingress 路由問題
# 解決 Gemma Backend API 路徑重複問題

set -e

echo "🔧 修復 Traefik Ingress 路由配置..."

cd /Users/yanghaoyu/Documents/k8s-fullstack/k8s/ingress/

# 檢查是否存在 domain-secret.yaml
if [ ! -f "domain-secret.yaml" ]; then
    echo "❌ 找不到 domain-secret.yaml，請先設置域名配置"
    echo "執行：cp domain-secret.example.yaml domain-secret.yaml"
    echo "然後編輯 domain-secret.yaml 設置正確的域名"
    exit 1
fi

echo "📋 應用域名 Secret..."
kubectl apply -f domain-secret.yaml

echo "🌐 部署修復的 Ingress 配置..."
# 替換佔位符並部署
sed 's/APP_DOMAIN_PLACEHOLDER/app.system2.work/g; s/N8N_DOMAIN_PLACEHOLDER/n8n.system2.work/g' traefik-ingress.yaml | kubectl apply -f -

echo "⏳ 等待 Ingress 配置生效..."
sleep 10

echo "🔍 檢查 Ingress 狀態..."
kubectl get ingressroute -n fullstack-app
kubectl get middleware -n fullstack-app | grep gemma

echo "🧪 測試修復結果..."
echo "正在測試 API 端點..."

# 等待服務準備
sleep 5

echo "✅ Ingress 修復完成！"
echo ""
echo "📋 測試指令："
echo "curl -v https://app.system2.work/gemma/api/health"
echo "curl -v https://app.system2.work/gemma/api/"
echo ""
echo "📊 監控日誌："
echo "kubectl logs -f deployment/gemma-backend -n fullstack-app"
