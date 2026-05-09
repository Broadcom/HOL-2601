#! /usr/bin/env bash

set -euo pipefail

INPUT="$(cat)"

if [[ -z "$INPUT" ]]; then
  echo "No input provided"
  exit 1
fi

token=$(echo "$INPUT" | jq -r '.token')
url=$(echo "$INPUT" | jq -r '.url')

response=$(curl -sk --fail-with-body -X POST \
    "https://${url}/oauth/provider/token" \
    -H "Accept: application/json" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "grant_type=refresh_token" \
    --data-urlencode "refresh_token=${token}")

access_token="$(echo "$response" | jq -r '.access_token // empty')"

jq -n \
  --arg access_token "$access_token" \
  '{
    access_token: $access_token
  }'
