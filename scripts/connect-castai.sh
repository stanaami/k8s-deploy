#!/bin/bash

set -e

echo "🔗 CAST AIへの接続を開始します..."
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

# Helmがインストールされているか確認
if ! command -v helm &> /dev/null; then
    echo "❌ Helmがインストールされていません"
    echo ""
    echo "Helmをインストールしてください:"
    echo "  brew install helm"
    exit 1
fi

echo "✅ Helmがインストールされています"
echo ""

# CAST AI APIトークンの確認
if [ -z "$CASTAI_API_TOKEN" ]; then
    echo "⚠️  環境変数 CASTAI_API_TOKEN が設定されていません"
    echo ""
    echo "CAST AI APIトークンを設定してください:"
    echo "  1. CAST AIダッシュボードにログイン: https://console.cast.ai"
    echo "  2. Settings > API Tokens に移動"
    echo "  3. 新しいトークンを作成または既存のトークンをコピー"
    echo ""
    echo "その後、以下のコマンドでトークンを設定:"
    echo "  export CASTAI_API_TOKEN='your-token-here'"
    echo "  ./scripts/connect-castai.sh"
    echo ""
    read -p "CAST AI APIトークンを入力してください: " CASTAI_API_TOKEN
    if [ -z "$CASTAI_API_TOKEN" ]; then
        echo "❌ トークンが入力されませんでした"
        exit 1
    fi
    export CASTAI_API_TOKEN
fi

echo "✅ CAST AI APIトークンが設定されています"
echo ""

# クラスター名を取得
CLUSTER_NAME=$(kubectl config current-context | sed 's/.*kind-//' || echo "k8s-testing")
echo "📦 クラスター名: $CLUSTER_NAME"
echo ""

# CAST AIの公式オンボーディングスクリプトを使用するか確認
USE_OFFICIAL_SCRIPT=${USE_CASTAI_OFFICIAL_SCRIPT:-"false"}

if [ "$USE_CASTAI_OFFICIAL_SCRIPT" = "true" ] || [ -n "$CASTAI_ORGANIZATION_ID" ]; then
    echo "📦 CAST AIの公式オンボーディングスクリプトを使用します..."
    echo ""
    
    # 必要な環境変数が設定されているか確認
    if [ -z "$CASTAI_ORGANIZATION_ID" ]; then
        echo "⚠️  CASTAI_ORGANIZATION_ID が設定されていません"
        echo "CAST AIダッシュボードから提供される完全なコマンドを使用してください"
        exit 1
    fi
    
    # 環境変数を設定してからスクリプトを実行
    export CASTAI_API_TOKEN
    export CASTAI_API_URL=${CASTAI_API_URL:-"https://api.cast.ai"}
    export CASTAI_ORGANIZATION_ID
    export CLUSTER_NAME=${CLUSTER_NAME:-"kind-cluster"}
    
    echo "環境変数を設定しました:"
    echo "  CASTAI_API_TOKEN: ${CASTAI_API_TOKEN:0:20}..."
    echo "  CASTAI_API_URL: $CASTAI_API_URL"
    echo "  CASTAI_ORGANIZATION_ID: $CASTAI_ORGANIZATION_ID"
    echo "  CLUSTER_NAME: $CLUSTER_NAME"
    echo ""
    
    # 公式オンボーディングスクリプトを実行
    /bin/bash -c "$(curl -fsSL 'https://api.cast.ai/v1/scripts/anywhere/onboarding.sh')"
else
    # 従来のHelmチャートを使用する方法
    echo "➕ CAST AI Helmリポジトリを追加しています..."
    helm repo add castai-helm https://castai.github.io/castai-helm-charts 2>/dev/null || {
        echo "⚠️  リポジトリは既に追加されています。更新します..."
    }
    helm repo update

    echo ""
    echo "📦 CAST AIエージェントをインストールしています..."
    echo ""

    # CAST AIエージェントをインストール
    helm upgrade --install castai-agent castai-helm/castai-agent \
      --namespace castai-system \
      --create-namespace \
      --set castai.apiToken="${CASTAI_API_TOKEN}" \
      --set castai.clusterID="${CLUSTER_NAME}" \
      --wait --timeout=5m
fi

echo ""
echo "✅ CAST AIエージェントのインストールが完了しました！"
echo ""

# エージェントの状態を確認
echo "📊 エージェントの状態を確認しています..."
sleep 5
kubectl get pods -n castai-system

echo ""
echo "📋 エージェントのログを確認しています..."
kubectl logs -n castai-system -l app=castai-agent --tail=20 || echo "ログを取得できませんでした（起動中かもしれません）"

echo ""
echo "🎉 セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "  1. CAST AIダッシュボードにアクセス: https://console.cast.ai"
echo "  2. クラスターが「Connected」状態になるまで数分待つ"
echo "  3. クラスターのリソース使用状況や推奨事項を確認"
echo ""
echo "エージェントの状態を確認する場合:"
echo "  kubectl get pods -n castai-system"
echo "  kubectl logs -n castai-system -l app=castai-agent --tail=50 -f"
echo ""
