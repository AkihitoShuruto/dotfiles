#!/usr/bin/env bash

# Detect active player (Spotify, Tauon, VLC etc.)
PLAYER=$(playerctl -l 2>/dev/null | head -n 1)

if [ -z "$PLAYER" ]; then
  rofi -e "Kein Media Player aktiv"
  exit 1
fi

CHOICE=$(echo -e "⏯ Play/Pause\n⏭ Next\n⏮ Previous\n🔊 Volume Up\n🔉 Volume Down\nℹ️ Track Info\n⏹ Stop" \
  | rofi -dmenu -i -p "🎵 Music")

case "$CHOICE" in
  "⏯ Play/Pause") playerctl play-pause ;;
  "⏭ Next") playerctl next ;;
  "⏮ Previous") playerctl previous ;;
  "🔊 Volume Up") playerctl volume 0.1+ ;;
  "🔉 Volume Down") playerctl volume 0.1- ;;
  "⏹ Stop") playerctl stop ;;
  "ℹ️ Track Info")
    INFO=$(playerctl metadata --format "{{artist}} - {{title}}")
    rofi -e "$INFO"
    ;;
esac