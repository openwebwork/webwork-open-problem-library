#!/usr/local/bin/perl

######################################################################
#
#  Macros used by the orientation problem set
#
######################################################################


#loadMacros("PGcourse.pl");

#
#  Special use of CARET to have it work in non-math mode
#
$CARET = MODES(
  TeX => '\hbox{\texttt{\char94}}',
  Latex2HTML => '^',
  HTML => '^'
);

#
#  Functions to display student input and computer output
#  (written as functions so that we change the style without
#  recoding the problems themselves).
#
sub student {
  my $message = shift;
  MODES(
    TeX => '\leavevmode\hbox{\texttt{'.$message.'}}',
    Latex2HTML =>
       $bHTML.'<NOBR><TT>'.$eHTML.$message.$bHTML.'</TT></NOBR>'.$eHTML,
    HTML => '<NOBR><TT>'.$message.'</TT></NOBR>'
  );
}

sub computer {
  my $message = shift;
  MODES(
    TeX => '\hbox{\texttt{'.$message.'}}',
    Latex2HTML =>
       $bHTML.'<NOBR><TT>'.$eHTML.$message.$bHTML.'</TT></NOBR>'.$eHTML,
    HTML => '<NOBR><TT>'.$message.'</TT></NOBR>'
  );
}

#
#  This prints things we need to fill in yet in red
#
sub moreWork {
  my $message = shift;
  MODES(
    TeX => '{\sl ' . $message . '}',
    Latex2HTML => $bHTML . '<FONT COLOR="#A00000">' . $eHTML .
      $message . $bHTML . '</FONT>' . $eHTML,
    HTML => '<FONT COLOR="#A00000">' . $message . '</FONT>'
  );
}

#
#  Temporary macros to mark comments in areas that we are
#  working on.
#
$BCOMMENT = MODES(
  TeX => '{\footnotesize\it',
  Latex2HTML => $bHTML.'<BLOCKQUOTE><SMALL><I><FONT COLOR="#A00000">'.$eHTML,
  HTML => '<BLOCKQUOTE><SMALL><I><FONT COLOR="#A00000">'
);

$ECOMMENT = MODES(
  TeX => '}',
  Latex2HTML => $bHTML.'</FONT></I></SMALL></BLOCKQUOTE>'.$eHTML,
  HTML => '</FONT></I></SMALL></BLOCKQUOTE>'
);

# $BCOMMENT = MODES(
#     TeX => '\iffalse',
#     Latex2HTML => $bHTML.'<!-- '.$eHTML,
#     HTML => '<!-- '
# );
# 
# $ECOMMENT = MODES(
#     TeX => '\fi',
#     Latex2HTML => $bHTML.' -->'.$eHTML,
#     HTML => ' -->'
# );


#
#  Hack to get better spacing in HTML_tth math mode but without
#  messing up the spacing in other modes.
#
$SP = MODES(
   TeX => ' ', Latex2HTML => ' ',
   HTML => ' ', HTML_tth => '\ ',
   HTML_jsMath => ' ', HTML_dpng => ' ',
);


#
#  Special table macros for questions that have 
#  displayed math expressions equal to an answer rule,
#  with an accompanying explanation on a separate line.
#

sub BeginExamples {
  return "" if ($displayMode eq "TeX");
  BeginTable(@_);
}

sub EndExamples {
  return "" if ($displayMode eq "TeX");
  EndTable();
}

@ExampleDefaults = (ans_rule_len => 40, ans_rule_height => 1);

sub BeginExample {
  my $math = shift;
  my $ans = shift;
  my %options = (@ExampleDefaults, @_);
  my ($cols,$rows) = ($options{ans_rule_len},$options{ans_rule_height});
  my $rule;

  if ($rows == 1) {$rule = ans_rule($cols)}
    else {$rule = ans_box($rows,$cols)}
  ANS($ans);

  #
  #  HTML_tth puts an unwanted <BR> at the beginning,
  #  and uses a centered table.  Remove the <BR> and
  #  align the table to the right.
  #
  if ($displayMode eq "HTML_tth") {
    $math = trimString(EV2('\['.$math.'\]'));
    $math =~ s!<br clear="all" />!!;
    $math =~ s!table align="center"!table align="right"!;
  } elsif ($displayMode eq "HTML") {
    $math = '\('.$math.'\)'
  } elsif ($displayMode =~ m/^HTML/) {
    $math = '\(\displaystyle '.$math.'\)'
  }

  MODES(
    TeX => "\n".'\['.$math.'=\hbox to 8em{'.$rule.'}\]',
    Latex2HTML => $bHTML.'<TR><TD ALIGN="RIGHT">'.$eHTML.
      '\(\displaystyle '.$math.'\)'.$bHTML.'</TD><TD>&nbsp;=&nbsp;&nbsp;</TD>'.
      '<TD>'.$eHTML.$rule.$bHTML.'</TD></TR>'.
      '<TR><TD></TD><TD></TD><TD>'.$eHTML,
    HTML => 
      '<TR><TD ALIGN="RIGHT">'.$math.'</TD><TD>&nbsp;=&nbsp;&nbsp;</TD>'.
      '<TD>'.$rule.'</TD></TR><TR><TD COLSPAN="2"></TD><TD>'
  );
}

