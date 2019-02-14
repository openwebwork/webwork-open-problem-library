=head1 NAME

stoutSpecialGradersCircle.pl

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

TODO

=head1 AUTHOR

Alex Basyrov, basyrova@uwstout.edu

=cut


loadMacros(
"MathObjects.pl",
"stoutUtils.pl",
);

# the formula that is a sum of terms, the terms are compared individually
sub SumOfTermsFormula{
	my $string_formula = shift;
	my $ref = new stoutSumOfTermsFormula($string_formula);
	return $ref; 
}

# put arbitrary constants into the context
sub PutArbitraryConstants{
	my $count = shift;
	$count = 9 unless defined $count; 
	foreach $param (1..$count){
		Context()->variables->add("C$param" => 'Real');
	}
}

# put indeterminant parameters into the context
sub PutIndeterminantParameters{
	my $count = shift;
	$count = 25 unless defined $count; 
	$count--;
	my @names = ('A'..'Z');
	my $i;
	foreach $i (0..$count){
		my $param = $names[$i];
		Context()->variables->add($param => 'Real');
	}
}

# the formula that represent a general solution to linear high order diff equation
sub LinearGeneralSolution{
	my $string_formula = shift;
	my $ref = new stoutLinearGeneralSolution($string_formula);
	return $ref; 
}


sub GenericEquation{
	my $string_formula = shift;
	my $ref = new stoutGenericEquation($string_formula);
	return $ref;
}

sub SlopeInterceptEquation{
	my $string_formula = shift;
	my $ref = new stoutSlopeInterceptEquation($string_formula);
	return $ref;
}

sub CircleStandardEquation{
	my $string_formula = shift;
	my $ref = new stoutCircleStandardEquation($string_formula);
	return $ref;
}

package stoutSumOfTermsFormula;


# the easier debug block
# it uses functions from stoutUtils package,
# but allows local setting of debugging constant
our $stoutDebug = 0;

sub stoutDebugMessage{
	stoutUtils::stoutDebugMessage(@_) if $stoutDebug;
}

sub stoutDebugShowVar{
	stoutUtils::stoutDebugShowVar(@_) if $stoutDebug;
}

sub stoutDebugShowArrayRef{
	stoutUtils::stoutDebugShowArrayRef(@_) if $stoutDebug;
}

sub stoutDebugShowHashRef{
	stoutUtils::stoutDebugShowHashRef(@_) if $stoutDebug;
}


sub new {
	my $class = shift;
	my $string_formula = shift;
	my %options = @_;
	
	
	my $context = main::Context()->copy();
	my $self = { 
		Formula => $string_formula,
		Context => $context,
		};
	bless $self, $class;
}

sub reduce{
	my $self = shift;
	my $original_formula = $self->{Formula};
	my $context = $self->{Context};
	
	stoutDebugMessage("Context inherited by formula:".main::pretty_print($context->{flags}));
	
	my $new_formula = main::Formula($context, $original_formula)->reduce;
	$self->{Formula} = $new_formula->string;
	return $self; 
}

sub theEvaluator { 
	my $self = shift; 
	my $hr_ans = shift; 
	stoutDebugShowHashRef("hr_ans variable", $hr_ans); 
	stoutDebugShowVar("Preview", $hr_ans->{isPreview}); 
			
	# store the options we got from the call to cmp() method
	my %options = @_;
	
	$options{factored_terms} = 0 unless defined $options{factored_terms};
	
	
	# debug
	stoutDebugShowHashRef("Options", \%options);
	
	my $ans = $hr_ans->{correct_value}->{Formula};
	my $context = $hr_ans->{correct_value}->{Context};
	my $fans = main::Formula($context, $ans);
	my @terms = maketerms($fans->{tree});
   
	stoutDebugShowArrayRef("Terms", \@terms);
	
	my $numCorrectTerms = scalar @terms; 
	my $student_ans = $hr_ans->{student_ans};
	
	# the following verifies that student answer would parse
	# could use 
	# my $test = Parser::Formula($student_ans);
	# if (defined $test) { #proceed with the use of $student_ans }
	# but this method produces answer hash with any syntax errors 
	# being highlighted 
	my $ans_hash = main::Formula($context, $ans)->cmp()->evaluate($student_ans); 
	stoutDebugShowHashRef("ans_hash variable", $ans_hash); 
	stoutDebugShowVar("isPreview in hash", $ans_hash->{isPreview}); 
	my $isPreview = 0;
	if (defined $ans_hash->{isPreview}){
		if ( !($ans_hash->{isPreview} eq "")){
		$isPreview  = 1;
		}
	}
	stoutDebugShowVar('isPreview',$isPreview);
	
	# need to do syntax error check before going furhter
	if ( defined $ans_hash->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($ans_hash->{error_message} eq "") ){
			return $ans_hash;
		}
	}
	# we should be safe to use student answer, since it should have passed parser
	
	# if it is a preview, we don't need to waste time
	# doing full answer check; return what we've got now
	if ($isPreview){
		return $ans_hash;
	}
	
	# see if we have to go on 
	my $can_proceed = 0; 
	if ( $ans_hash->{score} == 1) { 
		# the student answer is algebraically equivalent to the correct answer
		# can look into the structure of student answer
		$can_proceed = 1;
	} 
	
	$ans_hash->{student_ans} = $student_ans;
	$ans_hash->{original_student_ans} = $student_ans;

	if ( $can_proceed ) { 
		# since we got here, student's answer is equivalent to the correct one
		my $sans = main::Formula($context, $student_ans);
		my @sterms = maketerms($sans->{tree});
		
		stoutDebugShowArrayRef("Student Terms", \@sterms);
		
		my $snumTerms = scalar @sterms; 
		my $numTerms = scalar @terms;
		
		$ans_hash->{student_ans} = $student_ans;
		$ans_hash->{original_student_ans} = $student_ans;
		$ans_hash->{correct_ans} = $ans;
		$ans_hash->{correct_ans_latex_string} = $fans->TeX;
		$ans_hash->{preview_latex_string} = $sans->TeX;
		$ans_hash->{preview_text_string} = $sans->string;
		if ($snumTerms != $numTerms){
			$ans_hash->setKeys( 'ans_message' => "Your answer is algebraically equivalent to the correct one, but it is not in the correct form. Make sure that you simplify the answer and that the answer is in the requested form" );
			$ans_hash->{score} = 0;
			return $ans_hash;
		}
		
		my %matched;
		
		my ($i, $j);
		
		my $correctTerms = 0;
		
		for ($i = 0; $i < $numTerms; $i++) {
			$cTerm = $terms[$i];
			
			next if $matched{$i};
			
			for ($j = 0; $j < $snumTerms; $j++) {
				$sTerm = $sterms[$j];
				my $result = undef;
				if ($options{factored_terms}){
					$cTermFactored = new stoutFactoredFormula($cTerm);
					$ans_hash_term = $cTermFactored->cmp()->evaluate($sTerm);
					$result = $ans_hash_term->{score};
				} else { 
					$result = stoutUtils::matchUpToConstant($context, $cTerm, $sTerm);
				}
				if ((defined $result) && ($result==1)){
					$matched{$i} = 1;
					$correctTerms++; 
				} else {
					# factor is close to correct one, but it differes by a non-trivial constant
				}
			}
		}
		
		if ($correctTerms==$numTerms){
			$ans_hash->{score} = 1;
			return $ans_hash;
		} else {
			$ans_hash->setKeys( 'ans_message' => "Your answer is algebraically equivalent to the correct one, but it is not in the correct form. Make sure that you simplify the answer and that the answer is in the requested form" );
			$ans_hash->{score} = 0;
			return $ans_hash;
		}
	}
	
	$hr_ans = $ans_hash; # copy the hash from above
	return $hr_ans;
}


