#!/bin/bash

set -e

CLUSTER_NAME="${CLUSTER_NAME:-k8s-testing}"
PORT_CLIENT_ID="${PORT_CLIENT_ID:-7f6G1SyzxdpGC09ddwuBvQiYc0MIEnpu}"
PORT_CLIENT_SECRET="${PORT_CLIENT_SECRET:-uSmHEGFPYZPI8CN7ZA7dwTQsjsIv10kIwwLc0ddd8NKtXLRIozR0JN96cTmYrvYE}"

echo "🔗 Port.ioエージェントをインストールします..."
echo "クラスター名: $CLUSTER_NAME"
echo ""

# Helmがインストールされているか確認
if ! command -v helm &> /dev/null; then
    echo "❌ Helmがインストールされていません"
    echo ""
    echo "Helmをインストールしてください:"
    echo "  brew install helm"
    echo ""
    echo "または、公式サイトからインストール:"
    echo "  https://helm.sh/docs/intro/install/"
    exit 1
fi

# kubectlが利用可能か確認
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectlがインストールされていません"
    exit 1
fi

# クラスターに接続できるか確認
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetesクラスターに接続できません"
    exit 1
fi

echo "✅ 前提条件を確認しました"
echo ""

# Port.io Helmリポジトリを追加
echo "📦 Port.io Helmリポジトリを追加しています..."
helm repo add --force-update port-labs https://port-labs.github.io/helm-charts
helm repo update

# Port.ioエージェントをインストール
echo "🚀 Port.ioエージェントをインストールしています..."
helm upgrade --install $CLUSTER_NAME port-labs/port-k8s-exporter \
  --create-namespace \
  --namespace port-k8s-exporter \
  --set secret.secrets.portClientId="$PORT_CLIENT_ID" \
  --set secret.secrets.portClientSecret="$PORT_CLIENT_SECRET" \
  --set portBaseUrl="https://api.port.io" \
  --set stateKey="$CLUSTER_NAME" \
  --set eventListener.type="POLLING" \
  --set "extraEnv[0].name"="CLUSTER_NAME" \
  --set "extraEnv[0].value"="$CLUSTER_NAME"

echo ""
echo "✅ Port.ioエージェントのインストールが完了しました！"
echo ""
echo "📊 エージェントの状態を確認:"
echo "  kubectl get pods -n port-k8s-exporter"
echo ""
echo "📋 ログを確認:"
echo "  kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter"
echo ""
echo "🌐 Port.ioダッシュボードでクラスターの接続状態を確認してください"
