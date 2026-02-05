# ADR-002: Port Allocation Algorithm

## Status

Accepted

## Context

Each branch/service combination needs a unique port. Requirements:

1. **Deterministic** - Same branch/service should get the same port across restarts
2. **Collision handling** - Multiple branches might hash to the same port
3. **Configurable ranges** - Different services may need different port ranges
4. **Persistence** - Assignments should survive restarts

Random allocation would cause ports to change on every restart, breaking bookmarks and hardcoded URLs.

## Decision

Use FNV-32a hash-based allocation with linear probing:

```go
func hashPort(branch, service string, minPort, maxPort int) int {
    h := fnv.New32a()
    h.Write([]byte(branch + ":" + service))
    rangeSize := maxPort - minPort + 1
    return minPort + int(h.Sum32()) % rangeSize
}
```

Collision resolution:
1. Try the hashed port first
2. If occupied, try port+1, port+2, etc. (linear probing)
3. Wrap around at maxPort
4. If all ports exhausted, return error

Persistence:
- Store assignments in `~/.portree/state.json`
- Check if previously assigned port is still valid before re-hashing

## Consequences

### Positive
- **Deterministic** - `feature/auth` always gets the same port (assuming no collision)
- **Simple implementation** - FNV-32a is fast and well-distributed
- **Predictable** - Users can learn their branch's port

### Negative
- **TOCTOU race** - Port might be taken between check and bind (mitigated by file locking)
- **Range exhaustion** - If range is too small for many branches, allocation fails
- **Linear probing clustering** - Heavy collision scenarios degrade to sequential allocation
