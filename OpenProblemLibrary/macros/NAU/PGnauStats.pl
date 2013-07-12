loadMacros("PGnauGraphics.pl",      
          );      


################################
#Name: MeanDev
#Input: List of data values
#Output: List  containing mean and standard deviation
################################
sub MeanDev{
  my (@list) = @_;
  my($i, $dev, $sum, $mean, $size, @values);

  $sum = 0;
  $size = scalar @list;
  foreach $val (@list){
    $sum += $val;
  }
  $mean = $sum/$size;

  $sum = 0;
  foreach $val (@list){
    $sum += ($val - $mean)**2;
  }
  $dev = sqrt($sum / ($size - 1));

  @values = ($mean, $dev);
}


################################
#Name: Median
#Input: List of data values
#Output: Value of the median
################################
sub Median{
  my(@list) = @_;

  my ($med, $size);

  @list = num_sort(@list);
  $size = scalar @list;

  if ($size % 2 == 0){
    $med = ($list[$size/2] + $list[$size/2-1])/2;
  } else {
    $med = $list[$size/2];
  }
}


################################
#Name: FiveNum
#Input: List of data values
#Output: List containing the five number summary in order from Low to High
################################
sub FiveNum{
  my(@list) = @_;

  my ($L, $Q1, $Q2, $Q3, $H, $val, $size, $lower, $upper, @values);

  @list = num_sort(@list);
  $size = scalar @list;

  $L = $list[0];
  $H = $list[$size-1];
  $Q2 = Median(@list);
    $val = $size / 2;
  if ($size % 2 == 0){
    $lower = $val - 1;
    $upper = $val;
  } else{
    $lower = $val - 1;
    $upper = $val + 1;
  }

  $Q1 = Median(@list[0..$lower]);
  $Q3 = Median(@list[$upper..$size - 1]);

  @values = ($L, $Q1, $Q2, $Q3, $H);
}


################################
#Name: Mode
#Input: List of data values
#Optional Input: 'Max_Modes'=> num limits the maximum number of modes to num
#Output: List containing the mode or the list ("None") if the number of modes 
#        is more than num, 
################################
sub Mode{
  my (@list) = @_;

  my($max, $val, $size, $count, @modes, $preval, $max_modes);

  $max_modes = scalar @list;

  if ($list[0] eq 'Max_Modes'){
    shift @list;
    $max_modes = shift @list;
  }

  @list = num_sort(@list);

  $count = -1;
  $max = 0;
  $preval = $list[0];
  
  foreach $val (@list){
    if ($val == $preval){
      $count++;
    } else{
      $count = 0;
    }
    if ($count > $max){
      @modes = ();
      push @modes, $val;
      $max = $count;
    } elsif ($count == $max){
      push @modes, $val;
    }
  $preval = $val;
  }
  
  if (scalar @modes > $max_modes){
    ("None");
  } else {
  @modes;
  }
};


######################################
#Name: isstring
#Input: A variable
#Output: A 1 if the variable is a string, 0 otherwise
######################################
sub isstring {
  my ($val) = @_;
  
  my($ans, $range);
  
  $range = join '', ('a'..'z','A'..'Z');

  $ans = 0;
  if (length $val == 0 || $val =~ /[$range]/){
    $ans = 1;
  }

  $ans;
};

