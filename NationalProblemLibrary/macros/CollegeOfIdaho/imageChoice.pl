loadMacros(
  'PGchoicemacros.pl',
  'unionUtils.pl',
  'choiceUtils.pl',
);

sub _imageChoice_init {}; # don't reload this file

######################################################################
#
#  Create a match list where the answers are images
#
#  Usage:  $ml = new_image_match_list(options);
#
#  where options are those that can be supplied to image_print_a below.
#  The answers should be an image name or reference to to a plot object
#  (or a reference to a pair of either of these), and they are passed
#  to the Image function for processing.  See unionUtils.pl for more
#  information on how these are handled.
#
sub new_image_match_list {
  my $ml = new Match(random(1,2000,1), \&alt_print_q, \&img_print_a);
  $ml->{ImageOptions} = [@_];
  $ml;
}

######################################################################
#
#  A print routine for image matching.  This is designed to display
#  four graphs per row.  More can be included by setting the ImageOptions
#  variable in the match list.  For example:
#
#      $ml->{ImageOptions} = [size => [100,100]]
#
#  You can include the following options:
#
#    size => [w,h]      the width and height of the images
#    width => n         the width of the images (obsolete)
#    height => n        the height of the images (obsolete)
#    tex_size => n      the size for the TeX version of the image
#    separation => n    the spacing between the images in a row
#    vseparation => n   the spacing between the images and captions
#    link => 0 or 1     1 to make a link to the original image
#    columns => n       the number of images in each row (defaults to 4)
#    border => n        the width of the image border
#

sub img_print_a {
  my $self = shift;
  $self->{ImageOptions} = [] unless defined($self->{ImageOptions});
  my %options = (
     width => 150, height => 150, tex_size => 200, columns => 4,
     separation => 15, vseparation => 5, link => 0, @{$self->{ImageOptions}});
  my ($w,$h,$m) = ($options{width},$options{height},$options{columns});
     ($w,$h) = @{$options{size}} if defined($options{size});
  my ($sep,$vsep) = ($options{separation},$options{vseparation});
  my ($tsize,$link) = ($options{tex_size},$options{link});
  my $border = $options{border}; $border = ($link?2:1) unless defined($border);
  my $HTML; my @images = (); my @labels = (); my $i = 0;
  my $out;

  $out = BeginTable(tex_spacing => "5pt", tex_border => "5pt");
  while ($image = shift) {
    push(@images,Image(
      $image, size => [$w,$h], tex_size => $tsize,
	      link => $link, border => $border
    ));
    push(@labels,MODES(
      TeX => "\\hfil \\textbf{$main::ALPHABET[$i]}",
      Latex2HTML=>$bHTML."<CENTER><B>$main::ALPHABET[$i]</B></CENTER>".$eHTML,
      HTML => "<CENTER><B>$main::ALPHABET[$i]</B></CENTER>"
    ));
    if ((++$i % $m) == 0) {
      $out .= TableSpace(2*$vsep,6) if ($i > $m);
      $out .= Row([@images], separation => $sep).
	      TableSpace($vsep,0).
	      Row([@labels], separation => $sep);
      @images = (); @labels = ();
    }
  }
  if (scalar(@images) > 0) {
    $out .= TableSpace(2*$vsep) if ($i > $m && $displayMode ne "TeX");
    $out .= Row([@images], separation => $sep).
            TableSpace($vsep,0).
	    Row([@labels], separation => $sep);
  }
  $out .= EndTable(tex_border => "5pt");
  $out;
}

1;
