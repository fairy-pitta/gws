# portree TUI Dashboard Demo
# This demo shows the interactive terminal dashboard with multiple worktrees

Output demo-tui.gif

Require portree
Require git

Set Shell "bash"
Set FontSize 16
Set Width 1000
Set Height 600
Set Theme "Catppuccin Mocha"
Set Padding 20
Set Framerate 30
Set PlaybackSpeed 0.75

# Setup: Create worktree and start services
Hide
Type "git worktree add ../demo-feature feature/new-api 2>/dev/null || true"
Enter
Sleep 500ms
Type "portree up --all"
Enter
Sleep 2s
Show

# Launch dashboard
Type "portree dash"
Enter
Sleep 2s

# Navigate through services (4 services: 2 worktrees x 2 services)
Type "j"
Sleep 500ms
Type "j"
Sleep 500ms
Type "j"
Sleep 500ms

# Go back up
Type "k"
Sleep 500ms
Type "k"
Sleep 500ms

# Stop a service
Type "x"
Sleep 1.5s

# Start it again
Type "s"
Sleep 1.5s

# Restart
Type "r"
Sleep 1.5s

# Open in browser
Type "o"
Sleep 1.5s

# Stop all
Type "X"
Sleep 1.5s

# Start all
Type "a"
Sleep 1.5s

# Quit
Type "q"
Sleep 1s

# Cleanup
Hide
Type "portree down --all"
Enter
Sleep 500ms
Type "git worktree remove ../demo-feature 2>/dev/null || true"
Enter
Show
Sleep 500ms
