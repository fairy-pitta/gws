# portree への貢献

portree への貢献に興味を持っていただきありがとうございます！

## 開発環境のセットアップ

### 必要なもの

- Go 1.21+
- git

### クローンとビルド

```bash
# リポジトリをクローン
git clone https://github.com/fairy-pitta/portree.git
cd portree

# 依存関係をインストール
go mod download

# ビルド
go build -o portree .

# テスト実行
go test ./... -race
```

## テストの実行

```bash
# 全テスト実行
go test ./...

# race detector 付きでテスト
go test ./... -race

# カバレッジ付きでテスト
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out
```

## コードスタイル

- コミット前に `go fmt ./...` を実行
- `go vet ./...` で問題をチェック
- 標準的な Go の慣例に従う
- エラーはコンテキスト付きでラップ: `fmt.Errorf("context: %w", err)`
- 適切な場所ではテーブル駆動テストを使用

## 貢献の方法

### バグ報告

1. 重複を避けるため既存の issue を確認
2. [バグ報告テンプレート](.github/ISSUE_TEMPLATE/bug_report.md)を使用
3. `portree doctor` の出力を含める
4. `~/.portree/logs/` の関連ログを添付

### 機能提案

1. [機能リクエストテンプレート](.github/ISSUE_TEMPLATE/feature_request.md)を使用
2. 解決したい問題を説明
3. 具体的なユースケースを提供

### プルリクエスト

1. リポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/my-feature`)
3. 変更を加える
4. 新機能にはテストを書く
5. テストを実行 (`go test ./... -race`)
6. 説明的なメッセージでコミット
7. フォークにプッシュ
8. プルリクエストを作成

## コミットメッセージ

[Conventional Commits](https://www.conventionalcommits.org/) 形式に従う:

- `feat:` - 新機能
- `fix:` - バグ修正
- `docs:` - ドキュメントの変更
- `test:` - テストの追加・更新
- `chore:` - メンテナンスタスク
- `refactor:` - リファクタリング
- `perf:` - パフォーマンス改善

例: `feat(tui): add keyboard shortcut for restart`

## プロジェクト構成

```
├── cmd/           # CLI コマンド (Cobra)
├── docs/
│   ├── adr/       # Architecture Decision Records
│   ├── ja/        # 日本語ドキュメント
│   └── architecture.md
├── internal/
│   ├── browser/   # ブラウザ起動ユーティリティ
│   ├── config/    # 設定読み込み (.portree.toml)
│   ├── git/       # Git worktree 操作
│   ├── logging/   # ロギングユーティリティ
│   ├── port/      # ポート割り当て (FNV32 ハッシュ)
│   ├── process/   # プロセス管理 (Runner, Manager)
│   ├── proxy/     # リバースプロキシ (サブドメインルーティング)
│   ├── state/     # 状態永続化 (JSON + flock)
│   └── tui/       # ターミナル UI (Bubble Tea)
└── main.go
```

## アーキテクチャ

コードベースの詳細な概要は [docs/ja/architecture.md](docs/ja/architecture.md) を参照。

主要な設計判断は [Architecture Decision Records (ADRs)](docs/ja/adr/) に記録:

- [ADR-001: プロセス管理](docs/ja/adr/001-process-management.md)
- [ADR-002: ポート割り当て](docs/ja/adr/002-port-allocation.md)
- [ADR-003: リバースプロキシ](docs/ja/adr/003-reverse-proxy.md)
- [ADR-004: 状態管理](docs/ja/adr/004-state-management.md)

## 質問がありますか？

質問やヘルプが必要な場合は issue を作成してください。
