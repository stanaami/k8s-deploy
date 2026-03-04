#!/bin/bash

set -e

CLUSTER_NAME="test-cluster"

echo "🔍 Port.io同期の問題を診断します..."
echo "クラスター名: $CLUSTER_NAME"
echo ""

# エージェントの状態を確認
echo "📊 Port.ioエージェントの状態:"
kubectl get pods -n port-k8s-exporter
echo ""

# エージェントのログからエラーを確認
echo "📋 最近のエラーログ（最後の50行）:"
kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=$CLUSTER_NAME --tail=50 | grep -iE "error|failed|not found|does not exist|blueprint" | tail -20 || echo "エラーなし"
echo ""

# エージェントのログ全体（最近の100行）
echo "📋 エージェントのログ（最近の100行）:"
kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=$CLUSTER_NAME --tail=100 | tail -30
echo ""

# クラスター内のリソースを確認
echo "📦 クラスター内のNamespace:"
kubectl get namespaces
echo ""

echo "📦 クラスター内のPod:"
kubectl get pods --all-namespaces | grep -E "test|nginx|NAME" | head -15
echo ""

echo "📦 クラスター内のDeployments:"
kubectl get deployments --all-namespaces | grep -E "test|nginx|NAME" | head -10
echo ""

# ConfigMapを確認
echo "📋 Port.ioエージェントの設定:"
kubectl get configmap -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter -o yaml | grep -E "stateKey|CLUSTER_NAME|portBaseUrl" || echo "設定が見つかりません"
echo ""

echo "💡 診断結果:"
echo ""
echo "🔧 推奨される解決手順:"
echo ""
echo "1. Port.ioダッシュボードでブループリントを確認:"
echo "   URL: https://app.port.io/builder/blueprints"
echo "   以下のブループリントが存在するか確認:"
echo "   - k8s_namespace"
echo "   - k8s_workload"
echo "   - k8s_pod"
echo "   - k8s_cluster"
echo ""
echo "2. ブループリントが存在しない場合、Kubernetes統合テンプレートを適用:"
echo "   URL: https://app.port.io/settings/integrations/kubernetes"
echo "   「Set up integration」または「Configure」をクリック"
echo ""
echo "3. エージェントを再起動して再同期:"
echo "   kubectl rollout restart deployment/$CLUSTER_NAME-port-k8s-exporter -n port-k8s-exporter"
echo ""
echo "4. 再起動後、ログを確認:"
echo "   kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=$CLUSTER_NAME --tail=50 -f"
echo ""
