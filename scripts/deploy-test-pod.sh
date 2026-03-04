#!/bin/bash

set -e

echo "🚀 テストPodをデプロイします..."
echo ""

# kubectlが利用可能か確認
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectlがインストールされていません"
    exit 1
fi

# クラスターに接続できるか確認
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetesクラスターに接続できません"
    echo "kindクラスターが起動しているか確認してください"
    exit 1
fi

echo "✅ Kubernetesクラスターに接続できました"
echo ""

# テストPodをデプロイ
echo "📦 テストPodをデプロイしています..."
kubectl apply -f examples/test-pod.yaml

echo ""
echo "⏳ Podの起動を待機しています..."
kubectl wait --for=condition=Ready pod/test-pod --timeout=60s || {
    echo "⚠️  Podの起動に時間がかかっています。状態を確認してください:"
    kubectl get pod test-pod
    exit 1
}

echo ""
echo "✅ テストPodが正常にデプロイされました！"
echo ""
echo "📊 Podの状態:"
kubectl get pod test-pod
echo ""
echo "📋 Podの詳細情報:"
kubectl describe pod test-pod
echo ""
echo "💡 次のコマンドで確認できます:"
echo "  - Podのログ: kubectl logs test-pod"
echo "  - Podの状態: kubectl get pod test-pod"
echo "  - Podの削除: kubectl delete pod test-pod"
echo "  - ポートフォワーディング: kubectl port-forward test-pod 8080:80"
