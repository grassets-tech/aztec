#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

DIR="$1"

# Static values to insert
PUBLISHER=""
COINBASE=""

# Ensure jq is installed
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq not found. Please install it (e.g., sudo apt install jq)"
  exit 1
fi

# Find all JSON files
mapfile -t FILES < <(find "$DIR" -maxdepth 1 -type f -regextype posix-extended -regex '.*/keystore-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]+\.json$' | sort)

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No JSON files found in $DIR"
  exit 0
fi

for FILE in "${FILES[@]}"; do
  echo "Processing: $FILE"

  # Use jq to insert the fields in each validator object
  jq --arg publisher "$PUBLISHER" --arg coinbase "$COINBASE" '
    .validators |= map(
      . + {
        publisher: [$publisher],
        coinbase: $coinbase
      } | 
      {attester, publisher, coinbase, feeRecipient}
    )
  ' "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"

  echo "✅ Updated: $FILE"
done

echo "All files updated successfully."

