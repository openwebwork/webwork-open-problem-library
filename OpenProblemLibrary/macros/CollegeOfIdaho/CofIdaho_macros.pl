=pod

=head1 NAME

    extra macros for Intermediate Algebra problems at The College of Idaho

=head1 Synposis
    macros by R Cruz -- The College of Idaho
=cut

=head3 Format the instuctor answer

=pod

1) SimplifyExponents: Formats an expression without negative exponents
   To use: SimplifyExponents(num, den,~~@var,@exp);
           where num = numerator's constant
                 den = denominator's constant
                 ~~@var = pointer to an array with the list of variables
                 @exp = array with the exponents for the variables

2) num_and_unit_checker: Checks for units like "apples" or "oranges"
   To use: ANS (num_and_units_checker($correct_answer, "units");

3) strict_percent_cmp: Checks percentages have been rounded as required. 
    To use: ANS(strict_percent_cmp($answer,"%",roundto));  
           where $answer is in percent form: xx.x
                roundto = "tenths" or "hundredths"

4) Picky_equation_cmp: Checks both sides of an equation model the word problem. 
   To use:  Picky_equation_cmp("2x+1=5");
   Note:  This one allows only the variables that have been used in the CofIdaho
          problems.  It should be changed so that it is more flexible, or better,
          convert it to a MathObject.

5) SlopeIntercept_equation_cmp: Checks both sides of an equation for the 
   slope-intercept form of a line.
   To use: ANS(SlopeIntercept_equation_cmp($answer));
           where $answer = "y = $m x + $b";  (Use only y and x for variables.)

6) functionNotation_cmp: Checks for "f(x)= ***" notation
   To use: 
     ANS(functionNotation_cmp("f(x)=2x",["x","f"]));

7) Checks factors of polynomials.
   To use: The answer must be submitted in this form: 
              ANS(FactorEvaluator($answer,[variable array]));
   If the polynomial is prime: 
              ANS(FactorEvaluator("Does not factor",polynomial,[variable array]));

  Note: Answers must be in the form: monomial(poly)...(poly) with
    or without parentheses about the monomial.  The polynomial factors must
    not contain any other grouping symbols and, in any case, only parenthesis
    may be used.  This needs to be in the instructions for any set that uses 
    this macro (in the screenHeader.pg file).

  Note: "StrictFactoringEvaluator" requires leading negatives to be factored out.
    This not may not work with all situations.  BE SURE TO CHANGE THIS FILE IF THE
    FactoringEvaluator IS CHANGED!!

8) RationalExpEvaluator: Checks for simplified rational expressions. 
   To use: ANS(RationalExpEvaluation($answer,[variable array]));
      or something like:  ANS(RationalExpEvaluator($answer,["x","y"])); 

   Note: Answers must be of the form: (poly)/(poly) 

9) ReduceFraction: Returns a string that represents a reduced fraction.
   To use: $a = SimplifyFraction(numerator expression,denominator espression);
=cut



###################################################################
# 1) Formats an expression without negative exponents
#    Thanks to John Jones at ASU for this macro.

sub SimplifyExponents {
loadMacros("contextLimitedPowers.pl");
   my $num = shift;
   my $den = shift;
   my $varref = shift;
   my @expos = @_;
   my @vars = @$varref;

   Context()->operators->set(@LimitedPowers::OnlyPositiveIntegers);

   my $answer_n = Formula("$num");
   my $answer_d = Formula("$den");

   for $j (0..(scalar(@vars)-1)) {
      $answer_n *= Formula("$vars[$j]^$expos[$j] ") if ($expos[$j] > 0);
      $answer_d *= Formula("$vars[$j]^(-1*$expos[$j]) ") if ($expos[$j] < 0);
   }

   $answer = $answer_n/$answer_d;
   
   return($answer->reduce());
}


sub Simplified {
   my ($correct, $student, $ah)=@_;
   return unless $ah->{score} == 1;  #This does not work???
   my $VariablesPlus1 = 2;  #Put in the number of variables plus 1
   my $check = $ah->{student_ans};
   if(!( $ah->{isPreview}) && $correct == $student 
        && $check =~ /(([abxy].*){$VariablesPlus1,})|([\Q^].*[\Q^])/) 
        {
         $ah->{ans_message} = "Simplify your answer";
        }
                  
   return ($correct == $student &&    
   ($ah->{student_ans} !~ /(([abxy].*){$VariablesPlus1,})|([\Q^].*[\Q^])/));
   }


