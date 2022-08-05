DROP TABLE IF EXISTS sites;

CREATE TABLE sites (
	id            INT  NOT NULL PRIMARY KEY,
	name          TEXT NOT NULL COLLATE NOCASE,
	path          TEXT NOT NULL COLLATE NOCASE CHECK( path IN ('Fire','Air','Water','Earth','Astral','Death','Nature','Blood','Holy') ),
	level         INT  NOT NULL,
	rarity        TEXT NOT NULL COLLATE NOCASE CHECK( rarity IN ('Common','Uncommon','Rare','Never random','Throne lvl1','Throne lvl2','Throne lvl3') )
);

DROP TABLE IF EXISTS site_props;

CREATE TABLE site_props (
	site_id   INT NOT NULL,
	prop_name TEXT NOT NULL,
	value     TEXT NOT NULL,
	PRIMARY KEY ( site_id, prop_name ),
	FOREIGN KEY (site_id) REFERENCES sites(id)
		ON DELETE CASCADE
);
