#!/usr/bin/env sh
set -e
set -o pipefail

# Temporarily keeping images around, just in case they're interesting.
image="$(mktemp)"

curl -X POST "https://api.openai.com/v1/images/generations" \
     -H "Authorization: Bearer $(cat openai-api.key)" \
     -H "Content-Type: application/json" \
     -d '{
           "model": "dall-e-3",
           "prompt": "Can you create a virtual background which combines piano, rugby and lambda calculus?",
           "n": 1,
           "size": "1792x1024"
         }' | \
             tee /dev/stderr | \
             jq '.data[0].url' | \
             xargs curl | \
             convert - -resize 1920x1080 "${image}"

cp -v "${image}" ~/Downloads/background.webp
