package Test::Utils;

use utf8;

our @sample_entities = (
	{ category => 'items', id =>   1, name => 'Fire Sword',          type => '1-h wpn', constlevel => 0,  mainlevel => 1, mpath => 'F1',   gemcost => '5F'    },
	{ category => 'items', id => 100, name => 'Moon Blade',          type => '2-h wpn', constlevel => 4,  mainlevel => 1, mpath => 'S1',   gemcost => '5S'    },
	{ category => 'items', id => 400, name => 'Precious',            type => 'misc',    constlevel => 12, mainlevel => 2, mpath => 'F2',   gemcost => '10F'   },
	{ category => 'items', id => 445, name => 'Jinn Bottle',         type => 'misc',    constlevel => 6,  mainlevel => 2, mpath => 'A2E1', gemcost => '10A5E' },
	{ category => 'items', id => 363, name => 'Igor Könhelm\'s Tome',type => 'misc',    constlevel => 8,  mainlevel => 2, mpath => 'A2D2', gemcost => '10A10D'},
);

1;
