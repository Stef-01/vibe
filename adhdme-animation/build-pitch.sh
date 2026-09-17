#!/usr/bin/env bash
# Build the ADHDme pitch end to end: frames, music, mux.
#   ./build-pitch.sh            -> out/adhdme-pitch-final.mp4
#   ./build-pitch.sh --grid     just the 48-frame grid sheet, nothing else
#   ./build-pitch.sh --score    re-score and re-mux the last render (when only the music changed)
# Needs: node + npm i (puppeteer-core), Chrome or Chromium, ffmpeg.
set -euo pipefail
cd "$(dirname "$0")"
mode="${1:-}"
if [[ "$mode" == "--grid" ]]; then node render.mjs adhdme-pitch.html --ar 16:9 --width 1920 --grid 48; exit; fi
if [[ "$mode" != "--score" || ! -f out/adhdme-pitch.mp4 ]]; then node render.mjs adhdme-pitch.html --ar 16:9 --width 1920; fi   # out/adhdme-pitch.mp4 + contact sheet
node score.mjs adhdme-pitch.html --out out/score-pitch.wav        # the music, from the same timeline
# the music under the picture, brought to a broadcast loudness; crf 23 keeps the halftone under ~25 MB
ffmpeg -v error -y -i out/adhdme-pitch.mp4 -i out/score-pitch.wav -map 0:v -map 1:a -af loudnorm=I=-16:TP=-1.5:LRA=11 \
  -c:v libx264 -crf 23 -preset slow -pix_fmt yuv420p -movflags +faststart -c:a aac -b:a 192k -shortest out/adhdme-pitch-final.mp4
echo "out/adhdme-pitch-final.mp4"