#########################################################################################
#
# Name   : BoxPlot
# Input  : $min 	= the minimum value in the dataset
#          $q1 		= the first quartile value
#	   $q2 		= the second quartile (median) value
#          $q3 		= the third quartile value
#          $max 	= the maximum value in the dataset
#          Options      = array of numbers to be plotted with tickmarks,
#			  perhaps interspersed with the options below 
#			  in any order. 
#
#	   Options ::  The following may be passed AFTER the five numbers 
#                      (together with the labels, without regard to order):
#
#                      (1) Use "wmin=>number" (no quotes really) to set the
#		           lower viewing window.  Default is '$min'
#
#		       (2) Use "wmax=>number" (no quotes really) to set the 
#			   upper viewing window.  Default is '$max'
#
#		       (3) Use "horzlabels=>number" to set the approximate 
#			   number of horizontal labels.  Default is 10.
#
#		       (4) Use "axis=>0" to hide the horizontal axis.
#                          Default is to plot the axis.
#
#                      (5) Use labels such as 'a','b' and so on to label any 
#			   of the five numbers with the desired string.  
#			   Default is no labels.
#
# Output : $pic = a graphics object.
#
#####################################################################################
sub BoxPlot {
  my ($min, $q1, $q2, $q3, $max, @optional_labels) = @_;
  my $pic;
  my ($horizontal_label_count, $plotaxis, @qlabels, @nlabels, $i, $skip,
      $xlower, $xupper, $ylower, $yupper, $rough_step, $n,
      $a, $rounded_winmin, @labels, $label_step, $label_count, @scaledfive, $axis_labels);

  #initialize to default
  my $winmin = $min;
  my $winmax = $max;
  $horizontal_label_count = 10;
  $plotaxis = 1;

  @qlabels = ();
  @nlabels = ();
  
  while (scalar @optional_labels > 0){
    $val = shift @optional_labels;
    if (isstring($val)){
      if ($val eq "winmin"){
        $winmin = shift @optional_labels;
      } elsif($val eq "winmax") {
        $winmax = shift @optional_labels;
      } elsif($val eq "horzlabels") {
        $horizontal_label_count = shift @optional_labels;
        if ($horizontal_label_count == 0){
	  $horizontal_label_count = 10;
	}
      } elsif($val eq "axis") {
        $plotaxis = shift @optional_labels;
	if ($plotaxis != 1) {
	  $plotaxis = 0;
	}
      } else {
	push @qlabels, $val;
      }
    } else {
      push @nlabels, $val;
    }
  }

  # error check
  if ($winmin >= $winmax){die "the requested window settings are unusable";}
  
  # setup graph.  The size is essentially fixed here.
  $xlower = -20;
  $xupper = 120;
  $yupper = 20;

  if ($plotaxis == 1){
    $ylower = -10;
  } else{
    $ylower = 0;
  }

  $pic = init_graph($xlower, $ylower, $xupper, $yupper, 'pixels'=>[5*($xupper-$xlower),5*($yupper-  $ylower)]);
  
  $winsize = $winmax - $winmin;

  # determine a suitable label step size.  Approximately 10 'nice' labels are needed.
  $n = 0;
  
  $rough_step = $winsize/$horizontal_label_count;

  if ($rough_step < 1){
    while ($rough_step < 1){
      $n--;
      $rough_step = $rough_step * 10;
    }
  } elsif ($rough_step > 10){
    while ($rough_step > 10){
      $n++;
      $rough_step = $rough_step / 10;
    }
  }
  
  # optimize the step size.  The 'larger' is taken to avoid too many labels.
  if ($rough_step <= 2){$a = 2;}
  elsif ($rough_step > 5){$a = 10;}
  else {$a = 5;}
  
  # actually set the 'label_step'
  $label_step = $a * 10 ** $n;  
  if ($label_step == 0){die "Error determining the label step size";}
  
  # next, the upper and lower window values are adjusted to 'nice' numbers, if needed.
  $rounded_winmin = int ($winmin / $label_step) * $label_step - $label_step;
   
  #Build the 'labels' array.  There should be about 10 
  $i = 0;
  @labels = ($rounded_winmin);
  do{
    $i++;
    push @labels, $rounded_winmin + $label_step * $i;
  } while ($rounded_winmin + $label_step * $i <= $winmax);

  $label_count = $i;
  $rounded_winmax = $labels[$i];
  
  #scale the input data for plotting
  push @scaledfive, ($min - $winmin)*100/$winsize;
  push @scaledfive, ($q1 - $winmin)*100/$winsize;
  push @scaledfive, ($q2 - $winmin)*100/$winsize;
  push @scaledfive, ($q3 - $winmin)*100/$winsize;
  push @scaledfive, ($max - $winmin)*100/$winsize;

  
  #add the horizontal labels and axis to the picture.  Labeling starts at '$lower_window'.
  if($plotaxis == 1){

    $pic->moveTo($xlower,0);
    $pic->lineTo($xupper,0,1);       

    for ($i = 0; $i <= $label_count; $i++){
      $xval = ($labels[$i]-$winmin)*100/$winsize;

      if ($xval < 115 && $xval > -15 ){
        $pic->moveTo($xval,0);
        $pic->lineTo($xval,-1,1);
        $axislabels = new Label($xval, -3, $labels[$i], 'black', 'center', 'center');
        $pic->lb($axislabels);
      }
    }
  }

  #add the optional labels to the picture.
  for ($i = 0; $i < scalar @nlabels; $i++){
    $xval = ($nlabels[$i] - $winmin)*100 / $winsize;

    if ($nlabels[$i] >= $winmin && $nlabels[$i] <= $winmax){
      $pic->moveTo($xval,0);
      $pic->lineTo($xval,1,1);
      $axislabels = new Label($xval, 5, $nlabels[$i], 'black', 'center', 'center');
      $pic->lb($axislabels);
    }
  }

  $center = $yupper/2;

  #add the optional quartile labels
  for ($i = 0; $i < scalar @qlabels && $i < 5; $i++){
    if ($qlabels[$i] ne ''){
      $pic->moveTo($scaledfive[$i],$center + 4);
      $pic->lineTo($scaledfive[$i],$center + 5,1);
      $axislabels = new Label($scaledfive[$i], $center + 8, $qlabels[$i], 'black', 'center', 'center');
      $pic->lb($axislabels);
    }
  }

  # draw data lines
  $pic->stamps(closed_circle($scaledfive[0], $center, "black"));
  $pic->moveTo($scaledfive[0], $center);
  $pic->lineTo($scaledfive[1], $center,1);
  $pic->moveTo($scaledfive[3], $center,1);
  $pic->lineTo($scaledfive[4], $center,1);
  $pic->stamps(closed_circle($scaledfive[4], $center, "black"));
  
  # draw quart boxes
  $pic->moveTo($scaledfive[1],$center - 2);
  $pic->lineTo($scaledfive[3],$center - 2,1);
  $pic->lineTo($scaledfive[3],$center + 2,1);
  $pic->lineTo($scaledfive[1],$center + 2,1);
  $pic->lineTo($scaledfive[1],$center - 2,1);
  
  # draw median lines
  $pic->moveTo($scaledfive[2], $center - 2);
  $pic->lineTo($scaledfive[2], $center + 2,1);
  $pic;
}

