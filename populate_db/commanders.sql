CREATE TABLE commanders (
	id         INT  NOT NULL PRIMARY KEY,
	name       TEXT NOT NULL COLLATE NOCASE,
	hp         INT  NOT NULL,
	size       INT  NOT NULL CHECK( size >= 1 AND size <= 6 )
);


