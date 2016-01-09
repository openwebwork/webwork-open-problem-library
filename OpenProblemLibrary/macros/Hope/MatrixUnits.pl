=pod

=head1 NAME

MatrixUnits.pl 

=head1 SYNOPSIS

Generates unimodular n x n (n=2,3,4) MathObject matrices with real entries.

=head1 DESCRIPTION

This macro provides some routines for generating n x n (n=2,3,4) 
MathObject matrices with real entries that have determinant in the 
group of units of the integers Z (i.e., are Z-invertible).  A matrix 
C<$M = GLnZ();> (for det = +1 or -1) or <$M = SLnZ();> (for det = -1) 
has all integer entries, is invertible, and its inverse has all integer entries.
The matrix entries are intentionally chosen to be integers close to zero
(so, if you want unimodular matrices with larger integer entries, you
may want to copy the source code and modify it to suit your needs).
The basic idea is to multiply several elementary matrices of 
determinant +1 or -1 together to get a unimodular matrix (although the
code below accomplishes this by elementary row operations rather
than by multiplication of elementary matrices).

=over 12

=item  To produce a determinant +1 or -1 MathObject matrix C<$A>, use C<$A = GL2Z();>, C<$A = GL3Z();>, C<$A = GL4Z();>

=item  To produce a determinant +1 MathObject matrix C<$A>, use C<$A = SL2Z();>, C<$A = SL3Z();>, C<$A = SL4Z();>

=item  For determinant +1 or -1 perl arrays, use C<@a = GL2Z_perl();>, C<@a = GL3Z_perl();>, C<@a = GL4Z_perl();>

=item  For determinant +1 perl arrays, use C<@a = SL2Z_perl();>, C<@a = SL3Z_perl();>, C<@a = SL4Z_perl();>

=back

Note that the indexing on MathObject matrices starts at 1, while the indexing 
on perl arrays starts at 0, so that C<$A-<gt>element(1,1);> corresponds to
C<$a[0][0];>.  The perl arrays can be made into MathObject matrices by
C<$A = Matrix(@a);>, and this is, in fact, what the C<GLnZ()> and C<SLnZ()>
subroutines do for you.  The perl versions C<@a = GLnZ_perl()> and 
C<@a = SLnZ_perl()> are useful if you want to have quick access to the matrix 
values (as perl reals stored in C<@a>) without having to pull them out of a 
MathObject matrix via C<@b = $A-<gt>value;> (in which case C<@b> is an
array of MathObject reals).

Note: There is overlap between MatrixUnits.pl (written after MathObject 
matrices were created) and MatrixUnimodular.pl (written before MathObject
matrices were created).  MatrixUnimodular.pl was left unchanged to provide
legacy support for existing PG files.

=head1 AUTHORS

Paul Pearson, Hope College, Department of Mathematics

=cut

sub _MatrixUnits_init {}; # don't reload this file

loadMacros("MathObjects.pl",);

################################################
#  

sub GL2Z {
  my @a = GL2Z_perl();
  return Matrix(@a);
}

sub GL2Z_perl {

  # Create an invertible 2 x 2 matrix with determinant either 1  or -1

  my $a11 = random(-1,1,2);
  my $a12 = non_zero_random(-3,3,1);
  my $mult = non_zero_random(-2,2,1);
  my $a21 = $mult * $a11;
  my $b1 = random(-1,1,2);
  my $a22 = $mult * $a12 + $b1;

  # $a_det = $a11 * $b1;
  return ([$a11,$a12],[$a21,$a22]);
  
}

###################################################

sub SL2Z {
  my @a = SL2Z_perl();
  return Matrix(@a);
}

sub SL2Z_perl {

  # Create an invertible 2 x 2 matrix with determinant 1

  my $a11 = random(-1,1,2);
  my $a12 = non_zero_random(-3,3,1);
  my $mult = non_zero_random(-2,2,1);
  my $a21 = $mult * $a11;
  my $b1 = random(-1,1,2);
  my $a22 = $mult * $a12 + $b1;

  my $a_det = $a11 * $b1;
  
  if ($a_det == 1) {
    return ([$a11,$a12],[$a21,$a22]);
  } else { # det = -1, so swap rows to make det = 1
    return ([$a21,$a22],[$a11,$a12]);
  }

}

#######################################################

sub GL3Z {
  my @a = GL3Z_perl();
  return Matrix(@a);
}

sub GL3Z_perl {

  # Create an invertible 3 x 3 matrix with determinant either 1  or -1

  my $a11 = random(-2,2,1);
  my $a21 = random(-1,1,2);
  my $a31 = random(-1,1,2);

  my $b1 = random(-1,1,2);
  my $a12 = $b1 * $a11;
  my $m = random(-1,1,2);
  my $a22 = $b1 * $a21 + $m;
  my $a32 = $b1 * $a31;

  my $c = random(-1,1,1);
  my $d = random(-1,1,2);
  my $n = random(-1,1,2);
  my $a13 = $c * $a11 + $d * $a12 + $n;
  my $a23 = $c * $a21 + $d * $a22;
  my $a33 = $c * $a31 + $d * $a32;

  # $det = - $a31 * $m * $n;

  return ([$a11,$a12,$a13],[$a21,$a22,$a23],[$a31,$a32,$a33]);

}


