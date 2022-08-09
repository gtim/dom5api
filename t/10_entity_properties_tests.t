#!/usr/bin/perl -w

#
# 10_entity_properties_tests.t
#
# Test properties of all entity types.
#

use 5.34.0;
use utf8;
use Test::More;
use Test::Deep;
use LWP::UserAgent;
use URI;
use JSON 'decode_json';

use FindBin qw( $RealBin );
use lib "$RealBin/lib";
use List::Util 'sum';
use Test::Utils;

# Sample entities

my %sample_entities = (
	items => [
		{ id =>   1, name => 'Fire Sword',          type => '1-h wpn', constlevel => 0,  mainlevel => 1, mpath => 'F1',   gemcost => '5F'    },
		{ id => 100, name => 'Moon Blade',          type => '2-h wpn', constlevel => 4,  mainlevel => 1, mpath => 'S1',   gemcost => '5S'    },
		{ id => 363, name => 'Igor Könhelm\'s Tome',type => 'misc',    constlevel => 8,  mainlevel => 2, mpath => 'A2D2', gemcost => '10A10D'},
		{ id => 400, name => 'Precious',            type => 'misc',    constlevel => 12, mainlevel => 2, mpath => 'F2',   gemcost => '10F'   },
		{ id => 445, name => 'Jinn Bottle',         type => 'misc',    constlevel => 6,  mainlevel => 2, mpath => 'A2E1', gemcost => '10A5E' },
	],

	spells => [
		{ id => 151, name => 'Banishment',  gemcost => '', mpath => 'H1', type => 'Combat', school => 'Divine', researchlevel => 0 },
		{ id => 190, name => 'Divine Channeling',  gemcost => '', mpath => 'H5', type => 'Combat', school => 'Divine', researchlevel => 0 },
		{ id => 201, name => 'Daughter of Typhon',  gemcost => '30N', mpath => 'N5D2', type => 'Ritual', school => 'Conjuration', researchlevel => 9 },
		{ id => 300, name => 'Revive Wailing Lady',  gemcost => '8D', mpath => 'D2', type => 'Ritual', school => 'Conjuration', researchlevel => 2 },
		{ id => 400, name => 'Contact Tlahuelpuchi',  gemcost => '42B', mpath => 'B3', type => 'Ritual', school => 'Blood', researchlevel => 6 },
		{ id => 500, name => 'Geyser',  gemcost => '', mpath => 'W1F1', type => 'Combat', school => 'Evocation', researchlevel => 1 },
		{ id => 770, name => 'Will o\' the Wisp',  gemcost => '1F', mpath => 'F1', type => 'Combat', school => 'Conjuration', researchlevel => 5 },
		{ id => 1024, name => 'Melancholia',  gemcost => '20E', mpath => 'E5', type => 'Ritual', school => 'Thaumaturgy', researchlevel => 6 },
		{ id => 1176, name => 'Summon Si\'lat',  gemcost => '21A', mpath => 'A2', type => 'Ritual', school => 'Conjuration', researchlevel => 6 },
	],

	mercs => [
		{ id => 1, name => 'Dante\'s Stingers', bossname => 'Dante', commander_id => 291, unit_id => 285, nrunits => 30 },
		{ id => 3, name => 'Günter Blukraft\'s Sonnenkinder', bossname => 'Günter Blukraft', commander_id => 291, unit_id => 286, nrunits => 30 },
		{ id => 76, name => 'The Whisperer', bossname => 'Urvikel', commander_id => 2220, unit_id => 541, nrunits => 50 },
	],

	sites => [
		{ id => 1, name => 'The Smouldercone', path => 'Fire', level => 0, rarity => 'Never random',
			hcom => [87,89,923],
			mpath => 'F4',
			nations => [55],
			scales => ['Heat'],
		},
		{ id => 310, name => 'Tar Pits', path => 'Fire', level => 1, rarity => 'Common', mpath => 'F1' },
		{ id => 1147, name => 'The Throne of the Churning Ocean', path => 'Holy', level => 0, rarity => 'Throne lvl2',
			conj => '20%',
			domspread => 2,
			mpath => 'A1 W3',
			scales => ['Turmoil'],
			wilddefenders => 1,
		},
		{ id => 1163, name => 'Hall of the Ivy King', path => 'Nature', level => 3, rarity => 'Rare',
			mpath => 'N2',
			scales => ['Growth'],
		},
	],

	units => [
		# commanders
		{ id => 5, name => 'Serpent Lord', size => 3, hp => 15 },
		{ id => 37, name => 'Master of the Games', size => 2, hp => 15 },
		{ id => 41, name => 'Arch Theurg', size => 2, hp => 8,
			randompaths => [{paths=>'FAWS',levels=>1,chance=>100},{paths=>'FAWS',levels=>1,chance=>10}]
	       	},
		{ id => 60, name => 'Monk', size => 2, hp => 9 },
		{ id => 99, name => 'Adept of Pyriphlegeton', size => 2, hp => 10 },
		{ id => 183, name => '“Etimmu“ - Wraith Lord', size => 3, hp => 33 },
		{ id => 446, name => '“Pazuzu“ - Lord of the Plague Wind', size => 6, hp => 88 },
		{ id => 102, name => 'Initiate of the Deep', size => 2, hp => 10 },
		{ id => 913, name => 'Vaetti Hag', size => 1, hp => 7,
			randompaths => [{paths=>'SDNB',levels=>1,chance=>100}]
		},
		{ id => 1463, name => 'Pale One Commander', size => 3, hp => 22 },
		{ id => 1563, name => 'Void Cultist', size => 2, hp => 9,
			randompaths => [{paths=>'S',levels=>1,chance=>20}]
		},
		{ id => 2171, name => 'Enkidu Bone Reader', size => 3, hp => 24,
			randompaths => [{paths=>'WED',levels=>1,chance=>100}]
		},
		{ id => 2717, name => 'Ah Ha\'', size => 2, hp => 13 },
		{ id => 2665, name => 'Paqo of the Earth Mother', size => 2, hp => 10 },
		{ id => 3192, name => 'Great Camazotz', size => 2, hp => 8 },
		{ id => 3322, name => 'Piconye Scholar', size => 1, hp => 8 },
		{ id => 3465, name => 'Ifrit Sultan', size => 5, hp => 53,
			randompaths => [{paths=>'AES',levels=>1,chance=>100},{paths=>'FAES',levels=>1,chance=>10}]
		},
		{ id => 3484, name => '“\'Umm Ghulah“ - Mother Ghul', size => 2, hp => 14 },
		# non-commanders
		{ id => 2, name => 'Standard', size => 2, hp => 10 },
		{ id => 1630, name => 'Arssartut', size => 2, hp => 16 },
		{ id => 3480, name => 'Ghul', size => 3, hp => 15 },
	],
	
);

