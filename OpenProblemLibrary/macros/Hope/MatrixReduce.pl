sub _MatrixReduce_init {}; # don't reload this file

=pod

=head1 NAME

MatrixReduce.pl - reduced row echelon form, row 
operations, and elementary matrices.

=head1 SYNOPSIS

Provides subroutines for elementary matrix 
computations using MathObjects matrices.

=over 12

=item Get the reduced row echelon form: C<$Areduced = rref($A);>  Should be used in the fraction context with all entries of $A made into fractions.

=item Make matrix entries do fraction arithmetic (rather than decimal arithmetic): After selecting the Fraction context using Context('Fraction')->parens->set("[" => {formMatrix => 1}), C<$A = apply_fraction_to_matrix_entries($A);> applies Fraction() to all of the entries of $A, which makes subsequent matrix algebra computations with $A use fraction arithmetic.

=item Get the reduced column echelon form: C<$Areduced = rcef($A);>

=item Change the value of a matrix entry: C<change_matrix_entry($A,[2,3],50);> changes the [2,3] entry to the value 50.

=item Construct an n x n identity matrix: C<$E = identity_matrix(5);>

=item Construct an n x n elementary matrix that will permute rows i and j: C<$E = elem_matrix_row_switch(5,2,4);> creates a 5 x 5 identity matrix and swaps rows 2 and 4.

=item Construct an n x n elementary matrix that will multiply row i by s: C<$E = elem_matrix_row_mult(5,2,4);> creates a 5 x 5 identity matrix and swaps puts 4 in the second spot on the diagonal.

=item Construct an n x n elementary matrix that will multiply row i by s: C<$E3 = elem_matrix_row_add(5,3,1,35);> creates a 5 x 5 identity matrix and swaps puts 35 in the (3,1) position.

=item Perform the row switch transform that swaps (row i) with (row j): C<$Areduced = row_switch($A,2,4);> swaps rows 2 and 4 in matrix $A.

=item Perform the row multiplication transform s * (row i) placed into (row i): C<$Areduced = row_mult(A,2,10);> multiplies every entry in row 2 of $A by 10.

=item Perform the row addition transform (row i) + s * (row j) placed into (row i): C<$Areduced = row_add($A,2,1,10);> adds 10 times row 1 to row 2 and places the result in row 2.  (Same as constructing $E to be the identity with 10 placed in entry (2,1), then multiplying $E * $A.)

=back

=head1 DESCRIPTION

Usage:

=over 12

DOCUMENT();
loadMacros(
"PGstandard.pl",
"MathObjects.pl",
"MatrixReduce.pl", # automatically loads contextFraction.pl and MathObjects.pl
"PGcourse.pl",
);
$showPartialCorrectAnswers = 0;
TEXT(beginproblem()); 

# Context('Matrix'); # for decimal arithmetic
Context('Fraction'); # for fraction arithmetic

$A = Matrix([
[random(-5,5,1),random(-5,5,1),random(-5,5,1),3],
[random(-5,5,1),random(-5,5,1),random(-5,5,1),0.75],
[random(-5,5,1),random(-5,5,1),random(-5,5,1),9/4],
]);

$A = apply_fraction_to_matrix_entries($A); # try commenting this line out for different results

$Arref = rref($A);

$Aswitch = row_switch($A, 2, 3);

$Amult = row_mult($A, 2, 4);

$Aadd = row_add($A, 2, 1, 10);

$E = elem_matrix_row_add(3,2,1,10);
$EA = $E * $A;

$E1 = elem_matrix_row_switch(5,2,4);
$E2 = elem_matrix_row_mult(5,4,Fraction(1/10));
$E3 = elem_matrix_row_add(5,3,1,35);
$E4 = identity_matrix(4);
change_matrix_entry($E4,[3,2],10);

