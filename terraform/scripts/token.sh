#! /usr/bin/env bash

set -euo pipefail

INPUT="$(cat)"

if [[ -z "$INPUT" ]]; then
  echo "No input provided"
  exit 1
fi

TOKEN=$(echo "$INPUT" | jq -r '.token')
URL=$(echo "$INPUT" | jq -r '.url')

response=$(curl -sk --fail-with-body -X POST \
  "https://$URL/oauth/provider/token" \
  -H "Accept: application/json" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=refresh_token" \
  --data-urlencode "refresh_token=$TOKEN")

echo "$response"

access_token="$(echo "$response" | jq -r '.access_token // empty')"

if [ -z "$access_token" ]; then
    echo "$response" >&2
    exit 1
fi

jq -n --arg access_token "$access_token" '{access_token:$access_token}'