/*
 * populate_dbs.js
 *
 * Populate sqlite3 databases of all items, spells, commanders, units, mercs and sites.
 *
 * Expects dom5inspector running at localhost:8000.
 */

const assert = require('node:assert/strict');

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
	
	// Create tables
	const queries = fs.readFileSync('commanders.sql').toString().split(';').filter( (q) => /\S/.test(q) ); 
	for ( const query of queries ) {
		db.run(query);
	}
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

	// Props table
	await populate_units_props_table(page, db, 'commander', units.length);

	db.close();
}

async function populate_units_props_table( page, db, category, num_entities ) {
	// XXX temporary helper function until "commanders" category is removed
	const excluded_props = [
		'id', 'name', 'hp', 'size', // always present, included in commanders table
		// the following have not yet been handled:
		'A', 'B', 'D', 'E', 'F', 'H', 'N', 'S', 'W', 'aboleth', 'aciddigest', 'acidshield', 'addrandomage', 'adept_research', 'adeptsacr', 'adventurers', 'ainorec', 'airattuned', 'aisinglerec', 'alchemy', 'allret', 'almostundead', 'ambidextrous', 'amphibian', 'animal', 'animalawe', 'ap', 'appetite', 'aquatic', 'assassin', 'astralattuned', 'astralfetters', 'astralrange', 'att', 'autoblessed', 'autocompete', 'autodishealer', 'autohealer', 'autosum', 'awe', 'banefireshield', 'basecost', 'batstartsum1', 'batstartsum1d3', 'batstartsum1d6', 'batstartsum2', 'batstartsum2d6', 'batstartsum3', 'batstartsum3d6', 'batstartsum4d6', 'batstartsum5d6', 'batstartsum6d6', 'battlesum5', 'beartattoo', 'beastmaster', 'beckon', 'berserk', 'blessbers', 'blessfly', 'blind', 'bloodvengeance', 'bluntres', 'boartattoo', 'body', 'bodyguard', 'bonusspells', 'bringeroffortune', 'bug', 'bugreform', 'carcasscollector', 'casting_enc', 'castledef', 'changetargetgenderforseductionandseductionimmune', 'chaospower', 'chaosrec', 'cheapgod20', 'cheapgod40', 'cleanshape', 'clockworklord', 'cold', 'coldblood', 'coldpower', 'coldrec', 'coldres', 'coldsummon', 'combatcaster', 'combatspeed', 'commaster', 'comslave', 'corpseconstruct', 'corpseeater', 'corrupt', 'createdby', 'crossbreeder', 'crownonly', 'curseattacker', 'curseluckshield', 'damagerev', 'darkpower', 'darkvision', 'deathattuned', 'deathcurse', 'deathdisease', 'deathfire', 'deathparalyze', 'def', 'defector', 'defenceorganiser', 'defiler', 'demon', 'digest', 'disbelieve', 'diseasecloud', 'diseaseres', 'divineins', 'domimmortal', 'domsummon', 'domsummon20', 'doomhorror', 'douse', 'dragonlord', 'drainimmune', 'drake', 'dreanimator', 'dungeon', 'earthattuned', 'elegist', 'elementrange', 'enc', 'enchrebate10', 'enchrebate50', 'entangle', 'eracodes', 'ethereal', 'ethtrue', 'eyeloss', 'eyes', 'fallpower', 'falsearmy', 'farthronekill', 'fear', 'female', 'fireattuned', 'firepower', 'firerange', 'fireres', 'fireshield', 'firstshape', 'fixedname', 'fixedresearch', 'fixforgebonus', 'float', 'flying', 'foot', 'foreignmagicboost', 'forestshape', 'forestsurvival', 'forgebonus', 'formationfighter', 'fortkill', 'fullname', 'gcost', 'gemprod', 'goldcost', 'graphicsize', 'greaterhorror', 'growhp', 'guardianspiritmodifier', 'haltheretic', 'hand', 'head', 'heal', 'heat', 'heathensummon', 'heatrec', 'heretic', 'holy', 'homeshape', 'homesick', 'horrordeserter', 'horrormark', 'horrormarked', 'horsetattoo', 'hpoverflow', 'hpoverslow', 'iceforging', 'iceprot', 'illusion', 'illusionary', 'immortal', 'immortalrespawn', 'inanimate', 'incorporate', 'incunrest', 'indepmove', 'indepspells', 'indepstay', 'inept_research', 'infernoret', 'inquisitor', 'insane', 'insanify', 'inspirational', 'inspiringres', 'invisible', 'invulnerable', 'ironvul', 'isadaeva', 'isashah', 'isayazad', 'ivylord', 'kokytosret', 'labpromotion', 'lamialord', 'lanceok', 'landdamage', 'landenc', 'landshape', 'latehero', 'leader', 'leper', 'lesserhorror', 'linkname', 'listed_mpath', 'localsun', 'magicbeing', 'magicboostA', 'magicboostALL', 'magicboostD', 'magicboostE', 'magicboostF', 'magicboostN', 'magicboostS', 'magicboostW', 'magicleader', 'magicpower', 'magicstudy', 'makepearls', 'mapmove', 'mason', 'mastersmith', 'matchProperty', 'maxage', 'mind', 'mindcollar', 'mindslime', 'mindvessel', 'minprison', 'minsizeleader', 'misc', 'mor', 'moralebonus', 'mountainrec', 'mountainsurvival', 'mounted', 'mountedbeserk', 'mpath', 'mr', 'mummification', 'mummify', 'n_summon', 'nametype', 'nationname', 'natureattuned', 'naturerange', 'neednoteat', 'nobadevents', 'noheal', 'nohof', 'nomovepen', 'norange', 'noriverpass', 'nowish', 'older', 'onebattlespell', 'onisummon', 'pathboost', 'pathboostland', 'pathcost', 'patience', 'patrolbonus', 'percentpathreduction', 'petrify', 'pierceres', 'pillagebonus', 'plaguedoctor', 'plainshape', 'plant', 'poisonarmor', 'poisoncloud', 'poisonres', 'poisonskin', 'polyimmune', 'pooramphibian', 'popkill', 'preanimator', 'prec', 'prophetshape', 'prot', 'raiseonkill', 'raiseshape', 'randomspell', 'rcost', 'rcostsort', 'realms', 'reanimator', 'reanimpriest', 'reclimit', 'recruitedby', 'reformtime', 'regeneration', 'reincarnation', 'reinvigoration', 'renderOverlay', 'reqlab', 'reqtemple', 'researchbonus', 'researchwithoutmagic', 'resources', 'ressize', 'rpcost', 'rt', 'sailingmaxunitsize', 'sailingshipsize', 'sailsize', 'saltvul', 'scalewalls', 'searchable', 'secondshape', 'secondtmpshape', 'seduce', 'sendlesserhorrormult', 'shapechange', 'shatteredsoul', 'shockres', 'shrinkhp', 'siegebonus', 'singlebattle', 'skirmisher', 'slashres', 'slave', 'slaver', 'slaverbonus', 'sleepaura', 'slimer', 'slothresearch', 'slots', 'slow_to_recruit', 'snaketattoo', 'snowmove', 'sorceryrange', 'sorttype', 'speciallook', 'spellsinger', 'spiritsight', 'spreadchaos', 'spreaddeath', 'spreaddom', 'spreadgrowth', 'spreadorder', 'springpower', 'sprite', 'spy', 'standard', 'startaff', 'startage', 'startdom', 'startheroab', 'startingaff', 'startitem', 'stealthy', 'stonebeing', 'stormimmune', 'stormpower', 'str', 'stunimmunity', 'stupid', 'stygianguide', 'succubus', 'summerpower', 'summon', 'summon1', 'summon5', 'summonedby', 'summonedfrom', 'sunawe', 'supplybonus', 'swampsurvival', 'swimming', 'taskmaster', 'taxcollector', 'teleport', 'templetrainer', 'theftofthesunawe', 'thronekill', 'titles', 'tmpastralgems', 'tmpfiregems', 'trample', 'trampswallow', 'transformation', 'triple3mon', 'triplegod', 'triplegodmag', 'turmoilsummon', 'twiceborn', 'type', 'typechar', 'uncurableaffliction', 'undead', 'undeadleader', 'undisciplined', 'undying', 'unify', 'unique', 'unprep', 'unseen', 'unsurr', 'unteleportable', 'uwbug', 'uwdamage', 'uwfireshield', 'uwheat', 'uwregen', 'voidsanity', 'voidsum', 'wastesurvival', 'waterattuned', 'waterbreathing', 'watershape', 'winterpower', 'wintersummon1d3', 'wolf', 'wolftattoo', 'woundfend', 'xploss', 'xpshape', 'yearturn'
	];
	const array_props = [];
	const array_jsonprops = ['randompaths'];
	const scalar_props = ['immobile'];
	const unreadable_props = ['armor','cheapgod20','cheapgod40','createdby','dupes','eracodes','nations','recruitedby','sprite','summonedby','summonedfrom','weapons'];
	await populate_props_table( page, db, category, num_entities, scalar_props, array_props, array_jsonprops, excluded_props, unreadable_props );
}