# need this to correctly detect 'preview answers' vs. 'submit/check answers' mode
sub getPG {
  my $self = shift;
  (main::PG_restricted_eval(shift))[0];
#  eval ('package main; '.shift);  # faster
}

sub cmp {
	my $self = shift; 
	my %options = @_; 
	
	# debug: 
	stoutDebugShowHashRef("Options in cmp", \%options);
	
	my $ans = new AnswerEvaluator;
	# $ans->{debug} = 1;
	$ans->ans_hash(
		type => "Sum of Terms Formula",
		correct_ans => $self->{Formula},
		correct_value => $self,
	);
	$ans->install_evaluator('erase');
	
	# the following passes the %options we got here to the answer evaluator
	$ans->install_evaluator(sub {
		my $ans = shift;
		my $inputs = $self->getPG('${main::inputs_ref}');
		if ( defined $inputs->{action} ){
			$ans->{isPreview} = $inputs->{previewAnswers} || ($inputs->{action} =~ m/^Preview/);
		} else { 
			$ans->{isPreview} = $inputs->{previewAnswers};
		}
		$ans->{correct_value}->theEvaluator($ans, @_);
		}, 
		%options);	
	return $ans; 
}

sub maketerms {
	my $me = shift;
	my %options = @_;
	$options{sign} = 1 unless defined $options{sign}; 
	
	my $bop = $me->{bop};
	if (defined $bop){
		$bop =~ s/^\s+//;
		$bop =~ s/\s+$//;
	} else {
		$bop = "";
	}
	
	stoutDebugShowVar("Expression", $me->string);
	stoutDebugShowVar("BOP", $bop);
	stoutDebugShowVar("LOP", $me->{lop}->string) if defined $me->{lop};
	stoutDebugShowVar("ROP", $me->{rop}->string) if defined $me->{rop};

	if ($bop eq "+") {
		return ( maketerms($me->{lop}), maketerms($me->{rop}) );
	} elsif ($bop eq "-"){
		return ( maketerms($me->{lop}), maketerms($me->{rop}, sign => -1) );
	} else {
		if ( $options{sign} == 1){
			return $me->string;
		} elsif ($options{sign} == -1){
			return "-1*(".$me->string.")";
		} else {
			stoutDebugMessage("something is wrong...");
		}
	}
}	

# the following is almost useless so far, as the overload does not work here
sub stringify {
  my $self = shift;
  return $self->string;
}

# the following is almost useless so far, as the overload does not work here
sub string{
	my $self = shift;
	return $self->{Formula};
}

# the following is almost useless so far, as the overload does not work here
sub TeX{
	my $self = shift;
	my $context = $self->{Context};
	my $strFormula = $self->{Formula};
	return main::Formula($context, $strFormula)->TeX();
}



package stoutLinearGeneralSolution;
# the easier debug block
# it uses functions from stoutUtils package,
# but allows local setting of debugging constant
our $stoutDebug = 0;

sub stoutDebugMessage{
	stoutUtils::stoutDebugMessage(@_) if $stoutDebug;
}

sub stoutDebugShowVar{
	stoutUtils::stoutDebugShowVar(@_) if $stoutDebug;
}

sub stoutDebugShowArrayRef{
	stoutUtils::stoutDebugShowArrayRef(@_) if $stoutDebug;
}

sub stoutDebugShowHashRef{
	stoutUtils::stoutDebugShowHashRef(@_) if $stoutDebug;
}

sub new {
	my $class = shift;
	my $string_formula = shift;
	my %options = @_;
	
	
	my $context = main::Context()->copy();
	my $self = { 
		Formula => $string_formula,
		Context => $context,
		};
	bless $self, $class;
}

sub reduce{
	my $self = shift;
	my $original_formula = $self->{Formula};
	my $context = $self->{Context};
	
	stoutDebugMessage("Context inherited by formula:".main::pretty_print($context->{flags}));
	
	my $new_formula = main::Formula($context, $original_formula)->reduce;
	$self->{Formula} = $new_formula->string;
	return $self; 
}

