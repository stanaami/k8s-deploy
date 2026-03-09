#!/bin/bash

set -e

echo "▶️  kindクラスターを起動します..."
echo ""

# kindクラスターの名前を取得
CLUSTER_NAME=$(kind get clusters 2>/dev/null | head -n 1)

if [ -z "$CLUSTER_NAME" ]; then
    echo "⚠️  kindクラスターが見つかりません"
    echo ""
    echo "クラスターを作成する場合:"
    echo "  kind create cluster --name k8s-testing --config kind-config.yaml"
    exit 1
fi

echo "📦 クラスター名: $CLUSTER_NAME"
echo ""

# 停止されているノードコンテナを確認
echo "🔍 停止されているノードコンテナを確認しています..."
STOPPED_NODES=$(docker ps -a --filter "name=${CLUSTER_NAME}" --filter "status=exited" --format "{{.Names}}")

if [ -z "$STOPPED_NODES" ]; then
    echo "ℹ️  停止されているコンテナが見つかりません"
    echo "クラスターは既に実行中かもしれません"
    echo ""
    echo "クラスターの状態を確認:"
    kubectl cluster-info --context kind-${CLUSTER_NAME} 2>/dev/null || echo "クラスターに接続できません"
    exit 0
fi

echo "停止されているノードコンテナ:"
echo "$STOPPED_NODES"
echo ""

# 各ノードコンテナを起動
echo "▶️  ノードコンテナを起動しています..."

for NODE in $STOPPED_NODES; do
    echo "  起動中: $NODE"
    docker start "$NODE" 2>/dev/null || echo "    ⚠️  $NODE の起動に失敗しました"
done

echo ""
echo "⏳ クラスターが起動するまで10秒待機します..."
sleep 10

echo ""
echo "✅ クラスターを起動しました"
echo ""

# クラスターの状態を確認
echo "📋 クラスターの状態を確認しています..."
kubectl cluster-info --context kind-${CLUSTER_NAME} 2>/dev/null && {
    echo ""
    echo "📊 ノードの状態:"
    kubectl get nodes
    echo ""
    echo "✅ クラスターは正常に動作しています"
} || {
    echo "⚠️  クラスターに接続できません。もう少し待ってから再試行してください"
}

echo ""