###################################################################
# 2) Checks for units 

sub num_and_unit_checker{
        my $correct_ans = shift;  #the answer
	my $correct_units = shift;    #the unit type
	my $old_evaluator = num_cmp($correct_ans);
	
	my $new_evaluator = sub
        {
	   my $student_ans = shift;
           my $formatted_ans = $student_ans;
                 $formatted_ans =~ s{$correct_units}{};
   	          my $ans_hash = $old_evaluator->evaluate($formatted_ans);
           if ( $student_ans !~ /$correct_units/) {
                  $ans_hash->{score} = 0;
$ans_hash->setKeys( 'ans_message' =>"Enter your answer with the correct units: $correct_units");
               }
           $ans_hash->{original_student_ans}="$student_ans";
           $ans_hash->{preview_latex_string}="$student_ans";
                  $ans_hash->{student_ans} = "$student_ans";
                  $ans_hash->{correct_ans} = "$correct_ans"." $correct_units";   
	      
	          return $ans_hash;
	};

	return $new_evaluator;
}


###################################################################
# 3) Checks for rounded percents

sub strict_percent_cmp{
        my $correct_ans = shift;      #the answer
	my $correct_units = shift;    #the unit type which should be "%"
        my $error = shift;            #what to round to
        my $errorAmount = .1;
        if ($error eq "hundredth") {$errorAmount=.01;}    
	my $old_evaluator = num_cmp($correct_ans,tol=>0);
	
	my $new_evaluator = sub
        {
	   my $student_ans = shift;
           my $formatted_ans = $student_ans;
                 $formatted_ans =~ s{$correct_units}{};
   	          my $ans_hash = $old_evaluator->evaluate($formatted_ans);
           if ( $student_ans !~ /$correct_units/) {
                  $ans_hash->{score} = 0;
$ans_hash->setKeys( 'ans_message' =>"Enter your answer with the correct units: $correct_units");
               }
           else {
             if ($ans_hash->{score}==0 && 
                 abs($formatted_ans-$correct_ans)<$errorAmount) {
$ans_hash->setKeys( 'ans_message' =>"Round your answer to the nearest $error.");
                 }
                }        
           $ans_hash->{original_student_ans}="$student_ans";
           $ans_hash->{preview_latex_string}="$student_ans";
                  $ans_hash->{student_ans} = "$student_ans";
                  $ans_hash->{correct_ans} = "$correct_ans"." $correct_units";   
	      
	          return $ans_hash;
	};

	return $new_evaluator;
}


###################################################################
# 4) Checks both sides of an equation model the word problem.

sub Picky_equation_cmp {

loadMacros( "unionUtils.pl",
  "answerUtils.pl",
   "listAnswer.pl",
"extraAnswerEvaluators.pl"
);

   my $ans = shift;
   
my $new_evaluator = sub { 
   my $student = shift;

   $ans =~ tr/[=]/,/;
   $student =~ tr/[=]/,/;
   
   my $old_evaluator = fun_list_cmp($ans,vars=>['a','b','c','d','h','l','n','v','w','x','y','s','t','A','L','R','C','P']);
   my $ans_hash_old = $old_evaluator->evaluate($student);
 
      $ans =~ tr/,/=/;
      $student =~ tr/,/=/;
           $ans_hash_old->{correct_ans}="$ans";
           $ans_hash_old->{original_student_ans}="$student";
           $ans_hash_old->{student_ans}="$student";
           $ans_hash_old->{preview_latex_string}="$student";
   if ($ans_hash_old->{score}!=1) {
          $ans_hash_old->{score}=0;
#         $ans_hash_old->setKeys( 'ans_message' =>"Your equation must model the problem.");
          $ans_hash_old->setKeys( 'ans_message'=>"At least one side is incorrect.");
          }
   if ($student !~ /[=]/) {
      if ($ans =~/[RCP]/) {
        @side = split(/[=]/,$ans);
            $ans_hash_old->setKeys( 'ans_message'=>"Enter your answer in the form: $side[0] = expression.");}
      else  { $ans_hash_old->setKeys( 'ans_message' =>"You must enter an equation.");}
    };

return $ans_hash_old;	  
};
return $new_evaluator;
}

