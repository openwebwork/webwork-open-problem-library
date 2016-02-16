sub _VectorListCheckers_init {}; # don't reload this file

=pod

=head1 NAME

VectorListCheckers.pl

=head1 SYNOPSIS

Provides subroutines for answer checking lists MathObjects 
vectors with real entries.

=head1 DESCRIPTION

First, load the C<VectorListCheckers.pl> macro file.

=over 12

=item C<loadMacros("PGstandard.pl","MathObjects.pl","VectorListCheckers.pl");>

= back

For a MathObject list of MathObject vectors, the way to use the
answer checkers is the same as using a custom answer checker
inside of C<cmp(checker=<gt>~~&name_of_answer_checker_subroutine)>
such as

=over 12

=item C<ANS( List(ColumnVector(1,0,0),ColumnVector(0,1,0))-<gt>cmp( checker=<gt>~~&basis_checker_list_of_vectors ) );>

=item C<ANS( Vector("<1,0,0> + s * <0,1,0> + t * <0,0,1>")-<gt>cmp( checker=<gt>~~&affine_subspace_checker_vectors ) );>

=back

The "list of vectors" at the end of the checker name refers to the 
fact that the student answer is a list of vectors.

Here is an example of how to use these answer checkers.

=over 12

DOCUMENT();
loadMacros(
"PGstandard.pl",
"MathObjects.pl",
"VectorListCheckers.pl",
"PGcourse.pl",
);
$showPartialCorrectAnswers = 1;
TEXT(beginproblem()); 

Context('Vector');

$B = Matrix([[1,0,0],[0,1,0],[0,0,0]]);

$answer = List(ColumnVector(1,0,0),ColumnVector(0,1,0));

Context()->texStrings;
BEGIN_TEXT
A basis for the column space of \( B = $B \) is 
$BR
$BR
\{ $answer->ans_rule(60) \}
$BR
$BR
Enter your answer as a comma separated list of vectors, such as 
\( \verb+<1,2,3>,<4,5,6>+ \).
END_TEXT
Context()->normalStrings;

ANS( $answer->cmp(list_checker=>~~&basis_checker_list_of_vectors) );



ENDDOCUMENT();

=back

The answer evaluation section of the PG file is totally standard.

=over 12

ANS( $multians->cmp );

=back

The C<parametric_plane_checker_columns> should be used for
solutions to non-homogeneous systems of linear equations for
which the solution is essentially a point plus the span of 
several linearly independent vectors.  When using the parametric
plane checker, the first vector input always serves as a point
on the hyperplane (i.e., the first vector input is always a 
particular solution), while the remaining vectors are a basis for
the hyperplane (i.e., they span the homogeneous solution set).

=head1 AUTHORS

Paul Pearson, Hope College, Department of Mathematics

=cut



################################################

loadMacros("MathObjects.pl",); 

sub basis_checker_list_of_vectors {

	my ($correct, $student, $ansHash, $value) = @_;
	my @c = @{$correct};  
	my @s = @{$student};
	my $nc = scalar(@c);
	my $ns = scalar(@s);
	my $score = 0;
	my @errors = ();

	return ($score,@errors) if $nc != $ns;

	if ($nc == 1) {

		if (Vector($s[0])->isParallel($c[0])) { return ($nc,@errors); }

	} else {

		# Most of the answer checking is done on integers 
		# or on decimals like 0.24381729, so we will set the
		# tolerance accordingly in a local context.
		my $context = Context()->copy;
		$context->flags->set(
			tolerance => 0.001,
			tolType => "absolute",
		);

		# put the correct vectors into the columns of a matrix $C
		my @cor = ();
		foreach my $i (0..$nc-1) {
			push(@cor, Matrix($c[$i]) );
		}
		my $C = Matrix(@cor)->transpose;

		# put the student vectors into the columns of a matrix $S
		my @stu = ();
		foreach my $i (0..$ns-1) {
			push(@stu, Matrix($s[$i]) );
		}
		my $S = Matrix(@stu)->transpose;


		# Put $C and $S into the local context so that
		# all of the computations that follow will also be in
		# the local context.
		$C = Matrix($context,$C);
		$S = Matrix($context,$S);

		#  Theorem: A^T A is invertible if and only if A has linearly independent columns.

		#  Check that the professor's vectors are, in fact, linearly independent.
		$CTC = ($C->transpose) * $C;
		warn "Correct answer is a linearly dependent set." if ($CTC->det == 0);

		#  Check that the student's vectors are linearly independent
		if ( (($S->transpose) * $S)->det == 0) {
			Value->Error("Your vectors are linearly dependent");
			return 0;
		}

		# S = student, C = correct, X = change of basis matrix
		# Solve S = CX for X using (C^T C)^{-1} C^T S = X.
		$X = ($CTC->inverse) * (($C->transpose) * $S);
		if ( $S == $C * $X ) { $score = $nc; };
    
		return ($score,@errors);

	}

}

