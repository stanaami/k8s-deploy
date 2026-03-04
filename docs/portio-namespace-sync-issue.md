# Port.io Namespace同期の問題と解決方法

## 問題の症状

- Port.ioダッシュボードで「K8s Namespaces」が空（0 results）
- PodやDeploymentがPort.ioに表示されない
- エラーログ: `Entity with identifier "default-k8s-testing" does not exist in the blueprint "k8s_namespace"`

## 原因

Port.ioエージェントがnamespaceを同期していないため、その配下のリソース（Deployment、Podなど）も同期できません。

Port.ioのエンティティ階層：
```
k8s_cluster
  └── k8s_namespace
      └── k8s_workload (Deployment)
          └── k8s_replicaSet
              └── k8s_pod
```

親エンティティが存在しないと、子エンティティは作成できません。

## 解決方法

### 方法1: Port.ioダッシュボードで統合設定を確認

1. **Port.ioダッシュボードにアクセス**
   - https://app.port.io にログイン

2. **統合設定を確認**
   - Settings > Integrations > Kubernetes
   - 「K8s Namespaces」ブループリントが有効になっているか確認
   - Namespaceの同期が有効になっているか確認

3. **ブループリントの確認**
   - Builder > Blueprints
   - `k8s_namespace` ブループリントが存在するか確認
   - 存在しない場合は作成する必要があります

### 方法2: Port.ioエージェントの設定を確認

現在のエージェント設定では、namespaceの同期が有効になっていない可能性があります。

**Helmチャートの設定を確認:**

```bash
helm get values k8s-testing -n port-k8s-exporter
```

**必要に応じて、namespace同期を有効にする設定を追加:**

```bash
helm upgrade k8s-testing port-labs/port-k8s-exporter \
  -n port-k8s-exporter \
  --reuse-values \
  --set resourcesToSync.namespaces=true
```

### 方法3: Port.ioのブループリントを手動で作成

Port.ioダッシュボードで：

1. **Builder** > **Blueprints** に移動
2. **+ Blueprint** をクリック
3. 以下のブループリントを作成：
   - `k8s_namespace` - Namespace用
   - `k8s_workload` - Deployment/StatefulSet用
   - `k8s_replicaSet` - ReplicaSet用
   - `k8s_pod` - Pod用

4. 各ブループリント間の関係（Relations）を設定：
   - `k8s_namespace` → `k8s_workload`
   - `k8s_workload` → `k8s_replicaSet`
   - `k8s_replicaSet` → `k8s_pod`

### 方法4: Port.ioの統合テンプレートを使用

Port.ioが提供するKubernetes統合テンプレートを使用する場合：

1. Port.ioダッシュボードで **Settings** > **Integrations** > **Kubernetes**
2. 「Set up integration」または「Configure」をクリック
3. 統合テンプレートを適用（すべてのブループリントが自動的に作成されます）

## 確認方法

### エージェントのログを確認

```bash
# namespace同期に関するログを確認
kubectl logs -n port-k8s-exporter \
  -l app.kubernetes.io/instance=k8s-testing \
  --tail=100 | grep -i "namespace\|sync"
```

### Port.ioダッシュボードで確認

1. 「K8s Namespaces」テーブルを確認
2. `default`、`kube-system`、`port-k8s-exporter` などのnamespaceが表示されるか確認
3. Namespaceが表示されれば、その配下のリソースも同期されます

## トラブルシューティング

### エージェントを再起動

```bash
kubectl rollout restart deployment/k8s-testing-port-k8s-exporter -n port-k8s-exporter
```

### エージェントの設定を再確認

```bash
# 現在の設定を確認
helm get values k8s-testing -n port-k8s-exporter

# すべての設定を確認（デフォルト値含む）
helm get values k8s-testing -n port-k8s-exporter --all
```

### Port.ioのAPIで確認

Port.ioのAPIを使用して、namespaceエンティティが存在するか確認できます。

## 参考リンク

- [Port.io Kubernetes統合ドキュメント](https://docs.port.io/integrations/kubernetes)
- [Port.io Blueprints](https://docs.port.io/build-your-software-catalog/define-your-data-model/setup-blueprint)
