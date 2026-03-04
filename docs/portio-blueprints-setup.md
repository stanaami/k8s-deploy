# Port.io Kubernetesブループリントの設定手順

## 現在の状況

Port.ioダッシュボードで「K8s Namespace」ブループリントは存在していますが、他の必要なブループリントが不足している可能性があります。

エラーログから、以下のブループリントが必要です：
- `k8s_cluster` ✅ (存在する可能性が高い)
- `k8s_namespace` ✅ (存在確認済み)
- `k8s_workload` ❓ (確認が必要)
- `k8s_replicaSet` ❌ (エラーが発生)
- `k8s_pod` ❓ (確認が必要)

## 必要なブループリントの確認と作成

### ステップ1: 既存のブループリントを確認

1. Port.ioダッシュボードで **Builder** > **Blueprints** に移動
   - URL: https://app.port.io/builder/blueprints
   - または、右上の歯車アイコン「Builder」をクリック

2. 以下のブループリントが存在するか確認：
   - `k8s_cluster`
   - `k8s_namespace` ✅ (既に存在)
   - `k8s_workload`
   - `k8s_replicaSet`
   - `k8s_pod`
   - `k8s_node`

### ステップ2: 不足しているブループリントを作成

存在しないブループリントがある場合、以下の手順で作成します：

#### 2-1. `k8s_workload` ブループリントの作成

1. **Builder** > **Blueprints** で「**+ Blueprint**」をクリック
2. 以下の情報を入力：
   - **Identifier**: `k8s_workload`
   - **Title**: `K8s Workload`
   - **Icon**: Kubernetesアイコンを選択
3. **Properties**タブで以下のプロパティを追加：
   - `created` (Date-Time)
   - `labels` (JSON)
   - `name` (String)
   - `namespace` (String)
4. **Relations**タブで以下のリレーションを追加：
   - **Relation to**: `k8s_namespace`
   - **Relation identifier**: `namespace`
   - **Title**: `Namespace`
5. **Save**をクリック

#### 2-2. `k8s_replicaSet` ブループリントの作成

1. 「**+ Blueprint**」をクリック
2. 以下の情報を入力：
   - **Identifier**: `k8s_replicaSet`
   - **Title**: `K8s ReplicaSet`
   - **Icon**: Kubernetesアイコンを選択
3. **Properties**タブで以下のプロパティを追加：
   - `created` (Date-Time)
   - `labels` (JSON)
   - `name` (String)
   - `namespace` (String)
4. **Relations**タブで以下のリレーションを追加：
   - **Relation to**: `k8s_workload`
   - **Relation identifier**: `workload`
   - **Title**: `Workload`
5. **Save**をクリック

#### 2-3. `k8s_pod` ブループリントの作成

1. 「**+ Blueprint**」をクリック
2. 以下の情報を入力：
   - **Identifier**: `k8s_pod`
   - **Title**: `K8s Pod`
   - **Icon**: Kubernetesアイコンを選択
3. **Properties**タブで以下のプロパティを追加：
   - `created` (Date-Time)
   - `labels` (JSON)
   - `name` (String)
   - `namespace` (String)
   - `status` (String)
4. **Relations**タブで以下のリレーションを追加：
   - **Relation to**: `k8s_replicaSet`
   - **Relation identifier**: `replicaSet`
   - **Title**: `ReplicaSet`
5. **Save**をクリック

### ステップ3: リレーションの階層構造を確認

正しい階層構造は以下の通りです：

```
k8s_cluster
  └── k8s_namespace
      └── k8s_workload
          └── k8s_replicaSet
              └── k8s_pod
```

各ブループリントのRelationsタブで、親子関係が正しく設定されているか確認してください。

## クイックチェックリスト

- [ ] `k8s_cluster` ブループリントが存在する
- [ ] `k8s_namespace` ブループリントが存在する ✅
- [ ] `k8s_workload` ブループリントが存在する
- [ ] `k8s_replicaSet` ブループリントが存在する
- [ ] `k8s_pod` ブループリントが存在する
- [ ] `k8s_node` ブループリントが存在する
- [ ] 各ブループリント間のリレーションが正しく設定されている

## エージェントの再起動

すべてのブループリントを作成した後、エージェントを再起動して再同期します：

```bash
kubectl rollout restart deployment/test-cluster-port-k8s-exporter -n port-k8s-exporter
```

再起動後、ログを確認：

```bash
kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=test-cluster --tail=50 -f
```

エラーが解消され、正常に同期されていることを確認してください。

## 参考

- [Port.io Blueprints Documentation](https://docs.port.io/build-your-software-catalog/define-your-data-model/setup-blueprint)
- [Port.io Kubernetes Integration](https://docs.port.io/integrations/kubernetes)
