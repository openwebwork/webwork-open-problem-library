=head1 NAME

AnswerFormatHelp.pl

=head1 SYNOPSIS

Creates links for students to help documentation on formatting 
answers and allows for custom help links. 

=head1 DESCRIPTION

There are 16 predefined help links: angles, decimals, equations, 
exponents, formulas, fractions, inequalities, intervals, limits, 
logarithms, matrices, numbers, points, syntax, units, vectors.

Usage:

     DOCUMENT();
     loadMacros("PGstandard.pl","AnswerFormatHelp.pl",);
     TEXT(beginproblem());
     BEGIN_TEXT
     \{ ans_rule(20) \} 
     \{ AnswerFormatHelp("formulas") \} $PAR
     \{ ans_rule(20) \}
     \{ AnswerFormatHelp("equations","help entering equations") \} $PAR
     END_TEXT
     ENDDOCUMENT();


The first example use defaults and displays the help link right next to 
the answer blank, which is recommended.  The second example customizes 
the link text displayed to the student, but the actual help document
is unaffected.

=head1 AUTHOR

Paul Pearson, Hope College, Department of Mathematics

=cut



###########################

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

our ($syntaxHelpExists,   $angleHelpExists, $decimalHelpExists,
    $equationHelpExists, $exponentHelpExists, $formulaHelpExists, $fractionHelpExists, $inequalitiesHelpExists, 
    $intervalHelpExists, $limitsHelpExists, $logarithmsHelpExists, $numberHelpExists, $pointsHelpExists,
    $unitsHelpExists, $vectorsHelpExists,
    ) = (0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, );
    
sub _AnswerFormatHelp_init {}; # don't reload this file

