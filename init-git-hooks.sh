#!/bin/bash

GREEN="\033[0;32m"
NO_COLOR="\033[0m"

# Check if the .git directory exists
if [ ! -d ".git" ]; then
    echo "This is not a Git repository. Please run this script at the root of a Git repository."
    exit 1
fi

clear_specific_hook() {
    hook_name=$1
    hook_path=".git/hooks/$hook_name"

    if [ -f "$hook_path" ]; then
        rm -f "$hook_path"
        echo "Hook '$hook_name' has been cleared."
    else
        echo "Hook '$hook_name' not found or already cleared."
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

create_pre-push_hook() {
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

create_commit-msg_hook() {
    cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

if ! grep -qE '^\[(ADD|FIX|EDIT|DEL)\]' "$1"; then
    echo "Commit message does not follow the required format ([ADD], [FIX], [EDIT] or [DEL]):"
    exit 1
fi
EOF
    chmod +x .git/hooks/commit-msg
    echo "Commit-msg hook configured."
}

clear_hooks() {
    rm -f .git/hooks/pre-commit .git/hooks/pre-push .git/hooks/commit-msg
    echo "All configured hooks have been cleared."
}

# Function to create a pre-commit hook
create_pre-commit_hook() {
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "Running 'make' to build the project..."
make
if [ $? -ne 0 ]; then
    echo "Build failed. Please correct the errors before committing."
    exit 1
fi

executable="your_executable_name" # Replace with your executable's name

if [ ! -f "$executable" ]; then
    echo "The executable '$executable' was not found. Please check your Makefile."
    make fclean
    exit 1
fi

echo "Executable '$executable' successfully built."

make fclean
if [ $? -ne 0 ]; then
    echo "make fclean failed."
    exit 1
fi

echo "Cleanup successful."
exit 0
EOF
    chmod +x .git/hooks/pre-commit
    echo "Pre-commit hook configured."
}

hook_created=0

if [ "$1" = "clear" ]; then
    clear_hooks
    hook_created=1
elif [ "$1" = "clear-one" ]; then
    if [ -n "$2" ]; then
        clear_specific_hook "$2"
        hook_created=1
    else
        echo "Please specify a hook name to clear."
        exit 1
    fi
else
    for hook in pre-commit pre-push commit-msg; do
        if [ "$1" = "$hook" ]; then
            create_${hook}_hook
            hook_created=1
            break
        fi
    done
fi

# Display usage only if no action was taken
if [ "$hook_created" -eq 0 ]; then
    echo "Usage: $0 [pre-commit | pre-push | commit-msg | clear | clear-one <hook_name>]"
    exit 0
else
    echo "Usage: $0 [$(is_hook_configured pre-commit) | \
$(is_hook_configured pre-push) | \
$(is_hook_configured commit-msg) | \
clear | \
clear-one <hook_name>]"
fi
