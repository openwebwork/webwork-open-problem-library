sub _EV3P_init {}

######################################################################
#
#  New version of EV3 that allows `...` and ``...`` to insert TeX produced
#  by the new Parser (in math and display modes).
#
#  Format:  EV3P(string,...);
#           EV3P({options},string,...);
#
#  where options can include:
#
#    processCommands => 0 or 1     Indicates if the student's answer will
#                                  be allowed to process \{...\}.
#                                    Default: 1
#
#    processVariables => 0 1       Indicates whether variable substitution
#                                  should be performed on the student's
#                                  answer.
#                                    Default: 1
#
#    processMath => 0 or 1         Indicates whether \(...\), \[...\],
#                                  `...` and ``...`` will be processed
#                                  in the student's answer.
#                                    Default: 1
#
#    processParser => 0 or 1       Indicates if `...` and ``...`` should
#                                  be processed when math is being
#                                  processed.
#                                    Default: 1
#
#    fixDollars => 0 or 1          Specifies whether dollar signs not followed
#                                  by a letter should be replaced by ${DOLLAR}
#                                  prior to variable substitution (to prevent
#                                  accidental substitution of strange Perl
#                                  values).
#                                    Default: 1
#
sub EV3P {
  my $option_ref = {}; $option_ref = shift if ref($_[0]) eq 'HASH';
  my %options = (
    processCommands => 1,
    processVariables => 1,
    processParser => 1,
    processMath => 1,
    fixDollars => 1,
    %{$option_ref},
  );
  my $string = join(" ",@_);
  $string = ev_substring($string,"\\\\{","\\\\}",\&safe_ev) if $options{processCommands};
  if ($options{processVariables}) {
    my $eval_string = $string;
    $eval_string =~ s/\$(?![a-z])/\${DOLLAR}/gi if $options{fixDollars};
    my ($evaluated_string,$PG_eval_errors,$PG_full_errors) = 
      PG_restricted_eval("<<END_OF_EVALUATION_STRING\n$eval_string\nEND_OF_EVALUATION_STRING\n");
    if ($PG_eval_errors) {
      my $error = (split("\n",$PG_eval_errors))[0]; $error =~ s/at \(eval.*//gs;
      $string =~ s/&/&amp;/g; $string =~ s/</&lt;/g; $string =~ s/>/&gt;/g;
      $evaluated_string = $BBOLD."(Error: $error in '$string')".$EBOLD;
    }
    $string = $evaluated_string;
  }
  if ($options{processMath}) {
    $string = EV3P_parser($string) if $options{processParser};
    $string = ev_substring($string,"\\(","\\)",\&math_ev3);
    $string = ev_substring($string,"\\[","\\]",\&display_math_ev3);
  }
  return $string;
}

#
#  Look through a string for ``...`` or `...` and use
#  the parser to produce TeX code for the specified mathematics.
#  ``...`` does display math, `...` does in-line math.  They
#  can also be used within math mode already, in which case they
#  use whatever mode is already in effect.
#
sub EV3P_parser {
  my $string = shift;
  return $string unless $string =~ m/`/;
  my $start = ''; my %end = ('\('=>'\)','\['=>'\]');
  my @parts = split(/(``.*?``\*?|`.+?`\*?|(?:\\[()\[\]]))/s,$string);
  foreach my $part (@parts) {
    if ($part =~ m/^(``?)(.*)\1(\*?)$/s) {
      my ($delim,$math,$star) = ($1,$2,$3);
      my $f = Parser::Formula($math);
      if (defined($f)) {
        $f = $f->reduce if $star;
	$part = $f->TeX;
	$part = ($delim eq '`' ? '\('.$part.'\)': '\['.$part.'\]') if (!$start);
      } else {
	## FIXME:  use context->{error}{ref} to highlight error in $math.
	$part = $BBOLD."(Error: $$Value::context->{error}{message} '$math')".$EBOLD;
	$part = $end{$start}." ".$part." ".$start if $start;
      }
    }
    elsif ($start) {$start = '' if $part eq $end{$start}}
    elsif ($end{$part}) {$start = $part}
  }
  return join('',@parts);
}

1;
