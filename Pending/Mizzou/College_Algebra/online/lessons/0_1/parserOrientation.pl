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
  TeX => '\hbox{\texttt{\char`\^}}',
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


1;
