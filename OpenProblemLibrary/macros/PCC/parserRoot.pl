################################################################################
# WeBWorK Online Homework Delivery System
# Copyright © 2000-2013 The WeBWorK Project, http://openwebwork.sf.net/
# $CVSHeader: pg/macros/parserPrime.pl,v 1.2 2009/10/03 15:58:49 dpvc Exp $
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

parserRoot.pl - defines a root(n,x) function for n-th root of x.

=head1 DESCRIPTION

This file defines the code necessary to add a root(n,x) function to
any context that performs the n-th root of x.  For example,
Compute("root(3,27)") would return the equivalent of Real(3).

To accomplish this, put the line

	loadMacros("parserRoot.pl");

at the beginning of your problem file, then set the Context to the one
you wish to use in the problem.  Then use the command:

	parser::Root->Enable;

(You can also pass the Enable command a pointer to a context if you
wish to alter a context other than the current one.)

Once that is done, you (and students) can enter roots by using the
root() function.  You can use root() both within Formula() and
Compute() calls, and in Perl expressions, such as

        $n = root(3,27);

to obtain n-th roots.

=cut

sub _parserRoot_init {
  main::PG_restricted_eval('sub root {Parser::Function->call("root",@_)}');
}

package parser::Root;

sub Enable {
  my $self = shift;
  my $context = shift;
  $context = main::Context() unless Value::isContext($context);
  $context->functions->add(
    root => {class => 'parser::Root::Function::numeric2'},
  );
}

package parser::Root::Function::numeric2;
our @ISA = ('Parser::Function::numeric2');

sub root {
  shift; my $n = shift; my $x = shift;
  return $x**(1/$n);
}

sub TeX {
  my $self = shift;
  my ($n,$x) = ($self->{params}[0],$self->{params}[1]);
  return '\sqrt['.$n->TeX."]{".$x->TeX."}";
}

1;