sub EndExample {
  MODES(
    TeX => "\n",
    Latex2HTML => $bHTML.'<BR><BR></TD></TR>'.$eHTML,
    HTML => '<BR><BR></TD></TR>'
  );
}

sub ExampleRule {
  MODES(
    TeX => '\par',
    Latex2HTML => $bHTML.'<TR><TD COLSPAN="3"><HR></TD></TR>'.$eHTML,
    HTML => '<TR><TD COLSPAN="3"><HR></TD></TR>'
  );
}

#
#  Produce a TeX version and an answer checker for the formula
#
sub DisplayQA {my $f = shift; return (DMATH($f->TeX),$f->cmp)}
sub QA {my $f = shift; return ($f->TeX,$f->cmp)}

##################################################
#
#  Insert an image of an equation (but use the equation
#  in TeX mode).
#

sub MathIMG {
  my ($img,$text,$tex) = @_;
  my $useTeX = MODES(TeX => 1, Latex2HTML => 0, HTML => 0, HTML_tth => 0, HTML_dpng => 1);
  return '\('.$tex.'\)' if $useTeX;
  $img = alias($img);
  return qq{<IMG SRC="$img" BORDER="0" ALIGN="MIDDLE" ALT="$text">};
}


##################################################
#
#  A simple grader that always returns a score of 1.
#  This is used in the tutorial to give students
#  credit for reading a problem (even if it doesn't
#  ask any questions).
#  
sub forgiving_grader {
    my $rh_evaluated_answers = shift;
    my $rh_problem_state = shift;
    my %form_options = @_;
    my %evaluated_answers = %{$rh_evaluated_answers};
    my %problem_state =	%{$rh_problem_state};
    
    my %problem_result = (
       score  => 1,   # always return 1
       errors => '',
       type   => 'forgiving_grader',
       msg    => '',
    );
    
    return(\%problem_result,\%problem_state)
      if (!$form_options{answers_submitted});
    
    $problem_state{recorded_score} = $problem_result{score};
    $problem_state{num_of_correct_ans}++;
    
    (\%problem_result, \%problem_state);
}

##################################################
#
#  Syntactic sugar to avoid ugly ~~& construct in PG.
#
sub install_forgiving_grader {install_problem_grader(\&forgiving_grader)}

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


sub BeginList {
  my $LIST = 'OL';
  $LIST = shift if (uc($_[0]) eq "OL" or uc($_[0]) eq "UL");
  my $enum = ($LIST eq 'OL' ? "enumerate" : "itemize");
  my %options = @_;
  $LIST .= ' TYPE="'.$options{type}.'"' if defined($options{type});
  $LIST .= ' START="'.$options{value}.'"' if defined($options{value});
  $LIST = "<$LIST>";
  my $tex = ""; my $type = ""; my $top = "";
  $tex .= "\\parindent=0pt \\parskip=.75\\baselineskip\n" if $options{tex_par};
  $tex .= "\\setcounter{enumi}{".($options{value}-1)."}" if defined($options{value}) && $LIST eq 'OL';
  $type = "[\\quad $options{type}.]" if defined($options{type}) && $LIST eq 'OL';
  $top = '\vskip-\parskip\hrule height 0pt' if $options{noTopSkip};

  MODES(
    TeX => "\\par${top}{\\parskip=0pt\\begin{$enum}$type\n$tex",
    Latex2HTML => $bHTML.$LIST.$eHTML,
    HTML => $LIST."\n"
  );
}

#
#  Usage:  EndList(type)
#
#  where type is the list type (and must match the BeginList type).
#
sub EndList {
  my $LIST = shift; $LIST = 'OL' unless defined $LIST;
  my $enum = ($LIST eq 'OL' ? "enumerate" : "itemize");
  $LIST = "</$LIST>";
  MODES(
    TeX => "\\end{$enum}}",
    Latex2HTML => $bHTML.$LIST.$eHTML,
    HTML => $LIST."\n"
  );
}

