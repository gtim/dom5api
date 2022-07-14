CREATE TABLE spells (
	id            INT  NOT NULL PRIMARY KEY,
	name          TEXT NOT NULL COLLATE NOCASE,
	gemcost       TEXT NOT NULL CHECK( LENGTH(gemcost) <= 6 ),
	mpath         TEXT NOT NULL CHECK( LENGTH(mpath)   <= 6 ),
	type          TEXT NOT NULL CHECK( type IN ('Combat','Ritual') ),
	school        TEXT NOT NULL CHECK( school IN ('Conjuration','Alteration','Evocation','Construction','Enchantment','Thaumaturgy','Blood','Divine') ),
	researchlevel INT  NOT NULL
);