sub AnswerFormatHelp {

#
#  Define some local variables
#
my $helptype = shift;
my $customstring = shift;

my $helpstring = "";

# If producing PTX output, omit any formatting help.
# (PTX output is used to produce non-interactive presentations of a problem,
# so there is no need to give syntax formatting help.)
if ($main::displayMode eq "PTX") {
    return;
}



####################################
#  Angles

if ($helptype =~ m/angle/i) {

if ($angleHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpAngles() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Angles</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Angles</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>Angles in radians without units are the default:</font><blockquote>For an angle of 60 degrees, enter it in radians as &nbsp; <code>pi/3</code> &nbsp; or &nbsp; <code>1.04719...</code>, but <b>not 60</b><br />By default, trig functions are evaluated in radians, so <code>cos(pi/3) = 1/2</code>, but <code>cos(60) = -0.9524</code> since it is radians.  You must convert degrees to radians before applying a trig function to an angle.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Occasionally, units are required on angles:</font><blockquote>If asked for units on an angle, enter, for example, <br /><code>pi/6 rad</code> &nbsp; (including rad)<br /><code>30 deg</code> &nbsp; (including deg)</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of constants available:</font><blockquote><code>pi</code>, &nbsp; <code>e = e^1</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes decimals are not allowed:</font><blockquote>Sometimes &nbsp; <code>pi/6</code> &nbsp; is allowed, but &nbsp; <code>0.524</code> &nbsp; is not</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes trig functions are not allowed:</font><blockquote>Sometimes &nbsp; <code>0.866025403784</code> &nbsp; is allowed, but &nbsp; <code>cos(pi/6)</code> &nbsp; is not</blockquote></li>")
OpenWindow.document.write("<li><a href='http://webwork.maa.org/wiki/Available_Functions' target='_new'>Link to a list of all available functions</a><br /><br /></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$angleHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (angles)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpAngles()';");
} else { return $helpstring; }








####################################
#  Decimals

} elsif ($helptype =~ m/decimal/i) {

if ($decimalHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpDecimals() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Decimals</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Decimals</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>In general, give at least 5 decimal places.</font><blockquote>Typically, if your answer is correct to 5 decimal places it will be marked correct, although the number of decimal places required may vary from problem to problem.  When in doubt, give more decimal places.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If there is more than one correct answer, enter your answers as a comma separated list.</font><blockquote>For example, if your answers are <nobr><code>-3/2, 4/3, 2pi, e^3, 5</code></nobr> enter them as <nobr><code>-1.5, 1.3333333, 6.2831853, 20.0855369, 5</code></nobr></blockquote>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, fractions and certain operations are not allowed.</font><blockquote>Usually, the operations that are not allowed include addition <code>+</code>, subtraction <code>-</code>, multiplication <code>*</code>, division <code>/</code>, and exponentiation <code>^</code> (or <code>**</code>).  When these operations are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain functions are not allowed.</font> <blockquote>Usually, the functions that are not allowed include square root <code>sqrt( )</code>, absolute value <code>| |</code> (or <code>abs( )</code>), as well as other named functions such as <code>sin( )</code>, <code>ln( )</code>, etc.  When these functions are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$decimalHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (decimals)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpDecimals()';");
} else { return $helpstring; }





#########################################
#  Equations

} elsif ($helptype =~ m/equation/i) {

if ($equationHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpEquations() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Equations</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Equations</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>Equations must have an equals sign and use the correct variable names:</font><blockquote><code>y = 5x+2</code> &nbsp; will be incorrect if the answer is &nbsp; <code>w = 5y+2</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of valid equations that are equivalent:</font><blockquote><code>32 = 5*x + 2</code> &nbsp; is the same as &nbsp; <code>30 = 5x</code> &nbsp; or &nbsp; <code>x = 6</code></code><br /><code>y = (x-1)^2 + 3</code> &nbsp; is the same as &nbsp; <code>y - 3 = (x-1)^2</code><br /><code>x^2 + xy + y^2 = 13x</code> &nbsp; is the same as &nbsp; <code>y*(y+x) = 13x - x^2</code><br /></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If there is no equation that solves the question:</font><blockquote>Enter &nbsp; <code>NONE</code> &nbsp; or &nbsp; <code>DNE</code> &nbsp; (this may vary from problem to problem)</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of constants used in equations:</font><blockquote><code>pi</code>, <code>e = e^1</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Functions may be used in equations, but may not be applied across the equals sign:</font><blockquote><code>sqrt(x) = sqrt(5)</code> &nbsp; is valid, but &nbsp; <code>sqrt(x=5)</code> &nbsp; is not</blockquote></li>")
OpenWindow.document.write("<li><a href='http://webwork.maa.org/wiki/Available_Functions' target='_new'>Link to a list of all available functions</a><br /><br /></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$equationHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (equations)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpEquations()';");
} else { return $helpstring; }





###############################################
#  Exponents

} elsif ($helptype =~ m/exponent/i) {

if ($exponentHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpExponents() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Exponents</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Exponents</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>Both <code>^</code> and <code>**</code> are used for exponentiation.</font><blockquote>For example, <code>x^2</code> and <code>x**2</code> are the same, as are <code>e^(-x/2)</code> and <code>1/(e**(x/2))</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Square roots have a named function, but other roots do not and should be entered using fractional exponents.</font><blockquote>For example, the square root of 2 can be entered as <code>sqrt(2)</code>, <code>2^(1/2)</code>, or <code>2**(1/2)</code>, but the cube root of 2 must be entered as <code>2^(1/3)</code> or <code>2**(1/3)</code>.  The parentheses in <code>2^(1/3)</code> are required, since <code>2^1/3</code> will be interpreted as <code>(2^1)/3 = 2/3</code>.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, fractional exponents and certain operations are not allowed.</font><blockquote>Usually, the operations that are not allowed include addition <code>+</code>, subtraction <code>-</code>, multiplication <code>*</code>, division <code>/</code>.  When these operations are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain functions are not allowed.</font>  <blockquote>Usually, the functions that are not allowed include square root <code>sqrt( )</code>, absolute value <code>| |</code> (or <code>abs( )</code>), as well as other named functions such as <code>sin( )</code>, <code>ln( )</code>, etc.  When these functions are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$exponentHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (exponents)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpExponents()';");
} else { return $helpstring; }






#######################################
#  Formulas

} elsif ($helptype =~ m/formula/i) {

  my $local1UseBaseTenLogHelp = Context()->flags->get("useBaseTenLog");
  my $local2UseBaseTenLogHelp = main::Context()->flags->get("useBaseTenLog");
  my $globalUseBaseTenLogHelp = $useBaseTenLog;

  if ($local1UseBaseTenLogHelp == 1 || $local2UseBaseTenLogHelp == 1 || $globalUseBaseTenLogHelp == 1) {
      $useBaseTenLogHelpString = "<li><font color='#222255'>Entering logarithms:</font> <blockquote>In this question, use <code>ln(x)</code> for natural log, and <code>log(x), logten(x)</code> or <code>log10(x)</code> for the base 10 logarithm.  Enter log base b as <code>ln(x)/ln(b)</code></blockquote><br /></li>";
  } else {
      $useBaseTenLogHelpString = "<li><font color='#222255'>Entering logarithms:</font> <blockquote><font color='#ff0000'><b>Caution:</b></font> In this question, use <code>ln(x)</code> or <code>log(x)</code> for natural log, and <code>logten(x)</code> or <code>log10(x)</code> for the base 10 logarithm.  Enter log base b as <code>ln(x)/ln(b)</code></blockquote><br /></li>";
  }

if ($formulaHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpFormulas() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Formulas</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Formulas</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><a href='http://webwork.maa.org/wiki/Available_Functions' target='_new'>Link to a list of all available functions</a><br /><br /></li>")
OpenWindow.document.write("<li><font color='#222255'>Formulas must use the correct variable(s):</font><blockquote>For example, a function of time &nbsp; <code>t</code> &nbsp; could be &nbsp; <code>-16t^2 + 12</code>, while &nbsp; <code>-16x^2 + 12</code> &nbsp; would be incorrect. </blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of valid formulas:</font><blockquote><code>5*sin((pi*x)/2)</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>5 sin(pi x/2)</code><br /><code>e^(-x)</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>e**(-x)</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>1/(e^x)</code><br /><code>abs(5y)</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>|5y|</code><br /><code>sqrt(9 - z^2)</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>(9 - z^2)^(1/2)</code><br /><code>24</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>4!</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>4 * 3 * 2 * 1</code><br /><code>pi</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>4 arctan(1)</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>4 atan(1)</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>4 tan^(-1)(1)</code><br /></blockquote></li>")
OpenWindow.document.write("$useBaseTenLogHelpString")
OpenWindow.document.write("<li><font color='#222255'>Examples of constants used in formulas:</font><blockquote><code>pi</code>, <code>e = e^1</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of operations used in formulas:</font><blockquote>Addition <code>+</code>, subtraction <code>-</code>, multiplication <code>*</code>, division <code>/</code>, exponentiation <code>^</code> (or <code>**</code>), factorial <code>!</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of functions used in formulas:</font><blockquote><code>sqrt(x) = x^(1/2)</code>, <code>abs(x) = | x |</code><br /><code>2^x, e^x, ln(x), log10(x)</code> <br /><code>sin(x), cos(x), tan(x), csc(x), sec(x), cot(x)</code><br /><code>arcsin(x) = asin(x) = sin^(-1)(x)</code><br /> <code>arccos(x) = acos(x) = cos^(-1)(x)</code><br /><code>arctan(x) = atan(x) = tan^(-1)(x)</code><br /></blockquote>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes formulas must be simplified:</font><blockquote>For example, &nbsp; <code>6x + 5 - 2x</code> &nbsp; should be simplified to &nbsp; <code>4x + 5</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain operations are not allowed.</font><blockquote>Usually, the operations that are not allowed include addition <code>+</code>, subtraction <code>-</code>, multiplication <code>*</code>, division <code>/</code>, and exponentiation <code>^</code> (or <code>**</code>).  When these operations are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain functions are not allowed.</font>  <blockquote>Usually, the functions that are not allowed include square root <code>sqrt( )</code>, absolute value <code>| |</code> (or <code>abs( )</code>), as well as other named functions such as <code>sin( )</code>, <code>ln( )</code>, etc.  When these functions are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

 $formulaHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (formulas)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpFormulas()';");
} else { return $helpstring; }









#########################################
#  Fractions

} elsif ($helptype =~ m/fraction/i) {

if ($fractionHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpFractions() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Fractions</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Fractions</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>Examples of fractions, which are of the form a / b for non-decimal numbers a and b that have no common factors, include:</font><blockquote><code>5/2, -1/3, pi/3, 4, sqrt(2)/2</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of fractions, which are of the form a / b for non-decimal numbers a and b that have no common factors, include:</font><blockquote><code>5/2, -1/3, pi/3, 4, sqrt(2)/2</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of fractions that can be simplified include:</font><blockquote><code>15/6, (3-4)/3, 2*pi/6, (16/2)/2</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes decimals are not allowed:</font><blockquote>Allowed: &nbsp;&nbsp; <code>5/2, -1/3, pi/3, 4, sqrt(2)/2, 2^(1/2)</code><br />Not allowed: &nbsp;&nbsp; <code>2.5, -0.33333, 3.14159/3, 0.707106/2, 2^(0.5)</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes a mixed fraction is required:</font><blockquote>Enter <code>1 2/3</code> (for 1 and 2/3) with a space between the 1 and the 2 instead of <code>5/3</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, you must make an integer into a fraction:</font><blockquote>Enter <code>4/1</code> instead of <code>4</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If there is more than one correct answer, enter your answers as a comma separated list.</font><blockquote>For example, if your answers are <nobr><code>-3/2, 4/3, 2pi, e^3, 5</code></nobr> enter<nobr> <code>-3/2, 4/3, 2*pi, e^3, 5</code></nobr></blockquote>")
OpenWindow.document.write("<li><font color='#222255'>If there are no solutions:</font><blockquote>Enter &nbsp; <code>NONE</code> &nbsp; or &nbsp; <code>DNE</code> &nbsp; (this may vary from problem to problem)</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain operations are not allowed.</font><blockquote>Usually, the operations that are not allowed include addition <code>+</code>, subtraction <code>-</code>, multiplication <code>*</code>, and exponentiation <code>^</code> (or <code>**</code>).  When these operations are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain functions are not allowed.</font>  <blockquote>Usually, the functions that are not allowed include square root <code>sqrt( )</code>, absolute value <code>| |</code> (or <code>abs( )</code>), as well as other named functions such as <code>sin( )</code>, <code>ln( )</code>, etc.  When these functions are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$fractionHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (fractions)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpFractions()';");
} else { return $helpstring; }







###########################################
#  Inequalities

} elsif ($helptype =~ m/inequalit/i) {

if ($inequalitiesHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpInequalities() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Inequalities</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Inequalities</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>Types of operators:</font><blockquote><table border='0' cellspacing='2'><tr><td><code>&lt;</code></td><td>&nbsp;&nbsp;&nbsp; less than</td></tr><tr><td><code>&lt;=</code> &nbsp; or &nbsp; <code>=&lt;</code></td><td>&nbsp;&nbsp;&nbsp; less than or equal to</td></tr><tr><td><code>=</code></td><td>&nbsp;&nbsp;&nbsp; equals</td></tr><tr><td><code>!=</code></td><td>&nbsp;&nbsp;&nbsp; not equal to (uses exclamation point)</td></tr><tr><td><code>&gt;</code></td><td>&nbsp;&nbsp;&nbsp; greater than</td></tr><tr><td><code>&gt;=</code> &nbsp; or &nbsp; <code>=&gt;</code></td><td>&nbsp;&nbsp;&nbsp; greater than or equal to</td></tr></table></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Special symbols:</font><blockquote><code>infinity</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>inf</code> &nbsp;&nbsp;means positive infinity<br /><code>-infinity</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>-inf</code> &nbsp;&nbsp;means negative infinity<br /><code>R</code> &nbsp;&nbsp;means all real numbers<br /><code>R</code> &nbsp;&nbsp;is the same as&nbsp;&nbsp; <code>-inf < x < inf</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>(-inf,inf)</code><br /><code>{2,4,5}</code> &nbsp;&nbsp;using curly braces denotes a finite set<br /> <code>NONE</code> &nbsp;&nbsp;or a pair of curly braces&nbsp;&nbsp; <code>{}</code> &nbsp;&nbsp;means the empty set<br /><code>U</code> &nbsp;&nbsp;denotes the union of intervals</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Entering answers using inequality or interval notation:</font><blockquote><table border='1' cellspacing='0' cellpadding='5'><tr><td>Inequality<br />Notation</td><td><font color='#FF0000'>* </font>Interval<br />Notation</td><td>Remarks</td></tr><tr><td><code>x&LT;2</code></td><td><code>(-infinity,2)</code></td>    <td>Use rounded parentheses <nobr><code>(</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>)</code></nobr> at infinite endpoints</td></tr><tr><td><code>x&GT;2</code></td><td><code>(2,infinity)</code></td><td>&nbsp;</td></tr><tr><td><code>x&LT;=2</code></td><td><code>(-infinity,2]</code></td><td>&nbsp;</td></tr><tr><td><code>x&GT;=2</code></td><td><code>[2,infinity)</code></td><td>&nbsp;</td></tr><tr><td><code>0&LT;x&LT;=2</code></td><td><code>(0,2]</code></td><td>&nbsp;</td></tr><tr><td><nobr><code>0&LT;x and x&LT;2</code></nobr></td><td><code>(0,2)</code></td>    <td><code>and</code> &nbsp;&nbsp;is special</td></tr><tr><td><nobr><code>x&LT;0 or x&GT;2</code></nobr></td><td><code>(-inf,0)U(2,inf)</code></td>    <td><code>or</code> &nbsp;&nbsp;is special<br /><code>U</code> &nbsp;&nbsp;denotes union</td></tr><tr><td><nobr><code>x=0 or x=2</code></nobr></td><td><code>{0,2}</code></td>   <td>finite sets are allowed using curly braces&nbsp;&nbsp; <code>{a,b,c}</code></td></tr><tr><td><nobr><code>x<3 or x>3</code></nobr></td><td><code>(-inf,3)U(3,inf)</code><br /><code>x != 3</code><br /><code>R-{3}</code></td><td>set differences are allowed</td></tr></table><br /><font color='#FF0000'>* Some questions may not allow interval notation to be used</font></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Tips for entering inequalities and intervals:</font><blockquote>If an interval includes an endpoint, use square brackets: <nobr><code>[</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>]</code></nobr><br /><br />If an interval excludes an endpoint or an endpoint is infinite, use rounded parentheses: <nobr><code>(</code> &nbsp;&nbsp;or&nbsp;&nbsp; <code>)</code></nobr><br /><br />Use curly braces to enclose finite sets and commas to separate elements the set: <nobr><code>{ -3, pi, 2/5, 0.75 }</code></nobr><br /><br />All sets should be expressed in their simplest form in interval notation with no overlapping intervals.  For example,&nbsp;&nbsp; <code>[2,4]U[3,5]</code> &nbsp;&nbsp;is not equivalent to&nbsp;&nbsp; <code>[2,5]</code></br /><br />If you are asked to find the range of a function <code>y = f(x)</code>, your inequality should be in terms of the variable <code>y</code></blockquote></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$inequalitiesHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (inequalities)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpInequalities()';");
} else { return $helpstring; }










#######################################
#  Intervals

} elsif ($helptype =~ m/interval/i) {

if ($intervalHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpIntervals() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Intervals</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Intervals</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>Endpoints of intervals:</font> If an endpoint is included, then use <code>[</code> or <code>]</code>.  If not, then use <code>(</code> or <code>)</code>.  For example, the interval from -3 to 7 that includes 7 but not -3 is expressed <code>(-3,7]</code>.  <br /> <br /></li>")
OpenWindow.document.write("<li><font color='#222255'>Infinite intervals:</font> For infinite intervals, use <code>Inf</code> for <font size='+2'>&#8734;</font> (infinity) or <code>-Inf</code> for <font size='+2'>-&#8734;</font> (-Infinity).  For example, the infinite interval containing all points greater than or equal to 6 is expressed <code>[6,Inf)</code>.<br /><br /></li>")
OpenWindow.document.write("<li><font color='#222255'>Unions of intervals:</font> If the set includes more than one interval, they are joined using the union symbol U.  For example, the set consisting of all points in (-3,7] together with all points in [-8,-5) is expressed <code>[-8,-5)U(-3,7]</code>.  WeBWorK will <b>not</b> interpret <code>[2,4]U[3,5]</code> as equivalent to <code>[2,5]</code>, unless a problem tells you otherwise.  All sets should be expressed in their simplest interval notation form, with no overlapping intervals. <br /> <br /></li>")
OpenWindow.document.write("<li><font color='#222255'>Empty intervals:</font> If the answer is the empty set, you can specify that by using braces with nothing inside: <code> { }</code> <br /> <br /></li>")
OpenWindow.document.write("<li><font color='#222255'>Special symbols:</font> You can use <code>R</code> as a shorthand for all real numbers.  So, it is equivalent to entering <code>(-Inf, Inf)</code>.  <br /> <br /></li>")
OpenWindow.document.write("<li><font color='#222255'>Set notation: </font> You can use set difference notation.  So, for all real numbers except 3, you can use <code>R-{3}</code> or <code>(-Inf, 3)U(3,Inf)</code> since they are the same.  Similarly, <code>[1,10)-{3,4}</code> is the same as <code>[1,3)U(3,4)U(4,10)</code>.  <br /> <br /></li>")
OpenWindow.document.write("<li><font color='#222255'>One point intervals: </font> When an interval contains only one point, enter it as a one point set such as <code>{3}</code> or as a closed interval such as <code>[3,3]</code>.<br /> <br /></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$intervalHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (intervals)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpIntervals()';");
} else { return $helpstring; }







##############################################
#  Limits

} elsif ($helptype =~ m/limit/i) {

if ($limitsHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpLimits() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help With Limits</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help With Limits</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>Limits whose values are numbers:</font><blockquote>For example, lim<sub>x &rarr; &infin;</sub> arctan(x) = &pi;/2, so you would enter &nbsp; <code>pi/2</code> </blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Limits whose values are infinite:</font><blockquote>Enter &nbsp; <code>infinity</code>, &nbsp; <code>inf</code>, &nbsp; <code>-infinity</code>, &nbsp; <code>-inf</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Limits that don't exist:</font><blockquote>Enter &nbsp; <code>DNE</code> &nbsp; or &nbsp; <code>NONE</code> &nbsp; (this may vary from question to question)</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Limits whose value is a function:</font><blockquote>Enter the function using appropriate syntax, for example:<br /><code>sqrt(x) = x^(1/2)</code>, <code>abs(x) = | x |</code><br /><code>2^x, e^x, ln(x), log10(x)</code> <br /><code>sin(x), cos(x), tan(x), csc(x), sec(x), cot(x)</code><br /><code>arcsin(x) = asin(x) = sin^(-1)(x)</code><br /> <code>arccos(x) = acos(x) = cos^(-1)(x)</code><br /><code>arctan(x) = atan(x) = tan^(-1)(x)</code><br /></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes answers must be simplified:</font><blockquote>For example, &nbsp; <code>6x+5-2x+7</code> &nbsp; should be simplified to &nbsp; <code>4x+12</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain operations are not allowed.</font><blockquote>Usually, the operations that are not allowed include addition <code>+</code>, subtraction <code>-</code>, multiplication <code>*</code>, division <code>/</code>, and exponentiation <code>^</code> (or <code>**</code>).  When these operations are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain functions are not allowed.</font>  <blockquote>Usually, the functions that are not allowed include square root <code>sqrt( )</code>, absolute value <code>| |</code> (or <code>abs( )</code>), as well as other named functions such as <code>sin( )</code>, <code>ln( )</code>, etc.  When these functions are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$limitsHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (limits)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpLimits()';");
} else { return $helpstring; }








###############################################
#  Logarithms

} elsif ($helptype =~ m/log/i) {

  my $local1UseBaseTenLogHelp = Context()->flags->get("useBaseTenLog");
  my $local2UseBaseTenLogHelp = main::Context()->flags->get("useBaseTenLog");
  my $globalUseBaseTenLogHelp = $useBaseTenLog;

  if ($local1UseBaseTenLogHelp == 1 || $local2UseBaseTenLogHelp == 1 || $globalUseBaseTenLogHelp == 1) {
      $naturalLogHelpString = "<li><font color='#222255'>Entering natural logarithm:</font> In this question, use <code>ln(x)</code><br /><br /></li>";
      $basetenLogHelpString = "<li><font color='#222255'>Entering base 10 logarithm:</font> In this question, use <code>log(x)</code>, <code>log10(x)</code>, or <code>logten(x)</code>.<br /><br /></li>";
  } else {
      $naturalLogHelpString = "<li><font color='#FF0000'><b>Caution:</b></font> In this question <b><code>log(x)</code></b> is the same as <b><code>ln(x)</code></b><br /><br /></li><li><font color='#222255'>Entering natural logarithm:</font> In this question, use <code>ln(x)</code> or <code>log(x)</code><br /><br /></li>";
      $basetenLogHelpString = "<li><font color='#222255'>Entering base 10 logarithm:</font> In this question, use <code>log10(x)</code> or <code>logten(x)</code>.<br /><br /></li>";
  }

if ($logarithmsHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpLogarithms() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Logarithms</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Logarithms</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("$naturalLogHelpString")
OpenWindow.document.write("$basetenLogHelpString")
OpenWindow.document.write("<li><font color='#222255'>Entering logarithms base b:</font>  &nbsp; <code>ln(x)/ln(b)</code> &nbsp; or &nbsp; <code>log(x)/log(b)</code><blockquote>WeBWorK does not recognize logarithms to other bases, so you must use the change of base formula for logarithms to enter your answer.  For example, enter log base 2 of x as <br /><br /><code>ln(x)/ln(2)</code> &nbsp;&nbsp; or &nbsp;&nbsp; <code>log(x)/log(2)</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Put parentheses around the arguments to logs:</font><blockquote><code>ln(2x+8)</code> &nbsp; and &nbsp; <code>ln2x+8 = ln(2)*x+8</code> &nbsp; are very different.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes logarithms must be simplified or expanded:</font><blockquote>For example, the required answer may be &nbsp; <code>ln(6) + ln(x)</code> &nbsp; or &nbsp; <code>ln(6x)</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain operations are not allowed.</font><blockquote>Usually, the operations that are not allowed include addition <code>+</code>, subtraction <code>-</code>, multiplication <code>*</code>, division <code>/</code>, and exponentiation <code>^</code> (or <code>**</code>).  When these operations are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain functions are not allowed.</font>  <blockquote>Usually, the functions that are not allowed include square root <code>sqrt( )</code>, absolute value <code>| |</code> (or <code>abs( )</code>), as well as other named functions such as <code>sin( )</code>, <code>ln( )</code>, etc.  When these functions are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("<li><a href='http://webwork.maa.org/wiki/Available_Functions' target='_new'>Link to a list of all available functions</a><br /><br /></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$logarithmsHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (logarithms)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpLogarithms()';");
} else { return $helpstring; }









###########################################
#  Matrices

} elsif ($helptype =~ m/matri/i) {

if ($matricesHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpMatrices() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Matrices</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Matrices</h2></center>")
OpenWindow.document.write("<center><h3>When there is one big answer box</h3></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li>If the matrix has only one row, enter a list.  For example, enter a 1 x 3 matrix as a comma separated list enclosed by square brackets: <blockquote><code>[1, 2, 3]</code></blockquote> </li>")
OpenWindow.document.write("<li>If the matrix has more than one row, enter a list of lists.  For example, enter a 2 x 3 matrix with 1, 2, 3 in the top row and 4, 5, 6 in the bottom row as: <blockquote><code>[ [1, 2, 3], [4, 5, 6] ]</code></blockquote> </li>")
OpenWindow.document.write("<li>If the matrix has only one column, enter a list of lists.  For example, enter a 2 x 1 matrix with 1 in the top row and 2 in the bottom row as: <blockquote><code>[ [1], [2] ]</code></blockquote> </li>")
OpenWindow.document.write("<li>Enter <b>DNE</b> (short for Does Not Exist) if the answer is that no matrix with the desired property exists.</li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("<center><h3>When there are multiple small answer boxes</h3></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li>In this case, there is one answer box for each entry in the matrix.  Do the obvious thing and enter one item (often a number or a formula) into each answer box.</li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$matricesHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (matrices)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpMatrices()';");
} else { return $helpstring; }











##########################################
#  Numbers

} elsif ($helptype =~ m/number/i) {

if ($numberHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpNumbers() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Numbers</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Numbers</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>Examples of (real) numbers include:</font><blockquote><code>4, 5/2, -1/3, pi/3, e^3, 3.1415926535, sqrt(2) = 2^(1/2), ln(2), sin(2pi/3)</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If there is more than one correct answer, enter your answers as a comma separated list.</font><blockquote>For example, enter &nbsp; <nobr><code>-1.5, 4/3, 2pi, e^3, 5</code></nobr><br />Do not use commas in large numbers: enter &nbsp; <code>4321</code> &nbsp; (not &nbsp; <code>4,321</code>)</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If there are no solutions:</font><blockquote>Enter &nbsp; <code>NONE</code> &nbsp; or &nbsp; <code>DNE</code> &nbsp; (this may vary from problem to problem)</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If your answer is a decimal, give at least 5 decimal places.</font><blockquote>Typically, if your answer is correct to 5 decimal places it will be marked correct, although the number of decimal places required may vary from problem to problem.  When in doubt, give more decimal places.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, fractions and certain operations are not allowed.</font><blockquote>Usually, the operations that are not allowed include addition <code>+</code>, subtraction <code>-</code>, multiplication <code>*</code>, division <code>/</code>, and exponentiation <code>^</code> (or <code>**</code>).  When these operations are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Sometimes, certain functions are not allowed.</font>  <blockquote>Usually, the functions that are not allowed include square root <code>sqrt( )</code>, absolute value <code>| |</code> (or <code>abs( )</code>), as well as other named functions such as <code>sin( )</code>, <code>ln( )</code>, etc.  When these functions are not allowed, it is usually because you are expected to be able to simplify your answer, often without using a calculator.</blockquote></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

 $numberHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (numbers)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpNumbers()';");
} else { return $helpstring; }






#######################################
#  Points

} elsif ($helptype =~ m/point/i) {

if ($pointsHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpPoints() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Points</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Points</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>A point must use parentheses and commas:</font><blockquote><code>(4.5, 3/7)</code> &nbsp; is a valid point in 2 dimensions<br /><code>(pi,e,2)</code> &nbsp; is a valid point in 3 dimensions </blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If the answer is more than one point:</font><blockquote>Enter your answer as a comma-separated list of points, for example: &nbsp;&nbsp;<code>(4,3), (5,10)</code> </blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If there are no solutions:</font><blockquote>Enter &nbsp; <code>NONE</code> &nbsp; or &nbsp; <code>DNE</code> &nbsp; (this may vary from problem to problem)</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of constants used in points:</font><blockquote><code>pi</code>, <code>e = e^1</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Functions may be used in each coordinate of a point, but may not be applied across the parentheses or commas:</font><blockquote><code>(sqrt(2),sqrt(5))</code> &nbsp; is valid, but &nbsp; <code>(sqrt(2,5))</code> &nbsp; is not</blockquote></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$pointsHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (points)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpPoints()';");
} else { return $helpstring; }









####################################
#  Units

} elsif ($helptype =~ m/unit/i) {

if ($unitsHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpUnits() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Abbreviations for Units</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Abbreviations for Units</h2></center>")
OpenWindow.document.write("<ul><li>Some WeBWorK problems ask for answers with units.  Below is a list of basic units and how they need to be abbreviated in WeBWorK answers.  In some problems, youmay need to combine units (e.g, velocity might be in <code>ft/s</code> for feet per second).</li></ul><br /><br /><center><table border='1' cellpadding='4' cellspacing='0'><tr><th>Unit</th><th>Abbreviation</th></tr><tr><td colspan='2' align='center'><b>Time</b></td></tr><tr><td> Seconds  </td><td align='center'>  s</td></tr><tr><td> Minutes  </td><td align='center'>  min</td></tr><tr><td> Hours  </td><td align='center'>  hr</td></tr><tr><td> Days  </td><td align='center'>  day</td></tr><tr><td> Years  </td><td align='center'>  year</td></tr><tr><td> Milliseconds  </td><td align='center'>  ms</td></tr><tr><td colspan='2' align='center'><b>Distance</b></td></tr><tr><td> Feet  </td><td align='center'>  ft</td></tr><tr><td> Inches  </td><td align='center'>  in</td></tr><tr><td> Miles  </td><td align='center'>  mi</td></tr><tr><td> Meters  </td><td align='center'>  m</td></tr><tr><td> Centimeters  </td><td align='center'>  cm</td></tr><tr><td> Millimeters  </td><td align='center'>  mm</td></tr><tr><td> Kilometers  </td><td align='center'>  km</td></tr><tr><td> Angstroms  </td><td align='center'>  A</td></tr><tr><td> Light years  </td><td align='center'>  light-year</td></tr><tr><td colspan='2' align='center'><b>Mass</b></td></tr><tr><td> Grams  </td><td align='center'>  g</td></tr><tr><td> Kilograms  </td><td align='center'>  kg</td></tr><tr><td> Slugs  </td><td align='center'>  slug</td></tr><tr><td colspan='2' align='center'><b>Volume</b></td></tr><tr><td> Liters  </td><td align='center'>  L</td></tr><tr><td> Cubic Centimeters  </td><td align='center'>  cc</td></tr><tr><td> Milliliters  </td><td align='center'>  ml</td></tr><tr><td colspan='2' align='center'><b>Force</b></td></tr><tr><td> Newtons  </td><td align='center'>  N</td></tr><tr><td> Dynes  </td><td align='center'>  dyne</td></tr><tr><td> Pounds  </td><td align='center'>  lb</td></tr><tr><td> Tons  </td><td align='center'>  ton</td></tr><tr><td colspan='2' align='center'><b>Work/Energy</b></td></tr><tr><td> Joules  </td><td align='center'>  J</td></tr><tr><td> kilo Joule  </td><td align='center'>  kJ</td></tr><tr><td> ergs  </td><td align='center'>  erg</td></tr><tr><td> foot pounds  </td><td align='center'>  lbf</td></tr><tr><td> calories  </td><td align='center'>  cal</td></tr><tr><td> kilo calories  </td><td align='center'>  kcal</td></tr><tr><td> electron volts  </td><td align='center'>  eV</td></tr><tr><td> kilo Watt hours  </td><td align='center'>  kWh</td></tr><tr><td colspan='2' align='center'><b>Misc</b></td></tr><tr><td> Amperes  </td><td align='center'>  amp</td></tr><tr><td> Moles  </td><td align='center'>  mol</td></tr><tr><td> Degrees Centrigrade  </td><td align='center'>  degC</td></tr><tr><td> Degrees Fahrenheit  </td><td align='center'>  degF</td></tr><tr><td> Degrees Kelvin  </td><td align='center'>  degK</td></tr><tr><td> Angle degrees </td><td align='center'>  deg</td></tr><tr><td> Angle radians </td><td align='center'>  rad</td></tr></table></center><br /><br />")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$unitsHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (units)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpUnits()';");
} else { return $helpstring; }







########################################
#  Vectors

} elsif ($helptype =~ m/vector/i) {

if ($vectorsHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpVectors() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Help Entering Vectors</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Help Entering Vectors</h2></center>")
OpenWindow.document.write("<ul>")
OpenWindow.document.write("<li><font color='#222255'>Predefined vectors i, j, and k</font><blockquote><code>i</code> &nbsp; is the same as &nbsp; <code>&lt;1,0,0&gt;</code> &nbsp;&nbsp; or &nbsp;&nbsp; <code>&lt;1,0&gt;</code><br /><code>j</code> &nbsp; is the same as &nbsp; <code>&lt;0,1,0&gt;</code> &nbsp;&nbsp; or &nbsp;&nbsp; <code>&lt;0,1&gt;</code><br /><code>k</code> &nbsp; is the same as &nbsp; <code>&lt;0,0,1&gt;</code><br /></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>A vector may be entered using angle brackets and commas, or adding multiples of i, j, and k:</font><blockquote><code>&lt;4.5, 3/7&gt;</code> &nbsp; and &nbsp; <code>4.5i + 3/7j</code> &nbsp; are valid vectors in 2 dimensions<br /><code>&lt;pi,e,2&gt;</code> &nbsp; and &nbsp; <code>pi i + e j + 2 k</code> &nbsp; are valid vectors in 3 dimensions </blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If the answer is more than one vector:</font><blockquote>Enter your answer as a comma-separated list of vectors, for example: &nbsp;&nbsp;<code>&lt;4,3&gt;, &lt;5,10&gt;</code> </blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>If there are no solutions:</font><blockquote>Enter &nbsp; <code>NONE</code> &nbsp; or &nbsp; <code>DNE</code> &nbsp; (this may vary from problem to problem)</blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Examples of constants used in vectors:</font><blockquote><code>pi</code>, <code>e = e^1</code></blockquote></li>")
OpenWindow.document.write("<li><font color='#222255'>Functions may be used in each coordinate of a vector, but may not be applied across the parentheses or commas:</font><blockquote><code>&lt;sqrt(2),sqrt(5)&gt;</code> &nbsp; is valid, but &nbsp; <code>&lt;sqrt(2,5)&gt;</code> &nbsp; is not<br /> <br /></blockquote></li>")
OpenWindow.document.write("<li><a href='http://webwork.maa.org/wiki/Available_Functions' target='_new'>Link to a list of all available functions</a><br /><br /></li>")
OpenWindow.document.write("</ul>")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$vectorsHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (vectors)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpVectors()';");
} else { return $helpstring; }








#########################################
#  Syntax (the catch all)

#} elsif ($helptype =~ m/syntax/i) {
} else {

if ($syntaxHelpExists != 1) {

HEADER_TEXT(<<END_HEADER_TEXT);
<script type="text/javascript">
<!--
function openhelpSyntax() {
OpenWindow=window.open("","answer_format_help","width=550,height=550,status=0,toolbar=0,location=0,menubar=0,directories=0,resizeable=1,scrollbars=1");
OpenWindow.document.write("<title>Sytnax for Entering Answers</title>")
OpenWindow.document.write("<body bgcolor='#ffffff'>")
OpenWindow.document.write("<center><h2>Syntax for Entering Answers</h2></center>")
OpenWindow.document.write("<ul><li> + Addition</li><li> - Subtraction</li><li> * Multiplication can also be indicated by a space or juxtaposition, e.g. 2x, 2 x or 2*x, also 2(3+4).</li><li> / Division</li><li> ^ or ** You can use either ^ or ** for exponentiation, e.g. 3^2 or 3**2</li><li> Parentheses: () - You can also use square brackets, [ ], and braces, { }, for grouping, e.g. [1+2]/[3(4+5)]</li></ul><a name='Syntax_for_entering_expressions'></a><h3>Syntax for entering expressions</h4><ul><li> Be careful entering expressions just as you would be careful entering expressions in a calculator.</li><li> <b>Use the 'Preview Button' to see exactly how your entrylooks. E.g. to tell the difference between 1+2/3*4 and [1+2]/[3*4]click the 'Preview Button'.</b></li><li> Sometimes using the * symbol to indicate mutiplication makesthings easier to read. For example (1+2)*(3+4) and (1+2)(3+4) are bothvalid. So are 3*4 and 3&nbsp;4 (3 space 4, not 34) but using a * makesthings clearer.</li><li> Use ('s and )'s to make your meaning clear. You can also use ['s and ]'s and {'s and }'s.</li><li> Don't enter 2/4+5 (which is 5.5) when you really want 2/(4+5) (which is 2/9).</li><li> Don't enter 2/3*4 (which is 8/3) when you really want 2/(3*4) (which is 2/12).</li><li> Entering big quotients with square brackets, e.g. [1+2+3+4]/[5+6+7+8], is a good practice.</li><li> Be careful when entering functions. It's always good practiceto use parentheses when entering functions. Write sin(t) instead ofsint or sin t even though WeBWorK is smart enough to <b>usually</b> accept sin t or even sint. For example, sin 2t is interpreted as sin(2)t, i.e. (sin(2))*t so be careful.</li><li> You can enter sin^2(t) as a short cut although mathematicallyspeaking sin^2(t) is shorthand for (sin(t))^2(the square of sin of t).(You can enter it as sin(t)^2 or even sint^2, but don't try such thingsunless you <b>really</b> understand the precedence of operations. The'sin' operation has highest precedence, so it is performed first, usingthe next token (i.e. t) as an argument. Then the result is squared.)You can always use the Preview button to see a typeset version of whatyou entered and check whether what you wrote was what you meant. :-)</li><li> For example 2+3sin^2(4x) will work and is equivalent to2+3(sin(4x))^2 or 2+3sin(4x)^2. Why does the last expression work?Because things in parentheses are always done first [ i.e. (4x)], nextall functions, such as sin, are evaluated [giving sin(4x)], next allexponents are taken [giving sin(4x)^2], next all multiplications anddivisions are performed in order from left to right [giving3sin(4x)^2], and finally all additions and subtractions are performed[giving 2+3sin(4x)^2].</li><li> Is -5^2 positive or negative? It's negative. This is becausethe square operation is done before the negative sign is applied. Use(-5)^2 if you want to square negative 5.</li><li> When in doubt use parentheses!!!&nbsp;:-)</li><li> The complete rules for the precedence of operations, in addition to the above, are<ul><li> Multiplications and divisions are performed left to right: 2/3*4 = (2/3)*4 = 8/3.</li><li> Additions and subtractions are performed left to right: 1-2+3 = (1-2)+3 = 2.</li><li> Exponents are taken right to left: 2^3^4 = 2^(3^4) = 2^81 = a big number.</li></ul></li><li> <b>Use the 'Preview Button' to see exactly how your entrylooks. E.g. to tell the difference between 1+2/3*4 and [1+2]/[3*4]click the 'Preview Button'.</b></li></ul><a name='Mathematical_Constants_Available_In_WeBWorK'></a><h4>&nbsp;&nbsp;Mathematical Constants Available In WeBWorK</h4><ul><li> pi This gives 3.14159265358979, e.g. cos(pi) is -1</li><li> e This gives 2.71828182845905, e.g. ln(e*2) is 1 + ln(2)</li></ul><a name='Scientific_Notation_Available_In_WeBWorK'></a><h4>&nbsp;&nbsp;Scientific Notation Available In WeBWorK</h4><ul><li> 2.1E2 is the same as  210</li><li> 2.1E-2 is the same as .021</li></ul><a name='Mathematical_Functions_Available_In_WeBWorK'></a><h4>&nbsp;&nbsp;Mathematical Functions Available In WeBWorK</h4><p>Note that sometimes one or more of these functions is disabled for a WeBWorK problem because the instructor wants you to calculate the answer by some means other than just using the function.</p><ul><li> abs( ) The absolute value</li><li> cos( ) Note: cos( ) uses radian measure</li><li> sin( ) Note: sin( ) uses radian measure</li><li> tan( ) Note: tan( ) uses radian measure</li><li> sec( ) Note: sec( ) uses radian measure</li><li> cot( ) Note: cot( ) uses radian measure</li><li> csc( ) Note: csc( ) uses radian measure</li><li> exp( ) The same function as e^x</li><li> log( ) This is usually the natural log but your professor may have redined this as log to the base 10</li><li> ln( ) The natural log</li><li> logten( ) The log to the base 10</li><li> arcsin( )</li><li> asin( ) or sin^-1() Another name for arcsin</li><li> arccos( )</li><li> acos( ) or cos^-1() Another name for arccos</li><li> arctan( )</li><li> atan( ) or tan^-1() Another name for arctan</li><li> arccot( )</li><li> acot( ) or cot^-1() Another name for arccot</li><li> arcsec( )</li><li> asec( ) or sec^-1() Another name for arcsec</li><li> arccsc( )</li><li> acsc( ) or csc^-1() Another name for arccsc</li><li> sinh( )</li><li> cosh( )</li><li> tanh( )</li><li> sech( )</li><li> csch( )</li><li> coth( )</li><li> arcsinh( )</li><li> asinh( ) or sinh^-1() Another name for arcsinh</li><li> arccosh( )</li><li> acosh( ) or cosh^-1()Another name for arccosh</li><li> arctanh( )</li><li> atanh( ) or tanh^-1()Another name for arctanh</li><li> arcsech( )</li><li> asech( ) or sech^-1()Another name for arcsech</li><li> arccsch( )</li><li> acsch( ) or csch^-1() Another name for arccsch</li><li> arccoth( )</li><li> acoth( ) or coth^-1() Another name for arccoth</li><li> sqrt( )</li><li> n!  (n factorial -- defined for nonnegative integers)</li><li> These functions may not always be available for every problem.<ul><li> sgn( ) The sign function, either -1, 0, or 1</li><li> step(x) The step function (0 if x &lt; 0, and 1 if x &ge; 0)</li><li> fact(n) The factorial function n! (defined only for nonnegative integers)</li><li> P(n,k) = n*(n-1)*(n-2)...(n-k+1) the number of ordered sequences of k elements chosen from n elements</li><li> C(n,k) = 'n choose k' the number of unordered sequences of k elements chosen from n elements</li></ul></li></ul>For more information:<a href='http://webwork.maa.org/wiki/Available_Functions' target='_new'>http://webwork.maa.org/wiki/Available_Functions</a><br /><br />")
OpenWindow.document.write("</body>")
OpenWindow.document.write("</html>")
OpenWindow.document.close()
self.name="main"
if (window.focus) {OpenWindow.focus()}
return false;
}
-->
</script>
END_HEADER_TEXT

$syntaxHelpExists = 1;
}

if (!$customstring) { $helpstring = "help (syntax)"; } else { $helpstring = $customstring; }

if ($main::displayMode ne "TeX") { 
    return htmlLink( "#", "$helpstring","onClick='return openhelpSyntax()';");
} else { return $helpstring; }

}






} # end AnswerFormatHelp

1;