Context()->texStrings;
BEGIN_TEXT
The original matrix and its row reduced echelon form:
\[ $A \sim $Arref. \]
$BR
The original matrix with rows switched, multiplied, or added together:
\[ $Aswitch, $Amult, $Aadd. \]
$BR
Some elementary matrices.
\[$E1, $E2, $E3, $E4\]
END_TEXT
Context()->normalStrings;


ENDDOCUMENT();

=back

=head1 AUTHORS

Paul Pearson, Hope College, Department of Mathematics

with help from 

Davide Cervone, Union College, Department of Mathematics

Michael Doob, University of Manitoba, Department of Mathematics

=cut




# Observation: a randomly generated 3 x 4 matrix has a very high probability
# of having rank 3.  So, trying to generate random 3 x 4 matrices until a 
# matrix of rank < 3 appears would be a bad idea.  Also, there is no 
# guarantee that a randomly generated matrix will represent a consistent
# system; however, empirical evidence suggests that the majority of the
# time a random 3 x 4 matrix is produced, it is rank 3 and represents 
# a consistent system.  Also, with randomly chosen matrices, it is
# possible to get rows or columns of zeros, so watch out!

loadMacros("MathObjects.pl","contextFraction.pl",);

################################################
#  rref: input and output are MathObject matrices.  
#  Should be run in Fraction context for best results.

sub rref {
  my $M = shift;
  my @m = $M->value;
  my @m_reduced = rref_perl_array(@m);
  return Matrix(@m_reduced);
}

sub rcef {
  my $M = shift;
  my @m = $M->transpose->value;
  my @m_reduced = rref_perl_array(@m);
  return Matrix(@m_reduced)->transpose;
}

sub rref_perl_array {

	# input and output have form @A = ([1,2,3,4],[5,6,7,8]);
	my @A = @_;
	my $m = scalar(@A); # number of rows
	my $n = scalar(@{$A[0]}); # number of columns
	
	my $r = -1;
	my $i = -1;
	for my $j (0..$n-1) {
		$i = $r + 1;
		while ($i < $m and $A[$i][$j] == 0) {
			$i = $i + 1;
		}
		if ($i != $m) {
			$r = $r + 1;
			# row switch:
			@A[$i,$r] = @A[$r,$i];
			# row mult: scale row $r so that $A[$r][$j] = 1.
			my $lambda = $A[$r][$j];
			if ($lambda != 0) {
				foreach my $rowval ( @{$A[$r]} ) { $rowval /= $lambda; }
			}
			# row add:
			for my $k (0..$m-1) {
				if ($k == $r) { next; }
				my $lambda = $A[$k][$j]; 
				foreach my $p (0..$n-1) { $A[$k][$p] -= $lambda * $A[$r][$p]; }
			}
		}		
	}
	return @A;
}


################################################
#  This was written by Davide Cervone.
#  http://webwork.maa.org/moodle/mod/forum/discuss.php?d=2970

sub change_matrix_entry {
    my $self = shift; my $index = shift; my $x = shift;
    my $i = shift(@$index) - 1;
    if (scalar(@$index)) {change_matrix_entry($self->{data}[$i],$index,$x);}
		else {$self->{data}[$i] = Value::makeValue($x);
	}
}

################################################

sub identity_matrix {
	my $n = shift;
	return Value::Matrix->I($n);
}

################################################

sub elem_matrix_row_switch {

	# $n = number of rows (and columns) in matrix
	# $i and $j are indices of rows to be switched (index starting at 1, not 0)
	($n,$i,$j) = @_;
	if ($i < 1 or $j < 1 or $i > $n or $j > $n) {
		warn "Index out of bounds in Elem_row_switch().  Returning identity matrix.";
		return Value::Matrix->I($n);
	}
	my $M = Value::Matrix->I($n); # construct identity matrix
	my @m = $M->value;
	@m[$i - 1, $j - 1] = @m[$j - 1, $i - 1]; # switch rows
	return Matrix(@m);

}

#########################################

