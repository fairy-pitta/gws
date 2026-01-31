package cmd

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// Set via ldflags at build time.
var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version of portree",
	RunE: func(cmd *cobra.Command, args []string) error {
		jsonFlag, _ := cmd.Flags().GetBool("json")
		if jsonFlag {
			return json.NewEncoder(os.Stdout).Encode(map[string]string{
				"version": version,
				"commit":  commit,
				"date":    date,
			})
		}
		fmt.Printf("portree %s (commit: %s, built: %s)\n", version, commit, date)
		return nil
	},
}

func init() {
	versionCmd.Flags().Bool("json", false, "Output in JSON format")
	rootCmd.AddCommand(versionCmd)
}
