# Git Hooks Management Script

This script provides an easy way to manage Git hooks in your repository. It allows you to quickly create, clear, or check the configuration of various Git hooks, such as `pre-commit`, `pre-push`, and `commit-msg`.

## Features

- **Create Hooks:** Easily configure common Git hooks with predefined actions.
- **Clear Hooks:** Remove configured hooks individually or all at once.
- **Check Hook Configuration:** Quickly see which hooks are currently configured.

## Usage

To use this script, run it from the root of your Git repository with one of the following commands:

``` bash
./init-git-hooks.sh pre-commit    # Create a pre-commit hook
./init-git-hooks.sh pre-push      # Create a pre-push hook
./init-git-hooks.sh commit-msg    # Create a commit-msg hook
./init-git-hooks.sh clear         # Clear all configured hooks
./init-git-hooks.sh clear-one <hook_name>  # Clear a specific hook (e.g., pre-commit, pre-push, commit-msg)
```
Pre-Commit Hook
The pre-commit hook runs 'make' to build the project before each commit. It checks if the build is successful and if the specified executable is created.

Pre-Push Hook
The pre-push hook runs tests before pushing the code to the remote repository. It ensures that all tests pass and performs a cleanup using make fclean.

Commit-Msg Hook
The commit-msg hook checks the format of your commit messages. It ensures that each commit message starts with [ADD], [FIX], [EDIT], or [DEL].

Installation
Copy the script to the root of your Git repository.
Make the script executable: chmod +x init-git-hooks.sh.
Note
Ensure you have make and other necessary tools installed as required by the hooks.
Replace "your_executable_name" in the pre-commit hook with the actual name of your executable.
