BEGIN {
	be_strict();
}

package Chromatic;


  
sub ChromNum {
  my ($graph) = @_;
  my ($i, $j, @adj, $val, $size, $count, @edges, $fileout, $ctime, $fh, $fname);
  $ctime = time;
  $fileout = "/opt/webwork/webwork2/tmp/graph.$ctime.txt";

  sub matrix_graph {
    my ($graph) = @_;
    $graph =~ s/\A\s*//;
    $graph =~ s/;\s*\Z//;

    my (@m, $size, $i, $j, @r, @matrix);
    @m=split /\s*[;]\s*/ , $graph;
    $size=scalar @m;
    @matrix=();
    for ($i=0; $i<$size ; $i++) {
      @r=split /\s+/, $m[$i];
      for ($j=0; $j<$size;$j++) {
        $matrix[$i][$j]=$r[$j];
      }
    }
    @matrix;
  }

  @adj = matrix_graph($graph);
  $count = 0;
  $size = scalar @adj;

  for ($i = 0; $i < $size; $i++){
    for ($j = $i + 1; $j < $size; $j++){
      if ($adj[$i][$j] != 0){
        $count++;
        push @edges, $i + 1, $j + 1;
      }
    }
  }

# This is not quite good enough to avoid race conditions but it'll do.
  while (-e "$fileout") {
    sleep 1;
  }
  open OUT , ">$fileout";
  print OUT "$size $count\n";

  for ($i = 0; $i < scalar @edges; $i+=2){
    print OUT "$edges[$i] $edges[$i+1]\n";
  }
  close (OUT);

# This does not work, don't know why. It's probably unsecure anyway.
#  unless (-e '/opt/webwork/pg/lib/chromatic/color') {
#    `cd /opt/webwork/pg/lib/chromatic; gcc color.c -o color`;
#  }
  $val = qx[/opt/webwork/pg/lib/chromatic/color $fileout];
  $val =~  /value (\d+)/g;
  qx[rm $fileout];
  $1;
}

sub chn{
"Blah";
}
1;
