package main

import (
	"fmt"
	"os"

	"github.com/fairy-pitta/portree/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}
