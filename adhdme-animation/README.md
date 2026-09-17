# ADHDme animations

Two short hand-drawn films about ADHDme, both built with the
[hand-drawn-canvas-animation](https://github.com/alesha-pro/tools/tree/main/skills/hand-drawn-canvas-animation)
skill: every frame is drawn by JavaScript on Canvas 2D from one HTML file, following the
skill's `core.js`, with no images or libraries, seeded textures, drawn at 12 fps and packed
to 24 fps ("on twos"), and a soundtrack generated from the same timeline.

| film | file | look | what it is |
|---|---|---|---|
| Explainer | `adhdme.html` | ink on warm paper, with blueprint interludes | 28.75 s. Sam, a patient, tries to find a GP; the deck's problem, solution, assessment, fit loop and patient value |
| Pitch | `adhdme-pitch.html` | riso print: cream stock, fluorescent inks, halftone plates | 28 s. A YC-style pitch: hook, problem, who, solution, how, why now, market, model, traction, close. Content from the Value Proposition Canvas plus the deck's numbers |

Outputs with sound: `out/adhdme-final.mp4` and `out/adhdme-pitch-final.mp4`, 1920x1080, 24 fps.
Contact sheets (two tiles per second) sit next to them.

| file | what it is |
|---|---|
| `core.js` | the skill's shared core (palettes, finishes, marks, reveals, player). Not edited. |
| `render.mjs` | headless Chrome renderer: grid sheet, spot frames, mp4 and contact sheet |
| `score.mjs` | renders a film's Web Audio score to WAV headlessly, so no browser click is needed |
| `fonts/Caveat[wght].ttf` | the explainer's hand-lettering face (SIL Open Font License, `fonts/OFL.txt`) |
| `fonts/CaveatBrush-Regular.ttf` | the pitch's bold marker face (SIL Open Font License) |

## Watch or scrub

Open either HTML file in a browser: play, scrub, toggle sound, export frames or the score.

## Render

Needs Node 18+, Chrome or Chromium, and ffmpeg on PATH. `puppeteer-core` drives the Chrome
you already have. Set `CHROME=/path/to/chrome` if it is not found automatically.

```bash
npm i --no-audit --no-fund
node render.mjs adhdme-pitch.html --ar 16:9 --width 1920 --grid 24    # 24-frame sheet, look at this first
node render.mjs adhdme-pitch.html --ar 16:9 --width 1920              # out/adhdme-pitch.mp4 + contact sheet
node score.mjs adhdme-pitch.html --out out/score-pitch.wav            # the soundtrack
ffmpeg -i out/adhdme-pitch.mp4 -i out/score-pitch.wav -c:v copy -c:a aac -shortest out/adhdme-pitch-final.mp4
```

Swap `adhdme-pitch` for `adhdme` to build the explainer. Both films are designed for 16:9.
Scenes place everything relative to the frame centre, so `--ar 1:1` or `--ar 9:16` render
too, but the lettering is sized for the wide frame and needs shrinking before a square or
vertical cut is usable. Pass `--width 3840` for a 4K render.

## The pitch, scene by scene

| t | scene | what it shows |
|---|---|---|
| 0.00 | hook | Crayon ripples from the seed dot; an iris opens on the title card: a door, "ADHDme, the front door to ADHD care in Australia." |
| 2.00 | problem | "Getting ADHD care is a maze", then four pain cards at half a second each (cost is hidden, wrong fit, no standard, scripts lapse), then "So people give up before the first booking." |
| 5.50 | who | Australia in blue with Sydney, Melbourne and Brisbane ringed: 16 to 25, seeking a diagnosis. |
| 7.50 | solution | A patient dot and five clinicians; the fit lights up. "Matching, not triage." |
| 10.50 | how | Three cards at a second each: published cost bands, standard diagnosis templates, script-expiry alerts. |
| 13.50 | whynow | A starfield timeline: QLD live since Dec 2025, NSW and VIC in 2026. GPs can now diagnose ADHD. |
| 16.00 | market | ">1M Australians with ADHD" pops, "250K actively seeking care" counts up over a dot cloud of people. |
| 18.50 | model | A pink and blue duotone beat: patient, door, clinician. Free for patients; clinicians subscribe for matched patient flow. |
| 21.00 | traction | Three stamps: live at adhdme.au, 2 GPs in Sydney, 2 matching models in test. |
| 23.00 | gallery | Every card as a badge on dashed rings, collapsing into the seed dot. |
| 24.50 | close | "The right ADHD doctor should not be hard to find." types out over ripples. |
| 26.50 | signoff | ADHDme / adhdme.au in two inks. |

## The explainer, scene by scene

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

- The explainer's palette comes from the deck's brand system (paper, ink, amber, tint, slate)
  through the skill's `makePalette`; Sam is its anchor, in every shot, in chalk during the
  blueprint interludes.
- The pitch uses the skill's `risoPop` palette as printed: each card is three plates (blue, pink,
  yellow) drawn in black on white with knockouts, printed as halftone dots that multiply like
  ink; blue shapes are knocked out of the yellow glow so they stay blue. Its anchor is the seed
  dot at the bottom of every frame; the hook's ripples are born from it and the gallery collapses
  into it.
- Both are explainers, so each shot carries one short hand-lettered line in two inks. The skill
  reserves lettering for the sign-off; that deviation is noted in each file's brief.
- Where the Value Proposition Canvas and the deck differ on money, the pitch follows the canvas:
  free for patients, a clinician subscription for matched patient flow.
- `render.mjs` is the skill's script plus two small changes: it finds Playwright's bundled
  Chromium, and it passes `--no-sandbox` only when running as root (containers, CI).
