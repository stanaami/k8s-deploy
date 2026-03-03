#!/bin/bash

set -e

echo "📦 Gitリポジトリのセットアップを開始します..."

# Gitリポジトリが既に初期化されているか確認
if [ -d .git ]; then
    echo "ℹ️  Gitリポジトリは既に初期化されています"
else
    echo "🔧 Gitリポジトリを初期化しています..."
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

echo ""
echo "✅ Gitリポジトリのセットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "1. GitHubで新しいリポジトリを作成してください"
echo "2. 以下のコマンドでリモートを追加してpushしてください:"
echo ""
echo "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "または、SSHを使用する場合:"
echo "   git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