###################################################################
# 5) Checks both sides of an equation for the slope-intercept form of a line.

sub SlopeIntercept_equation_cmp {

loadMacros( "unionUtils.pl",
  "answerUtils.pl",
  "contextLimitedPolynomial.pl"
);

   my $ans = shift;
   my $formatAns = $ans;
   $formatAns =~ tr/ //;
   my @correctSides = split(/[=]/, $formatAns);

my $new_evaluator = sub { 
   my $left_evaluator = fun_cmp($correctSides[0],vars=>['x','y']);
   my $right_evaluator = fun_cmp($correctSides[1],vars=>['x','y']); 

   my $student = shift;
   my $formatStudent= $student;
   $formatStudent =~ tr/ //;
   if ($student !~ /[=]/) { 
      my $ans_hash = $right_evaluator->evaluate($formatStudent);
      $ans_hash->{correct_ans}="$ans";
      $ans_hash->{original_student_ans}="$student";
      $ans_hash->{student_ans}="$student";
      $ans_hash->{preview_latex_string}="$student";   
      $ans_hash->setKeys( 'ans_message' =>"You must enter an equation.");
      $ans_hash->{score}=0;
      return $ans_hash;
   }
   else {
      my @studentSides = split(/[=]/, $formatStudent);

      my $left_ans_hash = $left_evaluator->evaluate($studentSides[0]);
      my $right_ans_hash = $right_evaluator->evaluate($studentSides[1]);

      $left_ans_hash->{correct_ans}="$ans";
      $left_ans_hash->{original_student_ans}="$student";
      $left_ans_hash->{student_ans}="$student";
      $left_ans_hash->{preview_latex_string}="$student";
      
      if ($right_ans_hash->{score}==0) {$left_ans_hash->{score}=0;}
	
      my $perlNumber = "[0-9]+[\.\/]?[0-9]*|\.[0-9]+";
      my $BadForm = ($studentSides[0]=~/\w.*\w/
                     || $studentSides[1] =~ /[a-zA-Z].*[a-zA-Z]/
                     || $studentSides[1] =~ /($perlNumber)[+-]+($perlNumber[a-zA-Z][+-])?($perlNumber)/);
      if ($BadForm) {
             $left_ans_hash->setKeys( 
      'ans_message' =>"Enter your answer in the form: $BR y = mx+b, y = b or x = c");
             $left_ans_hash->{score}=0;  
             }  
	          
       return $left_ans_hash;
    }	  
};
return $new_evaluator;
}


###################################################################
# 6) Checks for function notation in an equality.

sub functionNotation_cmp {

loadMacros( "unionUtils.pl",
  "answerUtils.pl"
);

   my $ans = shift;
   my @variables = @_;

   my $formatAns = $ans;
   $formatAns =~ tr/ //;
   my @correctSides = split(/[=]/, $formatAns);

my $new_evaluator = sub { 
#   my $notation_evaluator = fun_cmp($correctSides[0],vars=>@variables);
   my $notation_evaluator = ordered_cs_str_cmp($correctSides[0]);
   my $notation2_evaluator = unordered_str_cmp($correctSides[0]);
   my $formula_evaluator = fun_cmp($correctSides[1],vars=>@variables,tol=>.001); 

   my $student = shift;
   my $formatStudent= $student;   
   $formatStudent =~ tr/ //;
  
   if ($student !~ /[=]/ || $student !~ /(\w\s*\(\s*\w\s*\))/) { 
      my $ans_hash = $formula_evaluator->evaluate($formatStudent);
      $ans_hash->{correct_ans}="$ans";
      $ans_hash->{original_student_ans}="$student";
      $ans_hash->{student_ans}="$student";
      $ans_hash->{preview_latex_string}="$student";   
      $ans_hash->setKeys( 'ans_message' =>"Your answer must be in function notation.");
      return $ans_hash;
   }
   else {
      my @studentSides = split(/[=]/, $formatStudent);

      my $notation_ans_hash = $notation_evaluator->evaluate($studentSides[0]);
      my $notation2_ans_hash = $notation2_evaluator->evaluate($studentSides[0]);
      my $formula_ans_hash = $formula_evaluator->evaluate($studentSides[1]);

      $formula_ans_hash->{correct_ans}="$ans";
      $formula_ans_hash->{original_student_ans}="$student";
      $formula_ans_hash->{student_ans}="$student";
      $formula_ans_hash->{preview_latex_string}="$student";
      
      if ($notation_ans_hash->{score}!=1) {
          $formula_ans_hash->{ans_message} = $notation_ans_hash->{ans_message};
          if ($notation2_ans_hash->{score}==1) 
              {$formula_ans_hash->setKeys( 'ans_message' =>"Your answer must be in correct function notation.");}
          $formula_ans_hash->{score} = 0; 
         }            
	
       return $formula_ans_hash;
    }	  
};
return $new_evaluator;
}

