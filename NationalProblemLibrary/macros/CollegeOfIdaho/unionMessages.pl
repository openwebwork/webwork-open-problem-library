sub _unionMessages_init {};

loadMacros("unionMacros.pl");

######################################################################
#
#  How to say "infinity"
#

$INFINITY_WORD = $$Value::context->flag('infiniteWord') unless defined($INFINITY_WORD);

######################################################################
#
#  A message that can be included (within BEGIN_TEXT and END_TEXT)
#  to tell the student how to enter infinity and minus infinity.
#
$INFINITY_MESSAGE =
  $BITALIC.$BSMALL.
  "Use ${LQ}$INFINITY_WORD${RQ} for $LQ\\(\\infty\\)$RQ ".
  "and ${LQ}-$INFINITY_WORD${RQ} for $LQ\\(-\\infty\\)$RQ." .
  $ESMALL.$EITALIC;

$INFINITY_MESSAGE = "" if $displayMode eq 'TeX';

######################################################################
#
#  A message to tell students how to enter "Does not exist".
#
$DNE_MESSAGE =
  $BITALIC.$BSMALL.
  "Use ${LQ}DNE${RQ} for ${LQ}Does not exist${RQ}.".
  $ESMALL.$EITALIC;

$DNE_MESSAGE = ""      if $displayMode eq 'TeX';

######################################################################
#
#  A message to tell students how to enter unions and infinities
#
$INFINITY_UNION_MESSAGE =
  "${BSMALL}${BBOLD}Note:${EBOLD} ".
  "If the answer includes more than one interval, write the intervals ".
  "separated by the ${LQ}union$RQ symbol, ${BITALIC}U${EITALIC}. If needed, enter ".
  "\\(\\infty\\) as ${BITALIC}$INFINITY_WORD${EITALIC} and \\(-\\infty\\) as ".
  "${BITALIC}-$INFINITY_WORD${EITALIC}.${ESMALL}";

$INFINITY_UNION_MESSAGE = "" if $displayMode eq 'TeX';

######################################################################
#
#  A message to tell students how to enter lists of intervals
#
$INTERVAL_LIST_MESSAGE = 
  $BSMALL.$BBOLD."Note:".$EBOLD.
  "Your answer should be a list of one or more intervals separated by commas.  ".
  "Enter ${BITALIC}NONE${EITALIC} if there are no intervals.";

$INTERVAL_LIST_MESSAGE = "" if $displayMode eq 'TeX';

######################################################################
#
#  A message for lists of unions
#
$UNION_LIST_MESSAGE =
  $BSMALL.$BBOLD."Note:".$EBOLD.
  "Your answer should be a list of one or more intervals or unions of intervals.  ".
  "Separate the entries in your list by commas.  ".
  "Enter ${BITALIC}NONE${EITALIC} if there are no intervals or unions.";

$UNION_LIST_MESSAGE = "" if $displayMode eq 'TeX';

1;
