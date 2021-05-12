################################################################################
# WeBWorK Online Homework Delivery System
# Copyright @copy; 2000-2018 The WeBWorK Project, http://openwebwork.sf.net/
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

Describe this context here.

=head1 DESCRIPTION

=cut

loadMacros(
  "MathObjects.pl",
  "bizarroArithmetic.pl",
  "contextInequalitySetBuilder.pl",
  "PGinfo.pl",
);

sub _contextRestrictedDomains_init {
  my $context = $main::context{RestrictedDomains} = Parser::Context->getCopy("InequalitySetBuilder");
  $context->{name} = "RestrictedDomains";
  $context->flags->set(
    reduceConstants =>0,
    reduceConstantFunctions => 0,
    formatStudentAnswer => "parsed",
    checkSqrt => 0, 
    checkRoot => 0,
    setSqrt => exp(1)/main::ln(2),
    wrongFormMessage => 'Your answer is algebraically equivalent to the correct answer, but not in the expected form. Maybe it is not fully simplified. Maybe something is not completely factored. Maybe it is not in the expected form for some other reason.',
    useBizarro => 1, 
    expressionWeight => 0.9,
  );
  $context->noreduce('(-x)+y','(-x)-y');
  $context->operators->set(
     '+' => {class => 'bizarro::BOP::add', isCommand => 1},       # override +
     '-' => {class => 'bizarro::BOP::subtract', isCommand => 1},  # override -
     ' ' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '*' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '* ' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     ' *' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '/' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     '/ ' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     ' /' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     '//' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
  );
  $context->operators->redefine('for',using=>',',from=>'Numeric');
  $context->operators->redefine(',for',using=>',',from=>'Numeric');
  $context->operators->redefine(', for',using=>',',from=>'Numeric');
  $context->operators->redefine('where',using=>',',from=>'Numeric');
  $context->operators->redefine(',where',using=>',',from=>'Numeric');
  $context->operators->redefine(', where',using=>',',from=>'Numeric');
  $context->operators->add('≠' => {precedence => .5, associativity => 'left', type => 'bin', string => ' != ', TeX => '\ne ',
class => 'Inequalities::BOP::inequality', eval => 'evalNotEqualTo'});
  $context->functions->set(sqrt=>{class=>'restrictedDomains::Function::numeric'}); # override sqrt()
  $context->functions->add(identity => {class => 'restrictedDomains::Function::numeric'});
  $context->{cmpDefaults}{Formula}{checker} = sub {
    my ($correct,$student,$ans) = @_;
    return 0 if $ans->{isPreview} || $correct != $student;
    $student = $ans->{student_formula};
    $student = Formula("identity($student)");  #ensure student is parsed as Formula object
    my $setSqrt = Context()->flag("setSqrt");
    my $useBizarro = Context()->flag("useBizarro");
    Context()->flags->set(checkSqrt => $setSqrt, bizarroAdd => $useBizarro, bizarroSub => $useBizarro, bizarroMul => $useBizarro, bizarroDiv => $useBizarro); 
    delete $correct->{test_values};
    delete $student->{test_values};
    my $OK = ($correct == $student); 
    Context()->flags->set(checkSqrt => 0, bizarroAdd => 0, bizarroSub => 0, bizarroMul => 0, bizarroDiv => 0); 
    Value::Error(Context()->flag('wrongFormMessage')) unless $OK;
    return $OK;
  };
  $showPartialCorrectAnswers = 1;
  $context->{cmpDefaults}{Formula}{showLengthHints} = 0;
  $context->{cmpDefaults}{Formula}{list_checker} = sub {
    my ($correct,$student,$ansHash,$value) = @_;
     my $score = 0;              # number of correct student answers
     my @errors = ();            # stores error messages
     my $i;                      # loop counters
     my $studentFormula = $ansHash->{student_formula};
     # Student answer needs to be a List consisting of a Formula/Real and then 0 or more Union/Interval/Sets
     if ($studentFormula->class ne 'Formula') {
       push(@errors,"Your answer isn't an expression with a possibly restricted domain");
       return (0,@errors);
     }
     if ($studentFormula->type ne 'Number' and $studentFormula->type ne 'List') {
       push(@errors,"Your answer isn't an expression with a possibly restricted domain");
       return (0,@errors);
     }
     my $studentList = $studentFormula;
     if ($studentFormula->type eq 'Number') {$studentList = Compute("$studentFormula, (-inf,inf)");};
     # Check that first item in list is a Formula that returns a number
     if (($studentList->value)[0]->type ne 'Number') {push(@errors,"The first part of your answer is not an expression")};
     $domainsCount = scalar($studentList->value) - 1;
     # Identify student answers like "1/x for x != 1, 2" and change to "1/x for x!=1, x!=2"
     my $alteredStudentList = Formula(($studentList->value)[0].", ".($studentList->value)[1]);
     for $i (2..$domainsCount) {
       my $dom = ($studentList->value)[$i];
       my $prevdom = ($alteredStudentList->value)[$i-1];
       if ($dom->type eq 'Number' and $prevdom->class eq 'Formula' and $prevdom->type eq 'Interval') {
         if (defined $prevdom->{tree}->{bop}) {
           if ($prevdom->{tree}->{bop} eq '!=') {
             my $x = (Context()->variables->variables)[0];
             $alteredStudentList = Formula($alteredStudentList->string.", $x != $dom");
           }
           else {$alteredStudentList = Formula($alteredStudentList->string.", $dom");}
         }
         else {$alteredStudentList = Formula($alteredStudentList->string.", $dom");}
       }
       else {$alteredStudentList = Formula($alteredStudentList->string.", $dom");}
     }
     $studentList = $alteredStudentList;
     for $i (1..$domainsCount) {
       my $dom = ($studentList->value)[$i];
       if ($dom->type ne 'Interval' and $dom->type ne 'Union' and $dom->type ne 'Set') {
         push(@errors,"Unable to understand how '".$dom->string."' describes the domain");
         return(0,@errors); 
       }
     }
     my $studentExpression = ($studentList->value)[0];
     my $studentDomain = Interval("(-inf,inf)");
     for my $i (1..$domainsCount) {
       $studentDomain = $studentDomain->intersect(Interval(($studentList->value)[$i]->string));
     }
     $studentDomain = Compute("$studentDomain");

     # Set correct answer parts
     my $correctFormula = $ansHash->{correct_value};
     my $correctScore = scalar ($correctFormula->value); 
     my $correctExpression = ($correctFormula->value)[0];
     my $correctDomain = ($correctFormula->value)[1];
     $correctDomain = Compute("$correctDomain");
     # If the correct answer has (-inf, inf) as the domain, don't print that in the correct answer
     if ($correctDomain == Interval("(-inf,inf)")) {
       $ansHash->{correct_ans_latex_string} = $correctExpression->TeX;
     }
     my $trueDomain = $correctDomain;
     if (defined($correctFormula->{trueDomain})) {$trueDomain = $correctFormula->{trueDomain};}

     # Check math expression
     my $expression_cmp = $correctExpression->cmp->evaluate($studentExpression->string);
     my $expressionOK = $expression_cmp->{score};
     push(@errors,'Your expression is not correct') unless ($expressionOK or $expression_cmp->{ans_message} or $ansHash->{isPreview});
     push(@errors,$expression_cmp->{ans_message}) if $expression_cmp->{ans_message};
     
     # Check student's domain
     my $domainOK = 1;
     my $trueUnion = Interval($trueDomain);
     my $studentUnion = Interval($studentDomain);
     my $correctUnion = Interval($correctDomain);
     if (!$correctUnion->contains($studentUnion) or !$studentUnion->contains($trueUnion)) {
       $domainOK = 0;
       push(@errors,'Your domain is not correct') unless ($studentFormula->type eq 'Number' or $ansHash->{isPreview});
       push(@errors,'You need to specify the restricted domain') if ($studentFormula->type eq 'Number' and $expressionOK);
     };

     my $allCorrectScore = ($ansHash->{student_formula}->type eq 'Number') ? 2 : scalar ($ansHash->{student_value}->value); 
     my $expressionWeight = Context()->flag("expressionWeight");
     $score += $expressionWeight*$allCorrectScore if $expressionOK;
     $score += (1-$expressionWeight)*$allCorrectScore if $domainOK;
     #$score = $score + $domainsCount if $domainOK;

     return ($score,@errors);
  };
}


###########################
#
#  Subclass the numeric functions
#
package restrictedDomains::Function::numeric;
our @ISA = ('Parser::Function::numeric');

#
#  Override sqrt() to return a special value times x when evaluated
#
sub sqrt {
  my $self = shift;
  my $x = shift;
  my $value = $self->context->flag("checkSqrt");
  return $value+1 if $value && $x == 1;  # force sqrt(1) to be incorrect
  return $value+1 if $value && $x == $value;  # force sqrt(sqrt(x)) to be incorrect
  return $value+1 if $value && $x == $self->context->flag("checkRoot");  # force sqrt(root(n,x))) to be incorrect
  return $value*$x if $value;
  return $self->SUPER::sqrt($x);
}

sub identity {
  my $self = shift;
  my $x = shift;
  return $x;
}
