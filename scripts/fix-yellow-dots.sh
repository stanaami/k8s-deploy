#!/bin/bash

set -e

CLUSTER_NAME="test-cluster"

echo "🔧 Port.ioの黄色ドット（警告状態）を修正します..."
echo "クラスター名: $CLUSTER_NAME"
echo ""

echo "📊 現在のエージェントの状態:"
kubectl get pods -n port-k8s-exporter
echo ""

echo "📋 エージェントのログからエラーを確認します..."
ERRORS=$(kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=$CLUSTER_NAME --tail=100 | grep -iE "error|failed|not found|does not exist|blueprint|namespace|workload" | tail -20 || echo "")

if [ -z "$ERRORS" ]; then
    echo "✅ エラーは見つかりませんでした"
else
    echo "⚠️  以下のエラーが見つかりました:"
    echo "$ERRORS"
    echo ""
fi

echo ""
echo "🔍 問題の分析:"
echo ""
echo "Port.ioダッシュボードで以下のエンティティが黄色のドットで表示されています:"
echo "  ⚠️  K8s Namespace"
echo "  ⚠️  K8s Workload"
echo "  ⚠️  K8s Pod"
echo ""
echo "これは、これらのエンティティが正しく同期されていないことを示しています。"
echo ""

echo "💡 原因:"
echo "  1. 親エンティティ（k8s_namespace）が同期されていない"
echo "  2. そのため、子エンティティ（k8s_workload、k8s_pod）も同期できない"
echo "  3. Kubernetesの階層構造により、親が存在しないと子は作成できない"
echo ""

echo "🔧 解決手順:"
echo ""
echo "1️⃣  エージェントを再起動して再同期を試みます..."
read -p "エージェントを再起動しますか？ (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 エージェントを再起動しています..."
    kubectl rollout restart deployment/$CLUSTER_NAME-port-k8s-exporter -n port-k8s-exporter
    
    echo ""
    echo "⏳ エージェントが再起動するまで15秒待機します..."
    sleep 15
    
    echo ""
    echo "📊 エージェントの状態を確認します..."
    kubectl get pods -n port-k8s-exporter
    
    echo ""
    echo "📋 エージェントのログを確認します（最初の50行）..."
    sleep 5
    kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=$CLUSTER_NAME --tail=50 | head -30
    
    echo ""
    echo "✅ 再起動が完了しました"
    echo ""
    echo "📝 次のステップ:"
    echo "  1. Port.ioダッシュボードをリフレッシュしてください"
    echo "  2. Data sourcesセクションで、黄色のドットが緑色に変わるか確認してください"
    echo "  3. Catalogセクションで、NamespaceやPodが表示されるか確認してください"
    echo ""
    echo "  もし問題が続く場合:"
    echo "  - Port.ioダッシュボードでブループリントのRelations設定を確認"
    echo "  - エージェントのログを継続的に監視:"
    echo "    kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=$CLUSTER_NAME --tail=50 -f"
else
    echo ""
    echo "ℹ️  エージェントの再起動をスキップしました"
    echo ""
    echo "手動で再起動する場合:"
    echo "  kubectl rollout restart deployment/$CLUSTER_NAME-port-k8s-exporter -n port-k8s-exporter"
fi
