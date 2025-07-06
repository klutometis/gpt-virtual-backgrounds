#!/usr/bin/env bash
#
# Generate a virtual background à la GPT; create a scene with OBS;* and add a
# little `while true` and `sleep` to spice it up mid-stream:
#
#   ./prg/gpt-virtual-backgrounds/bin/background.sh --api_key=[OpenAI API key]
#
# * https://obsproject.com/
#

# Enable error handling and exit on failure
set -euo pipefail
shopt -s nullglob

# shFlags implements Google commandline-style flags.*
#
# * https://github.com/kward/shflags
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
. "${SCRIPT_DIR}/../lib/shflags/shflags"
. "${SCRIPT_DIR}/../lib/bashlog/log.sh"

# Define flags.
DEFINE_string 'api_key' "$(pass platform.openai.com/api-key)" 'API key'
DEFINE_string 'model' 'gpt-image-1' 'GPT model'
DEFINE_string 'output' '' 'Where to write the image'
DEFINE_string 'prompt' '' 'Prompt to use (takes precedence over --prompt_file)'
DEFINE_string 'prompt_file' "${SCRIPT_DIR}/../data/prompts/math-and-music.prompt" 'Prompt file to use'
DEFINE_string 'size' '1536x1024' 'Size of the image'
DEFINE_string 'quality' 'medium' 'Quality of the image (auto, high, medium, low)'
DEFINE_string 'moderation' 'low' 'Content moderation level (auto, low)'
DEFINE_string 'output_format' 'png' 'Output format (png, jpeg, webp)'

function make_gpt_params() {
  # Either use --prompt or the contents of --prompt_file (in that order).
  local prompt="${FLAGS_prompt:-$(cat "${FLAGS_prompt_file}")}"

  log info "Using prompt: '${prompt:0:100}...'" >&2

  # Fill in the JSON request-template with various params.
  jq --null-input \
    --arg model "${FLAGS_model}" \
    --arg n "1" \
    --arg prompt "${prompt}" \
    --arg size "${FLAGS_size}" \
    --arg quality "${FLAGS_quality}" \
    --arg moderation "${FLAGS_moderation}" \
    --arg output_format "${FLAGS_output_format}" \
    -f "${SCRIPT_DIR}/../data/scripts/gpt-params.jq"
}

function call_gpt() {
  log info "Calling GPT API with model: ${FLAGS_model}" >&2

  local params=$(make_gpt_params) || {
    log error "Failed to generate GPT parameters"
    exit 1
  }

  log info "GPT parameters: ${params}" >&2

  # Invoke GPT using the above params; and locally encrypted key.
  curl -X POST "https://api.openai.com/v1/images/generations" \
    -H "Authorization: Bearer ${FLAGS_api_key}" \
    -H "Content-Type: application/json" \
    -d "${params}"
}

function main() {
  # Temporarily keeping images around, just in case they're interesting; also,
  # makes intra-stream swaps seamless.
  local image="$(mktemp --tmpdir --suffix=.${FLAGS_output_format} gpt-virtual-background-XXXXXX)"
  log info "Created temporary image file: ${image}" >&2

  local gpt_response=$(call_gpt)
  log info "GPT API call completed successfully" >&2

  log info "$(echo "${gpt_response}" | jq 'del(.data[].b64_json)')" >&2

  if echo "${gpt_response}" | jq -e '.error' > /dev/null 2>&1; then
    log error "API returned error: $(echo "${gpt_response}" | jq -r '.error.message')"
    exit 1
  fi

  local image_b64=$(echo "${gpt_response}" | jq -r '.data | first | .b64_json')
  log info "Extracted base64 image data" >&2

  echo "${image_b64}" | base64 -d > "${image}"
  log info "Decoded image to: ${image}" >&2

  # Output to stdout if no --output specified, otherwise write to file
  if [[ -n "${FLAGS_output}" ]]; then
    cp "${image}" "${FLAGS_output}"
    log info "Copied image to final destination: ${FLAGS_output}" >&2
  else
    log info "Outputting image to stdout" >&2
    cat "${image}"
  fi
}

# Parse flags.
FLAGS "$@" || exit $?
eval set -- "${FLAGS_ARGV}"

# Start!
main "$@"
