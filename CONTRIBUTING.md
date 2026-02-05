# Contributing to portree

Thank you for your interest in contributing to portree!

## Development Setup

### Prerequisites

- Go 1.21+
- git

### Clone and Build

```bash
# Clone the repository
git clone https://github.com/fairy-pitta/portree.git
cd portree

# Install dependencies
go mod download

# Build
go build -o portree .

# Run tests
go test ./... -race
```

## Running Tests

```bash
# Run all tests
go test ./...

# Run tests with race detection
go test ./... -race

# Run tests with coverage
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out
```

## Code Style

- Run `go fmt ./...` before committing
- Run `go vet ./...` to check for issues
- Follow standard Go conventions
- Wrap errors with context: `fmt.Errorf("context: %w", err)`
- Write table-driven tests where applicable

## How to Contribute

### Reporting Bugs

1. Check existing issues to avoid duplicates
2. Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md)
3. Include `portree doctor` output
4. Attach relevant logs from `~/.portree/logs/`

### Suggesting Features

1. Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md)
2. Describe the problem you're solving
3. Provide concrete use cases

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Write tests for new functionality
5. Run tests (`go test ./... -race`)
6. Commit your changes with a descriptive message
7. Push to your fork
8. Open a Pull Request

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring
- `perf:` - Performance improvements

Example: `feat(tui): add keyboard shortcut for restart`

## Project Structure

```
├── cmd/           # CLI commands (Cobra)
├── docs/
│   ├── adr/       # Architecture Decision Records
│   └── architecture.md
├── internal/
│   ├── browser/   # Browser opening utility
│   ├── config/    # Configuration loading (.portree.toml)
│   ├── git/       # Git worktree operations
│   ├── logging/   # Logging utilities
│   ├── port/      # Port allocation (FNV32 hash)
│   ├── process/   # Process management (Runner, Manager)
│   ├── proxy/     # Reverse proxy (subdomain routing)
│   ├── state/     # State persistence (JSON + flock)
│   └── tui/       # Terminal UI (Bubble Tea)
└── main.go
```

## Architecture

See [docs/architecture.md](docs/architecture.md) for a detailed overview of the codebase.

Key design decisions are documented in [Architecture Decision Records (ADRs)](docs/adr/):

- [ADR-001: Process Management](docs/adr/001-process-management.md)
- [ADR-002: Port Allocation](docs/adr/002-port-allocation.md)
- [ADR-003: Reverse Proxy](docs/adr/003-reverse-proxy.md)
- [ADR-004: State Management](docs/adr/004-state-management.md)

## Questions?

Open an issue if you have questions or need help.
