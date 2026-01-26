#!/bin/bash

# Update expedition photo manifests
# Run this after adding/removing photos from expedition folders

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Updating expedition photo manifests..."

# Episcopal expeditions
EPISCOPAL_DIR="$ROOT_DIR/images/cv/expeditions/episcopal"
EPISCOPAL_JSON="$ROOT_DIR/data/expeditions-episcopal.json"

if [ -d "$EPISCOPAL_DIR" ]; then
    (
        echo "["
        first=true
        shopt -s nullglob nocaseglob
        for f in "$EPISCOPAL_DIR"/*.jpg "$EPISCOPAL_DIR"/*.jpeg "$EPISCOPAL_DIR"/*.png; do
            if [ -f "$f" ]; then
                filename=$(basename "$f")
                if [ "$first" = true ]; then
                    first=false
                else
                    echo ","
                fi
                printf '  {"file": "%s"}' "$filename"
            fi
        done
        echo ""
        echo "]"
    ) > "$EPISCOPAL_JSON"
fi

echo "  Episcopal: $(grep -c '"file"' "$EPISCOPAL_JSON" 2>/dev/null || echo 0) photos"

# Cape Henry expeditions
CAPE_HENRY_DIR="$ROOT_DIR/images/cv/expeditions/cape-henry"
CAPE_HENRY_JSON="$ROOT_DIR/data/expeditions-cape-henry.json"

if [ -d "$CAPE_HENRY_DIR" ]; then
    (
        echo "["
        first=true
        shopt -s nullglob nocaseglob
        for f in "$CAPE_HENRY_DIR"/*.jpg "$CAPE_HENRY_DIR"/*.jpeg "$CAPE_HENRY_DIR"/*.png; do
            if [ -f "$f" ]; then
                filename=$(basename "$f")
                if [ "$first" = true ]; then
                    first=false
                else
                    echo ","
                fi
                printf '  {"file": "%s"}' "$filename"
            fi
        done
        echo ""
        echo "]"
    ) > "$CAPE_HENRY_JSON"
fi

echo "  Cape Henry: $(grep -c '"file"' "$CAPE_HENRY_JSON" 2>/dev/null || echo 0) photos"

echo "Done!"
