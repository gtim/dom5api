CREATE TABLE mercs (
	id            INT  NOT NULL PRIMARY KEY,
	name          TEXT NOT NULL COLLATE NOCASE,
	bossname      TEXT NOT NULL COLLATE NOCASE,
	commander_id  INT  NOT NULL,
	unit_id       INT  NOT NULL,
	nrunits       INT  NOT NULL
);


