DROP TABLE IF EXISTS commanders;

CREATE TABLE commanders (
	id         INT  NOT NULL PRIMARY KEY,
	name       TEXT NOT NULL COLLATE NOCASE,
	hp         INT  NOT NULL,
	size       INT  NOT NULL CHECK( size >= 1 AND size <= 6 )
);

DROP TABLE IF EXISTS commander_props;

CREATE TABLE commander_props (
	commander_id  INT NOT NULL,
	prop_name     TEXT NOT NULL,
	value         TEXT NOT NULL,
	arrayprop_ix  INT,
	PRIMARY KEY ( commander_id, prop_name, arrayprop_ix ),
	FOREIGN KEY (commander_id) REFERENCES commanders(id)
		ON DELETE CASCADE
);
