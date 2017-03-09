################################################################################
# WeBWorK Online Homework Delivery System
# Copyright © 2000-2013 The WeBWorK Project, http://openwebwork.sf.net/
# $CVSHeader: pg/macros/contextInequalities.pl,v 1.23 2010/03/22 11:01:55 dpvc Exp $
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

Context("InequalitySetBuilder"), Context("InequalitySetBuilder-Only") - Provides
contexts that allow sets to be specified using set-builder notation and inequalities.

=head1 DESCRIPTION

Implements contexts that provides for sets described using set-builder
notation with inequalities.  (This actually is a special way of
creating Intervals, Sets, and Unions, and they can be used together
with standard interval notation.)  There are two such contexts:
Context("InequalitySetBuilder"), in which both intervals and sets
formed by inequalities are defined, and
Context("InequalitySetBuilder-Only"), which allows only set-builder
notation (not intervals or point sets).

=head1 USAGE

	loadMacros("contextInequalitySetBuilder.pl");
	
	Context("InequalitySetBuilder");
	$S1 = Compute("{ x : 1 < x <= 4 }");
	$S2 = SetBuilder("(1,4]");     # force interval to be inequality
	
	Context("InequalitySetBuilder-Only");
	$S1 = Compute("{ x : 1 < x <= 4 }");
	$S2 = SetBuilder("(1,4]");     # generates an error
	
	$S3 = Compute("{ x : x < -2 or x > 2 }");  # forms the Union (-inf,-2) U (2,inf)
	$S4 = Compute("{ x : x > 2 and x <= 4 }"); # forms the Interval (2,4]
	$S5 = Compute("{ x : x = 1 }");            # forms the Set {1}
	$S6 = Compute("{ x : x != 1 }");           # forms the Union (-inf,1) U (1,inf)

The InequalitySetBuilder contexts accept the flags for the
Inequalities contexts from the contextInequalities.pl file (see its
documentation for details).

Set-builder and interval notation both can coexist side by side, but
you may wish to convert from one to the other.  Use SetBuilder() to
convert from an Interval, Set or Union to an Inequality, and use
Interval() to convert from an Inequality object to one in interval
notation.  For example:

	$I0 = Compute("(1,2]");               # the interval (1,2]
	$I1 = SetBuilder($I1);                # the set { x : 1 < x <= 2 }
	
	$I0 = Compute("{ x : 1 < x <= 2 }");  # the set { x : 1 < x <= 2 }
	$I1 = Interval($I0);                  # the interval (1,2]

Note that sets and intervals can be compared and combined
regardless of the format, so $I0 == $I1 is true in either example
above.

Since SetBuilder objects are actually Interval objects in disguise,
the variable used to create them doesn't matter.  That is,

	$I0 = Compute("{ x : 1 < x <= 2 }");
	$I1 = Compute("{ y : 1 < y <= 2 }");

would both produce the same interval, so $I0 == $I1 would be true in
this case.  If you need to distinguish between these two, use

	$I0 == $I1 && $I0->{varName} eq $I1->{varName}

instead.

Note that the "such that" symbol is ":" since the vertical line is
already in use for absolute values.  If you wish to use "|" rather
than ":", you can do that, but must then use "abs()" to obtain
absolute values.  To enable the vertical line as "such that", use

        InequalitySetBuilder::UseVerticalSuchThat();

prior to setting the context to one of the set-builder contexts.  This
will disable ":" and enable "|" as such-that rather than absolute-value.

=cut

loadMacros("contextInequalities.pl");

sub _contextInequalitySetBuilder_init {InequalitySetBuilder::Init()}

package InequalitySetBuilder;

