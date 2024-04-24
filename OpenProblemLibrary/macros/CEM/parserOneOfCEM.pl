################################################################################
# WeBWorK Online Homework Delivery System
# Copyright © 2000-2012 The WeBWorK Project, http://openwebwork.sf.net/
# $CVSHeader$
# 
# This program is free software; you can redistribute it and/or modify it under
# the terms of either: (a) the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version, or (b) the "Artistic License" which comes with this package.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See either the GNU General Public License or the
# Artistic License for more details.
################################################################################

=head1 NAME

parserOneOfCEM.pl - Implements a MathObject that allows students to entery any
                 one of several possible right answers.

=head1 DESCRIPTION

This file implements a MathObject that allows the student to answer
any one of several correct answers.  The correct answer (when shown in
the results table) will list all the possibilities.

To use it, load the macro file, and create a OneOfCEM() object:

	loadMacros(
	  "PGstandard.pl",
	  "MathObjects.pl",
	  "parserOneOfCEM.pl",
	);
	
	$ans = OneOfCEM(pi,"2x+1");

and create the answer checker as usual:

	ANS($ans->cmp);

If the student answers either "pi" or "2x+1" (or answers equivalent to
those), the answer will be marked correct.

You can control the format of the correct answer string using the
following flags on the OneOfCEM object:

    separator => ", "             The string to use for the separator between
                                  choices in the correct answer string

    or => " or "                  The string to use before the final choice

    tex_separator => "\hbox{, }"  The string to use for the separator between
                                  choices for TeX output

    tex_or => "\hbox{ or }"       The string to use before the final choice in
                                  TeX output strings

    format => string or code      An sprintf-style format string to be used to
                                  format the choices, or a code reference to
                                  a subroutine that accepts the entries as input
                                  and returns the formatted string.

    tex_format => string or code  Same as format above, but for use in tex output.

You can set this using the with() method, or by setting the values explicitly.
For example,

    $ans = OneOfCEM(pi,"2x+1",34)->with(separator=>"; ",tex_separator=>";\,");

or

    $ans = OneOfCEM(pi,"2x+1",34);
    $ans->{separator} = "; ";
    $ans->{tex_separator} = ";\, ";

=cut

sub _parserOneOfCEM_init {parser::OneOfCEM::Init()}

######################################################################

package parser::OneOfCEM;
our @ISA = ('Value::List');

my $SEPARATOR = ", ";  # default separator
my $OR = " or ";       # default "or" word

#
#  Define the OneOfCEM() creator function
#
sub Init {
  main::PG_restricted_eval('sub OneOfCEM {parser::OneOfCEM->new(@_)}');
}

#
#  Use Compute() to handle each of the entries so correct_ans will be set
#   for each entry
#
sub new {
  my $self = shift; my @params = (@_);
  foreach $x (@params) {$x = main::Compute($x) unless Value::isValue($x)}
  return $self->SUPER::new(@params);
}

#
#  Return the type of the first entry (usually these will all be the same)
#
sub type {
  my $self = shift;
  $self->{data}[0]->type;
}

#
#  Try to match against all the entries, and if any one of them matches,
#  go with it.
#
sub typeMatch {
  my $self = shift; my $other = shift;
  return &{$self->{typeMatch}}($other) if ref($self->{typeMatch}) eq "CODE";
  foreach $x (@{$self->{data}}) {return 1 if $x->typeMatch($other)}
  return 0;
}

#
#  Return the class for the first entry
#
sub cmp_class {
  my $self = shift; return $self->{cmp_class} if defined($self->{cmp_class});
  my $x = $self->{data}[0];
  return $x->{cmp_class} || $x->cmp_class();
}

#
#  Use the standard cmp_equal, not the list version, since
#  this acts as a single item not a list.
#
sub cmp_equal {
  Value::cmp_equal(@_);
}

#
#  Check if the student value equals one of the ones in the correct-answer list
#  and return the result of that comparison if it is correct.
#  (FIXME: should this check all and return the highest score?)
#

sub cmp_compare {
  my ($self,$other,$ans)=@_;
  foreach $x (@{$self->{data}}) {
    if ($x->typeMatch($other)) {
      my $result = $x->cmp->evaluate($other);
      if ($result->{score}) {
        $ans->score($result->{score});
        $ans->{ans_message} = $result->{ans_message};
        return $ans->{score};
      }
#      if ($result->{ans_message}) {
#        $ans->{ans_message} = $result->{ans_message}
#           if !$ans->{ans_message} || lenght($ans->{ans_message}) > lenght($result->{ans_message});
#      }
    }
  }
  return 0;
}

#
#  Produce the correct answer by combining correct answers of the originals.
#
sub correct_ans {
  my $self = shift;
  my $sep = $self->getFlag("separator",$SEPARATOR);
  my $or  = $self->getFlag("or",$OR);
  Value::preformat($self->format("correct_ans",$sep,$or));
}

#
#  Produce the string version by making a comma separated list with " or " for the last comma
#
sub string {
  my $self = shift;
  my $sep = $self->getFlag("separator",$SEPARATOR);
  my $or  = $self->getFlag("or",$OR);
  $self->format("string",$sep,$or);
}

#
#  Produce the TeX version by making a comma separated list with " or " for the last comma
#
sub TeX {
  my $self = shift;
  my $sep = $self->getFlag("tex_separator","\\hbox{$SEPARATOR}");
  my $or  = $self->getFlag("tex_or","\\hbox{$OR}");
  $self->format("TeX",$sep,$or);
}

#
#  Produce a list of entries separated by $sep with $or as the final separator.
#  The entries are converted using the given $method of the entry.
#  If there is a format (or tex_format) flag, use that to format the list instead.
#
sub format {
  my $self = shift;
  my $method = shift; my $sep = shift; my $or = shift;
  my @c = map {(defined($_->{$method})? $_->{$method} : $_->$method)} @{$self->{data}};
  my $format = $self->getFlag(($method eq "TeX" ? "tex_" : "")."format");
  return &$format(@c) if ref($format) eq "CODE";
  return sprintf($format,@c) if $format;
  return $c[0] unless scalar(@c) > 1;
  return join($or,@c) if scalar(@c) == 2;
  my $last = pop(@c); $or = "$sep$or";
  $or =~ s/(\\hbox\{.+?)\}\\hbox\{/$1/; $or =~ s/  +/ /g; # clear up some extra spacing
  return join($sep,@c).$or.$last;
}

#
#  Make a list containing a formula object rather than a
#  formula returning a list.
#
sub formula {
  my $self = shift; my $class = ref($self) || $self;
  bless {data => shift, context => $self->context}, $class;
}

1;
