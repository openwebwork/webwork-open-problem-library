loadMacros("PGnauGraphics.pl",      
          );      

#######################################################################################################
#
# Name : DrawVenn2
#
# Input		:	
#
#			$input_word 	=	'region1_info, region2_info, ...'
#						The information to use, arranged in order by region.
#						Use "_fill_" to shade the corresponding region, otherwise
#						the input is treated as label.
#
#			@options	=	'Arrow indicated options' in any order.
#						
#						  labels=>'Set1 label, Set2 label, U'.  Set1 is on the
#							  left.  Leaving any or all entries blank will
#							  produce no label for that item.  Default is
#							  'A,B,U'
#
# Output 	:	$diagram   	= 	a graphics object, the diagram to plot.  Use 'Plot' in the
#						.pg file. 
#
########################################################################################################
sub DrawVenn2{
  my (@input_word)=@_;
  my ($i, $xlower, $xupper, $ylower, $yupper, $diagram, $window_scale, $axis_label, $margin, $radius,
      $x1, $y1, $x2, $y2, $label_string, @labels, $optional_labels, $this_x, $this_y, @input, $templ,
      $tempu, $tempr2);
  
  # check for optional labels;
  $i = 0;
  while ($i < scalar @input_word - 1){
    if ($input_word[$i] eq "labels"){
      $optional_labels = 1;
      $label_string = $input_word[$i+1];
      splice (@input_word, $i, 2);
      $label_string =~ s/ //g;
      @labels = split ",", $label_string;
    }
    $i++;
  }
  if (!$optional_labels){@labels = ('A','B','U');}
  @input = split ",", $input_word[0];
  for ($i = 0; $i < scalar @input; $i++){
    $input[$i] =~ s/ //g;
  }      
  $margin = 5;
  $xlower = -$margin;
  $xupper = 100 + $margin;
  $ylower = -$margin;
  $yupper = 2/3*(($xupper-$margin)-($xlower+$margin)) + $margin;
  $window_scale = 3.5;
  $diagram = init_graph($xlower, $ylower, $xupper, $yupper, 'pixels'=>[$window_scale*($xupper-$xlower),$window_scale*($yupper-  $ylower)]);
  $diagram-> moveTo($xlower+$margin,$ylower+$margin);
  $diagram-> lineTo($xupper-$margin,$ylower+$margin);
  $diagram-> lineTo($xupper-$margin,$yupper-$margin);
  $diagram-> lineTo($xlower+$margin,$yupper-$margin);
  $diagram-> lineTo($xlower+$margin,$ylower+$margin);
  $axislabels = new Label(95, 7, $labels[2], 'black', 'center', 'center');
  $diagram-> lb($axislabels);
  $radius = ($xupper -$xlower - 2 * $margin)/4;
  $x1 = ($xupper -$xlower - 2 * $margin)/3;
  $y1 = ($yupper+$ylower)/2;
  $x2 = ($xupper -$xlower - 2 * $margin)/3*2;
  $y2 = ($yupper+$ylower)/2;
       
  # draw and label the first circle
  $templ = $x1 - $radius;
  $tempu = $x1 + $radius;
  $tempr2 = $radius**2;
  $circle1 = FEQ("sqrt($tempr2-(x-$x1)^2)+$y1 for x in <$templ,$tempu> using color:red and weight:2");
  $circle2 = FEQ("-sqrt($tempr2-(x-$x1)^2)+$y1 for x in <$templ,$tempu> using color:red and weight:2");
  ($c1ref, $c2ref) = plot_functions($diagram, $circle1, $circle2);
  $axislabels = new Label($x1 - (2+sqrt(2))/4*$radius, $y1 + (2+sqrt(2))/4*$radius, $labels[0], 'red', 'center', 'center');
  $diagram-> lb($axislabels);
  
  # draw and label the second circle
  $templ = $x2 - $radius;
  $tempu = $x2 + $radius;
  $tempr2 = $radius**2;
  $circle1 = FEQ("sqrt($tempr2-(x-$x2)^2)+$y2 for x in <$templ,$tempu> using color:blue and weight:2");
  $circle2 = FEQ("-sqrt($tempr2-(x-$x2)^2)+$y2 for x in <$templ,$tempu> using color:blue and weight:2");
  ($c1ref, $c2ref) = plot_functions($diagram, $circle1, $circle2);
  $axislabels = new Label($x2 + (2+sqrt(2))/4*$radius, $y2 + (2+sqrt(2))/4*$radius, $labels[1], 'blue', 'center', 'center');
  $diagram-> lb($axislabels);
  $i = 0;
  while ($i < scalar @input && $i < 4){
    if ($i == 0){
      $this_x = (($xupper - $margin)-($xlower + $margin))/2;
      $this_y = (($xupper - $margin)-($xlower + $margin))/3;        
    }  
    if ($i == 1){
      $this_x = $x1 - sqrt(2)/4*$radius;
      $this_y = $y1 + sqrt(2)/4*$radius;       
    }  
    if ($i == 2){
      $this_x = $x2 + sqrt(2)/4*$radius;
      $this_y = $y2 + sqrt(2)/4*$radius;       
    }  
    if ($i == 3){
      $this_x = $x2 + (2+sqrt(2))/4*$radius;
      $this_y = $y2 - (2+sqrt(2))/4*$radius;              
    }
    if ($input[$i] eq "_fill_"){
    
      $diagram->fillRegion([$this_x,$this_y,'gray']);     
    }else{
      $axislabels = new Label($this_x, $this_y, $input[$i], 'black', 'center', 'center');
      $diagram-> lb($axislabels);
    }
    $i++;
  }
  $diagram;
}


