sub PGnextfit{
  my($binsize,@input) = @_;
  my(@list, $val);

  $sum=0;
  $bin=1;
  foreach $val(@input){
    $sum+=$val;
    if ($sum >$binsize){
       $bin++;
       $sum=$val;
    }
  push @list,$bin;
}
@list;
}

sub PGdec_sort{
  my(@input) = @_;
  my(@list, @newlist, $val, $newval);
  
  foreach $val(@input){
    $newval=-$val; 
    push @newlist, $newval;
    }
  @list1=num_sort @newlist;
  foreach $val(@list1) {
    $newval=-$val; 
    push @list, $newval;
  }
@list;
}
                         
sub PGdnextfit{
  my($binsize,@input) = @_;
  my(@list, @newlist, $val);
  
  @newlist=PGdec_sort(@input);
  
  $sum=0;
  $bin=1;
  foreach $val(@newlist){
    $sum+=$val;
    if ($sum >$binsize){
       $bin++;
       $sum=$val;
    }
  push @list,$bin;
}
@list;
}

sub PGfirstfit{
  my($binsize,@input) = @_;
  my(@list, @total, $val, $bin, $sum, $size);
  
  @total = ();
  @list=();
  
  foreach $val(@input){
    $bin=-1;
    $size = scalar @total;

    do{$bin++;        
       if($bin > $size - 1){push @total,0;}
       $sum=$total[$bin]+$val;
    }
    while($sum > $binsize);

   $total[$bin]+=$val;
   push @list,$bin+1;
  }

@list;
}

sub PGdfirstfit{
  my($binsize,@input) = @_;
  my(@list,@newlist,@total,$bin,$val,$sum,$size);
  
  @total=();
  
  @newlist=PGdec_sort(@input);
  foreach $val(@newlist){
   $bin=-1;
   $size=scalar@total;
    do{$bin++;
      if($bin>$size-1){push @total,0;} 
      $sum=$total[$bin]+$val;
       
    }
    while( $sum > $binsize );
   $total[$bin] += $val;
   push @list, $bin+1;
  }
@list;
}

sub PGworstfit{
  my( $binsize, @input )=@_;
  my( $minbin, $bin, $sum, $minloc, $val, $minval, $a, @total, @bins );
  
  @total = (0);
  $minval = 0;
  $minbin = 0;
  $bin = 0;
  
  foreach $val( @input ){
   
   $sum = $minval + $val;
   
     if( $sum > $binsize ){
        push @total, $val;
        $bin = scalar@total - 1;
     	
       if( $val < $minval ){
         $minbin = scalar@total - 1;
         $minval = $val;
       } else{ $minval = $total[$minbin];
         } 
     } else{ $total[$minbin] += $val;
        $bin = $minbin;
	if( $total[$minbin] < min( @total )){
	  $minval = $total[$minbin];
	}  
        else{$minloc = -1;
         $a = min( @total );
	 do{$minloc++;
	 } until( $total[$minloc] == $a );
	   $minbin = $minloc;
	   $minval = $total[$minbin];
       }
      } push @bins, $bin+1;
}
@bins;
}

sub PGdworstfit{
  my($binsize, @input)=@_;
  my($minbin, $bin, $sum, $minloc, $val, $minval, $a, @total, @bins, @newlist );
  
  @newlist = PGdec_sort(@input);
  
  @total = (0);
  $minval = 0;
  $minbin = 0;
  $bin = 0;
  
  foreach $val( @newlist ){
   
   $sum = $minval+$val;
   
     if( $sum > $binsize ){
        push @total, $val;
        $bin = scalar@total-1;
     	
       if( $val < $minval ){
         $minbin = scalar@total-1;
         $minval = $val;
       } else{ $minval = $total[ $minbin ];
         } 
     } else{ $total[ $minbin ] += $val;
        $bin = $minbin;
	if( $total[ $minbin ] < min( @total )){
	  $minval = $total[ $minbin ];
	}  
        else{$minloc = -1;
         $a = min( @total );
	 do{$minloc++;
	 } until($total[ $minloc ] == $a);
	   $minbin = $minloc;
	   $minval = $total[ $minbin ];
       }
     } push @bins, $bin+1;
      
  } 
@bins;
}          	   

1;																	 