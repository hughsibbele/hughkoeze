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

# Convert WebP and HEIC originals to JPEG.
# macOS 'sips' (used for thumbnails below) cannot read WebP, and browsers
# cannot display HEIC, so both formats would silently vanish from the gallery.
# ImageMagick ('brew install imagemagick') handles WebP; sips handles HEIC.
converted=0
while IFS= read -r file; do
  [ -n "$file" ] || continue
  base="${file%.*}"
  out="$base.jpg"
  if [ -e "$out" ]; then
    echo "  $(basename "$file") was already converted to $(basename "$out"); delete the original."
    continue
  fi
  case "$file" in
    *.webp|*.WEBP)
      if command -v magick &> /dev/null; then
        magick "$file" -quality 92 "$out" && converted=$((converted + 1)) \
          && echo "  Converted $(basename "$file") -> $(basename "$out")"
      else
        echo "  WARNING: $(basename "$file") is WebP and ImageMagick is not installed; skipping. Run: brew install imagemagick"
      fi
      ;;
    *.heic|*.HEIC)
      sips -s format jpeg "$file" --out "$out" > /dev/null 2>&1 && converted=$((converted + 1)) \
        && echo "  Converted $(basename "$file") -> $(basename "$out")"
      ;;
  esac
done <<< "$(find images/photography -maxdepth 1 -type f \( -iname "*.webp" -o -iname "*.heic" \) | sort)"
if [ "$converted" -gt 0 ]; then
  echo "Converted $converted file(s) to JPEG. The originals are still in the folder;"
  echo "delete them (or move them out) so they are not re-converted next time."
fi

# Find all image files the gallery can display and thumbnail
files=$(find images/photography -maxdepth 1 -type f \( \
  -iname "*.jpg" -o \
  -iname "*.jpeg" -o \
  -iname "*.png" -o \
  -iname "*.gif" \
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
failed_thumbs=0
while IFS= read -r file; do
  if [ -n "$file" ]; then
    filename=$(basename "$file")
    out="$THUMB_DIR/$filename"
    if [ ! -f "$out" ] || [ "$file" -nt "$out" ]; then
      if sips -Z 800 "$file" --out "$out" > /dev/null 2>&1; then
        sips -s formatOptions 75 "$out" --out "$out" > /dev/null 2>&1
        thumb_count=$((thumb_count + 1))
      else
        echo "  ERROR: could not create thumbnail for $filename (the gallery will not show it)"
        failed_thumbs=$((failed_thumbs + 1))
      fi
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
if [ "$failed_thumbs" -gt 0 ]; then
  echo "WARNING: $failed_thumbs photo(s) have no thumbnail and will not appear in the gallery."
  exit 1
fi
