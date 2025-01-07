#!/bin/sh

# Load environment variables from config file
if [ -f "/mnt/onboard/.adds/pkm/.env" ]; then
    . "/mnt/onboard/.adds/pkm/.env"
else
    echo "Error: .env file not found"
    exit 1
fi

# Define paths
EXPORT_FOLDER="/mnt/onboard/Exported Notebooks"
ARCHIVE_DIR="$EXPORT_FOLDER/ArchiveLogseq"
CURL="/mnt/onboard/.niluje/usbnet/bin/curl"
JQ_BIN="/mnt/onboard/.niluje/usbnet/bin/jq"

# Set up directories
mkdir -p "$ARCHIVE_DIR"

# Function to make GitHub API requests
github_api_request() {
    local method="$1"
    local url="$2"
    local data="$3"
    "$CURL" -s -L -X "$method" \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        ${data:+-d "$data"} \
        "$url"
}

# Function to upload file to GitHub
upload_to_github() {
    local file_path="$1"
    local github_path="$2"
    local response sha JSON_DATA

    response=$(github_api_request GET "https://api.github.com/repos/$OWNER/$REPO/contents/$github_path")
    sha=$(echo "$response" | grep -o '"sha": "[^"]*"' | cut -d'"' -f4)
    ENCODED_CONTENT=$(openssl base64 -A < "$file_path") || return 1

    JSON_DATA="{\"message\": \"$( [ -n "$sha" ] && echo "Update" || echo "Create" ) notebook $(date '+%Y-%m-%d')\", \"content\": \"$ENCODED_CONTENT\"${sha:+, \"sha\": \"$sha\"}}"
    
    update_response=$(github_api_request PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$github_path" "$JSON_DATA")
    echo "$update_response" | grep -q '"content":'
}

# Process TXT files starting with "Log"
for file in "$EXPORT_FOLDER"/Log*.txt; do
    [ -f "$file" ] || continue

    CONTENT=$(cat "$file")
    DATE=$(date "+%Y_%m_%d")
    MARKDOWN_FILE="${DATE}.md"
    TEMP_FILE="$EXPORT_FOLDER/$MARKDOWN_FILE"

    existing_content=$(github_api_request GET "https://api.github.com/repos/$OWNER/$REPO/contents/journals/$MARKDOWN_FILE")
    
    if echo "$existing_content" | grep -q '"content":'; then
        TEMP_EXISTING="$EXPORT_FOLDER/.temp_existing"
        echo "$existing_content" | "$JQ_BIN" -r '.content' | base64 -d > "$TEMP_EXISTING" || continue
        cat "$TEMP_EXISTING" > "$TEMP_FILE"
        rm -f "$TEMP_EXISTING"
        [ -s "$TEMP_FILE" ] && [ "$(tail -c1 "$TEMP_FILE")" != "" ] && echo "" >> "$TEMP_FILE"
        grep -Fq "- $CONTENT #Kobo" "$TEMP_FILE" || echo "- $CONTENT #Kobo" >> "$TEMP_FILE"
    else
        echo "- $CONTENT #Kobo" > "$TEMP_FILE"
    fi

    if upload_to_github "$TEMP_FILE" "journals/$MARKDOWN_FILE"; then
        mv "$file" "$ARCHIVE_DIR/"
    fi

    rm -f "$TEMP_FILE"
done
