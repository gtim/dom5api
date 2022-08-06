#
# unit_dismabiguation.pl
#
# Script to investigate which same-name units can be disambiguated by using 
# different unit properties, such as size or nation.
#

use 5.34.0;

use List::Util 'uniq';

use DBI;
use DBD::SQLite::Constants qw/:file_open/;

my $dbh = DBI->connect("dbi:SQLite:dbname=../data/units.db",undef,undef, {
	sqlite_open_flags => SQLITE_OPEN_READONLY,
});


# get non-unique names


sub get_nonunique_names {
	my $dbh = shift;
	my $sth_groups = $dbh->prepare("SELECT count(*) num_units, name FROM units GROUP BY name HAVING num_units >= 2 ORDER BY min(id) ASC");
	$sth_groups->execute();
	my @nonunique_names;
	push @nonunique_names, $_->[1] while ( $_ = $sth_groups->fetch );
	return @nonunique_names;
}

my @nonunique_names = get_nonunique_names($dbh);


# for each group, try to disambiguate


sub get_units_with_name {
	my ( $dbh, $name ) = @_;
	my $sth = $dbh->prepare("SELECT name, size FROM units WHERE name = ?");
	$sth->execute($name);
	my $units = $sth->fetchall_arrayref({});
	return @$units;
}

my @still_ambiguous_names;

for my $name ( @nonunique_names ) {
	my @units = get_units_with_name( $dbh, $name );

	# try disambiguating on size
	
	my @sizes = map { $_->{size} } @units;
	if ( @sizes == uniq sort @sizes ) {
		say "  size: $name (@sizes)";
		next;
	}

	push @still_ambiguous_names, $name;

}


printf "%d non-unique name groups\n", 0+@nonunique_names;
printf "%d stlil ambiguous\n", 0+@still_ambiguous_names;