#################
# Name : SpecialData
# Input : A string containing the type of data desired (Exp, Sym, Bi, Norm, Left, Right)
#	  and any optional input.
# Optional Input : count => n : the number of data values to generate (default = 500)
#		    mean => n : The mean for the normal, left or right distributions (default = 0)
#		     dev => n : The standard deviation for the normal, left or right distributions (default = 1)
#		     min => n : The minimum value for the data (default = 0)
#		     max => n : The maximum value for the data (default = 100)
# Output : A list of data values with the special properties.
#################

sub SpecialData{
  my($type, %options) = @_;

  my($x, $sd, @dat, $max, $min, $mean, $count, $range);
  
  my ($B, $B1, $B2);
  @dat = ();
  
  $type = lc $type;
  
  if (defined $options{count}){$count = $options{count};} 
  else {$count = 500;}
  if (defined $options{mean}){$mean = $options{mean};}
  else {$mean = 0;}
  if (defined $options{dev}){$sd = $options{dev};}
  else {$sd = 1;}
  if (defined $options{min}){$min = $options{min};}
  else {$min = 0}
  if (defined $options{max}){$max = $options{max};}
  else {$max = 100;}

  $range = $max - $min;
  
  if ($type eq 'exp'){
    $B = random (.7, 10, .05);
    for ($i = 0; $i < $count; $i++){
      $val = random(0, .99, .01);
      push @dat, -$B * ln(1 - $val);
    }
  } elsif ($type eq 'bi'){
    $B1 = random(0, $range / 5, 1);
    $B2 = random(9 * $range / 10, $range,1);

    for ($i = 0; $i < $count/5; $i++){
      push @dat, $min + random($B1 - $range / 10, $B1 + $range/10, 1);
    }
    for ($i = 0; $i < 2*$count/5; $i++){
      push @dat, $min + random($B2 - $range / 10, $B2 + $range/10, 1);
    }
    for ($i = 0; $i < $count; $i++){
      push @dat, random($min,$max, 1);
    }
  } else {
    for ($i = 0; $i < $count; $i++){
      $val = RandomNormalNumber(mean=>$mean, dev=>$sd);
      push @dat, $val;
    }

    if ($type eq 'norm' || $type eq 'sym'){
      @dat = num_sort(@dat);
      $low = $dat[0];
      $high = $dat[$count - 1];
      $diff = $high - $low;
      for ($i = 0; $i < $count; $i++){
        $dat[$i] = $range * ($dat[$i] - $low)/ $diff + $min;
      }
    } else {
      for ($i = 0; $i < $count; $i++){
        $dat[$i] = $dat[$i]**2;
      }
      @dat = num_sort(@dat);
      $low = $dat[0];
      $high = $dat[$count - 1];
      $diff = $high - $low;
      for ($i = 0; $i < $count; $i++){
        $dat[$i] = $range * ($dat[$i] - $low) /  $diff + $min;
        if ($type eq 'left'){
          $dat[$i] = -$dat[$i] + $min + $max;
        }
      }
    }
  }

  @dat;
}


