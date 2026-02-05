# portree Multi-Worktree Workflow Demo
# This demo shows working with multiple worktrees simultaneously

Output demo-workflow.gif

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

# Create a new worktree
Type "git worktree add ../demo-feature feature/new-api"
Enter
Sleep 1.5s

# List worktrees
Type "git worktree list"
Enter
Sleep 2s

# Start services on ALL worktrees
Type "portree up --all"
Enter
Sleep 2.5s

# Check status - each worktree gets unique ports
Type "portree ls"
Enter
Sleep 3s

# Show accessible URLs for both worktrees
Type "echo ''"
Enter
Type "echo 'Access URLs:'"
Enter
Sleep 300ms
Type "echo '  main branch:'"
Enter
Type "echo '    http://main.localhost:3000         → frontend'"
Enter
Type "echo '    http://main.localhost:8000         → backend'"
Enter
Sleep 500ms
Type "echo '  feature/new-api branch:'"
Enter
Type "echo '    http://feature-new-api.localhost:3000  → frontend'"
Enter
Type "echo '    http://feature-new-api.localhost:8000  → backend'"
Enter
Sleep 2.5s

# Stop all
Type "portree down --all"
Enter
Sleep 2s

# Clean up worktree
Type "git worktree remove ../demo-feature"
Enter
Sleep 1.5s