sub theEvaluator { 
	my $self = shift; 
	my $hr_ans = shift; 
	stoutDebugShowHashRef("hr_ans variable", $hr_ans); 
	stoutDebugShowVar("Preview", $hr_ans->{isPreview}); 
	my $isPreview = 0;
	if (defined $hr_ans->{isPreview}){
		if ( !($hr_ans->{isPreview} eq "")){
		$isPreview  = 1;
		}
	}

	my $constName; 
	my %possibleConsts;
	foreach $constName ('A'..'Z'){
		$possibleConsts{$constName} = 1;
	}
	
	# store the options we got from the call to cmp() method
	my %options = @_;
	
	# debug
	stoutDebugShowHashRef("Options", \%options);
	
	my $ans = $hr_ans->{correct_value}->{Formula};
	my $context = $hr_ans->{correct_value}->{Context};
	my $fans = main::Formula($context, $ans);
	my @terms = maketerms($fans->{tree});
   
	stoutDebugShowArrayRef("Terms", \@terms);
	
	my $numCorrectTerms = scalar @terms; 
	my $student_ans = $hr_ans->{student_ans};

	# the following verifies that student answer would parse
	# could use 
	# my $test = Parser::Formula($student_ans);
	# if (defined $test) { #proceed with the use of $student_ans }
	# but this method produces answer hash with any syntax errors 
	# being highlighted 
	my $ans_hash = main::Formula($context, $ans)->cmp()->evaluate($student_ans); 
	stoutDebugShowHashRef("ans_hash variable", $ans_hash); 
	stoutDebugShowVar("isPreview in hash", $ans_hash->{isPreview}); 
	if (defined $ans_hash->{isPreview}){
		if ( !($ans_hash->{isPreview} eq "")){
		$isPreview  = 1;
		}
	}
	stoutDebugShowVar('isPreview',$isPreview);
	
	# need to do syntax error check before going furhter
	if ( defined $ans_hash->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($ans_hash->{error_message} eq "") ){
			return $ans_hash;
		}
	}
	# we should be safe to use student answer, since it should have passed parser
	
	# if it is a preview, we don't need to waste time
	# doing full answer check; return what we've got now
	if ($isPreview){
		return $ans_hash;
	}
	
	$ans_hash->{student_ans} = $student_ans;
	$ans_hash->{original_student_ans} = $student_ans;

	# since we got here, student's answer is equivalent to the correct one
	my $sans = main::Formula($context, $student_ans);
	my @sterms = maketerms($sans->{tree});
	
	stoutDebugShowArrayRef("Student Terms", \@sterms);
	
	my $snumTerms = scalar @sterms; 
	my $numTerms = scalar @terms;
	
	$ans_hash->{student_ans} = $student_ans;
	$ans_hash->{original_student_ans} = $student_ans;
	$ans_hash->{correct_ans} = $ans;
	$ans_hash->{correct_ans_latex_string} = $fans->TeX;
	$ans_hash->{preview_latex_string} = $sans->TeX;
	$ans_hash->{preview_text_string} = $sans->string;
	#if ($snumTerms != $numTerms){
	#	$ans_hash->setKeys( 'ans_message' => "Please make sure that there is one arbitrary constant per term in your answer.");
	#	$ans_hash->{score} = 0;
	#	return $ans_hash;
	#}
	
	my %matched;
	my %smatched;
	
	my ($i, $j);
	
	my $correctTerms = 0;
	
	my %sConstantsUsed;
	my %cConstantsUsed;
	
	my $diagMessage = "";
	
	for ($i = 0; $i < $numTerms; $i++) {
		$cTerm = $terms[$i];
		stoutDebugShowVar("Correct term", $cTerm);
		#next if $matched{$i};
		
		for ($j = 0; $j < $snumTerms; $j++) {
			next if $matched{$i}; # to skip the rest of the work when we found the match
			next if $smatched{$j}; # to skip the rest of the work when we found the match
			$sTerm = $sterms[$j];
			stoutDebugShowVar("Student term", $sTerm);
			my $result = undef;
			$cTermFormula = main::Formula($context,$cTerm);
			# @cFactors = makefactors($cTermFormula->{tree});
			$hr_cVars = $cTermFormula->{variables};
			@cConsts = ();
			foreach $vn (keys %{$hr_cVars}){
				if ($vn =~ /C([0-9])+/){
					push (@cConsts, $vn);
				} elsif ($possibleConsts{$vn}){
					push (@cConsts, $vn);
				}
			}
			#at this stage @cConsts contains all the arbitrary constants that the correct term had
			#there should be only one, but we will not assume that for now
			stoutDebugShowHashRef("Correct vars", $hr_cVars);
			my $cConstantCount = scalar (@cConsts);
			foreach $ac (@cConsts){
					stoutDebugMessage("Found constant: ", $ac);
					#$cTermFormulaDiff = $cTermFormula->D($ac);
					#stoutDebugMessage("The derivative result: ", $cTermFormula, " -> ", $cTermFormulaDiff);
					$cTermFormula = $cTermFormula->substitute($ac=>1);
					$cConstantsUsed{$ac}=1;
			}
			stoutDebugShowArrayRef("Correct term factors",\@cFactors);
			
			$sTermFormula = main::Formula($context,$sTerm);
			@sFactorsPowers = makefactors($sTermFormula->{tree});
			@sFactors = ();
			@sPowers = ();
			my $k;
			for ($k = 0; $k < scalar (@sFactorsPowers); $k+=2){
				push (@sFactors, $sFactorsPowers[$k]);
				push (@sPowers, $sFactorsPowers[$k+1]);
			}
			$hr_sVars = $sTermFormula->{variables};
			@sConsts = ();
			foreach $vn (keys %{$hr_sVars}){
				if ($vn =~ /C([0-9])+/){
					push (@sConsts, $vn);
				} elsif ($possibleConsts{$vn}){
					push (@sConsts, $vn);
				}
			}
			stoutDebugShowHashRef("Student vars", $hr_sVars);
			my $sConstantCount = scalar (@sConsts);
			foreach $ac (@sConsts){
					stoutDebugMessage("Found constant: ", $ac);
					my $thisConstantMatched = 0;
					# this would verify that the arbitrary constant comes in as a separate factor in the term
					#$sTermFormulaDiff = $sTermFormula->D($ac);
					#stoutDebugMessage("Student derivative result: ", $sTermFormula, " -> ", $sTermFormulaDiff);					
					foreach $fac (@sFactors){
						next if $thisConstantMatched; 
						my $res = stoutUtils::matchUpToConstant($context, $ac, $fac);
						if (defined $res){
							$thisConstantMatched = 1;
							$fac = main::Formula($context,$fac)->substitute($ac=>1)->string;
						}
					}
					# $sTermFormula = $sTermFormula->substitute($ac=>1);
					if (!$thisConstantMatched){
						$ans_hash->setKeys( 'ans_message' => "Arbitrary constant $ac does not appear to be properly used in your answer" );
						$ans_hash->{score} = 0;
						return $ans_hash; 
					}
					$sConstantsUsed{$ac}=1;
					@sTermsFP = ();
					for ($k = 0; $k < scalar (@sFactors); $k++){
						push (@sTermsFP, "(".$sFactors[$k].")^(".$sPowers[$k].")");
					}
					$sTermFormula = main::Formula($context, join("*",@sTermsFP));
			}

			stoutDebugShowArrayRef("Student term factors w/o powers",\@sFactors);
			
			stoutDebugMessage("Matching |". $cTermFormula->string ."| with |".$sTermFormula->string."|");
			
			if ($cConstantCount != 0){
				$result = stoutUtils::matchUpToConstant($context, $cTermFormula->string, $sTermFormula->string, non_trivial=>1);
			} else {
				$result = undef;
				# no constant in the correc term - should be no constant in the student term
				$res_hash = $cTermFormula->cmp()->evaluate($sTerm);
				if ($res_hash->{score}==1){
					$result = 1;
				}
			}
			
			if ($sConstantCount != $cConstantCount) {
				stoutDebugMessage("Did not match $cTerm with $sTerm due to constant count mismatch");
				if (defined $result){
					$ans_hash->setKeys( 'ans_message' => "You might want to double-check the use of arbitrary constants in your answer" );
				}
				$result = undef;
			}
			
			if (defined $result){
				$matched{$i} = 1;
				$smatched{$j} = 1;
				$correctTerms++; 
				stoutDebugMessage("MATCHED |". $cTermFormula->string ."| with |".$sTermFormula->string."|");
			} else {
				stoutDebugMessage("FAILED to match |". $cTermFormula->string ."| with |".$sTermFormula->string."|");
			}
		}
	}

	$sConstantsCheck = 1;
	$cConstantsCheck = 1;
	foreach $c (keys %sConstantsUsed){
		if ( !(defined $cConstantsUsed{$c}) ){
			$sConstantsCheck = 0;
		}
	}

	foreach $c (keys %cConstantsUsed){
		if ( !(defined $sConstantsUsed{$c}) ){
			$cConstantsCheck = 0;
		}
	}
	
	if ( ($correctTerms==$numTerms) && ($numTerms == $snumTerms) ){
		if ($sConstantsCheck*$cConstantsCheck == 1){			
			$ans_hash->{score} = 1;
			return $ans_hash;
		} else {
			$ans_hash->setKeys( 'ans_message' => "Your answer is close to being correct, but you need to check your use of arbitrary constants" );
			$ans_hash->{score} = 0;
			return $ans_hash;
		}
	} elsif ($snumTerms < $numTerms) {
		$ans_hash->setKeys( 'ans_message' => "Does your answer contain all the terms? Also please make sure there is only one arbitrary constant per term" );
		$ans_hash->{score} = 0;
		return $ans_hash;
	} elsif ($snumTerms > $numTerms) {
		$ans_hash->setKeys( 'ans_message' => "Does your answer contain any unnecessary terms? Also please make sure there is only one arbitrary constant per term" );
		$ans_hash->{score} = 0;
		return $ans_hash;
	} else {
		$ans_hash->{score} = 0;
		return $ans_hash;
	}
	
	
	$hr_ans = $ans_hash; # copy the hash from above
	return $hr_ans;
}


