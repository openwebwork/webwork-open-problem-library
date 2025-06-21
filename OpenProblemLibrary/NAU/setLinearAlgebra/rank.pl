# returns the rank of a matrix
# original code by Christopher Heckman modified by Nandor

sub rank {
   Context('Fraction');
   my $R = rref(apply_fraction_to_matrix_entries(shift));
   my ($row,$col) = $R->dimensions;
   my ($r,$c) = (1,1);
   while (($r <= $row) && ($c <= $col)) {
      $r++ if ($R->element($r,$c) > 0.5);
      $c ++;
   }
   $r - 1;
}

1;
