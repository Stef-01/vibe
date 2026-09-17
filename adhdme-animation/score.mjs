// Render a film's Web Audio score to a WAV without a browser click: the page's own score()
// runs in an OfflineAudioContext inside headless Chrome, and the samples are written here.
//
// Usage:
//   node score.mjs film.html                      -> out/score.wav
//   node score.mjs film.html --out path/score.wav
//   node score.mjs film.html --query narrated=1   extra query string for the page (a film can read it)
// Then mux it under the silent render from render.mjs:
//   ffmpeg -i out/film.mp4 -i out/score.wav -c:v copy -c:a aac -shortest out/film-final.mp4
//
// Env: CHROME=/path/to/chrome (same lookup as render.mjs). Needs puppeteer-core next to this script (npm i).
import puppeteer from 'puppeteer-core';
import {execFileSync} from 'node:child_process';
import {existsSync, mkdirSync, writeFileSync} from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const argv = process.argv.slice(2);
const file = argv.find(a => a.endsWith('.html'));
if (!file) { console.error('usage: node score.mjs film.html [--out score.wav]'); process.exit(2); }
const flag = name => { const k = argv.indexOf(name); return k >= 0 ? argv[k + 1] : undefined; };
const out = path.resolve(flag('--out') || path.join(path.dirname(file), 'out', 'score.wav'));
mkdirSync(path.dirname(out), {recursive: true});

function findChrome() {
  if (process.env.CHROME) return process.env.CHROME;
  const mac = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  if (existsSync(mac)) return mac;
  for (const bin of ['google-chrome', 'google-chrome-stable', 'chromium', 'chromium-browser']) {
    try { return execFileSync('which', [bin]).toString().trim(); } catch {}
  }
  const pw = path.join(process.env.PLAYWRIGHT_BROWSERS_PATH || '', 'chromium');
  if (process.env.PLAYWRIGHT_BROWSERS_PATH && existsSync(pw)) return pw;
  throw new Error('No Chrome found. Set CHROME=/path/to/chrome');
}

const url = pathToFileURL(path.resolve(file)).href + '?bare=1&frame=0' + (flag('--query') ? '&' + flag('--query') : '');   // --query narrated=1 etc., passed to the page
const asRoot = typeof process.getuid === 'function' && process.getuid() === 0;
const browser = await puppeteer.launch({executablePath: findChrome(), headless: true, args: asRoot ? ['--no-sandbox', '--disable-setuid-sandbox'] : []});
try {
  const page = await browser.newPage();
  const errors = [];
  page.on('pageerror', e => errors.push(String(e)));
  await page.goto(url, {waitUntil: 'load'});
  await page.waitForFunction('window.__ready === true', {timeout: 120000});
  const {b64, dur, sr} = await page.evaluate(async () => {
    const FILM = window.__FILM; if (!FILM || !FILM.score) throw new Error('the page defines no score');
    const sr = 48000, oac = new OfflineAudioContext(2, Math.ceil(sr * FILM.DUR), sr);
    FILM.score(oac, 0, oac.destination);
    const buf = await oac.startRendering();
    const n = buf.length, out = new DataView(new ArrayBuffer(44 + n * 4)), ws = (o, s) => { for (let i = 0; i < s.length; i++) out.setUint8(o + i, s.charCodeAt(i)); };
    ws(0, 'RIFF'); out.setUint32(4, 36 + n * 4, true); ws(8, 'WAVE'); ws(12, 'fmt '); out.setUint32(16, 16, true); out.setUint16(20, 1, true); out.setUint16(22, 2, true);
    out.setUint32(24, sr, true); out.setUint32(28, sr * 4, true); out.setUint16(32, 4, true); out.setUint16(34, 16, true); ws(36, 'data'); out.setUint32(40, n * 4, true);
    const L = buf.getChannelData(0), R = buf.getChannelData(1), cl = x => Math.max(-1, Math.min(1, x));
    let o = 44; for (let i = 0; i < n; i++) { out.setInt16(o, cl(L[i]) * 32767, true); out.setInt16(o + 2, cl(R[i]) * 32767, true); o += 4; }
    const bytes = new Uint8Array(out.buffer); let s = ''; for (let i = 0; i < bytes.length; i += 0x8000) s += String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000));
    return {b64: btoa(s), dur: FILM.DUR, sr};
  });
  if (errors.length) console.error('page errors:\n  ' + [...new Set(errors)].join('\n  '));
  writeFileSync(out, Buffer.from(b64, 'base64'));
  console.log(`score: ${out} (${dur.toFixed(2)} s at ${sr} Hz, stereo 16-bit)`);
} finally {
  await browser.close();
}