/*
 * Units
 */

async function populate_units_db( page ) {

	const db = new sqlite3.Database('../data/units.db' ).serialize();

	// Create tables
	const queries = fs.readFileSync('units.sql').toString().split(';').filter( (q) => /\S/.test(q) ); 
	for ( const query of queries ) {
		db.run(query);
	}
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
	
	// Props table
	await populate_units_props_table(page, db, 'unit', units.length);

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

	// Create tables
	const queries = fs.readFileSync('sites.sql').toString()
		.split(';') // split on semicolon, hacky and should be fixed if SQL contains ';'
		.filter( (q) => /\S/.test(q) ); // remove empty strings (after last semicolon)
	for ( const query of queries ) {
		db.run(query);
	}

	// Sites table
		
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

	// Site props table
	
	const excluded_props = [
		'id', 'name', 'path', 'level', 'rarity', // always present, included in sites table
		'renderOverlay', 'matchProperty', 'searchable', 'listed_gempath', 'mpath2', // inspector internals/artifacts
		'scale1', 'scale2', // included in composite property
		'sprite', 'url' // probably not interesting
	];
	const array_props = [ 'com', 'futurenations', 'hcom', 'hmon', 'mon', 'nations', 'provdef', 'scales', 'sum' ];
	const scalar_props = [
		'F','A','W','E','S','D','N','B',
		'alter','blood','conj','const','ench','evo','thau',
		'cold','death','drain','misfortune','sloth','turmoil',
		'evil','wilddefenders',
		'fort','lab',
		'n_sum1','n_sum2','n_sum3','n_sum4',
		'aawe','addtolimitedrecruitment','adventure','ageratereduction','airshield','att','awe','bringgold','callgodbonus','coldres','corpselord','curse','darkvision','def','disease','domconflict','domspread','dragonlord','exp','fireres','gold','heal','holyfire','holypow','horror','ivylord','loc','magicresistancebonus','maximizeorder','mor','mpath','natcom','nationalrecruits','natmon','poisonres','prec','reinvigoration','res','reveal','rit','ritrng','rituallevelmodifier','scorch','scry','scryrange','shockres','str','sup','throneclustering','undying','unr','voidgate'
	];
	await populate_props_table( page, db, 'site', sites.length, scalar_props, array_props, [], excluded_props, [] );
	
	db.close();
}

