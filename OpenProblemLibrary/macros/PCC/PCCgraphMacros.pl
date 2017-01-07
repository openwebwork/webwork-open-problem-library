=head1 NAME

PCCgraphMacros.pl - A collection of tools found to be useful for graphs during the development of the PCC problem library.

=head1 DESCRIPTION

This file implements graphing subroutines developed for use in problems originally developed for a PCC problem library

To use it, load the macro file:

	loadMacros(
	  "PGstandard.pl",
	  "MathObjects.pl",
	  "PCCgraphMacros.pl",
	);


=cut

###############################
#Some standard values
################################
sub xPixels{400;} #number of hor pixels in the graph object

sub yPixels{400;} #number of ver pixels in the graph object

sub xScreen{400;} #number of hor pixels used on screen

sub yScreen{400;} #number of ver pixels used on screen

sub TeXscalar{400;} #400=>image is at 40.0% in hardcopy

sub EnlargeImageStatementPGML{MODES(TeX => '', Latex2HTML => '', HTML => 'If you would like to enlarge the graph or make numbers and letters easier to read, you may click on it to open it in a new window. You may then enlarge that window with your mouse. To further enlarge the image, use your browser\'s zoom capabilities. On a PC this is usually *ctrl shift +* (and zooming out is *ctrl -*). On an Apple computer this is usually *apple shift +* (and zooming out is *apple -*).');};

sub EnlargeImageStatement{MODES(TeX => '', Latex2HTML => '', HTML => 'If you would like to enlarge the graph or make numbers and letters easier to read, you may click on it to open it in a new window. You may then enlarge that window with your mouse. To further enlarge the image, use your browser\'s zoom capabilities. On a PC this is usually $BBOLD ctrl shift +$EBOLD (and zooming out is $BBOLD ctrl -$EBOLD). On an Apple computer this is usually $BBOLD apple shift +$EBOLD (and zooming out is $BBOLD apple -$EBOLD).');};

###############################
#Name: NiceGraphParameters
#Input: References to two arrays: one with all the x "action" in a graph, the other with the y "action"
#Optional Input: centerOrigin, centerXaxis, centerYaxis, buffer, roughTickNum, roughTickNumX, roughTickNumY
#Output: A reference to an array (xmin, xmax, ymin, ymax, xticknumber, yticknumber). These parameters will make a nice looking scale for a graph that captures all of the x and y data. 
################################
sub NiceGraphParameters{
  my $xact = shift;
  my $yact = shift;
  my %options = @_;
  my @xaction = @{$xact};
  my @yaction = @{$yact};

  if ($options{centerYaxis} or $options{centerOrigin}) 
    {my @temp = ();
     for my $i (@xaction)
      {push(@temp, -$i);}
     @xaction = (@xaction,@temp);
    }

  if ($options{centerXaxis} or $options{centerOrigin}) 
    {my @temp = ();
     for my $i (@yaction)
      {push(@temp, -$i);}
     @yaction = (@yaction,@temp);
    }

  my(@max, @min);
  $max[0] = max(@xaction);
  $min[0] = min(@xaction);
  $max[1] = max(@yaction);
  $min[1] = min(@yaction);

  my @roughTickNum;
  $roughTickNum[0] = 10;
  $roughTickNum[1] = 10;
  for my $i (0,1) {$roughTickNum[$i] = $options{roughTickNum} if (defined $options{roughTickNum});};
  $roughTickNum[0] = $options{roughTickNumX} if (defined $options{roughTickNumX});
  $roughTickNum[1] = $options{roughTickNumY} if (defined $options{roughTickNumY});

  my $buffer = 1.618;
  $buffer = $options{buffer} if (defined $options{buffer});

  my (@center, @left, @right, @tickexp, %tickcoefs, @tickcoef, @marksep, @ticknum, @scale);
  for my $i (0,1) {
     $center[$i] = ($max[$i]+$min[$i])/2;
     $low[$i] = $center[$i]+$buffer*($min[$i]-$center[$i]);
     $high[$i] = $center[$i]+$buffer*($max[$i]-$center[$i]);
     $tickexp[$i] = round(log(($high[$i]-$low[$i])/$roughTickNum[$i])/log(10));
     %tickcoefs = ();
     %tickcoefs = (
       .2 => abs(.2*10**$tickexp[$i]-($high[$i]-$low[$i])/$roughTickNum[$i]),
       .5 => abs(.5*10**$tickexp[$i]-($high[$i]-$low[$i])/$roughTickNum[$i]),
        1 => abs(1*10**$tickexp[$i]-($high[$i]-$low[$i])/$roughTickNum[$i]),
        2 => abs(2*10**$tickexp[$i]-($high[$i]-$low[$i])/$roughTickNum[$i]),
        5 => abs(5*10**$tickexp[$i]-($high[$i]-$low[$i])/$roughTickNum[$i]));
     $tickcoef[$i] = .2;
     for my $key (keys %tickcoefs)
       {$tickcoef[$i] = $key if ($tickcoefs{$key}<$tickcoefs{$tickcoef[$i]});};
  $marksep[$i] = 10**($tickexp[$i])*$tickcoef[$i];
  $ticknum[$i] = 2*round(($high[$i]-$low[$i])/2/$marksep[$i]);
  $max[$i] = round($high[$i]/$marksep[$i])*$marksep[$i];
  $min[$i] = $max[$i] - $marksep[$i]*$ticknum[$i];
  @temp = ();
  };
  
 my @xticks = map { $min[0] + $marksep[0] * $_ } 1..$ticknum[0]-1;
 my @yticks = map { $min[1] + $marksep[1] * $_ } 1..$ticknum[1]-1;

  return ($min[0], $max[0], $min[1], $max[1], $ticknum[0], $ticknum[1], \@xticks, \@yticks, $marksep[0], $marksep[1]);
}

1;
