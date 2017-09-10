=head1 NAME

stoutFactoringGraders.pl

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

## the old sub -- should phase it out
sub GradeFactors {
	# force the use of object-oriented grader
	return FactoredFormula(shift)->cmp(); 
}

## used internally, don't know if it is useful in general
sub FormulaUpToConstant{
	my $string_formula = shift;
	my $ref_factored_formula = new stoutFormulaUpToConstant($string_formula);
	return $ref_factored_formula; 
}

## the defalt way to create factored formula answer checker
sub FactoredFormula{
	my $string_formula = shift;
	my $ref_factored_formula = new stoutFactoredFormula($string_formula);
	return $ref_factored_formula; 
}

## the default way to create factored formula that is correct up to 
## a constant factor answer checker
sub FactoredFormulaUpToConstant{
	my $string_formula = shift;
	my $ref_factored_formula = new stoutFactoredFormula($string_formula, up_to_constant => 1);
	return $ref_factored_formula; 
}

## the default way to create factored rational formula answer checker
## the option 
sub FactoredRationalFormula{
	my $string_rational_formula = shift;
	my $ref_factored_rational_formula = new stoutFactoredRationalFormula($string_rational_formula);
	return $ref_factored_rational_formula; 
}

package stoutFormulaUpToConstant;

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

sub theEvaluator { 
	my $hr_ans = shift; 
	
	# store the options we got from the call to cmp() method
	my %options = @_;
	
	my $ans = $hr_ans->{correct_ans}->{Formula};
	my $context = $hr_ans->{correct_ans}->{Context};
	my $fans = main::Formula($context, $ans);

	my $student_ans = $hr_ans->{student_ans};
	# the following verifies that student answer would parse
	# could use 
	# my $test = Parser::Formula($student_ans);
	# if (defined $test) { #proceed with the use of $student_ans }
	# but this method produces answer hash with any syntax errors 
	# being highlighted 
	my $ans_hash = main::Formula($context, $ans)->cmp()->evaluate($student_ans); 

	# need to do syntax error check before going furhter
	if ( defined $hr_ans->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		
		stoutDebugShowHashRef("Answer hash", $hr_ans);
		
		if ( !($hr_ans->{error_message} eq "") ){
			return $hr_ans;
		}
	}
	# we should be safe to use student answer, since it should have passed parser
	
	$ans_hash->{student_ans} = $student_ans;
	$ans_hash->{original_student_ans} = $student_ans;

	my $result = stoutUtils::matchUpToConstant($context, $ans, $student_ans);

	if ( (defined $result) && (abs($result) == 1) ){
		$ans_hash->{up_to_constant} = $result; 
		$ans_hash->{score} = 1;
		return $ans_hash;
	} else {
		$ans_hash->{score} = 0;
		$ans_hash->setKeys( 'ans_message' =>"Your answer seems to be off by a non-trivial constant");
		return $ans_hash;
	}
	

	$ans_hash->{score} = 0;
	$ans_hash->setKeys( 'ans_message' =>"Incorrect");
	
	return $hr_ans;
}

sub cmp {
	my $self = shift; 
	my %options = @_; 
	
	stoutDebugShowHashRef("Options in cmp", \%options);
	
	my $ans = new AnswerEvaluator(
		'correct_ans' => $self, 
		'type' => 'Formula Up To Constant',
		); 
	$ans->install_evaluator('erase');
	
	# the following passes the %options we got here to the answer evaluator
	$ans->install_evaluator(\&theEvaluator, %options);	
	return $ans; 
}


package stoutFactoredFormula;

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

# the following might be a good idea
# so that the factored formula has all 
# the MathObjects reduction goodness built in
# but something goes wrong with the inheritance, etc...
# our @ISA = ( 'Value::Formula' );

# sub new {
	# my $class = shift;
	# my $f = $class->SUPER::new(@_);
	# my $string_formula = shift;
	# $f->{Formula} = $string_formula;
	# return $f;
# }

sub new {
	my $class = shift;
	my $string_formula = shift;
	my %options = @_;
	
	$options{up_to_constant} = 0 unless defined $options{up_to_constant};
	
	my $context = main::Context()->copy();
	my $self = { 
		Formula => $string_formula,
		Context => $context,
		UpToConstant => $options{up_to_constant},
		};
	bless $self, $class;
}

