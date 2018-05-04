#These three subroutines uniformize how all our "solve this equation" problems are handled.

loadMacros("PCCmacros.pl");

sub _init_SolveLinearEquationPCCDevel {

 #Possibly add initialization code here
 #sub routine is not required, but prevents the macro from being re-loaded

}



sub contextSetup {
  my ($vRef, $aRef) = @_;
  Context("LimitedFraction");
  Context()->flags->set(requirePureFractions=>1);
  Context()->flags->set(showMixedNumbers=>0);
  %varAddHash = ();
  for my $i (0..$#{$vRef}) {
    $varAddHash{$vRef->[$i]} = 'Real';
  };
  Context()->variables->are(%varAddHash);
  parser::Assignment->Allow;
  Context()->flags->set(reduceConstantFunctions=>0,
                        formatStudentAnswer=>"parsed",
                        reduceConstants=>0,
                        formatStudentAnswer=>parsed,
                        reduceFractions=>0,
                        showExtraParens=>0);
  Context()->operators->redefine(',');
  Context()->lists->set(Set => {open => "{", close => "}"});
  Context()->parens->set("{" => {type => "Set", close => "}"});
  my @eqTypes = ();
  for my $i (keys %varAddHash) {
    push (@eqTypes, $i.' = ___');
  };
  my $n = $#eqTypes;
  my $eqTypesString = $eqTypes[0];
  if ($n == 1) {$eqTypesString .= ' or '.$eqTypes[1];};
  if ($n > 1) {
    for my $i (1..$n - 1) {$eqTypesString .= ', '.$eqTypes[$i];};
    $eqTypesString .= ', or '.$eqTypes[$n];
  };
  Context()->{error}{msg}{"The left side of an assignment must be a variable or function"} 
    = "Your answer should be in the form $eqTypesString";
  Context()->{error}{msg}{"The right side of an assignment must not include the variable being defined"} 
    = "The right side must not include the variable being defined";
  Context()->strings->add("no solution"=>{},
    "no solutions"=>{alias=>'no solution'}, 
    "none"=>{alias=>'no solution'}, 
    "all real numbers"=>{},
    "infinite number of solutions"=>{alias=>'all real numbers'}, 
    "infinite"=>{alias=>'all real numbers'},
    "infinite solutions"=>{alias=>'all real numbers'}
  );
  my @ansEqArray = ();
  for my $i (0..$#{$aRef}) {
    my $tempString = $vRef->[$i].' = '.$aRef->[$i];
    push (@ansEqArray , Formula("$tempString"));
  };
  @eqTypes = ();
  for my $i (0..$#{$vRef}) {
    push (@eqTypes, $vRef->[$i].' = ___');
  };
  return (\@ansEqArray,\@eqTypes);
};


sub instructions {
  my ($vRef) = @_;
  %varAddHash = ();
  for my $i (0..$#{$vRef}) {
    $varAddHash{$vRef->[$i]} = 'Real';
  };
  my @eqTypes = ();
  for my $i (keys %varAddHash) {
    push (@eqTypes, '[|'.$i.' = ___|]*');
  };
  my $eqTypesString = join(', ',@eqTypes);
  #"Solve the following linear equation; the answer could be in the form $eqTypesString, [|no solution|]*, or [|all real numbers|]*."
  'Solve the equation.'.KeyboardInstructions(q! (The answer might be "[|no solution|]*" or "[|all real numbers|]*".)!)
};


