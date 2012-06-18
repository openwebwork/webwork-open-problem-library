sub _MatrixUnimodular_init {}; # don't reload this file


sub xgcd ($$) {

  # Extended greatest common divisor
  # xgcd( a , b ) = ( d , x , y , s , t ) 
  # where 
  # gcd(a,b) = d = a (x + s k) + b (y + t k)  for any integer k

  my  ($a, $x, $y) = ( int(shift) , 1 , 0 ) ;
  my  ($b, $s, $t) = ( int(shift) , 0 , 1 ) ;

  my ($A,$B) = ($a,$b) ;

  while  ( $b != 0 )  {
    my  $q = int( $a / $b ) ;
    ($a, $x, $y, $b, $s, $t) = ($b, $s, $t, $a-$q*$b, $x-$q*$s, $y-$q*$t);
  }

  if ($a < 0) {
      return ( -$a, -$x, -$y, $s, $t ) ; }
  else {
      return ( $a, $x, $y, $s, $t ) ;
  }
}



sub unimodular_SL2Z_specific {

  # Unimodular 2x2 matrix in SL_2(Z)
  # unimodular( a11, a21 ) 
  # returns a determinant 1 matrix object  
  # [ a11  a12 ]
  # [ a21  a22 ]
  # The inputs a11 and a12 must be relatively prime
  # integers, and could be thought of as an eigenvector.
  # If they are not relatively prime, then the identity
  # matrix will be returned.

  my $a11 = shift;
  my $a21 = shift;

  my @w = xgcd($a11,$a21); # "weights"

  if ($w[0] != 1) { return (1,0,0,1); }
  #  my $a12 = -($w[2]);
  #  my $a22 = $w[1];

  @A = ( $a11, $a21, -($w[2]), $w[1] );

  return @A;

}



sub unimodular_SL2Z {

  # Unimodular 2x2 matrix in SL_2(Z)
  # unimodular ( A, B ) = ( a11, a21, a12, a22 )
  # where 
  # [ a11  a12 ]
  # [ a21  a22 ]
  # is a determinant one matrix with integer entries
  # and the inputs A < B are the limits of the size of the entries 
  # If they are not relatively prime, then the identity
  # matrix will be returned.
  # Note: it returns a matrix listed by columns (not rows)
  # so that you can easily use the columns as eigenvectors

  my $a11 = list_random(-7,-5,-3,-2,2,3,5,7);
  my $a21 = list_random(-7,-5,-3,-2,2,3,5,7);
  while ($a11 == $a21 || $a11 == -($a21)) { 
     $a21 = list_random(-7,-5,-3,-2,2,3,5,7); 
  };

  my @w = xgcd($a11,$a21);

  #  my $a12 = -($w[2]);
  #  my $a22 = $w[1];

  my @A = ( $a11, $a21, -($w[2]), $w[1] );

  return @A;

}



sub unimodular_GL2Z {

  # Unimodular 2x2 matrix in GL_2(Z)
  # unimodular ( A, B ) = ( a11, a21, a12, a22, det )
  # where 
  # [ a11  a12 ]
  # [ a21  a22 ]
  # is a determinant 1 or -1 matrix with integer entries
  # and det is the determinant.
  # If they are not relatively prime, then the identity
  # matrix will be returned.
  # Note: it returns a matrix listed by columns (not rows)
  # so that you can easily use the columns as eigenvectors.

  my $a11 = list_random(-7,-5,-3,-2,2,3,5,7);
  my $a21 = list_random(-7,-5,-3,-2,2,3,5,7);
  while ($a11 == $a21 || $a11 == -($a21)) { 
     $a21 = list_random(-7,-5,-3,-2,2,3,5,7); 
  };

  my @w = xgcd($a11,$a21);

  #  my $a12 = -($w[2]);
  #  my $a22 = $w[1];

  my $s = random(-1,1,2); # randomize the sign for the first column

  my @A = ( $s * $a11, $s * $a21, -($w[2]), $w[1] );

  return @A;

}


