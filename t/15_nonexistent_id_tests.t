#!/usr/bin/perl -w

#
# 15_nonexistent_id_tests.t
#
# Ensure invalid IDs return 404.
#

use 5.34.0;
use utf8;
use Test::More;
use LWP::UserAgent;
use URI;

use FindBin qw( $RealBin );
use lib "$RealBin/lib";
use List::Util 'sum';
use Test::Utils;

my $ua = LWP::UserAgent->new;

my %invalid_ids = (
	items      => [ 446, 500,     0, -1, 1e6, 'foo', sprintf('%.0f',2**50), "'" ],
	spells     => [ 1, 149, 1177, 0, -1, 1e6, 'foo', sprintf('%.0f',2**50), "'" ],
	units      => [ 4000, 10,     0, -1, 1e6, 'foo', sprintf('%.0f',2**50), "'" ],
	commanders => [ 1, 4000, 10,  0, -1, 1e6, 'foo', sprintf('%.0f',2**50), "'" ],
	sites      => [ 1200,         0, -1, 1e6, 'foo', sprintf('%.0f',2**50), "'" ],
	mercs      => [ 100,          0, -1, 1e6, 'foo', sprintf('%.0f',2**50), "'" ],
);

plan tests => sum map { 0 + @$_ } values %invalid_ids;


for my $category ( keys %invalid_ids ) {
	for my $id ( @{ $invalid_ids{$category} } ) {
		my $url = sprintf( 'https://%s/%s/%s', $Test::Utils::host, $category, $id );
		my $req = HTTP::Request->new( GET => $url );
		my $res = $ua->request($req);
		is( $res->code, 404, "non-existent at $url" );
	}
}

