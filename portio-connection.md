# Port.ioへの接続手順

このドキュメントでは、kindクラスターをPort.io環境に接続する手順を説明します。

## 前提条件

- kindクラスターが起動していること
- kubectlがクラスターに接続できること
- Port.ioアカウントを持っていること

## 接続方法

### 方法1: Port.ioダッシュボードから接続（推奨）

1. **Port.ioダッシュボードにログイン**
   - https://app.port.io にアクセス
   - アカウントにログイン

2. **クラスター登録**
   - ダッシュボードで「Settings」→「Clusters」に移動
   - 「Add Cluster」または「Connect Cluster」をクリック

3. **接続トークンの取得**
   - クラスター名を入力（例: `k8s-testing`）
   - 表示された接続トークンまたはマニフェストをコピー

4. **エージェントのデプロイ**
   
   **オプションA: マニフェストを使用する場合**
   ```bash
   # Port.ioから提供されたマニフェストを保存
   # portio-agent.yaml として保存した場合
   kubectl apply -f portio-agent.yaml
   ```

   **オプションB: Helmを使用する場合（推奨）**
   ```bash
   # Helmがインストールされていることを確認
   helm version
   
   # スクリプトを使用してインストール（推奨）
   ./scripts/install-portio-agent.sh
   
   # または、手動でHelmコマンドを実行
   helm repo add --force-update port-labs https://port-labs.github.io/helm-charts
   helm repo update
   helm upgrade --install k8s-testing port-labs/port-k8s-exporter \
     --create-namespace \
     --namespace port-k8s-exporter \
     --set secret.secrets.portClientId="YOUR_CLIENT_ID" \
     --set secret.secrets.portClientSecret="YOUR_CLIENT_SECRET" \
     --set portBaseUrl="https://api.port.io" \
     --set stateKey="k8s-testing" \
     --set eventListener.type="POLLING" \
     --set "extraEnv[0].name"="CLUSTER_NAME" \
     --set "extraEnv[0].value"="k8s-testing"
   ```

5. **接続の確認**
   - Port.ioダッシュボードでクラスターの状態を確認
   - 数分待つと、クラスターが「Connected」状態になります

### 方法2: Port.io CLIを使用

1. **Port.io CLIのインストール**
   ```bash
   # macOSの場合
   brew install portio/tap/portio
   
   # または公式サイトからダウンロード
   # https://docs.port.io/cli/installation
   ```

2. **認証**
   ```bash
   portio auth login
   ```

3. **クラスターの接続**
   ```bash
   portio cluster connect \
     --name k8s-testing \
     --context kind-k8s-testing
   ```

### 方法3: スクリプトを使用（推奨）

```bash
# Helmがインストールされていることを確認
helm version

# スクリプトを実行（Port.ioから取得したClient IDとSecretを使用）
./scripts/install-portio-agent.sh
```

**環境変数で認証情報を指定する場合:**

```bash
export PORT_CLIENT_ID="your-client-id"
export PORT_CLIENT_SECRET="your-client-secret"
export CLUSTER_NAME="k8s-testing"

./scripts/install-portio-agent.sh
```

## 接続後の確認

### クラスターの状態確認

```bash
# Port.ioエージェントのPodを確認
kubectl get pods -n port-k8s-exporter

# エージェントのログを確認
kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter

# すべてのリソースを確認
kubectl get all -n port-k8s-exporter
```

### Port.ioダッシュボードでの確認

- Port.ioダッシュボードで「Clusters」セクションを確認
- クラスター名 `k8s-testing` が表示され、「Connected」状態になっていることを確認
- クラスターのリソース（ノード、Pod、サービスなど）が表示されることを確認

## トラブルシューティング

### エージェントが起動しない場合

```bash
# エージェントのPodの状態を確認
kubectl describe pod -n portio-agent -l app=portio-agent

# イベントを確認
kubectl get events -n portio-agent --sort-by='.lastTimestamp'
```

### 接続が確立されない場合

1. **ネットワーク接続の確認**
   ```bash
   # Port.ioのAPIエンドポイントに接続できるか確認
   curl -I https://api.port.io
   ```

2. **トークンの有効性確認**
   - Port.ioダッシュボードでトークンが有効か確認
   - トークンの有効期限を確認

3. **ファイアウォール設定**
   - kindクラスターからPort.ioのAPIエンドポイントへのアウトバウンド接続が許可されているか確認

### エージェントの再デプロイ

```bash
# Helmでアンインストール
helm uninstall k8s-testing -n port-k8s-exporter

# 再度インストール
./scripts/install-portio-agent.sh
```

