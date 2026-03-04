# Gitの構造と`.gitignore`について

## `.git`ディレクトリ

`.git`ディレクトリは、Gitリポジトリのすべてのメタデータと履歴情報を格納する場所です。

### 主な内容

#### 1. **`config`** - リポジトリ設定
- リモートリポジトリのURL（`origin`など）
- ブランチの設定
- ユーザー情報（ローカルのみ、グローバル設定は`~/.gitconfig`）
- その他のリポジトリ固有の設定

```bash
# 確認方法
cat .git/config
```

#### 2. **`HEAD`** - 現在のブランチ参照
- 現在チェックアウトしているブランチを指す
- 通常は `ref: refs/heads/main` のような形式

#### 3. **`refs/`** - 参照情報
- `refs/heads/` - ブランチのコミットハッシュ
- `refs/remotes/` - リモートブランチの参照
- `refs/tags/` - タグの参照

#### 4. **`objects/`** - Gitオブジェクトストア
- コミット、ツリー、ブロブ（ファイル内容）の圧縮データ
- SHA-1ハッシュで管理される
- Gitのコアデータベース

#### 5. **`index`** - ステージングエリア
- `git add`で追加されたファイルの情報
- 次のコミットに含まれるファイルのスナップショット

#### 6. **`hooks/`** - Gitフック
- `pre-commit`, `post-commit`, `pre-push` などのスクリプト
- 特定のGit操作の前後に自動実行される
- 例: `post-commit` - コミット後に自動push

#### 7. **`logs/`** - 操作履歴
- `HEAD`の移動履歴
- ブランチの変更履歴
- `git reflog`で表示される情報

#### 8. **`info/`** - 追加情報
- `exclude` - リポジトリ固有の`.gitignore`（コミットされない）
- その他の補助情報

### 重要なポイント

- **`.git`ディレクトリは通常、リポジトリにコミットしない**
- ローカル環境でのみ存在し、各開発者のマシンに個別に存在
- リモートリポジトリにpushされても、`.git`ディレクトリ自体は送信されない
- ただし、`.git`内の一部の情報（設定など）は共有される場合がある

## `.gitignore`ファイル

`.gitignore`は、Gitが追跡しないファイルやディレクトリを指定するファイルです。

### 主な用途

#### 1. **機密情報の保護**
```
# 認証情報
*.key
*.pem
.env
secrets.yaml
```

#### 2. **ビルド成果物**
```
# コンパイル済みファイル
*.class
*.o
*.exe
dist/
build/
```

#### 3. **依存関係**
```
# パッケージマネージャー
node_modules/
vendor/
.venv/
```

#### 4. **IDE/エディタ設定**
```
# IDE設定（個人の設定）
.vscode/
.idea/
*.swp
*.swo
```

#### 5. **OS固有ファイル**
```
# macOS
.DS_Store
.AppleDouble

# Windows
Thumbs.db
desktop.ini

# Linux
*~
```

#### 6. **一時ファイル**
```
*.tmp
*.log
*.cache
```

### `.gitignore`の書き方

#### パターンマッチング
```gitignore
# 特定のファイル
filename.txt

# ワイルドカード
*.log
*.tmp

# ディレクトリ全体
node_modules/
.vscode/

# 特定のディレクトリ内のファイル
logs/*.log

# 再帰的にマッチ
**/*.log

# 否定（例外）
!important.log
```

#### 例：このプロジェクトの`.gitignore`
```gitignore
# kind関連
kind-*

# kubectl設定（ローカルのみ）
.kube/

# 一時ファイル
*.tmp
*.log
*.swp
*~

# macOS
.DS_Store

# IDE
.vscode/
.idea/
*.iml

# Port.io認証情報（機密情報を含む可能性があるファイル）
# portio-agent.yaml に認証情報が含まれている場合は、この行のコメントを外してください
# portio-agent.yaml
```

### `.gitignore`の優先順位

1. **リポジトリルートの`.gitignore`** - プロジェクト全体に適用
2. **サブディレクトリの`.gitignore`** - そのディレクトリと配下に適用
3. **`.git/info/exclude`** - リポジトリ固有だがコミットされない設定
4. **`~/.gitignore_global`** - ユーザー全体のグローバル設定

### 注意事項

#### 既に追跡されているファイル
`.gitignore`に追加しても、既にGitで追跡されているファイルは無視されません。

```bash
# 既に追跡されているファイルを削除（ファイル自体は残る）
git rm --cached filename.txt

# その後、.gitignoreに追加
echo "filename.txt" >> .gitignore
git commit -m "Add filename.txt to .gitignore"
```

#### 機密情報が誤ってコミットされた場合
```bash
# Git履歴から完全に削除（注意：履歴を書き換える）
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch secrets.yaml" \
  --prune-empty --tag-name-filter cat -- --all

# または、git-filter-repoを使用（推奨）
git filter-repo --path secrets.yaml --invert-paths
```

## まとめ

### `.git`ディレクトリ
- Gitリポジトリの**メタデータと履歴**を格納
- ローカル環境でのみ存在
- 通常はコミットしない
- リポジトリの「データベース」のようなもの

### `.gitignore`
- Gitが**追跡しないファイル**を指定
- 機密情報や一時ファイルを保護
- リポジトリにコミットされる
- チーム全体で共有される

## 参考リンク

- [Git公式ドキュメント - .gitignore](https://git-scm.com/docs/gitignore)
- [Git公式ドキュメント - Git Internals](https://git-scm.com/book/en/v2/Git-Internals)
- [GitHub - gitignore templates](https://github.com/github/gitignore)