# looks like it is easier to make a new reduce method
# instead of trying to inherit from MathObjects
sub reduce{
	my $self = shift;
	my $original_formula = $self->{Formula};
	my $context = $self->{Context};
	
	stoutDebugShowHashRef("Context inherited by formula", $context->{flags});
	
	my $new_formula = main::Formula($context, $original_formula)->reduce;
	$self->{Formula} = $new_formula->string;
	return $self; 
}

sub theEvaluator { 
	my $hr_ans = shift; 
	
	# store the options we got from the call to cmp() method
	my %options = @_;
	
	# the options we could use: 
	# $options{constant_factors} = keep|combine
	# $options{exponents} = integers|positive|fractions|constant|any
	# $options{factors} = strict_polynomials|strict_terms|any

	$options{constant_factors} = 'keep' unless defined $options{constant_factors};
	$options{exponents} = 'any' unless defined $options{exponents};
	$options{factors} = 'any' unless defined $options{factors};
	$options{up_to_constant} = 0 unless defined $options{up_to_constant}; 
	
	stoutDebugShowHashRef("Options ", \%options);
	
	my $ans = $hr_ans->{correct_ans}->{Formula};
	my $context = $hr_ans->{correct_ans}->{Context};
	my $fans = main::Formula($context, $ans);
	my @factorspowers = makefactors($fans->{tree});

	stoutDebugShowArrayRef("Factors and powers", \@factorspower);

	if ($options{constant_factors} eq 'combine'){
		@factorspowers = combineConstantFactors($context, @factorspowers);
	}
	
	my @factors = ();
	my @powers = (); 
	my $i; 
	for ($i = 0; $i < scalar @factorspowers; $i+=2){
		push @factors, $factorspowers[$i];
		push @powers, $factorspowers[$i+1];
	}
	
	stoutDebugShowArrayRef("Factors", \@factors);
	stoutDebugShowArrayRef("Powers", \@powers);
	
	my $numCorrectFactors = scalar @factors; 

	my $student_ans = $hr_ans->{student_ans};
	# the following verifies that student answer would parse
	# could use 
	# my $test = Parser::Formula($student_ans);
	# if (defined $test) { #proceed with the use of $student_ans }
	# but this method produces answer hash with any syntax errors 
	# being highlighted 
	my $ans_hash = main::Formula($context, $ans)->cmp()->evaluate($student_ans); 

	# need to do syntax error check before going furhter
	if ( defined $hr_ans->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($hr_ans->{error_message} eq "") ){
			return $hr_ans;
		}
	}
	# we should be safe to use student answer, since it should have passed parser
	
	my $can_proceed = 0; 
	if ( $ans_hash->{score} == 1) { 
		$can_proceed = 1;
	} elsif ($options{up_to_constant}){
		my $result = stoutUtils::matchUpToConstant($context, $ans, $student_ans);
		if ((defined $result) && (abs($result)==1)){
				$can_proceed = 1;
		}
	}
	
	$ans_hash->{student_ans} = $student_ans;
	$ans_hash->{original_student_ans} = $student_ans;

	if ( $can_proceed ) { 
		# since we got here, student's answer is equivalent to the correct one
		my $sans = main::Formula($context, $student_ans);
		my @sfactorspowers = makefactors($sans->{tree});
		my @sfactors=();
		my @spowers=();
		if ($options{constant_factors} eq 'combine'){
			@sfactorspowers = combineConstantFactors($context, @sfactorspowers);
		}
		for ($i = 0; $i < scalar @sfactorspowers; $i+=2){
			push @sfactors, $sfactorspowers[$i];
			push @spowers, $sfactorspowers[$i+1];
		}

		stoutDebugShowArrayRef("Student Factors", \@sfactors);
		stoutDebugShowArrayRef("Student Powers", \@spowers);
		
		my $snumCorrectFactors = scalar @sfactors; 
		
		if ( $snumCorrectFactors < $numCorrectFactors) {
			$ans_hash->setKeys( 'ans_message' => "Make sure that your answer is factored completely!" );
			$ans_hash->{score} = 0;
			return $ans_hash;
		}
		if ( $snumCorrectFactors > $numCorrectFactors) {
			$ans_hash->setKeys( 'ans_message' => "Your  answer is equivalent to the correct one, but it has too many factors. Does your answer contain repeated factors?" );
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
			$cpower = main::Formula($context, $powers[$i]);
			for ($j = 0; $j < scalar @sfactors; $j++) {
				$sfactor = $sfactors[$j];
				$spower = main::Formula($context, $spowers[$j]);
				my $result = stoutUtils::matchUpToConstant($context, $cfactor, $sfactor);
				if ((defined $result) && (abs($result)==1)){
					# only factors correct up to negative are counted
					# but that could be changed to 'up to a constant', if needed
					if ( $cpower == $spower){
						$correctFactors++; 
						$accumulatedFactor *= ($result)**($cpower);
					} 
				} else {
					# factor is close to correct one, but it differes by a non-trivial constant
					$offByConstant = 1;
				}
			}
		}
		
		if ( ($correctFactors == $numCorrectFactors) && ($accumulatedFactor == 1) ) {
			$ans_hash->{score} = 1;
			return $ans_hash; 
		}
		
		if ( ($options{up_to_constant}) && ($correctFactors == $numCorrectFactors) ){
			$ans_hash->{up_to_constant} = $accumulatedFactor; 
			$ans_hash->{score} = 1;
			return $ans_hash;
		}
		
		if ($offByConstant == 1){
			$ans_hash->{score} = 0;
			$ans_hash->setKeys( 'ans_message' =>"Your answer is algebraically equivalent to the correct one, but some factors are off by a non-trivial constant. Are your factors reasonably simplified?");
			return $ans_hash;
		}
		
		$ans_hash->{score} = 0;
		$ans_hash->setKeys( 'ans_message' =>"Your answer is algebraically equivalent to the correct one, but you want to factor it completely.");
	}
	
	$hr_ans = $ans_hash; # copy the hash from above
	return $hr_ans;
}

