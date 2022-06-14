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

// regenerate items sqlite table
db.run("DROP TABLE IF EXISTS items");
db.run("CREATE TABLE items (         \
	id INT NOT NULL PRIMARY KEY, \
	name TEXT NOT NULL           \
)");


(async () => {

	// Open inspector
	const browser = await puppeteer.launch();
	const page = await browser.newPage();
	await page.goto('http://localhost:8000');

	// Get items array from inspector
	const items = await page.evaluate(_ => { return Promise.resolve( DMI.modctx.itemdata ) } );

	// Store items in sqlite table
	const stmt_insert_item = db.prepare("INSERT INTO items (id, name) VALUES ($id, $name)");
	for ( const item of items ) {
		stmt_insert_item.run({ $id: item.id, $name: item.name });
	}
	stmt_insert_item.finalize();
	db.close();

	await browser.close();

})();