######################################
#Name: PercentStemAndLeaf
#Input: List of percentage values (anything from 0 to 100).
#Optional Input: At beginning of list: 
#		all => 1,0 turns on or off the display of all columns of the 
#		 table (useful if data is within a small range).
#		sort => 1,0 turns on or off sorted data rows.
#		single=>1,0 displays answers as a single cell in the table or
#		 determines the number from the data.
#Output: A list containing two strings.  The first is a string that represents 
#	 the html table to be displayed and the second is the TeX table to be 
#	 displayed.
######################################
sub PercentStemAndLeaf{
  my(@dat) = @_;
  
  my($i, $j, $s1, $s2, $all, $low, $max, $num, $row, $cols, $high, @list, $sort, $var1, $var2, , $tex_table, $html_table);
  
  while (isstring($dat[0]) == 1){
    $var1 = shift @dat;
    if ($var1 eq 'all'){
      $all = shift @dat;
    } elsif($var1 eq 'sort'){
      $sort = shift @dat;
    } elsif ($var1 eq 'single'){
      if (shift @dat == 0){
        $cols = -1;
      }
    } else {
      shift @dat;
    }
  }
  
  $all = 1 unless defined ($all);
  $sort = 1 unless defined ($sort);
  $cols = 3 unless defined ($cols);
  
  for ($i = 0; $i < scalar @dat; $i++){
    $num = int($dat[$i] / 10);
    $row = "row$num";
    push @$row, $dat[$i] % 10;
  }

  $max = 0;
  for ($i = 0; $i <= 10; $i++){
    $j = 10 - $i;
    $var1 = "row$i";
    $var2 = "row$j";
    $s1 = scalar @$var1;
    $s2 = scalar @$var2;
    if ($s1 != 0){$high = $i;}
    if ($s2 != 0){$low = $j;}
    if ($s1 > $max){$max = $s1;}
  }
  if ($all){
    $low = 0;
    $high = 10;
  }
  if ($cols == -1){
    $cols = $max;
  }
  $tex_cols = $cols - 1;
  
  $align = 'r|';
  for ($i = 0; $i < $tex_cols - 1; $i++){
    $align .= 'l';
  }

  $html_table = begintable($cols);
  $tex_table  = "\\begin{tabular}{$align}";
  
  for ($i = $high; $i >= $low; $i--){
    $var1 = "row$i";
    
    @list = @$var1;
    if ($sort){
      @list = num_sort(@list);
    }
    if ($cols == 3){
      @list = (join '', @list);
    } 
    $html_table .= row($i, ' ', @list);
    $tex_table .= "\n $i";
    for ($j = 1; $j < $tex_cols; $j++){
      if (scalar @list > 0){
        $var2 = shift @list;
      } else {
        $var2 = '';
      }
      $tex_table .= "\&$var2 ";
    }
    $tex_table .= "\\\\\n";
  }
  $html_table .= endtable();
  $tex_table .= '\end{tabular}';
  ($html_table, $tex_table);
}


###
# Name	: RoundStep
###
sub RoundStep{
  my ($num, $val) = @_;
  my ($remainder);
  #qualify the input
  $minus = 0;
  if($num < 0){$num = -$num; $minus = 1;}
  $val = abs ($val);
  $remainder = ($num / $val - int ($num / $val)) * $val;
  if ($remainder < ($val / 2)){
    $num = int ($num / $val) * $val;
  }else{
    $num = (int ($num / $val) + 1) * $val;
  }
  if ($minus){$num = -$num;}
  $num;
}


###
# Name	: CeilingStep
###
sub CeilingStep{
  my ($num, $val) = @_;
  #qualify the input
  $minus = 0;
  if($num < 0){$num = -$num; $minus = 1;}
  $val = abs ($val);
  $num = (int ($num / $val) + 1) * $val;
  if ($minus){$num = -$num;}
  $num;
}


###
# Name	: FloorStep
###
sub FloorStep{
  my ($num, $val) = @_;
  #qualify the input
  $minus = 0;
  if($num < 0){$num = -$num; $minus = 1;}
  $val = abs ($val);
  $num = int ($num / $val) * $val;
  if ($minus){$num = -$num;}
  $num;
}


