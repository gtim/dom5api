CREATE TABLE items (
	id         INT  NOT NULL PRIMARY KEY,
	name       TEXT NOT NULL COLLATE NOCASE,
	type       TEXT NOT NULL CHECK( type IN ('1-h wpn','2-h wpn','shield','helm','crown','armor','boots','misc') ),
	constlevel INT  NOT NULL,
	mainlevel  INT  NOT NULL,
	mpath      TEXT NOT NULL CHECK( LENGTH(mpath) <= 6 ),
	gemcost    TEXT NOT NULL CHECK( LENGTH(gemcost) <= 6 )
);

