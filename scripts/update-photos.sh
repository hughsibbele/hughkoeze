#!/bin/bash
# Generates photos.json manifest from images/photography folder
# Extracts year from EXIF DateTimeOriginal when available
# Run this after adding/removing photos: ./scripts/update-photos.sh

cd "$(dirname "$0")/.."

# Check for exiftool
if ! command -v exiftool &> /dev/null; then
  echo "Warning: exiftool not found. Install with: brew install exiftool"
  echo "Years will not be extracted."
  HAS_EXIFTOOL=false
else
  HAS_EXIFTOOL=true
fi

# Find all image files
files=$(find images/photography -maxdepth 1 -type f \( \
  -iname "*.jpg" -o \
  -iname "*.jpeg" -o \
  -iname "*.png" -o \
  -iname "*.gif" -o \
  -iname "*.webp" \
\) | sort)

# Build JSON array
echo "[" > photos.json

first=true
count=0
while IFS= read -r file; do
  if [ -n "$file" ]; then
    filename=$(basename "$file")

    # Extract year from EXIF if available (try multiple date fields)
    year="null"
    if [ "$HAS_EXIFTOOL" = true ]; then
      extracted=$(exiftool -DateTimeOriginal -CreateDate -ModifyDate -d "%Y" -s -s -s "$file" 2>/dev/null | head -1)
      if [ -n "$extracted" ]; then
        year="$extracted"
      fi
    fi

    if [ "$first" = true ]; then
      first=false
    else
      echo "," >> photos.json
    fi

    if [ "$year" = "null" ]; then
      printf '  {"file": "%s", "year": null}' "$filename" >> photos.json
    else
      printf '  {"file": "%s", "year": %s}' "$filename" "$year" >> photos.json
    fi

    count=$((count + 1))
  fi
done <<< "$files"

echo "" >> photos.json
echo "]" >> photos.json

echo "Updated photos.json with $count photos"
