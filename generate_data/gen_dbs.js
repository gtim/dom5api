/*
 * gen_dbs.js
 *
 * Generate sqlite3 databases of all items and spells.
 *
 * Expects dom5inspector running at localhost:8000.
 */

const puppeteer = require('puppeteer');

const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');

(async () => {

	// Open inspector
	
	const browser = await puppeteer.launch();
	const page = await browser.newPage();
	await page.goto('http://localhost:8000');
	await page.$('#page-tabs');
	await new Promise(r => setTimeout(r, 500));

	/*
	 * Items
	 */

	// regenerate items sqlite table
	const db = new sqlite3.Database('../data/items.db' ).serialize();
	db.run("DROP TABLE IF EXISTS items");
	db.run( fs.readFileSync('items.sql').toString() );

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


	/*
	 * Spells
	 */
	
	// regenerate spells sqlite table
	const db = new sqlite3.Database('../data/spells.db' ).serialize();
	db.run("DROP TABLE IF EXISTS spells");
	db.run( fs.readFileSync('spells.sql').toString() );
	
	// Get spells array from inspector
	const spells = await page.evaluate(_ => {
		return Promise.resolve(
			DMI.modctx.spelldata
				.filter( spell => spell.research != "unresearchable" )
				.map( spell => { return {
					id: spell.id,
					name: spell.name,
					gemcost: spell.gemcost || '',
					mpath: spell.mpath,
					type: spell.type,
					school: spell.school,
					researchlevel: spell.researchlevel
				}; })
		);
	} );
	
	// Store spells in sqlite table
	const stmt_insert_spell = db.prepare("INSERT INTO spells (id, name, gemcost, mpath, type, school, researchlevel ) VALUES ($id, $name, $gemcost, $mpath, $type, $school, $researchlevel)");
	const schools = ['Conjuration','Alteration','Evocation','Construction','Enchantment','Thaumaturgy','Blood','Divine'];
	for ( const spell of spells ) {
		console.log('inserting spell ' + spell.id + ': ' + spell.name );
		stmt_insert_spell.run({
			$id: spell.id,
			$name: spell.name,
			$mpath: spell.mpath,
			$gemcost: spell.gemcost,
			$type: spell.type,
			$school: schools[spell.school],
			$researchlevel: spell.researchlevel
		});
	}
	stmt_insert_spell.finalize();
	db.close();


	await browser.close();

})();

