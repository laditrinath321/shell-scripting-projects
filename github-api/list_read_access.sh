#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local repo_owner="$1"
    local repo_name="$2"
    local endpoint="repos/${repo_owner}/${repo_name}/collaborators"

    # Fetch the list of collaborators on the repository
    collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"

    # Display the list of collaborators with read access
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${repo_owner}/${repo_name}."
    else
        echo "Users with read access to ${repo_owner}/${repo_name}:"
        echo "$collaborators"
    fi
}

# Function to fetch all repositories of the user
function fetch_repositories {
    local user="$1"
    local endpoint="users/${user}/repos"

    # Fetch the list of repositories owned by the user
    github_api_get "$endpoint" | jq -r '.[].name'
}

# Main script
echo "Fetching all repositories for user ${USERNAME}..."
repositories=$(fetch_repositories "$USERNAME")

if [[ -z "$repositories" ]]; then
    echo "No repositories found for user ${USERNAME}."
    exit 1
fi

# Loop through each repository and check for users with read access
for repo in $repositories; do
    echo "----------------------------------------"
    echo "Checking users with read access for repository: ${repo}"
    list_users_with_read_access "$USERNAME" "$repo"
    echo "----------------------------------------"
done

