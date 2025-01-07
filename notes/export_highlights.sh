#!/bin/sh

NOTES="/mnt/onboard/.adds/notes"
EXPORT_FOLDER="/mnt/onboard/Exported Annotations"
EXPORT="$EXPORT_FOLDER/notes-$(date "+%Y-%m-%d").md"
KEEP=21

DB="/mnt/onboard/.kobo/KoboReader.sqlite"
SQLITE="${NOTES}/sqlite3"

# Set up environment
LD_LIBRARY_PATH="${NOTES}/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH

# Create export directory
mkdir -p "$(dirname "$EXPORT")"

# Initialize export file
echo -e "# Kobo Notes\n" > $EXPORT
echo -e "*$(date -R)*\n" >> $EXPORT
echo -e "## Highlights\n" >> $EXPORT

# Load environment variables from config file
if [ -f "/mnt/onboard/.adds/pkm/.env" ]; then
    . "/mnt/onboard/.adds/pkm/.env"
else
    echo "Error: .env file not found"
    exit 1
fi

# Verify required variables exist
if [ -z "$GITHUB_TOKEN" ] || [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$BRANCH" ]; then
    echo "Error: Required variables not set in config.txt (GITHUB_TOKEN, OWNER, REPO, BRANCH)"
    exit 1
fi

# SQL query directly on the database
SQL="SELECT DISTINCT TRIM(
  CASE
    WHEN b.Type = 'highlight' THEN
      '- ' || REPLACE(
        REPLACE(
          REPLACE(
            TRIM(TRIM(TRIM(b.Text), char(9)), char(10)),
            char(9), ''
          ),
          char(10), ' '
        ),
        '  ', ' '
      )
      || char(10)
      || '    - ' || c.Title || COALESCE(', ' || c.Attribution, '') || ' - ' || datetime(b.dateCreated)
      || CASE 
         WHEN b.Annotation IS NOT NULL AND b.Annotation != '' 
         THEN char(10) || '    - ' || REPLACE(b.Annotation, char(10), ' ') 
         ELSE '' 
         END
      || char(10, 10)
    ELSE
      '### ' ||
      CASE
        WHEN b.Type = 'dogear' THEN char(128278, 32)
        WHEN b.Type = 'note' THEN char(9999, 32)
      END
      || c.Title || ', ' || COALESCE(c.Attribution, 'N/A') || char(10, 10, 42)
      || datetime(b.dateCreated) || char(42, 92, 10)
      || COALESCE(c1.Title, '') || char(10, 10, 62, 32) ||
      CASE
        WHEN b.Type = 'dogear' THEN
          COALESCE(ContextString, 'No context available') || char(8230, 10)
        ELSE
          REPLACE(
            REPLACE(
              TRIM(
                TRIM(
                  TRIM(b.Text),
                  char(9)
                ),
                char(10)
              ),
              char(9), ''
            ),
            char(10), char(10, 62, 32, 10, 62, 32))
          || char(10, 10)
          || COALESCE(b.Annotation, '') || char(10)
      END
  END, char(10)
  ) || char(10, 10)
  FROM Bookmark b
    INNER JOIN content c ON b.VolumeID = c.ContentID
    LEFT OUTER JOIN content c1 ON (c1.ContentId LIKE b.ContentId || '%')
  ORDER BY c.Title ASC,
           c.VolumeIndex ASC,
           b.ChapterProgress ASC,
           b.DateCreated ASC;"

$SQLITE "$DB" "$SQL" >> $EXPORT

echo -e "## Book progress\n" >> $EXPORT
echo -e "Currently reading:\n" >> $EXPORT

SQL="SELECT
  '- ' || c.Title || COALESCE(', ' || c.Attribution, '')
  || ' (' || COALESCE(c1.Title || ', ', '') || c.___PercentRead || '% read' || ')'
  FROM Content c
  LEFT OUTER JOIN Content c1 ON (
    c.ContentID = c1.BookID
    AND c1.ContentType = 899
    AND REPLACE(c1.ContentID, '!', '/') LIKE
      '%' || SUBSTR(c.ChapterIDBookmarked, 1, INSTR(c.ChapterIDBookmarked, '#') + INSTR(c.ChapterIDBookmarked, '?') - 1) || '%'
  )
  WHERE c.ContentType = 6
    AND c.ReadStatus = 1
    AND c.IsDownloaded = 'true'
  ORDER BY c.___PercentRead DESC,
           c.Title ASC,
           c.Attribution ASC;"

$SQLITE "$DB" "$SQL" >> $EXPORT

# Clean up old notes
cd "$EXPORT_FOLDER"
for i in $(ls -v notes* | head -n -$KEEP); do
  rm "$i"
done

# Helper function for GitHub API calls
github_api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    local CURL="/mnt/onboard/.niluje/usbnet/bin/curl"
    
    [ ! -x "$CURL" ] && return 1
    
    $CURL -s -L \
        -X "$method" \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        ${data:+-d "$data"} \
        "https://api.github.com/$endpoint"
}

# Upload to GitHub function
upload_to_github() {
    local file_path="pages/highlights.md"
    
    [ ! -f "$EXPORT" ] && return 1
    
    # Encode content
    local encoded_content=$(openssl base64 -A < "$EXPORT") || return 1
    
    # Get existing file SHA
    local response=$(github_api_call "GET" "repos/$OWNER/$REPO/contents/$file_path")
    local sha=$(echo "$response" | grep -o '"sha": "[^"]*"' | cut -d'"' -f4)
    
    # Prepare and send update
    local json_data
    if [ -n "$sha" ]; then
        json_data="{\"message\": \"Update notes $(date '+%Y-%m-%d')\", \"content\": \"$encoded_content\", \"sha\": \"$sha\"}"
    else
        json_data="{\"message\": \"Update notes $(date '+%Y-%m-%d')\", \"content\": \"$encoded_content\"}"
    fi
    
    github_api_call "PUT" "repos/$OWNER/$REPO/contents/$file_path" "$json_data"
}

# Call the upload function
upload_to_github