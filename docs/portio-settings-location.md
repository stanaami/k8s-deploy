# Port.io Settingsの場所

## Settingsへのアクセス方法

### 方法1: 右上のアイコンから（推奨）

1. Port.ioダッシュボードの右上を見る
2. 以下のいずれかをクリック：
   - **歯車アイコン（⚙️ Builder）** - Builder設定
   - **ユーザーアイコン（円形の"S"アイコン）** - ユーザー設定
   - **設定アイコン** - 直接Settingsへ

### 方法2: URLから直接アクセス

以下のURLに直接アクセス：

- **統合設定**: https://app.port.io/settings/integrations
- **ブループリント**: https://app.port.io/builder/blueprints
- **Kubernetes統合**: https://app.port.io/settings/integrations/kubernetes

### 方法3: ナビゲーションメニューから

1. 左上の「Port」ロゴの横にある**ドロップダウン矢印（▼）**をクリック
2. メニューから「Settings」を選択

## Kubernetes統合設定へのアクセス

### ステップバイステップ

1. **右上の歯車アイコン（⚙️ Builder）またはユーザーアイコンをクリック**
2. メニューから「**Settings**」を選択
3. 左サイドバーで「**Integrations**」をクリック
4. 「**Kubernetes**」を選択

または、直接URLにアクセス：
```
https://app.port.io/settings/integrations/kubernetes
```

## Builder（ブループリント設定）へのアクセス

1. **右上の「Builder」アイコン（⚙️）をクリック**
2. 左サイドバーで「**Blueprints**」を選択

または、直接URLにアクセス：
```
https://app.port.io/builder/blueprints
```

## 確認すべき設定項目

### Kubernetes統合設定で確認：
- ✅ Kubernetes統合が有効になっているか
- ✅ クラスターが正しく接続されているか
- ✅ ブループリントテンプレートが適用されているか

### Blueprintsで確認：
- ✅ `k8s_namespace` ブループリントが存在するか
- ✅ `k8s_workload` ブループリントが存在するか
- ✅ `k8s_pod` ブループリントが存在するか
- ✅ 各ブループリント間の関係（Relations）が設定されているか
