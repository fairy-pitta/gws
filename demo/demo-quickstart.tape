# portree Quick Start Demo
# This demo shows the basic workflow: config → up → ls → URLs → open

Output demo-quickstart.gif

Require portree

Set Shell "bash"
Set FontSize 16
Set Width 1000
Set Height 600
Set Theme "Catppuccin Mocha"
Set Padding 20
Set Framerate 30
Set PlaybackSpeed 0.75

# Show config
Type "cat .portree.toml"
Enter
Sleep 3s

# Start services
Type "portree up"
Enter
Sleep 2.5s

# Check status
Type "portree ls"
Enter
Sleep 2.5s

# Show accessible URLs
Type "echo ''"
Enter
Type "echo 'Access URLs:'"
Enter
Sleep 300ms
Type "echo '  http://main.localhost:3000  → frontend'"
Enter
Sleep 300ms
Type "echo '  http://main.localhost:8000  → backend'"
Enter
Sleep 2s

# Open in browser
Type "portree open"
Enter
Sleep 2s

# Stop services
Type "portree down"
Enter
Sleep 2s