# need this to correctly detect 'preview answers' vs. 'submit/check answers' mode
sub getPG {
  my $self = shift;
  (main::PG_restricted_eval(shift))[0];
#  eval ('package main; '.shift);  # faster
}

sub cmp {
	my $self = shift; 
	my %options = @_; 
	
	# debug: 
	# stoutDebugShowHashRef("Options in cmp", \%options);
	
	my $ans = new AnswerEvaluator;
	# $ans->{debug} = 1;
	$ans->ans_hash(
		type => "Linear General Solutuion",
		correct_ans => $self->{Formula},
		correct_value => $self,
	);
	$ans->install_evaluator('erase');
	
	# the following passes the %options we got here to the answer evaluator
	$ans->install_evaluator(sub {
		my $ans = shift;
		my $inputs = $self->getPG('${main::inputs_ref}');
		if ( defined $inputs->{action} ){
			$ans->{isPreview} = $inputs->{previewAnswers} || ($inputs->{action} =~ m/^Preview/);
		} else { 
			$ans->{isPreview} = $inputs->{previewAnswers};
		}
		$ans->{correct_value}->theEvaluator($ans, @_);
		}, 
		%options);	
	return $ans; 
}

sub maketerms {
	my $me = shift;
	my %options = @_;
	$options{sign} = 1 unless defined $options{sign}; 
	
	my $bop = $me->{bop};
	if (defined $bop){
		$bop =~ s/^\s+//;
		$bop =~ s/\s+$//;
	} else {
		$bop = "";
	}
	
	#stoutDebugShowVar("Expression", $me->string);
	#stoutDebugShowVar("BOP", $bop);
	#stoutDebugShowVar("LOP", $me->{lop}->string) if defined $me->{lop};
	#stoutDebugShowVar("ROP", $me->{rop}->string) if defined $me->{rop};

	if ($bop eq "+") {
		return ( maketerms($me->{lop}), maketerms($me->{rop}) );
	} elsif ($bop eq "-"){
		return ( maketerms($me->{lop}), maketerms($me->{rop}, sign => -1) );
	} else {
		if ( $options{sign} == 1){
			return $me->string;
		} elsif ($options{sign} == -1){
			return "-1*(".$me->string.")";
		} else {
			stoutDebugMessage("something is wrong...");
		}
	}
}	

sub makefactors {
	my $me = shift;
	
	my $bop = $me->{bop};

	if (defined $bop){
		$bop =~ s/^\s+//;
		$bop =~ s/\s+$//;
	} else {
		$bop = "";
	}
	
	my $uop = $me->{uop};
	if (defined $uop){
		$uop =~ s/^\s+//;
		$uop =~ s/\s+$//;
	} else {
		$uop = "";
	}

	#stoutDebugShowVar("Expression", $me->string);
	#stoutDebugShowVar("BOP", $bop);
	#stoutDebugShowVar("UOP", $uop);
	#stoutDebugShowVar("LOP", $me->{lop}->string) if defined $me->{lop};
	#stoutDebugShowVar("ROP", $me->{rop}->string) if defined $me->{rop};
	#stoutDebugShowVar("OP", $me->{op}->string) if defined $me->{op};

	if ( ($bop eq "*") ) {
		return ( makefactors($me->{lop}), makefactors($me->{rop}) );
	} elsif ( ( $bop eq "^") || ($bop eq "**") ) {
		# the factor has exponent!
		my $base = $me->{lop}->string; 
		my $exponent = $me->{rop}->string;
		return ($base, $exponent);
	} elsif ( ($bop eq "" ) && ($uop eq 'u-') ) {
		# there is no binary operation - could have unitary
		# need to figure out what to do here
		my $base = $me->string;
		my $exponent = 1;
		return ($base, $exponent);
	} else { 
		# the factor has no exponent
		my $base = $me->string;
		my $exponent = 1;
		return ($base, $exponent);
	}
}	


# the following is almost useless so far, as the overload does not work here
sub stringify {
  my $self = shift;
  return $self->string;
}

