#!/bin/bash

set -e

CLUSTER_NAME="test-cluster"

echo "🔧 Port.ioブループリント設定を修正します..."
echo "クラスター名: $CLUSTER_NAME"
echo ""

echo "📋 現在のエージェントの状態を確認します..."
kubectl get pods -n port-k8s-exporter
echo ""

echo "📋 エージェントのログからエラーを確認します..."
ERRORS=$(kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=$CLUSTER_NAME --tail=100 | grep -iE "error|failed|not found|does not exist|blueprint" | tail -10 || echo "")

if [ -z "$ERRORS" ]; then
    echo "✅ エラーは見つかりませんでした"
else
    echo "⚠️  以下のエラーが見つかりました:"
    echo "$ERRORS"
    echo ""
fi

echo ""
echo "🔧 解決手順:"
echo ""
echo "1️⃣  Port.ioダッシュボードでブループリントを確認:"
echo "   URL: https://app.port.io/builder/blueprints"
echo "   以下のブループリントが存在するか確認してください:"
echo "   - k8s_namespace"
echo "   - k8s_workload"
echo "   - k8s_pod"
echo "   - k8s_cluster"
echo ""
echo "2️⃣  ブループリントが存在しない場合、Kubernetes統合テンプレートを適用:"
echo "   URL: https://app.port.io/settings/integrations/kubernetes"
echo "   「Set up integration」または「Configure」をクリック"
echo "   Kubernetes統合テンプレートを適用してください"
echo ""
echo "3️⃣  統合テンプレートを適用した後、このスクリプトを再実行してエージェントを再起動します"
echo ""
read -p "統合テンプレートを適用しましたか？ (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 エージェントを再起動します..."
    kubectl rollout restart deployment/$CLUSTER_NAME-port-k8s-exporter -n port-k8s-exporter
    
    echo ""
    echo "⏳ エージェントが再起動するまで10秒待機します..."
    sleep 10
    
    echo ""
    echo "📋 エージェントの状態を確認します..."
    kubectl get pods -n port-k8s-exporter
    
    echo ""
    echo "📋 エージェントのログを確認します（リアルタイム）..."
    echo "   ログを確認して、エラーが解消されているか確認してください"
    echo "   Ctrl+Cで終了できます"
    echo ""
    sleep 3
    
    kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=$CLUSTER_NAME --tail=50 -f
else
    echo ""
    echo "ℹ️  統合テンプレートを適用してから、このスクリプトを再実行してください"
    echo ""
    echo "次のステップ:"
    echo "  1. https://app.port.io/settings/integrations/kubernetes にアクセス"
    echo "  2. Kubernetes統合テンプレートを適用"
    echo "  3. このスクリプトを再実行: ./scripts/fix-portio-blueprints.sh"
fi