########################################################

$vector_list_column_syntax_angle_brackets = MODES(TeX=>'',HTML=>
"Enter a column vector such as
\\( \\left\\lbrack \\begin{array}{r} 1 \\\\ 2 \\end{array} \\right\\rbrack \\) 
using the syntax \\( \\verb+<1,2>+ \\). 
If there is more than one vector in your answer, enter 
your answer as a comma separated list of vectors, such as 
\\( \\verb+<1,2>,<3,4>+ \\)."  
);

########################################################

$vector_list_row_syntax_angle_brackets = MODES(TeX=>'',HTML=>
"Enter a row vector using the syntax \\( \\verb+<1,2>+ \\). 
If there is more than one vector in your answer, enter 
your answer as a comma separated list of vectors, such as 
\\( \\verb+<1,2>,<3,4>+ \\)."  
);

########################################################

sub affine_subspace_checker_vectors {

	my ( $correct, $student, $ansHash ) = @_;
	my @s = ();
	my @c = ();

	# Most of the answer checking is done on integers 
	# or on decimals like 0.24381729, so we will set the
	# tolerance accordingly in a local context.
	my $context = Context()->copy;
	$context->flags->set(
		tolerance => 0.001,
		tolType => "absolute",
	);

	# Get the variables from the context
	my @vars = $context->variables->names;

	# Make an array of zeros the same length as @vars
	my @zeros = ();
	foreach (@vars) { push(@zeros,0); }

	# Evaluate the correct and student answers on the zero vector
	my %h;
	@h{@vars} = @zeros;
	push(@c,Matrix($context,$correct->eval(%h)));
	push(@s,Matrix($context,$student->eval(%h)));

	# Make standard basis vectors e_i with ith entry = 1 and all other entries = 0
	# and evaluate the correct and student answers on e_i
	my @temp = ();
	foreach my $i (0..$#vars) { 
		@temp = @zeros;
		$temp[$i] = 1;
		@h{@vars} = @temp;   
		my $c_temp = Matrix($context,$correct->eval(%h));
		my $s_temp = Matrix($context,$student->eval(%h));
		$c_temp = $c_temp - $c[0];
		$s_temp = $s_temp - $s[0];
		push(@c,$c_temp);
		push(@s,$s_temp);
	}

	# Put the results into the columns of matrices
	my $C0 = Matrix($context,shift(@c))->transpose; # column vector = displacement vector
	my $C = Matrix($context,@c)->transpose; # matrix columns = vectors that span the hyperplane
	my $S0 = Matrix($context,shift(@s))->transpose; # column vector = displacement vector
	my $S = Matrix($context,@s)->transpose; # matrix columns = vectors that span the hyperplane
  
	#  Theorem: A^T A is invertible if and only if A has linearly independent columns.

    #  Check that the professor's vectors are, in fact, linearly independent.
    $CTC = ($C->transpose) * $C;
    warn "Correct answer is a linearly dependent set." if ($CTC->det == 0);

    #  Check that the student's vectors are linearly independent
    if ( (($S->transpose) * $S)->det == 0) {
		Value->Error("Your vectors do not span a (hyper) plane of the correct dimension");
        return 0;
    }

    # solve (S_0 = C_0 + C A) for the column vector A of weights using
    # (S_0 - C_0) = C A
    # C^T (S_0 - C_0) = C^T C A
    # (C^T C)^{-1} C^T (S_0 - C_0) = A
    my $A = ($CTC->inverse) * ($C->transpose) * ($S0 - $C0);
    if ($S0 != $C0 + $C*$A) {
        #Value->Error("Your particular solution $S0 is incorrect");
        return 0;
    }

    # S = student, C = correct, X = change of basis matrix
    # Solve S = CX for X using (C^T C)^{-1} C^T S = X.
    $X = ($CTC->inverse) * (($C->transpose) * $S);
    return $S == $C * $X;

}


1;