# the following is almost useless so far, as the overload does not work here
sub string{
	my $self = shift;
	return $self->{Formula};
}

# the following is almost useless so far, as the overload does not work here
sub TeX{
	my $self = shift;
	my $context = $self->{Context};
	my $strFormula = $self->{Formula};
	return main::Formula($context, $strFormula)->TeX();
}

package stoutGenericEquation;
@stoutGenericEquation::ISA =qw(Value);

# the easier debug block
# it uses functions from stoutUtils package,
# but allows local setting of debugging constant
our $stoutDebug = 0;

sub stoutDebugMessage{
	stoutUtils::stoutDebugMessage(@_) if $stoutDebug;
}

sub stoutDebugShowVar{
	stoutUtils::stoutDebugShowVar(@_) if $stoutDebug;
}

sub stoutDebugShowArrayRef{
	stoutUtils::stoutDebugShowArrayRef(@_) if $stoutDebug;
}

sub stoutDebugShowHashRef{
	stoutUtils::stoutDebugShowHashRef(@_) if $stoutDebug;
}

sub new {
	my $class = shift;
	my $string_formula = shift;
	my %options = @_;
	
	my $result = $class->getSides($string_formula);
	
	if ($result->{error}){
		warn "This: |$string_formula| does not look like an equation";
	}
	
	my $context = main::Context()->copy();
	my $self = { 
		Formula => $string_formula,
		Context => $context,
		LHS => $result->{lhs},
		RHS => $result->{rhs},
		};
	bless $self, $class;
}

sub theEvaluator { 
	my $self = shift; 
	my $hr_ans = shift; 
	stoutDebugShowHashRef("hr_ans variable", $hr_ans); 
	stoutDebugShowVar("Preview", $hr_ans->{isPreview}); 
			
	# store the options we got from the call to cmp() method
	my %options = @_;
	
	# debug
	stoutDebugShowHashRef("Options", \%options);

	my $isPreview = 0;
	
	if (defined $hr_ans->{isPreview}){
		if ( !($hr_ans->{isPreview} eq "")){
		$isPreview  = 1;
		}
	}
	stoutDebugShowVar('isPreview',$isPreview);
	
	my $ans = $hr_ans->{correct_value}->{Formula};
	my $ans_tex = $hr_ans->{correct_value}->TeX;
	my $clhs = $hr_ans->{correct_value}->{LHS};
	my $crhs = $hr_ans->{correct_value}->{RHS};
	
	my $context = $hr_ans->{correct_value}->{Context};

	my $student_ans = $hr_ans->{student_ans};

	my $sresult = $self->getSides($student_ans);
	stoutDebugShowHashRef("Student result", $sresult);
	
	if ($sresult->{error}){
		$hr_ans->{score} = 0;
		$hr_ans->setKeys( 'ans_message' => "Your answer does not look like an equation" );
		return $hr_ans;
	}
	
	my $slhs = $sresult->{lhs};
	my $srhs = $sresult->{rhs};
	
	my $ans_hash = main::Formula($context, $clhs)->cmp()->evaluate($slhs);
	# need to do syntax error check before going furhter
	if ( defined $ans_hash->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($ans_hash->{error_message} eq "") ){
			$err = $ans_hash->{error_message};
			$ans_hash->setKeys( 'ans_message' => "Error in the left hand side of your equation. ".$err );
			return $ans_hash;
		}
	}

	$ans_hash = main::Formula($context, $crhs)->cmp()->evaluate($srhs);
	# need to do syntax error check before going furhter
	if ( defined $ans_hash->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($ans_hash->{error_message} eq "") ){
			$err = $ans_hash->{error_message};
			$ans_hash->setKeys( 'ans_message' => "Error in the right hand side of your equation. ".$err );
			return $ans_hash;
		}
	}

	my $sans_string = $slhs .'='.$srhs;
	my $sans_tex = main::Formula($context, $slhs)->TeX .'='. main::Formula($context, $srhs)->TeX;
	
	$ans_hash = $hr_ans;
	$ans_hash->{student_ans} = $student_ans;
	$ans_hash->{original_student_ans} = $student_ans;
	$ans_hash->{correct_ans} = $ans;
	$ans_hash->{correct_ans_latex_string} = $ans_tex;
	$ans_hash->{preview_latex_string} = $sans_tex;
	$ans_hash->{preview_text_string} = $sans_string;

	
	# we should be safe to use student answer, since it should have passed parser
	
	# if it is a preview, we don't need to waste time
	# doing full answer check; return what we've got now
	if ($isPreview){
		return $ans_hash;
	}
		
	my $match = stoutUtils::matchUpToConstant($context, "($clhs)-($crhs)","($slhs)-($srhs)", non_trivial => 1 );
	
	if ( defined $match ){
		$ans_hash->{score} = 1;
		return $ans_hash;		
	}
	
	# my $f_clhs = main::Formula($clhs);
	# my $f_crhs = main::Formula($crhs);
	
	# $res_l = $f_clhs->cmp()->evaluate($slhs);
	# $res_r = $f_crhs->cmp()->evaluate($srhs);
	
	# if ( ($res_l->{score} == 1) && ($res_r->{score} = 1) ){
		# $hr_ans->{score} = 1;
		# return $hr_ans;		
	# } 
	
	# $res_l = $f_clhs->cmp()->evaluate($srhs);
	# $res_r = $f_crhs->cmp()->evaluate($slhs);
	
	# if ( ($res_l->{score} == 1) && ($res_r->{score} = 1) ){
		# $hr_ans->{score} = 1;
		# return $hr_ans;		
	# } 
	
	
	$ans_hash->{score} = 0;

	return $ans_hash;
}

# need this to correctly detect 'preview answers' vs. 'submit/check answers' mode
sub getPG {
  my $self = shift;
  (main::PG_restricted_eval(shift))[0];
#  eval ('package main; '.shift);  # faster
}

sub cmp {
	my $self = shift; 
	my %options = @_; 
	
	# debug: 
	stoutDebugShowHashRef("Options in cmp", \%options);
	
	my $ans = new AnswerEvaluator;
	# $ans->{debug} = 1;
	$ans->ans_hash(
		type => "Generic Equation",
		correct_ans => $self->{Formula},
		correct_value => $self,
	);
	$ans->install_evaluator('erase');
	
	# the following passes the %options we got here to the answer evaluator
	$ans->install_evaluator(sub {
		my $ans = shift;
		my $inputs = $self->getPG('${main::inputs_ref}');
		if ( defined $inputs->{action} ){
			$ans->{isPreview} = $inputs->{previewAnswers} || ($inputs->{action} =~ m/^Preview/);
		} else { 
			$ans->{isPreview} = $inputs->{previewAnswers};
		}
		$ans->{correct_value}->theEvaluator($ans, @_);
		}, 
		%options);	
	return $ans; 
}

