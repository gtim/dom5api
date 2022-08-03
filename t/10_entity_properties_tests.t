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

my $host = 'dom5api.illwiki.com';
my $ua = LWP::UserAgent->new;

plan tests => sum map { 0 + keys %$_ } @Test::Utils::sample_entities; # one test per element except "category", plus one test for request status

for my $expected ( @Test::Utils::sample_entities ) {
	my $id = $expected->{id};
	my $url = "https://$host/$expected->{category}/$id";
	my $req = HTTP::Request->new(GET => $url);
	my $res = $ua->request($req);

	ok( $res->is_success, "requesting $url");
	my $received = decode_json( $res->content );
	for my $field ( keys %$expected ) {
		next if $field eq 'category'; # "category" not tested, only needed for endpoint URL
		is( $received->{$field}, $expected->{$field}, "  $field" );
	}
}