#######################################################################################################
#
# Name : DrawVenn3
#
# Input		:	
#
#			$input_word 	=	'region1_info, region2_info, ...'
#						The information to use, arranged in order by region.
#						Use "_fill_" to shade the corresponding region, otherwise
#						the input is treated as label.
#
#			@options	=	'Arrow indicated options' in any order.
#						
#						  labels=>'Set1 label, Set2 label, Set 3 label, U'.  Set1 is on the
#							  left.  Leaving any or all entries blank will
#							  produce no label for that item.  Default is
#							  'A,B,C,U'
#
# Output 	:	$diagram   	= 	a graphics object, the diagram to plot.  Use 'Plot' in the
#						.pg file. 
#
########################################################################################################
sub DrawVenn3{
  my (@input_word)=@_;
  my ($i, $xlower, $xupper, $ylower, $yupper, $diagram, $window_scale, $axis_label, $margin, $radius,
      $x1, $y1, $x2, $y2, $x3, $y3, $x4, $y4, $label_string, @labels, $optional_labels, $this_x, $this_y, 
      @input, $templ, $tempu, $tempr2, $tempo);
  
  # check for optional labels;
  $i = 0;
  while ($i < scalar @input_word - 1){
    if ($input_word[$i] eq "labels"){
      $optional_labels = 1;
      $label_string = $input_word[$i+1];
      splice (@input_word, $i, 2);
      $label_string =~ s/ //g;
      @labels = split ",", $label_string;
    }
    $i++;
  }
  if (!$optional_labels){@labels = ('A','B','C','U');}
  @input = split ",", $input_word[0];
  for ($i = 0; $i < scalar @input; $i++){
    $input[$i] =~ s/ //g;
  }
  $margin = 5;
  $xlower = -$margin;
  $xupper = 100 + $margin;
  $ylower = -$margin;
  $yupper = (4 + sqrt(3))/6*(($xupper-$margin)-($xlower+$margin)) + $margin;
  $window_scale = 3.5;
  $diagram = init_graph($xlower, $ylower, $xupper, $yupper, 'pixels'=>[$window_scale*($xupper-$xlower),$window_scale*($yupper-  $ylower)]);
  $diagram-> moveTo($xlower+$margin,$ylower+$margin);
  $diagram-> lineTo($xupper-$margin,$ylower+$margin);
  $diagram-> lineTo($xupper-$margin,$yupper-$margin);
  $diagram-> lineTo($xlower+$margin,$yupper-$margin);
  $diagram-> lineTo($xlower+$margin,$ylower+$margin);
  $axislabels = new Label(95, 7, $labels[3], 'black', 'center', 'center');
  $diagram-> lb($axislabels);
  $radius = ($xupper -$xlower - 2 * $margin)/4;
  $x1 = ($xupper -$xlower - 2 * $margin)/3;
  $y1 = (($xupper - $margin)-($xlower+$margin))*(2+sqrt(3))/6;
  $x3 = ($xupper -$xlower - 2 * $margin)/3*2;
  $y3 = (($xupper - $margin)-($xlower+$margin))*(2+sqrt(3))/6;
  $x2 = ($xupper -$xlower - 2 * $margin)/2;
  $y2 = (($xupper - $margin)-($xlower+$margin))/3;
       
  # draw and label the first circle
  $templ = $x1 - $radius;
  $tempu = $x1 + $radius;
  $tempr2 = $radius**2;
  $circle1 = FEQ("sqrt($tempr2-(x-$x1)^2)+$y1 for x in <$templ,$tempu> using color:red and weight:2");
  $circle2 = FEQ("-sqrt($tempr2-(x-$x1)^2)+$y1 for x in <$templ,$tempu> using color:red and weight:2");
  ($c1ref, $c2ref) = plot_functions($diagram, $circle1, $circle2);
  $axislabels = new Label($x1 - (2+sqrt(2))/4*$radius, $y1 + (2+sqrt(2))/4*$radius, $labels[0], 'red', 'center', 'center');
  $diagram-> lb($axislabels);
  
  # draw and label the second circle
  $templ = $x2 - $radius;
  $tempu = $x2 + $radius;
  $tempr2 = $radius**2;
  $circle1 = FEQ("sqrt($tempr2-(x-$x2)^2)+$y2 for x in <$templ,$tempu> using color:blue and weight:2");
  $circle2 = FEQ("-sqrt($tempr2-(x-$x2)^2)+$y2 for x in <$templ,$tempu> using color:blue and weight:2");
  ($c1ref, $c2ref) = plot_functions($diagram, $circle1, $circle2);
  $axislabels = new Label($x2 - (2+sqrt(2))/4*$radius, $y2 - (2+sqrt(2))/4*$radius, $labels[1], 'blue', 'center', 'center');
  $diagram-> lb($axislabels);

  # draw and label the third circle
  $templ = $x3 - $radius;
  $tempu = $x3 + $radius;
  $tempr2 = $radius**2;
  $circle1 = FEQ("sqrt($tempr2-(x-$x3)^2)+$y3 for x in <$templ,$tempu> using color:orange and weight:2");
  $circle2 = FEQ("-sqrt($tempr2-(x-$x3)^2)+$y3 for x in <$templ,$tempu> using color:orange and weight:2");
  ($c1ref, $c2ref) = plot_functions($diagram, $circle1, $circle2);
  $axislabels = new Label($x3 + (2+sqrt(2))/4*$radius, $y3 + (2+sqrt(2))/4*$radius, $labels[2], 'orange', 'center', 'center');
  $diagram-> lb($axislabels);
  $x4 = $x2;
  $y4 = $y2 + (($xupper-$margin)-($xlower+$margin))/(3*sqrt(3));
  $i = 0;
  while ($i < scalar @input && $i < 8){
    if ($i == 0){
      $this_x = $x4;
      $this_y = $y4;
    }  
    if ($i == 1){
      $this_x = $x4;
      $this_y = $y4 + (($xupper-$margin)-($xlower+$margin))/(6*sqrt(3));       
    }  
    if ($i == 2){
      $this_x = $x1 + (($xupper-$margin)-($xlower+$margin))/12;
      $this_y = $y1 - (($xupper-$margin)-($xlower+$margin))*sqrt(3)/12;       
    }  
    if ($i == 3){
      $this_x = $x3 - (($xupper-$margin)-($xlower+$margin))/12;
      $this_y = $y3 - (($xupper-$margin)-($xlower+$margin))*sqrt(3)/12;      
    }
    if ($i == 4){
      $this_x = $x3 + sqrt(2)/4 * $radius;
      $this_y = $y3 + sqrt(2)/4 * $radius;      
    }
    if ($i == 5){
      $this_x = $x1 - sqrt(2)/4 * $radius;
      $this_y = $y1 + sqrt(2)/4*$radius; 
    }
    if ($i == 6){
      $this_x = $x2;
      $this_y = $y2 - $radius / 2 ;
    }
    if ($i == 7){
      $this_x = $xupper - $margin - $radius/2;
      $this_y = $ylower + $margin + $radius/2;
    }
    if ($input[$i] eq "_fill_"){    
      $diagram->fillRegion([$this_x,$this_y,'gray']);    
    }else{
      $axislabels = new Label($this_x, $this_y, $input[$i], 'black', 'center', 'center');
      $diagram-> lb($axislabels);
    }
    $i++;
  }
  $diagram;
}


