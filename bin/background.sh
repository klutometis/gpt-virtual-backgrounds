#!/usr/bin/env sh
#
# Generate a virtual background à la GPT; do with a little `while true` and
# `sleep` action to spice up life.
#
. external/shflags/shflags

DEFINE_string 'api_key' '' 'API key (takes precedence over --api_key_file)'
DEFINE_string 'api_key_file' 'data/keys/openai-api.key' 'API key file'
DEFINE_string 'model' 'dall-e-3' 'GPT model'
DEFINE_string 'output' "$HOME/background.webp" 'Where to write the image'
DEFINE_string 'prompt' '' 'Prompt to use (takes precedence over --prompt_file)'
DEFINE_string 'prompt_file' 'data/prompts/math-and-music.prompt' 'Prompt file to use'
DEFINE_string 'size' '1792x1024' 'Size of the image'

function make_gpt_params() {
    # Either use --prompt or the contents of --prompt_file.
    local prompt="${FLAGS_prompt:-$(cat "${FLAGS_prompt_file}")}"

    # Fill in the JSON request-template with various params.
    jq --null-input \
       --arg model "${FLAGS_model}" \
       --arg n "1" \
       --arg prompt "${prompt}" \
       --arg size "${FLAGS_size}" \
       -f "data/scripts/gpt-params.jq"
}

function call_gpt() {
    local api_key="${FLAGS_api_key:-$(cat "${FLAGS_api_key_file}")}"

    # Invoke GPT using the above params; and locally encrypted key.
    curl -X POST "https://api.openai.com/v1/images/generations" \
         -H "Authorization: Bearer ${api_key}" \
         -H "Content-Type: application/json" \
         -d "$(make_gpt_params)"
}

function main() {
    # Temporarily keeping images around, just in case they're interesting; also,
    # makes intra-stream swaps seamless.
    local image="$(mktemp --suffix=gpt-virtual-background-XXXXXX.webp)"

    call_gpt |                  # Generate the image.
         tee /dev/stderr |      # Also divert output to user.
         jq '.data | first | .url' |    # Extract the image URL.
         xargs curl |           # Download the image
         convert - -resize "${FLAGS_size}" "${image}" # Resize and serialize.

    # Keep the original until reaped; but also copy to destination.
    cp -v "${image}" "${FLAGS_output}"
}

# Fail early.
set -e
set -o pipefail

# Parse flags.
FLAGS "$@" || exit $?
eval set -- "${FLAGS_ARGV}"

# Start!
main "$@"