#############################################################################
# Name   : Histogram 
# Input  : @data 	= "the data"
#          Options      = may be interspersed in the data in any order. 
#
#	   Options ::  The following may be passed AFTER the standard input
#		       above (without regard to order):
#
#                      (1) Use "labelcells=>1" (no quotes really) to include
#		           frequency labels at the top of each cell.
#			   The default is no labels.
#
#		       (2) Use "labelcount=>number" (no quotes really) to 
#			   set an approximate number of labels to use on the
#			   vertical axis.  Default is 5.
#
#		       (3) Use "title=>string" to add a title, centered at
#			   the top.
#
#		       (4) Use "axislabel=>string" to add an axis label, 
#			   centered at the bottom.
#
#		       (5) Use "bins=>number" to specify approximately how
#			   many bins should be used.  Default is 10.
#
#		       Note : any extra numbers input at the end will be
#			      taken as data.
#
# Output : $pic = a graphics object
#############################################################################
sub Histogram { 
  my (@data) = @_;
  my $pic;
  my ($key, $cell_labels, $target_label_count, $xlower, $xupper, $ylower,
      $yupper, @division_values, $frequency, $j, @frequencies, $maxfreq,
      @scaled_division_values, $division_count, $axis_labels, $rough_step,
      $n, $step, $scaled_step, $this_label, $i, $bins);
  $key = 0;

  # check for options
  for ($i = 0; $i < scalar @data; $i++){
    $cut = 0;
    $val = $data[$i];
    if ($val eq 'labelcells'){
      if ($data[$i+1] != 0){$cell_labels = 1;}
      $cut = 1;
    } elsif ($val eq 'labelcount'){
      $target_label_count = $data[$i+1];
      $cut = 1;
    } elsif ($val eq 'title'){
      $title = $data[$i+1];
      $cut = 1;
    } elsif ($val eq 'axislabel'){
      $axislabel = $data[$i+1];
      $cut = 1;
    } elsif ($val eq 'bins'){
      $bins = $data [$i+1];
      $cut = 1;
    }
    
    if ($cut == 1){
      splice  (@data, $i, 2);
      $i--;
    }
  }

  $cell_labels = 0 unless defined ($cell_labels);
  $target_label_count = 5 unless defined ($target_label_count);
  $title = '' unless defined ($title);
  $axislabel = '' unless defined ($axislabel);
  $bins = 10 unless defined ($bins);

  # setup graph.  The size is essentially fixed here.
  $window_size = 5;
  $xlower = -20;
  $xupper = 120;
  $ylower = -20;
  $yupper = 70;
  $pic = init_graph($xlower, $ylower, $xupper, $yupper, 'pixels'=>[$window_size*($xupper-$xlower),$window_size*($yupper-  $ylower)]);
  # find the data range  
  $min = min (@data);
  $max = max (@data);
  $rough_step = ($max - $min) / $bins;
  #find a 'nice' width 
  $n = 0;
  
  if(int($rough_step) > 10){
    while ($rough_step > 10){
      $n++;
      $rough_step = $rough_step / 10;
    }
  } elsif(int($rough_step) < 1){
    while ($rough_step < 1){
      $n--;
      $rough_step = $rough_step * 10;
    }
  }

  if ($rough_step <= 2){$a = 2;}
  elsif ($rough_step > 2 && $rough_step <= 5){$a = 5;}
  else {$a = 10;}
  $width = $a * 10 ** $n;
  # round
  $min = FloorStep($min,$width);
  $max = CeilingStep($max,$width);  
  # setup the cell division values
  @division_values = ($min);
  $i = 0;
  while ($min + $width * $i < $max){
    $i++;
    push @division_values, $min + $width * $i;
  }
  $division_count = $i;
  # calculate the frequencies for each cell
  $maxfreq = 1;
  for ($i = 0; $i < $division_count; $i++){
    #determine the current frequency    
    $j = 0;
    $frequency = 0;
    while ($j < scalar @data){
      if ($data[$j] >= $division_values[$i] && $data[$j] < $division_values[$i+1]){
        $frequency++;
      }
      $j++;
    }
    push @frequencies, $frequency;
    if ($frequencies[$i] > $maxfreq){
      $maxfreq = $frequencies[$i];
    }
  }
  #scaling transformations.  The given $min and $max are used for this.
  $i = 0;
  while ($i <= $division_count){
    $scaled_division_values[$i] = ($division_values[$i]-$min)*100/($max-$min);
    if ($i != $division_count){  
      $scaled_frequencies[$i] = ($frequencies[$i])*50/($maxfreq);
    }
    $i++;
  }
  $pic->moveTo($scaled_division_values[0],0);
  $pic->lineTo($scaled_division_values[$division_count],0,1);
  $pic->lineTo($scaled_division_values[$division_count],55,1);
  $pic->lineTo($scaled_division_values[0],55,1);
  $pic->lineTo($scaled_division_values[0],0,1);
  #label the division points, and draw the cells
  $i = 0;
  while ($i < $division_count){
    $pic->moveTo($scaled_division_values[$i],0);
    $axislabels = new Label($scaled_division_values[$i], -3, $division_values[$i], 'black', 'center', 'center');
    $pic->lb($axislabels);
    $pic->lineTo($scaled_division_values[$i],$scaled_frequencies[$i],1);
    $pic->lineTo($scaled_division_values[$i+1],$scaled_frequencies[$i],1);
    $pic->lineTo($scaled_division_values[$i+1],0,1);
    if($frequencies[$i] > 0){
      $pic->fillRegion([($scaled_division_values[$i]+$scaled_division_values[$i+1])/2,0.000001,'gray']);
    }
    #add the optional cell labels
    if ($cell_labels == 1){
      if ($frequencies[$i] > 0){
        $axislabels = new Label(($scaled_division_values[$i]+$scaled_division_values[$i+1])/2, $scaled_frequencies[$i]+3, $frequencies[$i], 'black', 'center', 'center');
        $pic->lb($axislabels);
      }      
    }
    $i++;
  }
  # add the last division label if it is not too far to the right
  if ($scaled_division_values[$division_count] <= 110){
    $pic->moveTo($scaled_division_values[$division_count],0);
    $axislabels = new Label($scaled_division_values[$division_count], -3, $division_values[$division_count], 'black', 'center', 'center');
    $pic->lb($axislabels);
  }
  #find 'nice' frequency axis labels
  $n = 0;
  $rough_step = $maxfreq / $target_label_count;
  if(int($rough_step) > 10){
    while ($rough_step > 10){
      $n++;
      $rough_step = $rough_step / 10;
    }
  } elsif(int($rough_step) < 1){
    $rough_step = -1;
  }

  if ($rough_step < 0){$a = 1;}
  elsif ($rough_step > 0 && $rough_step <= 2){$a = 2;}
  elsif ($rough_step > 2 && $rough_step <= 5){$a = 5;}
  else {$a = 10;}

  $step = $a * 10 ** $n;
  $scaled_step = $step * 50 / $maxfreq;
  # add the tickmarks and labels
  $i = 1;
  while ($i <= $target_label_count && $scaled_step * $i < 55){
    #draw tick marks
    $pic->moveTo($scaled_division_values[0],$scaled_step*$i);
    $pic->lineTo($scaled_division_values[0]-1,$scaled_step*$i);
    #create this label
    $this_label = $step*$i;
    $axislabels = new Label($scaled_division_values[0]-3, $scaled_step*$i + 1.25, $this_label, 'black', 'center', 'center');
    $pic->lb($axislabels);    
    $i++;
  }
  # add the title, if needed.
  if ($title ne ''){
    $axislabels = new Label(50, ($yupper + 50)/2, $title, 'black', 'center', 'center');
    $pic->lb($axislabels);
  }
  # add bottom label, if needed.
  if ($axislabel ne ''){
    $axislabels = new Label(50, $ylower/2, $axislabel, 'black', 'center', 'center');
    $pic->lb($axislabels);
  }      
  $pic;
}


