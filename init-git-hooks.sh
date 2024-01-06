#!/bin/bash

GREEN="\033[0;32m"
NO_COLOR="\033[0m"

declare -A hook_map
hook_map[1]="pre-commit"
hook_map[2]="pre-push"
hook_map[3]="commit-msg"

if [ ! -d ".git" ]; then
    echo "This is not a Git repository. Please run this script at the root of a Git repository."
    exit 1
fi

clear_specific_hook() {
    local hook_number=$1
    local hook_name=${hook_map[$hook_number]}

    if [ -z "$hook_name" ]; then
        echo "Invalid hook number."
        return 1
    fi

    local hook_path=".git/hooks/$hook_name"
    if [ -f "$hook_path" ]; then
        rm -f "$hook_path"
        echo "Hook '$hook_name' has been cleared."
    else
        echo "Hook '$hook_name' not found or already cleared."
    fi
}


create_pre_push_hook() {
    cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

echo "Running tests before push..."
make test
if [ $? -ne 0 ]; then
    echo "Tests failed. Fix the issues before pushing."
    exit 1
fi

echo "All tests passed."
make fclean
exit 0
EOF
    chmod +x .git/hooks/pre-push
    echo "Pre-push hook configured."
}

create_commit_msg_hook() {
    echo "Enter the path of the file containing the reasons for commit messages (e.g. '(add) [add] [ADD]'):"
    read keywords_file

    if [ ! -f "$keywords_file" ]; then
        echo "File not found : $keywords_file"
        return 1
    fi

    IFS=$'\n' read -d '' -r -a lines < "$keywords_file"
    keywords=$(IFS='|'; echo "${lines[*]}")

    cat > .git/hooks/commit-msg <<EOF
#!/bin/bash

if ! grep -qE '$keywords' "\$1"; then
    echo "the commit message does not follow the required format. Possible reasons are: ${lines[*]}"
    exit 1
fi
EOF
    chmod +x .git/hooks/commit-msg
    echo "Commit-msg hook configured with patterns: ${lines[*]}"
}


clear_hooks() {
    rm -f .git/hooks/pre-commit .git/hooks/pre-push .git/hooks/commit-msg
    echo "All configured hooks have been cleared."
}

create_pre_commit_hook() {
    local executable_name=""
    echo -n "Enter the name of the executable to build before committing (default: 'default'): "
    read executable_name

    if [ -z "$executable_name" ]; then
        echo "No executable name specified for the pre-commit hook. Use of 'default."
        executable_name="default"
    fi
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "Running 'make' to build the project..."
make
if [ $? -ne 0 ]; then
    echo "Build failed. Please correct the errors before committing."
    exit 1
fi

if [ ! -f "$executable_name" ]; then
    echo "The executable '$executable_name' was not found. Please check your Makefile."
    make fclean
    exit 1
fi

echo "Executable '$executable_name' successfully built."

make fclean
if [ $? -ne 0 ]; then
    echo "make fclean failed."
    exit 1
fi

echo "Cleanup successful."
exit 0
EOF
chmod +x .git/hooks/pre-commit
echo "Pre-commit hook configured with executable $executable_name."
}

backup_hooks() {
    local backup_dir=".git/hooks_backup"

    mkdir -p "$backup_dir"

    if cp .git/hooks/* "$backup_dir"/; then
        echo "The hooks have been saved in $backup_dir"
    else
        echo "Error saving hooks."
    fi
}

restore_hooks() {
    local backup_dir=".git/hooks_backup"

    if [ ! -d "$backup_dir" ]; then
        echo "No backups of hooks found."
        return 1
    fi

    if cp "$backup_dir"/* .git/hooks/; then
        echo "The hooks have been restored since $backup_dir"
    else
        echo "Error restoring hooks."
    fi
}

is_hook_configured() {
    hook_path=".git/hooks/$1"
    if [ -f "$hook_path" ] && [ -s "$hook_path" ]; then
        echo -e "${GREEN}$1${NO_COLOR}"
    else
        echo "$1"
    fi
}

display_hook_option() {
    local hook_number=$1
    local hook_name=$2
    local formatted_name=$(is_hook_configured $hook_name)
    echo "$hook_number. $formatted_name Configure $hook_name hook"
}

main_menu() {
    while true; do
        clear

        echo "Git Hook Manager"
        echo "================"
        display_hook_option "1" "pre-commit"
        display_hook_option "2" "pre-push"
        display_hook_option "3" "commit-msg"
        echo "4. Clear all hooks"
        echo "5. Clear specific hook by number"
        echo "6. Backup hooks"
        echo "7. Restore hooks from backup"
        echo "q. Quit"
        echo ""
        echo -n "Enter your choice: "

        read choice

        case $choice in
            1) create_pre_commit_hook ;;
            2) create_pre_push_hook ;;
            3) create_commit_msg_hook ;;
            4) clear_hooks ;;
            5)
                echo -n "Enter the number of the hook to clear: "
                read hook_number
                clear_specific_hook $hook_number
                ;;
            q)
                echo "Exiting..."
                exit 0
                ;;
            6) backup_hooks ;;
            7) restore_hooks ;;
            *) echo "Invalid option. Please try again." ;;
        esac

        echo "Press any key to return to menu..."
        read -n 1
    done
}

main_menu