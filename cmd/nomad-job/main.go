// Package main provides a simple utility to execute Nomad job files.
// This program acts as a wrapper around the 'nomad job run' command.
package main

import (
	"fmt"
	"os"
	"os/exec"
)

// main is the entry point of the program. It validates the input arguments,
// executes the Nomad job file using the 'nomad job run' command, and handles
// any errors that occur during execution.
func main() {
	// Ensure at least one argument (the job file path) is provided.
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <job-file1.hcl> [<job-file2.hcl> ...]\n", os.Args[0])
		os.Exit(1)
	}

	// Iterate over all provided job file paths.
	for _, jobFile := range os.Args[1:] {
		// Prepare the 'nomad job run' command with the current job file.
		cmd := exec.Command("nomad", "job", "run", jobFile)
		cmd.Stdout = os.Stdout // Redirect command output to standard output.
		cmd.Stderr = os.Stderr // Redirect command errors to standard error.

		// Execute the command and handle any errors.
		if err := cmd.Run(); err != nil {
			fmt.Fprintf(os.Stderr, "Failed to run job for file %s: %v\n", jobFile, err)
			os.Exit(1)
		}

		// Print a success message if the job file was executed successfully.
		fmt.Printf("✅ Successfully submitted job file: %s\n", jobFile)
	}
}
