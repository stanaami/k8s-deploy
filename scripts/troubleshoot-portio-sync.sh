#!/bin/bash

echo "🔍 Port.io同期の問題を診断します..."
echo ""

# エージェントの状態を確認
echo "📊 Port.ioエージェントの状態:"
kubectl get pods -n port-k8s-exporter
echo ""

# エージェントのログからエラーを確認
echo "📋 最近のエラーログ:"
kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=k8s-testing --tail=100 | grep -i "error\|failed\|not found" | tail -10
echo ""

# クラスター内のリソースを確認
echo "📦 クラスター内のリソース:"
echo "Deployments:"
kubectl get deployments --all-namespaces | grep -E "test|NAME"
echo ""
echo "Pods:"
kubectl get pods --all-namespaces | grep -E "test|NAME" | head -10
echo ""

echo "💡 問題の原因:"
echo "  Port.ioエージェントのログに以下のエラーが表示されています:"
echo "  - 'Entity with identifier ... does not exist in the blueprint k8s_workload'"
echo ""
echo "🔧 解決方法:"
echo "  1. Port.ioダッシュボードでブループリント設定を確認"
echo "     - 'k8s_workload' ブループリントが存在するか確認"
echo "     - 'k8s_pod' ブループリントが存在するか確認"
echo ""
echo "  2. エージェントを再起動して再同期:"
echo "     kubectl rollout restart deployment/k8s-testing-port-k8s-exporter -n port-k8s-exporter"
echo ""
echo "  3. Port.ioの統合設定を確認:"
echo "     - Port.ioダッシュボード > Settings > Integrations > Kubernetes"
echo "     - ブループリントが正しく設定されているか確認"
echo ""
