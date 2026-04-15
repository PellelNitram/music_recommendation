#!/usr/bin/env bash
set -euo pipefail

API_BASE="http://localhost:${ND_PORT}/rest"
AUTH="u=${ND_API_USER}&p=${ND_API_PASSWORD}&c=makefile&v=1.16.1&f=json"

echo "Searching for all songs..."
RESPONSE=$(curl -sf "${API_BASE}/search3?${AUTH}&query=&songCount=100")

SONG_IDS=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
songs = data.get('subsonic-response', {}).get('searchResult3', {}).get('song', [])
for s in songs:
    print(s['id'])
")

if [ -z "$SONG_IDS" ]; then
    echo "Error: No songs found. Make sure Navidrome has finished scanning."
    echo "You can trigger a scan or wait for the next scheduled scan."
    exit 1
fi

echo "$SONG_IDS"

COUNT=$(echo "$SONG_IDS" | wc -l | tr -d ' ')
echo "Found ${COUNT} songs."

# Build songId params
SONG_PARAMS=""
while IFS= read -r id; do
    SONG_PARAMS="${SONG_PARAMS}&songId=${id}"
done <<< "$SONG_IDS"

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M")
PLAYLIST_NAME="RecSys Songs ${TIMESTAMP}"
PLAYLIST_NAME_ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${PLAYLIST_NAME}'))")

echo "Creating playlist '${PLAYLIST_NAME}'..."
RESULT=$(curl -sf "${API_BASE}/createPlaylist?${AUTH}&name=${PLAYLIST_NAME_ENCODED}${SONG_PARAMS}")

STATUS=$(echo "$RESULT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('subsonic-response', {}).get('status', 'unknown'))
")

if [ "$STATUS" = "ok" ]; then
    echo "Playlist '${PLAYLIST_NAME}' created with ${COUNT} songs."
else
    echo "Error creating playlist:"
    echo "$RESULT" | python3 -m json.tool
    exit 1
fi
