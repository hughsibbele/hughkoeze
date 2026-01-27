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
      # Validate: must be exactly 4 digits and a reasonable year (1900-2099)
      if [[ "$extracted" =~ ^(19|20)[0-9]{2}$ ]]; then
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

# Generate thumbnails (800px max dimension, 75% JPEG quality)
echo "Generating thumbnails..."
THUMB_DIR="images/photography/thumbnails"
mkdir -p "$THUMB_DIR"

thumb_count=0
while IFS= read -r file; do
  if [ -n "$file" ]; then
    filename=$(basename "$file")
    out="$THUMB_DIR/$filename"
    if [ ! -f "$out" ] || [ "$file" -nt "$out" ]; then
      sips -Z 800 "$file" --out "$out" > /dev/null 2>&1
      sips -s formatOptions 75 "$out" --out "$out" > /dev/null 2>&1
      thumb_count=$((thumb_count + 1))
    fi
  fi
done <<< "$files"

# Remove thumbnails for deleted photos
for thumb in "$THUMB_DIR"/*; do
  [ -f "$thumb" ] || continue
  original="images/photography/$(basename "$thumb")"
  if [ ! -f "$original" ]; then
    rm "$thumb"
    echo "  Removed orphaned thumbnail: $(basename "$thumb")"
  fi
done

echo "Generated $thumb_count new thumbnails ($(ls "$THUMB_DIR" | wc -l | tr -d ' ') total)"
