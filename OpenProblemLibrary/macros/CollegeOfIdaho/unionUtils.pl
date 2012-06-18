######################################################################
##
##  These are some miscellaneous routines that may be useful.
##  

sub _unionUtils_init {}; # don't reload this file

#
#  Remove leading and trailing spaces
#
sub trimString {
  my $s = shift;
  $s =~ s/^\s+|\s+$//g;
  return $s;
}

#
#  Check if a string is a number
#
sub isNumber {
  my $n = shift;
  $n = ($n =~ m/^[+-]?(\d+(\.\d*)?|\.\d+)([Ee][-+]?\d+)?$/);
  return $n;
}

#
#  names for numbers
#
sub NameForNumber {
  my $n = shift;
  my $name =  ('zeroth','first','second','third','fourth','fifth',
               'sixth','seventh','eighth','ninth','tenth')[$n];
  $name = "$n-th" if ($n > 10);
  return $name;
}


#
#  A debugging routine that allows the "warn" function to print a variable that
#  contains HTML code properly
#
sub showHTML {
    my $string = shift;
    $string =~ s/&/\&amp;/g;
    $string =~ s/</\&lt;/g;
    $string =~ s/>/\&gt;/g;
    $string;
}

#
#  Make a named subroutine that returns the value of a function.  If
#  no parameters are passed to the function, the function's string
#  is returned.  (This will be obsolete when I finish the
#  new expression parser -- DPVC.)
#
sub perlFunction {
  my $def = shift; my $debug = shift;
  if ($def !~ m/^\s*(\w+)\s*\(\s*((\w+\s*,?\s*)+)\s*\)\s*:?=\s*(.*)$/) {
    warn "perlFunction:  can't parse '$def'";
    return
  }
  my ($name,$vars,$expr) = ($1,$2,$4);
  my $f = $expr;
  my @X; my $x; $vars =~ s/\s//g;
  foreach $x (split(',',$vars)) {
    push(@X,"\$$x");
    $expr =~ s/(\b|\d)$x\b/$1(\$$x)/g;
  }
  #
  #  Fix up the expression
  #
  $expr =~ s/\bpi\b/(4*atan2(1,1))/g;
  $expr =~ s/\be\b/(exp(1))/g;
  $expr =~ s!\\frac\{([^\}]*)\}\s*\{([^\}]*)\}!($1)/($2)!g;  # fractions
  $expr =~ s/\{([^\}]*)\}/($1)/g;                            # TeX parameters
  $expr =~ s/\\//g;                                          # TeX slashes
  $expr =~ s/\^/**/g;                                        # change ^ to **
  #
  #  Do implied multiplication
  #
  $expr =~ s/\)\s*\(/\)*\(/g;
  $expr =~ s/\)\s*([a-zA-Z0-9.])/\)*$1/g;
  $expr =~ s/([\d.])(\s\d)/$1*$2/g;
  $expr =~ s/([\d.])\s*([a-zA-Z\(])/$1*$2/g;
  #
  #  Fix +-, -+, ++ and --
  #
  $expr =~ s/\+\s*([\+-])/$1/g;
  $expr =~ s/-\s*\+/-/g; $expr =~ s/-\s*-/+/g;
  #
  #  Create the named function
  #
  PG_restricted_eval("sub $name { return('$f') unless (\@_);
                      my (".join(',',@X).") = \@_; $expr}");
  warn("sub $name { my (".join(',',@X).") = \@_; $expr}") if $debug;
}

#
#  A hack to pick display mode in HTML modes, but plain math mode
#  in TeX modes.  This makes fractions appear better in HTML mode,
#  without making it worse in TeX modes.  This is for use with
#  AlignedList objects.
#
sub DMATH {
  my $math = shift;
  #
  #  HTML_tth puts an unwanted <BR> at the beginning,
  #  and uses a centered table.  So here we remove the
  #  <BR> and re-align the table to the right.
  #
  if ($displayMode eq "HTML_tth") {
    $math = trimString(EV2('\['.$math.'\]'));
    $math =~ s!<br clear="all" />!!;
    $math =~ s!table align="center"!table align="right"!;
    $math =~ s!(table [^>]*) width="100%"!$1!;
  } elsif ($displayMode eq "HTML") {
    $math = '\('.$math.'\)'
  } elsif ($displayMode =~ m/^HTML/) {
    $math = '\(\displaystyle '.$math.'\)'
  }

  MODES(
    TeX => '\(\displaystyle '.$math.'\)',
    Latex2HTML => '\(\displaystyle '.$math.'\)',
    HTML => $math,
    HTML_tth => $math,
    HTML_dpng => $math,
  );
}

1;
