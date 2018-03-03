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

Context file to check that the students answer is completely factored
when compared with the answer. 

The flag factorableObject defaults to 'polynomial', but it could be set to say, 'rational expression', etc. It is used in error messages.

=cut

loadMacros(
    "bizarroArithmetic.pl",

);

#
#  Set up the LimitedFactor context
#
sub _contextLimitedFactor_init {
  my $context = $main::context{LimitedFactor} = Parser::Context->getCopy("Numeric");
  $context->operators->set(
     '+'  => {class => 'bizarro::BOP::add', isCommand => 1},
     '-'  => {class => 'bizarro::BOP::subtract', isCommand => 1},
     '/'  => {class => 'bizarro::BOP::divide', isCommand => 1},
  );

  main::PG_restricted_eval('sub root {Parser::Function->call("root",@_)}');
  $context->functions->add(
    root => {class => 'my::Function::numeric2'},
  );
  $context->flags->set(limits => [1,5]);   # no negatives in the radicals  
  $context->flags->set(factorableObject => 'polynomial');
  $context->{cmpDefaults}{Formula}{checker} = sub {
    my ($correct,$student,$ans) = @_;
    return 0 if $ans->{isPreview} || $correct != $student;
    $student = $ans->{student_formula};
    $correct = $correct->{original_formula} if defined $correct->{original_formula};
    # check for equivalence when bizarro arithmetic is enforced
    Context()->flags->set(bizarroSub=> 1,bizarroAdd=> 1, bizarroDiv=> 1);
    delete $correct->{test_values};
    delete $student->{test_values};
    my $OK = ($correct == $student); # check if equal when arithmetic is replace by bizarro arithmetic
    Context()->flags->set(bizarroSub=> 0,bizarroAdd=> 0, bizarroDiv=> 0);
    $factorableObject = Context()->flag("factorableObject");
    Value::Error("Your answer is equivalent to the $factorableObject in the correct answer, but not completely factored or simplified") unless $OK;
    return $OK;
  };

}



1;
