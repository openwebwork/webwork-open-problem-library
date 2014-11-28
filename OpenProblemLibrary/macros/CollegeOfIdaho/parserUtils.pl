loadMacros(
  "unionImage.pl",
  "unionTables.pl",
);

$bHTML = '\begin{rawhtml}';
$eHTML = '\end{rawhtml}';

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
#  Block quotes
#
$BBLOCKQUOTE = HTML('<BLOCKQUOTE>','\hskip3em ');
$EBLOCKQUOTE = HTML('</BLOCKQUOTE>');

#
#  Smart-quotes in TeX mode, regular quotes in HTML mode
#
$LQ = MODES(TeX => '``', Latex2HTML => '"', HTML => '"');
$RQ = MODES(TeX => "''", Latex2HTML => '"', HTML => '"');

#
#  make sure all characters are displayed
#
sub protectHTML {
    my $string = shift;
    $string =~ s/&/\&amp;/g;
    $string =~ s/</\&lt;/g;
    $string =~ s/>/\&gt;/g;
    $string;
}

sub _parserUtils_init {}

1;

