# Architecture

## Overview

portree is a Git Worktree Server Manager that enables running multiple development servers across git worktrees with automatic port allocation and subdomain-based routing.

```
┌─────────────────────────────────────────────────────────────────┐
│                         User                                     │
├─────────────────────────────────────────────────────────────────┤
│  CLI Commands          │  TUI Dashboard      │  Browser          │
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

## Package Responsibilities

### cmd/
CLI entry points using Cobra. Each file corresponds to a subcommand.

### internal/config/
Loads and parses `.portree.toml` configuration.

### internal/git/
Git worktree operations: list, add, remove, detect current worktree.

### internal/process/
Process lifecycle management:
- `Runner` - Starts a single service process
- `Manager` - Coordinates multiple services across worktrees

### internal/port/
Port allocation using FNV-32a hashing with linear probing fallback.

### internal/proxy/
HTTP reverse proxy for subdomain-based routing.

### internal/state/
JSON file-based state persistence with file locking.

### internal/tui/
Bubble Tea-based terminal UI dashboard.

### internal/browser/
Cross-platform browser opening.

### internal/logging/
Structured logging utilities.

## Data Flow

### 1. Configuration Loading
```
.portree.toml → config.Load() → Config{Services, ProxyPorts}
```

### 2. Worktree Discovery
```
git worktree list → git.ListWorktrees() → []Worktree{Branch, Path}
```

### 3. Port Allocation
```
(branch, service) → port.Allocate() → unique port number
                         │
                         ├── FNV32(branch:service) % range
                         ├── Check if port is free
                         └── Linear probe if collision
```

### 4. Service Start
```
Config + Port → Runner.Start() → sh -c "command"
                    │                    │
                    ├── Set PORT env     │
                    ├── Set PT_* env     │
                    └── Track PID ───────┴──→ state.json
```

### 5. Proxy Routing
```
http://feature-auth.localhost:3000
         │
         ▼
    Extract slug: "feature-auth"
         │
         ▼
    Resolve: slug + service → port 3150
         │
         ▼
    Proxy to: http://127.0.0.1:3150
```

## State File Structure

Location: `~/.portree/state.json`

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

## Key Design Decisions

See [ADR documents](./adr/) for detailed rationale:

- [ADR-001: Process Management](./adr/001-process-management.md) - Direct process spawning vs Docker
- [ADR-002: Port Allocation](./adr/002-port-allocation.md) - Hash-based deterministic allocation
- [ADR-003: Reverse Proxy](./adr/003-reverse-proxy.md) - *.localhost subdomain routing
- [ADR-004: State Management](./adr/004-state-management.md) - JSON + flock approach
