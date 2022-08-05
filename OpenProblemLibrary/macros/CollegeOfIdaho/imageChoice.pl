################################################################################
# WeBWorK Online Homework Delivery System
# Copyright &copy; 2000-2022 The WeBWorK Project, https://github.com/openwebwork
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of either: (a) the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version, or (b) the "Artistic License" which comes with this package.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See either the GNU General Public License or the
# Artistic License for more details.
################################################################################

=head1 NAME

imageChoice.pl - Provides support for randomly selecting a subset of images from
a given set.

=head1 DESCRIPTION

This is similar to the ChoiceList macro for producing multiple choice problems
however has additional features for images.

To use the scaffolding macros, include the macros into your problem

    loadMacros("imageChoice.pl");

In the preamble of the problem, first define an array of questions and answers
where the answers are images:

    #Define the questions and answers
    @QA = (
    "image 1", "image1.png",
    "image 2", "image2.png",
    "image 3", "image3.png",
    "image 4", "image4.png",
    "image 5", "image5.png",
    "image 6", "image6.png",
    );

Note that the images can be local links (like the above example) or absolute links
where the images can be on a different server.

Next, define the match list.  A default is

    $ml = new_image_match_list();

Often, this is used with popup lists and the following will create these:

    $ml->rf_print_q(~~&pop_up_list_print_q); # use pop-up-lists
    $ml -> ra_pop_up_list([ No_answer=>"?", A=>"A", B=>"B", C=>"C", D=>"D" ] );

    $ml->qa(@QA);               #  set the questions and answers
    $ml->choose(4);             #  select 4 of them

As an example, the main text of the problem (as a PGML block) could look like:

    BEGIN_PGML
    Match the correct image

    [@ $ml -> print_q @]*

    [@ $ml -> print_a @]*
    END_PGML

=head2 new_image_match_list

Makes a new image match list. The following options are valid for an Image (from
the unionImage macro)

=over

=item * C<size => [w,h]>

the width and height of the images

=item * C<width => n>

the width of the images (obsolete)

=item * C<height => n>

the height of the images (obsolete)

=item * C<tex_size => n>

the size for the TeX version of the image

=item * C<separation => n>

the spacing between the images in a row

=item * C<vseparation => n>

the spacing between the images and captions

=item * C<link => 0>

or 1     1 to make a link to the original image

=item * C<columns => n>

the number of images in each row (defaults to 4)

=item * C<border => n>

the width of the image border

=item *C<extra_html_tags => str>

where C<str> is a string containing any extra html tags to the image tag.  This
is often used for alt tags.

=back

=cut

loadMacros(
  'PGchoicemacros.pl',
  "PGunion.pl",
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
  my $extra_html_tags = $options{extra_html_tags};

  # this is the order of the images.  Needed for getting proper extra_html_tags.
  my @sl = @{$self->{slice}};
  my @sh = @{$self->{shuffle}};
  my @image_order = @sl[@sh];

  my $border = $options{border}; $border = ($link?2:1) unless defined($border);
  my $HTML; my @images = (); my @labels = (); my $i = 0;
  my $out;

  $out = BeginTable(tex_spacing => "5pt", tex_border => "5pt");
  while ($image = shift) {
    push(@images,Image(
      $image, size => [$w,$h], tex_size => $tsize,
	      link => $link, border => $border, extra_html_tags => $extra_html_tags->[$image_order[$i]]
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
