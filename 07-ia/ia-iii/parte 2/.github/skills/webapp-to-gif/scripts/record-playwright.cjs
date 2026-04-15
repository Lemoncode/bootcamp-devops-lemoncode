#!/usr/bin/env node
/*
 * record-playwright.cjs
 *
 * Record a deterministic browser demo of Vacation Swipe and save as .webm.
 * Usage:
 *   node record-playwright.cjs [url] [seconds] [output-name] [action-delay-ms]
 */

const fs = require('fs');
const path = require('path');

async function main() {
  const url = process.argv[2] || 'http://localhost:8000';
  const seconds = Number(process.argv[3] || 12);
  const outputName = process.argv[4] || 'recording-playwright';
  const actionDelayMs = Number(process.argv[5] || 1200);

  if (!Number.isFinite(seconds) || seconds <= 0) {
    throw new Error('El parámetro [seconds] debe ser un número positivo.');
  }
  if (!Number.isFinite(actionDelayMs) || actionDelayMs < 300) {
    throw new Error('El parámetro [action-delay-ms] debe ser un número >= 300.');
  }

  let chromium;
  try {
    ({ chromium } = require('playwright'));
  } catch {
    throw new Error(
      'No se pudo cargar playwright. Ejecuta con npx: ' +
      'npx --yes -p playwright node .agents/skills/webapp-to-gif/scripts/record-playwright.cjs'
    );
  }

  const rootDir = process.cwd();
  const screenshotsDir = path.join(rootDir, 'workspace', 'screenshots');
  const videosDir = path.join(screenshotsDir, 'videos_tmp');

  fs.mkdirSync(videosDir, { recursive: true });

  let browser;
  try {
    browser = await chromium.launch({ headless: true, channel: 'chrome' });
  } catch {
    // Fallback: bundled Chromium. If missing, Playwright will throw a clear install hint.
    browser = await chromium.launch({ headless: true });
  }

  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    recordVideo: {
      dir: videosDir,
      size: { width: 1280, height: 720 }
    }
  });

  const page = await context.newPage();
  const video = page.video();

  console.log(`=> Abriendo ${url}`);
  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 30000 });
  await page.waitForTimeout(1000);

  // Ensure the game shell is present.
  await page.waitForSelector('vacation-game', { timeout: 20000 });

  const endAt = Date.now() + seconds * 1000;
  const actions = [1, -1, 1, 1, -1];
  let i = 0;

  async function clickInGame(selector) {
    return page.evaluate((sel) => {
      const game = document.querySelector('vacation-game');
      if (!game || !game.shadowRoot) return false;
      const btn = game.shadowRoot.querySelector(sel);
      if (!btn) return false;
      btn.click();
      return true;
    }, selector);
  }

  async function getCardMetrics() {
    return page.evaluate(() => {
      const game = document.querySelector('vacation-game');
      if (!game || !game.shadowRoot) return null;

      const cardWrap = game.shadowRoot.querySelector('.card-wrap');
      if (!cardWrap) return null;

      const rect = cardWrap.getBoundingClientRect();
      if (!rect || rect.width <= 0 || rect.height <= 0) return null;

      return {
        centerX: rect.left + rect.width / 2,
        centerY: rect.top + rect.height / 2,
        width: rect.width
      };
    });
  }

  async function dragCard(direction) {
    const metrics = await getCardMetrics();
    if (!metrics) return false;

    const distance = Math.max(120, Math.min(220, Math.round(metrics.width * 0.4)));
    const targetX = metrics.centerX + direction * distance;
    const steps = 12;

    await page.mouse.move(metrics.centerX, metrics.centerY);
    await page.mouse.down();

    for (let step = 1; step <= steps; step += 1) {
      const progress = step / steps;
      const x = metrics.centerX + (targetX - metrics.centerX) * progress;
      await page.mouse.move(x, metrics.centerY);
      await page.waitForTimeout(16);
    }

    await page.mouse.up();
    return true;
  }

  while (Date.now() < endAt) {
    const direction = actions[i % actions.length];
    const dragged = await dragCard(direction);

    if (!dragged) {
      // If result screen appears, restart and continue the demo.
      const restarted = await clickInGame('#btn-restart');
      if (!restarted) {
        await page.waitForTimeout(200);
      }
    }

    i += 1;
    await page.waitForTimeout(actionDelayMs);
  }

  await page.waitForTimeout(800);
  await context.close();
  await browser.close();

  const videoPath = await video.path();
  const outputPath = path.join(screenshotsDir, `${outputName}.webm`);

  fs.copyFileSync(videoPath, outputPath);
  fs.rmSync(videosDir, { recursive: true, force: true });

  console.log(`✓ Video generado: ${outputPath}`);
}

main().catch((err) => {
  console.error('Error grabando con Playwright:', err.message);
  process.exit(1);
});
