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
is($p1->verb('find'), 'finds', 'Tests the conjugation of the verb find for Fred.');
is($p1->verb('is','are'), 'is', 'Tests the conjugation of the verb is for Fred.');


is($p2->name, 'Gabriella', 'Test the name method for Gabriella');
is($p2->pronoun, 'she', 'Test the pronoun method for Gabriella');
is($p2->Pronoun, 'She', 'Test the pronoun method for Gabriella');
is($p2->verb('find'), 'finds', 'Tests the conjugation of the verb find for Gabriella.');
is($p2->verb('is','are'), 'is', 'Tests the conjugation of the verb is for Gabriella.');

is($p3->name, 'Kai', 'Test the name method for Kai');
is($p3->pronoun, 'they', 'Test the pronoun method for Kai');
is($p3->Pronoun, 'They', 'Test the pronoun method for Kai');
is($p3->verb('find'), 'find', 'Tests the conjugation of the verb find for Kai.');
is($p3->verb('is','are'), 'are', 'Tests the conjugation of the verb is for Kai.');

my $rando = randomPerson();

# Since the randomPerson() method use PGrandom, the seed is consistent, the person is
# Brad. Note: may need to be updated if the list changes.

is(ref $rando, 'Person', 'Check that the randomPerson method returns an object of Person class');
is($rando->name, 'Brad', 'Check that the randomPerson method with standard seed returns Brad');

done_testing;