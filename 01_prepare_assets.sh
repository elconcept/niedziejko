#!/usr/bin/env bash
set -euo pipefail

mkdir -p assets/images/original
mkdir -p assets/images/web
mkdir -p assets/images/thumbs

for f in assets/images/[1-9].png; do
    [ -f "$f" ] || continue

    name="$(basename "$f" .png)"

    cp "$f" "assets/images/original/${name}.png"

    if command -v magick >/dev/null 2>&1; then
        magick "$f" \
            -strip \
            -resize 1600x1600\> \
            -quality 92 \
            "assets/images/web/${name}.jpg"

        magick "$f" \
            -strip \
            -resize 600x600^ \
            -gravity center \
            -extent 600x600 \
            -quality 88 \
            "assets/images/thumbs/${name}.jpg"

    elif command -v convert >/dev/null 2>&1; then
        convert "$f" \
            -strip \
            -resize 1600x1600\> \
            -quality 92 \
            "assets/images/web/${name}.jpg"

        convert "$f" \
            -strip \
            -resize 600x600^ \
            -gravity center \
            -extent 600x600 \
            -quality 88 \
            "assets/images/thumbs/${name}.jpg"
    else
        echo "ImageMagick nie jest zainstalowany."
        exit 1
    fi
done

cat <<MSG

Assets przygotowane:

assets/images/original/
assets/images/web/
assets/images/thumbs/

Następny krok:
02_build_css.sh

MSG
