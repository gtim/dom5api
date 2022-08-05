#!/usr/bin/perl -w

#
# 10_entity_properties_tests.t
#
# Test properties of all entity types.
#

use 5.34.0;
use utf8;
use Test::More;
use LWP::UserAgent;
use URI;
use JSON 'decode_json';

use FindBin qw( $RealBin );
use lib "$RealBin/lib";
use List::Util 'sum';
use Test::Utils;

my $ua = LWP::UserAgent->new;

# Sample entities

our @sample_entities = (
	# Items
	{ category => 'items', id =>   1, name => 'Fire Sword',          type => '1-h wpn', constlevel => 0,  mainlevel => 1, mpath => 'F1',   gemcost => '5F'    },
	{ category => 'items', id => 100, name => 'Moon Blade',          type => '2-h wpn', constlevel => 4,  mainlevel => 1, mpath => 'S1',   gemcost => '5S'    },
	{ category => 'items', id => 363, name => 'Igor Könhelm\'s Tome',type => 'misc',    constlevel => 8,  mainlevel => 2, mpath => 'A2D2', gemcost => '10A10D'},
	{ category => 'items', id => 400, name => 'Precious',            type => 'misc',    constlevel => 12, mainlevel => 2, mpath => 'F2',   gemcost => '10F'   },
	{ category => 'items', id => 445, name => 'Jinn Bottle',         type => 'misc',    constlevel => 6,  mainlevel => 2, mpath => 'A2E1', gemcost => '10A5E' },

	# Spells
	{ category => 'spells', id => 151, name => 'Banishment',  gemcost => '', mpath => 'H1', type => 'Combat', school => 'Divine', researchlevel => 0 },
	{ category => 'spells', id => 190, name => 'Divine Channeling',  gemcost => '', mpath => 'H5', type => 'Combat', school => 'Divine', researchlevel => 0 },
	{ category => 'spells', id => 201, name => 'Daughter of Typhon',  gemcost => '30N', mpath => 'N5D2', type => 'Ritual', school => 'Conjuration', researchlevel => 9 },
	{ category => 'spells', id => 300, name => 'Revive Wailing Lady',  gemcost => '8D', mpath => 'D2', type => 'Ritual', school => 'Conjuration', researchlevel => 2 },
	{ category => 'spells', id => 400, name => 'Contact Tlahuelpuchi',  gemcost => '42B', mpath => 'B3', type => 'Ritual', school => 'Blood', researchlevel => 6 },
	{ category => 'spells', id => 500, name => 'Geyser',  gemcost => '', mpath => 'W1F1', type => 'Combat', school => 'Evocation', researchlevel => 1 },
	{ category => 'spells', id => 770, name => 'Will o\' the Wisp',  gemcost => '1F', mpath => 'F1', type => 'Combat', school => 'Conjuration', researchlevel => 5 },
	{ category => 'spells', id => 1024, name => 'Melancholia',  gemcost => '20E', mpath => 'E5', type => 'Ritual', school => 'Thaumaturgy', researchlevel => 6 },
	{ category => 'spells', id => 1176, name => 'Summon Si\'lat',  gemcost => '21A', mpath => 'A2', type => 'Ritual', school => 'Conjuration', researchlevel => 6 },

	# Mercs
	{ category => 'mercs', id => 1, name => 'Dante\'s Stingers', bossname => 'Dante', commander_id => 291, unit_id => 285, nrunits => 30 },
	{ category => 'mercs', id => 3, name => 'Günter Blukraft\'s Sonnenkinder', bossname => 'Günter Blukraft', commander_id => 291, unit_id => 286, nrunits => 30 },
	{ category => 'mercs', id => 76, name => 'The Whisperer', bossname => 'Urvikel', commander_id => 2220, unit_id => 541, nrunits => 50 },

	# Sites
	{ category => 'sites', id => 1, name => 'The Smouldercone', path => 'Fire', level => 0, rarity => 'Never random' },
	{ category => 'sites', id => 310, name => 'Tar Pits', path => 'Fire', level => 1, rarity => 'Common' },
	{ category => 'sites', id => 1147, name => 'The Throne of the Churning Ocean', path => 'Holy', level => 0, rarity => 'Throne lvl2' },
	{ category => 'sites', id => 1163, name => 'Hall of the Ivy King', path => 'Nature', level => 3, rarity => 'Rare' },

	# Commanders
	{ category => 'commanders', id => 5, name => 'Serpent Lord', size => 3, hp => 15 },
	{ category => 'commanders', id => 37, name => 'Master of the Games', size => 2, hp => 15 },
	{ category => 'commanders', id => 41, name => 'Arch Theurg', size => 2, hp => 8 },
	{ category => 'commanders', id => 60, name => 'Monk', size => 2, hp => 9 },
	{ category => 'commanders', id => 99, name => 'Adept of Pyriphlegeton', size => 2, hp => 10 },
	{ category => 'commanders', id => 183, name => '“Etimmu“ - Wraith Lord', size => 3, hp => 33 },
	{ category => 'commanders', id => 446, name => '“Pazuzu“ - Lord of the Plague Wind', size => 6, hp => 88 },
	{ category => 'commanders', id => 102, name => 'Initiate of the Deep', size => 2, hp => 10 },
	{ category => 'commanders', id => 913, name => 'Vaetti Hag', size => 1, hp => 7 },
	{ category => 'commanders', id => 1463, name => 'Pale One Commander', size => 3, hp => 22 },
	{ category => 'commanders', id => 1563, name => 'Void Cultist', size => 2, hp => 9 },
	{ category => 'commanders', id => 2171, name => 'Enkidu Bone Reader', size => 3, hp => 24 },
	{ category => 'commanders', id => 2717, name => 'Ah Ha\'', size => 2, hp => 13 },
	{ category => 'commanders', id => 2665, name => 'Paqo of the Earth Mother', size => 2, hp => 10 },
	{ category => 'commanders', id => 3192, name => 'Great Camazotz', size => 2, hp => 8 },
	{ category => 'commanders', id => 3322, name => 'Piconye Scholar', size => 1, hp => 8 },
	{ category => 'commanders', id => 3465, name => 'Ifrit Sultan', size => 5, hp => 53 },
	{ category => 'commanders', id => 3484, name => '“\'Umm Ghulah“ - Mother Ghul', size => 2, hp => 14 },

	# Units
	{ category => 'units', id => 2, name => 'Standard', size => 2, hp => 10 },
	{ category => 'units', id => 1630, name => 'Arssartut', size => 2, hp => 16 },
	{ category => 'units', id => 3480, name => 'Ghul', size => 3, hp => 15 },
	
);

# all commanders are also units, so add them to the units category as well.

for my $commander ( grep { $_->{category} eq 'commanders' } @sample_entities ) {
	my $unit = { %$commander };
	$unit->{category} = 'units';
	push @sample_entities, $unit;
}

# one test per element except "category", plus one test for request status

plan tests => sum map { 0 + keys %$_ } @sample_entities; 

# request and test

for my $expected ( @sample_entities ) {
	my $id = $expected->{id};
	my $url = "$Test::Utils::protocol://$Test::Utils::host/$expected->{category}/$id";
	my $req = HTTP::Request->new(GET => $url);
	my $res = $ua->request($req);

	ok( $res->is_success, "requesting $url");
	my $received = decode_json( $res->content );
	for my $field ( keys %$expected ) {
		next if $field eq 'category'; # "category" not tested, only needed for endpoint URL
		is( $received->{$field}, $expected->{$field}, "  $field" );
	}
}
