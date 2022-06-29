#!/usr/bin/perl -w

#
# run_api_test.pl
#
# Runs a test suite against the live API.
#

use 5.34.0;
use Test::More;
use LWP::UserAgent;
use JSON 'decode_json';

my $host = 'dom5api.illwiki.com';
my $ua = LWP::UserAgent->new;

#
#
# Test /items/:id endpoint
#
#


#
# Ensure some sample items give correct properties
#

my %item_id_tests = (
	  1 => { name => 'Fire Sword', type => '1-h wpn', constlevel => 0,  mainlevel => 1, mpath => 'F1',   gemcost => '5F'    },
	100 => { name => 'Moon Blade', type => '2-h wpn', constlevel => 4,  mainlevel => 1, mpath => 'S1',   gemcost => '5S'    },
	400 => { name => 'Precious',   type => 'misc',    constlevel => 12, mainlevel => 2, mpath => 'F2',   gemcost => '10F'   },
	445 => { name => 'Jinn Bottle',type => 'misc',    constlevel => 6,  mainlevel => 2, mpath => 'A2E1', gemcost => '10A5E' },
);

plan tests => keys(%item_id_tests) * 8;
while ( my ( $item_id, $expected ) = each %item_id_tests ) {
	my $url = "https://$host/items/$item_id";
	my $req = HTTP::Request->new(GET => $url);
	my $res = $ua->request($req);

	ok( $res->is_success, "request to $url");
	my $item = decode_json( $res->content );
	is( $item->{id}, $item_id, '  id');
	for my $field ( qw/name type constlevel mainlevel mpath gemcost/ ) {
		is( $item->{$field}, $expected->{$field}, "  $field" );
	}
}

#
# Tests to implement:
# - ensure screenshot URL is returned
# - ensure screenshot is a PNG image
# - invalid item IDs: ensure 404 returned
# - /items?name=:name endpoint
#   - invalid item names: ensure none returned
#   - duplicate item names: ensure both returned
# - /items?name=:name&match=fuzzy endpoint
#   - sensible examples
#


