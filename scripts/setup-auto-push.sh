#!/bin/bash

set -e

echo "⚙️  自動pushの設定を開始します..."
echo ""

# Gitリポジトリが存在するか確認
if [ ! -d .git ]; then
    echo "❌ Gitリポジトリが見つかりません"
    echo "まず git init を実行してください"
    exit 1
fi

# post-commitフックを作成
HOOK_FILE=".git/hooks/post-commit"

cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash

# 自動的にGitHubにpushするpost-commitフック

# 現在のブランチを取得
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# mainブランチの場合のみ自動push
if [ "$BRANCH" = "main" ]; then
    echo "🚀 自動的にGitHubにpushします..."
    git push origin main
    if [ $? -eq 0 ]; then
        echo "✅ GitHubへのpushが完了しました"
    else
        echo "⚠️  pushに失敗しました。手動でpushしてください: git push origin main"
    fi
fi
EOF

# 実行権限を付与
chmod +x "$HOOK_FILE"

echo "✅ 自動pushフックを設定しました"
echo ""
echo "📋 設定内容:"
echo "  - コミット後に自動的にGitHubにpushされます"
echo "  - mainブランチのみが対象です"
echo ""
echo "💡 テスト方法:"
echo "  1. ファイルを変更"
echo "  2. git add ."
echo "  3. git commit -m 'test'"
echo "  4. 自動的にpushされます"
echo ""
echo "🔧 無効化する場合:"
echo "  rm .git/hooks/post-commit"