sub cmp {
	my $self = shift; 
	my %options = @_; 
	
	# debug: 

	stoutDebugShowHashRef("Options in cmp", \%options);
	
	my $ans = new AnswerEvaluator(
		'correct_ans' => $self, 
		'type' => 'Factored Formula',
		); 
	$ans->install_evaluator('erase');
	
	# the following passes the %options we got here to the answer evaluator
	$ans->install_evaluator(\&theEvaluator, up_to_constant => $self->{UpToConstant}, %options);	
	return $ans; 
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

	stoutDebugShowVar("Expression", $me->string);
	stoutDebugShowVar("BOP", $bop);
	stoutDebugShowVar("UOP", $uop);
	stoutDebugShowVar("LOP", $me->{lop}->string) if defined $me->{lop};
	stoutDebugShowVar("ROP", $me->{rop}->string) if defined $me->{rop};
	stoutDebugShowVar("OP", $me->{op}->string) if defined $me->{op};

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

sub combineConstantFactors{
	my $context = shift;
	my @inputFactorsPowers = @_;
	
	stoutDebugShowArrayRef("Factors and powers", \@inputFactorsPowers);
	
	my @outputFactorsPowers;
	my $i; 
	my $factor;
	my $power;
	my $f_factor;
	my $constant = 1;
	for ($i = 0; $i < scalar @inputFactorsPowers; $i+=2){
		$factor = $inputFactorsPowers[$i];
		$power = $inputFactorsPowers[$i+1];
		$f_factor = ::Formula($context,"($factor)^($power)"); 
		if ($f_factor->isConstant){
			$constant *= $f_factor->value; 
		} else {
			push @outputFactorsPowers, $factor;
			push @outputFactorsPowers, $power;
		}
	}
	if ($constant != 1){
		push @outputFactorsPowers, $constant;
		push @outputFactorsPowers, 1;
	}
	
	# debug
	stoutDebugShowArrayRef("Output Factors and Powers", \@outputFactorsPowers);
	
	return @outputFactorsPowers; 
}

sub stringify {
  my $self = shift;
  return $self->string;
}

sub string{
	my $self = shift;
	return $self->{Formula};
}

sub TeX{
	my $self = shift;
	my $context = $self->{Context};
	my $strFormula = $self->{Formula};
	return main::Formula($context, $strFormula)->TeX();
}


package stoutFactoredRationalFormula;

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
	
	my $self = { Formula => $string_formula};
	
	bless $self, $class;
}