sub Init {
  #
  #  Make a new context from an old one and add SetBuilder notation
  #
  my $addSetBuilder = sub {
    my ($new,$old) = @_;
    my $context = $main::context{$new} = Parser::Context->getCopy($old);
    $context->{name} = $new;
    $context->operators->add(
      ":" => {precedence => .25, associativity => "left", type => "bin", string => " : ",
              class => "InequalitySetBuilder::BOP::suchthat"},
      "_suchthat" => {alias => ":", hidden => 1},
    );
    $context->operators->set(
      "+" => {class => "InequalitySetBuilder::BOP::add"},
      "-" => {class => "InequalitySetBuilder::BOP::subtract"},
      "U" => {class => "InequalitySetBuilder::BOP::union"},
    );
    $context->lists->set(Set => {class => "InequalitySetBuilder::List::Set"});
    $context->{precedence}{InequalitySetBuilder} = $context->{precedence}{Inequality} + .5;
    $context->{value}{SetBuilder} = "InequalitySetBuilder::SetBuilder";
    $context->{value}{InequalitySetBuilder} = "InequalitySetBuilder::SetBuilder";
    $context->{value}{InequalitySetBuilderInterval} = "InequalitySetBuilder::Interval";
    $context->{value}{InequalitySetBuilderUnion} = "InequalitySetBuilder::Union";
    $context->{value}{InequalitySetBuilderSet} = "InequalitySetBuilder::Set";
    $context->{error}{msg}{"You are not allowed to use intervals or sets in this context"} =
      "You are not allowed to use intervals in this context";
    return $context;
  };

  #
  #  Make the two new contexts
  #
  &{$addSetBuilder}("InequalitySetBuilder","Inequalities");
  &{$addSetBuilder}("InequalitySetBuilder-Only","Inequalities-Only")->flags->set(noSets => 1);

  #
  #  Define the SetBuilder() constructor
  #
  main::PG_restricted_eval('sub SetBuilder {Value->Package("SetBuilder")->new(@_)}');
}

sub UseVerticalSuchThat {
  my $adjust = sub {
    my $context = $main::context{$_[0]};
    $context->operators->remove(":");
    $context->operators->set(
      "|" => {precedence => .25, associativity => "left", type => "bin", string => " | ", TeX => ' \mid ',
              class => "InequalitySetBuilder::BOP::suchthat"},
      "_suchthat" => {alias => "|", hidden => 1},
    );
    $context->parens->remove("|");
  };
  &{$adjust}("InequalitySetBuilder");
  &{$adjust}("InequalitySetBuilder-Only");
}

##################################################
#
#  A class for making set-builder sets by hand
#
package InequalitySetBuilder::SetBuilder;
our @ISA = ('Value');

sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  my $S = shift; my $x = shift;
  $S = Value::makeValue($S,context=>$context);
  if (Value::classMatch($S,"InequalitySetBuilder")) {
    if (defined($x)) {$S->{varName} = $x; $S->updateParts}
    return $S;
  }
  $x = ($context->variables->names)[0] unless $x;
  $S = bless $S->inContext($context), $context->Package("InequalitySetBuilder".$S->type);
  $S->{varName} = $x; $S->{reduceSets} = $S->{"is".$S->Type} = 1;
  $S->updateParts;
  return $S;
}

##################################################
##################################################
#
#  The Parser object that holds the set-builder notation
#  (and also allows point-set notation)
#
package InequalitySetBuilder::List::Set;
our @ISA = ('Parser::List::Set');

sub _check {
  my $self = shift; my $arg = $self->{coords}[0];
  if ($self->{type}{length} == 1 && $arg->{isSuchThat}) {
    $self->{type}{list} = 0;
    $self->{type} = $arg->{type};
    $self->{isSetBuilder} = 1;
  } else {
    $self->SUPER::_check(@_);
    $self->Error("You are not allowed to use point sets in this context")
     if $self->context->flag("noSets");
  }
}

sub eval {
  my $self = shift;
  if ($self->{isSetBuilder}) {
    my $set = $self->{coords}[0]->{rop}->eval;
    return $set->demote if $set->string eq $self->context->flag("noneWord");
    $set->{isSetBuilder} = $set->{isInequality} = 1;
    bless $set, $self->Package("InequalitySetBuilder".$set->type);
    return $set;
  } else {
    return $self->SUPER::eval(@_);
  }
}

sub canBeInUnion {1}

##################################################
##################################################
#
#  The such-that operator
#
package InequalitySetBuilder::BOP::suchthat;
our @ISA = ('Parser::BOP');

sub _check {
  my $self = shift;
  $self->Error("%s should follow a variable name",$self->{bop})
    unless $self->{lop}->class eq 'Variable';
  $self->Error("The condition for the set should be an inequality")
    unless $self->{rop}{isInequality};
  $self->Error("The variable of the condition to the right of %s should match the variable on the left",$self->{bop})
    unless $self->{lop}{name} eq $self->{rop}{varName};
  $self->{type} = $self->{rop}->typeRef;
  $self->{isSuchThat} = 1;
  delete $self->{equation}{variables}{$self->{lop}{name}};
  $self->{lop} = Inequalities::DummyVariable->new($self->{equation},$self->{lop}{name},$self->{lop}{ref});
}

#
#  Make sure it is only used in set braces
#
sub eval {
  my $self = shift;
  $self->Error("'%s' can only appear within set-builder notation (did you forget braces?)",$self->{bop});
}

##################################################
#
#  Give a warning about adding sets
#
package InequalitySetBuilder::BOP::add;
our @ISA = ('Inequalities::BOP::add');

