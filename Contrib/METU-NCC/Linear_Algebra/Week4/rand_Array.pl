#######################################################
#  Written by Benjamin Walter,  2020
#   METU-NCC Mathematics Research and Teaching Group
#######################################################

=head1 NAME

       rand_Array.pl

Provides macros for generating random matrix arrays.

=cut

loadMacros("PGchoicemacros.pl");   # needed for shuffle()


=head3 rand_Array_2nonzero

Usage rand_Array_2nonzero(n, [m=n], [size=2])

Creates a random n x m array with 2 nonzero elements in each row
by performing a row/column permutation on array with 1 on diagonal 
and nonzero of max value = size on superdiagonal.

=cut


sub rand_Array_2nonzero {
  my ($n, $m, $size) = @_;
  $m //= $n;
  $size //= 2;

  my @rand_Array;
  my @p = shuffle($n);
  my @q = shuffle($m);
  foreach my $i (0..$n-1) {
    foreach my $j (0..$m-1) {
      $rand_Array[$p[$i]][$q[$j]] = ($j==$i) ? 1 :
                                    ($j==($i+1)%$m) ? non_zero_random(-$size,$size) : 0;
    }
  }
  return (@rand_Array);
}



=head3 rand_Array_triangle

Usage rand_Array_triangle(n, [m=n], [size=2])

Creates a random n x m array by performing row/column permutation to
upper triangular matrix with 1 on diagonal.

=cut


sub rand_Array_triangle {
  my ($n, $m, $size) = @_;
  $m //= $n;
  $size //= 2;

  my @rand_Array;
  my @p = shuffle($n);
  my @q = shuffle($m);
  foreach my $i (0..$n-1) {
    foreach my $j (0..$m-1) {
      $rand_Array[$p[$i]][$q[$j]] = ($j==$i) ? 1 :
                                    ($j>$i)  ? non_zero_random(-$size,$size) : 0;
    }
  }
  return (@rand_Array);
}


=head3 rand_Array_En

Usage rand_Array_En(n, [m=n], [size=2], [k=1])

Creates a random n x m array by performing row/column permutation to
product of k elementary matrices (k nonzero off-diagonal terms).

=cut

sub rand_Array_En {             # product of elementary matrices
  my ($n, $m, $size, $k) = @_;  # matrix dim = n x m
  $m //= $n;                    # off-diag max size = size
  $size //= 2;                  # k = number of nonzero off-diag
  $k //= 1;                     #    (at most one per row)

  my @rand_Array;
  my @p = shuffle($n);
  my @q = shuffle($m);
  foreach my $i (0..$n-1) {
    foreach my $j (0..$m-1) {
      $rand_Array[$p[$i]][$q[$j]] = ($j==$i) ? 1 : 0;
    }
  }
  my @a = shuffle($n); 
  foreach my $i (0..min($n-1,$k-1)) {
    my $b = random(0,$m-1);
    do { $b = random(0,$m-1); } while ($a[$i]==$b);
    $rand_Array[$p[$a[$i]]][$q[$b]] = non_zero_random(-$size,$size);
  }
  return (@rand_Array);
}


=head3 rand_Array_En

Usage rand_Array_En(n, [m=n])

Creates a random n x m array which is a row/column permutation of
a diagonal matrix. 

=cut


sub rand_Array_perm {
  my ($n, $m) = @_;
  $m //= $n;

  my @rand_Array;
  my @p = shuffle($n);
  my @q = shuffle($m);
  foreach my $i (0..$n-1) {
    foreach my $j (0..$m-1) {
      $rand_Array[$p[$i]][$q[$j]] = ($j==$i) ? 1 : 0;
    }
  }
  return (@rand_Array);
}



=head3 ident_Array 

Usage ident_Array(n, [m=n])

Creates an n x m diagonal array.

=cut


sub ident_Array {
  my ($n, $m) = @_;
  $m //= $n;

  my @ident;
  foreach my $i (0..$n-1) {
    foreach my $j (0..$m-1) {
      $ident[$i][$j] = ($j==$i) ? 1 : 0;
    }
  }
  return (@ident);
}



=head3 pick

Usage pick(n, (array))

Picks n elements out of (array)

=cut

 
sub pick {
  my ($k, @in) = @_;
  my @out = ();
  while (@out < $k) { push( @out, splice(@in, random(0,$#in), 1) ); }
  @out;
}




1;