sub unimodular_diagonalization_SL2Z {

  # input: two distinct integer eigenvalues (lambda1, lambda2)
  #
  # output: a single array with the following entries in order:
  # 2x2 matrix listed by columns (A11,A21,A12,A22),
  # first eigenvalue lambda1, first eigenvector (P11,P21),
  # second eigenvalue lambda2, second eigenvector (P12,P22)

  my $lambda1 = shift;
  my $lambda2 = shift;

  my @P = unimodular_SL2Z();

  # A = P D P^(-1), where D is diagonal with $lambda1 and $lambda2

  my @A = (
    $P[0] * $P[3] * $lambda1 - $P[1] * $P[2] * $lambda2,
    $P[1] * $P[3] * $lambda1 - $P[1] * $P[3] * $lambda2,
    $P[0] * $P[2] * $lambda2 - $P[0] * $P[2] * $lambda1,
    $P[0] * $P[3] * $lambda2 - $P[1] * $P[2] * $lambda1 
  );

  return ( @A, @P, $lambda1, $lambda2 );

}


sub unimodular_diagonalization_GL2Z {

  # input: two distinct integer eigenvalues (lambda1, lambda2)
  #
  # output: a single array with the following entries in order:
  # 2x2 matrix listed by columns (M11,M21,M12,M22),
  # first eigenvalue lambda1, first eigenvector (P11,P21),
  # second eigenvalue lambda2, second eigenvector (P12,P22)

  my $lambda1 = shift;
  my $lambda2 = shift;

  my @P = unimodular_GL2Z();
  my $detP = $P[0] * $P[3] - $P[1] * $P[2];

  # A = P D P^(-1), where D is diagonal [ [lambda1,0], [0,lambda1] ]
  my @A = ( 
    $detP * $P[0] * $P[3] * $lambda1 - $detP * $P[1] * $P[2] * $lambda2,
    $detP * $P[1] * $P[3] * $lambda1 - $detP * $P[1] * $P[3] * $lambda2,
    $detP * $P[0] * $P[2] * $lambda2 - $detP * $P[0] * $P[2] * $lambda1,
    $detP * $P[0] * $P[3] * $lambda2 - $detP * $P[1] * $P[2] * $lambda1
  );

  return ( @A, @P, $lambda1, $lambda2 );

}



###############################################################
#  Versions with small integer entries

sub small_unimodular_GL2Z {

  # Unimodular 2x2 matrix in GL_2(Z)
  # unimodular ( A, B ) = ( a11, a21, a12, a22, det )
  # where 
  # [ a11  a12 ]
  # [ a21  a22 ]
  # is a determinant 1 or -1 matrix with integer entries
  # and det is the determinant.
  # If they are not relatively prime, then the identity
  # matrix will be returned.
  # Note: it returns a matrix listed by columns (not rows)
  # so that you can easily use the columns as eigenvectors.

  my $a11 = list_random(-4,-3,-2,2,3,4);
  my $a21 = list_random(-4,-3,-2,2,3,4);
  while ($a11 == $a21 || $a11 == -($a21) || gcd($a11,$a21) != 1) { 
     $a21 = list_random(-4,-3,-2,2,3,4); 
  };

  my @w = xgcd($a11,$a21);

  #  my $a12 = -($w[2]);
  #  my $a22 = $w[1];

  my $s = random(-1,1,2); # randomize the sign for the first column

  my @A = ( $s * $a11, $s * $a21, -($w[2]), $w[1] );

  return @A;

}


sub small_unimodular_diagonalization_GL2Z {

  # input: two distinct integer eigenvalues (lambda1, lambda2)
  #
  # output: a single array with the following entries in order:
  # 2x2 matrix listed by columns (M11,M21,M12,M22),
  # first eigenvalue lambda1, first eigenvector (P11,P21),
  # second eigenvalue lambda2, second eigenvector (P12,P22)

  my $lambda1 = shift;
  my $lambda2 = shift;

  my @P = small_unimodular_GL2Z();
  my $detP = $P[0] * $P[3] - $P[1] * $P[2];

  # A = P D P^(-1), where D is diagonal [ [lambda1,0], [0,lambda1] ]
  my @A = ( 
    $detP * $P[0] * $P[3] * $lambda1 - $detP * $P[1] * $P[2] * $lambda2,
    $detP * $P[1] * $P[3] * $lambda1 - $detP * $P[1] * $P[3] * $lambda2,
    $detP * $P[0] * $P[2] * $lambda2 - $detP * $P[0] * $P[2] * $lambda1,
    $detP * $P[0] * $P[3] * $lambda2 - $detP * $P[1] * $P[2] * $lambda1
  );

  return ( @A, @P, $lambda1, $lambda2 );

}


1;