######################################################################
##
##  Functions used to make <UL> and <OL> lists in HTML files
##  and corresponding lists in TeX mode.
##
##    BeginList()             starts a list
##    $ITEM                   start a list item
##    $ITEMSEP                puts spacing between items
##    EndList()               ends a list
##
##    BeginParList()          starts a list of paragraphs
##    EndParList()            ends such a list
##

sub _unionLists_init {}; # don't reload this file

=head2 unionLists.pl

 ######################################################################
 #
 #  Usage:  BeginList(type,options);
 #
 #  Produces <OL> and <UL> lists.  Type must be either "OL" or "UL",
 #  (and defaults to "OL").  The options are
 #
 #    type => "type"            Specifies the type of marker
 #                              (default is none specified)
 #
 #    value => num or string    Specified the initial value of the
 #                              item numbering
 #
 #    tex_par => 1 or 0         Set paragraph spacing in TeX mode
 #                              (default is 0)
 #
 #    noTopSkip => 1 or 0       Remove top skip produced by enumerate
 #                              in TeX mode
 #                              (default is 0)
 #
 #  Example:
 #
 #    BEGIN_TEXT
 #      \{BeginList("OL")\}
 #      $ITEM This is the first item
 #      $ITEM This is the second
 #      \{EndList("OL")\}
 #    END_TEXT
 #
 #
 #  Usage:  EndList(type)
 #
 #  where type is the list type (and must match the BeginList type).
 #
 
 
 
=cut

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

1;
