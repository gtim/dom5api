#!/usr/bin/perl -w

#
# 1w_entity_name_search_tests.t
#
# Test number of returned matches for all entity types.
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

my %name_counts = (
	'items' => {
		'Nothing' => 0,
		'Fire Sword' => 1,
		'Moon Blade' => 1,
		'Igor Könhelm\'s Tome' => 1,
		'Precious' => 1,
		'Jinn Bottle' => 1,
		'Shadow Brand' => 1,
		'Staff of Elemental Mastery' => 2,
		'Bane Blade' => 2,
		'Eye of the Grey Ones' => 1,
		'Champion\'s Cuirass' => 1,
	},
	'spells' => {
		'Nothing' => 0,
		'Banishment' => 1,
		'Divine Channeling' => 1,
		'Daughter of Typhon' => 1,
		'Revive Wailing Lady' => 1,
		'Contact Tlahuelpuchi' => 1,
		'Geyser' => 1,
		'Will o\' the Wisp' => 1,
		'Melancholia' => 1,
		'Summon Si\'lat' => 1,
	},
	'mercs' => {
		'Nothing' => 0,
		'Dante\'s Stingers' => 1,
		'Günter Blukraft\'s Sonnenkinder' => 1,
		'The Whisperer' => 1,
	},
	'sites' => {
		'Nothing' => 0,
		'The Smouldercone' => 3, # EA, MA, LA
		'Tar Pits' => 1,
		'The Throne of the Churning Ocean' => 1,
		'Hall of the Ivy King' => 1,
	},
	'commanders' => {
		'Nothing' => 0,
		'Serpent Lord' => 2, # MA, LA
		'Master of the Games' => 1,
		'Arch Theurg' => 1,
		'Monk' => 2,
		'Adept of Pyriphlegeton' => 1,
		'“Etimmu“ - Wraith Lord' => 1,
		'“Pazuzu“ - Lord of the Plague Wind' => 1,
		'Initiate of the Deep' => 1,
		'Vaetti Hag' => 2, # Jotun, Vaetti
		'Pale One Commander' => 1,
		'Void Cultist' => 1,
		'Enkidu Bone Reader' => 1,
		'Ah Ha\'' => 2, # MA, LA
		'Paqo of the Earth Mother' => 1,
		'Great Camazotz' => 1,
		'Piconye Scholar' => 1,
		'Ifrit Sultan' => 1,
		'“\'Umm Ghulah“ - Mother Ghul' => 1,
	},
	'units' => {
		'Nothing' => 0,
		'Standard' => 4,
		'Arssartut' => 1,
		'Ghul' => 4,
	}
);

plan tests => 2 * sum map { 0 + keys %$_ } values %name_counts; 

for my $category ( keys %name_counts ) {
	while ( my ( $name, $expected_count ) = each( %{ $name_counts{$category} } ) ) {
		my $url = URI->new("$Test::Utils::protocol://$Test::Utils::host/$category");
		$url->query_form( name => $name );
		my $req = HTTP::Request->new( GET => $url );
		my $res = $ua->request($req);

		ok( $res->is_success, "requesting $url");
		my $entities = ( decode_json( $res->content ) )->{$category};
		is( 0+@$entities, $expected_count, "number of $category" );
	}
}
