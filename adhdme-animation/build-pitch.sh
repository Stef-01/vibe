#!/usr/bin/env bash
# Build the ADHDme pitch end to end: narration, frames, music, mix.
#   ./build-pitch.sh            full build -> out/adhdme-pitch-final.mp4
#   ./build-pitch.sh --grid     just the 48-frame grid sheet (after the narration timing exists)
# Needs: node + npm i (puppeteer-core), Chrome or Chromium, ffmpeg, python3 with numpy, and piper-tts with a
# voice in voices/ (see README).
set -euo pipefail
cd "$(dirname "$0")"
python3 voice.py adhdme-pitch-narration.json                       # out/voice/*.wav, out/voice.wav, adhdme-pitch-voice.js
if [[ "${1:-}" == "--grid" ]]; then node render.mjs adhdme-pitch.html --ar 16:9 --width 1920 --grid 48; exit; fi
node render.mjs adhdme-pitch.html --ar 16:9 --width 1920            # out/adhdme-pitch.mp4 + contact sheet
node score.mjs adhdme-pitch.html --out out/score-pitch.wav          # the music, from the same timeline
# music ducked under the narration, then both mixed
ffmpeg -v error -y -i out/adhdme-pitch.mp4 -i out/score-pitch.wav -i out/voice.wav \
  -filter_complex "[2:a]asplit=2[v1][v2];[1:a][v1]sidechaincompress=threshold=0.02:ratio=6:attack=40:release=600:makeup=1[m];[m]volume=0.9[m2];[m2][v2]amix=inputs=2:duration=first:normalize=0[a]" \
  -map 0:v -map "[a]" -c:v libx264 -crf 23 -preset slow -pix_fmt yuv420p -movflags +faststart -c:a aac -b:a 192k -shortest out/adhdme-pitch-final.mp4   # crf 23 keeps the halftone under ~25 MB
echo "out/adhdme-pitch-final.mp4"
