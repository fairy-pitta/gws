# アーキテクチャ

## 概要

portree は Git Worktree Server Manager で、複数の git worktree にまたがる開発サーバーを、自動ポート割り当てとサブドメインベースのルーティングで管理します。

```
┌─────────────────────────────────────────────────────────────────┐
│                         ユーザー                                 │
├─────────────────────────────────────────────────────────────────┤
│  CLI コマンド           │  TUI ダッシュボード │  ブラウザ         │
│  (portree up/down/ls)  │  (portree dash)     │  (*.localhost)    │
└───────────┬────────────┴────────┬───────────┴────────┬──────────┘
            │                     │                    │
            ▼                     ▼                    ▼
┌───────────────────────────────────────────────────────────────────┐
│                          cmd/ (Cobra)                             │
│  up.go, down.go, ls.go, dash.go, proxy.go, doctor.go, etc.       │
└───────────────────────────────────────────────────────────────────┘
            │
            ▼
┌───────────────────────────────────────────────────────────────────┐
│                        internal/                                  │
├─────────────┬─────────────┬─────────────┬─────────────┬──────────┤
│   config/   │    git/     │  process/   │   proxy/    │   tui/   │
│   ├─load    │   ├─list    │   ├─runner  │   ├─server  │  ├─app   │
│   └─parse   │   ├─add     │   ├─manager │   └─resolve │  └─view  │
│             │   └─remove  │   └─stop    │             │          │
├─────────────┼─────────────┼─────────────┼─────────────┼──────────┤
│    port/    │   state/    │  browser/   │  logging/   │          │
│   └─alloc   │   ├─store   │   └─open    │   └─log     │          │
│             │   └─lock    │             │             │          │
└─────────────┴─────────────┴─────────────┴─────────────┴──────────┘
```

## パッケージの責務

### cmd/
Cobra を使った CLI エントリーポイント。各ファイルがサブコマンドに対応。

### internal/config/
`.portree.toml` 設定ファイルの読み込みとパース。

### internal/git/
Git worktree 操作: 一覧取得、追加、削除、現在の worktree 検出。

### internal/process/
プロセスライフサイクル管理:
- `Runner` - 単一のサービスプロセスを起動
- `Manager` - 複数 worktree のサービスを統括

### internal/port/
FNV-32a ハッシュを使ったポート割り当て（衝突時は linear probing）。

### internal/proxy/
サブドメインベースルーティングの HTTP リバースプロキシ。

### internal/state/
ファイルロック付き JSON ファイルベースの状態永続化。

### internal/tui/
Bubble Tea ベースのターミナル UI ダッシュボード。

### internal/browser/
クロスプラットフォームのブラウザ起動。

### internal/logging/
構造化ロギングユーティリティ。

## データフロー

### 1. 設定の読み込み
```
.portree.toml → config.Load() → Config{Services, ProxyPorts}
```

### 2. Worktree の検出
```
git worktree list → git.ListWorktrees() → []Worktree{Branch, Path}
```

### 3. ポート割り当て
```
(branch, service) → port.Allocate() → ユニークなポート番号
                         │
                         ├── FNV32(branch:service) % range
                         ├── ポートが空いているか確認
                         └── 衝突時は linear probe
```

### 4. サービス起動
```
Config + Port → Runner.Start() → sh -c "command"
                    │                    │
                    ├── PORT 環境変数設定 │
                    ├── PT_* 環境変数設定 │
                    └── PID 追跡 ────────┴──→ state.json
```

### 5. プロキシルーティング
```
http://feature-auth.localhost:3000
         │
         ▼
    スラッグ抽出: "feature-auth"
         │
         ▼
    解決: slug + service → ポート 3150
         │
         ▼
    プロキシ先: http://127.0.0.1:3150
```

## 状態ファイルの構造

場所: `~/.portree/state.json`

```json
{
  "services": {
    "main:frontend": {
      "port": 3100,
      "pid": 12345,
      "status": "running"
    },
    "feature-auth:frontend": {
      "port": 3150,
      "pid": 12346,
      "status": "running"
    }
  },
  "proxy": {
    "running": true,
    "pids": {
      "3000": 12400
    }
  },
  "port_assignments": {
    "main:frontend": 3100,
    "feature-auth:frontend": 3150
  }
}
```

## 主要な設計判断

詳細な根拠は [ADR ドキュメント](./adr/) を参照:

- [ADR-001: プロセス管理](./adr/001-process-management.md) - 直接プロセス起動 vs Docker
- [ADR-002: ポート割り当て](./adr/002-port-allocation.md) - ハッシュベースの決定論的割り当て
- [ADR-003: リバースプロキシ](./adr/003-reverse-proxy.md) - *.localhost サブドメインルーティング
- [ADR-004: 状態管理](./adr/004-state-management.md) - JSON + flock アプローチ
