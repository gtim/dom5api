/*
 * populate_dbs.js
 *
 * Populate sqlite3 databases of all items, spells, commanders, units, mercs and sites.
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

	await populate_items_db(page);
	await populate_spells_db(page);
	await populate_commanders_db(page);
	await populate_units_db(page);
	await populate_mercs_db(page);
	await populate_sites_db(page);

	await browser.close();

})();

/*
 * Items
 */

async function populate_items_db( page ) {
	// Re-generate items sqlite table
	const db = new sqlite3.Database('../data/items.db' ).serialize();
	db.run("DROP TABLE IF EXISTS items");
	db.run( fs.readFileSync('items.sql').toString() );
	// Get items array from inspector
	const items = await page.evaluate(_ => { return Promise.resolve( DMI.modctx.itemdata ) } );
	// Populate items sqlite table
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
}

/*
 * Spells
 */

async function populate_spells_db( page ) {
	const db = new sqlite3.Database('../data/spells.db' ).serialize();
	db.run("DROP TABLE IF EXISTS spells");
	db.run( fs.readFileSync('spells.sql').toString() );
	const spells = await page.evaluate(_ => {
		return Promise.resolve(
			DMI.modctx.spelldata
				.filter( spell => spell.research != "unresearchable" )
				.map( spell => { return {
					$id: spell.id,
					$name: spell.name,
					$gemcost: spell.gemcost || '',
					$mpath: spell.mpath,
					$type: spell.type,
					$school: spell.school,
					$researchlevel: spell.researchlevel
				}; })
		);
	} );
	const schools = ['Conjuration','Alteration','Evocation','Construction','Enchantment','Thaumaturgy','Blood','Divine'];
	spells.forEach( spell => spell.$school = schools[spell.$school] );
	const stmt_insert_spell = db.prepare("INSERT INTO spells (id, name, gemcost, mpath, type, school, researchlevel ) VALUES ($id, $name, $gemcost, $mpath, $type, $school, $researchlevel)");
	for ( const spell of spells ) {
		stmt_insert_spell.run( spell );
	}
	stmt_insert_spell.finalize();
	db.close();
}

/*
 * Commanders
 */

async function populate_commanders_db( page ) {
	const db = new sqlite3.Database('../data/commanders.db' ).serialize();
	db.run("DROP TABLE IF EXISTS commanders");
	db.run( fs.readFileSync('commanders.sql').toString() );
	const units = await page.evaluate(_ => {
		return Promise.resolve(
			DMI.modctx.unitdata
				.filter( unit =>
					unit.type == "c"
					|| unit.typechar == "Pretender"
					|| unit.typechar == "Commander"
					|| unit.typechar !== undefined && unit.typechar.startsWith("cmdr")
				).filter( unit => Number.isInteger( unit.id ) ) // skip inspector-"duplicated" units, e.g. #443.02, for summons and occasionally multiple nations
				.map( unit => { return {
					$id: unit.id,
					$name: unit.fullname,
					$hp: unit.hp,
					$size: unit.size
				}; })
		);
	} );
	const stmt_insert_unit = db.prepare("INSERT INTO commanders (id, name, hp, size) VALUES ($id, $name, $hp, $size)");
	for ( const unit of units ) {
		stmt_insert_unit.run( unit );
	}
	stmt_insert_unit.finalize();
	db.close();
}

/*
 * Units
 */

async function populate_units_db( page ) {
	// TODO: commanders and units use the same table structure and should be combined
	const db = new sqlite3.Database('../data/units.db' ).serialize();
	db.run("DROP TABLE IF EXISTS units");
	db.run( fs.readFileSync('units.sql').toString() );
	const units = await page.evaluate(_ => {
		return Promise.resolve(
			DMI.modctx.unitdata
				.filter( unit => Number.isInteger( unit.id ) ) // skip inspector-"duplicated" units
				.map( unit => { return {
					$id: unit.id,
					$name: unit.fullname,
					$hp: unit.hp,
					$size: unit.size
				}; })
		);
	} );
	const stmt_insert_unit = db.prepare("INSERT INTO units (id, name, hp, size) VALUES ($id, $name, $hp, $size)");
	for ( const unit of units ) {
		stmt_insert_unit.run( unit );
	}
	stmt_insert_unit.finalize();
	db.close();
}

/*
 * Mercs
 */

async function populate_mercs_db( page ) {
	const db = new sqlite3.Database('../data/mercs.db' ).serialize();
	db.run("DROP TABLE IF EXISTS mercs");
	db.run( fs.readFileSync('mercs.sql').toString() );
	const mercs = await page.evaluate(_ => {
		return Promise.resolve(
			DMI.modctx.mercdata.map( merc => { return {
				$id: merc.id,
				$name: merc.name,
				$bossname: merc.bossname,
				$commander_id: merc.com,
				$unit_id: merc.unit,
				$nrunits: merc.nrunits
			}; })
		);
	} );
	const stmt_insert_merc = db.prepare("INSERT INTO mercs (id, name, bossname, commander_id, unit_id, nrunits) VALUES ($id, $name, $bossname, $commander_id, $unit_id, $nrunits)");
	for ( const merc of mercs ) {
		stmt_insert_merc.run( merc );
	}
	stmt_insert_merc.finalize();
	db.close();
}

/*
 * Sites
 */

async function populate_sites_db( page ) {
	const db = new sqlite3.Database('../data/sites.db' ).serialize();
	db.run("DROP TABLE IF EXISTS sites");
	db.run( fs.readFileSync('sites.sql').toString() );
	const sites = await page.evaluate(_ => {
		return Promise.resolve(
			DMI.modctx.sitedata.map( site => { return {
				$id: site.id,
				$name: site.name,
				$path: site.path,
				$level: site.level,
				$rarity: site.rarity,
			}; })
		);
	} );
	const rarities = { 0: 'Common', 1: 'Uncommon', 2: 'Rare', 5: 'Never random', 11: 'Throne lvl1', 12: 'Throne lvl2', 13: 'Throne lvl3' };
	sites.forEach( site => site.$rarity = rarities[site.$rarity] );
	const stmt_insert_site = db.prepare("INSERT INTO sites (id, name, path, level, rarity) VALUES ($id, $name, $path, $level, $rarity)");
	for ( const site of sites ) {
		stmt_insert_site.run( site );
	}
	stmt_insert_site.finalize();
	db.close();
}