################################
#Name: RandomNormalNumber
#Input: None required
#Optional Input: 'mean' => the mean of the normal distribution being used. (default = 0)
#		  'dev' => the standard deviation of the normal distribution being used. (default = 1)
#Output: A number that is related to the standard normal curve with the given mean and deviation.
################################
sub RandomNormalNumber{
  my (@options) = @_;
  
  my($dev, $val, $mean, $norm_num);

  while (scalar @options > 0){
    $val = shift @options;
    if ($val eq 'mean'){
      $mean = shift @options;
    } elsif ($val eq 'dev'){
      $dev = shift @options;
    } else {
      shift @options;
    }
  }
  $mean = 0 unless defined ($mean);
  $dev = 1 unless defined ($dev);
  
  $num = random(.01,.99,.01);
  if ($num >= .5){
    $norm_num =  normal_distr($num-.5, mean=>$mean, deviation=>$dev);
  } else {
    $norm_num =  2*$mean - normal_distr(.5 - $num, mean=>$mean, deviation=>$dev);
  }
  $norm_num;
}

################################
#Name: Scatterplot
#Input: Correlation coefficient
#Optional Input: 'count'=> Number of data points to be calculated.
#		 'mean' => the mean of the normal distribution being used.
#		  'dev' => the standard deviation of the normal distribution being used.
#		 'slope'=> the slope of the scatterplot.
#Output: A picture of the scatterplot with given slope and correlation coefficient.
################################
sub Scatterplot{
  my ($corr, @options) = @_;
  
  my ($i, $y1, $y2, $dev, $max, $min, $pic, $val, $mean, $circle, $count, @x_vals, @y_vals);
  
  while (scalar @options > 0 ){
    $val = shift @options;
    if ($val eq 'count'){
      $count = shift @options;
    } elsif ($val eq 'mean'){
      $mean = shift @options;
    } elsif ($val eq 'dev'){
      $dev = shift @options;
    } elsif ($val eq 'slope'){
      $slope = shift @options;
    } else {
      shift @options;
    }
  }
  
  $count = 100 unless defined ($count);
  $mean = 0 unless defined ($mean);
  $dev = 1 unless defined ($dev);
  $slope = 1 unless defined ($slope);
    
  $min = 0;
  $max = 2;
  for ($i = 0; $i < $count; $i++){
    $val = RandomNormalNumber('mean'=>$mean, 'dev'=>$dev);
    $y1 = RandomNormalNumber('mean'=>$mean, 'dev'=>$dev);
    $y2 = sqrt(1 - $corr**2) * $val + $slope * $corr * $y1;
    if ($y1 < $min){
      $min = $y1;
    } elsif ($y1 > $max){
      $max = $y1;
    }
    if ($y2 < $min){
      $min = $y2;
    } elsif ($y2 > $max){
      $max = $y2;
    }
    push @x_vals, $y1;
    push @y_vals, $y2;
  }

  $min = $min - 1;
  $max = $max + 1;
  $pic="";
  $pic = init_graph($min, $min, $max, $max, 'pixels'=>[200,200]);
  for ($i = 0; $i < $count; $i++){
    $circle = new Circle($x_vals[$i], $y_vals[$i], 2, 'black', 'none');
    $pic->stamps($circle);
  }
  $pic;
}

