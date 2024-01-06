# Git Hooks Management Script

This script offers a convenient way to manage Git hooks within your repository. It enables you to easily create, clear, or verify the configuration of various Git hooks such as `pre-commit`, `pre-push`, and `commit-msg`. The script also provides functionality for backing up and restoring hook configurations, as well as the ability to customize hooks with user-specified parameters.

## Features

- **Create Hooks:** Configure common Git hooks with predefined or custom actions.
- **Clear Hooks:** Remove configured hooks individually by their name or number, or clear all hooks at once.
- **Check Hook Configuration:** Quickly determine which hooks are currently configured.
- **Backup and Restore Hooks:** Save your current hook configurations and restore them as needed.
- **Interactive Menu:** Easily navigate and select hook management options through an interactive command-line interface.
- **Customizable Commit Messages:** For the `commit-msg` hook, specify a file containing required keywords or patterns for commit messages.

## Usage

Run the script from the root of your Git repository using one of the following commands:

```bash
./init-git-hooks.sh pre-commit    # Create a pre-commit hook
./init-git-hooks.sh pre-push      # Create a pre-push hook
./init-git-hooks.sh commit-msg    # Create a commit-msg hook
./init-git-hooks.sh clear         # Clear all configured hooks
./init-git-hooks.sh clear-one <hook_number>  # Clear a specific hook by number
Pre-Commit Hook
The pre-commit hook runs 'make' to build the project before each commit. It checks if the build is successful and if the specified executable is created. The user can specify the name of the executable.

Pre-Push Hook
The pre-push hook executes tests before pushing the code to the remote repository, ensuring that all tests pass. It performs a cleanup using make fclean.

Commit-Msg Hook
The commit-msg hook validates the format of commit messages against a user-provided set of keywords or patterns. This ensures that each commit message starts with specified keywords like [ADD], [FIX], [EDIT], or [DEL].

Backup and Restore Hooks
You can backup your current hook configurations to a designated directory and restore them later. This feature is useful for maintaining consistent hook settings across different repositories or sharing configurations with team members.

Installation
Copy the script to the root of your Git repository.
Make the script executable: chmod +x init-git-hooks.sh.
Note
Ensure you have make and other necessary tools installed as required by the hooks.
Customize the pre-commit hook by replacing "your_executable_name" with the actual name of your executable.
For the commit-msg hook, provide a file containing the required keywords or patterns for commit messages.