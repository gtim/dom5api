CREATE TABLE sites (
	id            INT  NOT NULL PRIMARY KEY,
	name          TEXT NOT NULL COLLATE NOCASE,
	path          TEXT NOT NULL COLLATE NOCASE CHECK( path IN ('Fire','Air','Water','Earth','Astral','Death','Nature','Blood','Holy') ),
	level         INT  NOT NULL,
	rarity        TEXT NOT NULL COLLATE NOCASE CHECK( rarity IN ('Common','Uncommon','Rare','Never random','Throne lvl1','Throne lvl2','Throne lvl3') )
);