sub _check {
  my $self = shift;
  $self->SUPER::_check(@_);
  $self->Error("Can't add sets (do you mean to use a union?)")
    if $self->{lop}{isSetBuilder} || $self->{rop}{isSetBuilder};
}

##################################################
#
#  Handle subtraction of sets
#
package InequalitySetBuilder::BOP::subtract;
our @ISA = ("Inequalities::BOP::subtract");

sub _check {
  my $self = shift;
  if ($self->{lop}{isSetBuilder} && $self->{rop}{isSetBuilder})
    {$self->{isSetBuilder} = 1} else {$self->SUPER::_check(@_)}
}

##################################################
#
#  Handle unions of sets
#
package InequalitySetBuilder::BOP::union;
our @ISA = ("Parser::BOP::union");

sub _check {
  my $self = shift;
  if ($self->{lop}{isSetBuilder} && $self->{rop}{isSetBuilder})
    {$self->{isSetBuilder} = 1} else {$self->SUPER::_check(@_)}
}

##################################################
##################################################
#
#  Common function for the classes below
#

package InequalitySetBuilder::common;
our @ISA = ();

sub _updateParts {
  my $self = shift;
  $self->{isSetBuilder} = 1;
}

sub _apply {
  my $self = shift; my $I = shift;
  $I->{isSetBuilder} = 1;
  bless $I, $self->Package("InequalitySetBuilder".$I->type);
  return $I;
}

sub _string {
  my $self = shift; my $string = shift;
  my $bop = $self->context->operators->get("_suchthat") || {};
  while ($bop->{alias}) {$bop = $self->context->operators->get($bop->{alias})}
  return '{ '.$self->{varName}.($bop->{string}||' : ').$string.' }';
}

sub _TeX {
  my $self = shift; my $string = shift;
  my $bop = $self->context->operators->get("_suchthat") || {};
  while ($bop->{alias}) {$bop = $self->context->operators->get($bop->{alias})}
  return '\{ '.$self->{varName}.($bop->{TeX}||$bop->{string}||' : ').$string.' \}';
}

sub _typeMatch {
  my ($self,$other,$result) = @_;
  return 0 if ($result && $other->class eq 'Inequality');
  return $result;
}

sub class {"InequalitySetBuilder"}
sub cmp_class {"a Set in Set-Builder Notation"}
sub showClass {"a Set in Set-Builder Notation"}


##################################################
#
#  Special Inequalities::Interval subclass that
#  prints using set-builder notation.
#
package InequalitySetBuilder::Interval;
our @ISA = ('InequalitySetBuilder::common', 'Inequalities::Interval');

sub updateParts {my $self = shift; $self->_updateParts($self->SUPER::updateParts)}
sub apply       {my $self = shift; $self->_apply($self->SUPER::apply(@_))}
sub string      {my $self = shift; $self->_string($self->SUPER::string)}
sub TeX         {my $self = shift; $self->_TeX($self->SUPER::TeX)}
sub typeMatch   {my $self = shift; my $other = Value::makeValue(shift);
                 $self->_typeMatch($other,$self->SUPER::typeMatch($other))}

##################################################
#
#  Special Inequalities::Union subclass that
#  prints using set-builder notation.
#

package InequalitySetBuilder::Union;
our @ISA = ('InequalitySetBuilder::common', 'Inequalities::Union');

sub updateParts {my $self = shift; $self->_updateParts($self->SUPER::updateParts)}
sub apply       {my $self = shift; $self->_apply($self->SUPER::apply(@_))}
sub string      {my $self = shift; $self->_string($self->SUPER::string)}
sub TeX         {my $self = shift; $self->_TeX($self->SUPER::TeX)}
sub typeMatch   {my $self = shift; my $other = Value::makeValue(shift);
                 $self->_typeMatch($other,$self->SUPER::typeMatch($other))}

##################################################
#
#  Special Inequalities::Set subclass that
#  prints using set-builder notation.
#

package InequalitySetBuilder::Set;
our @ISA = ('InequalitySetBuilder::common', 'Inequalities::Set');

sub updateParts {my $self = shift; $self->_updateParts($self->SUPER::updateParts)}
sub apply       {my $self = shift; $self->_apply($self->SUPER::apply(@_))}
sub string      {my $self = shift; $self->_string($self->SUPER::string)}
sub TeX         {my $self = shift; $self->_TeX($self->SUPER::TeX)}
sub typeMatch   {my $self = shift; my $other = Value::makeValue(shift);
                 $self->_typeMatch($other,$self->SUPER::typeMatch($other))}

##################################################

1;
