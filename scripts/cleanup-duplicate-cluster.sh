#!/bin/bash

set -e

echo "🧹 重複したクラスターエンティティをクリーンアップします..."
echo ""

# 現在のHelmリリースを確認
echo "📦 現在のHelmリリース:"
helm list -n port-k8s-exporter
echo ""

# k8s-testingエージェントの状態を確認
echo "✅ k8s-testingエージェントの状態:"
kubectl get pods -n port-k8s-exporter -l app.kubernetes.io/instance=k8s-testing
echo ""

# my-clusterに関連する残存リソースを確認
echo "🔍 my-clusterに関連する残存リソースを確認:"
kubectl get all -n port-k8s-exporter | grep my-cluster || echo "残存リソースなし"
echo ""

echo "📋 クリーンアップ手順:"
echo ""
echo "1. Port.ioダッシュボードで 'my-cluster' エンティティを削除:"
echo "   - Port.ioダッシュボードにアクセス"
echo "   - 'K8s Clusters' テーブルで 'my-cluster' を選択"
echo "   - 削除ボタンをクリックして削除"
echo ""
echo "2. または、Port.io APIを使用して削除:"
echo "   - Port.ioのAPIトークンを使用"
echo "   - DELETE /v1/entities/{entity_id} を実行"
echo ""
echo "3. 残存リソースがある場合:"
echo "   kubectl delete all -n port-k8s-exporter -l app.kubernetes.io/instance=my-cluster"
echo ""