### 重複したクラスターエンティティの削除

同じクラスターに対して複数回インストールした場合、Port.ioダッシュボードに重複したクラスターが表示されることがあります。

**Port.ioダッシュボードから削除:**
1. Port.ioダッシュボードにアクセス
2. 「K8s Clusters」テーブルで不要なクラスター（例: `my-cluster`）を選択
3. 削除ボタンをクリックして削除

**Kubernetesリソースの確認:**
```bash
# 現在のHelmリリースを確認
helm list -n port-k8s-exporter

# 残存リソースを確認
kubectl get all -n port-k8s-exporter

# 不要なHelmリリースを削除
helm uninstall <release-name> -n port-k8s-exporter
```

### Helmがインストールされていない場合

```bash
# macOSの場合
brew install helm

# または、公式インストールスクリプト
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### NamespaceやPodがPort.ioに表示されない場合

Port.ioダッシュボードで「K8s Namespaces」や「K8s Pods」が表示されない、または黄色の警告ドットが表示される場合、以下の手順で解決してください：

**問題の原因:**
- Port.ioのブループリント設定で`k8s_namespace`、`k8s_workload`、`k8s_pod`が存在しない、または正しく設定されていない
- Namespaceが同期されていないため、その配下のリソース（Deployment、Pod）も同期できない
- エージェントのログに「Entity with identifier ... does not exist in the blueprint」というエラーが表示される

**診断手順:**

1. **診断スクリプトを実行**
   ```bash
   ./scripts/diagnose-portio-sync.sh
   ```
   このスクリプトは以下を確認します：
   - エージェントの状態
   - エラーログ
   - クラスター内のリソース
   - エージェントの設定

2. **エージェントのログを直接確認**
   ```bash
   # エージェントのログを確認（test-clusterの場合）
   kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=test-cluster --tail=100
   
   # エラーのみを確認
   kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=test-cluster --tail=100 | grep -iE "error|failed|not found|does not exist|blueprint"
   ```

**解決方法:**

1. **Port.ioダッシュボードでブループリントを確認**
   - URL: https://app.port.io/builder/blueprints
   - または、左上の「Port」ロゴの横のドロップダウンから「Builder」→「Blueprints」を選択
   - 以下のブループリントが存在するか確認：
     - `k8s_namespace`
     - `k8s_workload`
     - `k8s_pod`
     - `k8s_cluster`
     - `k8s_replicaset`
     - `k8s_node`

2. **Kubernetes統合テンプレートを適用（推奨）**
   - URL: https://app.port.io/settings/integrations/kubernetes
   - または、右上の歯車アイコン「Builder」→「Settings」→「Integrations」→「Kubernetes」
   - 「Set up integration」または「Configure」をクリック
   - Kubernetes統合テンプレートを適用（すべてのブループリントが自動的に作成されます）
   - これにより、必要なブループリントとマッピングが自動的に設定されます

3. **エージェントを再起動して再同期**
   ```bash
   # test-clusterの場合
   kubectl rollout restart deployment/test-cluster-port-k8s-exporter -n port-k8s-exporter
   
   # または、Helmでアップグレード
   helm upgrade test-cluster port-labs/port-k8s-exporter \
     --namespace port-k8s-exporter \
     --reuse-values
   ```

4. **再起動後、ログを監視**
   ```bash
   # リアルタイムでログを確認
   kubectl logs -n port-k8s-exporter -l app.kubernetes.io/name=port-k8s-exporter,app.kubernetes.io/instance=test-cluster --tail=50 -f
   ```
   - エラーが解消され、正常に同期されていることを確認
   - 「Synced」や「upserted」などの成功メッセージが表示されることを確認

5. **Port.ioダッシュボードで確認**
   - Data sources セクションで「Kubernetes - test-cluster」を確認
   - 各エンティティタイプ（K8s Namespace、K8s Podなど）のドットが緑色になることを確認
   - Catalog セクションで実際のリソースが表示されることを確認

**注意事項:**
- エージェントは60秒ごとにポーリングします
- 変更後、最大60秒待つ必要があります
- Port.ioダッシュボードをリフレッシュしてください

詳細は `docs/portio-namespace-sync-issue.md` を参照してください。

## 参考リンク

- [Port.io公式ドキュメント](https://docs.port.io/)
- [Port.ioクラスター接続ガイド](https://docs.port.io/cluster-connection)
- [Port.io CLIドキュメント](https://docs.port.io/cli)
