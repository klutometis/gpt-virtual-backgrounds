#!/usr/bin/env sh
set -e
set -o pipefail

function make_gpt_params() {
    jq --null-input \
       --arg model "dall-e-3" \
       --arg prompt "Can you create a simple virtual background which delights lovers of math and music? Shouldn't be too busy." \
       --arg n "1" \
       --arg size "1792x1024" \
       -f "gpt.jq"
}

# Temporarily keeping images around, just in case they're interesting; also,
# makes intra-stream swaps seamless.
image="$(mktemp --suffix=gpt-virtual-background-XXXXXX.webp)"

curl -X POST "https://api.openai.com/v1/images/generations" \
     -H "Authorization: Bearer $(cat openai-api.key)" \
     -H "Content-Type: application/json" \
     -d "$(make_gpt_params)" | \
    tee /dev/stderr | \
    jq '.data[0].url' | \
    xargs curl | \
    convert - -resize 1920x1080 "${image}"

cp -v "${image}" ~/Downloads/background.webp
