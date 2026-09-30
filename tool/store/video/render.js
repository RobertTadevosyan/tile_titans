// Renders promo.html frame by frame with the installed Google Chrome and
// encodes an H.264 MP4. The page is deterministic in `t` (seconds): every
// frame is a fresh evaluation of `window.seek(t)`.
//
//   node render.js --lang en --out ../../video/en_promo.mp4 [--fps 30] [--w 1080 --h 1920]
//
// Needs puppeteer-core (npm i puppeteer-core) and an ffmpeg binary:
// FFMPEG env var, or `pip3 install imageio-ffmpeg` (auto-detected).
const path = require('path');
const fs = require('fs');
const os = require('os');
const { execFileSync, spawnSync } = require('child_process');
const puppeteer = require(process.env.PUPPETEER_CORE || 'puppeteer-core');

const args = Object.fromEntries(process.argv.slice(2).reduce((a, v, i, arr) => {
  if (v.startsWith('--')) a.push([v.slice(2), arr[i + 1]]);
  return a;
}, []));
const lang = args.lang || 'en';
const fps = +(args.fps || 30);
const W = +(args.w || 1080), H = +(args.h || 1920);
const out = path.resolve(args.out || `${lang}_promo.mp4`);
const chrome = process.env.CHROME || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

function ffmpegPath() {
  if (process.env.FFMPEG) return process.env.FFMPEG;
  const r = spawnSync('python3', ['-c', 'import imageio_ffmpeg as f; print(f.get_ffmpeg_exe())']);
  if (r.status === 0) return r.stdout.toString().trim();
  return 'ffmpeg';
}

(async () => {
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'adpocket-promo-'));
  const browser = await puppeteer.launch({ executablePath: chrome, headless: true,
    args: ['--hide-scrollbars', '--force-device-scale-factor=1'] });
  const page = await browser.newPage();
  await page.setViewport({ width: W, height: H, deviceScaleFactor: 1 });
  const url = 'file://' + path.resolve(__dirname, 'promo.html') + `?lang=${lang}`;
  await page.goto(url, { waitUntil: 'networkidle0' });
  await page.evaluate(() => document.fonts.ready);
  const duration = await page.evaluate(() => window.DURATION);
  const frames = Math.round(duration * fps);
  console.log(`rendering ${frames} frames (${duration}s @ ${fps}fps) -> ${tmp}`);
  for (let i = 0; i < frames; i++) {
    await page.evaluate((t) => window.seek(t), i / fps);
    await page.screenshot({ path: path.join(tmp, `f${String(i).padStart(5, '0')}.png`), type: 'png' });
    if (i % 60 === 0) process.stdout.write(`  ${i}/${frames}\n`);
  }
  await browser.close();
  fs.mkdirSync(path.dirname(out), { recursive: true });
  // App Store previews are rejected in processing (state FAILED, no message)
  // without an audio track, so every export carries silent stereo AAC and
  // follows Apple's spec: H.264 High, level 4.0, 30 fps, ~10 Mbps.
  execFileSync(ffmpegPath(), ['-y', '-framerate', String(fps), '-i', path.join(tmp, 'f%05d.png'),
    '-f', 'lavfi', '-i', 'anullsrc=r=44100:cl=stereo', '-map', '0:v', '-map', '1:a', '-shortest',
    '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-profile:v', 'high', '-level', '4.0', '-r', String(fps),
    '-b:v', '10M', '-maxrate', '12M', '-bufsize', '20M', '-preset', 'slow',
    '-c:a', 'aac', '-b:a', '256k', '-ar', '44100', '-ac', '2',
    '-movflags', '+faststart', out], { stdio: 'inherit' });
  fs.rmSync(tmp, { recursive: true, force: true });
  console.log('wrote', out);
})();
