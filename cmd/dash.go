package cmd

import (
	"github.com/fairy-pitta/portree/internal/tui"
	"github.com/spf13/cobra"
)

var dashCmd = &cobra.Command{
	Use:   "dash",
	Short: "Open the TUI dashboard",
	Long: `Launches an interactive terminal dashboard to manage all worktree services.

Key bindings:
  j/k or ↑/↓  Navigate services
  s           Start selected service
  x           Stop selected service
  r           Restart selected service
  o           Open in browser
  a           Start all services
  X           Stop all services
  l           View logs
  q           Quit dashboard`,
	RunE: func(cmd *cobra.Command, args []string) error {
		return tui.Run(cfg, repoRoot)
	},
}

func init() {
	rootCmd.AddCommand(dashCmd)
}
