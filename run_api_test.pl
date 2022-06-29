#!/usr/bin/perl -w

#
# run_api_test.pl
#
# Runs a test suite against the live API.
#
# Tests to write:
# - ensure screenshot URL is returned
# - ensure screenshot is a PNG image

use 5.34.0;
use utf8;
use Test::More;
use LWP::UserAgent;
use URI;
use JSON 'decode_json';

my $host = 'dom5api.illwiki.com';
my $ua = LWP::UserAgent->new;

my @test_items = (
	{ id =>   1, name => 'Fire Sword',          type => '1-h wpn', constlevel => 0,  mainlevel => 1, mpath => 'F1',   gemcost => '5F'    },
	{ id => 100, name => 'Moon Blade',          type => '2-h wpn', constlevel => 4,  mainlevel => 1, mpath => 'S1',   gemcost => '5S'    },
	{ id => 400, name => 'Precious',            type => 'misc',    constlevel => 12, mainlevel => 2, mpath => 'F2',   gemcost => '10F'   },
	{ id => 445, name => 'Jinn Bottle',         type => 'misc',    constlevel => 6,  mainlevel => 2, mpath => 'A2E1', gemcost => '10A5E' },
	{ id => 363, name => 'Igor Könhelm\'s Tome',type => 'misc',    constlevel => 8,  mainlevel => 2, mpath => 'A2D2', gemcost => '10A10D'},
);

my %item_counts = (
	# name -> number of items with the name
	'Wondrous Box of Monster' => 0,
	'Sun Blade' => 0,
	'Antimagic Amulet' => 0,
	'Treelords Staff' => 0,
	'Bane Blade' => 2,
	'Staff of Elemental Mastery' => 2,
);

my %fuzzy_matches = (
	# fuzzy search term -> expected item name
	'carcator' => 'Carcator the Pocket Lich',
	'antimagic' => 'Amulet of Antimagic',
	'baneblade' => 'Bane Blade',
);

my $num_id_tests         = 8 * @test_items + 6;
my $num_name_tests       = 8 * @test_items + 2*keys(%item_counts);
my $num_fuzzy_name_tests = 9 * @test_items + 2*keys(%fuzzy_matches);

plan tests => $num_id_tests + $num_name_tests + $num_fuzzy_name_tests;


#
#
# Test /items/:id endpoint
#
#


# Ensure some sample items give correct properties

for my $expected ( @test_items ) {
	my $item_id = $expected->{id};
	my $url = "https://$host/items/$item_id";
	my $req = HTTP::Request->new(GET => $url);
	my $res = $ua->request($req);

	ok( $res->is_success, "requesting $url");
	my $item = decode_json( $res->content );
	for my $field ( qw/id name type constlevel mainlevel mpath gemcost/ ) {
		is( $item->{$field}, $expected->{$field}, "  $field" );
	}
}

# Non-existent item IDs

for my $item_id ( 446, 500, 1e6, 2**50, -1, 0 ) {
	my $url = sprintf( 'https://%s/items/%.0f', $host, $item_id );
	my $req = HTTP::Request->new( GET => $url );
	my $res = $ua->request($req);
	is( $res->code, 404, "non-existent item $url" );
}


#
#
# Test /items?name=:name 
#
#

# Ensure some sample items give correct properties

for my $expected ( @test_items ) {
	my $uri = URI->new("https://$host/items");
	$uri->query_form( name => $expected->{name} );
	my $req = HTTP::Request->new(GET => $uri);
	my $res = $ua->request($req);

	ok( $res->is_success, "requesting $uri");
	my $item = ( decode_json( $res->content ) )->{items}[0];
	for my $field ( qw/id name type constlevel mainlevel mpath gemcost/ ) {
		is( $item->{$field}, $expected->{$field}, "  $field" );
	}
}

# Non-existent item names and items with duplicate names

while ( my ( $item_name, $expected_num ) = each %item_counts ) {
	my $uri = URI->new("https://$host/items");
	$uri->query_form( name => $item_name );
	my $req = HTTP::Request->new(GET => $uri);
	my $res = $ua->request($req);

	ok( $res->is_success, "requesting $uri");
	my $items = ( decode_json( $res->content ) )->{items};
	is( @$items, $expected_num, '  counting items' );
}

#
#
# Test /items?name=:name with fuzzy matching
#
#

for my $expected ( @test_items ) {
	my $uri = URI->new("https://$host/items");
	$uri->query_form( name => $expected->{name}, match => 'fuzzy' );
	my $req = HTTP::Request->new(GET => $uri);
	my $res = $ua->request($req);

	ok( $res->is_success, "requesting $uri");
	my $items = ( decode_json( $res->content ) )->{items};
	is( @$items, 1, '  counting matches' );
	my $item = $items->[0];
	for my $field ( qw/id name type constlevel mainlevel mpath gemcost/ ) {
		is( $item->{$field}, $expected->{$field}, "  $field" );
	}
}

while ( my ( $query, $expected_name ) = each %fuzzy_matches ) {
	my $uri = URI->new("https://$host/items");
	$uri->query_form( name => $query, match => 'fuzzy' );
	my $req = HTTP::Request->new(GET => $uri);
	my $res = $ua->request($req);

	ok( $res->is_success, "requesting $uri");
	my $items = ( decode_json( $res->content ) )->{items};
	is( $items->[0]{name}, $expected_name, '  name' );
}


