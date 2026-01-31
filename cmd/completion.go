package cmd

import (
	"os"

	"github.com/spf13/cobra"
)

var completionCmd = &cobra.Command{
	Use:   "completion [bash|zsh|fish|powershell]",
	Short: "Generate shell completion scripts",
	Long: `Generate shell completion scripts for portree.

To load completions:

  bash:
    $ source <(portree completion bash)
    # Or for persistent use:
    $ portree completion bash > /etc/bash_completion.d/portree

  zsh:
    $ portree completion zsh > "${fpath[1]}/_portree"
    # You may need to start a new shell for this to take effect.

  fish:
    $ portree completion fish | source
    # Or for persistent use:
    $ portree completion fish > ~/.config/fish/completions/portree.fish

  powershell:
    PS> portree completion powershell | Out-String | Invoke-Expression
    # Or for persistent use:
    PS> portree completion powershell > portree.ps1
    # and add ". portree.ps1" to your PowerShell profile.
`,
	DisableFlagsInUseLine: true,
	ValidArgs:             []string{"bash", "zsh", "fish", "powershell"},
	Args:                  cobra.MatchAll(cobra.ExactArgs(1), cobra.OnlyValidArgs),
	RunE: func(cmd *cobra.Command, args []string) error {
		switch args[0] {
		case "bash":
			return rootCmd.GenBashCompletionV2(os.Stdout, true)
		case "zsh":
			return rootCmd.GenZshCompletion(os.Stdout)
		case "fish":
			return rootCmd.GenFishCompletion(os.Stdout, true)
		case "powershell":
			return rootCmd.GenPowerShellCompletionWithDesc(os.Stdout)
		}
		return nil
	},
}

func init() {
	rootCmd.AddCommand(completionCmd)
}
