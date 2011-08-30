
sub _PGnauGraphics_init {}; #don't reload this file
# loadMacros('PGunion.pl');
loadMacros('PGgraphmacros.pl','unionTables.pl','PGchoicemacros.pl');

######################################
#Name: Plot
#Input: Graphical object
#Optional Input: tex_size => n: control size of tex output.  n = 10*percentage of page (i.e. 200 = 20% of page)
#				note that in single column, the images are twice as big, so 200 = 40% of page
#		 single => 0,1: turn on or off single column display which makes pictures fit (default = 0)
#Output: An image with appropriate width and height of the graphical object 
######################################
sub Plot{
  my ($pic, @options) = @_;
  my ($tex, $val, $plot, @size, $width, $height);

  while (scalar @options > 0){
    $val = shift @options;
    if ($val eq 'single'){
      if (shift @options == 1){$tex = 200};
    } elsif ($val eq 'tex_size'){
      $tex = shift @options;
    } else {
      shift @options;
    }
  }
  
  $tex = 400 unless defined ($tex);
  ($width, $height) = @{$pic->size()};
  
  $plot = image(insertGraph($pic), width=>$width, height=>$height, tex_size=>$tex, extra_html_tags=>'border=0');
};


######################################
#Name: checkbox_table
#Input: [values list], [answer list i.e. 1,0,1,0]
#Optional Input: border => n - width of border in table (default = 0)
#		 tex_size => n - control size of tex output for pictures (defualt = 10 * 95 / # of columns)
#		 geometry =>[r,c] -  the number of rows and columns desired in the table (default = 2,2)
#		 labels => [@list] - a list of labels that appear beside the checkboxes. (default is blank)
#		 [..] - other answer lists, included as many as desired.  Note the lists must use the same 
#			  values as the others and answer lists must be in the same basic order.
#Output: A table to be displayed and the answer evaluator.
#	    The table should be placed between BEGIN_TEXT and END_TEXT.
#	    The evaluator should be placed after END_TEXT by itself.
######################################
sub checkbox_table{
  my ($val_ref, $ans_ref, @options) = @_;
  
  my ($i, $j, $k, @ans, $lab, $cols, $name, @vals, $rows, @rule, $size, $true, $val1, $val2, $val3, $count, 
      @labels, @names, @order, @other, $quest, $table, $total, $answer, $length, $letter, $tex_size, @ansrow, 
      @valrow, @answer, %row_opts);
  
  @vals = @{$val_ref};
  @ans0 = @{$ans_ref};
  $count = 1;
  
  while (@options){
    $val1 = shift @options;
    if ($val1 eq 'border'){
      $border = shift @options;
    } elsif ($val1 eq 'tex_size'){
      $single = shift @options;
    } elsif ($val1 eq 'geometry'){
      $val1 = shift @options;
      ($rows, $cols) = @{$val1};
    } elsif ($val1 eq 'labels'){
      $val1 = shift @options;
      @labels = @{$val1};
    } else {
      $val2 = "ans$count";
      @$val2 = @{$val1};
      $count++;
    }
  }  

  $border = 0 unless defined ($border);
  $rows = 2 unless defined ($rows);
  $cols = 2 unless defined ($cols);
  $tex_size = int(95 / $cols) * 10 unless defined ($tex_size);
  
  $size = scalar @vals;
  $val1 = int (($size - 1)/$cols) + 1;
  if ($val1 != $rows){ return ("Incorrect geometry or input.", 0);}
  for ($i = 0; $i < $count; $i++){
    $val = "ans$i";
    if (scalar @$val != $size){ return ("Values and answers do not match.",0);}
  }
  
  $length = scalar @labels;
  $total = $count * $size;
  if ($total == $size){
    for ($i = $length; $i < $total; $i++){
      push @labels, '';
    }
  } else {
    while ($length < $total){
      $loc = int($length / $size) + 1;
      push @labels, "$loc";
      $length++;	
    }
  }
  
  @order = NchooseK($size, $size);
  @vals = @vals[@order];
  for ($i = 0; $i < $count; $i++){
    $val1 = "ans$i";
    $val2 = "labels$i";
    $j = $i * $size;
    $k = $j + $size - 1;
    @$val1 = @$val1[@order];
    @$val2 = @labels[$j..$k];
    @$val2 = @$val2[@order];
  }
  
  for ($i = 0; $i < $size; $i++){
    if ($vals[$i] =~ /WWPlot=HASH/){
      $vals[$i] = Plot($vals[$i], tex_size=>$tex_size);
    }
  }
  
  for ($i = 0; $i < $count; $i++){
    $true = '';
    $val1 = "ans$i";
    $val2 = "labels$i";
    $val3 = "rule$i";
    $name = "CheckBoxName$i";
    for ($j = 0; $j < $size; $j++){
      $letter = $ALPHABET[$j];
      if ($$val2[$j] eq ''){
        $lab = $letter;
      } else {
        $lab = "$letter: ". "$$val2[$j]";
      }
      $$val3[$j] = ($j ? NAMED_ANS_CHECKBOX_OPTION($name, $letter, $lab):
                        NAMED_ANS_CHECKBOX($name, $letter, $lab));
        # TeX-mode uses \item, but we're not in a list, so remove it
        #   and put a fake box in front
      $$val3[$j] =~ s/\\item/\$\\Box\$ / if $displayMode eq 'TeX';
      $true .= $letter if $$val1[$j] == 1;
    }
  push @answer, LABELED_ANS($name =>checkbox_cmp($true));
  }

  $table = BeginTable(spacing=>5, border=>$border, center=>0);
  %row_opts = (separation=>0);
  for ($i = 0; $i < $rows; $i++){
    $j = 0;
    @valrow = ();
    while (@vals && $j < $cols){
      push @valrow, shift @vals;
      $j++;
    }
    $table .= AlignedRow([@valrow], %row_opts);
    for ($j = 0; $j < $count + 1; $j++){
      @ansrow = ();
      $val1 = "rule$j";
      $k = 0;
      while (@$val1 && $k < $cols){
        push @ansrow, shift @$val1;
	$k++;
      }
      $table .= AlignedRow([@ansrow], %row_opts);
    }
    if ($rows > 1 && $i > 0){
      $table .= TableSpace(16,8);
    }
  }
  $table .= EndTable();
  unshift @answer, ($table);
  
  return @answer;
};


