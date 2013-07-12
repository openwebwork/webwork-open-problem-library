loadMacros("unionMacros.pl");

sub _unionImage_init {}; # don't reload this file

######################################################################
#
#  A routine to make including images easier to control
#
#  Usage:  Image(name,options)
#
#  where name is the name of an image file or a reference to a
#  graphics object (or a reference to a pair of one of these),
#  and options are taken from among the following:
#
#    size => [w,h]           the size of the image in the HTML page
#                            (default is [150,150])
#
#    tex_size => r           the size to use in TeX mode (as a percentage
#                            of the line width times 10).  E.g., 500 is 
#                            half the width, etc.  (default is 200.)
#
#    link => 0 or 1          whether to include a link to the original
#                            image (default is 0, unless there are
#                            two images given)
#
#    border => 0 or 1        size of image border in HTML mode
#                            (defaults to 2 or 1 depending on whether
#                            there is a link or not)
#
#    align => placement      vertical alignment for image in HTML mode
#                            (default is "BOTTOM")
#
#    tex_center => 0 or 1    whether to center the image horizontally
#                            in TeX mode  (default is 0)
#
#  The image name can be one of a number of different things.  It can be
#  the name of an image file, or an alias to one produce by the alias()
#  command.  It can be a graphics object reference created by init_graph().
#  Or it can be a pair of these (in square brackets).  The first is the
#  image for the HTML file, and the second is the image that it will be
#  linked to.
#
#  Examples:  Image("graph.gif", size => [200,200]);
#             Image(["graph.gif","graph-large.gif"]);
#
#  The alias() and insertGraph() functions will be called automatically
#  when needed.
#
sub Image {
  my $image = shift; my $ilink;
  my %options = (
    size => [150,150], tex_size => 200,
    link => 0, align => "BOTTOM", tex_center => 0, @_);
  my ($w,$h) = @{$options{size}};
  my ($ratio,$link) = ($options{tex_size}*(.001),$options{link});
  my ($border,$align) = ($options{border},$options{align});
  my ($tcenter) = $options{tex_center};
  my $HTML; my $TeX;
  ($image,$ilink) = @{$image} if (ref($image) eq "ARRAY");
  $image = alias(insertGraph($image)) if (ref($image) eq "WWPlot");
  $image = alias($image) unless ($image =~ m!^(/|https?:)!i); # see note
  if ($ilink) {
    $ilink = alias(insertGraph($ilink)) if (ref($ilink) eq "WWPlot");
    $ilink = alias($ilink) unless ($ilink =~ m!^(/|https?:)!i); # see note
  } else {$ilink = $image}
  #
  # Note: These cases were added to handle the examples where the 
  # $image tag has a full url -- in practice this arises when using lighttpd 
  # to server images from a different port
  # e.g. http://hosted2.webwork.rochester.edu:8000/webwork2_course_files/....
  # A smarter implementation of alias might make this check unnecessary
  #
  $border = (($link || $ilink ne $image)? 2: 1) unless defined($border);
  $HTML = '<IMG SRC="'.$image.'" WIDTH="'.$w.
          '" HEIGHT="'.$h.'" BORDER="'.$border.'" ALIGN="'.$align.'">';
  $HTML = '<A HREF="'.$ilink.'">'.$HTML.'</A>' if $link or $ilink ne $image;
  $TeX = '\includegraphics[width='.$ratio.'\linewidth]{'.$image.'}';
  $TeX = '\centerline{'.$TeX.'}' if $tcenter;
  MODES(
    TeX => $TeX."\n",
    Latex2HTML => $bHTML.$HTML.$eHTML,
    HTML => $HTML
  );
}

1;
