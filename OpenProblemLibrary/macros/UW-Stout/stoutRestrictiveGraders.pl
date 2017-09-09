=head1 NAME

stoutRestrictiveGraders.pl

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

TODO

=head1 AUTHOR

Alex Basyrov, basyrova@uwstout.edu

=cut


loadMacros(
"MathObjects.pl",
);


sub MonomialFormula{
	my $string_formula = shift;
	my $ref_monomial_formula = new stoutMonomialFormula($string_formula);
	return $ref_monomial_formula;
}

package stoutMonomialFormula;

sub new {
	my $class = shift;
	my $string_formula = shift;
	my $self = { Formula => $string_formula };
	bless $self, $class;
}

sub reduce{
	my $self = shift;
	my $original_formula = $self->{Formula};
	my $new_formula = ::Formula($original_formula)->reduce;
	$self->{Formula} = $new_formula->string;
	return $self; 
}

sub onlyDigits{
	$string = shift;
	
	if ($string=~ /^(-|\+|)(\d+)$/){
		return 1;
	} else {
		return 0;
	}
}

sub theEvaluator { 
	my $hr_ans = shift; 
	my %options = @_;
	my $ans = $hr_ans->{correct_ans};
	my $fans = ::Formula($ans);
	my @factorspowers = makefactors($fans->{tree});
	# warn "Factors and powers: ". join (",",@factorspowers);
	my @factors = ();
	my @powers = (); 
	my $i; 
	for ($i = 0; $i < scalar @factorspowers; $i+=2){
		push @factors, $factorspowers[$i];
		push @powers, $factorspowers[$i+1];
	}
	
	#warn "Factors: ". join (",",@factors);
	#warn "Powers: ". join (",",@powers);
	
	my $numCorrectFactors = scalar @factors; 
	# my $var = shift;

	my $student_ans = $hr_ans->{student_ans};
	# the following verifies that student answer would parse
	# could use 
	# my $test = Parser::Formula($student_ans);
	# if (defined $test) { #proceed with the use of $student_ans }
	# but this method produces answer hash with any syntax errors 
	# being highlighted 
	my $ans_hash = ::Formula($ans)->cmp()->evaluate($student_ans); 
	$ans_hash->{student_ans} = $student_ans;
	$ans_hash->{original_student_ans} = $student_ans;
	
	if ( $ans_hash->{score} == 1) { 
		# since we got here, student's answer is equivalent to the correct one
		my $sans = ::Formula($student_ans);
		my @sfactorspowers = makefactors($sans->{tree});
		my @sfactors=();
		my @spowers=();
		for ($i = 0; $i < scalar @sfactorspowers; $i+=2){
			push @sfactors, $sfactorspowers[$i];
			push @spowers, $sfactorspowers[$i+1];
		}
		#warn "Student Factors: ". join (",",@factors);
		#warn "Student Powers: ". join (",",@powers);
		my $snumCorrectFactors = scalar @sfactors; 
		
		if ( $snumCorrectFactors < $numCorrectFactors) {
			$ans_hash->setKeys( 'ans_message' => "Make sure that your answer is simplified completely!" );
			$ans_hash->{score} = 0;
			return $ans_hash;
		}
		if ( $snumCorrectFactors > $numCorrectFactors) {
			$ans_hash->setKeys( 'ans_message' => "Your  answer is equivalent to the correct one, but it has too many terms. Did you simplify your answer completely?" );
			$ans_hash->{score} = 0;
			return $ans_hash;
		}
		
		# since we got here, both answers have the same number of factors
		# we can compare each correct factor to student's and see what we get
		my $correctFactors = 0;
		my $accumulatedSign = 1;
		my $accumulatedFactor = 1;
		my $offByConstant = 0;
		for ($i = 0; $i < scalar @factors; $i++) {
			$cfactor = $factors[$i];
			$cpower = ::Formula($powers[$i]);
			for ($j = 0; $j < scalar @sfactors; $j++) {
				$sfactor = $sfactors[$j];
				$spower = ::Formula($spowers[$j]);				
				if (!onlyDigits($spowers[$j])){
					# numeric exponent is not simplified
					$ans_hash->{score} = 0;
					$ans_hash->setKeys( 'ans_message' =>"Exponents need to be completely simplified.");
					return $ans_hash;
				}
				my $context = ::Context()->copy;
				$context->flags->set(no_parameters=>0);
				$pname='Az';
				$context->variables->add($pname=>'Parameter');
				my $c0 = ::Formula($context,$pname);
				$fstudent = ::Formula($context,$sfactor);
				if ($fstudent->isConstant){
					if (!onlyDigits($sfactor)){
						# numeric factor is not simplified
						$ans_hash->{score} = 0;
						$ans_hash->setKeys( 'ans_message' =>"Constants need to be completely simplified.");
						return $ans_hash;
					}
				}
				$fcorrect = ::Formula($context,"$c0 * ($cfactor)");
				if ( $fcorrect == $fstudent ) {
					# warn "Matched: $student vs. $correct"; 
					# warn "Value of constant: ". $context->variables->value('C0');
					$parameterValue = $context->variables->value($pname);
					if ( abs($parameterValue) == 1){
						# only factors correct up to negative are counted
						# but that could be changed to 'up to a constant', if needed
						if ( $cpower == $spower){
							$correctFactors++; 
							$accumulatedFactor *= ($parameterValue)**($cpower);
						}
					} else {
						# factor is close to correct one, but it differes by a non-trivial constant
						$offByConstant = 1;
					}
				} 
			}
		}
		
		if ( ($correctFactors == $numCorrectFactors) && ($accumulatedFactor == 1) ) {
			$ans_hash->{score} = 1;
			return $ans_hash; 
		}
		
		if ($offByConstant == 1){
			$ans_hash->{score} = 0;
			$ans_hash->setKeys( 'ans_message' =>"Your answer is algebraically equivalent to the correct one, but it does not appear to be completely simplified.");
			return $ans_hash;
		}
		
		$ans_hash->{score} = 0;
		$ans_hash->setKeys( 'ans_message' =>"Your answer is algebraically equivalent to the correct one, but it does not appear to be completely simplified.");
	}
	
	$hr_ans = $ans_hash; # copy the hash from above
	return $hr_ans;
}

sub cmp {
	my $self = shift; 
	my %options = @_;
	my $ans = new AnswerEvaluator(
		'correct_ans' => $self->{Formula}, 
		'type' => 'Factored Formula',
		); 
	$ans->install_evaluator(\&theEvaluator);
	return $ans; 
}

sub makefactors {
	my $me = shift;
	
	my $bop = $me->{bop};
	#$bop =~ s/^~~s+//;
	#$bop =~ s/~~s+$//;
	if (defined $bop){
		$bop =~ s/^\s+//;
		$bop =~ s/\s+$//;
	} else {
		$bop = "";
	}
	
	#warn "Expression: |". $me->string ."|";
	#$warn "BOP: |". $bop ."|";
	#warn "LOP: |". $me->{lop}->string ."|";
	#warn "ROP: |". $me->{rop}->string ."|";

	if ( ($bop eq "*") ) {
		return ( makefactors($me->{lop}), makefactors($me->{rop}) );
	} else {
		if ( ( $bop eq "^") || ($bop eq "**") ) {
			# the factor has exponent!
			my $base = $me->{lop}->string; 
			my $exponent = $me->{rop}->string;
			return ($base, $exponent);
		} else { 
			# the factor has no exponent
			my $base = $me->string;
			my $exponent = 1;
			return ($base, $exponent);
		}
	}
}	