######################################
#Name: PieChart
#Input: List of values as: decimals - which should add to 1.  If it 
#			  	sums to less than one, the function will make up the difference.
#			   or numbers > 1 - will be treated as numerators for fractions.  The sum of the 
#				numbers will be the denominator and fractions will be placed on the 
#				circle plot.
#Optional Input: percent => 0, 1 : Off or on display of percentage values (regardless of input manner) (default = 0)
#		 labels => 1, 0 : On or off label display.  (default = 1)
#		 values => 1, 0 : On or off value display. (default = 1)
#Output: A picture of the corresponding circle plot
######################################
sub PieChart{
  my @list = @_;
  
  my($i,  @R, @G, @B, $v1, $v2, $Bot, $lab, $pic, $Top, $val, $mark, $angle, $denom, 
     $total, $value, $labels, $radius, @values, $percent, $lett_adj, $line_adj);
  
  while (isstring($list[0])){
    $val = shift @list;
    if ($val eq 'percent'){
      $percent = shift @list;
    } elsif ($val eq 'labels'){
      $labels = shift @list;
    } elsif ($val eq 'values'){
      $value = shift @list;
    } else {
      shift @list;
    }
  }
  $labels = 1 unless defined ($labels);
  $value = 1 unless defined ($values);
  $percent = 0 unless defined ($percent);
  
  $total = 0;
  foreach $val (@list){
    $total += $val;
  }
  
  if ($total <= 0){return "Incorrect values"}
  if ($total > 2){
    $denom = $total;
  } elsif ($total < 1 ){
    push @list, 1 - $total;
    $denom = 1;
  } else {$denom = 1;}
  
  foreach $val (@list){
    if ($percent == 1 && $total < 2){
      $lab = 100 * $val;
      push @values, "$lab%";
    } elsif ($percent == 1){
      $lab = 100 * $val / $total;
      push @values, "$lab%";
    } elsif ($denom != 1) {
      $i = gcd($val, $total);
      $v1 = $val/$i;
      $v2 = $denom/$i;
      push @values, "$v1/$v2";
    } else {
      push @values, $val;
    }
    push @radlist, $val / $total * 2 * $PI;
  }
  
  $radius = 25;
  $v1 = -3/2 * $radius;
  $v2 = 3/2 * $radius;
  $val = $radius ** 2;
  $pic = init_graph($v1, $v1, $v2, $v2, 'pixels'=>[300,300]);
  $Top = FEQ("sqrt($val-(x)^2) for x in <-$radius,$radius> using color:blue and weight:2");
  $Btm = FEQ("-sqrt($val-(x)^2) for x in <-$radius,$radius> using color:blue and weight:2");
  plot_functions($pic, $Top, $Btm);

  $angle = 0;
  $total = scalar @list;
  $dc = int (255 / ($total + 1));
  for ($i = 1; $i <= $total; $i++){
    push @R, 255 - $i * $dc;
    push @B, $i * $dc;
    push @G, 0;
  }
  $i = 0;
  foreach $val (@radlist){
    $pic->moveTo(0,0);
    $pic->lineTo($radius * cos($angle), $radius * sin($angle), 1);
    $angle += $val;
    $mark = $angle - $val / 2;
    $v1 = $radius * cos ($mark);
    $v2 = $radius * sin ($mark);
    $lett_adj = 2/3;
    $line_adj = 7/8;
    $pic->new_color("col$i", $R[$i], $G[$i], $B[$i]);
    $pic->fillRegion([$v1 / 2, $v2 / 2, "col$i"]);
    if ($value == 1){
      $lab = new Label(1.3 * $v1, 1.3 * $v2, "$values[$i]", 'black', 'center', 'center');
      $pic->lb($lab);
      $pic->moveTo($line_adj * $v1, $line_adj * $v2);
      $pic->lineTo(1.1 * $v1, 1.1 * $v2,1);
    }
    if ($labels == 1){
      $lab = new Label($lett_adj * $v1, $lett_adj * $v2, $ALPHABET[$i % 26], 'yellow', 'center', 'center');
      $pic->lb($lab);
    }
    $i++;
  }

  $pic;
}

