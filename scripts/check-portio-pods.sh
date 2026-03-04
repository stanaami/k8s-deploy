#!/bin/bash

echo "🔍 Port.ioへのPod同期状況を確認します..."
echo ""

# クラスター内のPodを確認
echo "📦 クラスター内のPod:"
kubectl get pods --all-namespaces | grep -v "kube-system\|port-k8s-exporter\|local-path"
echo ""

# Port.ioエージェントの状態を確認
echo "🤖 Port.ioエージェントの状態:"
kubectl get pods -n port-k8s-exporter
echo ""

# エージェントのログを確認（最近の同期情報）
echo "📋 エージェントのログ（最近の同期情報）:"
kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=k8s-testing --tail=50 | grep -E "pod|sync|entity" | tail -20
echo ""

echo "💡 Port.ioダッシュボードでの確認:"
echo "  - Port.ioエージェントは60秒ごとにポーリングします"
echo "  - Podが作成されてから最大60秒待つ必要があります"
echo "  - Port.ioダッシュボードをリフレッシュしてください"
echo ""
echo "🔧 手動で同期をトリガーする場合:"
echo "  - Port.ioエージェントのPodを再起動:"
echo "    kubectl rollout restart deployment/k8s-testing-port-k8s-exporter -n port-k8s-exporter"