sub hasEquality{
	my $self = shift;
	my $equation = shift;
	
	$equation = "" unless (defined $equation);
	
	my $lhs = "";
	my $rhs = "";
	
	if ($equation=~/(.+)=(.+)/){
		# we have equality sign in the formula
		$lhs = $1;
		$rhs = $2;
		return { 
			lhs => $lhs, 
			rhs => $rhs,
			error => 0,
			};
	} else {
		# there is no equality sign, need to complain
		return { 
			lhs => undef,
			rhs => undef,
			error => 1,
			};
	}	
}

sub getSides{
	my $self = shift;
	my $equation = shift;
	
	stoutDebugShowVar("Equation string", $equation);
	
	my $result = $self->hasEquality($equation);
	
	stoutDebugShowHashRef("Result hash", $result);

	if ( !($result->{error}) ){
		# check to see if there are more equality signs in the mix
		$lhs_result = $self->hasEquality($result->{lhs});
		$rhs_result = $self->hasEquality($result->{rhs});		
		stoutDebugShowHashRef("LHS Result hash", $lhs_result);
		stoutDebugShowHashRef("RHS Result hash", $rhs_result);
		
		if ( ( !($lhs_result->{error}) ) || ( !($rhs_result->{error}) ) ){
			# no error in either means there are 
			# equality signs in that 'side'
			# that is bad!
			return {
				lhs => undef,
				rhs => undef,
				error => 1,
				};
		} else {
			# we've got no more equality signs
			# everything is good
			return {
				lhs => $result->{lhs},
				rhs => $result->{rhs},
				error => 0,
				};
		}
	}

	return {
		lhs => undef,
		rhs => undef,
		error => 1,
		};

}

# the following is almost useless so far, as the overload does not work here
sub stringify {
  my $self = shift;
  return $self->string;

}
	  
# the following is almost useless so far, as the overload does not work here
sub string{
	my $self = shift;
	return $self->{Formula};
}

# the following is almost useless so far, as the overload does not work here
sub TeX{
	my $self = shift;
	my $context = $self->{Context};
	
	my $lhsFormula = main::Formula($context, $self->{LHS});
	my $rhsFormula = main::Formula($context, $self->{RHS});
	
	my $res = $lhsFormula->TeX() . '=' . $rhsFormula->TeX();
	
	return $res;	
}

package stoutSlopeInterceptEquation;
@stoutSlopeInterceptEquation::ISA = qw(stoutGenericEquation);

# the easier debug block
# it uses functions from stoutUtils package,
# but allows local setting of debugging constant
our $stoutDebug = 0;

sub stoutDebugMessage{
	stoutUtils::stoutDebugMessage(@_) if $stoutDebug;
}

sub stoutDebugShowVar{
	stoutUtils::stoutDebugShowVar(@_) if $stoutDebug;
}

sub stoutDebugShowArrayRef{
	stoutUtils::stoutDebugShowArrayRef(@_) if $stoutDebug;
}

sub stoutDebugShowHashRef{
	stoutUtils::stoutDebugShowHashRef(@_) if $stoutDebug;
}

sub new {
	my $class = shift;
	my $string_formula = shift;
	my %options = @_;
	my $context = main::Context()->copy();
	
	my $result = $class->getSides($string_formula);
	
	if ($result->{error}){
		warn "This: |$string_formula| does not look like an equation";
	}

	my $lhs = $result->{lhs};	
	$lhs =~ s/^\s+//;
	$lhs =~ s/\s+$//;

	my $rhs = $result->{rhs};	
	$rhs =~ s/^\s+//;
	$rhs =~ s/\s+$//;
	
	if ($lhs ne "y"){
		warn "This |$string_formula| should have y as its left hand side. Got |$lhs|.";
	}
	
	my $fans = main::Formula($context, $rhs);
	my @terms = maketerms($fans->{tree});
	
	my $count = scalar @terms; 
	
	if ($count > 2){
		warn "This |$string_formula| should have at most 2 terms as its right hand side. Got |$rhs|.";
	}
	
	my $const_term = 0;
	my $slope_term = 0;
	my $error_in_slope_term = 0;
	
	for my $tt (@terms){
		my $f_tt = main::Formula($context, $tt);
		if ($f_tt->isConstant){
			$const_term++;
		}else{
			my $f_m = $f_tt->substitute('x'=>1);
			my $f_mm = main::Formula($context, "$f_m * x");
			if ($f_mm == $f_tt){
				$slope_term++;
			}else{
				$error_in_slope_term++;
			}
		}
	}
	
	if ( ($const_term > 1) ){
		warn "This |$string_formula| does not look like slope-intercept formula: it contains two constant terms on its left hand side. Got |$rhs|.";
	}

	if ( ($slope_term > 1) ){
		warn "This |$string_formula| does not look like slope-intercept formula: it contains two terms with x on its left hand side. Got |$rhs|.";
	}

	if ( ($error_in_slope_term > 0) ){
		warn "This |$string_formula| does not look like slope-intercept formula: it does not seem to contain a simplified slope term. Got |$rhs|.";
	}
	
	my $self = { 
		Formula => $string_formula,
		Context => $context,
		LHS => $result->{lhs},
		RHS => $result->{rhs},
		};
	bless $self, $class;
	
}

sub maketerms {
	my $me = shift;
	my %options = @_;
	$options{sign} = 1 unless defined $options{sign}; 
	
	my $bop = $me->{bop};
	if (defined $bop){
		$bop =~ s/^\s+//;
		$bop =~ s/\s+$//;
	} else {
		$bop = "";
	}
	
	stoutDebugShowVar("Expression", $me->string);
	stoutDebugShowVar("BOP", $bop);
	stoutDebugShowVar("LOP", $me->{lop}->string) if defined $me->{lop};
	stoutDebugShowVar("ROP", $me->{rop}->string) if defined $me->{rop};

	if ($bop eq "+") {
		return ( maketerms($me->{lop}), maketerms($me->{rop}) );
	} elsif ($bop eq "-"){
		return ( maketerms($me->{lop}), maketerms($me->{rop}, sign => -1) );
	} else {
		if ( $options{sign} == 1){
			return $me->string;
		} elsif ($options{sign} == -1){
			return "-1*(".$me->string.")";
		} else {
			stoutDebugMessage("something is wrong...");
		}
	}
}	

