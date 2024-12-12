#!/bin/bash

# Configuration
REPO_PATH="$1"  # Pass the repository path as first argument
LOG_FILE="git-commit.log"

# Function to get current timestamp
get_timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Function for logging
log_message() {
    echo "$(get_timestamp) - $1"
}

# Check if repository path is provided
if [ -z "$REPO_PATH" ]; then
    log_message "Error: Repository path not provided"
    echo "Usage: $0 <repository-path>"
    exit 1
fi

# Check if the directory exists
if [ ! -d "$REPO_PATH" ]; then
    log_message "Error: Directory $REPO_PATH does not exist"
    exit 1
fi

# Change to the repository directory
cd "$REPO_PATH" || {
    log_message "Error: Cannot change to directory $REPO_PATH"
    exit 1
}

# Check if it's a git repository
if [ ! -d ".git" ]; then
    log_message "Error: $REPO_PATH is not a git repository"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Check for changes
if git status --porcelain | grep -q '^'; then
    # There are changes to commit
    timestamp=$(get_timestamp)

    # Try to add all changes
    if git add .; then
        log_message "Changes staged successfully"

        # Try to commit
        if git commit -m "Commit: $timestamp"; then
            log_message "Successfully committed changes on branch $CURRENT_BRANCH"

            # Try to push changes
            if git push origin "$CURRENT_BRANCH"; then
                log_message "Successfully pushed changes to remote"
            else
                log_message "Error: Failed to push changes to remote"
            fi
        else
            log_message "Error: Failed to commit changes"
        fi
    else
        log_message "Error: Failed to stage changes"
    fi
else
    log_message "No changes detected in repository"
fi
