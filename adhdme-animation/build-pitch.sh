#!/usr/bin/env bash
# Build the ADHDme pitch end to end: frames, music, mux.
#   ./build-pitch.sh              music only (the default) -> out/adhdme-pitch-final.mp4
#   ./build-pitch.sh --narrated   the narrated cut: piper reads adhdme-pitch-narration.json, the film re-times
#                                 itself to the speech, and the music is ducked under the voice
#   ./build-pitch.sh --grid       just the 48-frame grid sheet, nothing else
# Needs: node + npm i (puppeteer-core), Chrome or Chromium, ffmpeg. --narrated also needs python3 with numpy and
# piper-tts with a voice in voices/ (see README).
set -euo pipefail
cd "$(dirname "$0")"
mode="${1:-}"
q=()                                                              # the page loads the speech timing only when asked
if [[ "$mode" == "--narrated" ]]; then
  python3 voice.py adhdme-pitch-narration.json                    # out/voice/*.wav, out/voice.wav, adhdme-pitch-voice.js
  q=(--query narrated=1)
fi
if [[ "$mode" == "--grid" ]]; then node render.mjs adhdme-pitch.html --ar 16:9 --width 1920 --grid 48; exit; fi
node render.mjs adhdme-pitch.html --ar 16:9 --width 1920 ${q[@]+"${q[@]}"}   # out/adhdme-pitch.mp4 + contact sheet
node score.mjs adhdme-pitch.html --out out/score-pitch.wav ${q[@]+"${q[@]}"} # the music, from the same timeline
enc=(-c:v libx264 -crf 23 -preset slow -pix_fmt yuv420p -movflags +faststart -c:a aac -b:a 192k -shortest)   # crf 23 keeps the halftone under ~25 MB
if [[ "$mode" == "--narrated" ]]; then
  # music ducked under the narration, then both mixed
  ffmpeg -v error -y -i out/adhdme-pitch.mp4 -i out/score-pitch.wav -i out/voice.wav \
    -filter_complex "[2:a]asplit=2[v1][v2];[1:a][v1]sidechaincompress=threshold=0.02:ratio=6:attack=40:release=600:makeup=1[m];[m]volume=0.9[m2];[m2][v2]amix=inputs=2:duration=first:normalize=0[a]" \
    -map 0:v -map "[a]" "${enc[@]}" out/adhdme-pitch-final.mp4
else
  # the music alone, brought to a broadcast loudness
  ffmpeg -v error -y -i out/adhdme-pitch.mp4 -i out/score-pitch.wav -map 0:v -map 1:a -af loudnorm=I=-16:TP=-1.5:LRA=11 "${enc[@]}" out/adhdme-pitch-final.mp4
fi
echo "out/adhdme-pitch-final.mp4"