# test plan
#
# three test per element (ID search + esact name search + fuzzy name search),
# + five test per entity:
#     ID search request status
#     exact name search request status & correct-ID check
#     fuzzy name search request status & correct-ID check

{
	my @all_entities = map { @$_ } values %sample_entities;
	my $num_entities = 0 + @all_entities;
	my $total_num_props = sum map { 0 + keys %$_ } @all_entities;
	plan tests => 3 * $total_num_props + (1+2+2) * $num_entities;
}

# test all sample entities 

my $ua = LWP::UserAgent->new;
for my $category ( keys %sample_entities ) {
	for my $expected ( @{$sample_entities{$category}} ) {

		# test ID endpoint
		{
			my $url = "$Test::Utils::protocol://$Test::Utils::host/$category/$expected->{id}";
			my $res = $ua->request( HTTP::Request->new(GET => $url) );
			ok( $res->is_success, "requesting $url");
			my $received = decode_json( $res->content );
			test_expected_vs_received( $expected, $received );
		}

		# test exact-name and fuzzy-name endpoints
		for my $fuzzy ( 0, 1 ) {
			my $url = URI->new( "$Test::Utils::protocol://$Test::Utils::host/$category" );
			$url->query_form( match => 'fuzzy' ) if $fuzzy;
			$url->query_form( name => $expected->{name} );
			my $res = $ua->request( HTTP::Request->new(GET => $url) );
			ok( $res->is_success, "requesting $url");
			my $received = decode_json( $res->content );
			my @entities_with_correct_ID = grep { $_->{id} == $expected->{id} } @{ $received->{$category} };
			is( 0+@entities_with_correct_ID, 1, "name search returned correct ID (fuzzy:$fuzzy)");
			test_expected_vs_received( $expected, $entities_with_correct_ID[0] );
		}
	}
}


# entity deep test sub

sub test_expected_vs_received {
	my ( $expected, $received ) = @_;
	for my $field ( keys %$expected ) {
		if ( ref($expected->{$field}) eq 'ARRAY' ) {
			cmp_bag( $received->{$field}, $expected->{$field}, "  $field (bag)" );
		} else {
			is( $received->{$field}, $expected->{$field}, "  $field" );
		}
	}
}


