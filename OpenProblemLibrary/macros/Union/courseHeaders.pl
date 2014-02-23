#!/usr/local/bin/perl 

sub _courseHeaders_init {
#
#  This is the hint to display in screen headers.  You can change this
#  in the specific header .pg file for a problem set, provided you do so
#  after the call to loadMacros that loads this file.
#

$HINT =
  "Give 4 or 5 significant digits when entering decimal numbers.  ".
  "For most problems, you can enter elementary expressions such as ".
  "${BTT}2^3${ETT} instead of ${BTT}8${ETT}, ${BTT}sin(3pi/2)${ETT} ".
  "instead of ${BTT}-1${ETT}, ${BTT}e^(ln(2))${ETT} instead of ${BTT}2${ETT}, ".
  "${BTT}(2+tan(3))*(4-sin(5))^6-7/8${ETT} instead of ${BTT}27620.3413${ETT}, ".
  "etc.  Consult WeBWorK's ".
    htmlLink('http://webwork.math.rochester.edu/webwork_system_html/docs/docs/pglanguage/availablefunctions.html','list of functions').
  " or review the problems in the orientation homework set for more ".
  "information on the functions and values that WeBWorK understands.";

};

######################################################################
#
#  This file implements a standard format for the screen and paper
#  headers.  The same file works for both, so there is no need to
#  make duplicate files.  See courseHeader() below for details.
#

loadMacros(
  "PG.pl",
  "PGbasicmacros.pl",
  "PGunion.pl"
);

#
#  Get the course name from the course ID
#
$course = $courseName;
$course =~ s/\d\d(FA|WI|SP|SU)-//;                # Union-sepcific
$course =~ s/-.*//;                               # Union-specific
$course = protect_underbar($course);  # just in case

#
#  Set some variables to use in headers
#
$dateTime = $formatedDueDate;
$sectionNumber = protect_underbar($sectionNumber);
$setNumber = protect_underbar($setNumber);

#
#  Evaluate the string as in PG, then trim white space from the ends
#
sub EV_trim {
  my $string = EV2(@_);
  $string =~ s/(^\s+|\s+$)//g;
  return $string;
}

#
#  Get a number sign in all modes
#
$NUMBER = MODES(TeX => '\#', HTML => '#');

#
#  couseHeader creates the header based on values passed to it.
#  It works for both screen and paper headers, so you only need
#  one header file.  The options you can pass it are:
#
#      topic => '...'      a short string to be used in
#                          "this is an assignment on ..."
#
#      preposition => 'on'
#                          what word to use before the topic
#
#      bookinfo => '...'   the section of the book to refer to for more
#                          information.
#
#      bookprobs => ['...','...',]
#                          a list of strings giving problems from
#                          various sections of the book.  As many
#                          strings can be supplied as you want.
#                          They will be placed on separate lines in
#                          the screen header, but on one line in the PDF
#                          file.  If left empty, the word "none" will be
#                          supplied automatically.  If set to undef,
#                          no book problems will be given.
#
#     moreprobs => ['...','...',]
#                          a list of strings giving problems from
#                          various sections of the book.  (See bookprobs
#                          for details of how this works.)
#
#     text => '...'        This is additional text to be inserted
#                          after the book assignment.  It can explain
#                          more about the problems, give hints, etc.
#
#     showhint => 0 or 1   Indicates whether the message about typing
#                          webwork answers should be shown in the screen
#                          header.  It defaults to 1 (yes).
#                          You can change the variable $HINT to be
#                          a different hint, if you want.  Be sure
#                          to do this AFTER the loadMacros call.
#                          
#
sub courseHeader {
  my %ops = (
    topic => "",
    preposition => "on",
    bookinfo => "",
    bookprobs => [],
    moreprobs => undef,
    text => "",
    showhint => 1,

    topic_text => 'This is a collection of WeBWorK problems ',
    bookinfo_text => 'Relevant information can be found in %s of your text.',
    bookprobs_text => 'Book problems to do as part of this assignment:',
    moreprobs_text => 'Additional problems to do with this assignment:',
    @_
  );

  if ($displayMode =~ m/^HTML/ || $displayMode eq "Latex2HTML") {
#    TEXT($BBLOCKQUOTE);
    TEXT(EV_trim($ops{topic_text}.$ops{preposition}.' '.$ops{topic}).".\n") if $ops{topic};
    TEXT(sprintf($ops{bookinfo_text},$ops{bookinfo})) if $ops{bookinfo};
    TEXT($BR,$PAR,"\n\n");
    if (ref($ops{bookprobs}) eq "ARRAY") {
      TEXT($ops{bookprobs_text}."\n");
      if (scalar(@{$ops{bookprobs}}) == 0) {TEXT("none.\n\n")} else {
	TEXT(
	  $BBLOCKQUOTE,
	  EV_trim(join($BR."\n",@{$ops{bookprobs}})),
          $EBLOCKQUOTE,"\n"
        );
      }
      TEXT($PAR,"\n\n");
    }
    if (ref($ops{moreprobs}) eq "ARRAY") {
      TEXT($ops{moreprobs_text}."\n");
      if (scalar(@{$ops{moreprobs}}) == 0) {TEXT("none.\n\n")} else {
	TEXT(
	  $BBLOCKQUOTE,
	  EV_trim(join($BR."\n",@{$ops{moreprobs}})),
          $EBLOCKQUOTE,"\n"
        );
      }
    }
    TEXT($HR,$PAR,EV_trim($ops{text})) if $ops{text};
    TEXT($HR,$PAR."\n\n",$BSMALL.$HINT.$ESMALL."\n\n",$PAR) 
      if ($ops{showhint});
#    TEXT($EBLOCKQUOTE);
  } elsif ($displayMode eq "TeX") {
    TEXT(
      $BEGIN_ONE_COLUMN,
      '{\parindent=0pt \parskip=4pt',"\n",
      '{\large\bf '.$studentName.'\hfill '.$course.' '.$sectionNumber.'}',
      '\break\null\hfill '.
      "WeBWorK assignment $setNumber due $dateTime".'\par'."\n",
    );
    TEXT(EV_trim($ops{topic_text}.$ops{preposition}.' '.$ops{topic}).".\n") if $ops{topic};
    TEXT(sprintf($ops{bookinfo_text},$ops{bookinfo})) if $ops{bookinfo};
    TEXT('\par',"\n\n");
    if (ref($ops{bookprobs}) eq "ARRAY") {
      TEXT($ops{bookprobs_text}.' ');
      if (scalar(@{$ops{bookprobs}}) == 0) {TEXT("none.\\par\n\n")} else {
	TEXT(
          EV_trim(join("; ",@{$ops{bookprobs}})).
          '.\par'."\n\n"
        );
      }
    }
    if (ref($ops{moreprobs}) eq "ARRAY") {
      TEXT($ops{moreprobs_text}.' ');
      if (scalar(@{$ops{moreprobs}}) == 0) {TEXT("none.\\par\n\n")} else {
	TEXT(
          EV_trim(join("; ",@{$ops{moreprobs}})).
          '.\par'."\n\n"
        );
      }
    }
    TEXT(EV_trim($ops{text}).'\par'."\n\n") if $ops{text};
    TEXT('\par}',$END_ONE_COLUMN);
  } else {
    warn "courseHeader: Unknown display mode: $displayMode"
  }
}

1;
