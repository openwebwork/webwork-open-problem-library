=head1 NAME

PGnamemacros.pl - Load macros for random names.

=head1 SYNOPSIS

 loadMacros('PGnamemacros.pl');

=head1 DESCRIPTION

PGnamemacros.pl provides a randomName function that generates a random name with pronouns.  In addition,
there is the capability of providing pronouns with and without capitilization and verb conjugation.

=cut

# sub list_random {
# 	my @values = @_;
# 	my $n = scalar(@values);
# 	my $i = int($n*rand());
# 	return $values[$i];
# }

use YAML::XS;

sub randomPerson {
	my @names = LoadFile('names-pronouns.yml');
	return Person->new(list_random(@names));
}

1;