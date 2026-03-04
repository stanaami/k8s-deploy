#!/bin/bash

set -e

USERNAME="stanaami"
REPO_NAME="k8s-deploy"

echo "📦 GitHubへのpushを開始します..."
echo "ユーザー名: $USERNAME"
echo "リポジトリ名: $REPO_NAME"
echo ""

# Gitリポジトリの初期化
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "ℹ️  Gitリポジトリは既に初期化されています"
else
    echo "🔧 Gitリポジトリを初期化しています..."
    # .gitディレクトリが不完全な場合は削除して再初期化
    if [ -d .git ]; then
        echo "⚠️  不完全な.gitディレクトリを削除しています..."
        rm -rf .git
    fi
    git init
fi

# ファイルを追加
echo "📝 ファイルをステージングしています..."
git add .

# コミット
echo "💾 変更をコミットしています..."
git commit -m "Initial commit: kind Kubernetes testing environment" || {
    echo "⚠️  コミットする変更がありません（既にコミット済みの可能性があります）"
}

# リモートの確認と追加（SSHを使用）
if git remote get-url origin &> /dev/null; then
    echo "🔄 既存のリモートを更新しています..."
    git remote set-url origin "git@github.com:${USERNAME}/${REPO_NAME}.git"
else
    echo "➕ リモートリポジトリを追加しています..."
    git remote add origin "git@github.com:${USERNAME}/${REPO_NAME}.git"
fi

# ブランチ名をmainに設定
echo "🌿 ブランチをmainに設定しています..."
git branch -M main

# GitHubにpush
echo "🚀 GitHubにpushしています..."
git push -u origin main

echo ""
echo "✅ GitHubへのpushが完了しました！"
echo "リポジトリURL: https://github.com/${USERNAME}/${REPO_NAME}"
