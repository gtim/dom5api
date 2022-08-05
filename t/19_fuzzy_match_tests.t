#!/usr/bin/perl -w

#
# 19_fuzzy_match_tests.t
#
# Test return values of fuzzy name matching with match=fuzzy in /items, /spells, /units, /commanders, /sites and /mercs.
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

my %fuzzy_matches = (
	items => {
		'carcator'  => 'Carcator the Pocket Lich',
		'antimagic' => 'Amulet of Antimagic',
		'baneblade' => 'Bane Blade',
		'bear'      => 'Bear Claw Talisman',
	},
	spells => {
		'blessing' => 'Blessing',
		'jinn block' => 'Awaken Jinn Block',
		'tart' => 'Tartarian Gate',
	},
	units => {
		'logrian slinger' => 'Logrian Slinger',
		'einherse' => 'Einhere',
	},
	commanders => {
		'kalamukha' => 'Kala-Mukha',
		'etimmu' => '“Etimmu“ - Wraith Lord',
	},
	sites => {
		'inkpot' => 'Inkpot End',
		'steelovens' => 'The Steel Ovens',
		'silver order' => 'Tower of the Silver Order',
	},
	mercs => {
		'mamor' => 'Mamor, the White Wizard',
		'marmor' => 'Mamor, the White Wizard',
		'nergash' => 'Nergash\'s Damned Legion',
		'sogg' => 'Fish Master Sogg',
		'shipwreckers' => 'Ship Wreckers',
	},
);

plan tests => 2 * sum map { 0 + values %$_ } values %fuzzy_matches;


for my $category ( keys %fuzzy_matches ) {
	while ( my ( $search, $expected_name ) = each %{$fuzzy_matches{$category}} ) {
		my $url = URI->new("$Test::Utils::protocol://$Test::Utils::host/$category");
		$url->query_form( name => $search, match => 'fuzzy' );
		my $req = HTTP::Request->new( GET => $url );
		my $res = $ua->request($req);
		is( $res->code, 200, "GET $url" );
		my $entities = ( decode_json( $res->content ) )->{$category};
		is( $entities->[0]{name}, $expected_name, "fuzzy search \"$search\" matches" );
	}
}

