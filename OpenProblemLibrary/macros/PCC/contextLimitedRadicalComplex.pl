=head1 NAME
contextLimitedRadical.pl - defines a root(n,x) function for n-th root of x, and 
allows for specification of forms of radical answers, like simplified radicals or
with rational denominators

=head1 DESCRIPTION

This file enables a context LimitedRadical in which students and pg-authors may use 
root(n,x) for the nth root of x. The function makes sure n!=0, and also allows for 
negative x only if n is an odd integer.

By default, the limits for Formula answer checking are [0,5] to avoid negatives in 
radicals. If it is important to distinguish sqrt(x^2) as |x| rather than x, then the 
limits should be changed to include a region where they differ.

The context requires that radical expressions (using either sqrt() or root()) meet 
the form of the author's answer with respect to simplification and rationalization 
of denominators.

To accomplish this, Math Objects like "root(3,2)" should be created as Formula("root(3,2)"), 
not Compute("root(3,2)"), or they will be treated as Reals and evaluated as decimals. 
Compute("root(3,x)") should be fine though, since it is unambiguously a Formula.

Student answers are first compared to the correct answer in the usual way to see if 
they are at least numerically correct. Then to check that expressions are fully 
simplified, during a check, both sqrt(x) and root(n,x) are temporarily replaced by certain 
other functions.  Also +, -, *, and / are temporarily replaced with bizarro arithmetic 
(from bizarroArithmetic.pl) that nearly make for a bizarro field structure on R. 
If the student and author answers disagree after this change, then the student's answer 
is not in form of the author's answer.

For example "1+2" is not equivalent to "3" under bizarro addition. "2sqrt(2)" is not 
equivalent to "sqrt(8)" with the bizarro arithmetic. Any radical applied to 1 is declared 
unsimplified as well.

If a student's answer is numerically equal to the author's, but not equal under bizarro 
arithmetic, students get the message that their answer is not fully simplified. So care 
should be taken by the problem author when defining answers.

The near-field structure of the bizarro versions means that "1+sqrt(2)+sqrt(3)" can be 
entered as "sqrt(3)+sqrt(2)+1", etc, and not be declared "unsimplified". Also "(1+sqrt(2))/2" 
can be entered as "1/2+sqrt(2)/2" without being declared "unsimplified". However, 
"(1+2sqrt(2))/2" *will* be declared different from "1/2+sqrt(2)", even though both are 
generally considered fully simplified. If an author can foresee this arising, consider 
using parserOneOf.pl to allow for multiple forms of the correct answer.

Technically both "sqrt(3)/3" and "1/sqrt(3)" are fully simplified, although you may want 
rational denominators. This context will declare them equal but not equivalent. The author 
should either accept both as correct using parserOneOf.pl, or give the message that the 
student's answer does not have a rational denominator using answerHints.pl.

Note that there is nothing here that is actually doing any reducing of radical quantities 
or honestly checking for "simplified" answers - so authors need to make sure their answers 
are reduced and simplified. Also if the correct answer is "sqrt(2)" and the student 
enters "sqrt(3)+sqrt(3)" or "4sqrt(2)/2", they will just be told they are wrong, not that 
their (incorrect) answer is unsimplified.


=cut
loadMacros(
    "contextLimitedPowers.pl",
    "bizarroArithmetic.pl",

);

#
#  Set up the LimitedRadical context
#
sub _contextLimitedRadicalComplex_init {
  my $context = $main::context{LimitedRadicalComplex} = Parser::Context->getCopy("Complex");
  Parser::Number::NoDecimals($context);
  $context->flags->set(setSqrt => exp(1)/ln(2), setRoot => exp(1)/ln(2)); 
  $context->operators->set(
     '+' => {class => 'bizarro::BOP::add', isCommand => 1},       # override +
     '-' => {class => 'bizarro::BOP::subtract', isCommand => 1},  # override -
     '*' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '* ' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     ' *' => {class => 'bizarro::BOP::multiply', isCommand => 1},  # override *
     '/' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     '/ ' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     ' /' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /
     '//' => {class => 'bizarro::BOP::divide', isCommand => 1},    # override /  
);
  $context->functions->set(sqrt=>{class=>'my::Function::numeric'});  # override sqrt()
  main::PG_restricted_eval('sub root {Parser::Function->call("root",@_)}');
  $context->functions->add(
    root => {class => 'my::Function::numeric2'},
  );
  $context->flags->set(limits => [0,5]);   # no negatives in the radicals  
  $context->flags->set(reduceConstantFunctions=>0,
                       reduceConstants=>0,
                       formatStudentAnswer =>parsed,
                       checkSqrt => 0, 
                       checkRoot => 0);
  LimitedPowers::OnlyPositiveIntegers($context);  # don't allow powers of 1/2, 1/3, etc
  $context->{cmpDefaults}{Formula}{checker} = sub {
    my ($correct,$student,$ans) = @_;
    return 0 if $ans->{isPreview} || $correct != $student;
    $student = $ans->{student_formula};
    $correct = $correct->{original_formula} if defined $correct->{original_formula};
    $student = Formula("$student"); $correct = Formula("$correct"); #ensure both are Formula objects
    my ($setSqrt, $setRoot) = (Context()->flag("setSqrt"), Context()->flag("setRoot"));
    Context()->flags->set(checkSqrt => $setSqrt, checkRoot => $setRoot, bizarroAdd => 1, bizarroSub => 1, bizarroMul => 1, bizarroDiv => 1); 
    delete $correct->{test_values}, $student->{test_values};
    my $OK = (($correct == $student) or ($student == $correct)); # check if equal when sqrt's are replaced by 1
    Context()->flags->set(checkSqrt => 0, checkRoot => 0, bizarroAdd => 0, bizarroSub => 0, bizarroMul => 0, bizarroDiv => 0); 
    Value::Error("You must simplify your answer further") unless $OK;
    return $OK;
  };
}

###########################
#
#  Create root(n, x)
#

package my::Function::numeric2;
our @ISA = ('Parser::Function::numeric2');


sub root {
  my $self = shift; my $n = shift; my $x = shift;
  $self->Error("Can't take 0th roots") if ($n == 0);
  $self->Error("Can't take general roots of negative numbers") if (($x < 0) and (($n-1)/2 != int(($n-1)/2)));
  my $value = $self->context->flag("checkRoot");
  return $value+1 if $value && $x == 1;  # force root(n,1) to be incorrect
  return $value+1 if $value && $x == $value;  # force root(n,root(m,x))) to be incorrect
  return $value+1 if $value && $x == $self->context->flag("checkSqrt");  # force root(n,sqrt(x))) to be incorrect
  return $value*$x if $value;
  return ($x)**(1/$n) if (($x > 0) and ($n != 0));
  return -(abs($x)**(1/$n)) if (($x < 0) and (($n-1)/2 == int(($n-1)/2)));
}


sub TeX {
  my $self = shift;
  my ($n,$x) = ($self->{params}[0],$self->{params}[1]);
  return '\sqrt['.$n->TeX."]{".$x->TeX."}";
}



###########################
#
#  Subclass the numeric functions
#
package my::Function::numeric;
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



1;
