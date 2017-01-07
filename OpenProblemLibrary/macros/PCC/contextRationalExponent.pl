=head1 NAME

contextRationalExponent.pl - allows the requirement of simplified rational exponent answers. May be a misnomer since nothing requires exponents to be rational.

=head1 DESCRIPTION

This code is a copy of contextLimitedRadical.pl, with the following changes:
- no need for contextLimitedPowers.pl, since we need to use bizarro power, so that macro is removed
- name of the context changed to RationalExponent
- set class of ^ and ** to bizarro
- removed  LimitedPowers::OnlyPositiveIntegers($context) call
- set bizarroPow flags in answer checking (on, then off)
- undefined sqrt and root (after root is added to the context). These can be redefined by a problem author if desired.
- added special messages if sqrt or root are used when they were undefined

=cut
loadMacros(
    "bizarroArithmetic.pl",

);

#
#  Set up the RationalExponent context
#
sub _contextRationalExponent_init {
  my $context = $main::context{RationalExponent} = Parser::Context->getCopy("Numeric");
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
     '**' => {class => 'bizarro::BOP::power', isCommand => 1, perl=>undef},    # override **
     '^' => {class => 'bizarro::BOP::power', isCommand => 1, perl=>undef},    # override ^  
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
   $context->functions->undefine('sqrt');
   $context->functions->undefine('root');
   $context->{error}{msg}{"Function 'root' is not allowed in this context"} 
  = "Please use rational exponents, not root or sqrt";
   $context->{error}{msg}{"Function 'sqrt' is not allowed in this context"} 
  = "Please use rational exponents, not sqrt or root";
  $context->{cmpDefaults}{Formula}{checker} = sub {
    my ($correct,$student,$ans) = @_;
    return 0 if $ans->{isPreview} || $correct != $student;
    $student = $ans->{student_formula};
    $correct = $correct->{original_formula} if defined $correct->{original_formula};
    $student = Formula("$student"); $correct = Formula("$correct"); #ensure both are Formula objects
    my ($setSqrt, $setRoot) = (Context()->flag("setSqrt"), Context()->flag("setRoot"));
    Context()->flags->set(checkSqrt => $setSqrt, checkRoot => $setRoot, bizarroAdd => 1, bizarroSub => 1, bizarroMul => 1, bizarroDiv => 1, bizarroPow => 1); 
    delete $correct->{test_values};
    delete $student->{test_values};
    my $OK = (($correct == $student) or ($student == $correct)); # check if equal when sqrt's are replaced by 1
    Context()->flags->set(checkSqrt => 0, checkRoot => 0, bizarroAdd => 0, bizarroSub => 0, bizarroMul => 0, bizarroDiv => 0, bizarroPow => 0); 
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