#
#  Syntactic sugar for making lists of paragraphs
#
sub BeginParList {
  my $LIST = 'OL';
  $LIST = shift if (uc($_[0]) eq "OL" or uc($_[0]) eq "UL");
  BeginList($LIST,tex_par=>1,@_);
}

sub EndParList {EndList(@_)};


#
#  Use $ITEM to introduce a new list item
#
$ITEM = MODES(
  TeX => '\item\ignorespaces ',
  Latex2HTML => $bHTML.'<LI>'.$eHTML,
  HTML => "<LI>"
);

#
#  This is a hack for when you want MSIE to handle
#  space between list items properly
#
$ITEMSEP = MODES(
  TeX => '\par\vskip-\parskip\vskip\baselineskip ',
  Latex2HTML => $bHTML."<BR><BR>".$eHTML,
  HTML => "<BR><BR>"
);


sub ColumnTable {
  my $col1 = shift; my $col2 = shift;
  my %options = (indent => 0, separation => 50, valign => "MIDDLE", @_);
  my ($ind,$sep) = ($options{"indent"},$options{"separation"});
  my $valign = $options{"valign"};

  my ($bhtml,$ehtml) = ('\begin{rawhtml}','\end{rawhtml}');
  ($bhtml,$ehtml) = ('','') unless ($displayMode eq "Latex2HTML");

  my $HTMLtable = qq {
    $bhtml<TABLE BORDER="0"><TR VALIGN="$valign">
    <TD WIDTH="$ind">&nbsp;</TD><TD>$ehtml
    $col1
    $bhtml</TD><TD WIDTH="$sep">&nbsp;</TD><TD>$ehtml
    $col2
    $bhtml</TD></TR></TABLE>$ehtml
  };

  MODES(
    TeX => '\par\medskip\hbox{\qquad\vtop{'.
	   '\advance\hsize by -3em '.$col1.'}}'.
           '\medskip\hbox{\qquad\vtop{'.
           '\advance\hsize by -3em '.$col2.'}}\medskip',
    Latex2HTML => $HTMLtable,
    HTML => $HTMLtable
  );
}

#
#  Use columns for a match-list output
#
#  Usage:  ColumnMatchTable($ml,options)
#
#  where $ml is a math list reference and options are those
#  allowed for ColumnTable above.
#
sub ColumnMatchTable {
  my $ml = shift;

  ColumnTable($ml->print_q,$ml->print_a,@_);
}



#
#  Command for tables with no borders.
#
#  Usage:  BeginTable(options);
#
#  Options are taken from:
#
#    border => n           value for BORDER attribute (default 0)
#    spacing => n          value for CELLSPACING attribute (default 0)
#    padding => n          value for CELLPADDING attribute (default 0)
#    tex_spacing => dimen  value for spacing between columns in TeX
#                          (e.g, tex_spacing => 2em) (default 1em)
#    tex_border => dimen   value for left- and right border in TeX (0pt)
#    center => 0 or 1      center table or not (default 1)
#
sub BeginTable {
  my %options = (border => 0, padding => 0, spacing => 0, center => 1,
                 tex_spacing => "1em", tex_border => "0pt", @_);
  my ($bd,$pd,$sp) = ($options{border},$options{padding},$options{spacing});
  my ($tsp,$tbd) = ($options{tex_spacing},$options{tex_border});
  my ($center,$tcenter) = (' ALIGN="CENTER"','\centerline');
     ($center,$tcenter) = ('','') if (!$options{center});
  my $table = 
    qq{<TABLE BORDER="$bd" CELLPADDING="$pd" CELLSPACING="$sp"$center>};

  MODES(
    TeX => '\par\medskip'.$tcenter.'{\kern '.$tbd.
           '\vbox{\halign{#\hfil&&\kern '.$tsp.' #\hfil',
    Latex2HTML => $bHTML.$table.$eHTML."\n",
    HTML => $table."\n"
  );
}

#
#  Usage:  EndTable(options)
#
#  where options are taken from:
#
#     tex_border => dimen     extra vertical space in TeX mode (default 0pt)
#
sub EndTable {
  my %options = (tex_border => "0pt", @_);
  my $tbd = $options{tex_border};
  MODES(
    TeX => '\cr}}\kern '.$tbd.'}\medskip'."\n",
    Latex2HTML => $bHTML.'</TABLE>'.$eHTML."\n",
    HTML => '</TABLE>'."\n"
  );
}