sub theEvaluator { 
	my $self = shift; 
	my $hr_ans = shift; 
	stoutDebugShowHashRef("hr_ans variable", $hr_ans); 
	stoutDebugShowVar("Preview", $hr_ans->{isPreview}); 
			
	# store the options we got from the call to cmp() method
	my %options = @_;
	
	# debug
	stoutDebugShowHashRef("Options", \%options);

	my $isPreview = 0;
	
	if (defined $hr_ans->{isPreview}){
		if ( !($hr_ans->{isPreview} eq "")){
		$isPreview  = 1;
		}
	}
	stoutDebugShowVar('isPreview',$isPreview);
	
	my $ans = $hr_ans->{correct_value}->{Formula};
	my $ans_tex = $hr_ans->{correct_value}->TeX;
	my $clhs = $hr_ans->{correct_value}->{LHS};
	my $crhs = $hr_ans->{correct_value}->{RHS};
	
	my $context = $hr_ans->{correct_value}->{Context};

	my $student_ans = $hr_ans->{student_ans};

	my $sresult = $self->getSides($student_ans);
	stoutDebugShowHashRef("Student result", $sresult);
	
	if ($sresult->{error}){
		$hr_ans->{score} = 0;
		$hr_ans->setKeys( 'ans_message' => "Your answer does not look like an equation" );
		return $hr_ans;
	}
	
	my $slhs = $sresult->{lhs};
	my $srhs = $sresult->{rhs};
	
	my $ans_hash = main::Formula($context, $clhs)->cmp()->evaluate($slhs);
	# need to do syntax error check before going furhter
	if ( defined $ans_hash->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($ans_hash->{error_message} eq "") ){
			$err = $ans_hash->{error_message};
			$ans_hash->setKeys( 'ans_message' => "Error in the left hand side of your equation. ".$err );
			return $ans_hash;
		}
	}

	$ans_hash = main::Formula($context, $crhs)->cmp()->evaluate($srhs);
	# need to do syntax error check before going furhter
	if ( defined $ans_hash->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($ans_hash->{error_message} eq "") ){
			$err = $ans_hash->{error_message};
			$ans_hash->setKeys( 'ans_message' => "Error in the right hand side of your equation. ".$err );
			return $ans_hash;
		}
	}

	my $sans_string = $slhs .'='.$srhs;
	my $sans_tex = main::Formula($context, $slhs)->TeX .'='. main::Formula($context, $srhs)->TeX;
	
	$ans_hash = $hr_ans;
	$ans_hash->{student_ans} = $student_ans;
	$ans_hash->{original_student_ans} = $student_ans;
	$ans_hash->{correct_ans} = $ans;
	$ans_hash->{correct_ans_latex_string} = $ans_tex;
	$ans_hash->{preview_latex_string} = $sans_tex;
	$ans_hash->{preview_text_string} = $sans_string;
	$ans_hash->{score} = 0; # just in case
	
	# we should be safe to use student answer, since it should have passed parser
	
	# if it is a preview, we don't need to waste time
	# doing full answer check; return what we've got now
	if ($isPreview){
		return $ans_hash;
	}
	
	# now we check if student answer looks like slope intercept equation

	$slhs =~ s/^\s+//;
	$slhs =~ s/\s+$//;

	$srhs =~ s/^\s+//;
	$srhs =~ s/\s+$//;
	
	if ($slhs ne "y"){
			$ans_hash->setKeys( 'ans_message' => "Your answer should contain y as the left hand side of the equation" );
			return $ans_hash;
	}
	
	my $fans = main::Formula($context, $srhs);
	my @terms = maketerms($fans->{tree});
	
	my $count = scalar @terms; 
	
	if ($count > 2){
		$ans_hash->setKeys( 'ans_message' => "Your answer should have at most 2 terms as its right hand side." );
		return $ans_hash;
	}
	
	my $const_term = 0;
	my $slope_term = 0;
	my $error_in_slope_term = 0;
	
	for my $tt (@terms){
		my $f_tt = main::Formula($context, $tt);
		if ($f_tt->isConstant){
			$const_term++;
		}else{
			my $f_m = $f_tt->substitute('x'=>1);
			my $f_mm = main::Formula($context, "$f_m * x");
			if ($f_mm == $f_tt){
				$slope_term++;
			}else{
				$error_in_slope_term++;
			}
		}
	}
	
	if ( ($const_term > 1) ){
		$ans_hash->setKeys( 'ans_message' => "Your answer should have at most 1 constant term in its right hand side." );
		return $ans_hash;
	}

	if ( ($slope_term > 1) ){
		$ans_hash->setKeys( 'ans_message' => "Your answer should have at most 1 term with x in its right hand side." );
		return $ans_hash;
	}

	if ( ($error_in_slope_term > 0) ){
		$ans_hash->setKeys( 'ans_message' => "It looks like the term with x in your answer could be simplified. " );
		return $ans_hash;
	}

	# if we're at this stage, the equation should look like slope-intercept equation. 
	# we now do a simple check of the equation
	
	my $match = stoutUtils::matchUpToConstant($context, "($clhs)-($crhs)","($slhs)-($srhs)", non_trivial => 0 );
	
	if ( defined $match ){
		$ans_hash->{score} = 1;
		return $ans_hash;
	}
	
	$ans_hash->{score} = 0; # again to be sure

	return $ans_hash;
}

package stoutCircleStandardEquation;
@stoutCircleStandardEquation::ISA = qw(stoutGenericEquation);


# the easier debug block
# it uses functions from stoutUtils package,
# but allows local setting of debugging constant
our $stoutDebug = 0;

sub stoutDebugMessage{
	stoutUtils::stoutDebugMessage(@_) if $stoutDebug;
}

sub stoutDebugShowVar{
	stoutUtils::stoutDebugShowVar(@_) if $stoutDebug;
}

sub stoutDebugShowArrayRef{
	stoutUtils::stoutDebugShowArrayRef(@_) if $stoutDebug;
}

sub stoutDebugShowHashRef{
	stoutUtils::stoutDebugShowHashRef(@_) if $stoutDebug;
}

