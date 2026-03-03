#!/bin/bash

set -e

CLUSTER_NAME="k8s-testing"

echo "🧹 Kubernetes検証環境のクリーンアップを開始します..."

# クラスターが存在するか確認
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "ℹ️  クラスター '${CLUSTER_NAME}' は存在しません"
    exit 0
fi

# 確認
read -p "クラスター '${CLUSTER_NAME}' を削除しますか？ (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "クリーンアップを中止しました"
    exit 0
fi

# クラスターの削除
echo "🗑️  クラスターを削除しています..."
kind delete cluster --name ${CLUSTER_NAME}

echo "✅ クリーンアップが完了しました"