#
#  Creates a row in the table
#
#  Usage:  Row([item1,item2,...],options);
#
#  Each item appears as a separate entry in the table.
#
#  Options control how the row is displayed:
#
#    indent => num           Specifies size of blank column on the left
#                            (default:  indent => 0)
#
#    separation => num       Specifies separation of columns
#                            (default:  spearation => 30)
#
#    tex_vspace => "dimen"   Specifies additional vertical spacing for TeX
#
#    align => "type"         Specifies alignment of initial column
#                            (default:  align => "LEFT")
#
#    valign => "type"        Specified vertical alignment of row
#                            (default:  valign => "MIDDLE")
#
sub Row {
  my $rowref = shift; my @row = @{$rowref};
  my %options = (
     indent => 0, separation => 30,
     align => "LEFT", valign => "MIDDLE",
     @_
  );
  my ($cind,$csep) = ($options{indent},$options{separation});
  my ($align,$valign) = ($options{align},$options{valign});
  my $sep = '<TD WIDTH="'.$csep.'">&nbsp;</TD>'; $sep = '' if ($csep < 1);
  my $ind = '<TD WIDTH="'.$cind.'">&nbsp;</TD>'; $ind = '' if ($cind < 1);
  my $fill = '';
  $fill = '\hfil' if (uc($align) eq "CENTER");
  $fill = '\hfill' if (uc($align) eq "RIGHT");
  my $vspace = '';
  $vspace = '\noalign{\vskip '.$options{tex_vspace}.'}' if $options{tex_vspace};

  MODES(
    TeX => '\cr'.$vspace."\n". $fill . join('& ',@row),
    Latex2HTML =>
      $bHTML."<TR VALIGN=\"$valign\">$ind<TD ALIGN=\"$align\">".$eHTML .
      join($bHTML."</TD>$sep<TD>".$eHTML,@row) .
      $bHTML.'</TD></TR>'.$eHTML."\n",
    HTML => "<TR VALIGN=\"$valign\">$ind<TD ALIGN=\"$align\">" .
      join("</TD>$sep<TD>",@row) . '</TD></TR>'."\n"
  );
}


sub TableSpace {
  my $rsep = shift;
  my $tsep = shift;
  $rsep = $tsep if (defined($tsep) && $main::displayMode eq "TeX");
  return "" if ($rsep < 1);
  MODES(
    TeX => '\vadjust{\kern '.$rsep.'pt}' . "\n",
    Latex2HTML =>
      $bHTML.'<TR><TD HEIGHT="'.$rsep.'"><!></TD></TR>'.$eHTML."\n",
    HTML => '<TR><TD HEIGHT="'.$rsep.'"></TD></TR>'."\n",
  );
}



#
#  A horizontal rule within a table.  (Could have been a variable,
#  but all the other table commands are subroutines, so kept it
#  one to be consistent.)
#
sub TableLine {
  MODES(
    TeX => '\vadjust{\kern2pt\hrule\kern2pt}',
    Latex2HTML => $bHTML.
      '<TR><TD COLSPAN="10"><HR NOSHADE SIZE="1"></TD></TR>'.
      $eHTML."\n",
    HTML =>'<TR><TD COLSPAN="10"><HR NOSHADE SIZE="1"></TD></TR>'."\n"
  );
}


sub Image {
  my $image = shift; my $ilink;
  my %options = (
    size => [150,150], tex_size => 200,
    link => 0, align => "BOTTOM", tex_center => 0, @_);
  my ($w,$h) = @{$options{size}};
  my ($ratio,$link) = ($options{tex_size}*(.001),$options{link});
  my ($border,$align) = ($options{border},$options{align});
  my ($tcenter) = $options{tex_center};
  my $HTML; my $TeX;
  ($image,$ilink) = @{$image} if (ref($image) eq "ARRAY");
  $image = alias(insertGraph($image)) if (ref($image) eq "WWPlot");
  $image = alias($image) unless ($image =~ m!^/!i);
  if ($ilink) {
    $ilink = alias(insertGraph($ilink)) if (ref($ilink) eq "WWPlot");
    $ilink = alias($ilink) unless ($ilink =~ m!^/!i);
  } else {$ilink = $image}
  $border = (($link || $ilink ne $image)? 2: 1) unless defined($border);
  $HTML = '<IMG SRC="'.$image.'" WIDTH="'.$w.
          '" HEIGHT="'.$h.'" BORDER="'.$border.'" ALIGN="'.$align.'">';
  $HTML = '<A HREF="'.$ilink.'">'.$HTML.'</A>' if $link or $ilink ne $image;
  $TeX = '\includegraphics[width='.$ratio.'\linewidth]{'.$image.'}';
  $TeX = '\centerline{'.$TeX.'}' if $tcenter;
  MODES(
    TeX => $TeX."\n",
    Latex2HTML => $bHTML.$HTML.$eHTML,
    HTML => $HTML
  );
}



1;
