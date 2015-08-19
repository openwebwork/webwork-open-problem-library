sub _MatrixCheckers_init {}; # don't reload this file

=pod

=head1 NAME

MatrixCheckers.pl

=head1 SYNOPSIS

Provides subroutines for answer checking using MathObjects 
matrices with real entries.  (Sadly, it does not provide 
routines for using matrices to win at the game of checkers.)

=head1 DESCRIPTION

First, load the C<MatrixCheckers.pl> macro file.  If the basis has 
more than one vector, also load C<parserMultiAnswer.pl>.

=over 12

=item C<loadMacros("PGstandard.pl","MathObjects.pl","parserMultiAnswer.pl","MatrixCheckers.pl");>

= back

For a matrix that has a single column or row, the way to use the
answer checkers is the same as using a custom answer checker
inside of C<cmp(checker=<gt>~~&name_of_answer_checker_subroutine)>
such as

=over 12

=item C<ANS( Matrix([[1],[2],[3]])-<gt>cmp( checker=<gt>~~&basis_checker_one_column ) );>

=item C<ANS( Matrix([[1],[2],[3]])-<gt>cmp( checker=<gt>~~&unit_basis_checker_one_column ) );>

=back

The "one column" at the end of the checker name refers to the 
fact that the student answer is a one-column matrix.  The "unit
basis checker" ensures that the student answer has unit length. 

For answers that are a collection of column or row vectors, the
way to use the answer checkers is inside of a MultiAnswer object.
The macro C<parserMultiAnswer.pl> should also be loaded.
The answer checkers that should be used inside a MultiAnswer
object are:

=over 12

=item C<basis_checker_columns>

=item C<orthonormal_basis_checker_columns>

=item C<basis_checker_rows>

=item C<orthonormal_basis_checker_rows>

=item C<parametric_plane_checker_columns>

=back

Here is an example of how to use these answer checkers.
In the setup section of the PG file we create two 3 x 1 MathObject 
matrices with real-entries that serve as basis vectors.  The object
C<$multians> takes the basis vectors as input and passes them
to the custom answer checker called by C<checker =<gt>...>.

=over 12

$basis1 = Matrix([1/sqrt(2), 0, 1/sqrt(2)])->transpose;
$basis2 = Matrix([0,1,0])->transpose;

$multians = MultiAnswer($basis1, $basis2)->with(
  singleResult => 1,
  separator => ', ',
  tex_separator => ', ',
  allowBlankAnswers=>0,
  checker => ~~&orthonormal_basis_checker_columns,
);

=back

In the main text portion of the PG file, we use C<\{ $multians-<gt>ans_array(15) \}> 
to create an array of text boxes that are 15 characters wide and have square 
brackets around them to look like a matrix.  The braces around the vectors, which 
are produced by C<\(\Bigg\lbrace\)> and C<\(\Bigg\rbrace\)>, are a matter of personal
preference (since a basis is an ordered set, I like to include braces).

=over 12

Context()->texStrings;
BEGIN_TEXT
Find an orthonormal basis for...
$BR
$BR
$BCENTER
\(\Bigg\lbrace\) 
\{ $multians->ans_array(15) \}, 
\{ $multians->ans_array(15) \} 
\(\Bigg\rbrace.\)
$ECENTER
END_TEXT
Context()->normalStrings;

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

loadMacros("MathObjects.pl",); # , will "parserMultiAnswer.pl" create an infinite loop?


################################################

sub concatenate_columns_into_matrix {

  my @c = @_;
  my @temp = ();
  for my $column (@c) {
    push(@temp,Matrix($column)->transpose->row(1));    
  }
  return Matrix(@temp)->transpose;

}

##########################################

sub basis_checker_one_column { 

      my ( $correct, $student, $answerHash ) = @_;
      
      # Most of the answer checking is done on integers 
      # or on decimals like 0.24381729, so we will set the
      # tolerance accordingly in a local context.
      my $context = Context()->copy;
      $context->flags->set(
        tolerance => 0.001,
        tolType => "absolute",
      );

      #my $C = Matrix($context,$correct);
      #my $S = Matrix($context,$student);
      my $C = Vector($context,$correct);
      my $S = Vector($context,$student);
      return $S->isParallel($C);

}

##########################################

sub basis_checker_columns {

      my ( $correct, $student, $answerHash ) = @_;
      my @c = @{$correct};
      my @s = @{$student};

      # Most of the answer checking is done on integers 
      # or on decimals like 0.24381729, so we will set the
      # tolerance accordingly in a local context.
      my $context = Context()->copy;
      $context->flags->set(
        tolerance => 0.001,
        tolType => "absolute",
      );

      return 0 if scalar(@s) < scalar(@c);  # count the number of vector inputs

      my $C = concatenate_columns_into_matrix(@c);
      my $S = concatenate_columns_into_matrix(@s);

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
      return $S == $C * $X;

}


#############################################

