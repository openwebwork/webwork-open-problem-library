=head1 NAME

PeriodicRerandomization.pl - forced re-randomization of the 
problem every p submissions.

=head1 SYNOPSIS

Let p be a positive integer.  This macro provides the ability
to force a re-randomization of the question every p attempts.
For example, this macro can be used to create a practice exercise 
that provides a new version of the question every 4 attempts 
and displays a solution every fourth attempt. 

=head1 DESCRIPTION

Usage:

     DOCUMENT();
     loadMacros(
     "PGstandard.pl",
     "MathObjects.pl",
     "PeriodicRerandomization.pl",
     );
     TEXT(beginproblem());

     PeriodicRerandomization("4");

     $a = random(2,9,1);
     do { $b = random(2,9,1); } until ($b != $a);

     BEGIN_TEXT
     An equation for a line in the xy-plane with slope \( $a \)
     and y-intercept \( $b \) is
     $BR
     $BR
     \( y = \) \{ ans_rule(20) \} 
     $BR
     $BR
     END_TEXT

     PeriodicStatus(
     "Generate a new version of this problem",
     "You have ${attempts_modp_remaining} attempt(s) remaining 
     before you will receive a new version of this problem."
     ); 

     if ($attempts_modp == 0) {
     BEGIN_TEXT
     $BR
     $BR
     ${BBOLD}Solution:${EBOLD}  Multiply \( x \) by \( $a \)
     and add \( $b \).
     $BR
     $BR
     END_TEXT
     }

     ANS( Compute("$a x + $b")->cmp() );

     COMMENT('MathObject version.  Periodically re-randomizes.');

     ENDDOCUMENT();


The argument of C<PeriodicRerandomization()> is a number p (the period) 
that is the number of attempts allowed before the problem is 
re-randomized.  C<PeriodicRerandomization()> must be called before
any random parameters are defined.

The two arguments of C<PeriodicStatus()> are (1) the text that will 
appear on the button for a new version of the problem when the number 
of attempts is 0 mod p, and (2) a message that will appear when the 
number of attempts is not 0 mod N.  If C<PeriodicStatus()> has no 
arguments, then it will use defaults.  

There are several globally defined variables.  C<$rerand_period> is 
the period p.  C<$attempts_modp> is the total number of attempts modulo 
the period except for when the problem is first accessed, in which case
its value is -p (the rationale behind this is that the case when the 
problem is first accessed often needs to be handled separately.)  
C<$attempts_modp_remaining> is the number of attempts 
remaining before re-randomization.  C<$problem_version_number> is the 
floor function applied to the total number of attempts divided by the 
period p.  C<$newProblemSeed> is the problem seed for the current
version of the problem, whereas C<$problemSeed> is the original
problem seed (which does not change with different versions of the 
problem).  You can access the total number of attempts using
C<$envir{numOfAttempts}>, which is a sequence 0,0,1,2,3,... (not
0,1,2,3,...).

=head1 AUTHOR

Paul Pearson, Fort Lewis College, Department of Mathematics

=cut



###########################



sub _PeriodicRerandomization_init {}; # don't reload this file

sub PeriodicRerandomization {

  #
  # define some global variables 
  #

  $rerand_period = shift;
  $attempts_modp = ($envir{numOfAttempts}+1) % $rerand_period;
  $attempts_modp_remaining = $rerand_period - $attempts_modp;

  #
  # a correction because the $envir{numOfAttempts} progression is 0,0,1,2,3... instead of 0,1,2,3,...
  #
  if ( $envir{numOfAttempts}==0 && !defined(${$inputs_ref}{'hasBeenAttempted'}) ) { 
  
    TEXT(MODES(
      HTML      => qq!<INPUT type="hidden" NAME="hasBeenAttempted" VALUE="1">!,
      HTML_dpng => qq!<INPUT type="hidden" NAME="hasBeenAttempted" VALUE="1">!,
      TeX => "")
    );

    $attempts_modp += -(1+$rerand_period);
    $attempts_modp_remaining += 1;

  } else {

    TEXT(MODES(
      HTML      => qq!<INPUT type="hidden" NAME="hasBeenAttempted" VALUE="1">!,
      HTML_dpng => qq!<INPUT type="hidden" NAME="hasBeenAttempted" VALUE="1">!,
      TeX => "")
    );

  }

  $problem_version_number = floor($envir{'numOfAttempts'} / $rerand_period);
  
  if ($problemSeed < 2000) {
     $newProblemSeed = $problemSeed + $problem_version_number;
  } else {
     $newProblemSeed = $problemSeed - $problem_version_number;
  } 

  $main::PG_random_generator -> srand( $newProblemSeed );


}





sub PeriodicStatus {

  my $button_text = shift;
  my $status_text = shift;

  if ( !defined($button_text) ) { $button_text = "Generate a new version of this problem"; }

  if ( !defined($status_text) ) { 
     $status_text = 
     "You have ${attempts_modp_remaining} attempt(s) remaining before you will receive a new version of this problem."; 
  } 


  if ($attempts_modp == 0 && defined(${$inputs_ref}{'hasBeenAttempted'}) ) {

  TEXT(MODES(
    HTML     =>"<input type=\"submit\" name=\"submitAnswers\" value=\"$button_text\" onclick=\"\" />",
    HTML_dpng=>"<input type=\"submit\" name=\"submitAnswers\" value=\"$button_text\" onclick=\"\" />",
    TeX => "")
  );

  } else {

  TEXT(EV3($status_text));

  }

}

1;