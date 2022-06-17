/*
 * gen_item_db.js
 *
 * Generate sqlite3 database of all items.
 *
 * Expects dom5inspector running at localhost:8000.
 */

const puppeteer = require('puppeteer');

const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('../data/items.db' ).serialize();
const fs = require('fs');

// regenerate items sqlite table
db.run("DROP TABLE IF EXISTS items");
db.run( fs.readFileSync('items.sql').toString() );

(async () => {

	// Open inspector
	const browser = await puppeteer.launch();
	const page = await browser.newPage();
	await page.goto('http://localhost:8000');
	await new Promise(resolve => setTimeout(resolve, 200));

	// Get items array from inspector
	const items = await page.evaluate(_ => { return Promise.resolve( DMI.modctx.itemdata ) } );

	// Store items in sqlite table
	const stmt_insert_item = db.prepare("INSERT INTO items (id, name, type, constlevel, mainlevel, mpath, gemcost ) VALUES ($id, $name, $type, $constlevel, $mainlevel, $mpath, $gemcost)");
	for ( const item of items ) {
		stmt_insert_item.run({
			$id: item.id,
			$name: item.name,
			$type: item.type,
			$constlevel: item.constlevel,
			$mainlevel: item.mainlevel,
			$mpath: item.mpath,
			$gemcost: item.gemcost
		});
	}
	stmt_insert_item.finalize();
	db.close();

	await browser.close();

})();

