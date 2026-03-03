#!/bin/bash

set -e

CLUSTER_NAME="k8s-testing"
CONFIG_FILE="kind-config.yaml"

echo "🚀 Kubernetes検証環境のセットアップを開始します..."

# kindがインストールされているか確認
if ! command -v kind &> /dev/null; then
    echo "❌ kindがインストールされていません"
    echo "以下のコマンドでインストールしてください:"
    echo "  brew install kind"
    exit 1
fi

# Dockerがインストールされているか確認
if ! command -v docker &> /dev/null; then
    echo "❌ Dockerがインストールされていません"
    echo "以下のコマンドでDocker Desktopをインストールしてください:"
    echo "  brew install --cask docker"
    echo ""
    echo "インストール後、Docker Desktopを起動してから再度実行してください"
    exit 1
fi

# Dockerが起動しているか確認
if ! docker info &> /dev/null; then
    echo "❌ Dockerが起動していません"
    echo "Docker Desktopを起動してください"
    echo ""
    echo "起動方法:"
    echo "  - アプリケーションフォルダから「Docker」を起動"
    echo "  - または: open -a Docker"
    exit 1
fi

# 既存のクラスターがあるか確認
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "⚠️  クラスター '${CLUSTER_NAME}' は既に存在します"
    read -p "削除して再作成しますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  既存のクラスターを削除しています..."
        kind delete cluster --name ${CLUSTER_NAME}
    else
        echo "セットアップを中止しました"
        exit 0
    fi
fi

# クラスターの作成
echo "📦 クラスターを作成しています..."
kind create cluster --name ${CLUSTER_NAME} --config ${CONFIG_FILE}

# kubectlの設定確認
echo "✅ クラスターが作成されました"
echo ""
echo "📋 クラスター情報:"
kubectl cluster-info --context kind-${CLUSTER_NAME}
echo ""
echo "📊 ノード一覧:"
kubectl get nodes
echo ""
echo "✨ セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "  - サンプルアプリケーションをデプロイ: kubectl apply -f examples/nginx-deployment.yaml"
echo "  - Podの確認: kubectl get pods"
echo "  - クラスターの削除: kind delete cluster --name ${CLUSTER_NAME}"
