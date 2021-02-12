# algebraMacros.pl

# define any custom subroutines you want and then use them in
# problems by including the file in loadMacros() calls.

sub _init_macro_template {

 #Possibly add initialization code here
 #sub routine is not required, but prevents the macro from being re-loaded

}



######################## display macros for cyclic and dihedral groups

sub cyclic { 

	my $n = shift;

	# leave one of the following return commands uncommented, depending on what notation you want to use for finite cyclic groups (e.g., Z/nZ)
	
	# display order n cyclic group as Z_n
	return "\\mathbb{Z}_{$n}",
	
	# display order n cyclic group as C_n
	# return "C_{$n}";
	
	# display order n cyclic group as Z/nZ
	# return "\\mathbb{Z}/{$n}\\mathbb{Z}";

};

sub dihedral { 

	my $n = shift;
	
	# if you want to display dihedral groups as D_n (for instance, D_4 is the dihedral group of order 8), then leave this subroutine unmodified
	
	
	# if you want to display dihedral groups as D_{2n} (for instance, D_8 is the dihedral group of order 8), then uncomment this set of if/else statements. The regular expression conditionals are to make sure it handles different types of arguments correctly.
	# if( "$n" =~ m/^\s*(\d+)\s*$/ )
	# {
		# $n = 2 * $1;
	# }
	# elsif( "$n" =~ m/^\s*(\w+)\s*$/ )
	# {
		# $n = "2$1";
	# }
	# else
	# {
		# $n = "2($n)";
	# }
	
		
	return "D_{$n}";
	
};


sub quaternions {

	# if you want to display the Quaternion group as Q_8, then leave this subroutine unmodified
	
	return "Q_8"
	
	
	# if you want to display the Quaternion group using some other notation, comment the statement above and uncomment one of these (or add your own):
	
	# return "H_8"
	
	# return "Q"

};





######################## subroutines


# fisher-yates shuffle
# argument: reference to a list
#			shuffles list in-place
# returns: nothing
sub fyshuffle
{
    my $array = shift;
    my $i = @$array;
    while ( --$i )
    {
        my $j = random( 0, $i, 1 );
        @$array[$i,$j] = @$array[$j,$i];
    }
};


# extended euclidean algorithm
# by Dick Lane
# http://webwork.maa.org/moodle/mod/forum/discuss.php?d=2286
# arguments: a, b
# returns: d, x, y, s, t where gcd( a, b ) = d = a( x + sk ) + b( y + tk ) for all k
sub xgcd ($$) {
	my ( $a, $b, $x, $y, $s, $t ) = ( @_, 1, 0, 0, 1 );
	
	while  ( $b )  {
		my  $q = int( $a / $b ) ;
		( $a, $x, $y, $b, $s, $t ) = ( $b, $s, $t, $a - $q * $b, $x - $q * $s, $y - $q * $t );
	}

	return [ $a, $x, $y, $s, $t ];
};



# subroutine to decompose a permutation into a product of disjoint cycles. 
# argument: reference to a list containing the permutation data
#			that is, element 0 of the list is f(0), element 1 is f(1), etc
# returns: mathObject list of lists representing the cycle decomposition of the permutation
sub disjointCycles
{
	$p = shift;
	
	# create a hash representing the permutation
	%pHash = ();
	$pHash{ $_ } = $$p[ $_ ] foreach ( 0 .. -1 + scalar @$p );

	@cycles = ( );
	while( keys %pHash )
	{
		# start with first available key
		@c = ( keys %pHash )[ 0 ]; 
		
		# keep looping through set, adding elements to the current cycle (c)
		# until we get back to the beginning of c
			push @c, delete $pHash{ $c[ -1 ] } while $pHash{ $c[ -1 ] } != $c[ 0 ];
		
		delete $pHash{ $c[ -1 ] };
		
		# add c to cycles if it's not just a 1-cycle
		push @cycles, [ map { $_ + 1 } @c ] if @c > 1;
	}

	# making the lists of lists must be done carefully in order to get the behavior we want
	# we want the cycles (Lists within the List) to always have parentheses, even if there's
	# only one. But we want the outer List to never have parentheses
	if( scalar @cycles > 1 )
	{
		$result = List( map { List( join( ',', @$_ ) ) } ( @cycles ) );
	}
	elsif (scalar @cycles > 0 )
	{
		$result = List( map { List( '(' . join( ',', @$_ ) . ')' ) } @cycles );
	} else {
                Context()->strings->add(id => {alias => "identity"});          
                $result = List( ( id ) );
	}
	return $result;
};


# subroutine to decompose a permutation into a product of transpositions ( 2-cycles ).
# argument: mathObject list of lists representing the cycle decomposition of the 	permutation (i.e., the output of disjointCycles() )
# returns: mathObject list of lists representing the permutation as a list of transpositions
sub cyclesToTranspositions
{
	my $listOfCycles = shift;
	
	@transpositions = ( );
	
	# decompose each cycle ( a_1 a_2 ... a_n ) into ( a_1 a_2 )( a_1 a_3 ) ... ( a_1 a_n )
	foreach ( $listOfCycles->value )
	{
		my @cycle = $_->value;
		foreach ( 1 .. @cycle - 1 )
		{
			push @transpositions, List( @cycle[ 0, $_ ] );
		}
	}
	
	# unlike disjointCycles, this subroutine is only used in a problem where the permutation has order > 4, so there will always be more than one element. Therefore we don't have to do any weird stuff to format the list (make parentheses display correctly)
	return List( @transpositions );
};



