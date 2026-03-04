#!/bin/bash

echo "📊 Port.ioエージェントの状態を確認します..."
echo ""

# Podの状態を確認
echo "🔍 Podの状態:"
kubectl get pods -n port-k8s-exporter
echo ""

# Helmリリースの状態を確認
echo "📦 Helmリリースの状態:"
helm list -n port-k8s-exporter
echo ""

# k8s-testingエージェントのログを確認（最新10行）
echo "📋 k8s-testingエージェントのログ（最新10行）:"
kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=k8s-testing --tail=10 2>&1 | head -20
echo ""

# すべてのリソースを確認
echo "📦 すべてのリソース:"
kubectl get all -n port-k8s-exporter
echo ""

echo "✅ 確認完了"
echo ""
echo "💡 Port.ioダッシュボードでクラスター 'k8s-testing' が表示されているか確認してください"
