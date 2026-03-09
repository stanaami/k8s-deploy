# CAST AIへの接続手順

このドキュメントでは、kindクラスターをCAST AIに接続する手順を説明します。

## 前提条件

- kindクラスターが起動していること
- kubectlがクラスターに接続できること
- Helmがインストールされていること
- CAST AIアカウントを持っていること
- CAST AI APIトークン（`CASTAI_API_TOKEN`）を取得済みであること

## CAST AIとは

CAST AIは、Kubernetesクラスターの自動最適化とコスト削減を提供するサービスです。以下の機能があります：

- 自動スケーリング
- コスト最適化
- クラスターの監視と分析
- リソース推奨事項

## 接続方法

### 方法1: スクリプトを使用（推奨）

```bash
# 環境変数でAPIトークンを設定
export CASTAI_API_TOKEN="your-api-token-here"

# 接続スクリプトを実行
./scripts/connect-castai.sh
```

### 方法2: Helmを使用して手動インストール

1. **CAST AI Helmリポジトリを追加**

```bash
helm repo add castai-helm https://castai.github.io/castai-helm-charts
helm repo update
```

2. **CAST AIエージェントをインストール**

```bash
# APIトークンを環境変数として設定
export CASTAI_API_TOKEN="your-api-token-here"

# エージェントをインストール
helm upgrade --install castai-agent castai-helm/castai-agent \
  --namespace castai-system \
  --create-namespace \
  --set castai.apiToken="${CASTAI_API_TOKEN}" \
  --set castai.clusterID="kind-k8s-testing"
```

3. **接続の確認**

```bash
# エージェントのPodを確認
kubectl get pods -n castai-system

# エージェントのログを確認
kubectl logs -n castai-system -l app=castai-agent
```

### 方法3: CAST AIダッシュボードから接続

1. **CAST AIダッシュボードにログイン**
   - https://console.cast.ai にアクセス
   - アカウントにログイン

2. **クラスターを追加**
   - ダッシュボードで「Add Cluster」または「Connect Cluster」をクリック
   - クラスター名を入力（例: `kind-k8s-testing`）
   - 表示されたインストールコマンドをコピー

3. **インストールコマンドを実行**
   - コピーしたコマンドをターミナルで実行
   - 通常はHelmコマンドまたはkubectl applyコマンド

## 接続後の確認

### エージェントの状態確認

```bash
# CAST AIエージェントのPodを確認
kubectl get pods -n castai-system

# エージェントのログを確認
kubectl logs -n castai-system -l app=castai-agent --tail=50

# すべてのリソースを確認
kubectl get all -n castai-system
```

### CAST AIダッシュボードでの確認

- CAST AIダッシュボードでクラスターの状態を確認
- 数分待つと、クラスターが「Connected」状態になります
- クラスターのリソース使用状況や推奨事項が表示されます

## トラブルシューティング

### エージェントが起動しない場合

```bash
# エージェントのPodの状態を確認
kubectl describe pod -n castai-system -l app=castai-agent

# イベントを確認
kubectl get events -n castai-system --sort-by='.lastTimestamp'
```

### 接続が確立されない場合

1. **APIトークンの確認**
   - CAST AIダッシュボードでAPIトークンが有効か確認
   - トークンの有効期限を確認

2. **ネットワーク接続の確認**
   ```bash
   # CAST AIのAPIエンドポイントに接続できるか確認
   curl -I https://api.cast.ai
   ```

3. **ファイアウォール設定**
   - kindクラスターからCAST AIのAPIエンドポイントへのアウトバウンド接続が許可されているか確認

### エージェントの再デプロイ

```bash
# Helmでアンインストール
helm uninstall castai-agent -n castai-system

# 再度インストール
./scripts/connect-castai.sh
```

### Helmがインストールされていない場合

```bash
# macOSの場合
brew install helm

# または、公式インストールスクリプト
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## APIトークンの管理

### 環境変数として設定

```bash
# 一時的に設定（現在のセッションのみ）
export CASTAI_API_TOKEN="your-api-token-here"

# 永続的に設定（~/.zshrcまたは~/.bashrcに追加）
echo 'export CASTAI_API_TOKEN="your-api-token-here"' >> ~/.zshrc
source ~/.zshrc
```

### Secretとして管理（推奨）

APIトークンを環境変数として設定する代わりに、Kubernetes Secretとして管理することもできます：

```bash
# Secretを作成
kubectl create secret generic castai-api-token \
  --from-literal=apiToken="${CASTAI_API_TOKEN}" \
  -n castai-system

# HelmでSecretを参照
helm upgrade --install castai-agent castai-helm/castai-agent \
  --namespace castai-system \
  --set castai.secretName=castai-api-token \
  --set castai.secretKey=apiToken
```

## 参考リンク

- [CAST AI公式ドキュメント](https://docs.cast.ai/)
- [CAST AI Helm Charts](https://github.com/castai/castai-helm-charts)
- [CAST AI Console](https://console.cast.ai)
