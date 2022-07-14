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

=head3 name

This returns the name of the person.

C< my $p = new Person({ name => 'Roger', pronoun => 'he'})>

C< $p->name> returns the name.

=cut

sub name { return shift->{_name}; }

=head3 pronoun

This returns the pronoun as a lower case.

C<$p->pronoun> returns the pronoun. In this case 'he'.

=cut

sub pronoun { return shift->{_pronoun}; }

=head3 Pronoun

This returns the pronoun as an upper case.

C<$p->Pronoun> returns the upper case pronoun. In this case 'He'.

=cut

sub Pronoun { return ucfirst(shift->{_pronoun}); }

=head3 verb

Outputs the correct conjugation of the verb.  Pass in the singular and plural forms of the
verbs in that order.

For example if C<$p1 = new Person({ name => 'Roger', pronoun => 'he' })> and
C<$p2 = new Person({ name => 'Max', pronoun 'they'})> then

C<$p1->verb('finds', 'find')> outputs C<'finds'>

C<$p2->verb('is','are')> outputs C<'are'>

=cut

sub verb {
	my ($self, $sing, $plur) = @_;
	return $self->{_pronoun} eq 'they' ? $plur : $sing;
}

1;