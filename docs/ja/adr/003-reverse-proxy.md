# ADR-003: リバースプロキシのアーキテクチャ

## ステータス

Accepted

## コンテキスト

ユーザーはポート番号なしで異なるブランチに個別の URL でアクセスしたい:
- `http://main.localhost:3000` → main ブランチのフロントエンド
- `http://feature-auth.localhost:3000` → feature/auth ブランチのフロントエンド

検討したオプション:

1. **/etc/hosts 編集** - sudo が必要、手動メンテナンス
2. **ローカル DNS サーバー (dnsmasq)** - 追加の依存関係、複雑なセットアップ
3. ***.localhost 解決に依存** - RFC 6761 準拠、設定不要

RFC 6761 は `*.localhost` がループバック (127.0.0.1) に解決されるべきと規定している。モダンブラウザ (Chrome 80+, Firefox 78+, Safari 13+) はこれに準拠。

## 決定

シンプルな HTTP リバースプロキシを実装:

1. 設定されたプロキシポート（デフォルト: 3000, 8000 など）でリッスン
2. Host ヘッダーからブランチスラッグを抽出: `feature-auth.localhost:3000` → `feature-auth`
3. そのブランチ/サービスの組み合わせのバックエンドポートを検索
4. リクエストを `127.0.0.1:<backend-port>` にプロキシ

特別な処理:
- **WebSocket サポート** - 接続を適切にアップグレード
- **SSE/HMR サポート** - 書き込みタイムアウトなし、ストリーミングレスポンス
- **ルートドメインフォールバック** - `localhost:3000` は main ブランチにルーティング

```go
proxy := &httputil.ReverseProxy{
    Director: func(req *http.Request) {
        slug := extractSlug(req.Host)
        port := resolver.Resolve(slug, service)
        req.URL.Host = fmt.Sprintf("127.0.0.1:%d", port)
    },
}
```

## 結果

### 良い点
- **設定不要** - /etc/hosts 編集不要、DNS セットアップ不要
- **モダンブラウザサポート** - 最近のブラウザですぐに動作
- **HMR/SSE 互換** - ホットリロードがシームレスに動作

### 悪い点
- **古いブラウザの問題** - IE11 以前は *.localhost を解決しない可能性
- **HTTPS なし** - 証明書生成が必要（localhost では通常不要）
- **ポート競合** - プロキシポート (3000, 8000) が使用中の可能性