#####################################
#
# Name	:	Venn2answers
#
#
#####################################
sub Venn2answers{

  my ($labels) = @_;
  my (@set, $i);
  
  @set = split ",", $labels;
  if (scalar @set < 3){die "Too few labels, exiting ...";}
  for ($i = 0; $i < scalar @set; $i++){$set[$i] =~ s/ //g;}
  
  $combo[0] = "0,\\( $set[0] \\cap $set[1] \\), \\( \\overline{\\overline{$set[0]} \\cup \\overline{$set[1]}} \\)";
  $combo[1] = "1,\\( $set[0] \\cap \\overline{$set[1]}\\), \\( \\overline{\\overline{$set[0]} \\cup $set[1] } \\)";
  $combo[2] = "2,\\( \\overline{$set[0]} \\cap $set[1]\\), \\( \\overline{$set[0] \\cup \\overline{$set[1]}} \\)"; 
  $combo[3] = "3,\\( \\overline{$set[0] \\cup $set[1]}\\), \\(\\overline{$set[0]} \\cap \\overline{$set[1]} \\)";
  
  @combo;
}


#####################################
#
# Name	:	Venn3answers
#
#
#####################################
sub Venn3answers{

  my ($labels) = @_;
  my (@set, $i);
  
  @set = split ",", $labels;
  if (scalar @set < 4){die "Too few labels, exiting ...";}
  for ($i = 0; $i < scalar @set; $i++){$set[$i] =~ s/ //g;}
  
  $combo[0] = "0,\\( $set[0] \\cap $set[1] \\cap $set[2] \\), \\( \\overline{\\overline{$set[0]} \\cup \\overline{$set[1]} \\cup \\overline{$set[2]}}\\), \\( \\overline{\\overline{$set[0]} \\cup \\overline{$set[1]}} \\cap $set[2] \\)";
  $combo[1] = "1,\\( $set[0] \\cap $set[2] \\cap \\overline{$set[1]} \\), \\(\\overline{\\overline{$set[0]} \\cup \\overline{$set[2]} \\cup $set[1] } \\), \\( \\overline{\\overline{$set[0]} \\cup \\overline{$set[2]}} \\cap \\overline{$set[1]} \\)";
  $combo[2] = "2,\\( $set[0] \\cap $set[1] \\cap \\overline{$set[2]} \\), \\(\\overline{\\overline{$set[0]} \\cup \\overline{$set[1]} \\cup $set[2] } \\), \\( \\overline{\\overline{$set[0]} \\cup \\overline{$set[1]}} \\cap \\overline{$set[2]} \\)"; 
  $combo[3] = "3,\\( $set[1] \\cap $set[2] \\cap \\overline{$set[0]} \\), \\(\\overline{\\overline{$set[1]} \\cup \\overline{$set[2]} \\cup $set[0] } \\), \\( \\overline{\\overline{$set[1]} \\cup \\overline{$set[2]}} \\cap \\overline{$set[0]} \\)"; 
  $combo[4] = "4,\\( $set[2] \\cap (\\overline{$set[0] \\cup $set[1]}) \\), \\( $set[2] \\cap \\overline{$set[0]} \\cap \\overline{$set[1]} \\), \\( \\overline{\\overline{$set[2]} \\cup $set[0] \\cup $set[1]} \\)"; 
  $combo[5] = "5,\\( $set[0] \\cap (\\overline{$set[2] \\cup $set[1]}) \\), \\( $set[0] \\cap \\overline{$set[2]} \\cap \\overline{$set[1]} \\), \\( \\overline{\\overline{$set[0]} \\cup $set[2] \\cup $set[1]} \\)"; 
  $combo[6] = "6,\\( $set[1] \\cap (\\overline{$set[0] \\cup $set[2]}) \\), \\( $set[1] \\cap \\overline{$set[0]} \\cap \\overline{$set[2]} \\), \\( \\overline{\\overline{$set[1]} \\cup $set[0] \\cup $set[2]} \\)"; 
  $combo[7] = "7,\\( \\overline{$set[0] \\cup $set[1] \\cup $set[2]} \\), \\( \\overline{$set[0]} \\cap \\overline{$set[1]} \\cap \\overline{$set[2]}  \\), \\( (\\overline{$set[0] \\cup $set[1]} ) \\cap \\overline{$set[2]}\\)"; 
  
  @combo;
}

1;