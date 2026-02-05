# ADR-004: State Management Design

## Status

Accepted

## Context

portree needs to track:
- Port assignments per branch/service
- Running process PIDs
- Service status (running/stopped)
- Proxy configuration

Multiple portree processes might access state simultaneously:
- User runs `portree up` in one terminal
- User runs `portree ls` in another terminal
- TUI dashboard polls state continuously

Options considered:

1. **SQLite** - ACID, well-tested, but requires CGO
2. **BoltDB/BadgerDB** - Pure Go, but adds dependency
3. **JSON file + flock** - Simple, no dependencies, human-readable

## Decision

Use JSON file storage with file locking:

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

State structure:
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

## Consequences

### Positive
- **No CGO** - Pure Go, easy cross-compilation
- **Human-readable** - Debug by reading state.json directly
- **Simple recovery** - Delete state.json to reset everything
- **No external dependencies** - Just the standard library

### Negative
- **Not atomic** - Write is not atomic (mitigated by flock)
- **Windows compatibility** - flock needs alternative implementation
- **Corruption risk** - Crash during write could corrupt file (mitigated by re-reading on start)
- **No query capability** - Must load entire state to read anything
