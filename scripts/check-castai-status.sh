#!/bin/bash

echo "🔍 CAST AIの接続状態を確認します..."
echo ""

# CAST AIエージェントのPodを確認
echo "📊 CAST AIエージェントのPod状態:"
kubectl get pods -n castai-agent 2>/dev/null || kubectl get pods -n castai-system 2>/dev/null || echo "CAST AIエージェントのNamespaceが見つかりません"

echo ""

# ConfigMapからクラスターIDを確認
echo "📋 CAST AIエージェントの設定:"
kubectl get configmap -n castai-agent castai-agent-metadata -o yaml 2>/dev/null | grep -E "clusterId|cluster-id|CLUSTER_ID" || {
    echo "ConfigMapが見つかりません。別のNamespaceを確認します..."
    kubectl get configmap -n castai-system -l app=castai-agent -o yaml 2>/dev/null | grep -E "clusterId|cluster-id|CLUSTER_ID" || echo "ConfigMapが見つかりませんでした"
}

echo ""

# エージェントのログを確認
echo "📋 CAST AIエージェントのログ（最近の20行）:"
kubectl logs -n castai-agent -l app=castai-agent --tail=20 2>/dev/null || {
    kubectl logs -n castai-system -l app=castai-agent --tail=20 2>/dev/null || echo "ログを取得できませんでした"
}

echo ""

# Helmリリースを確認
echo "📦 Helmリリース:"
helm list -n castai-agent 2>/dev/null || helm list -n castai-system 2>/dev/null || echo "Helmリリースが見つかりません"

echo ""

# metrics-serverの状態を確認
echo "📊 Metrics Serverの状態:"
kubectl get deployment metrics-server -n kube-system 2>/dev/null || echo "Metrics Serverが見つかりません"

echo ""

echo "💡 確認ポイント:"
echo "  1. CAST AIエージェントのPodがRunning状態であること"
echo "  2. エージェントのログにエラーがないこと"
echo "  3. CAST AIダッシュボードでクラスターが表示されること"
echo ""
echo "CAST AIダッシュボード: https://console.cast.ai"
echo ""