# subroutine to determine the order of a permutation
# argument: a list of lists representing a permutation in the form of a product of disjoint cycles ( i.e., the output of disjointCycles() )
# returns: mathObject integer representing the order of the permutation
sub cycleOrder
{
	my $p = shift; # list of lists
	
	my $order = 1;
	$order = lcm( $order, $_->length ) foreach $p->value;
	
	return Compute( $order );
};



# subroutine to determine the parity of a permutation
# argument: a list of lists representing a permutation in the form of a product of disjoint cycles (i.e., the output of disjointCycles() )
# returns: TRUE if the permutation is even, FALSE if the permutation is odd
sub isEven
{
	my $p = shift;
	
	my $numberEvenCycles = scalar grep { $_->length % 2 == 0 } $p->value;
	
	return !( $numberEvenCycles % 2 );

};






######################## frequently-used custom checkers

# you can call these when checking answers like this:
#
# ANS( $f->cmp( checker => ~~&modChecker ) );

# make sure the external variables are available; for instance, in order to use
# the modChecker subroutine, you must have the variable $modulus defined in
# your problem



###############################################################################
# modChecker
###############################################################################
#	Type: 		checker
#	Used in:	RingsDefinition3.pg
#				RingsDefinition4.pg
#				RingsDefinition5.pg
#				RingsDefinition7.pg
#				RingsQuotientPolynomial3.pg
#				RingsQuotientPolynomial4.pg
#				RingsIdealsHomomorphisms2.pg
#	Purpose: 	Compare the student's answer (a number) to the correct
#				answer (a number), modulo $modulus
#	External variables:
#				$modulus
#	Comment:	This checker is defined in algebraMacros.pl because it's used
#				in so many problems
###############################################################################
	sub modChecker
	{
		my ( $correct, $student, $ansHash ) = @_;  # get correct and student MathObjects
		return ( $student % $modulus == $correct % $modulus ? 1 : 0 );
	};
###############################################################################





###############################################################################
# checkCycles
###############################################################################
#	Type:		checker
#	Used in:	Permutations1.pg
#				Permutations2.pg
#				Permutations5.pg
#				Permutations6.pg
#	Purpose:	Compare a student's cycle to a correct cycle, see if they
#				represent the same permutation (i.e. ( 1 2 3 ) = ( 2 3 1 ) )
#	External variables:
#	Comment:	This checker is defined in algebraMacros.pl because it's used
#				in so many problems
###############################################################################
	sub checkCycles
	{
		my ( $correct , $student , $ansHash ) = @_;
	
		@studentCycle = $student->value;
		@correctCycle = $correct->value;
	
		# immediately fail if the cycles are not the same length
		return 0 if @studentCycle != @correctCycle;
		
		# try each offset, see if the lists are the same
		foreach ( 0 .. @studentCycle - 1 )
		{
			my $i = 0;
			$i++ while $i < @studentCycle && $studentCycle[ $i ] == $correctCycle[ -$_ + $i ];
			return 1 if $i == @studentCycle;
		}
		
		return 0;
	};
###############################################################################


###############################################################################
# checkListOfTranspositions
###############################################################################
#	Type:		checker
#	Used in:	Permutations4.pg
#				Permutations8.pg
#	Purpose:	Compare a student's sequence of transpositions to a correct
#				sequence of transpositions, see if they	represent the same
#				permutation
#	External variables:
#				@x - list of elements in the set on which permutations are
#				defined
#	Comment:	This checker is defined in algebraMacros.pl because it's used
#				in so many problems
###############################################################################
	sub checkListOfTranspositions
	{
		my ( $correct, $student, $ansHash, $value ) = @_;

		# create hashes which will be used to store the student and correct permutations
		my( %studentPerm, %correctPerm );
		$studentPerm{ $_ } = $correctPerm{ $_ } = $_ foreach ( 1 .. @x );
		
		# apply each of the correct transpositions in succession, from right to left
		foreach ( 1 .. @$correct )
		{
			# read the transposition ( a, b ) as a pair of integers
			$a = ( $correct->[ -$_ ]->value )[ 0 ]->value;
			$b = ( $correct->[ -$_ ]->value )[ 1 ]->value;

			# switch a and b elements of the hash
			@correctPerm{ $a, $b } = @correctPerm{ $b, $a };
		}

		# apply each of the student's transpositions in succession, from right to left
		foreach ( 1 .. @$student )
		{
			# check to make sure this entry is a list of 2 elements, both of which are positive integers in the set @x
			return( 0, "one of your entries is not a well-defined transposition on this set" ) if $student->[ -$_ ]->length != 2 || scalar grep{ !Value::isReal( $_ ) || $_ != int $_ || $_ < 1 || $_ > @x } $student->[ -$_ ]->value;

			# read the transposition ( a, b ) as a pair of integers
			$a = ( $student->[ -$_ ]->value )[ 0 ]->value;
			$b = ( $student->[ -$_ ]->value )[ 1 ]->value;
			
			# switch elements a and b of the hash
			@studentPerm{ $a, $b } = @studentPerm{ $b, $a };
		}

		# read the two hashes to make sure they're the same. if not, the answer is wrong
		return scalar ( grep{ $studentPerm{ $_ } != $correctPerm{ $_ } } ( 1 .. @x ) ) ? (0) : (scalar(@$student));

		# an alternative way to do this would be to compute the permutation represented by the correct list of transpositions, then do the inverse of the student's list of transpositions (work left-to-right instead of right-to-left) on the same list, and see if it results in the identity.	
	};
###############################################################################






1; #required at end of file - a perl thing
