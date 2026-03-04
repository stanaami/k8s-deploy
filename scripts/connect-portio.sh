#!/bin/bash

set -e

echo "🔗 Port.ioへの接続を開始します..."
echo ""

# kubectlが利用可能か確認
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectlがインストールされていません"
    exit 1
fi

# クラスターに接続できるか確認
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetesクラスターに接続できません"
    echo "kindクラスターが起動しているか確認してください:"
    echo "  kubectl cluster-info"
    exit 1
fi

echo "✅ Kubernetesクラスターに接続できました"
echo ""

# Port.ioトークンの確認
if [ -z "$PORTIO_TOKEN" ]; then
    echo "⚠️  環境変数 PORTIO_TOKEN が設定されていません"
    echo ""
    echo "Port.ioトークンを設定してください:"
    echo "  1. Port.ioダッシュボードにログイン"
    echo "  2. Settings > Clusters に移動"
    echo "  3. 「Add Cluster」をクリック"
    echo "  4. 表示されたトークンをコピー"
    echo ""
    echo "その後、以下のコマンドでトークンを設定:"
    echo "  export PORTIO_TOKEN='your-token-here'"
    echo "  ./scripts/connect-portio.sh"
    echo ""
    read -p "Port.ioトークンを入力してください: " PORTIO_TOKEN
    if [ -z "$PORTIO_TOKEN" ]; then
        echo "❌ トークンが入力されませんでした"
        exit 1
    fi
fi

echo "📦 Port.ioエージェントをデプロイしています..."
echo ""

# Port.ioエージェントのデプロイ
# 注意: 実際のPort.ioエージェントマニフェストはPort.ioダッシュボードから取得してください
kubectl create namespace portio-agent --dry-run=client -o yaml | kubectl apply -f -

echo "ℹ️  Port.ioエージェントのマニフェストを適用する必要があります"
echo ""
echo "次のステップ:"
echo "1. Port.ioダッシュボードでクラスター登録用のマニフェストを取得"
echo "2. 以下のコマンドでマニフェストを適用:"
echo "   kubectl apply -f portio-agent-manifest.yaml"
echo ""
echo "または、Port.io CLIを使用する場合:"
echo "   portio cluster connect --token $PORTIO_TOKEN"
echo ""
