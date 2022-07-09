/*
 * gen_screenshots.js
 *
 * Generate screenshots of dom5inspector popups for all items, spells, units and events.
 *
 * Expects dom5inspector running at localhost:8000.
 */

const puppeteer = require('puppeteer');


(async () => {
	const browser = await puppeteer.launch();
	const page = await browser.newPage();
	await page.goto('http://localhost:8000/?loadEvents=1');
	await page.$('#page-tabs');


	for ( const type of ['item', 'spell', 'unit', 'event'] ) {

		// Go to correct tab
		await page.evaluate( (type) => { $('#'+type+'-page-button').trigger('click'); }, type );

		// Get entities (items/spells/units/events)
		const overlay = await page.$('#'+type+'-page div.fixed-overlay')
		const num_entities = await page.evaluate( (type) => {
			return Promise.resolve( DMI.modctx[type+'data'].length )
		}, type );

		// Render and capture overlays
		for ( let entity_i = 0; entity_i < num_entities; entity_i++ ) {

			// render entity to fixed overlay
			const entity_id = await page.evaluate( (type,entity_i) => {
				const entity = DMI.modctx[type+'data'][entity_i];
				$('#'+type+'-page div.fixed-overlay').empty().append( entity.renderOverlay(entity) );
				return entity.id;
			}, type, entity_i );

			// sleep waiting for element to unfold: should be a proper await
			await new Promise(r => setTimeout(r, 500));

			// screenshot overlay
			const overlay = await page.$('#'+type+'-page div.fixed-overlay')
			await overlay.screenshot({ path: '../data/screenshot/'+type+'/' + entity_id + '.png' });
		}
	}

	await browser.close();
})();
