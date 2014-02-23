######################################################################
#
#  Some macros that add to the ones like $PAR, $BR, etc.
#

sub _unionMacros_init {}; # don't reload this file

#
#  Shorthand for WeBWorK
#
$WW = "WeBWorK";

#
#  Shorthands for entering and leaving rawhtml mode in
#  LaTeX2HTML (since they are so commonly used).
#
$bHTML = '\begin{rawhtml}';
$eHTML = '\end{rawhtml}';


#
#  HTML(htmlcode)
#  HTML(htmlcode,texcode)
#
#  Insert $html in HTML mode or \begin{rawhtml}$html\end{rawhtml} in
#  Latex2HTML mode.  In TeX mode, insert nothing for the first form, and
#  $tex for the second form.
#
sub HTML {
  my ($html,$tex) = @_;
  return('') unless (defined($html) && $html ne '');
  $tex = '' unless (defined($tex));
  MODES(TeX => $tex, Latex2HTML => $bHTML.$html.$eHTML, HTML => $html);
}


#
#  Begin and end indented text
#

$BBLOCKQUOTE = HTML('<BLOCKQUOTE>','\par\bgroup\advance\leftskip by 2em ');
$EBLOCKQUOTE = HTML('</BLOCKQUOTE>','\par\egroup ');

#
#  Start and stop centering
#
$BCENTER = HTML('<CENTER>','\begin{center}');
$ECENTER = HTML('</CENTER>','\end{center}');


#
#  Begin and end <TT> mode
#
$BTT = HTML('<TT>','\texttt{');
$ETT = HTML('</TT>','}');

#
#  Begin and end <SMALL> mode
#
$BSMALL = HTML('<SMALL>','{\small ');
$ESMALL = HTML('</SMALL>','}');

#
#  Remove extra space in bold in latex2html mode
#
$BBOLD = HTML('<B>','{\bf ');
$EBOLD = HTML('</B>','}');

#
#  tth doesn't seem to understand \colon
#
$COLON = MODES(TeX=>'\colon ',HTML=>':', HTML_dpng => '\colon ');

#
#  Alternatives to the standard WW versions of these
#
$LT = $LTS;
$GT = $GTS;

$LE = $LTE;
$GE = $GTE;

#
#  Common math sets
#
$R = MODES(TeX => '{\bf R}', HTML_tth => '{\bf R}', HTML => '<B>R</B>');
$Z = MODES(TeX => '{\bf Z}', HTML_tth => '{\bf Z}', HTML => '<B>Z</B>');
$N = MODES(TeX => '{\bf N}', HTML_tth => '{\bf N}', HTML => '<B>N</B>');
$Q = MODES(TeX => '{\bf Q}', HTML_tth => '{\bf Q}', HTML => '<B>Q</B>');
$C = MODES(TeX => '{\bf C}', HTML_tth => '{\bf C}', HTML => '<B>C</B>');

#
#  Superscripts and subscript (mostly for if you want answer
#  rules in these positions).
#
$BSUP = HTML('<SUP>','$^{');
$ESUP = HTML('</SUP>','}$');

$BSUB = HTML('<SUB>','$_{');
$ESUB = HTML('</SUB>','}$');

#
#  Browser-only BR
#
$BBR = HTML('<BR>');

#
#  Broser-only \displaystyle
#
$DISPLAY = MODES(TeX => '', Latex2HTML => '\displaystyle ',
                 HTML_tth => '\displaystyle ', HTML => '');

#
#  Provides a title to the problem
#
sub Title {
  my $title = shift;

  TEXT(MODES(
    TeX => "\\par\\begin{centering}{\\bf $title}\\par\\end{centering}\\nobreak\n",
    Latex2HTML => $bHTML.'<CENTER><H2>'.$title.'</H2></CENTER>'.$eHTML,
    HTML => '<CENTER><H2>'.$title.'</H2></CENTER>'
  ));
}


#
# A warning that we are using javaScript
#
sub JAVASCRIPT_PROBLEM {
  TEXT(HTML(
     '<NOSCRIPT><CENTER><H2><FONT COLOR="#CC0000">
      This problem requires that JavaScript be enabled!
      </FONT></H2></CENTER>
      </NOSCRIPT>'
  ));
}


#
#  Modify a polynomial to remove coeficients of 1, -1 and 0
#  The polynomial can be a multivariable one.  The parameters
#  following the formula itself are the names of the variables
#  for the formula.  Any number can be provided, and the default
#  is x, y, and z.  Variable names must be one character long, 
#  and the formula really should be a polynomial, as the algorithm
#  for removing coefficients of 0 relies on that in an important way.
#
sub FPOLY {
  my $poly = shift; $poly = FEQ($poly);
  @_ = ('x','y','z') unless scalar(@_) > 0;
  my $x = '['.join('',@_).']';
  $poly =~ s/(^|[^\d.])1\s*(\*\s*)?($x)/$1$3/g;
  $poly =~ s/-1\s*($x)/-$1/g;
  $poly =~ s/(^|\+|\-)\s*0(\s*(\*\s*)?$x((\^|\*\*)\d+(\.\d*)?)?)+//g;
  $poly =~ s/(^|\+|\-)\s*0+\s*([-+]|$)/$2/;
  $poly =~ s/^\s*\+\s*//;
  $poly = "0" if ($poly eq "");
  return $poly;
}

1;
