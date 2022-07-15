=head1 NAME

PGnamemacros.pl - Load macros for random names.

=head2 SYNOPSIS

 loadMacros('PGnamesmacros.pl');

=head2 DESCRIPTION

PGnamemacros.pl provides a randomName function that generates a random name with pronouns.  In addition,
there is the capability of providing pronouns with and without capitilization and verb conjugation.

Note: this idea was taken from the PCCmacros.pl RandomName subroutine to extend to
the handling of pronouns.

=head2 USAGE

First load the C<PGnamesmacro> with

C<loadMacros('PGnamesmacros.pl');>

and then call the randomName subroutine

C< $p1 = randomName() >

The variable C<$p1> is now a C<Person> object with methods to access the names, pronouns
and verb conjugation.  It is can be used within a problem as

C<BEGIN_PGML>
C<[@ $p1->name @] [@ $p1->verb('travels','travel') @] 1.5 miles to school.  After school,
[$p1->pronoun] then [$p1->]


=cut

my $names = {
	'Aaliyah'=>'she',
	'Aaron'=>'he',
	'Adrian'=>'she',
	'Aiden' => 'they',
	'Alejandro'=>'he',
	'Aleric'=>'he',
	'Alex'=>'they',
	'Alisa'=>'she',
	'Alyson'=>'she',
	'Amber'=>'she',
	'Andrew'=>'he',
	'Annaly'=>'she',
	'Anthony'=>'he',
	'Ashley'=>'she',
	'Barbara'=>'she',
	'Benjamin'=>'he',
	'Blake'=>'he',
	'Bobbi'=>'she',
	'Brad'=>'he',
	'Brent'=>'he',
	'Briana'=>'she',
	'Candi'=>'she',
	'Carl'=>'he',
	'Carly'=>'she',
	'Carmen'=>'she',
	'Casandra'=>'she',
	'Charity'=>'she',
	'Charlotte'=>'she',
	'Cheryl'=>'she',
	'Chris'=>'he',
	'Cody'=>'he',
	'Connor'=>'he',
	'Corey'=>'he',
	'Daniel'=>'he',
	'Dave'=>'he',
	'Dawn'=>'she',
	'Dennis'=>'he',
	'Derick'=>'he',
	'Devon'=>'he',
	'Diane'=>'she',
	'Don' => 'they',
	'Donna'=>'she',
	'Douglas'=>'he',
	'Dylan'=>'they',
	'Eileen'=>'she',
	'Eliot'=>'they',
	'Elishua'=>'she',
	'Emiliano'=>'he',
	'Emily'=>'she',
	'Eric'=>'he',
	'Evan'=>'he',
	'Fabrienne'=>'she',
	'Farshad'=>'he',
	'Gosheven'=>'he',
	'Grant'=>'he',
	'Gregory'=>'he',
	'Gustav'=>'he',
	'Haley'=>'she',
	'Hannah'=>'she',
	'Hayden'=>'he',
	'Heather'=>'she',
	'Henry'=>'he',
	'Holli'=>'she',
	'Huynh'=>'he',
	'Irene'=>'she',
	'Ivan'=>'he',
	'Izabelle'=>'she',
	'James'=>'he',
	'Janieve'=>'she',
	'Jay'=>'he',
	'Jeff'=>'he',
	'Jenny'=>'she',
	'Jerry'=>'he',
	'Jessica'=>'she',
	'Jon'=>'he',
	'Jordan'=>'they',
	'Joseph'=>'he',
	'Joshua'=>'he',
	'Julie'=>'she',
	'Kandace'=>'she',
	'Kara'=>'she',
	'Katherine'=>'she',
	'Kayla'=>'she',
	'Ken'=>'he',
	'Kenji'=>'he',
	'Kim'=>'she',
	'Kimball'=>'he',
	'Kristen'=>'she',
	'Kurt'=>'he',
	'Kylie'=>'she',
	'Kyrie'=>'he',
	'Laney'=>'she',
	'Laurie'=>'she',
	'Lesley'=>'she',
	'Lily'=>'she',
	'Lin'=>'he',
	'Lindsay'=>'she',
	'Lisa'=>'she',
	'Luc'=>'they',
	'Malik'=>'he',
	'Marc'=>'he',
	'Maria'=>'she',
	'Martha'=>'she',
	'Matthew'=>'he',
	'Matty'=>'they',
	'Max'=>'they',
	'Maygen'=>'she',
	'Michael'=>'he',
	'Michele'=>'she',
	'Morah'=>'she',
	'Nathan'=>'he',
	'Neil'=>'he',
	'Nenia'=>'she',
	'Nicholas'=>'he',
	'Nina'=>'she',
	'Olivia'=>'she',
	'Page'=>'she',
	'Parnell'=>'he',
	'Penelope'=>'she',
	'Perlia'=>'she',
	'Peter'=>'he',
	'Phil'=>'he',
	'Priscilla'=>'she',
	'Randi'=>'he',
	'Ravi'=>'he',
	'Ray'=>'they',
	'Rebecca'=>'she',
	'Renee'=>'she',
	'Rita'=>'she',
	'Ronda'=>'she',
	'Ross'=>'he',
	'Ryan'=>'he',
	'Samantha'=>'she',
	'Sarah'=>'she',
	'Scot'=>'he',
	'Sean'=>'he',
	'Sebastian'=>'he',
	'Selena'=>'she',
	'Shane'=>'he',
	'Sharell'=>'she',
	'Sharnell'=>'she',
	'Sherial'=>'she',
	'Stephanie'=>'she',
	'Stephen'=>'he',
	'Subin'=>'she',
	'Sydney'=>'she',
	'Tammy'=>'she',
	'Teresa'=>'she',
	'Thanh'=>'he',
	'Tien'=>'he',
	'Tiffany'=>'she',
	'Timothy'=>'he',
	'Tracey'=>'she',
	'Virginia'=>'she',
	'Wendy'=>'she',
	'Wenwu'=>'he',
	'Will'=>'he'
};

