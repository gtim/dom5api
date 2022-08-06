DROP TABLE IF EXISTS units;

CREATE TABLE units (
	id         INT  NOT NULL PRIMARY KEY,
	name       TEXT NOT NULL COLLATE NOCASE,
	hp         INT  NOT NULL,
	size       INT  NOT NULL CHECK( size >= 1 AND size <= 6 )
);

DROP TABLE IF EXISTS unit_props;

CREATE TABLE unit_props (
	unit_id  INT NOT NULL,
	prop_name     TEXT NOT NULL,
	value         TEXT NOT NULL,
	arrayprop_ix  INT,
	PRIMARY KEY ( unit_id, prop_name, arrayprop_ix ),
	FOREIGN KEY (unit_id) REFERENCES units(id)
		ON DELETE CASCADE
);