sub answerCheck {
  my ($ansEqRef, $eqTypesRef) = @_;
  for my $i (0..$#{$ansEqRef}) {
    $ansType[$i] = $eqTypesRef->[$i];
    $ansEq[$i] = $ansEqRef->[$i];
    ANS($ansEq[$i]->cmp(
      cmp_class=>"a variable assignment of the form $ansType[$i]",
      correct_ans_latex_string => '\\{' . (Compute($ansEq[$i])->value)[1] . '\\}',
      correct_ans => '{' . (Compute($ansEq[$i])->value)[1] . '}',
    )->withPostFilter(
      AnswerHints( 
        #(Compute($ansEq[$i])->value)[1] => ["You have the solution, but the answer to this question should be in the form $ansType[$i]" , replaceMessage => 1],
        #sub {
        #  my ($correct, $student, $ansHash) =@_;
        #  return (Compute($ansHash->{original_student_ans})->class eq 'Set');
        #} => ["You are trying to give the solution set in set notation, but the answer to this question should be in the form $ansType[$i]" , replaceMessage => 1],
        #sub {
        #  my ($correct, $student, $ansHash) =@_;
        #  return (Compute($ansHash->{original_student_ans})->class eq 'Set' and $student == (Compute($ansEq[$i])->value)[1]);
        #} => ["You have the solution set, but the answers to this question should be in the form $ansType[$i]" , replaceMessage => 1],
        $ansEq[$i] => ["Good. And the solution set for this equation is {" . (Compute($ansEq[$i])->value)[1] . "}.", replaceMessage => 1, checkCorrect =>1],
      )
    )
    ->withPostFilter(sub {
      my $ansHash = shift;
      if ($ansHash->{score}) {
        my ($svar,$sfrac) = $ansHash->{student_value}->value;
        if (Value::classMatch($sfrac,'Fraction')) {
          if (($sfrac->value)[1] == 1 or ($sfrac->value)[0] == 0) {
            $ansHash->{score} = 0;
            $ansHash->{ans_message} = "Your fraction is not reduced";
          } else {
            my $correctAnswer = $ansHash->{correct_value};
            my ($cvar,$cfrac) = Compute("$correctAnswer")->value;
            $cfrac = Fraction($cfrac);
            my $check = $cfrac->cmp->evaluate($sfrac->string);
            $ansHash->{score} = $check->{score};
            $ansHash->{ans_message} = $check->{ans_message};
          }
       }
      }
          #if we make it through all the pre-2017 answer checking, now check for answers like 12 or {12} (as opposed to x=12) and award credit
          elsif (Value::classMatch($ansHash->{student_value},'Fraction') or Value::classMatch($ansHash->{student_value},'Real')) {
            my $simpleans = Fraction((Compute($ansEq[$i])->value)[1]);
            my $simplecheck = $simpleans->cmp->evaluate($ansHash->{student_value}->string);
            $ansHash->{score} = $simplecheck->{score};
            $ansHash->{ans_message} = $simplecheck->{ans_message};
            if (Value::classMatch($ansHash->{student_value},'Fraction')) {
              if (($ansHash->{student_value}->value)[1] == 1 or ($ansHash->{student_value}->value)[0] == 0) {
                $ansHash->{score} = 0;
                $ansHash->{ans_message} = "Your fraction is not reduced";
              }
            }
          } 
          elsif (Value::classMatch($ansHash->{student_value},'Set')) {
            my $correctsol = (Compute($ansEq[$i])->value)[1];
            my $check = $correctsol->cmp->evaluate(($ansHash->{student_value}->value)[0]->string);
            $ansHash->{score} = $check->{score};
            $ansHash->{ans_message} = $check->{ans_message};
          } 
      return $ansHash;
    })
    );
  };
};


sub summary {
  my ($ansEq, $left, $right) = @_;
  my ($var, $ans) = (Compute($ansEq)->value);
  my $ansEqTeX = $ansEq->TeX;
  my $leftTeX = $left->TeX;
  my $rightTeX = $right->TeX;
  my $ansTeX = $ans->TeX;
  "The solution to this equation is [`$ans`]. To stress that this is a value assigned to [`$var`], some report [`$ansEqTeX`]. We can also say that the solution set is [`\\{$ansTeX\\}`], or that [`$var\\in\\left\\{$ansTeX\\right\\}`]. If we substitute [`$ansTeX`] in for [`$var`] in the original equation [`$leftTeX=$rightTeX`], the equation will be true. Please check this on your own; it is an important habit. "

};


1;
