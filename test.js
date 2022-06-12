const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('https://gurka.se');
  await page.screenshot({ path: 'gurka.png' });

  await browser.close();
})();
