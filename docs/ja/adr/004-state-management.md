# ADR-004: 状態管理の設計

## ステータス

Accepted

## コンテキスト

portree は以下を追跡する必要がある:
- ブランチ/サービスごとのポート割り当て
- 実行中プロセスの PID
- サービスステータス (running/stopped)
- プロキシ設定

複数の portree プロセスが同時に状態にアクセスする可能性:
- ユーザーが一つのターミナルで `portree up` を実行
- 別のターミナルで `portree ls` を実行
- TUI ダッシュボードが継続的に状態をポーリング

検討したオプション:

1. **SQLite** - ACID、実績あり、ただし CGO が必要
2. **BoltDB/BadgerDB** - Pure Go、ただし依存関係が増える
3. **JSON ファイル + flock** - シンプル、依存関係なし、人間が読める

## 決定

ファイルロック付きの JSON ファイルストレージを採用:

```go
type FileStore struct {
    path string
    mu   sync.Mutex
}

func (s *FileStore) WithLock(fn func() error) error {
    s.mu.Lock()
    defer s.mu.Unlock()

    f, _ := os.OpenFile(s.lockPath(), os.O_CREATE|os.O_RDWR, 0600)
    defer f.Close()

    syscall.Flock(int(f.Fd()), syscall.LOCK_EX)
    defer syscall.Flock(int(f.Fd()), syscall.LOCK_UN)

    return fn()
}
```

状態の構造:
```json
{
  "services": {
    "main:frontend": {"port": 3100, "pid": 12345, "status": "running"},
    "feature-auth:frontend": {"port": 3150, "pid": 12346, "status": "running"}
  },
  "proxy": {
    "running": true,
    "pids": {"3000": 12400, "8000": 12401}
  },
  "port_assignments": {
    "main:frontend": 3100,
    "feature-auth:frontend": 3150
  }
}
```

## 結果

### 良い点
- **CGO 不要** - Pure Go、クロスコンパイルが簡単
- **人間が読める** - state.json を直接読んでデバッグ可能
- **簡単なリカバリ** - state.json を削除すれば全てリセット
- **外部依存なし** - 標準ライブラリのみ

### 悪い点
- **非アトミック** - 書き込みはアトミックではない（flock で軽減）
- **Windows 互換性** - flock は別実装が必要かもしれない
- **破損リスク** - 書き込み中のクラッシュでファイルが壊れる可能性（起動時の再読み込みで軽減）
- **クエリ機能なし** - 何かを読むには状態全体をロードする必要
