#!/bin/bash
# 
# This script fetches all project names from the Doppler API and returns them as JSON
# for use a Terraform external data source.
#
# Requires DOPPLER_TOKEN environment variable
#
# Returns JSON in format: {"projects": ["project1", "project2", ...]}

set -euo pipefail

# Check for required tools
command -v curl >/dev/null 2>&1 || { echo >&2 "Error: curl is required but not installed."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "Error: jq is required but not installed."; exit 1; }

if [ -z "${DOPPLER_TOKEN:-}" ]; then
    echo >&2 "Error: DOPPLER_TOKEN environment variable is required"
    exit 1
fi

BASE_URL="https://api.doppler.com/v3"
HEADERS=(
    -H "accept: application/json"
    -H "authorization: Bearer $DOPPLER_TOKEN"
)

fetch_projects_page() {
    local page=$1
    local per_page=${2:-100}
    local url="$BASE_URL/projects?page=$page&per_page=$per_page"
    
    local response
    response=$(curl -s -w "\n%{http_code}" "${HEADERS[@]}" "$url")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -ne 200 ]; then
        echo >&2 "Error: Failed to fetch projects from Doppler API (page $page)"
        echo >&2 "HTTP Status: $http_code"
        echo >&2 "Response: $body"
        exit 1
    fi
    
    echo "$body"
}

fetch_all_projects() {
    local all_projects="[]"
    local page=1
    local per_page=100
    
    while true; do
        local response
        response=$(fetch_projects_page "$page" "$per_page")
        
        # Debug: Show raw response (uncomment for debugging)
        # echo >&2 "Debug: API response for page $page: $response"
        
        # Extract projects from response
        local projects
        projects=$(echo "$response" | jq -r '.projects // []')
        
        # Check if we got any projects
        local project_count
        project_count=$(echo "$projects" | jq 'length')
        
        # Handle case where project_count might be empty or null
        if [ -z "$project_count" ] || [ "$project_count" -eq 0 ]; then
            break
        fi
        
        # Merge projects into all_projects array
        all_projects=$(echo "$all_projects $projects" | jq -s 'add')
        
        # If we got fewer than per_page results, we're done
        if [ -n "$project_count" ] && [ "$project_count" -lt "$per_page" ]; then
            break
        fi
        
        page=$((page + 1))
    done
    
    echo "$all_projects"
}

# Function to extract project names from project objects
extract_project_names() {
    local projects=$1
    echo "$projects" | jq -r '[.[].name] | sort'
}

main() {
    local all_projects
    all_projects=$(fetch_all_projects)
    
    local project_names
    project_names=$(extract_project_names "$all_projects")
    
    # Return in format expected by Terraform external data source
    jq -n --argjson projects "$project_names" '{"projects": $projects}'
}

main