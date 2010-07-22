###########################
#  Site administration
#
#  The only thing you may need to modify is the value
#  of $helpurl near the end of this file.
#
###########################
#  Usage
#
#  DOCUMENT();
#  loadMacros("PGstandard.pl","AnswerFormatHelp.pl",);
#  TEXT(beginproblem());
#  BEGIN_TEXT
#  \{ AnswerFormatHelp("formulas") \} $PAR
#  \{ AnswerFormatHelp("equations","help entering equations") \} $PAR
#  \{ AnswerFormatHelp("formulas","help (formulas)","http://webwork.someschool.edu/dir/subdir/") \}
#  END_TEXT
#  ENDDOCUMENT();
#
#  First example: use defaults.
#
#  Second example: use customized text displayed to the student
#  as the html link.
#
#  Third example: additionally points to a particular URL where 
#  html help files are located. The URL must end with a forward slash.
#
#  The third method is not recommended, as a universal, site-wide,
#  or course-wide solution obtained by modifying the value of
#  $helpdir in AnswerFormatHelp.pl is preferable to setting the
#  URL in every individual PG file manually.
#
###########################


sub _AnswerFormatHelp_init {}; # don't reload this file

sub AnswerFormatHelp {

my $helptype = shift;
my $customstring = shift;
my $customurl = shift;

my $helpfile = "";
my $helpstring = "";


##########################################

if ($helptype =~ m/angle/i) {
  $helpfile = "Entering-Angles.html";
  if (!$customstring) { $helpstring = "help (angles)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/decimal/i) {
  $helpfile = "Entering-Decimals.html";
  if (!$customstring) { $helpstring = "help (decimals)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/exponent/i) {
  $helpfile = "Entering-Exponents.html";
  if (!$customstring) { $helpstring = "help (exponents)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/equation/i) {
  $helpfile = "Entering-Equations.html";
  if (!$customstring) { $helpstring = "help (equations)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/formula/i) {
  $helpfile = "Entering-Formulas.html";
  if (!$customstring) { $helpstring = "help (formulas)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/fraction/i) {
  $helpfile = "Entering-Fractions.html";
  if (!$customstring) { $helpstring = "help (fractions)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/inequalit/i) {
  $helpfile = "Entering-Inequalities.html";
  if (!$customstring) { $helpstring = "help (inequalities)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/interval/i) {
  $helpfile = "IntervalNotation.html"; # "Entering-Intervals.html";
  if (!$customstring) { $helpstring = "help (intervals)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/log/i) {
  $helpfile = "Entering-Logarithms.html";
  if (!$customstring) { $helpstring = "help (logarithms)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/limit/i) {
  $helpfile = "Entering-Limits.html";
  if (!$customstring) { $helpstring = "help (limits)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/number/i) {
  $helpfile = "Entering-Numbers.html";
  if (!$customstring) { $helpstring = "help (numbers)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/point/i) {
  $helpfile = "Entering-Points.html";
  if (!$customstring) { $helpstring = "help (points)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/syntax/i) {
  $helpfile = "Syntax.html"; # "Entering-Syntax.html";
  if (!$customstring) { $helpstring = "help (syntax)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/unit/i) {
  $helpfile = "Units.html"; # "Entering-Units.html";
  if (!$customstring) { $helpstring = "help (units)"; } else { $helpstring = $customstring; }

} elsif ($helptype =~ m/vector/i) {
  $helpfile = "Entering-Vectors.html";
  if (!$customstring) { $helpstring = "help (vectors)"; } else { $helpstring = $customstring; }

} else { # most general, catch-all?
  $helpfile = "Entering-Syntax.html";
  if (!$customstring) { $helpstring = "help (syntax)"; } else { $helpstring = $customstring; }
}


#####################################
my $helpurl = "";
  
#  Globally recognized directory for default help files
$helpurl = "https://courses.webwork.maa.org/webwork2_files/helpFiles/" . $helpfile;

#  Example of a fixed local directory for help files 
#  $helpurl = "https://hosted2.webwork.rochester.edu/webwork2_course_files/fortlewis_math121/" . $helpfile;

#  Example where all the help files are put in the "course_name/html" directory of a particular course.
#  This is useful since $htmlDirectory is an automatically set environment variable determined by each course.
#  $helpurl = alias("${htmlDirectory}$helpfile");

#  (Not recommended) Allow for a custom directory for help files specified in each individual PG problem
unless (!$customurl) { $helpurl = $customurl . $helpfile; }

#  Create the html link
return htmlLink( "${helpurl}", "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\');  
return false;"');



} # end AnswerFormatHelp

1;