sub randomPerson {
        my @names = lex_sort(keys(%$names));
        my $random_name = list_random(@names);
	return Person->new({ name => $random_name, pronoun => $names->{$random_name}});
}

=pod
=head2 package Person

This makes a Person class to handle name and pronouns of a Person.

Make a person with C<new Person({ name => 'Roger', pronoun => 'he'})> as an example. This is
often used with the C<randomPerson> method which returns a blessed Person object
which can be used in problems to write a problem with a random name with pronouns
and verb conjugation.

=cut



package Person;

sub new {
	my ($class, $p) = @_;
	my $self = {
		_name => $p->{name},
		_pronoun => $p->{pronoun}
	};
	bless $self, $class;
	return $self;
}

=pod
=head3 name

This returns the name of the person.

C< my $p = new Person({ name => 'Roger', pronoun => 'he'})>

C< $p->name> returns the name.

=cut

sub name { return shift->{_name}; }

=pod
=head3 pronoun

This returns the pronoun as a lower case.

C<$p->pronoun> returns the pronoun. In this case 'he'.

=cut

sub pronoun { return shift->{_pronoun}; }

=pod
=head3 Pronoun

This returns the pronoun as an upper case.

C<$p->Pronoun> returns the upper case pronoun. In this case 'He'.

=cut

sub Pronoun { return ucfirst(shift->{_pronoun}); }

=pod
=head3 verb

Outputs the correct conjugation of the verb.  If only one verb is passed in, it should
be regular and the plural (without an s) version.

For example if C<$p1 = new Person({ name => 'Roger', pronoun => 'he' })> and
C<$p2 = new Person({ name => 'Max', pronoun 'they'})> then

C<$p1->verb('find')> outputs C<'finds'>

C<$p2->vert('find')> outputs C<'find'>


If two arguments are passed in, they should be the singular and plural forms of the
verbs in that order.

For example if C<$p1 = new Person({ name => 'Roger', pronoun => 'he' })> and
C<$p2 = new Person({ name => 'Max', pronoun 'they'})> then

C<$p1->verb('are', 'is')> outputs C<'is'>

C<$p2->verb('are', 'is')> outputs C<'are'>

=cut

sub verb {
	my ($self, $sing, $plur) = @_;
	return defined($plur) ?
		($self->{_pronoun} eq 'they' ? $plur : $sing) :
		($self->{_pronoun} eq 'they' ? $sing : $sing . 's');
}

1;
