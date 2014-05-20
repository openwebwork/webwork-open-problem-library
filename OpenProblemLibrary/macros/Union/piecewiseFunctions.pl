#! /usr/local/bin/perl

sub _piecewiseFunctions_init {}; # don't reload this file

#
#  Implements a method of producing piecewise-defined functions that
#  works in all modes (TeX, Latex2HTML and HTML).
#

##################################################
#
#  piecewiseFunction(name, [part1, part1-x, ...], options)
#
#  Here, "name" is a string like "f(x)" that is the name of the
#  function,
#
#  "part1" is the function's definition for piece one, e.g. "x+4".
#          (It is put in math mode automatically.)
#
#  "part1-x" is the function's domain description, e.g., "if \(x $LTS 3\)".
#          (It is NOT in math mode automatically.)
#
#  You can supply as many partN,partN-x pairs as needed.
#
#  The options are:
#
#      bracesize => n           specifies height of braces for HTML modes
#      spacing => n             gives row spacing for HTML
#
sub piecewiseFunction {
  my $f = shift;
  my $arrayref = shift; my @array = @{$arrayref};
  my %options = @_;
  set_default_options(\%options, bracesize => 0, spacing => 5);
  my ($size,$sep) = ($options{bracesize},$options{spacing});
  my ($output,$fx,$ifx) = ('','','');

  if ($displayMode eq 'HTML' || $displayMode eq 'HTML_tth') {
    #
    #  A <TABLE> hack to handle piecewise functions in HTML
    #
    $output =
      '<BLOCKQUOTE>
       <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
       <TR VALIGN="CENTER"><TD NOWRAP>' . "\\($f\\) = " .
      '</TD><TD WIDTH="3"></TD>' .
      "\n<TD>$braceHTML[$size]</TD>\n".
      '<TD WIDTH="3"></TD>
       <TD><TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">'."\n";
    while (@array) {
      $fx = shift(@array); $ifx = shift(@array);
      $output .= '<TR VALIGN="CENTER">'."\n".'<TD NOWRAP>' . DMATH($fx) .
        '</TD><TD WIDTH="10">&nbsp;</TD><TD NOWRAP>' . $ifx . "</TD></TR>\n";
      $output .= '<TR><TD HEIGHT="'.$sep.'"></TD></TR>' if (@array);
    }
    $output .= "</TABLE></TD></TR>\n</TABLE>\n</BLOCKQUOTE>";
  } elsif ($displayMode =~ m/^HTML/ ||
           $displayMode eq "Latex2HTML" || $displayMode eq "TeX") {
    $output = '\[' . $f . '= \begin{cases}';
    while (@array) {
      $fx = shift(@array); $ifx = shift(@array);
      $ifx =~ s/\\\(/\}/g; $ifx =~ s/\\\)/\\text\{/g;
      $output .= $fx . '&\text{' . $ifx . '}\\\\' . "\n";
    }
    $output =~ s/\\text\{\}//g; $output =~ s/\\\\$//;
    $output .= '\end{cases}\]';
  } else {
    warn "piecewiseFunction: Unknown display mode: $displayMode"
  }
  return($output);
}

#
#  Characters that make up the brace in the symbol font
#
($brt,$brm,$brb,$brc) = ('&#xF8F1;','&#xF8F2;','&#xF8F3;','&#xF8F4;');

#
#  Braces of different sizes (an alternative would be to
#  add $brc characters to extend the vertical parts).
#  If you want additional sizes, you can push more onto the end
#  of the array from within the .pg file, or add them here.
#
#
@braceHTML = (
  qq{<FONT SIZE="0">$brt<BR>$brm<BR>$brb</FONT>},
  qq{<FONT SIZE="1">$brt<BR>$brm<BR>$brb</FONT>},
  qq{<FONT SIZE="2">$brt<BR>$brm<BR>$brb</FONT>},
  qq{<FONT SIZE="3">$brt<BR>$brm<BR>$brb</FONT>},
  qq{<FONT SIZE="4">$brt<BR>$brm<BR>$brb</FONT>},
  qq{<FONT SIZE="5">$brt<BR>$brm<BR>$brb</FONT>},
  qq{<FONT SIZE="6">$brt<BR>$brm<BR>$brb</FONT>},
  qq{<FONT SIZE="7">$brt<BR>$brm<BR>$brb</FONT>},
  qq{<FONT SIZE="8">$brt<BR>$brm<BR>$brb</FONT>}
);

1;