###################################################################
# 7) Checks factors of polynomials. 
# Note: Student's answers must be of the form: monomial(poly)...(poly) with
#    or without parentheses about the monomial.  The polynomial factors must
#    not contain any other grouping symbols and, in any case, only parenthesis
#    may be used.  This needs to be in the instructions for any set that uses 
#    this macro (in the screenHeader.pg file).
# Note: "StrictFactoringEvaluator" requires leading negatives to be factored out.
#    This not may not work with all situations.  BE SURE TO CHANGE THIS FILE IF THE
#    FactoringEvaluator IS CHANGED!!
#---------For diagnosing problems--------------------------------------
#                $ans_hash->setKeys( 'ans_message' =>"FYI: Not checking correctly. 
#                    AnswerHashScore: $ans_hash->{score} : 
#                   Student: $#student_factors, $student_ans,
#                   Formatted: $format_student_ans, 
#                   Student Factors: $student_factors[0], $student_factors[1],   
#                   : Correct: $#factors, $factors[0], $factors[1], 
#                   Number matched: $CorrectFactors");
#----------------------------------------------------------------------	


sub FactoringEvaluator {

       Context()->strings->add("Does not factor"=>());
       
       my $ans = shift;
       my $ans_text = $ans;   #For string answers like "Does not factor"
       if ($ans=~/factor/)
          {
          $ans = shift;
          } 
       my @vars = @_;

       my $format_ans = $ans;
       $format_ans =~ s/\*/ /g;                              #Remove any astrix
       $format_ans =~ s/[\(]/,\(/g;                          #Put in the delimiter ,
       if ($format_ans=~/^,/) {$format_ans=~ s/,//;}         #Remove any leading comma
       my @factors = split(/[,]/, $format_ans);              #Split off the terms
       for $k (0..$#factors) {$factors[$k] = Formula($factors[$k])->reduce;}
       $ans = Formula($ans)->reduce;

       my $old_evaluator = fun_cmp($ans,var=>@vars);
    
       my $new_evaluator = sub {
          local($factor_eval,$negfactor_eval,$factor_hash,$negfactor_hash);

          my $student_ans = shift;

#---------For string answers----------------------------------------------  
          if ($student_ans =~ /factor/)
             {  
              my $old_eval_string = str_cmp($ans_text);
              my $ans_hash = $old_eval_string->evaluate($student_ans);
              $ans_hash->{correct_ans} = $ans_text;    #For better display (no caps)
              $ans_hash->{student_ans} = $student_ans;
              $ans_hash->{original_student_ans} = $student_ans;
              return $ans_hash;
              }
#---------------------------------------------------------------------------

          my $ans_hash = $old_evaluator->evaluate($student_ans);

#----------The only parentheses are allowed for grouping symbols------------
#----------and only the minimum set needed to enter the answer correctly.---
          if ($student_ans =~ /[\{\}\[\]]/)
             {  
              $ans_hash->{student_ans} = $student_ans;
              $ans_hash->{original_student_ans} = $student_ans;
              $ans_hash->{score}=0;
 	      $ans_hash->setKeys( 'ans_message' =>"You may only use parentheses in your answer.");
              return $ans_hash;
              }
         if ($student_ans =~ /[\(][^\)]*[\(]/)
             {  
              $ans_hash->{student_ans} = $student_ans;
              $ans_hash->{original_student_ans} = $student_ans;
              $ans_hash->{score}=0;
 	      $ans_hash->setKeys( 'ans_message' =>"Your answer has extraneous grouping symbols.");
              return $ans_hash;
              }

#-----------Check the factors---------------------------------------------

          if ($ans_hash->{score}==1) {                                     
	     my $format_student_ans = $student_ans;
             $format_student_ans =~ s/[\*]/ /g;                             #Remove any astrix
             $format_student_ans =~ s/[\(]/,\(/g;                           #Put in the delimiter ,
             if ($format_student_ans=~/^,/) {$format_student_ans=~ s/,//;}  #Remove leading commas             
             my @student_factors = split(/[,]/, $format_student_ans);       #Split off the terms
             for $k (0..$#student_factors) {$student_factors[$k] = Formula($student_factors[$k]);}

             #########Could this be done with a list?--would have to change the list's error msg.

             my $CorrectFactors = 0;   
          
             foreach $i (0..$#factors)  
                { 
                $factor_eval = fun_cmp($factors[$i],var=>@vars);
                $negfactor_eval = fun_cmp(-1*($factors[$i]),var=>@vars);
                foreach $j (0..$#student_factors) 
                   {
                   $factor_hash = $factor_eval->evaluate($student_factors[$j]);
                   $negfactor_hash = $negfactor_eval->evaluate($student_factors[$j]);
                   if ($factor_hash->{score}==1 || $negfactor_hash->{score}==1) 
                      {
                      $CorrectFactors=$CorrectFactors+1;

#---------This segment is for binomial factors raised to powers---------------- 
#         Example: (3x+1)^2 is correct, and (9x^2+6x+1) should not be accepted
#        SHOULD MAKE THIS MORE GENERAL: TAKE OTHER EXPONENTS BESIDES INTEGERS, 
#        THE PATTERN SHOULD BE BETTER DEFINED.                            
#------------------------------------------------------------------------------
                      $factor_string = $factors[$i]->string;
                      $st_factor_string = $student_factors[$j]->string;
                      if ($factor_string =~ /\(.*[+-]{1}.*\)\^\d+$/ && $st_factor_string !~ /\(.*[+-]{1}.*\)\^\d+$/) 
                         {
                          $ans_hash->{score}=0;
 			  $ans_hash->setKeys( 'ans_message' =>"Factor the expression completely.");
 		          }	
#-------------------------------------------------------------------------------
                      }
                   }
                 }  

             if ($CorrectFactors!=$#factors+1) 
                {
	        $ans_hash->{score}=0;
                $ans_hash->setKeys( 'ans_message' =>"Check that your answer is factored 
                                                     completely and is entered in the 
                                                     required format.");
                }
	   }

          if ($ans_text=~/factor/) {$ans_hash->{correct_ans} = $ans_text;}  #In case the answer is a string
 
         return $ans_hash;
       };   #END of SUB

       Context()->strings->remove("Does not factor"=>());
          return $new_evaluator;
}


sub StrictFactoringEvaluator {

       my $ans = shift;
       my @vars = @_;

       my $format_ans = $ans;
       $format_ans =~ s/[\*]//g;                             #Remove any astrix
       $format_ans =~ s/[\(]/,\(/g;                          #Put in the delimiter ,
       if ($format_ans=~/^,/) {$format_ans=~ s/,//;}         #Remove any leading commas
       my @factors = split(/[,]/, $format_ans);              #Split off the terms
       for $k (0..$#factors) {$factors[$k] = Formula($factors[$k]);}
       $ans = Formula($ans)->reduce;

       my $old_evaluator = fun_cmp($ans,var=>@vars);
    
       my $new_evaluator = sub {
          local($factor_eval,$factor_hash);
    
          my $student_ans = shift;

#----This could be changed so that it would check prime polyomials here instead
#----of in the problem template.   
          if ($student_ans =~ /factor/) 
             {  
              my $string_ans = $ans->string;
              my $old_eval_string = std_cs_str_cmp($string_ans);
              my $ans_hash = $old_eval_string->evaluate($student_ans);
              return $ans_hash;
              }
#------------------------------------------------------   
       
          my $ans_hash = $old_evaluator->evaluate($student_ans);
 
          if ($ans_hash->{score} == 1) {                                    #Check factors
	     my $format_student_ans = $student_ans;
             $format_student_ans =~ s/[\*]//g;                              #Remove any astrix
             $format_student_ans =~ s/[\(]/,\(/g;                           #Put in the delimiter ,
             if ($format_student_ans=~/^,/) {$format_student_ans=~ s/,//;}  #Remove any leading commas             
             my @student_factors = split(/[,]/, $format_student_ans);       #Split off the terms
             for $k (0..$#student_factors) {$student_factors[$k] = Formula($student_factors[$k]);}

             #########Could this be done with a list?--would have to change the list's error msg.

             my $CorrectFactors = 0;   
          
             foreach $i (0..$#factors)  
                { 
                $factor_eval = fun_cmp($factors[$i],var=>@vars);
                foreach $j (0..$#student_factors) 
                   {
                   $factor_hash = $factor_eval->evaluate($student_factors[$j]);
                   if ($factor_hash->{score}==1) 
                      {
                      $CorrectFactors=$CorrectFactors+1;
                      }
                   }
                 }  

             if ($CorrectFactors!=$#factors+1) 
                {
	        $ans_hash->{score}=0;
                $ans_hash->setKeys( 'ans_message' =>"Check that your answer is factored completely and is entered in the required format.");
                }
	   }
          return $ans_hash;
       };
          return $new_evaluator;
}

###################################################################
# 8) Checks for simplified rational expressions. 
# Note: Student's answers must be of the form: (poly)/(poly) 
# 
#---------For diagnosing problems--------------------------------------
#     $ans_hash->setKeys( 'ans_message' =>"FYI: Not checking correctly. 
#                         Student: $student_num, $student_den,$student_ans; 
#                         Answer: $num,$den,$ans");
#----------------------------------------------------------------------

sub RationalExpEvaluator {

	Context()->strings->add( "Does not simplify" => () );

	my $ans      = shift;
	my $ans_text = $ans;    #Mainly for string answers like "Does not simplify"
	if ( $ans =~ /not/ ) {
		$ans = shift;
	}
	my @vars = @_;

	#---------Split off the numerator/denominator
	my @factors = split( q[/], $ans );
	my $num = Formula( $factors[0] );
	my $den = ($#factors > 0) ? Formula( $factors[1] ) : Formula("1");

	my $old_evaluator = fun_cmp( $ans, var => @vars );

	my $new_evaluator = sub {
		my $student_ans      = shift;
		my $student_ans_text = $student_ans;

		#---------For string answers----------------------------------------------
		if ( $student_ans_text =~ /not/ ) {
			my $old_eval_string = str_cmp($ans_text);
			my $ans_hash        = $old_eval_string->evaluate($student_ans_text);
			$ans_hash->{correct_ans}          = $ans_text;
			$ans_hash->{student_ans}          = $student_ans_text;
			$ans_hash->{original_student_ans} = $student_ans_text;
			return $ans_hash;
		}
		#-------------------------------------------------------------------------

		my $ans_hash = $old_evaluator->evaluate($student_ans);

		if ( $ans_hash->{score} == 1 ) {
			#--------Check for a scalar answer in case and the student entered a decimal
			if ( $student_ans !~ /[a-zA-Z]/ && $ans !~ /[a-zA-Z]/ ) {
				$ans_hash->{correct_ans}          = $ans_text;
				$ans_hash->{student_ans}          = $student_ans_text;
				$ans_hash->{original_student_ans} = $ans_hash->{student_ans};
				return $ans_hash;
			}
			#--------------------------------------------------------------------

			#--------Split off the numerator/denominator-------------------------
			my $student_ans_mo = Formula( $student_ans_text );
			my ( $student_num, $student_den );
			my @student_factors;

			# use MO parse tree rather than regex split because of surrounding parens from mathquill
			if ( $student_ans_mo->{tree}->class eq 'BOP' && $student_ans_mo->{tree}{bop} =~ m!/! ) {
				$student_num = $student_ans_mo->{tree}{lop};
				$student_den = $student_ans_mo->{tree}{rop};
				@student_factors = ( $student_num->string, $student_den->string );
			} else {
				$student_num = $student_ans_mo;
				$student_den = Formula('1');
				@student_factors = ( $student_num->string );
			}
			#--------------------------------------------------------------------

			if ( $#factors != $#student_factors ) {
				$ans_hash->{score} = 0;
			} else {
				my $num_eval = fun_cmp( $num, var => @vars );
				my $num_hash = $num_eval->evaluate($student_num);
				$ans_hash->{score} = $num_hash->{score};
				
				if ( $#factors > 0 ) {
					my $den_eval = fun_cmp( $den, var => @vars );
					my $den_hash = $den_eval->evaluate($student_den);
					$ans_hash->{score} = $den_hash->{score};
				}
			}

			$ans_hash->{ans_message} = "Simplify your answer." if ( $ans_hash->{score} == 0 );
		}

		return $ans_hash;
	};

	Context()->strings->remove( "Does not simplify" => () );
	return $new_evaluator;
}

###################################################################
#  9) Writes a fraction in reduced form.  
#     

sub ReduceFraction {
   my $num = shift;
   my $den = shift;
   my $n = 1;
   my $d = 1;
   
  ($n,$d) = reduce($num,$den);
   my $result = "$n/$d";
   if ($d==1) {$result = "$n";}
   
   return($result);
}



###################################################################
# 10) Checks a list of equations.  
#     Designed for checking a list of asymptotes

sub equation_cmp_list {
   
loadMacros(
   "extraAnswerEvaluators.pl"
);
       
   my $ans = shift;
   my @vars = @_;

   my $format_ans = $ans;
   $format_ans =~ tr/ //;                             #Remove any whitespace
   my @ans_list = split(/[,]/, $format_ans);          #Split off the terms
   
#    
#    my $old_evaluator2 = str_cmp($ans_list[1]);	
#  Would like to change this to an equation evaluator later
#	my $old_evaluator1 = equation_cmp($ans[0],vars=>@vars);
#	my $old_evaluator2 = equation_cmp($ans[1],vars=>@vars);
	
   my $new_evaluator = sub {

      local($eq_eval,$ans_hash);

      my $student_ans = shift;
      chomp $student_ans;
      my $format_st = $student_ans;
      $format_st =~ tr/ //;                      #Remove any whitespace

      my @student_list = split(/,/,$format_st);
          
      my $Correct = -1;   
      foreach $i (0..$#ans_list)   #Count the number of matches between the lists  
         { 
         my $eq_eval = str_cmp($ans_list[$i]);
         foreach $j (0..$#student_list) 
            {
            $ans_hash = $eq_eval->evaluate($student_list[$j]);
            if ($ans_hash->{score}==1) {$Correct=$Correct+1;}
            }
         }
      my $Duplicates = -1;
      foreach $i (0..$#student_list)    #Check for duplicates in the student's list  
         { 
         my $eq_eval = str_cmp($student_list[$i]);
         foreach $j (0..$#student_list) 
            {
            $ans_hash = $eq_eval->evaluate($student_list[$j]);
            if ($ans_hash->{score}==1) {$Duplicates=$Duplicates+1;}
            }
         }
      if ($Correct!=$#ans_list || $Duplicates!=$#student_list)
         {
          $ans_hash->{score}=0;
          if ($Duplicates!=$#student_list)
             {
             $ans_hash->setKeys( 'ans_message' =>"You have listed an asymptote more than once.");
             }
          }
       else
          {
          $ans_hash->{score}=1;
          }
       $ans_hash->{correct_ans} = $ans;
       $ans_hash->{student_ans} = $student_ans;
       $ans_hash->{original_student_ans} = $ans_hash->{student_ans};
#       $ans_hash->{type} =      '',
       $ans_hash->{preview_text_string} = $student_ans;
       $ans_hash->{preview_latex_string} = $student_ans;
       return $ans_hash;  
      };
 return $new_evaluator;
}


1;
