# ADHDme animations

Two short hand-drawn films about ADHDme, both built with the
[hand-drawn-canvas-animation](https://github.com/alesha-pro/tools/tree/main/skills/hand-drawn-canvas-animation)
skill: every frame is drawn by JavaScript on Canvas 2D from one HTML file, following the
skill's `core.js`, with no images or libraries, seeded textures, drawn at 12 fps and packed
to 24 fps ("on twos"), and a soundtrack generated from the same timeline.

| film | file | look | what it is |
|---|---|---|---|
| Explainer | `adhdme.html` | ink on warm paper, with blueprint interludes | 28.75 s. Sam, a patient, tries to find a GP; the deck's problem, solution, assessment, fit loop and patient value |
| Pitch | `adhdme-pitch.html` | riso print: cream stock, fluorescent inks, halftone plates, drawn people and icons | 2 min 47 s, no narrator: the lettering carries the script over an arpeggio-led music bed that lands its bars on the cuts. A YC-style pitch: hook, problem, who, solution, three matches on life experience shown as faces, how the match is made (four beats), what that changes, how it works, why now, market, model, traction, close. Content from the Value Proposition Canvas plus the deck's numbers |

Outputs with sound: `out/adhdme-final.mp4` and `out/adhdme-pitch-final.mp4`, 1920x1080, 24 fps.
Contact sheets (two tiles per second) sit next to them.

| file | what it is |
|---|---|
| `core.js` | the skill's shared core (palettes, finishes, marks, reveals, player). Not edited. |
| `render.mjs` | headless Chrome renderer: grid sheet, spot frames, mp4 and contact sheet |
| `score.mjs` | renders a film's Web Audio score to WAV headlessly, so no browser click is needed |
| `build-pitch.sh` | the whole pitch build: frames, music, mux (`--narrated` adds a voice) |
| `voice.py`, `adhdme-pitch-narration.json` | the optional narrated cut: a script with one line per beat, synthesised with piper into a voice track and a speech-timed beat sheet (`adhdme-pitch-voice.js`, generated, not committed) that the film uses when present |
| `fonts/Caveat[wght].ttf` | the explainer's hand-lettering face (SIL Open Font License, `fonts/OFL.txt`) |
| `fonts/CaveatBrush-Regular.ttf` | the pitch's bold marker face (SIL Open Font License) |
| `fonts/NotoSansDevanagari…`, `fonts/NotoNastaliqUrdu…` | the Hindi and Urdu on the clinician's label (SIL Open Font License) |
| `fonts/Poppins-Black.ttf`, `fonts/CourierPrime-Bold.ttf` | the logo: the heavy geometric "me" and the typewriter A D H D (both SIL Open Font License) |

## Watch or scrub

Open either HTML file in a browser: play, scrub, toggle sound (the music), export frames or the score.

## Render

Needs Node 18+, Chrome or Chromium, and ffmpeg on PATH. `puppeteer-core` drives the Chrome
you already have. Set `CHROME=/path/to/chrome` if it is not found automatically.

```bash
npm i --no-audit --no-fund
./build-pitch.sh              # frames -> music -> out/adhdme-pitch-final.mp4
./build-pitch.sh --grid       # just a 48-frame sheet to look at
```

The pitch's length comes from `BEAT_SHEET` at the top of `adhdme-pitch.html`: one duration per
beat, in seconds. Change a number and rebuild; every card places its reveals as fractions of
its beat, and the music re-anchors its bars on the new cuts. The steps, by hand:

```bash
node render.mjs adhdme-pitch.html --ar 16:9 --width 1920      # out/adhdme-pitch.mp4 + contact sheet
node score.mjs adhdme-pitch.html --out out/score-pitch.wav    # the music, from the same timeline
ffmpeg -i out/adhdme-pitch.mp4 -i out/score-pitch.wav -map 0:v -map 1:a -af loudnorm=I=-16:TP=-1.5:LRA=11 ...   # see build-pitch.sh
```

A narrated cut is still one flag away: `./build-pitch.sh --narrated` synthesises
`adhdme-pitch-narration.json` with piper, re-times every beat to max(its visual minimum, lead +
speech + pad), and ducks the music under the voice. It needs Python 3 with numpy and
`pip install piper-tts`, plus a piper voice in `voices/` (the script names `en-us-ryan-high`
from [piper's v0.0.2 release](https://github.com/rhasspy/piper/releases/tag/v0.0.2); any piper
voice works, set `model` in the narration file; with network access to Microsoft's endpoint,
`"engine": "edge"` uses `edge-tts` and an Australian neural voice instead).

The explainer builds the same way: `node render.mjs adhdme.html --ar 16:9 --width 1920`,
`node score.mjs adhdme.html`, then `ffmpeg -i out/adhdme.mp4 -i out/score.wav -c:v copy -c:a aac -shortest out/adhdme-final.mp4`.
Both films are designed for 16:9. Scenes place everything relative to the frame centre, so
`--ar 1:1` or `--ar 9:16` render too, but the lettering is sized for the wide frame and needs
shrinking before a square or vertical cut is usable. Pass `--width 3840` for a 4K render.

## The pitch, scene by scene

Times are from `BEAT_SHEET`; there is no narration, so the last column is what is lettered on
the card.

| t | beat | what it shows | on the card |
|---|---|---|---|
| 0:00 | hook | Crayon ripples from the seed dot; an iris opens on the logo card: the yellow field with a pink misregistered edge, "me" in the heavy face, A D H D landing one by one in the typewriter face, the orange full stop, then the tagline typing out. | The front door to ADHD care in Australia. |
| 0:06 | maze | The headline knocked out of a real generated maze, the patient at the entrance, the door at the far end. | Getting ADHD care is a maze. |
| 0:11 | pain1 to pain4 | A swinging price tag with a question for an amount; a round peg lowered onto a triangular hole; three clinicians' sheets that disagree; a bottle draining while the alert is crossed out. | Cost is hidden. Wrong fit. No standard. Scripts lapse. |
| 0:27 | giveup | The line knocked out of a pink ellipse. | So people give up before the first booking. |
| 0:31 | who | Australia prints in blue, then Sydney, Melbourne and Brisbane ring one by one; five young people arrive in a row. | 16 to 25, seeking a diagnosis. Sydney · Melbourne · Brisbane |
| 0:38 | solution | A patient faces five clinicians; lines draw, the fit lights up, and the sub line types as it lands. | Matching, not triage. Not the next free slot. The right person, for you. |
| 0:45 | pair1 | A new mother with her baby, a pram and a night-feed moon behind her, faces a woman GP who could be her: the same skin, the same bun, a coat, a stethoscope and a heart badge. The line lands. | A new parent, postpartum. matched with a GP who has perinatal experience. |
| 0:53 | pair2 | A young woman with her family behind her, a lit window, and a "…" for the things not said, faces a bearded doctor whose name tag reads हिंदी and اردو. | A South Asian family. Stigma at home. matched with a doctor of the same background, in Hindi and Urdu. |
| 1:02 | pair3 | A hooded patient with a crowd behind and a thought bubble holding a pill and a question mark, faces a clinician who waves, with a heart and a tick in a speech bubble. | Afraid of being judged. matched with plain language and no judgement. |
| 1:10 | pairs | The three pairs as small portraits, cross-matched. | Matched on life, not just availability. Postpartum. Cultural background. Stigma. The things a directory never asks. |
| 1:17 | algo1 | What we ask: a patient beside seven life factors that arrive one by one (stage of life, background and language, what you fear, how you like to be spoken to, cost, telehealth, when). | We ask about your life. Not your postcode. |
| 1:25 | algo2 | What we know: a clinician beside the seven things the interview covers (interviewed first, what they have seen, who they do best with, how they speak, how they run a consult, scope, availability). | We know every clinician the same way. Interviewed first. Notes and outcomes later, with consent. |
| 1:33 | algo3 | Two lanes: rules that score every factor as growing bars, and a language model that reads what you wrote; both end on the same match. | Two models, side by side. Transparent rules, and a language model that reads nuance. We test which earns its place. |
| 1:42 | algo4 | The loop: a consultation in the middle, five fit signals around it feeding back, the next match better; a crossed-out star. | Every consult makes the next match better. Five fit signals, after every consultation. A fit profile, not a star score. |
| 1:50 | value | Three columns: a pair who fit before they meet; faster and cheaper; the same clinician at 6, 12 and 24 months. | What that changes. |
| 1:59 | how | Cost bands, standard templates, script alerts, and a pill: free for patients. | Published. Standard. Safe. |
| 2:06 | whynow | A starfield timeline: QLD live, NSW and VIC in 2026. | Why now? GPs can now diagnose ADHD. The pathway is opening state by state. |
| 2:13 | market | ">1M" pops, "250K" counts up while a quarter of the crowd turns pink. | >1M Australians with ADHD. 250K seeking care right now. |
| 2:19 | model | Pink and blue duotone: patient, door, clinician. | Free for patients. Clinicians subscribe for matched patient flow. |
| 2:26 | traction | Three stamps land with a tilt; two GPs stand by theirs. | Live today. adhdme.au · 2 GPs in Sydney · 2 models of matching in test |
| 2:32 | gallery | Every card as a badge on dashed rings, collapsing into the seed dot. | |
| 2:36 | close | The tagline types out; the six people stand together, smiling. | The right ADHD doctor should not be hard to find. Now, they are not. |
| 2:42 | signoff | The logo draws itself over the closing ripples; adhdme.au beneath. | adhdme.au |

The music is written in `score()` from the same timeline and re-anchors its bars on every
beat, so downbeats land on the cuts. A plucked arpeggio carries the whole film over soft pads
and a sine bass: quarter notes in the hook, a minor loop through the problem, eighths from the
segment on, a second arpeggio an octave up on the off-beats through the matches and the
engine, a key change up a whole tone for the value, a riser into the market, and the arpeggio
thinning back to quarter notes for the close. No drums, no lead line. `build-pitch.sh`
normalises it to about -16 LUFS.

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

## What would take the pitch further

A critical appraisal of the current cut, most valuable first.

- **A voice, if one is wanted.** The cut is music only; the lettering is the script. If a
  narrated version is wanted later, `--narrated` builds one from the same beats, but the
  synthetic US voice it uses was only the best one reachable from the build machine. An
  Australian voice matters for an Australian company: `"engine": "edge"` in the narration
  file gives Microsoft's en-AU neural voices where that endpoint is reachable, and a human
  voice actor reading the script would be better still (voice.py's timing step works
  unchanged from recorded clips).
- **Length.** 2 min 47 s against a 2 min 30 s target, with every card holding long enough to
  read its lines twice. `BEAT_SHEET` is the length control: taking half a second off each of
  the four pain cards and the summary of the pairs, and a second off each engine card, lands
  it at 2 min 40 s; dropping the "why now" beat gets it under 2 min 35 s.
- **The music.** The bed is oscillators and a generated reverb, written in the film. It lands
  its accents on the cuts, but it lacks the warmth of sampled instruments. A next step is a
  real harp or felt-piano sample set playing the same arpeggio through the same timeline, and
  a limiter after the loudness normalisation. Light foley on the cuts (a paper flip, the thump
  of a stamp) would sell the print idea.
- **Claims and compliance.** "Faster and cheaper than the psychiatrist-only route" and the
  market numbers should carry an on-screen source or be softened; the deck's own tone rule
  is "no claims", and Australian health-advertising rules apply to anything public. The
  business model on screen follows the canvas (free for patients, a clinician subscription);
  the deck says a 10% booking fee. One of them should win before the film goes out.
- **Accessibility.** The lettering is the script, so an SRT for screen readers can be generated
  from `BEAT_SHEET` and each card's lines; that is one script away. The riso dot
  screens hold contrast well, but the yellow glow behind navy lettering should be checked
  against WCAG at small sizes.
- **Motion.** The people blink and the plates land in print order, but nothing breathes: a slow
  push-in on each pair card, a head tilt on the stressed word of a line, and a path drawn
  through the maze would add life without breaking the drawn-on-twos cadence.
- **Cuts and formats.** A 60 s trailer (hook, one pair, the engine, the close) for social, and
  9:16 and 1:1 layouts, which need the lettering resized per format.
- **Tooling.** A check that every hand-lettered line fits its frame (measureText against the
  card width) and a contact-sheet diff against a golden render would catch layout
  regressions before a four-minute build. The current QA pass is manual: two spot frames per
  beat rendered with `--only`, tiled four to a sheet and read at full size. That is what caught
  the tagline sitting on the anchor, a sub line running into the clinician column, and the
  anchor turning blue under the duotone palette.

## Design notes

- The explainer's palette comes from the deck's brand system (paper, ink, amber, tint, slate)
  through the skill's `makePalette`; Sam is its anchor, in every shot, in chalk during the
  blueprint interludes.
- The pitch uses the skill's `risoPop` palette as printed: each card is three plates (blue, pink,
  yellow) drawn in black on white with knockouts, printed as halftone dots that multiply like
  ink; blue shapes are knocked out of the yellow glow so they stay blue. Its anchor is the
  logo's orange full stop at the bottom of every frame; the hook's ripples are born from it and
  the gallery collapses into it.
- The logo is drawn, not placed: `logo()` in `adhdme-pitch.html` sets "me" in Poppins Black,
  scatters A D H D above it in Courier Prime Bold at the tilts of the brand mark, and adds the
  orange full stop, with a pink offset under the navy like every other line in the film. On the
  title card it sits on its yellow field, printed on the yellow plate with a misregistered pink
  edge. The explainer (`adhdme.html`) still hand-letters the name.
- The people in the pitch are drawn by one `bust()` function: skin, hair and clothes as flat
  fills under a riso dot screen, features in navy line, with a mood and a brow angle, and
  props for a life: a baby held, a bindi, a hood, a beard and glasses, a stethoscope, a badge,
  a bilingual name tag, a raised hand. Skin tones are tints and shades of the palette's orange.
- The postpartum match is a woman who could be the mother herself: the same skin tone and
  the same bun, with the coat, the stethoscope and the heart badge as the only difference.
  The other two matches are drawn on shared background and on manner.
- The pitch has no narrator. Every sub line types in as soon as its picture has made its
  point (the match line landing, the models arriving), so each card is read, not heard.
- Both are explainers, so each shot carries one short hand-lettered line in two inks. The skill
  reserves lettering for the sign-off; that deviation is noted in each file's brief.
- Where the Value Proposition Canvas and the deck differ on money, the pitch follows the canvas:
  free for patients, a clinician subscription for matched patient flow.
- `render.mjs` is the skill's script plus two small changes: it finds Playwright's bundled
  Chromium, and it passes `--no-sandbox` only when running as root (containers, CI).
