# k8s-deploy

ローカルにk8sクラスタをデプロイ（kind）

このプロジェクトは、kind（Kubernetes in Docker）を使用したKubernetes検証環境です。

## 前提条件

- Docker Desktop がインストールされ、起動していること
- kubectl がインストールされていること（推奨）

## セットアップ

### 1. Docker Desktopのインストール

kindはDockerを使用するため、まずDocker Desktopをインストールする必要があります。

macOSの場合、Homebrewを使用してインストールできます：

```bash
brew install --cask docker
```

インストール後、Docker Desktopを起動してください：

```bash
open -a Docker
```

または、アプリケーションフォルダから「Docker」を起動してください。

Dockerが正常に起動したことを確認：

```bash
docker info
```

### 2. kindのインストール

macOSの場合、Homebrewを使用してインストールできます：

```bash
brew install kind
```

または、公式のインストールスクリプトを使用：

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### 3. クラスターの作成

```bash
kind create cluster --name k8s-testing --config kind-config.yaml
```

### 4. kubectlの設定確認

```bash
kubectl cluster-info --context kind-k8s-testing
kubectl get nodes
```

## 使用方法

### クラスターの起動・停止

クラスターはDockerコンテナとして実行されているため、通常は常時起動しています。
停止する場合は、Dockerコンテナを停止してください：

```bash
docker ps | grep kind
docker stop <container-id>
```

### サンプルアプリケーションのデプロイ

```bash
kubectl apply -f examples/nginx-deployment.yaml
kubectl get pods
kubectl get services
```

### ポートフォワーディング

nginxのサンプルアプリケーションにアクセスする場合：

```bash
kubectl port-forward service/nginx-service 8080:80
```

その後、ブラウザで `http://localhost:8080` にアクセスできます。

## クラスターの削除

```bash
kind delete cluster --name k8s-testing
```

## トラブルシューティング

### Docker Desktopがインストールされていない場合

```bash
# Homebrewでインストール
brew install --cask docker

# インストール後、Docker Desktopを起動
open -a Docker
```

### Dockerが起動していない場合

```bash
# Docker Desktopを起動してください
open -a Docker

# または、アプリケーションフォルダから「Docker」を起動
```

### クラスターの状態確認

```bash
kind get clusters
docker ps | grep kind
```

### ログの確認

```bash
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

## GitHubへのpush手順

このプロジェクトをGitHubにpushする場合、以下の手順を実行してください：

### 1. Gitリポジトリの初期化

```bash
git init
```

### 2. ファイルの追加とコミット

```bash
git add .
git commit -m "Initial commit: kind Kubernetes testing environment"
```

### 3. GitHubリポジトリの作成

GitHubで新しいリポジトリを作成してください：
- GitHubにログイン
- 右上の「+」→「New repository」をクリック
- リポジトリ名を入力（例: `k8s-testing-environment`）
- 「Create repository」をクリック

### 4. リモートリポジトリの追加とpush

```bash
# リモートリポジトリを追加（YOUR_USERNAMEとYOUR_REPO_NAMEを置き換えてください）
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# ブランチ名をmainに変更（必要に応じて）
git branch -M main

# GitHubにpush
git push -u origin main
```

または、SSHを使用する場合：

```bash
git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

## 参考リンク

- [kind公式ドキュメント](https://kind.sigs.k8s.io/)
- [Kubernetes公式ドキュメント](https://kubernetes.io/docs/)
