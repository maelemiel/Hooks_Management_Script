#!/bin/bash

in_main_loop=false

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
    echo "1. Run tests before pushing with all test passed"
    echo "2. Run tests before pushing with a certain percentage passed"
    echo "3. Run tests before pushing with a percentage greater than or equal to the last test run"
    echo "4. Run tests before pushing with no errors in the epitech standard"
    echo -n "Enter the number of the choice you want to make: "
    read choice_pre_push
    if [ "$choice_pre_push" = "1" ]; then
        create_pre_push_hook_1
    elif [ "$choice_pre_push" = "2" ]; then
        create_pre_push_hook_2
    elif [ "$choice_pre_push" = "3" ]; then
        create_pre_push_hook_3
    elif [ "$choice_pre_push" = "4" ]; then
        create_pre_push_hook_4
    else
        echo "Invalid option. Please try again."
    fi
}

create_pre_push_hook_1() {
    cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

echo "Running tests before push..."
make tests_run
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

create_pre_push_hook_2() {
    echo -n "Enter the percentage of tests that must pass: "
    read percentage
    cat > .git/hooks/pre-push << EOF
#!/bin/bash

echo "Running tests before push..."
make tests_run > .git/hooks/tmp_output_prepush.txt
if [ \$? -ne 0 ]; then
    echo "Tests failed. Fix the issues before pushing."
    exit 1
fi
line=\$(grep 'Synthesis: Tested:' .git/hooks/tmp_output_prepush.txt)
tested=\$(echo "\$line" | awk -F'[:|]' '{print $3}')
passing=\$(echo "\$line" | awk -F'[:|]' '{print $5}')

if [ \$tested -ne 0 ]; then
    percentage_passed=\$((100 * \$passing / \$tested))
else
    percentage_passed=0
fi

if [ \$percentage_passed -lt $percentage ]; then
    echo "Only \$percentage_passed% of tests passed. Fix the issues before pushing."
    exit 1
fi
echo "\$percentage_passed% of tests passed."
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

    cat > .git/hooks/commit-msg << EOF
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
    executable_name="default"
    echo -n "Enter the name of the executable to build before committing (default: 'default'): "
    read executable_name

    if [ -z "$executable_name" ]; then
        echo "No executable name specified for the pre-commit hook. Use of 'default."
        executable_name="default"
    fi
    echo $executable_name > .git/hooks/executable_name.tmp
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
executable_name=$(cat .git/hooks/executable_name.tmp)
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

    if find .git/hooks -maxdepth 1 -type f -exec cp {} "$backup_dir" \; ; then
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

    if find "$backup_dir" -maxdepth 1 -type f -exec cp {} .git/hooks \; ; then
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

show_help() {
    local in_main_loop=$1
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  1                 Configure pre-commit hook."
    echo "  2                 Configure pre-push hook."
    echo "  3                 Configure commit-msg hook."
    echo "  4                 Clear all hooks."
    echo "  5                 Clear specific hook by number."
    echo "  6                 Backup hooks."
    echo "  7                 Restore hooks from backup."
    echo "  h                 Display this help message and exit."
    echo "  q                 Quit the script."
    if [ "$in_main_loop" = false ]; then
        echo "Run without options to enter the interactive Git Hook Manager menu."
    fi
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help false
    exit 0
fi

main_menu() {
    in_main_loop=true
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
        echo "h. show help"
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
            6) backup_hooks ;;
            7) restore_hooks ;;
            h) show_help "$in_main_loop" ;;
            q)
                echo "Exiting..."
                exit 0
                ;;
            *) echo "Invalid option. Please try again." ;;
        esac

        echo "Press any key to return to menu..."
        read -n 1
    done
}

main_menu