sub new {
	my $class = shift;
	my $string_formula = shift;
	my %options = @_;
	my $context = main::Context()->copy();
	
	my $result = $class->getSides($string_formula);
	
	if ($result->{error}){
		warn "This: |$string_formula| does not look like an equation";
	}

	my $lhs = $result->{lhs};	
	$lhs =~ s/^\s+//;
	$lhs =~ s/\s+$//;

	my $rhs = $result->{rhs};	
	$rhs =~ s/^\s+//;
	$rhs =~ s/\s+$//;

	my $rhs_formula = main::Formula($context, $rhs);
	if ( !($rhs_formula->isConstant) ){
		warn "This: |$string_formula| should have radius (constant) as its right hand side.";
	}
	
	my $lhs_formula = main::Formula($context, $lhs);
	my @terms = maketerms($lhs_formula->{tree});
	
	my $count = scalar @terms; 
	
	if ($count > 2){
		warn "This |$string_formula| should have at most 2 terms as its left hand side. Got |$lhs|.";
	}
	
	my $self = { 
		Formula => $string_formula,
		Context => $context,
		LHS => $result->{lhs},
		RHS => $result->{rhs},
		};
	bless $self, $class;
	
}

sub maketerms {
	my $me = shift;
	my %options = @_;
	$options{sign} = 1 unless defined $options{sign}; 
	
	my $bop = $me->{bop};
	if (defined $bop){
		$bop =~ s/^\s+//;
		$bop =~ s/\s+$//;
	} else {
		$bop = "";
	}
	
	stoutDebugShowVar("Expression", $me->string);
	stoutDebugShowVar("BOP", $bop);
	stoutDebugShowVar("LOP", $me->{lop}->string) if defined $me->{lop};
	stoutDebugShowVar("ROP", $me->{rop}->string) if defined $me->{rop};

	if ($bop eq "+") {
		return ( maketerms($me->{lop}), maketerms($me->{rop}) );
	} elsif ($bop eq "-"){
		return ( maketerms($me->{lop}), maketerms($me->{rop}, sign => -1) );
	} else {
		if ( $options{sign} == 1){
			return $me->string;
		} elsif ($options{sign} == -1){
			return "-1*(".$me->string.")";
		} else {
			stoutDebugMessage("something is wrong...");
		}
	}
}	

sub theEvaluator { 
	my $self = shift; 
	my $hr_ans = shift; 
	stoutDebugShowHashRef("hr_ans variable", $hr_ans); 
	stoutDebugShowVar("Preview", $hr_ans->{isPreview}); 
			
	# store the options we got from the call to cmp() method
	my %options = @_;
	
	# debug
	stoutDebugShowHashRef("Options", \%options);

	my $isPreview = 0;
	
	if (defined $hr_ans->{isPreview}){
		if ( !($hr_ans->{isPreview} eq "")){
		$isPreview  = 1;
		}
	}
	stoutDebugShowVar('isPreview',$isPreview);
	
	my $ans = $hr_ans->{correct_value}->{Formula};
	my $ans_tex = $hr_ans->{correct_value}->TeX;
	my $clhs = $hr_ans->{correct_value}->{LHS};
	my $crhs = $hr_ans->{correct_value}->{RHS};
	
	my $context = $hr_ans->{correct_value}->{Context};

	my $student_ans = $hr_ans->{student_ans};

	my $sresult = $self->getSides($student_ans);
	stoutDebugShowHashRef("Student result", $sresult);
	
	if ($sresult->{error}){
		$hr_ans->{score} = 0;
		$hr_ans->setKeys( 'ans_message' => "Your answer does not look like an equation" );
		return $hr_ans;
	}
	
	my $slhs = $sresult->{lhs};
	my $srhs = $sresult->{rhs};
	
	my $ans_hash = main::Formula($context, $clhs)->cmp()->evaluate($slhs);
	# need to do syntax error check before going furhter
	if ( defined $ans_hash->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($ans_hash->{error_message} eq "") ){
			$err = $ans_hash->{error_message};
			$ans_hash->setKeys( 'ans_message' => "Error in the left hand side of your equation. ".$err );
			return $ans_hash;
		}
	}

	$ans_hash = main::Formula($context, $crhs)->cmp()->evaluate($srhs);
	# need to do syntax error check before going furhter
	if ( defined $ans_hash->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($ans_hash->{error_message} eq "") ){
			$err = $ans_hash->{error_message};
			$ans_hash->setKeys( 'ans_message' => "Error in the right hand side of your equation. ".$err );
			return $ans_hash;
		}
	}

	my $sans_string = $slhs .'='.$srhs;
	my $sans_tex = main::Formula($context, $slhs)->TeX .'='. main::Formula($context, $srhs)->TeX;
	
	$ans_hash = $hr_ans;
	$ans_hash->{student_ans} = $student_ans;
	$ans_hash->{original_student_ans} = $student_ans;
	$ans_hash->{correct_ans} = $ans;
	$ans_hash->{correct_ans_latex_string} = $ans_tex;
	$ans_hash->{preview_latex_string} = $sans_tex;
	$ans_hash->{preview_text_string} = $sans_string;
	$ans_hash->{score} = 0; # just in case
	
	# we should be safe to use student answer, since it should have passed parser
	
	# if it is a preview, we don't need to waste time
	# doing full answer check; return what we've got now
	if ($isPreview){
		return $ans_hash;
	}
	
	# now we check if student answer looks like equation of circle in standard form

	$slhs =~ s/^\s+//;
	$slhs =~ s/\s+$//;

	$srhs =~ s/^\s+//;
	$srhs =~ s/\s+$//;

	my $srhs_formula = main::Formula($context, $srhs);
	if ( !($srhs_formula->isConstant) ){
		$ans_hash->setKeys( 'ans_message' => "Your answer should have radius as its right hand side");
		return $ans_hash;
	}
	
	my $slhs_formula = main::Formula($context, $slhs);
	my @terms = maketerms($slhs_formula->{tree});
	
	my $count = scalar @terms; 
	
	if ($count > 2){
		$ans_hash->setKeys( 'ans_message' => "Your answer should have at most 2 terms as its left hand side");
		return $ans_hash;
	}

	my $score_rhs = 0;
	my $score_lhs = 0;
	
	my $crhs_formula = main::Formula($context, $crhs);
	if ($crhs_formula == $srhs_formula){
		$score_rhs = 1;
	}
	
	my $lhs_hash = main::SumOfTermsFormula($clhs)->cmp(factored_terms=>1)->evaluate($slhs);
	
	$score_lhs = $lhs_hash->{score};
	
	$ans_hash->{score} = ($score_rhs + $score_lhs)/2;

	return $ans_hash;
}

