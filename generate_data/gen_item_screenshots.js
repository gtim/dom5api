/*
 * gen_item_screenshots.js
 *
 * Generate screenshots of dom5inspector popups for all items.
 *
 * Expects dom5inspector running at localhost:8000.
 */

const puppeteer = require('puppeteer');


(async () => {
	const browser = await puppeteer.launch();
	const page = await browser.newPage();
	await page.goto('http://localhost:8000');

	// Get items
	const items = await page.evaluate(_ => { return Promise.resolve( DMI.modctx.itemdata ) } );
	for ( let item_i = 0; item_i < items.length; item_i++ ) {

		// render item to fixed overlay
		await page.evaluate( item_i => {
			const item = DMI.modctx.itemdata[item_i];
			$('#item-page div.fixed-overlay').empty().append( item.renderOverlay(item) );
		}, item_i );

		// sleep waiting for element to unfold: should be a proper await
		await new Promise(r => setTimeout(r, 500));

		// screenshot overlay
		const overlay = await page.$('#item-page div.fixed-overlay')
		await overlay.screenshot({ path: 'data/screenshot/item/' + items[item_i].id + '.png' });
	}

	await browser.close();
})();
