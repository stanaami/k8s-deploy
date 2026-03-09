#!/bin/bash

set -e

echo "🔗 CAST AIへの接続を開始します（公式オンボーディングスクリプト使用）..."
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

# 必要な環境変数の確認
if [ -z "$CASTAI_API_TOKEN" ]; then
    echo "❌ CASTAI_API_TOKEN が設定されていません"
    echo ""
    echo "CAST AIダッシュボードから提供される完全なコマンドを使用してください"
    exit 1
fi

if [ -z "$CASTAI_ORGANIZATION_ID" ]; then
    echo "❌ CASTAI_ORGANIZATION_ID が設定されていません"
    echo ""
    echo "CAST AIダッシュボードから提供される完全なコマンドを使用してください"
    exit 1
fi

# 環境変数を設定
export CASTAI_API_TOKEN
export CASTAI_API_URL=${CASTAI_API_URL:-"https://api.cast.ai"}
export CASTAI_ORGANIZATION_ID
export CLUSTER_NAME=${CLUSTER_NAME:-"kind-cluster"}

echo "📋 設定された環境変数:"
echo "  CASTAI_API_TOKEN: ${CASTAI_API_TOKEN:0:20}..."
echo "  CASTAI_API_URL: $CASTAI_API_URL"
echo "  CASTAI_ORGANIZATION_ID: $CASTAI_ORGANIZATION_ID"
echo "  CLUSTER_NAME: $CLUSTER_NAME"
echo ""

# その他の環境変数が設定されている場合は使用
if [ -n "$CREDENTIALS_SCRIPT_API_TOKEN" ]; then
    export CREDENTIALS_SCRIPT_API_TOKEN
fi

if [ -n "$WORKLOAD_AUTOSCALER_EXPORTER_TELEMETRY_URL" ]; then
    export WORKLOAD_AUTOSCALER_EXPORTER_TELEMETRY_URL
fi

echo "🚀 CAST AIの公式オンボーディングスクリプトを実行します..."
echo ""

# 公式オンボーディングスクリプトを実行
/bin/bash -c "$(curl -fsSL 'https://api.cast.ai/v1/scripts/anywhere/onboarding.sh')"

echo ""
echo "✅ セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "  1. CAST AIダッシュボードにアクセス: https://console.cast.ai"
echo "  2. クラスターが「Connected」状態になるまで数分待つ"
echo "  3. クラスターのリソース使用状況や推奨事項を確認"
echo ""