sub findNumeratorDenominator {
	my $me = shift;
	
	my $bop = $me->{bop};

	if (defined $bop) {
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
	
	stoutDebugShowVar("Expression", $me->string);
	stoutDebugShowVar("BOP", $bop);
	stoutDebugShowVar("UOP", $uop);
	stoutDebugShowVar("LOP", $me->{lop}->string) if defined $me->{lop};
	stoutDebugShowVar("ROP", $me->{rop}->string) if defined $me->{rop};
	stoutDebugShowVar("OP", $me->{op}->string) if defined $me->{op};

	if ($bop eq "/" ) {
		return { 
			'numerator' => $me->{lop}->string, 
			'denominator' => $me->{rop}->string,
			'error_code' => 0,
			};
	} elsif ($bop eq "*") {
		$l_res = findNumeratorDenominator($me->{lop});
		$r_res = findNumeratorDenominator($me->{rop});
		
		if ( ( !( $l_res->{denominator} eq "") ) && ( !( $r_res->{denominator} eq "") ) ) {
			# two denominators or something else is wrong!
			return { 
				'numerator' => $me->string, 
				'denominator' => 'error', 
				'error_code' => 1
				};
		}
		return { 
			'numerator' => "(". $l_res->{numerator} .")*(". $r_res->{numerator} .")", 
			'denominator' => $l_res->{denominator} . $r_res->{denominator},
			'error_code' => 0,
			};
	} elsif ($uop eq "u-"){
		$u_res = findNumeratorDenominator($me->{op});
		return {
			'numerator' => "-(". $u_res->{numerator} .")", 
			'denominator' => $u_res->{denominator},
			'error_code' => $u_res->{error_code},
		};
	} else {
		return { 
			'numerator' => $me->string, 
			'denominator' => "",
			'error_code' => 0,
			};
	}
}

sub checkNumeratorDenominator{
	my $string_formula = shift; 
	
	if ($string_formula =~ /(.*)\/(.*)/ ) {
		# bad news - there is a division operation in the string somewhere
		# need to dig deeper
		my $formula = ::Formula($string_formula); 
		return detectRational($formula->{tree}); 
	} else {
		return 0; # no problems detected
	}
}

sub detectRational{
	my $me = shift; 
	my $bop = $me->{bop};
	if (defined $bop) {
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

	if ($bop eq "/" ) {
		# bad news -- we have division operation
		my $string = $me->string;
		my $f_string = ::Formula($string);
		if ($f_string->isConstant){
			return 0;
		} else {
			return 1;
		}
	} elsif( !($bop eq "") )  { 
		# there is some binary operation
		my $l_result = 0; 
		$l_result = detectRational($me->{lop}) if (defined $me->{lop});
		my $r_result = 0;
		$r_result = detectRational($me->{rop}) if (defined $me->{rop});		
		return ($l_result+$r_result);
	} elsif( !($uop eq "") ) {
		# there is some unitary operation
		my $u_result = 0;
		$u_result = detectRational($me->{op}) if (defined $me->{op});
		return $u_result; 
	}
}

sub theEvaluator { 
	my $hr_ans_init = shift; 
	
	# debug!
	# warn(::pretty_print($hr_ans_init));
	
	my %options = @_;
	
	$options{strict_match} = 0 unless defined $options{strict_match};
	$options{numerator_factored} = 0 unless defined $options{numerator_factored};
	
	my $ans = $hr_ans_init->{correct_ans};
	$ans = "" unless (defined $ans); 
	my $fans = ::Formula($ans);
	my $student_ans = $hr_ans_init->{student_ans};
	$student_ans = "" unless (defined $student_ans); 

	my $hr_ans = $fans->cmp()->evaluate($student_ans);
	# warn ::pretty_print($hr_ans); 
	
	if ( defined $hr_ans->{error_message} ){
		# error message was set - is that enough? 
		# TODO: might need to check $hr_ans->{error_flag} 
		# warn ::pretty_print($hr_ans); 
		if ( !($hr_ans->{error_message} eq "") ){
			return $hr_ans;
		}
	}
	
	my $ans_numerator="";
	my $ans_denominator="";

	my $sans_numerator="";
	my $sans_denominator="";
	
	$fans = ::Formula($ans);
	my $ans_split = findNumeratorDenominator($fans->{tree});
	# TODO: work with error status of the above call 
	if ( $ans_split->{error_code} > 0 ){
		# we have something wrong in the correct answer!!! 
		$hr_ans->{score} = 0; 
		$hr_ans->setKeys( 'ans_message' => "Something is wrong with the correct answer. Please let your professor know. Thanks!" );
		warn "Something is wrong with the correct answer. Please let your professor know. Thanks!";
		# warn ::pretty_print($ans_split);
		return $hr_ans;	
	}
	
	$ans_numerator = $ans_split->{numerator};
	$ans_denominator = $ans_split->{denominator};
	if ($ans_denominator eq ""){
		$ans_denominator = "1";
	}
	
	# debug!
	# warn "Numerator: |". ::pretty_print($ans_numerator) ."|"; 
	# warn "Denominator: |". ::pretty_print($ans_denominator) ."|";


	my $fsans = ::Formula($student_ans);
	my $sans_split = findNumeratorDenominator($fsans->{tree});
	# TODO: work with error status of the above call 
	# warn ::pretty_print($sans_split);

	if ( $sans_split->{error_code} > 0 ){
		# we have something wrong in the rational expression
		$hr_ans->{score} = 0; 
		$hr_ans->setKeys( 'ans_message' => "Your answer does not look like a single rational expression" );
		return $hr_ans;	
	}
	$sans_numerator = $sans_split->{numerator};
	$sans_denominator = $sans_split->{denominator};
	if ($sans_denominator eq ""){
		$sans_denominator = "1";
	}

	# TODO: check if student answer is in fact a 'flat' rational expression
	
	my $snum_check = checkNumeratorDenominator($sans_numerator);
	my $sden_check = checkNumeratorDenominator($sans_denominator);
	
	if ( ($snum_check + $sden_check) != 0){
		$hr_ans->{score} = 0; 
		$hr_ans->setKeys( 'ans_message' => "Your answer does not look like a valid rational expression. Are there parenthesis missing around numerator/denominator?" );
		return $hr_ans;
	}
	
	# debug!
	#warn "Student Numerator: |". ::pretty_print($sans_numerator) ."|"; 
	#warn "Student Denominator: |". ::pretty_print($sans_denominator) ."|";
	
	$student_formula = ::Formula($student_ans);
	$correct_student_formula = ::Formula( "( $sans_numerator )/( $sans_denominator )");
	# $result_hash = $correct_student_formula->cmp()->evaluate($student_formula);
	
	if ( $student_formula != $correct_student_formula ) {
		$hr_ans->{score} = 0; 
		$hr_ans->setKeys( 'ans_message' => "Does your answer miss parenthesis around numerator or denominator?" );
		return $hr_ans;
	}
	
	if ($hr_ans->{score} == 0 ) { 
		# student answer is not equivalent to the correct one
		# no need to go into the details 
		return $hr_ans; 
	}	
	
	if ($options{numerator_factored}==1){
		# both numerator and denominator must be in factored form
		if ($options{strict_match}==1){
			$numerator_hash = main::FactoredFormula($ans_numerator)->cmp()->evaluate($sans_numerator);
			$denominator_hash = main::FactoredFormula($ans_denominator)->cmp()->evaluate($sans_denominator);
		} else {
			$numerator_hash = main::FactoredFormulaUpToConstant($ans_numerator)->cmp()->evaluate($sans_numerator);
			$denominator_hash = main::FactoredFormulaUpToConstant($ans_denominator)->cmp()->evaluate($sans_denominator);
		}
	} else {
		# here we expect only denominator to be factored, and numerator could be in any form
		if ($options{strict_match}==1){
			$numerator_hash = main::Formula($ans_numerator)->cmp()->evaluate($sans_numerator);
			$denominator_hash = main::FactoredFormula($ans_denominator)->cmp()->evaluate($sans_denominator);
		} else {
			$numerator_hash = main::FormulaUpToConstant($ans_numerator)->cmp()->evaluate($sans_numerator);
			$denominator_hash = main::FactoredFormulaUpToConstant($ans_denominator)->cmp()->evaluate($sans_denominator);
		}
	}
	my $total_result = 1;
	$total_result * $numerator_hash->{up_to_constant} if (defined $numerator_hash->{up_to_constant});
	$total_result * $denominator_hash->{up_to_constant} if (defined $denominator_hash->{up_to_constant});
	
	# debug
	# warn $total_result; 
	
	if ($total_result == 1){	
		$hr_ans->{score} = 0.5*($numerator_hash->{score} + $denominator_hash->{score});
		# debug 
		# warn "Score: ". $hr_ans->{score};
		return $hr_ans;
	} else {
		# for now this means that something was really wrong, 
		# but I don't see how we could even end up here
		$hr_ans->{score} = 0;
		return $hr_ans;
	}
	
	#we must return the reference to answer hash
}

sub cmp {
	my $self = shift; 
	my %options = @_;
	my $ans = new AnswerEvaluator(
		'correct_ans' => $self->{Formula}, 
		'type' => 'Factored Rational Formula',
		); 
	$ans->install_evaluator('erase');
	$ans->install_evaluator(\&theEvaluator, %options);
	return $ans; 
}
