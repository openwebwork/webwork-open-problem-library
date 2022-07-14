use warnings;
use strict;

package main;

use Test::More;
use Test::Exception;

# The following needs to include at the top of any testing down to END OF TOP_MATERIAL.

my $current_dir;

BEGIN {
	die "PG_ROOT not found in environment.\n" unless $ENV{PG_ROOT};
	$main::pg_dir = $ENV{PG_ROOT};

	use File::Basename qw/dirname/;
	use Cwd qw/abs_path/;
	$current_dir = dirname(abs_path(__FILE__));

}

use lib "$main::pg_dir/lib";
use lib "$current_dir";

require("$main::pg_dir/t/build_PG_envir.pl");

## END OF TOP_MATERIAL

require 'PGnamesmacro.pl';

use Person;

my $p1 = Person->new({ name => 'Fred', pronoun => 'he' });
my $p2 = Person->new({ name => 'Gabriella', pronoun => 'she' });
my $p3 = Person->new({ name => 'Kai', pronoun => 'they' });

is($p1->name, 'Fred', 'Test the name method for Fred');
is($p1->pronoun, 'he', 'Test the pronoun method for Fred');
is($p1->Pronoun, 'He', 'Test the pronoun method for Fred');
is($p1->verb('finds','find'), 'finds', 'Tests the conjugation of the verb find for Fred.');
is($p1->verb('is','are'), 'is', 'Tests the conjugation of the verb is for Fred.');


is($p2->name, 'Gabriella', 'Test the name method for Gabriella');
is($p2->pronoun, 'she', 'Test the pronoun method for Gabriella');
is($p2->Pronoun, 'She', 'Test the pronoun method for Gabriella');
is($p2->verb('finds','find'), 'finds', 'Tests the conjugation of the verb find for Gabriella.');
is($p2->verb('is','are'), 'is', 'Tests the conjugation of the verb is for Gabriella.');

is($p3->name, 'Kai', 'Test the name method for Kai');
is($p3->pronoun, 'they', 'Test the pronoun method for Kai');
is($p3->Pronoun, 'They', 'Test the pronoun method for Kai');
is($p3->verb('finds','find'), 'find', 'Tests the conjugation of the verb find for Kai.');
is($p3->verb('is','are'), 'are', 'Tests the conjugation of the verb is for Kai.');

done_testing;