/*
 * Properties table logic
 *
 * scalar_props: stored in single row
 * array_props: stored one element per row
 * array_jsonprops: stored one element per row, JSON-encoded
 * excluded_props: not stored
 * unreadable_props: cannot be directly serialized by puppeteer and must be culled puppet-side
 *
 * TODO: should be better decoupled and more sensible in general
 *
 */ 

async function populate_props_table( page, db, category, num_entities, scalar_props, array_props, array_jsonprops, excluded_props, unreadable_props ) {
	
	const stmt_insert_prop = db.prepare("INSERT INTO "+category+"_props ("+category+"_id, prop_name, arrayprop_ix, value) VALUES ($id, $name, $ix, $value)");

	if ( category == 'commander' ) { category = 'unit'; } // XXX temporary hack until "commanders" category is removed

	for ( let site_i = 0; site_i < num_entities; site_i++ ) {
		// Can't grab the entire array in one go due to puppeteer limitations, so fetch them one at a time.
		const props = await page.evaluate( (category, entity_i, unreadable_props) => {
			let entity = DMI.modctx[category+'data'][entity_i];
			for ( const unreadable_prop of unreadable_props ) {
				delete entity[unreadable_prop];
			}
			return Promise.resolve( entity );
		}, category, site_i, unreadable_props );
		for ( const prop_name of Object.keys(props) ) {
			if ( excluded_props.includes(prop_name) ) {
				continue;
			} else if ( array_props.includes(prop_name) || array_jsonprops.includes(prop_name) ) {
				assert.ok( props[prop_name].constructor === Array, 'expected array prop' );
				for ( let [arrayprop_ix, arrayprop_element ] of props[prop_name].entries() ) {
					if ( array_jsonprops.includes(prop_name) ) {
						arrayprop_element = JSON.stringify(arrayprop_element);
					}
					stmt_insert_prop.run( { $id: props.id, $name: prop_name, $value: arrayprop_element, $ix: arrayprop_ix });
				}
			} else if ( scalar_props.includes(prop_name ) ) {
				if ( prop_name == 'mpath' ) { // trailing space
					props[prop_name] = props[prop_name].trim();
				}
				stmt_insert_prop.run( { $id: props.id, $name: prop_name, $value: props[prop_name], $ix: null });
			} else {
				throw 'Unknown prop: ' + prop_name;
			}
		}
	}
	stmt_insert_prop.finalize();
}
