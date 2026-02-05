# portree Demo GIFs

This directory contains VHS tape files for generating demo GIFs for the README.

## Prerequisites

- [VHS](https://github.com/charmbracelet/vhs) - Terminal recorder
- Go (for building portree)
- Python 3 (for mock servers)

```bash
# Install VHS
brew install vhs
```

## Quick Start

```bash
# Generate all demo GIFs
make all

# Or generate individually
make quickstart   # Basic usage demo
make tui          # TUI dashboard demo
make workflow     # Multi-worktree workflow demo
```

## Demo Files

| File | Description | Output |
|------|-------------|--------|
| `demo-quickstart.tape` | Basic portree workflow: init → up → ls → proxy | `demo-quickstart.gif` |
| `demo-tui.tape` | Interactive TUI dashboard demonstration | `demo-tui.gif` |
| `demo-workflow.tape` | Multi-worktree development workflow | `demo-workflow.gif` |

## Manual Generation

If `make` doesn't work, you can run manually:

```bash
# 1. Build portree
cd /path/to/portree
go build -o portree .

# 2. Setup demo environment
./demo/setup-demo-env.sh /tmp/portree-demo ./portree

# 3. Generate GIFs
cd /tmp/portree-demo
export PATH="/path/to/portree:$PATH"
vhs /path/to/portree/demo/demo-quickstart.tape
vhs /path/to/portree/demo/demo-tui.tape
vhs /path/to/portree/demo/demo-workflow.tape
```

## Customization

Edit the `.tape` files to customize:
- `Set FontSize` - Font size (default: 14)
- `Set Width/Height` - Terminal dimensions
- `Set Theme` - Color theme (e.g., "Catppuccin Mocha", "Dracula")
- `Set PlaybackSpeed` - Speed multiplier
- `Sleep` durations - Pause between commands

See [VHS documentation](https://github.com/charmbracelet/vhs) for all options.

## Adding to README

After generating, move the GIFs and update the main README:

```markdown
## Demo

![Quick Start](./demo/demo-quickstart.gif)
```
