#!/usr/bin/env bash

# Get script directory (works even with symlinks)
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Add bashlog
. "${SCRIPT_DIR}/../lib/bashlog/log.sh"

# Where to fetch the .ics calendar
ICAL_URL="https://calendar.google.com/calendar/ical/melissagoldtoronto%40gmail.com/public/basic.ics"

# Extract today's date in YYYYMMDD format
DATE=$(date +"%Y%m%d")
log info "Looking for events on date: ${DATE}" >&2

# Add time context
HOUR=$(date +"%H")
TIME_CONTEXT=""
if [ "$HOUR" -lt 6 ]; then
  TIME_CONTEXT="in the pre-dawn darkness, when night goddesses hold sway"
elif [ "$HOUR" -lt 12 ]; then
  TIME_CONTEXT="in the morning light, as dawn goddesses awaken"
elif [ "$HOUR" -lt 18 ]; then
  TIME_CONTEXT="in the afternoon radiance, under the sun's feminine aspect"
else
  TIME_CONTEXT="in the evening twilight, as dusk goddesses emerge"
fi

# Add ddate if available
DDATE_INFO=""
if command -v ddate >/dev/null 2>&1; then
  DDATE_INFO="Discordian date: $(ddate)"
fi

# Extract relevant calendar entries (SUMMARY fields) for today
EVENTS=$(curl -s "$ICAL_URL" \
  | awk -v today="$DATE" '
  BEGIN { RS="BEGIN:VEVENT"; FS="\n" }
  $0 ~ "DTSTART[^:]*:"today {
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^SUMMARY/) {
        gsub(/^SUMMARY:/, "", $i)
        print $i
      }
    }
  }' | paste -sd '; ' -)

# If no events found, fall back to Apollo
log info "Raw EVENTS before fallback: '${EVENTS:0:200}...'" >&2
log info "EVENTS length: $(echo -n "$EVENTS" | wc -c)" >&2
[ -z "$EVENTS" ] && EVENTS="Apollo"
log info "Final EVENTS variable: '${EVENTS}'" >&2

# Create temporary file for the prompt
PROMPT_FILE=$(mktemp --suffix=.prompt)

# Add some randomness/variation elements
VARIATION_ELEMENTS=("moonlight" "starlight" "dawn mist" "ocean spray" "golden hour" "twilight shadows")
RANDOM_ELEMENT=${VARIATION_ELEMENTS[$RANDOM % ${#VARIATION_ELEMENTS[@]}]}

# Write multi-line prompt to temp file
cat > "$PROMPT_FILE" << EOF
The eternal feminine, *das ewig Weibliche*, as it appears on this day—$DATE $TIME_CONTEXT.

Ancient Greek festival context: $EVENTS
$DDATE_INFO

Generate a captivating image of feminine divinity with siren-like allure.
Incorporate $RANDOM_ELEMENT for atmospheric variation.

Be creative and surprising while maintaining divine beauty and mystery.
Vary the composition, colors, and mood - each generation should feel unique.
Surprise me with your interpretation.
EOF

# Get API key
API_KEY=$(pass platform.openai.com/api-key)

# Call background.sh with the prompt file
"${SCRIPT_DIR}/background.sh" \
  --api_key "$API_KEY" \
  --prompt_file "$PROMPT_FILE" \
  "$@"
