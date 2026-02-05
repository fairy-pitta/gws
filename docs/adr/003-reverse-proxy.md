# ADR-003: Reverse Proxy Architecture

## Status

Accepted

## Context

Users want to access different branches via distinct URLs without port numbers:
- `http://main.localhost:3000` → main branch frontend
- `http://feature-auth.localhost:3000` → feature/auth branch frontend

Options considered:

1. **/etc/hosts editing** - Requires sudo, manual maintenance
2. **Local DNS server (dnsmasq)** - Additional dependency, complex setup
3. **Rely on *.localhost resolution** - RFC 6761 compliance, zero config

RFC 6761 specifies that `*.localhost` should resolve to loopback (127.0.0.1). Modern browsers (Chrome 80+, Firefox 78+, Safari 13+) comply with this.

## Decision

Implement a simple HTTP reverse proxy that:

1. Listens on configured proxy ports (default: 3000, 8000, etc.)
2. Extracts branch slug from Host header: `feature-auth.localhost:3000` → `feature-auth`
3. Looks up the backend port for that branch/service combination
4. Proxies the request to `127.0.0.1:<backend-port>`

Special handling:
- **WebSocket support** - Upgrade connection properly
- **SSE/HMR support** - No write timeout, streaming responses
- **Root domain fallback** - `localhost:3000` routes to main branch

```go
proxy := &httputil.ReverseProxy{
    Director: func(req *http.Request) {
        slug := extractSlug(req.Host)
        port := resolver.Resolve(slug, service)
        req.URL.Host = fmt.Sprintf("127.0.0.1:%d", port)
    },
}
```

## Consequences

### Positive
- **Zero configuration** - No /etc/hosts editing, no DNS setup
- **Modern browser support** - Works out of the box on recent browsers
- **HMR/SSE compatible** - Hot reload works seamlessly

### Negative
- **Old browser issues** - IE11 and older browsers may not resolve *.localhost
- **No HTTPS** - Would require certificate generation (usually not needed for localhost)
- **Port conflicts** - Proxy ports (3000, 8000) might be in use
