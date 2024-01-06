# Git Hooks Management Script

This script provides an easy and interactive way to manage Git hooks in your repository. It allows you to quickly create, clear, backup, or restore the configuration of various Git hooks, such as `pre-commit`, `pre-push`, and `commit-msg`.

## Features

- **Interactive Menu:** Navigate and manage Git hooks through an easy-to-use interactive menu.
- **Create Hooks:** Configure common Git hooks with customizable actions.
- **Clear Hooks:** Remove configured hooks individually by their number or clear all hooks at once.
- **Backup and Restore Hooks:** Easily backup your current hook configurations and restore them as needed.
- **Check Hook Configuration:** Quickly see which hooks are currently configured and modify them if necessary.

## Usage

To use this script, run it from the root of your Git repository. You'll be presented with an interactive menu where you can select various options:

```bash
./init-git-hooks.sh
```

## Available Options
1. ### Configure pre-commit hook:
     Sets up a **'pre-commit'** hook that runs 'make' to build the project and checks if a specified executable is     created.

2. ### Configure pre-push hook:
     Establishes a **'pre-push'** hook to run tests before pushing code, ensuring all tests pass.
   
3. ### Configure commit-msg hook:
     Creates a **'commit-msg'** hook that checks the format of your commit messages based on specified patterns.
4. ### Clear all hooks:
     Removes all configured hooks from the repository. 
5. ### Clear specific hook by number:
     Clears a specified hook based on its number in the menu.
6. ### Backup hooks:
     Saves the current hook configurations to a backup directory.
7. ### Restore hooks from backup:
     Restores hooks from the previously saved backup.

## Pre-Commit Hook
- The **'pre-commit'** hook compiles the project using **'make'** and checks for the successful creation of a specified executable.
- You can specify the name of the executable when setting up this hook.

## Pre-Push Hook
- The **'pre-push'** hook executes tests before pushing changes, ensuring that all tests pass.
- It performs a cleanup using **'make fclean'** after running the tests.
  
## Commit-Msg Hook
- The **'commit-msg'** hook validates the format of commit messages against specified patterns or keywords.
- You will be prompted to provide a file containing the required patterns when setting up this hook.
  
## Backup and Restore
- The script provides options to backup and restore your Git hooks, allowing you to maintain consistent hook configurations across different setups.

## Installation
1. Copy the script to the root of your Git repository.
2. Make the script executable: **'chmod +x init-git-hooks.sh'**.

## Notes
- Ensure you have **'make'** and any other necessary tools installed as required by the hooks.
- Modify the hooks as needed to fit your specific workflow or project requirements.
