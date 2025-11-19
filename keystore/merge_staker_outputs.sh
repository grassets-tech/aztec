#!/bin/bash
set -e

# Check if directory argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

DIR="$1"
OUTPUT_FILE="merged_staker_outputs.json"

echo "📂 Reading JSON files from: $DIR"
echo "📝 Writing merged JSON to: $OUTPUT_FILE"

# Find all matching files inside the directory
mapfile -t files < <(find "$DIR" -maxdepth 1 -type f -name "*staker_output.json" | sort)

# Check if any files were found
if [ ${#files[@]} -eq 0 ]; then
  echo "❌ No files found containing 'staker_output.json' in $DIR"
  exit 1
fi

# Start JSON array
echo "[" > "$OUTPUT_FILE"

# Loop through found files
for i in "${!files[@]}"; do
  file="${files[$i]}"
  echo "➕ Adding: $file"

  # Validate and read JSON content compactly
  content=$(jq -c '.' "$file")

  # Add comma except for last element
  if [ $i -lt $((${#files[@]} - 1)) ]; then
    echo "  $content," >> "$OUTPUT_FILE"
  else
    echo "  $content" >> "$OUTPUT_FILE"
  fi
done

# Close JSON array
echo "]" >> "$OUTPUT_FILE"

echo "✅ Successfully merged ${#files[@]} files into $OUTPUT_FILE"