######################################
#Name: radio_table
#Input: [values list], [answer list i.e. 1,0,1,0]
#Optional Input: border => n - width of border in table (default = 0)
#		 tex_size => n - control size of tex output for pictures (defualt = 10 * 95 / # of columns)
#		 geometry =>[r,c] -  the number of rows and columns desired in the table (default = 2,2)
#		 labels => [@list] - a list of labels that appear beside the radio buttons. (default is blank)
#		 [..] - other answer lists, included as many as desired.  Note the lists must use the same 
#			  values as the others and answer lists must be in the same basic order.
#Output: A table to be displayed and the answer evaluator.
#	    The table should be placed between BEGIN_TEXT and END_TEXT.
#	    The evaluator should be placed after END_TEXT by itself.
######################################
sub radio_table{
  my ($val_ref, $ans_ref, @options) = @_;
  
  my ($i, $j, $k, @ans, $lab, $cols, $name, @vals, $rows, @rule, $size, $true, $val1, $val2, $val3, $count, 
      @labels, @names, @order, @other, $quest, $table, $total, $answer, $length, $letter, $tex_size, @ansrow, 
      @valrow, @answer, %row_opts);
  
  @vals = @{$val_ref};
  @ans0 = @{$ans_ref};
  $count = 1;
  
  while (@options){
    $val1 = shift @options;
    if ($val1 eq 'border'){
      $border = shift @options;
    } elsif ($val1 eq 'tex_size'){
      $tex_size = shift @options;
    } elsif ($val1 eq 'geometry'){
      $val1 = shift @options;
      ($rows, $cols) = @{$val1};
    } elsif ($val1 eq 'labels'){
      $val1 = shift @options;
      @labels = @{$val1};
    } else {
      $val2 = "ans$count";
      @$val2 = @{$val1};
      $count++;
    }
  }  

  $border = 0 unless defined ($border);
  $rows = 2 unless defined ($rows);
  $cols = 2 unless defined ($cols);
  $tex_size = int(95 / $cols) * 10 unless defined ($tex_size);
  
  $size = scalar @vals;
  $val1 = int (($size - 1)/$cols) + 1;
  if ($val1 != $rows){ return ("Incorrect geometry or input.", 0);}
  for ($i = 0; $i < $count; $i++){
    $val1 = "ans$i";
    if (scalar @$val1 != $size){ return ("Values and answers do not match.",0);}
    $total = 0;
    for ($j = 0; $j < $size; $j++){
      $total += $$val1[$j];
    }
    if ($total != 1){ return ("Wrong number of correct answers for radio button.",0);}
  }
  
  $length = scalar @labels;
  $total = $count * $size;
  if ($total == $size){
    for ($i = $length; $i < $total; $i++){
      push @labels, '';
    }
  } else {
    while ($length < $total){
      $loc = int($length / $size) + 1;
      push @labels, "$loc";
      $length++;	
    }
  }
  
  @order = NchooseK($size, $size);
  @vals = @vals[@order];
  for ($i = 0; $i < $count; $i++){
    $val1 = "ans$i";
    $val2 = "labels$i";
    $j = $i * $size;
    $k = $j + $size - 1;
    @$val1 = @$val1[@order];
    @$val2 = @labels[$j..$k];
    @$val2 = @$val2[@order];
  }
  
  for ($i = 0; $i < $size; $i++){
    if ($vals[$i] =~ /WWPlot=HASH/){
      $vals[$i] = Plot($vals[$i], tex_size=>$tex_size);
    }
  }
  
  for ($i = 0; $i < $count; $i++){
    $true = '';
    $val1 = "ans$i";
    $val2 = "labels$i";
    $val3 = "rule$i";
    $name = "CheckBoxName$i";
    for ($j = 0; $j < $size; $j++){
      $letter = $ALPHABET[$j];
      if ($$val2[$j] eq ''){
        $lab = $letter;
      } else {
        $lab = "$letter: ". "$$val2[$j]";
      }
      $$val3[$j] = ($j ? NAMED_ANS_RADIO_EXTENSION($name, $letter, $lab):
                        NAMED_ANS_RADIO($name, $letter, $lab));
        # TeX-mode uses \item, but we're not in a list, so remove it
        #   and put a fake box in front
      $$val3[$j] =~ s/\\item/\$\\Box\$ / if $displayMode eq 'TeX';
      $true .= $letter if $$val1[$j] == 1;
    }
  push @answer, LABELED_ANS($name =>checkbox_cmp($true));
  }

  $table = BeginTable(spacing=>5, border=>$border, center=>0);
  %row_opts = (separation=>0);
  for ($i = 0; $i < $rows; $i++){
    $j = 0;
    @valrow = ();
    while (@vals && $j < $cols){
      push @valrow, shift @vals;
      $j++;
    }
    $table .= AlignedRow([@valrow], %row_opts);
    for ($j = 0; $j < $count + 1; $j++){
      @ansrow = ();
      $val1 = "rule$j";
      $k = 0;
      while (@$val1 && $k < $cols){
        push @ansrow, shift @$val1;
	$k++;
      }
      $table .= AlignedRow([@ansrow], %row_opts);
    }
    if ($rows > 1 && $i > 0){
      $table .= TableSpace(16,8);
    }
  }
  $table .= EndTable();
  unshift @answer, ($table);
  
  return @answer;
};

1;