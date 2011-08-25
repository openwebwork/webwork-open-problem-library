



#####################################################################
#
# Name : ListProcEval  (answer evaluator for the scheduling .pg files)
#
#####################################################################

sub ListProcEval {
my (@input) = @_;
  sub {
    my $in = shift;
    my $score=0;
    my $ans_hash;
    my $plot_input;
    my $bad_input = 0;    
    my $student_answer = "";
    my @coordinates_weights = split ",",$input[0];
    
    my $i = 0; my $max_weight = 0;
    while ($i < int(scalar @coordinates_weights)){
      if ($i % 3 == 2){$max_weight += $coordinates_weights[$i];} 
      $i++;  
    }
    
    # form the correct string ...
    my @temp = split ",", $input[scalar @input - 1];
    my $proc_label = shift @temp;
    my $correct = join ",",@temp;
    
    # check for 'bad' input ...
    $in = uc $in;
    $in =~ s/ //g;        
    my $temp_word = $in;
    
    $temp_word =~ s/T//g;
    for ($i = 0; $i < 10; $i++){$temp_word =~ s/$i//g;}
    $temp_word =~ s/,//g;
 
    if ($temp_word ne ""){
      $bad_input = 1;
    } else {
      $temp_word = $in;
      $temp_word = uc $temp_word;
      if ($temp_word =~ "TT" || $temp_word =~ "T,T"){
        $bad_input = 1;
      } else {
        @temp = split ",", $temp_word;
        for ($i = 0; $i < scalar @temp; $i++){
          if ($temp[$i] =~ "T"){
	    $temp[$i] =~ s/T//g;
            if ($temp[$i] > (scalar @coordinates_weights)/3){
	      $bad_input = 1;
	    }
	  } else { 
	    if ($temp[$i] > $max_weight){$bad_input = 1;}	  
	  }
        }
      }
    }
    if ($bad_input){
      $score = 0;
      $student_answer = 'The answer format is not correct';
    } else {
      $plot_input = join ",", $proc_label, $in; 
      if ($correct eq $in) {
        $score = 1;
      }
      my $pic = DrawProcessorSchedule($input[0], $plot_input);
      $pic->gifName($pic->gifName()."-$plot_input");
      $student_answer = Plot($pic);
    }
    $ans_hash = { score => $score,
                  correct_ans => $correct,
		  student_ans => $student_answer,
		  preview_latex_string    =>  "$in",
#		  ans_message => ($score) ? ' ' : ' '
                };
    $ans_hash;
  }
}




#############################################################
#
# Name : MakeArrow
#
# Input 	:  $i_1  = the 'tail' x_coordinate in pixels
#		   $i_2  = the 'tail' y_coordinate in pixels
#		   $j_1  = the 'head' x_coordinate in pixels
#		   $j_2  = the 'head' y_coordinate in pixels
#		   $size = the arrowhead size, in pixels
#		   $pic  = the graphics object to modify
#
# Output 	:  $pic
#
#############################################################

sub MakeArrow {
  my ($i_1, $i_2, $j_1, $j_2, $size, $pic) = @_;
  my ($diff1, $diff2, $angle);
  $angle = atan2($j_2 - $i_2, $j_1 - $i_1);
  $diff1 = $size * (cos($angle) + sin($angle));
  $diff2 = $size * (cos($angle) - sin($angle));
  $pic->moveTo($i_1,$i_2);
  $pic->lineTo($j_1,$j_2, 1);
  $pic->lineTo($j_1 - $diff1, $j_2 + $diff2, 1);
  $pic->lineTo($j_1 - $diff2, $j_2 - $diff1, 1);
  $pic->lineTo($j_1, $j_2, 1);
}




####################################################################################################
#
# Name : DrawSchedule
#
# Input 	:	$coordinates = "row (0, ... , 10), column (0, ... , 10), weight, ... ,  ... "
#				       The order determines the vertex index and label used.
#			$connections = "vertex index (tail), vertex index (head), ... , ... "
#				       The vertex indices are taken according to the ordering in
#				       $coordinates.
#
# Output 	:	$pic = the graphics object.
#
####################################################################################################

sub DrawSchedule {
  my ($coordinates, $connections) = @_;
  my (@coordinates_weights, @connections, $y_coor_min, $x_coor_max, $pic,
      $circleradius, $grid_space, $window_scale, $xlower, $xupper, $ylower, $yupper,
      @scaled_coordinates_weights, $offset_1, $offset_2, $this_angle, $arrow_size,
      $i_1, $i_2, $j_1, $j_2,$label_x,$label_y,$diff, $vert_label, @circle,$i);
  @coordinates_weights = split ",", $coordinates;
  @connections = split ",", $connections;
  $i = 0;
  while ($i < scalar @connections){$connections[$i]--;$i++;}    
  # find the coordinate extremes. 
  $y_coor_min = 0;
  $x_coor_max = 0;
  $i = 0;
  while ($i < scalar @coordinates_weights){
    if ( $coordinates_weights[$i+1] > $x_coor_max ){$x_coor_max = $coordinates_weights[$i+1]}
    if ( $coordinates_weights[$i] > $y_coor_min ){$y_coor_min = $coordinates_weights[$i]}
    $i+=3;
  }
  # check the coordinates, and reply with error if necessary 
  if (abs($y_coor_min)>10||abs($x_coor_max)>10){
    die "The absolute value of any coordinate cannot exceed '10' ";
  }
  #scaling factors
  $circleradius = 15;
  $grid_space = 15;
  $window_scale = 3;
  # setup graph.  The size is essentially fixed here.
  $xlower = - $grid_space;
  $xupper = $x_coor_max *  $grid_space +  $grid_space;
  $ylower = -$y_coor_min *  $grid_space -  $grid_space;
  $yupper =  $grid_space;
  $pic = init_graph($xlower, $ylower, $xupper, $yupper, 'pixels'=>[$window_scale*($xupper-$xlower),$window_scale*($yupper-$ylower)]);
  # scale the coordinates 
  $i = 0;
  while ($i < scalar @coordinates_weights){
    $scaled_coordinates_weights[$i+1] = $coordinates_weights[$i+1] *  $grid_space;
    $scaled_coordinates_weights[$i] = -$coordinates_weights[$i] *  $grid_space;
    $i += 3;
  }
  # add the arrows
  $this_angle = 0;
  $i = 0;
  while ($i < scalar @connections){
    $offset_1 = $connections[$i]*3;
    $offset_2 = $connections[$i+1]*3;
    $arrow_size = 1.5;
    $this_angle = atan2($scaled_coordinates_weights[$offset_2]-$scaled_coordinates_weights[$offset_1],
                        $scaled_coordinates_weights[$offset_2+1]-$scaled_coordinates_weights[$offset_1+1]);
    $i_1 = $scaled_coordinates_weights[$offset_1+1] + $circleradius * cos($this_angle)/$window_scale;
    $i_2 = $scaled_coordinates_weights[$offset_1] + $circleradius * sin($this_angle)/$window_scale;
    $j_1 = $scaled_coordinates_weights[$offset_2+1] - $circleradius * cos($this_angle)/$window_scale;
    $j_2 = $scaled_coordinates_weights[$offset_2] - $circleradius * sin($this_angle)/$window_scale;
    MakeArrow($i_1, $i_2, $j_1, $j_2, $arrow_size, $pic);
    $i+=2;
  }
  # add the vertex circles
  $i = 0;
  while($i < scalar @coordinates_weights){
    $label_x = $scaled_coordinates_weights[$i+1];
    $label_y = $scaled_coordinates_weights[$i];
    $diff = $circleradius/(1.5*$window_scale);
    $vert_label = $i / 3 + 1;
    $circle[$i] = new Circle($label_x,$label_y, $circleradius,'black','none');
    $pic->stamps($circle[$i]);
    $pic->lb(new Label($label_x, $label_y + $diff, "T$vert_label",'black','center','center'));
    $pic->lb(new Label($label_x, $label_y, $coordinates_weights[$i+2],'black','center','center'));
    $i += 3;
  }
  # the output
  $pic;
}




######################################################################################################
#
# Name : ListProc (to determine the schedule from a priority list)
#
# Input 	:	$coordinates   = "row (0, ... , 10), column (0, ... , 10), weight, ... ,  ... "
#				         The order determines the vertex index and label used.
#			$connections   = "vertex index (tail), vertex index (head), ... , ... "
#				         The vertex indices are taken according to the ordering in
#				         $coordinates.
#			$order 	       = The 'priority list' needed to realize the scheduling (p.79 textbook).
#			$machine_count = The number of available machines or processors.
#
# Output 	:       @done_list     = The 'raw' scheduling solution, indexed by machine:
#					 "vertex index, time, vertex index, time, ...
#					 The last indexed entry is the algorithm time.
#
#####################################################################################################

sub ListProc {
  my ($coordinates, $connections, $order, $machine_count)=@_;
  my (@coordinates_weights, @weights, @connections, @order, $task_count, @not_ready, @ready, @machines, @dependence_count,
      @done_list, $time, $done, $i, $j, $k, $l, $max_weight, $onlist, $assigned, $done_count, @machine_info, @these_dones);
      
  #intialize and setup
  #####################################################  
  @coordinates_weights = split ",", $coordinates;
  $i = 0;
  $j = 0;
  $max_weight = 0;
  while ($i < int(scalar @coordinates_weights)){
    if ($i % 3 == 2){
      $weights[$j] =$coordinates_weights[$i]; 
      $max_weights += $weights[$j]; 
      $j++;
    } 
    $i++;  
  }
  @connections = split ",", $connections;
  $i = 0;
  while ($i < scalar @connections){$connections[$i]--;$i++;}
  $order =~ s/T//g;    
  @order = split ",", $order;
  $i = 0; while ($i < scalar @order){$order[$i]--;$i++;}
  $task_count = scalar @weights;
  $i = 0; while ($i < $machine_count){$machines[$i] = "-1,-2";$i++;}
  $i = 0;
  while ($i < $machine_count){
    $done_list[$i] = join "", ("P",$i+1);
    $i++;
  }
  $i = 0;
  while ($i < $task_count){
    $dependence_count[$i] = 0;
    $not_ready[$i] = $i;
    $ready[$i] = -1; 
    $i++;
  }
  $j = 1;
  while ($j < scalar @connections){    
    $dependence_count[$connections[$j]]++;        
    $j+=2;
  }
  # done intializing
  ##########################################
  $time = 0;
  $done = 0;
  $done_count = 0;
  while ($time < $max_weights && !$done){
    # update @ready
    $i = 0;
    while ($i < $task_count){
      # check if the current task is already on the 'ready' list
      $onlist = 0;
      $j = 0;
      while ($j < $task_count && !$onlist){
        if ($ready[$j] == $i){$onlist = 1;}
        $j++;
      }
      # check readyness against current dependencies
      if (!$onlist && $dependence_count[$i] == 0){
        unshift @ready, $i;
	pop @ready;
      }
      $i++;
    }
    $j = 0;
    while ($j < $task_count){
      # check if the highest priority task is on the 'ready' list
      $k = 0;
      while ($k < $task_count){
        if ($order[$j] == $ready[$k]){
          # check for an empty machine
          $l = 0;
          $assigned = 0;
          while ($l < $machine_count && !$assigned){
            @machine_info = split ",", $machines[$l];
            if ($machine_info[0] == -1){
              # add the ready task to this machine
	      $assigned = 1;
	      $machines[$l] = join ",",($ready[$k],$weights[$ready[$k]]);
	      # change the dependence count to '-1' to indicate processing.
	      $dependence_count[$ready[$k]] = -1;
	      #remove the ready task from the list
	      splice @ready, $k, 1;
	      #free a vacant spot
	      push @ready, -1;
	    }
	    $l++;
	  }
        }
	$k++;
      }
      $j++;
    }
    $time++;
    # update the remaining processing times 
    $i = 0;
    while ($i < $machine_count){
      @machine_info = split ",", $machines[$i];
      if ($machine_info[0] != -1){
        $machine_info[1]--;
	# update
	$machines[$i] = join ",", ($machine_info[0], $machine_info[1]);
      }
      $i++
    }
    # check for 'freed' machines 
    $i = 0;
    while ($i < $machine_count){
      @machine_info = split ",", $machines[$i];
      if ($machine_info[0] != -1){
        if ($machine_info[1] == 0){
	  # found a 'done' task
	  $done_list[$i] = join ",", $done_list[$i], ($machine_info[0]+1, $time);	  
	  push @these_dones, $machine_info[0];
	  $machines[$i] = "-1,-2";	  
	  $done_count++;
	}	
      }
      $i++
    }
    # check for stop condition, otherwise, update dependencies if necessary.
    if ($done_count == $task_count){
      $done = 1;
    }
    else{
      while (scalar @these_dones > 0){
        $j = pop @these_dones;
        $k = 0;
	while ($k < scalar @connections){
	  if ($connections[$k] == $j){$dependence_count[$connections[$k+1]]--;}
	  $k+=2;
	}
      }            
    }  
  }
  # build the 'slack time' answer format
  #
  # add the "T's" to the labels
  $i = 0;
  while ($i < scalar @done_list){
    $j = 1;
    @this_list = split ",",$done_list[$i];
    while ($j < scalar @this_list){
      $this_list[$j] = join "", ("T", $this_list[$j]);
      $j+=2;
    }
    $done_list[$i] = join ",", @this_list; 
    $i++;
  }
  # cycle through each machine, and correct the format
  $i = 0;
  while ($i < scalar @done_list){
    @this_list = split ",",$done_list[$i];
    # add any slack time before the first task
    $offset = 0;
    if (scalar @this_list >= 3){
      $this_task = $this_list[1];
      $this_done = $this_list[2];
      $this_task =~ s/T//g;
      if ($this_done - $weights[$this_task-1] > 0){
        $temp = shift @this_list;
        unshift @this_list, ($this_done - $weights[$this_task-1]);
        unshift @this_list, $temp;    
        $offset++;
      }
    }
    #check this machine schedule for slack time. Enter '-1' if no slack time.
    $j = 1 + $offset;
    while ($j < (scalar @this_list-3)){
      # check for slack time
      $next_task = $this_list[$j+2];
      $next_task =~ s/T//g;
      $this_done = $this_list[$j+1];
      $next_done = $this_list[$j+3];
      $next_weight = $weights[$next_task - 1];
      if ($next_done - $next_weight == $this_done){
        #no slack time
        $this_list[$j + 1] = -1;
      }        
      else{
        #enter slack time
	$this_list[$j+1] = ($next_done - $next_weight)-$this_done;
      }
      $j+=2;
    }    
    # check for slack time on the last task
    if (scalar @this_list == 1){push @this_list, $time;}
    if (scalar @this_list > 2){
      if ($this_list[(scalar @this_list) - 1]==$time){
        $this_list[(scalar @this_list) - 1]=-1;
      }else{
        $this_list[(scalar @this_list) - 1] = $time - $this_list[(scalar @this_list) - 1];
      }
    }
    #update
    $j = 2 + $offset;
    while ($j < scalar @this_list){
      if ($this_list[$j] == -1){
        splice @this_list, $j, 1;
	$j++;
      }
      else{$j+=2;}
    }
    # final update
    $done_list[$i] = join ",",@this_list;
    $i++;
  }
  push @done_list, $time;
  @done_list;
}




###########################################################
#  To generate a randomly ordered list of distinct integers
###########################################################

sub RandomIntList{
  my ($max) = @_;
  my ($i, $list, @integer_list, @list, $index);
  while (scalar @integer_list < $max){
    push @integer_list, (scalar @integer_list + 1); 
  }
  $i = 0;
  while ($i < $max){
    $index = random(0,$max - $i - 1,1);
    push @list, $integer_list[$index];
    splice @integer_list,$index,1; 
    $i++;
  }
  $list = join ",",@list;
  $list;
}




############################################################################################################################
#
# Name : FindPathsSchedule  ( Works only for appropriate schedule type graphs )
#
# Input 	:	$start_vertex   = An index indicating the 'start vertex' to consider.  Indices here START WITH ZERO.
#			$connections	= The connectivity vector to use to determine the paths.  Indices here START WITH ZERO.
#
# Output	:	@path_list	= stores all possible paths from the 'start' vertex.
#
############################################################################################################################

sub FindPathsSchedule{
  my ($start_vertex, $connections) = @_;
  my (@path_list, $i, $j, $k, $path_update, $list_count, $this_vertex, $previous_vertex, @these_connections,
      $first_pass, @this_path, $count, @update, @connections);
  
  # initialize
  @connections = split ",",$connections;
  @path_list = ("$start_vertex");
  $count = 0;
  $path_update = 1;
  while ($path_update){
    $list_count = scalar @path_list;
    for ($j = 0; $j < $list_count; $j++){
      @this_path = split ",", $path_list[$j];
      $this_vertex = $this_path[scalar @this_path - 1];
      $previous_vertex = $this_path[scalar @this_path - 2];
      # find all possible connections for '$this_vertex'
      $k = 1;
      @these_connections = ();
      while ($k < scalar @connections){
        if ($connections[$k-1] == $this_vertex){
	  push @these_connections, $connections[$k];
	}
        $k+=2;
      }
      $first_pass = 1;
      $update[$j] = 0;
      for ($i = 0; $i < scalar @these_connections; $i++){
        $update[$j] = 1;
	if ($first_pass){
	  $first_pass = 0;
	  $path_list[$j] = join ",", $path_list[$j], $these_connections[$i];
	}else{
	  push @path_list, (join ",", @this_path);
	  $path_list[scalar @path_list - 1] = join ",",$path_list[scalar @path_list - 1], $these_connections[$i]; 
	}
      }
    }      
    # check if any paths were updated
    while (scalar @update > 0){
      $path_update = 0;
      $temp = pop @update;
      if ($temp == 1){$path_update = 1;}
    }
    # to avoid infinite loops only.  
    $count++;
    if ($count > 1000){
      die "Infinite loop, perhaps ... ";
      $path_update = 0;
    }
  }
  @path_list;
}




###########################################################################################################
#
# Name : CritList  ( Produces a priority list according to the critical path scheduling algorithm )
#
# Input 	:	$coordinates   = "row (0, ... , 10), column (0, ... , 10), weight, ... ,  ... "
#				         The order determines the vertex index and label used.
#			$connections   = "vertex index (tail), vertex index (head), ... , ... "
#				         The vertex indices are taken according to the ordering in
#				         $coordinates.
#
# Output 	:       $priority_list = The priority list to use, according to the critical path
#					 algorithm.  (The tasks are numerically labeled beginning with
#					 1 according to the order of $coordinates.)  
#
#####################################################################################################

sub CritList{
  my ($coordinates, $connections) = @_;
  my ($priority_list, @coordinates_weights, @these_coordinates_weights, @weights, $task_count, $i, $j, $k, $max_weights,
      $scheduled_count, @left_vertices, $this_vertex, @these_paths, @this_path, $path_weight,
      $max_path_weight, $max_path_index, $done, $prioritized, @connection_array, $current_vertex, 
      @temp, @temp_list,  $max_vertex, $independent, $crit_path, $these_connections, $these_coordinates, $temp_word);

  #intialize and setup
  #####################################################  
  @coordinates_weights = split ",", $coordinates;
  @these_coordinates_weights = @coordinates_weights;
  $i = 0;
  $j = 0;
  $max_weight = 0;
  while ($i < int(scalar @coordinates_weights)){
    if ($i % 3 == 2){
      $weights[$j] =$coordinates_weights[$i]; 
      $max_weights += $weights[$j]; 
      $j++;
    } 
    $i++;  
  }
  $task_count = scalar @weights;
  @connection_array = split ",", $connections;
  $priority_list = "";
  # end intialize and setup
  #####################################################  
  $scheduled_count = 0;
  while ($scheduled_count < $task_count){
    # update priority list
    $these_connections = join ",", @connection_array;
    $these_coordinates = join ",", @these_coordinates_weights;
    $crit_path = CritPath($these_coordinates, $these_connections);
    # remove the path weight, which is of no current use
    @temp = split ";", $crit_path;
    # convert labels to numbers
    $temp[0] =~ s/T//g;
    @this_path = split ",", $temp[0];
    $this_task = shift (@this_path);
    @temp_list = split ",", $priority_list;
    push @temp_list, $this_task;
    $priority_list = join ",", @temp_list;
    # remove the connection corresponding to the critical path
    $j = 0;
    while ($j < scalar @connection_array){
      if ($connection_array[$j] == $this_task){
        splice @connection_array, $j, 2;
      }else{
        $j+=2;
      }
    }
    # update coordinates to indicate which tasks are already prioritized ... 
    splice @these_coordinates_weights, ($this_task - 1)*3, 3, (-1,-1,-1);        
    ### to temporarily force a stop
    $scheduled_count++; 
    if ($scheduled_count > 1000){
      die "possible infinite loop";
    }
  }
  # add the "T" notation ...
  $priority_list = join "", "T", $priority_list;
  $priority_list =~ s/,/,T/g;
  $priority_list;
}




##########################################################################################################
#
# Name : CritPath ( Finds the critical path in a schedule type graph.  'Ties' are broken by comparing
#		    the task labels of the first task at which two paths disagree.  The smaller label
#		    is taken as the critical path. )
#
# Input 	:	$coordinates   = "row (0, ... , 10), column (0, ... , 10), weight, ... ,  ... "
#				         The order determines the vertex index and label used.
#					 If -1,-1,-1 appears for any vertex, that task is not considered
#					 as part of the graph.
#			$connections   = "vertex index (tail), vertex index (head), ... , ... "
#				         The vertex indices are taken according to the ordering in
#				         $coordinates.
#
# Output	:	$crit_path	= "task_label1, task_label2, ... , $task_labeln; total_weight
#
###########################################################################################################

sub CritPath{
  my ($coordinates, $connections) = @_;
  my (@coordinates_weights, @weights, $task_count, $i, $j, $k,
      $scheduled_count, @left_vertices, $this_vertex, @these_paths, @this_path, $path_weight,
      $max_path_weight, $max_path_index, $done, $prioritized, @connection_array, $current_vertex,
      @temp, $max_vertex, $independent);

  #intialize and setup
  #####################################################  
  @coordinates_weights = split ",", $coordinates;
  $i = 0;
  $j = 0;
  while ($i < int(scalar @coordinates_weights)){
    if ($i % 3 == 2){
      $weights[$j] =$coordinates_weights[$i]; 
      $j++;
    } 
    $i++;  
  }
  $task_count = scalar @weights;
  @connection_array = split ",", $connections;
  $i = 0;
  while ($i < scalar @connection_array){$connection_array[$i]--;$i++;}
  # end intialize and setup
  #####################################################  

  # find all possible starting vertices ...
  @left_vertices=();
  $j = 0;
  while ($j < scalar @connection_array){
    $this_vertex = $connection_array[$j];
    push @left_vertices, $this_vertex;
    # check if the vertex was already found
    for ($k = 0; $k < scalar @left_vertices - 1; $k++){
      if ($this_vertex == $left_vertices[$k]){
        pop @left_vertices;
        $k = scalar @left_vertices - 1;
      }
    }
    # check if we have a right vertex
    $k = 1;
    while ($k < scalar @connection_array){
      if ($connection_array[$k]==$this_vertex){
        pop @left_vertices;
	$k = scalar @connection_array;
      }else{
        $k+=2;
      }
    }
    $j+=2;
  }
  # check for 'independent' tasks
  for ($j = 0; $j < $task_count; $j++){
    $independent = 1;
    # check if the vertex is connected 
    for ($k = 0; $k < scalar @connection_array; $k++){
      if ($connection_array[$k] == $j){
	$independent = 0;
      }
    }
    # add this independent task
    if ($independent && $coordinates_weights[$j * 3] != -1){push @left_vertices, $j;}
  }
  # find ALL paths ... 
  $j = 0;
  @these_paths = ();
  while ($j < scalar @left_vertices){
    $this_vertex = $left_vertices[$j];
    push  @these_paths, FindPathsSchedule($this_vertex, (join ",",@connection_array)); 
    $j ++;
  }
  # determine the CRITICAL path ... 
  $j = 0;
  $max_path_weight = 0;
  $max_path_index = 0;
  while ($j < scalar @these_paths){
    @this_path = split ",", $these_paths[$j];
    $current_vertex = $this_path[0];
    @temp = split ",", $these_paths[$max_path_index];
    $max_vertex = shift @temp; 
    $path_weight = 0;
    while (scalar @this_path > 0){
      $this_vertex = pop @this_path;
      $path_weight = $path_weight + $weights[$this_vertex];  
    }
    if ($path_weight > $max_path_weight){
      $max_path_weight = $path_weight; 
      $max_path_index = $j;
    }
    else{
      if ($path_weight == $max_path_weight){
        if ($current_vertex < $max_vertex){
	  $max_path_weight = $path_weight; 
	  $max_path_index = $j;
	}
	if ($current_vertex == $max_vertex){
	  # the paths need to be compared according to vertex labels ...
	  @temp = split ",", $these_paths[$max_path_index];
          $k = 0;
	  while ($k < scalar @temp && $k < scalar @this_path){
	    if ($this_path[$k] < $temp[$k]){
	      $max_path_weight = $path_weight; 
	      $max_path_index = $j;    
	      $k = scalar @temp - 1; 
	    }
	    if ($this_path[$k] > $temp[$k]){
	      $k = scalar @temp - 1;
	    }
	    $k++;
	  }
	}	  	
      }	  
    }        
    $j++;
  }
  # update and output
  $crit_path = $these_paths[$max_path_index];
  @temp = split ",", $crit_path;
  $j = 0;
  while ($j < scalar @temp){
    $temp[$j]++;
    $j++;
  }
  $crit_path = join ",", @temp;
  $crit_path = join "", "T", $crit_path;
  $crit_path =~ s/,/,T/g;
  $crit_path = join ";", $crit_path, $max_path_weight;
  $crit_path;
}




#######################################################################################################
#
# Name : PickSchedule
#
# Input		:	$random_flag  = if zero, empty or out-of-range, a random choice is made.  If positive
#					and in-range, this indexes the graph to use.  If "easy", then an 'easy'
#					graph is chosen.
#
# Output 	:	$graph_info    = $coordinates ; $connections where:
#
#				$coordinates   = "row (0, ... , 10), column (0, ... , 10), weight, ... ,  ... "
#				         	 The order determines the vertex index and label used.
#				$connections   = "vertex index (tail), vertex index (head), ... , ... "
#				         	 The vertex indices are taken according to the ordering in
#				         	 $coordinates.
#
########################################################################################################

sub PickSchedule{
  
  my ($random_flag) = @_;
  my ($temp,$coordinates, $connections, $this_graph, $graph_info, @vertex_data, @connect_data, @vertices_weights, $i);

  # screen the input variable ...
  if ($random_flag){
    $temp = $random_flag;
    if ($temp =~ "easy" || $temp =~ "Easy"){
      $random_flag =~ "easy";
    } else {
      for ($i = 0; $i < 10; $i++){$temp =~ s/$i//g;}
      if ($temp ne ""){$random_flag = 0;}
    }
  }

  # load some possible graphs ...
  $vertex_data[0] = "2,0,9,1,1,9,3,1,9,0,2,9,2,2,9,4,2,9,1,3,9,3,3,9";
  $connect_data[0] = "1,2,1,3,1,5,2,4,2,5,3,6,4,7,5,7,5,8,6,8,1,7";

  $vertex_data[1] = "1,0,14,0,3,14,1,6,36,2,3,14,4,0,4,3,1,6,3,5,16,5,1,4,5,3,4,5,5,16";
  $connect_data[1] = "1,2,1,4,5,6,5,8,6,4,8,9,9,10,4,7,2,3,4,3";

  $vertex_data[2] = "1,0,8,1,1,6,2,2,9,2,3,4,0,2,5,0,3,3,0,0,5,0,1,7";
  $connect_data[2] = "1,2,2,3,3,4,5,6,2,5";

  $vertex_data[3] = "0,0,2,1,0,1,2,0,1,3,0,1,1,3,3,2,4,3,3,3,3,4,2,3,0,2,8";
  $connect_data[3] = "1,9,4,5,4,6,4,7,4,8";

  $vertex_data[4] = "2,0,13,5,0,18,0,2,12,4,2,9,2,3,8,5,4,20";
  $connect_data[4] = "1,3,1,4,2,4,3,5,4,5,2,6";

  $vertex_data[5] = "1,0,1,1,1,1,0,2,1,2,2,1,1,3,1,2,4,1,2,5,1";
  $connect_data[5] = "1,2,2,3,2,4,4,5,3,5,4,6,6,7";

  $vertex_data[6] = "1,0,1,0,1,1,2,1,1,1,2,1,0,3,1,2,3,1,2,4,1";
  $connect_data[6] = "1,2,1,3,2,4,3,4,2,5,3,6,6,7";

  $vertex_data[7] = "0,0,10,1,0,3,2,0,8,0,3,15,1,3,4,2,3,20";
  $connect_data[7] = "2,4,2,5,3,5";

  $vertex_data[8] = "0,0,8,2,0,9,4,0,3,6,0,10,1,2,12,4,2,5,2,4,6,6,4,10";
  $connect_data[8] = "1,5,2,5,3,6,4,8,5,7,5,8";

  $vertex_data[9] = "0,0,8,0,2,6,0,4,3,2,0,5,2,2,2,2,4,9,4,0,7";
  $connect_data[9] = "1,2,4,2,4,5,2,3,5,3,5,6";

  $vertex_data[10] = "0,0,7,0,2,6,0,4,7,2,0,2,2,2,13,2,4,6,4,0,1,4,2,5,4,4,8";
  $connect_data[10] = "1,2,4,5,7,5,7,8,2,3,2,6,5,6,8,9";

  $vertex_data[11] = "1,0,8,0,1,5,2,1,6,1,2,5,0,3,7";
  $connect_data[11] = "1,2,1,3,2,4,2,5,3,4";

  $vertex_data[12] = "0,0,12,2,0,9,4,0,7,0,2,13,2,2,15,0,4,20,4,3,10";
  $connect_data[12] = "1,4,2,5,3,5,4,6,5,6,3,7,7,6";

  $vertex_data[13] = "1,0,8,1,1,6,2,2,9,2,4,4,0,2,5,0,4,3,0,0,5,0,1,7";
  $connect_data[13] = "1,2,2,5,2,3,5,6,3,4";

  $vertex_data[14] = "0,0,3,1,0,2,2,0,2,3,0,2,1,3,4,2,4,4,3,3,4,4,2,4,0,2,9";
  $connect_data[14] ="1,9,4,5,4,6,4,7,4,8"; 
  
  $vertex_data[15] = "0,0,1,1,0,1,2,0,1,3,0,1,4,0,10,5,0,10,6,0,10,0,3,3,1,3,3,2,3,3,3,3,3,1.5,4.5,10";
  $connect_data[15] =  "1,8,1,9,1,10,1,11,8,12,9,12,10,12,11,12";

  $vertex_data[16] = "1,0,14,0,3,14,1,6,36,2,3,14,4,0,4,3,1,6,3,5,16,5,1,4,5,3,4,5,5,16,4,6,20,0,7,30,2,7,10";
  $connect_data[16] = "1,2,1,4,5,6,5,8,6,4,8,9,9,10,4,7,2,3,4,3,10,11,7,11,3,12,3,13,7,13";

  $vertex_data[17] = "0,0,4,2,0,5,4,0,3,1.5,4,3,1,2,8,3,2,7";
  $connect_data[17] = "1,5,2,5,3,6,5,4,6,4";

  $vertex_data[18] = "0,0,3,0,3,5,0,6,8,2,0,4,2,3,6,2,6,2";
  $connect_data[18] = "1,2,1,5,4,5,2,3,5,3,5,6";

  $vertex_data[19] = "2,0,5,4,0,9,0,0,3,2,3,5,2,6,3,4,6,2,4,3,5";
  $connect_data[19] = "1,4,2,4,2,7,4,5,4,6";

  $vertex_data[20] = "0,0,8,2,1,10,0,2,12,2,3,15,0,4,5,2,5,9,2,7,8,0,6,13";
  $connect_data[20] = "1,3,2,3,2,4,3,5,4,6,5,6,5,8,6,7";

  $vertex_data[21] = "0,0,7,0,3,9,0,6,5,2,0,8,2,3,6,2,6,7";
  $connect_data[21] = "1,2,4,5,2,3,5,3,5,6,2,6";
  
  # ************ ADD ANY NEW GRAPHS HERE ********************
  
  # pick the graph
  if ($random_flag){
    if ($random_flag =~ "easy"){
      $this_graph = list_random(3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22)-1;
      # randomize the weights
      @vertices_weights = split ",",$vertex_data[$this_graph];
      $i = 2;
      while ($i < scalar @vertices_weights){
        $vertices_weights[$i] = list_random(1,2,5);
        $i+=3;
      }
      $vertex_data[$this_graph] = join ",", @vertices_weights;
    }
    else {
      if ($random_flag >= 1 && $random_flag <= scalar @vertex_data){
        $this_graph = $random_flag - 1;
      }else {
        $this_graph = random(0, (scalar @vertex_data) - 1, 1);
      }    
    }
  } else {
    $this_graph = random(0,(scalar @vertex_data)-1, 1);
    @vertices_weights = split ",",$vertex_data[$this_graph];
    $i = 2;
    while ($i < scalar @vertices_weights){
      $vertices_weights[$i] = random(1,9,1);
      $i+=3;
    }
    $vertex_data[$this_graph] = join ",", @vertices_weights;
  }
    
  # randomize the connectivity (?)

  # ready to output
  $coordinates = $vertex_data[$this_graph];
  $connections = $connect_data[$this_graph];
  $graph_info = join ";", $coordinates, $connections;  
  $graph_info;
}




#######################################################################################################
#
# Name : DrawProcessorSchedule
#
# Input		:	$coordinates   	= "row (0, ... , 10), column (0, ... , 10), weight, ... ,  ... "
#				          The order determines the vertex index and label used.  The 
#					  weights are needed to draw the schedules.
#			$done_list     	= The scheduling solution, for the current processor.
#
# Output 	:	$schedule_graph = graphics object.
#
########################################################################################################

sub DrawProcessorSchedule{

  my ($coordinates, $done_list) = @_;
  my ($i, $j, $max_weights, $window_size, $xlower, $xupper, $ylower, $yupper, $yuppermargin, $pic, @coordinates_weights, 
      @weights, @done_array, $total_time, $this_task_index, @break_lines, @scaled_break_lines,
      @shade_region, $label, $lower_region, $processor_label, $margin);

  @coordinates_weights = split ",", $coordinates;
  $i = 0;  $j = 0;
  $max_weight = 0;
  while ($i < int(scalar @coordinates_weights)){
    if ($i % 3 == 2){
      $weights[$j] =$coordinates_weights[$i]; 
      $max_weights += $weights[$j]; 
      $j++;
    } 
    $i++;  
  }
  @done_array = split ",", $done_list; 
  $processor_label = shift @done_array;

  # setup graph.  The size is essentially fixed here.
  $window_size = 4;
  $yuppermargin = 1;
  $margin = 5;
  $xlower = - $margin;
  $xupper = 100 + $margin;
  $ylower = -$margin;
  $yupper = 8 + $yuppermargin;
  $pic = init_graph($xlower, $ylower, $xupper, $yupper, 'pixels'=>[$window_size*($xupper-$xlower),$window_size*($yupper-  $ylower)]);
  $pic->moveTo($xlower + $margin,$ylower + $margin);
  $pic->lineTo($xupper - $margin, $ylower + $margin, 1);
  $pic->lineTo($xupper - $margin, $yupper - $yuppermargin, 1);
  $pic->lineTo($xlower + $margin, $yupper - $yuppermargin, 1);
  $pic->lineTo($xlower + $margin, $ylower + $margin, 1);
  
  # determine the total processing time, build the 'break_lines' and 'shade region' array
  $i = 0; $total_time = 0;
  while ($i < scalar @done_array){
    if ($done_array[$i] =~ "T"){
      $this_task_index = $done_array[$i];
      $this_task_index =~ s/T//g;
      $this_task_index--;
      $total_time +=  $weights[$this_task_index];
      $break_lines[$i] = $total_time;
      $shade_region[$i] = 1;
    } else {
      $total_time += $done_array[$i];
      $break_lines[$i] = $total_time;
      $shade_region[$i] = 0;  
    }
    $i++;
  }  
  # build the 'scaled break lines' array ...
  $i = 0;
  while ($i < @break_lines){
    $scaled_break_lines[$i] = (($xupper - $margin)-($xlower + $margin)) / $total_time * $break_lines[$i];
    $i++;
  }  
  # draw the processor schedule
  $label = new Label($xlower + $margin  / 2, (($yupper - $yuppermargin) + ($ylower + $margin)) * 2 / 3, $processor_label, 'black', 'center', 'center');
  $pic->lb($label);
  $label = new Label($xlower + $margin, $ylower + $margin * 3 / 4, "0", 'black', 'center', 'center');
  $pic->lb($label);          
  for ($i = 0; $i < scalar @scaled_break_lines; $i++){
      $pic->moveTo($scaled_break_lines[$i], $ylower + $margin);
      $pic->lineTo($scaled_break_lines[$i], $yupper - $yuppermargin);
      if ($shade_region[$i] == 1){
        if ($i == 0) {$lower_region = 0;} else {$lower_region = $scaled_break_lines[$i - 1];}
        $label = new Label(($scaled_break_lines[$i] + $lower_region) / 2, (($yupper - $yuppermargin) + ($ylower + $margin)) *2 / 3, $done_array[$i], 'black', 'center', 'center');
        $pic->lb($label);
        $pic->fillRegion([($scaled_break_lines[$i] + $lower_region) / 2, (($yupper - $yuppermargin) + ($ylower + $margin)) *2 / 3,'gray']);
      }
      $label = new Label($scaled_break_lines[$i], $ylower + $margin * 3 / 4, $break_lines[$i], 'black', 'center', 'center');
      $pic->lb($label);
  }
  $pic;
}




###
# Name	: FindMinimum
###

sub FindMinimum{
  my (@list) = @_;
  my ($minval, $i);
  $minval = $list[0];
  $i = 0;
  while ($i < scalar @list){
    if ($list[$i] < $minval){$minval = $list[$i];}
    $i++;
  }
  $minval;
}
1;
