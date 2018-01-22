sub _PGgraphgrid_init {}; # don't reload this file

=pod

=head1 NAME

PGgraphgrid.pl

=head1 SYNOPSIS

Provides subroutines plotting a parallelogram grid on a 
graph object created by PGgraphmacros.pl.

=head1 DESCRIPTION

Load the C<PGgraphgrid.pl> macro file.

=over 12

=item C<loadMacros("PGstandard.pl","MathObjects.pl","PGgraphmacros.pl","PGgraphgrid.pl");>

= back

The macro C<PGgraphgrid.pl> provides two different subroutines
for graphing grids: the first one draws the grid using parallel lines
and should be fast, and a second that draws each individual 
parallelogram and should be slow (but will suffer less from clipping):

=over 12

=item C<graphgrid1($gr, $B, $hmin, $vmin, $hmax, $vmax, $color, $linewidth)>

=item C<graphgrid1($gr, $B, $hmin, $vmin, $hmax, $vmax, $color, $linewidth)>

=back

Here C<$gr> is a graph object created by C<PGgraphmacros.pl>, 
C<$B> is a two by two MathObjects matrix, the integers C<$hmin> and 
C<$vmin> specify one corner of the grid, the integers C<$hmax> and 
C<$vmax> specify the opposite corner of the grid, C<$color> is a string
that specifies the drawing color, and C<$linewidth> is a positive integer
for the line width.

=over 12

=head1 AUTHORS

Paul Pearson, Hope College, Department of Mathematics

=cut

################################################

loadMacros("MathObjects.pl","PGgraphmacros.pl",);


sub graphgrid1 {
  # inputs
  my $gr = shift; # graph object
  my $B = shift; # 2x2 basis matrix with B = (b1 | b2), with basis vectors in columns
  my $xmin = shift; my $ymin = shift; my $xmax = shift; my $ymax = shift; # (xmin,ymin) and (xmax,ymax) are two of the corners of the grid (must be integers)
  my $color = shift; # grid color
  my $linewidth = shift; # line thickness

  # standard coordinates for horizontal lines
  my @hx = (); # horizontal lines, x values
  my @hy = (); # horizontal lines, y values
  foreach my $y ($ymin..$ymax) {
    push(@hx, ($xmin,$xmax));
    push(@hy, ($y,$y));
  }
  my $H = Matrix([
  [@hx],
  [@hy]
  ]);
  my $BH = $B * $H;
  my @bh = $BH->value;
  # draw parallelogram grid on graph object
  # "horizontal" lines
  my $bh_ncol = ($BH->dimensions)[1];
  foreach my $i (0..$bh_ncol/2) {
    $gr->moveTo($bh[0][2*$i],$bh[1][2*$i]); $gr->lineTo($bh[0][2*$i+1],$bh[1][2*$i+1],$color,$linewidth);
  }

  # standard coordinates for vertical lines
  my @vx = (); # vertical lines, x values
  my @vy = (); # vertical lines, y values
  foreach my $x ($xmin..$xmax) {
    push(@vx, ($x,$x));
    push(@vy, ($ymin,$ymax));
  }
  my $V = Matrix([
  [@vx],
  [@vy]
  ]);
  my $BV = $B * $V;
  my @bv = $BV->value;
  # draw parallelogram grid on graph object
  # "vertical" lines
  my $bv_ncol = ($BV->dimensions)[1];
  foreach my $i (0..$bv_ncol/2) {
    $gr->moveTo($bv[0][2*$i],$bv[1][2*$i]); $gr->lineTo($bv[0][2*$i+1],$bv[1][2*$i+1],$color,$linewidth);
  }

} # end graphgrid1


sub graphgrid2 {
  # inputs
  my $gr = shift; # graph object
  my $B = shift; # 2x2 basis matrix with B = (b1 | b2), with basis vectors in columns
  my $xmin = shift; my $ymin = shift; my $xmax = shift; my $ymax = shift; # (xmin,ymin) and (xmax,ymax) are two of the corners of the grid (must be integers)
  my $color = shift; # grid color
  my $linewidth = shift; # line thickness

  foreach my $x ($xmin..$xmax) {
    foreach my $y ($ymin..$ymax) {
      my $X = Matrix([
      [$x,$x+1,$x+1,$x,$x],
      [$y,$y,$y+1,$y+1,$y]
      ]);
      my $BX = $B * $X;
      my @bx = $BX->value;
      $gr->moveTo($bx[0][0], $bx[1][0]);
      $gr->lineTo($bx[0][1], $bx[1][1], $color, $linewidth);
      $gr->lineTo($bx[0][2], $bx[1][2], $color, $linewidth);
      $gr->lineTo($bx[0][3], $bx[1][3], $color, $linewidth);
      $gr->lineTo($bx[0][4], $bx[1][4], $color, $linewidth);
    }
  }
} # end graphgrid2

1;
