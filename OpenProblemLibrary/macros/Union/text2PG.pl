######################################################################
#
#  Sanitize a text string for use with TEXT and EV3, so that
#  non-math text is properly displayed in HTML mode and TeX
#  mode.  Newlines and blank lines can be converted to $BR and
#  $PAR automatically.
#
#  Format:  text2PG(stiring[,options]);
#
#  where options are from among:
#
#    trimWhitespace => 0 or 1    Specifies if leading and trailing whitespace
#                                is removed before processing.
#                                  Default: 1
#
#    convertBlanklines => 0 or 1 Specifies whether blank lines should be
#                                turned into paragraph breaks.
#                                  Default: 1
#
#    convertNewlines => 0 or 1   Specifies whether newlines should be
#                                turned into line breaks.
#                                  Default: 1
#
#    sanitizeText => 0 or 1      Specifies whether to convert HTML and TeX
#                                special characters to printable form
#                                outside of math mode and commands.
#                                  Default: 1
#
#    allowCommands => 0 or 1     Specifies if text within command blocks
#                                is left unchanged (1) or not (0).
#                                  Default: 0
#
#    convertDollars => 0 or 1    Specifies whether dollar signs not followed
#                                by a letter should be replaced by ${DOLLAR}
#                                (you only want to do this if not passing
#                                the result through EV3 with variable
#                                substitutions).
#                                  Default: 0
#
#    doubleSlashes => 0 or 1     Specifies whether backslashes should be
#                                doubled (in preparation for passing
#                                into EV3).
#                                  Default: 1
#
sub text2PG {
  my $string = shift; return unless defined($string);
  my %options = (
    trimWhiteSpace => 1,
    convertBlanklines => 1,
    convertNewlines => 1,
    convertDollars => 0,
    sanitizeText => 1,
    allowCommands => 0,
    doubleSlashes => 1,
    @_,
  );
  $string =~ s/\r\n?/\n/g if $options{convertNewlines};  # convert Mac and PC line breaks to unix
  $string =~ s/^\s+|\s+$//g if $options{trimWhitespace};
  my @parts; my $i = 0;
  if ($options{allowCommands}) 
    {@parts = split(/(\\\{.*?\\\}|``.*?``\*?|`.+`\*?|\\\(.*?\\\)|\\\[.*?\\\])/s,$string)}
   else
    {@parts = split(/(``.*?``\*?|`.+`\*?|\\\(.*?\\\)|\\\[.*?\\\])/s,$string)}
  while ($i <= $#parts) {
    if ($options{sanitizeText}) {
      if ($displayMode eq 'TeX') {
	$parts[$i] =~ s/(["\#%&<>\\^_\{\}~])/$text2PG{TeX}{$1}/eg;
      } else {
        $parts[$i] =~ s/&/&amp;/g;
        $parts[$i] =~ s/</&lt;/g;
        $parts[$i] =~ s/>/&gt;/g;
      }
    }
    $parts[$i] =~ s/\$/$DOLLAR/og if $options{convertDollars};
    $parts[$i] =~ s/\n\n+/$PAR/og if $options{convertBlanklines};
    $parts[$i] =~ s/\n/$BR/og if $options{convertNewlines};
    $i += 2;
  }
  $string = join('',@parts);
  $string =~ s/\\/\\\\/g if $options{doubleSlashes};
  return $string;
}

$text2PG{TeX} = {
  '"' => '{\tt\char34}',
  '#' => '{\tt\char35}',
  '$' => '\$',
  '%' => '\%',
  '&' => '\&',
  '<' => '{\tt\char60}',
  '>' => '{\tt\char62}',
  '\\' => '{\tt\char92}',
  '^' => '{\tt\char94}',
  '_' => '\_',
  '{' => '{\tt\char123}',
  '}' => '{\tt\char125}',
  '~' => '{\tt\char126}',
};

1;