sub elem_matrix_row_mult {

	# $n = number of rows (and columns) in matrix
	# $i and $j are indices of rows to be switched (index starting at 1, not 0)
	($n,$i,$s) = @_;
	if ($i < 1 or $i > $n) {
		warn "Index out of bounds in elem_row_mult().  Returning identity matrix.";
		return Value::Matrix->I($n);
	}
	if ($s == 0) {
		warn "Scaling by zero not allowed in elem_row_mult().  Returning identity matrix.";
		return Value::Matrix->I($n);
	}
	my $M = Value::Matrix->I($n); # construct identity matrix
	my @m = $M->value;
	foreach my $rowval ( @{$m[$i - 1]} ) { $rowval *= $s; }
	return Matrix(@m);

}

######################################

sub elem_matrix_row_add {

	# $n = number of rows (and columns) in matrix
	# $i and $j are indices of rows to be switched (index starting at 1, not 0)
	($n,$i,$j,$s) = @_;
	if ($i < 1 or $j < 1 or $i > $n or $j > $n) {
		warn "Index out of bounds in elem_matrix_row_add().  Returning identity matrix.";
		return Value::Matrix->I($n);
	}
	if ($s == 0) {
		warn "Scaling by zero not allowed in elem_matrix_row_add().  Returning identity matrix.";
		return Value::Matrix->I($n);
	}
	my $M = Value::Matrix->I($n); # construct identity matrix
	my @m = $M->value;
	$m[$i - 1][$j - 1] = $s;
	return Matrix(@m);

}



##############################################

sub row_add {

	# put  (row i) + s * (row j) into (row i)

	my $M = shift; # MathObject matrix
	my $i = shift; # row index
	my $j = shift; # row index
	my $s = shift; # scaling factor

	my ($r,$c) = $M->dimensions;
	if (($i < 1) or ($j < 1) or ($i > $r) or ($j > $r)) {
		warn "i = $i, j = $j, r = $r.  Index out of bounds in row_add().  Returning original matrix.";
		return $M;
	}
	if ($s == 0 and $permissionLevel >= 10) { 
		warn "Scaling a row by zero is not a valid row operation.  (This warning is only shown to professors.)  Returning original matrix.";
		return $M; 
	}

	# my $E = elem_matrix_row_add($r, $i, $j, $s);
	# return $E * $M;

	my @m = $M->value;
	foreach my $k (0..$c-1) {
		$m[$i - 1][$k] += $s * $m[$j - 1][$k];
	}
	return Matrix(@m);

}

####################################

sub row_switch {

	my $M = shift; # MathObject matrix
	my $i1 = shift; # index of row to be swapped, indexing starts at 1
	my $i2 = shift; # index of row to be swapped
	my ($r,$c) = $M->dimensions;
	if ($i1 < 1 or $i2 < 1 or $i1 > $r or $i2 > $r) {
		warn "Index out of bounds in row switch.  Returning original matrix.";
		return $M;
	}
	my @m = $M->value;
	@m[$i1 - 1,$i2 - 1] = @m[$i2 - 1,$i1 - 1];
	return Matrix(@m);

}

#########################################

sub row_mult {

	my $M = shift; # MathObject matrix
	my $i = shift; # index of row to be scaled
	my $s = shift; # scaling factor
	my ($r,$c) = $M->dimensions;
	if ($i < 1 or $i > $r) {
		warn "Index out of bounds in row multiplication.  Returning original matrix.";
		return $M;
	}
	if ($s == 0 and $permissionLevel >= 10) { warn "Scaling a row by zero is not a valid row operation.  (This warning is only shown to professors.)"; }
	my @m = $M->value;
	foreach my $rowval ( @{$m[$i - 1]} ) { $rowval *= $s; } # row multiplication
	return Matrix(@m);

}

####################################

sub apply_fraction_to_matrix_entries {

	my $M = shift;
	my @m = $M->value;
	my ($r,$c) = $M->dimensions;
	foreach my $i (0..$r-1) {
		foreach my $rowval ( @{$m[$i]} ) { $rowval = Fraction("$rowval"); }
	}
	return Matrix(@m);

}


1;