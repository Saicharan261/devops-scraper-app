// scraper/scrape.js
const puppeteer = require('puppeteer');
const fs = require('fs');

const url = process.env.SCRAPE_URL;

if (!url) {
  console.error("SCRAPE_URL environment variable not set.");
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    executablePath: '/usr/bin/chromium'

  });

  const page = await browser.newPage();
  await page.goto(url);

  const data = await page.evaluate(() => {
    return {
      title: document.title,
      heading: document.querySelector('h1')?.innerText || "No <h1> found"
    };
  });

  fs.writeFileSync('scraped_data.json', JSON.stringify(data, null, 2));
  await browser.close();
})();