sub unit_basis_checker_one_column { 

      my ( $correct, $student, $answerHash ) = @_;
      
      # Most of the answer checking is done on integers 
      # or on decimals like 0.24381729, so we will set the
      # tolerance accordingly in a local context.
      my $context = Context()->copy;
      $context->flags->set(
        tolerance => 0.001,
        tolType => "absolute",
      );

      my $C = Vector($context,$correct);
      my $S = Vector($context,$student);
      return ($S->isParallel($C) and norm($S)==1);

}

###############################################

sub orthonormal_basis_checker_columns {

      my ( $correct, $student, $answerHash ) = @_;
      my @c = @{$correct};
      my @s = @{$student};

      # Most of the answer checking is done on integers 
      # or on decimals like 0.24381729, so we will set the
      # tolerance accordingly in a local context.
      my $context = Context()->copy;
      $context->flags->set(
        tolerance => 0.001,
        tolType => "absolute",
      );

      return 0 if scalar(@s) < scalar(@c);  # count the number of vector inputs

      my $C = concatenate_columns_into_matrix(@c);
      my $S = concatenate_columns_into_matrix(@s);

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

      my $identity = Value::Matrix->I(scalar(@c));
      #  Check that the student's vectors are orthonormal
      if ( (($S->transpose) * $S) != $identity) {
        Value->Error("Your vectors are not orthonormal (or you may need to enter more decimal places)");
        return 0;
      }

      # S = student, C = correct, X = change of basis matrix
      # Solve S = CX for X using (C^T C)^{-1} C^T S = X.
      $X = ($CTC->inverse) * (($C->transpose) * $S);
      return $S == $C * $X;

}

##############################################

sub basis_checker_rows {

      my ( $correct, $student, $answerHash ) = @_;
      my @c = @{$correct};
      my @s = @{$student};

      # Most of the answer checking is done on integers 
      # or on decimals like 0.24381729, so we will set the
      # tolerance accordingly in a local context.
      my $context = Context()->copy;
      $context->flags->set(
        tolerance => 0.001,
        tolType => "absolute",
      );

      return 0 if scalar(@s) < scalar(@c);  # count the number of vector inputs

      # These two lines are what is different from basis_checker_columns
      my $C = Matrix(@c)->transpose; # put the rows of @c into columns of $C.
      my $S = Matrix(@s)->transpose; # put the rows of @s into columns of $S.

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
      return $S == $C * $X;

}

#############################################

sub orthonormal_basis_checker_rows {

      my ( $correct, $student, $answerHash ) = @_;
      my @c = @{$correct};
      my @s = @{$student};

      # Most of the answer checking is done on integers 
      # or on decimals like 0.24381729, so we will set the
      # tolerance accordingly in a local context.
      my $context = Context()->copy;
      $context->flags->set(
        tolerance => 0.001,
        tolType => "absolute",
      );

      return 0 if scalar(@s) < scalar(@c);  # count the number of vector inputs

      # These two lines are what is different from basis_checker_columns
      my $C = Matrix(@c)->transpose; # put the rows of @c into columns of $C.
      my $S = Matrix(@s)->transpose; # put the rows of @s into columns of $S.

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

      my $identity = Value::Matrix->I(scalar(@c));
      #  Check that the student's vectors are orthonormal
      if ( (($S->transpose) * $S) != $identity) {
        Value->Error("Your vectors are not orthonormal (or you may need to enter more decimal places)");
        return 0;
      }

      # S = student, C = correct, X = change of basis matrix
      # Solve S = CX for X using (C^T C)^{-1} C^T S = X.
      $X = ($CTC->inverse) * (($C->transpose) * $S);
      return $S == $C * $X;

}

##############################################

sub parametric_plane_checker_columns {

      my ( $correct, $student, $answerHash ) = @_;
      my @c = @{$correct};
      my @s = @{$student};

      # Most of the answer checking is done on integers 
      # or on decimals like 0.24381729, so we will set the
      # tolerance accordingly in a local context.
      my $context = Context()->copy;
      $context->flags->set(
        tolerance => 0.001,
        tolType => "absolute",
      );

      return 0 if scalar(@s) < scalar(@c);  # count the number of vector inputs

      # pull off the first vector as the displacement vector
      my $C0 = Matrix(shift(@c));
      my $S0 = Matrix(shift(@s));

      # put the remaining vectors into the columns of a matrix.
      my $C = concatenate_columns_into_matrix(@c);
      my $S = concatenate_columns_into_matrix(@s);

      # Put $C and $S into the local context so that
      # all of the computations that follow will also be in
      # the local context.
      $C0 = Matrix($context,$C0);
      $S0 = Matrix($context,$S0);
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

      # solve (S_0 = C_0 + C A) for the column vector A of weights using
      # (S_0 - C_0) = C A
      # C^T (S_0 - C_0) = C^T C A
      # (C^T C)^{-1} C^T (S_0 - C_0) = A
      my $A = ($CTC->inverse) * ($C->transpose) * ($S0 - $C0);
      if ($S0 != $C0 + $C*$A) {
          Value->Error("Your particular solution is incorrect");
          return 0;
      }

      # S = student, C = correct, X = change of basis matrix
      # Solve S = CX for X using (C^T C)^{-1} C^T S = X.
      $X = ($CTC->inverse) * (($C->transpose) * $S);
      return $S == $C * $X;

}


########################################################

1;