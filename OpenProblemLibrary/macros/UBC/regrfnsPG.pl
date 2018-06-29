
# functions for simple linear regression in perl

#/* "a","b" are the two endpoints of the range of 
#   random integers to be produced. */
# inputs $a,$b are integers
#sub rndgen
#{ local($a,$b,$r);
#  $a=$_[0]; $b=$_[1];
#  $r=rand($b-$a+1); # in (0,b-a+1)
#  #print $a," ",$b," ",$r,"\n";
#  $r=int($r)+$a; # between a,b inclusive
#  $r;
#}

# N (size of population) and ssize (sample size) are inputs
sub isamp  
{ local($N,$ssize,$N1,$j,$k,$temp,@x,@xsub);
  $N=$_[0]; $ssize=$_[1]; $N1=$N-1;
  @x= 0..$N1;
  for($j=0; $j<$ssize; $j++)
  { #$k=rndgen($j,$N1);
    $k=random($j,$N1,1);  # using function in WebWork
    $temp=$x[$j]; $x[$j]=$x[$k]; $x[$k]=$temp;
  }
  #for($j=0; $j<$ssize; $j++) { $xsub[$j]=$x[$j]; }
  @xsub=@x[0..($ssize-1)];
  @xsub;
}

# simple linear regression
# input xvec, yvec : assumed as one vector here
# output ($n,$xbar,$ybar,$sx2,$sy2,$sxy,$b0,$b1,$sse,$mse,$x0);
sub lsreg
{ local($n,$i,$xi,$yi,$sx1,$sx2,$sy1,$sy2,$sxy,$xbar,$ybar,$b0,$b1,$sse,$mse);
  $n=($#_+1)/2;
  #print $n,"\n";
  $sx1=0; $sx2=0; $sy1=0; $sy2=0; $sxy=0; 
  for($i=0;$i<$n;$i++)
  { #$xi=$xx[$i]; $yi=$yy[$i];
    $xi=$_[$i]; $yi=$_[$i+$n];
    $sx1=$sx1+$xi; $sx2=$sx2+$xi*$xi;
    $sy1=$sy1+$yi; $sy2=$sy2+$yi*$yi;
    $sxy=$sxy+$xi*$yi;
  }
  $xbar=$sx1/$n; $ybar=$sy1/$n;
  $sx2=($sx2-$n*$xbar**2)/($n-1);
  $sy2=($sy2-$n*$ybar**2)/($n-1);
  $sxy=($sxy-$n*$xbar*$ybar)/($n-1);
  $b1=$sxy/$sx2; $b0=$ybar-$b1*$xbar;
  $sse=($sy2-$sxy**2/$sx2)*($n-1);
  $mse=$sse/($n-2);
  @out=($n,$xbar,$ybar,$sx2,$sy2,$sxy,$b0,$b1,$sse,$mse);
  @out;
}

# subpopulation mean at x0 
#sqrt(mse*(1/n+(x0-xbar)^2/((n-1)*sx2)))
# input : output of lsreg, plus x0
#  or ($n,$xbar,$ybar,$sx2,$sy2,$sxy,$b0,$b1,$sse,$mse,$x0);
# output: point estimate and SE
sub subpopmeanint
{ local($n,$xbar,$sx2,$b0,$b1,$x0,$muygx,$semu,@out);
  $n=$_[0];
  $xbar=$_[1];
  $sx2=$_[3];
  $b0=$_[6];
  $b1=$_[7];
  $mse=$_[9];
  $x0=$_[10];
  $muygx=$b0+$b1*$x0;
  $semu= sqrt($mse*(1/$n+($x0-$xbar)**2/(($n-1)*$sx2)));
  @out=($muygx,$semu);
  @out;
}

#prediction interval at x=x0
#sqrt(mse*(1+1/n+(x0-xbar)^2/((n-1)*sx2)))
# input : output of lsreg, plus x0
# ($n,$xbar,$ybar,$sx2,$sy2,$sxy,$b0,$b1,$sse,$mse,$x0);
# output: point estimate and SE
sub predint
{ local($n,$xbar,$sx2,$b0,$b1,$x0,$muygx,$semu,@out);
  $n=$_[0];
  $xbar=$_[1];
  $sx2=$_[3];
  $b0=$_[6];
  $b1=$_[7];
  $mse=$_[9];
  $x0=$_[10];
  $muygx=$b0+$b1*$x0;
  $semu= sqrt($mse*(1+1/$n+($x0-$xbar)**2/(($n-1)*$sx2)));
  @out=($muygx,$semu);
  @out;
}

1; #return true