###########################################################################################################
#
# Name	:	DrawNormalDist
#
# Input : 	lower_z_point, upper_z_point (use -INF or INF for infinite values)
#		
# Optional Input : After first two points.
#		$lower_label = the lower label to use.  Default is 'a'
#		$upper_label = the upper label to use.  Default is 'b' 
#		    (if only want upper label, must input a lower label)
#		outside => n - 0, 1 to shade between or outside the numbers Default = 0;
#		title => 'title string' - will display a title if desired.
#		mean => n - will display the given mean (default display nothing)
#			 
###########################################################################################################
sub DrawNormalDist{
  my ($low, $high, @opt) = @_;

  my ($x1, $x2, $y1, $y2, $pic, $x_val, $y_lab, $y_min, $y_tit, $y_val, $scale, 
      $margin, $xlower, $xupper, $ylower, $yupper, $low_pt, $high_pt, $title, 
      $label, $outside, $trace, $x_slope, $x_int, $y_slope, $y_int, @pt_labels, 
      $mean_val);
  
  ###########################
  # begin intialize and setup
  # initialize to default
  # check for options      
  while (@opt){
    $val = shift @opt;
    if ($val eq 'outside'){$outside = shift @opt;}
    elsif ($val eq 'title'){$title = shift @opt;}
    elsif ($val eq 'mean'){$mean_val = shift @opt;}
    else {push @pt_labels, $val;}
  }
  if (scalar @pt_labels == 0){push @pt_labels, 'a', 'b';}
  elsif (scalar @pt_labels == 1){push @pt_labels, 'b';}
  $outside = 0 unless defined ($outside);
  $title = '' unless defined ($title);
  
  if ($low eq '-INF'){$low_pt = -3.5;}
  else {$low_pt = $low;}
  if ($high eq 'INF'){$high_pt = 3.5;}
  else {$high_pt = $high;}
  # end initialize and setup
  ##########################  
  
  # setup the graph.  The size is essentially fixed here.
  $scale = 4;
  $margin = 5;
  $xlower = - $margin;
  $xupper = 100 + $margin;
  $ylower = -$margin;
  $yupper = 50 + $margin;
  $x1 = $xlower + $margin;
  $x2 = $xupper - $margin;
  $y1 = $ylower + $margin + 2.5;
  $y2 = $yupper - $margin + 2.5;

  $pic = init_graph($xlower, $ylower, $xupper, $yupper, 'pixels'=>[$scale * ($xupper-$xlower), $scale * ($yupper-$ylower)]);
#  $pic->moveTo($x1, $y1);
#  $pic->lineTo($x2, $y1, 1);
#  $pic->lineTo($x2, $y2, 1);
#  $pic->lineTo($x1, $y2, 1);
#  $pic->lineTo($x1, $y1, 1);

  $x_slope = ($x2 - $x1 - 2 * $margin)/6;
  $x_int = $x1 + $margin + $x_slope * 3;
  $y_slope = ($y2 - $y1 - 2 * $margin) * sqrt(2 * $PI);
  $y_int = $y1 + $margin;
  $y_min = $y1 + $margin;

  $trace = FEQ("1/sqrt(2*$PI)*exp(-((x-$x_int)/$x_slope)^2/2)*$y_slope + $y_int for x in <$x1, $x2> using color:black and weight:1");
  plot_functions($pic, $trace);
  
  $pic->moveTo($x1, $y_min);
  $pic->lineTo($x2, $y_min);
  
  # add labels to the independent axis
  $y_lab = $y1 + 3 * $margin / 4;

  $x_val = $low_pt * $x_slope + $x_int;
  $y_val = 1/sqrt(2 * $PI) * exp(-($low_pt)**2/2) * $y_slope + $y_int;
  $label = new Label($x_val, $y_lab, $pt_labels[0],'black','center','center');
  $pic->lb($label);
  $pic->moveTo($x_val, $y_min);
  $pic->lineTo($x_val, $y_min - 1, 1);
  $pic->moveTo($x_val, $y_min);
  $pic->lineTo($x_val, $y_val, 'gray');

  $x_val = $high_pt * $x_slope + $x_int;
  $y_val = 1/sqrt(2*$PI)*exp(-($high_pt)**2/2) * $y_slope + $y_int;
  $label = new Label($x_val, $y_lab, $pt_labels[1],'black','center','center');
  $pic->lb($label);
  $pic->moveTo($x_val, $y_min);
  $pic->lineTo($x_val, $y_min - 1, 1);
  $pic->moveTo($x_val, $y_min);  
  $pic->lineTo($x_val, $y_val, 'gray');

  if (defined $mean_val){
    $x_val = ($xupper + $xlower) / 2;
    $pic->moveTo($x_val, $y_min);
    $pic->lineTo($x_val, $y_min - 1, 1);
    $label = new Label($x_val, $y_lab, $mean_val,'black','center','center');
    $pic->lb($label);
  }
  if ($title ne ''){
    $y_tit = $y_lab - $margin - 1;
    $y_val = $y_lab - $margin + 1;
    $x_val = ($xupper + $xlower) / 2;
    $label = new Label($x_val, $y_tit, $title,'black','center','center');
    $pic->lb($label);
  }

  # shading
  if ($outside == 1){
    $pic->fillRegion([($low_pt - 3.25)/2 * $x_slope + $x_int, $y_min + 0.0001, 'gray']);
    $pic->fillRegion([($high_pt + 3.25)/2 * $x_slope + $x_int, $y_min + 0.0001, 'gray']);
  }elsif ($high_pt - $low_pt > 0.05){
      $pic->fillRegion([($high_pt + $low_pt)/2 * $x_slope + $x_int, $y_min + 0.0001, 'gray']);
  }
  $pic;
}

1;