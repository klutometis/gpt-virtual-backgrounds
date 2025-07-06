#!/usr/bin/env bash

# Where to fetch the .ics calendar
ICAL_URL="https://calendar.google.com/calendar/ical/melissagoldtoronto%40gmail.com/public/basic.ics"

# Extract today's date in YYYYMMDD format
DATE=$(date +"%Y%m%d")

# Extract relevant calendar entries (SUMMARY fields) for today
EVENTS=$(curl -s "$ICAL_URL" \
  | awk -v today="$DATE" '
  BEGIN { RS="BEGIN:VEVENT"; FS="\n" }
  $0 ~ "DTSTART.*"today {
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^SUMMARY/) {
        gsub(/^SUMMARY:/, "", $i)
        print $i
      }
    }
  }' | paste -sd '; ' -)

# If no events found, fall back to Apollo
[ -z "$EVENTS" ] && EVENTS="Apollo"

# Create temporary file for the prompt
PROMPT_FILE=$(mktemp --suffix=.prompt)

# Write multi-line prompt to temp file
cat > "$PROMPT_FILE" << EOF
The eternal feminine, *das ewig Weibliche*, as it appears on this day—$DATE.

Calendar context: $EVENTS

Generate a symbolic, mythically resonant image reflecting feminine divinity:
beauty, mystery, mathematical harmony, and archetypal presence.

Avoid literal depiction. Emphasize atmosphere, elegance, geometry, and mythic allusion.
EOF

# Get API key
API_KEY=$(pass platform.openai.com/api-key)

# Call background.sh with the prompt file
background \
  --api_key "$API_KEY" \
  --prompt_file "$PROMPT_FILE" \
  "$@"
