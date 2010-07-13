loadMacros(
  'PGchoicemacros.pl',
  'unionUtils.pl',
  'choiceUtils.pl',
);

sub _alignedChoice_init {}; # don't reload this file

######################################################################
#
#  Prints questions with the answer rule at the right, all aligned.
#  (for use by AlignedList object below)
#
sub aligned_print_q {
  my $self = shift;
  my (@questions) = @_;
  my $length = $self->{ans_rule_len};
  my ($numbered,$equals) = ($self->{numbered},$self->{equals});
  my ($valign,$align) = ($self->{valign},$self->{align});
  my ($sep,$tsep) = ($self->{spacing},$self->{tex_spacing});
  my ($rsep) = ($self->{row_spacing});
  my $i=1; my $quest; my $rest;

  my $out = "";
  if ($main::displayMode =~ m/^HTML/) {
    $out = "\n<P>\n<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=$sep>\n";
    foreach $quest (@questions) {
      if (ref($quest) eq 'ARRAY') {($quest,$rest) = @{$quest}} else {$rest = ''}
      $out .= "<TR VALIGN=$valign>";
      $out .= "<TD><B>" . $i++ . ".</B> &nbsp;</TD>" if ($numbered);
      $out .= "<TD ALIGN=$align>$quest</TD>";
      $out .= "<TD>=</TD>" if ($equals);
      $out .= "<TD>" . ans_rule($length) . $rest . "</TD></TR>\n";
      $out .= "<TR><TD HEIGHT=\"$rsep\"></TD></TR>\n" if ($rsep);
    }
    $out .= "</TABLE>\n";
  } elsif ($main::displayMode eq 'Latex2HTML') {
    $out = "\\par\n\\begin{rawhtml}".
      "<TABLE BORDER=0 CELLSPACING=$sep CELLPADDING=0>\\end{rawhtml}\n";
    foreach $quest (@questions) {
      if (ref($quest) eq 'ARRAY') {($quest,$rest) = @{$quest}} else {$rest = ''}
      $out .= "\\begin{rawhtml}<TR VALIGN=$valign>";
      $out .= "<TD VALIGN=MIDDLE><B>".$i++.".</B>&nbsp;</TD>" if ($numbered);
      $out .= "<TD ALIGN=$align>\\end{rawhtml}$quest\\begin{rawhtml}</TD>";
      $out .= "<TD>=</TD>" if ($equals);
      $out .= "<TD>\\end{rawhtml}".ans_rule($length).$rest.
	"\\begin{rawhtml}</TD></TR>\\end{rawhtml}";
      $out .= "\\begin{rawhtml}<TR><TD HEIGHT=\"$rsep\"></TD></TR>\\end{rawhtml}\n" if ($rsep);
    }
    $out .= "\\begin{rawhtml}</TABLE>\n\\end{rawhtml}";
  } elsif ($main::displayMode eq 'TeX') {
    my $num = ''; $num = 'r' if ($numbered);
    my $algn = 'r'; $algn = 'l' if (uc($align) eq "LEFT");
    $algn = 'c' if (uc($align) eq "CENTER");
    $algn .= "c" if ($equals);
    $out = "\n\\par\\begin{tabular}{${num}${algn}l}\n";
    foreach $quest (@questions) {
      if (ref($quest) eq 'ARRAY') {($quest,$rest) = @{$quest}} else {$rest = ''}
      $out .= $i++ . ".\\ &" if ($numbered);
      $out .= $quest . "&";
      $out .= "=&" if ($equals);
      $out .= "\\ ". ans_rule($length) . $rest . "\\\\ \\noalign{\\kern $tsep}\n";
    }
    $out .= "\\end{tabular}\n";
  } else {
    $out = "Error: std_aligned_print_q: Unknown displayMode: ".
      $main::displayMode;
  }
  $out;
}

######################################################################
#
#  Genarate a new AlignedList object
#
#     $al = new_aligned_list(options)
#
#  Where "options" can be taken from among:
#
#      valign => "placement"     Sets the vertical alignment for the table
#                                (default is valign => "MIDDLE")
#
#      align => "placement"      Sets the horizontal aligmnent for the first
#                                column of the table
#                                (default is align => "RIGHT")
#
#      spacing => n              Sets the CELLSPACING value for the table
#                                (default is spacing => 5)
#
#      tex_spacing => dimen      Extra spacing between rows
#                                (default is tex_spacing => "0pt")
#
#      numbered => 1 or 0        1 means the problems should be numbered.
#                                0 means no numbers for the problems.
#
#      equals => 1 or 0          1 means include a column of equal signs between
#                                  the questions and the answer blocks.
#                                0 means no column of equals.
#
#      ans_rule_len => n         Sets the length of the answer rule
#
#
sub new_aligned_list {
  new AlignedList(random(1,2000,1), \&aligned_print_q, \&std_print_a, @_);
}

package AlignedList;

@AlignedList::ISA = qw( ChoiceList );

sub new {
    my $type = shift;
    my ($rnd,$pq,$pa,@params) = @_;
    my $self = ChoiceList->new($rnd,$pq,$pa);
    $self = bless $self, $type;
    my ($var,$val);
    @params = (
        valign => "MIDDLE",
	align => "RIGHT",
        numbered => 0,
        equals => 1,
        ans_rule_len => 10,
        spacing => 5,
        tex_spacing => "0pt",
        @params
    );
    while (@params) {
	$var = shift(@params); $val = shift(@params);
	$self->{$var} = $val;
    }
    return $self;
}

sub qa {
    my $self = shift;
    $self->SUPER::qa(@_);
    my $n = scalar(@{$self->{questions}});
    $self->{selected_q} = [@{$self->{questions}}];
    $self->{selected_a} = [@{$self->{answers}}];
    $self->{slice} = [0..$n];
    $self->{shuffle} = [0..$n];
    $self->{inverted_shuffle} = [0..$n];
}

sub selectQA {
    my $self = shift;
    $self->{selected_q} = [@{$self->{questions}}[@{$self->{slice}}]];
    $self->{selected_a} = [@{$self->{answers}}[@{$self->{slice}}]];
    $self->{shuffle} = [0..scalar(@{$self->{slice}})];
    $self->{inverted_shuffle} = [0..scalar(@{$self->{slice}})];
}

sub correct_ans {
  my $self = shift;
  return @{$self->{selected_a}}
}

1;