########################################################

sub SL3Z {
  my @a = SL3Z_perl();
  return Matrix(@a);
}

sub SL3Z_perl {

  # Create an invertible 3 x 3 matrix with determinant 1

  my $a11 = random(-2,2,1);
  my $a21 = random(-1,1,2);
  my $a31 = random(-1,1,2);

  my $b1 = random(-1,1,2);
  my $a12 = $b1 * $a11;
  my $m = random(-1,1,2);
  my $a22 = $b1 * $a21 + $m;
  my $a32 = $b1 * $a31;

  my $c = random(-1,1,1);
  my $d = random(-1,1,2);
  my $n = random(-1,1,2);
  my $a13 = $c * $a11 + $d * $a12 + $n;
  my $a23 = $c * $a21 + $d * $a22;
  my $a33 = $c * $a31 + $d * $a32;

  my $det = - $a31 * $m * $n;

  if ($det == 1) { 
      return ([$a11,$a12,$a13],[$a21,$a22,$a23],[$a31,$a32,$a33]); 
  } else { # det = -1, so swap two rows so that det = +1. 
      return ([$a21,$a22,$a23],[$a11,$a12,$a13],[$a31,$a32,$a33]); 
  }

}


#######################################################

sub GL4Z {
  my @a = GL4Z_perl();
  return Matrix(@a);
}


sub GL4Z_perl {

  # Create an invertible 4 x 4 matrix with determinant either 1  or -1

  my @a = ();
  $a[1][1] = random(-2,2,1);
  $a[2][1] = random(-1,1,2);
  $a[3][1] = random(-1,1,2);
  $a[4][1] = random(-1,1,1);

  my $b1 = random(-1,1,2);
  foreach my $i (1..4) { 
	$a[$i][2] = $b1 * $a[$i][1];
  }
  my $p = random(-1,1,2);
  $a[2][2] = $a[2][2] + $p;

  my $c = random(-1,1,1);
  my $d = random(-1,1,2);
  my $n = random(-1,1,2);
  foreach my $i (1..4) {
	$a[$i][3] = $c * $a[$i][1] + $d * $a[$i][2];
  }
  my $n = random(-1,1,2);
  $a[1][3] = $a[1][3] + $n;

  my $f = random(-1,1,2);
  my $g = random(-1,1,1);
  my $h = random(-1,1,1);
  foreach my $i (1..4) {
	$a[$i][4] = $f * $a[$i][1] + $g * $a[$i][2] + $h * $a[$i][3];  
  }
  my $q = random(-1,1,2);
  $a[4][4] = $a[4][4] + $q;

  # my $det = - $a[3][1] * $p * $n * $q;

  return (
  [ $a[1][1], $a[1][2], $a[1][3], $a[1][4] ],
  [ $a[2][1], $a[2][2], $a[2][3], $a[2][4] ],
  [ $a[3][1], $a[3][2], $a[3][3], $a[3][4] ],
  [ $a[4][1], $a[4][2], $a[4][3], $a[4][4] ]
  );

}


sub SL4Z {
  my @a = SL4Z_perl();
  return Matrix(@a);
}

sub SL4Z_perl {

  # Create an invertible 4 x 4 matrix with determinant 1

  my @a = ();
  $a[1][1] = random(-2,2,1);
  $a[2][1] = random(-1,1,2);
  $a[3][1] = random(-1,1,2);
  $a[4][1] = random(-1,1,1);

  my $b1 = random(-1,1,2);
  foreach my $i (1..4) { 
	$a[$i][2] = $b1 * $a[$i][1];
  }
  my $p = random(-1,1,2);
  $a[2][2] = $a[2][2] + $p;

  my $c = random(-1,1,1);
  my $d = random(-1,1,2);
  my $n = random(-1,1,2);
  foreach my $i (1..4) {
	$a[$i][3] = $c * $a[$i][1] + $d * $a[$i][2];
  }
  my $n = random(-1,1,2);
  $a[1][3] = $a[1][3] + $n;

  my $f = random(-1,1,2);
  my $g = random(-1,1,1);
  my $h = random(-1,1,1);
  foreach my $i (1..4) {
	$a[$i][4] = $f * $a[$i][1] + $g * $a[$i][2] + $h * $a[$i][3];  
  }
  my $q = random(-1,1,2);
  $a[4][4] = $a[4][4] + $q;

  my $det = - $a[3][1] * $p * $n * $q;

  if ($det == 1) {

    return (
    [ $a[1][1], $a[1][2], $a[1][3], $a[1][4] ],
    [ $a[2][1], $a[2][2], $a[2][3], $a[2][4] ],
    [ $a[3][1], $a[3][2], $a[3][3], $a[3][4] ],
    [ $a[4][1], $a[4][2], $a[4][3], $a[4][4] ]
    );

  } else { # det = -1, so swap two rows to make it have det = 1

    return (
    [ $a[1][1], $a[1][2], $a[1][3], $a[1][4] ],
    [ $a[3][1], $a[3][2], $a[3][3], $a[3][4] ],
    [ $a[2][1], $a[2][2], $a[2][3], $a[2][4] ],
    [ $a[4][1], $a[4][2], $a[4][3], $a[4][4] ]
    );

  }

}

##################################################

1;