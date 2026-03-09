#!/bin/bash

set -e

echo "🛑 kindクラスターを停止します（削除しません）..."
echo ""

# kindクラスターの名前を取得
CLUSTER_NAME=$(kind get clusters 2>/dev/null | head -n 1)

if [ -z "$CLUSTER_NAME" ]; then
    echo "⚠️  実行中のkindクラスターが見つかりません"
    exit 0
fi

echo "📦 クラスター名: $CLUSTER_NAME"
echo ""

# クラスターのノードコンテナを確認
echo "🔍 クラスターのノードコンテナを確認しています..."
NODES=$(docker ps --filter "name=${CLUSTER_NAME}" --format "{{.Names}}")

if [ -z "$NODES" ]; then
    echo "ℹ️  クラスターは既に停止しているようです"
    exit 0
fi

echo "実行中のノードコンテナ:"
echo "$NODES"
echo ""

# 確認
read -p "これらのコンテナを停止しますか？ (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 停止をキャンセルしました"
    exit 0
fi

echo ""
echo "🛑 ノードコンテナを停止しています..."

# 各ノードコンテナを停止
for NODE in $NODES; do
    echo "  停止中: $NODE"
    docker stop "$NODE" 2>/dev/null || echo "    ⚠️  $NODE の停止に失敗しました"
done

echo ""
echo "✅ クラスターを停止しました"
echo ""
echo "📋 停止されたコンテナ:"
docker ps -a --filter "name=${CLUSTER_NAME}" --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "💡 クラスターを再起動する場合:"
echo "  docker start \$(docker ps -a --filter \"name=${CLUSTER_NAME}\" --format \"{{.Names}}\")"
echo ""
echo "または、kindコマンドを使用:"
echo "  kind get clusters  # クラスター一覧を確認"
echo "  kubectl cluster-info --context kind-${CLUSTER_NAME}  # 接続確認"
echo ""
