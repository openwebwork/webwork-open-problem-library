sub _altPlotMacros_int {};   # don't reload this file

#
#  An alternative to plot_functions that allows any perl
#  expression as the function (it doesn't get parsed by
#  the PG function parser, so you can do fancier
#  expressions; in particular, things like f(x,y))
#
#  This is just a hack, as it doesn't really parse the
#  expression, so might not translate everything properly.
#  It will be obsolete when I finish my new expression
#  parser, but I needed it to handle traces of multivariable
#  functions easier.  --- DPVC
#

sub alt_plot_functions {
  my $graph = shift;
  my @function_list = @_;
  my $error = "";
  $error .= "The first argument to plot_functions must be a graph object" unless ref($graph) =~/WWPlot/;
  my $fn;
  my @functions=();
  foreach $fn (@function_list) {

  # model:   "2.5-x^2 for x in <-1,0> using color:red and weight:2"
    if ($fn =~ /^(.+)for\s*(\w+)\s*in\s*([\(\[\<])\s*([\d\.\-]+)\s*,\s*([\d\.\-]+)\s*([\)\]\>])\s*using\s*(.*)$/ )  {
      my ($rule,$var, $left_br, $left_end, $right_end, $right_br, $options) =
	($1, $2, $3, $4, $5, $6, $7);
      my %options = split( /\s*and\s*|\s*:\s*|\s*,\s*|\s*=\s*|\s+/,$options); 
      my ($color, $weight);
      if ( defined($options{'color'})  ){
	$color = $options{'color'}; #set pen color
      }	else {
	$color = 'default_color';
      }
      if ( defined($options{'weight'}) ) {
	$weight = $options{'weight'}; # set pen weight (width in pixels)
      } else {
	$weight = 2; 
      }
      
      my $subRef = alt_string_to_sub($rule,$var);
      my $funRef = new Fun($subRef,$graph);
      $funRef->color($color);
      $funRef->weight($weight);
      $funRef->domain($left_end , $right_end);
      push(@functions,$funRef);
      # place open (1,3) or closed (1,3) circle at the endpoints or do nothing <1,3>
      if ($left_br eq '[' ) {
	$graph->stamps(closed_circle($left_end,&$subRef($left_end),$color) );
      } elsif ($left_br eq '(' ) {
	$graph->stamps(open_circle($left_end, &$subRef($left_end), $color) );
      } 
      if ($right_br eq ']' ) {
	$graph->stamps(closed_circle($right_end,&$subRef($right_end),$color) );
      } elsif ($right_br eq ')' ) {
	$graph->stamps(open_circle($right_end, &$subRef($right_end), $color) );
      } 
      
    } else {
      $error .= "Error in parsing: $fn";
    }
    
  }
  die ("Error in plot_functions:\n\t $error") if $error;
  @functions;   # return function references unless there is an error.
}

#
#  A cheap way to convert a string to a perl function
#  that returns the value of the expression given in the
#  string.  Since no special parsing is done, you need
#  to make sure your function is essentially in perl
#  form.
#
sub alt_string_to_sub {
  my $expr = my_math_constants(shift);
  my $x = shift;
  #
  #  Give the variable a $ and rename it with an leading underscore
  #
  $expr =~ s/(\b|\d)$x\b/$1(\$_x)/g;
  #
  #  Fix up the expression
  #
  $expr =~ s!\\frac\{([^\}]*)\}\s*\{([^\}]*)\}!($1)/($2)!g;  # fractions
  $expr =~ s/\{([^\}]*)\}/($1)/g;                            # TeX parameters
  $expr =~ s/\\//g;                                          # TeX slashes
  $expr =~ s/\^/**/g;                                        # change ^ to **
  #
  #  Do implied multiplication
  #
  $expr =~ s/\)\s*\(/\)*\(/g;
  $expr =~ s/\)\s*([a-zA-Z0-9.])/\)*$1/g;
  $expr =~ s/([\d.])(\s\d)/$1*$2/g;
  $expr =~ s/([\d.])\s*([a-zA-Z\(])/$1*$2/g;
  #
  #  Fix +-, -+, ++ and --
  #
  $expr =~ s/\+\s*([\+-])/$1/g;
  $expr =~ s/-\s*\+/-/g; $expr =~ s/-\s*-/+/g;
  #
  #  Make the function
  #
  PG_restricted_eval "sub {my \$_x = shift; return $expr}";
}

1;
