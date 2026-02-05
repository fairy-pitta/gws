# Contributing to portree

Thank you for your interest in contributing to portree!

## Development Setup

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

## Code Style

- Run `go fmt ./...` before committing
- Run `go vet ./...` to check for issues
- Follow standard Go conventions

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Run tests (`go test ./... -race`)
5. Commit your changes with a descriptive message
6. Push to your fork
7. Open a Pull Request

## Commit Messages

Follow conventional commits format:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring

Example: `feat(tui): add keyboard shortcut for restart`

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

## Project Structure

```
├── cmd/           # CLI commands (cobra)
├── internal/
│   ├── browser/   # Browser opening utility
│   ├── config/    # Configuration loading
│   ├── git/       # Git worktree operations
│   ├── logging/   # Logging utilities
│   ├── port/      # Port allocation
│   ├── process/   # Process management
│   ├── proxy/     # Reverse proxy
│   ├── state/     # State persistence
│   └── tui/       # Terminal UI (bubbletea)
└── main.go
```

## Questions?

Open an issue if you have questions or need help.
