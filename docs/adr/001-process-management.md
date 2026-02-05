# ADR-001: Process Management Approach

## Status

Accepted

## Context

portree needs to start and manage multiple development servers across git worktrees. There are several approaches to process management:

1. **Docker Compose** - Container-based, requires Docker installation
2. **Direct process spawning** - Native processes via `sh -c`
3. **systemd/launchd** - OS-level service management

Users typically want to:
- Use their existing development toolchain without modification
- Avoid additional dependencies like Docker
- Have processes that behave identically to running commands manually

Git worktrees operate on the host filesystem, making container volume mounting more complex.

## Decision

Use direct process spawning via `sh -c` with process group management:

```go
cmd := exec.Command("sh", "-c", command)
cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
```

Key implementation details:
- Each service runs as a process group leader
- Child processes are killed via `syscall.Kill(-pgid, syscall.SIGTERM)`
- Graceful shutdown with timeout, then SIGKILL
- PID tracking in state.json for orphan detection

## Consequences

### Positive
- **Zero dependencies** - Single binary installation
- **Native performance** - No container overhead
- **Familiar behavior** - Processes behave exactly as if run manually
- **Simple debugging** - Standard tools (ps, lsof, strace) work normally

### Negative
- **No isolation** - Processes share host environment
- **Platform differences** - Process group semantics vary (Windows needs different approach)
- **Orphan processes** - If portree crashes, processes may be left running (mitigated by PID tracking)
