# ADHDme explainer animation

A 28.75 second hand-drawn explainer of what ADHDme does, why finding a GP you click
with is hard, and the value proposition from the September 2026 strategic plan deck.
Every frame is drawn by JavaScript on Canvas 2D from one HTML file, following the
[hand-drawn-canvas-animation](https://github.com/alesha-pro/tools/tree/main/skills/hand-drawn-canvas-animation)
skill: no images, no libraries, seeded textures, drawn at 12 fps and packed to 24 fps
("on twos"), with the soundtrack generated from the same timeline.

| file | what it is |
|---|---|
| `adhdme.html` | the film: brief and beat sheet, palette, puppets, twelve scenes, score |
| `core.js` | the skill's shared core (palettes, finishes, marks, reveals, player). Not edited. |
| `render.mjs` | headless Chrome renderer: grid sheet, spot frames, mp4 and contact sheet |
| `score.mjs` | renders the Web Audio score to `out/score.wav` headlessly, so no browser click is needed |
| `fonts/Caveat[wght].ttf` | the hand-lettering face (SIL Open Font License, see `fonts/OFL.txt`) |
| `out/adhdme-final.mp4` | the film with sound, 1920x1080, 24 fps |
| `out/adhdme-contact.jpg` | contact sheet, two tiles per second |

## Watch or scrub it

Open `adhdme.html` in a browser: play, scrub, toggle sound, export frames or the score.

## Render it

Needs Node 18+, Chrome or Chromium, and ffmpeg on PATH. `puppeteer-core` drives the Chrome
you already have. Set `CHROME=/path/to/chrome` if it is not found automatically.

```bash
npm i --no-audit --no-fund
node render.mjs adhdme.html --ar 16:9 --width 1920 --grid 24    # 24-frame sheet, look at this first
node render.mjs adhdme.html --ar 16:9 --width 1920              # out/adhdme.mp4 + out/adhdme-contact.jpg
node score.mjs adhdme.html                                      # out/score.wav
ffmpeg -i out/adhdme.mp4 -i out/score.wav -c:v copy -c:a aac -shortest out/adhdme-final.mp4
```

The film is designed for 16:9. Scenes place everything relative to the frame centre, so
`--ar 1:1` or `--ar 9:16` render too, but the captions and card text are sized for the wide
frame and need shrinking before a square or vertical cut is usable. Pass `--width 3840` for
a 4K render.

## The scenes

| t | scene | what it shows |
|---|---|---|
| 0.00 | sam | Sam on warm paper, thinking of a GP and a question mark. "Step one: find a GP." |
| 2.50 | directory | A pencil-look page of identical listings: same score stamp, ad tags, a scrawl where the fee should be. |
| 4.50 | stuck | Sam stays put while the world cuts around him: a price tag with a hidden amount, four faceless profiles with the same score, a clinic door and the worry about being judged for wanting medication. Then Sam walks away: people stop before the first booking. |
| 8.75 | frontdoor | An ink blot grows out of Sam into a blueprint: ADHDme as one circle with three branches, find, compare, book. |
| 11.50 | find | Five GP profile cards cut past at half a second each: each GP in their own words, filter chips for approach, background and fit, fit signals, scope icons. |
| 14.00 | compare | Two GPs side by side with the whole two-consult price (A$400 diagnosis, A$200 per quarterly review) and scope ticks. A crayon ring picks one. |
| 16.00 | book | A calendar with both consults circled and both linked to the same GP. |
| 17.75 | assess | Sam and the GP at a desk while cardiac, psychological and biomarker icons appear: two long consults that look at the whole person. |
| 20.25 | loop | Blueprint of the fit loop: need, match, consult, rate, learn. A spark laps it faster the second time. A star score crossed out: fit, not stars. |
| 22.75 | value | Three badges: transparent, fast, personal. "Save money. Get diagnosed fast. Find a doctor who gets you." |
| 25.25 | tagline | "The right ADHD doctor should not be hard to find." Sam and the GP walk off together. |
| 27.25 | signoff | ADHDme / adhdme.au in two inks, Sam waving. |

## Design notes

- Palette comes from the deck's brand system (paper, ink, amber, tint, slate) through the
  skill's `makePalette`, with a warmer paper so stock grain shows and a slate navy for the
  blueprint interludes.
- Sam is the anchor: in every shot, in chalk during the blueprint interludes.
- This is an explainer, so each shot carries one short hand-lettered caption in two inks,
  taken from the deck's own lines. Everything else is drawn.
- `render.mjs` is the skill's script plus two small changes: it finds Playwright's bundled
  Chromium, and it passes `--no-sandbox` only when running as root (containers, CI).
