# additional macros developed in conjunction with the problems from 
# the consortium (hughes-hallett) calculus text
# 
# written by Gavin LaRose, <glarose@umich.edu>
# version 1.2
# 1.2: added reduced_frac()
# 1.1: added numorfun_cmp()
#
# shufflemap
# produces a reference to a hash of indices from 0 to n-1 pointing to 
# a random permutation of the same, and the index that points to 0
#
# string_list_cmp
# check a comma-separated list of strings as student answers and 
# check them with the standard str_cmp evaluator.  this is really 
# John Jones' number_list_cmp rewritten to be do string comparison
#
# integrand_fun_cmp
# an answer evaluator that allows checking functions with 'dt' in them; 
# redundant now that the Parser allows checking with multicharacter
# variables
#
# numfun_cmp
# an answer evaluator that requires that the answer be 
# simplified to the number given without returning an error if 
# it's a function
#
# numorfun_cmp
# an answer evaluator that first checks to see if the student answer
# checks correctly as a number, and if so returns that result; if not,
# repeats the check with a function checker and returns that.  options
# for the respective checkers are provided as separate hash references
#
# classify_cmp
# take a correct answer of the form "val=string, val=string.."
# and check a comma-separated list of student answers against these
# if the option 'order'=>'strict' is provided, requires that the 
# answers be in the same order.  any other options are passed to 
# num_cmp to check the val entries; strings are checked with a 
# standard str_cmp
# doesn't currently allow for passing in of a reference to an array 
# of solutions to generate a list of evaluators, but that would be 
# easy to add
#

sub reduced_frac {
    my ($num, $den) = @_;

    if ($num/$den == int($num/$den) ) {
	return $num/$den;
    } else {
	for ( my $j = ($num > $den? $den: $num); $j>1; $j-- ) {
	    if ( $num/$j == int($num/$j) && $den/$j == int($den/$j) ) {
		$num = $num/$j; $den = $den/$j;
	    }
	}
	if ( $den == 1 ) {
	    return $num;
	} else {
	    return( "{$num" . '\over' . "$den}" );
	}
    }
}

sub shufflemap {
    my $n = shift();
    my $m = $n - 1;
    my $zeroind;

    my %map = ();

    my @vals = (0..$m);
    for ( my $i=0; $i<$m; $i++ ) {
	my $j = random(0,$m-$i,1);
	$map{$i} = $vals[$j];
	$zeroind = $i if ( $map{$i} == 0 );
	splice(@vals, $j, 1);
    }
    $map{$m} = $vals[0];
    $zeroind = $m if ( $map{$m} == 0 );

    return( { %map }, $zeroind );
}

sub string_list_cmp {
    my $cList = shift();
    my %opts = @_;

    my $ordered = 0;
    if ( defined( $opts{'ordered'} ) ) {
	$ordered = 1 if ( $opts{'ordered'} );
	delete( $opts{'ordered'} );
    }
    
    my @cAns = split(/,\s*/, $cList);

    my @ansEval = ();
    foreach ( @cAns ) {
	push( @ansEval, str_cmp( $_, %opts ) );
    }

    return( sub {
	my $sList = shift();
	my @sAns = split(/,\s*/, $sList);

	my $res = new AnswerHash;

	if ( $ordered ) {
	    if ( @sAns ) {
		my $res = $ansEval[0]->evaluate( $sAns[0] );
		for( my $i=1; $i<@sAns && $i<@ansEval; $i++ ) {
		    $res = $res->AND( $ansEval[$i]->evaluate( $sAns[$i] ) );
		}
		if ( @ansEval > @sAns ) {
		    $res->{'score'} = 0;
		    for( my $j=@sAns; $j<@ansEval; $j++ ) {
			my $fakeRes = $ansEval[$j]->evaluate('something');
			$res->{'correct_ans'} .= "AND " . 
			    $fakeRes->{'correct_ans'};
		    }
		} elsif ( @sAns > @ansEval ) {
		    $res->{'score'} = 0;
		    for( my $j=@ansEval; $j<@sAns; $j++ ) {
			my $fakeRes = $ansEval[0]->evaluate( $sAns[$j] );
			$res->{'student_ans'} .= ", " . 
			    $fakeRes->{'student_ans'};
			$res->{'original_student_ans'} .= ", " .
			    $fakeRes->{'original_student_ans'};
		    }
		}
		return $res;
	    } else {
		my $res = $ansEval[0]->evaluate('');
		for( my $i=1; $i<@ansEval; $i++ ) {
		    $res = $res->AND( $ansEval[$i]->evaluate('') );
		}
		return $res;
	    } 
	} else {
	# go through and check each in turn
	    my $res;
	    my @missedAnsEval = ();
	    my @doneStuAns = ();
	    my $stuAnsDone = '';
	    for( my $i=0; $i<@ansEval; $i++ ) {
		my $doneOne = 0;
		for( my $j=0; $j<@sAns; $j++ ) {
		    next if ( $stuAnsDone =~ /\b$j\b/ );
		    my $curRes = $ansEval[$i]->evaluate( $sAns[$j] );
		    if ( $curRes->{'score'} ) {
			if ( ref( $res ) ) {
			    $res = $res->AND($curRes);
			    $res->{'student_ans'} .= ", " .
				$curRes->{'student_ans'};
			    $res->{'original_student_ans'} .= ", " .
				$curRes->{'original_student_ans'};
			} else {
			    $res = $curRes;
			}
			$stuAnsDone .= "$j,";
			$doneOne = 1;
			push( @doneStuAns, $j );
			last;
		    }
		}
		push(@missedAnsEval, $i) if ( ! $doneOne );
	    }
	# did we miss any correct answers?
	    if ( @missedAnsEval ) {
		$res->{'score'} = 0;

		foreach ( @missedAnsEval ) {
		    my $fakeRes = $ansEval[$_]->evaluate('something');
		    $res->{'correct_ans'} .= " AND " . 
			$fakeRes->{'correct_ans'};
		}
	    }
	# did we miss any student answers?
	    if ( @doneStuAns != @sAns ) {
		$res->{'score'} = 0;

		for ( my $i=0; $i<@sAns; $i++ ) {
		    if ( $stuAnsDone !~ /\b$i\b/ ) {
			$res->{'student_ans'} .= ", " . uc($sAns[$i]);
			$res->{'original_student_ans'} .= ", " . $sAns[$i];
			$res->{'preview_latex_string'} .= "\\quad \\mbox{" . 
			    uc($sAns[$i]) . "}";
		    }
		}
	    }
	    return $res;
	}
    } );
}

# integrand_fun_cmp 
# an answer evaluator to allow checking functions with 'dt' in them
#
sub integrand_fun_cmp {
    my $cAns = shift();
    my %opts = @_;

    if ( defined( $opts{'var'} ) && $opts{'var'} ) {
	$differential = "d" . $opts{'var'}->[0]; # we assume the first
	push( @{$opts{'var'}}, 'Q' );            # variable is the 
    } else {                                     # independent variable
	$differential = "dx";
	$opts{'var'} = [ 'x', 'Q' ];
    }
    $cAns =~ s/$differential/Q/;
    $eval = fun_cmp( $cAns, %opts );

    return( sub { 
	my $sAns = shift();
	$sAns = '' if ( ! defined( $sAns ) );
	$sAns =~ s/$differential/Q/;

	my $ansHash = $eval->evaluate( $sAns );
  # replace Q with the correct differential
  # are there missing values?
	foreach my $v ( qw( correct_ans original_correct_ans student_ans 
			    original_student_ans preview_text_string 
			    preview_latex_string ) ) {
	    $ansHash->{$v} = '' if ( ! defined( $ansHash->{$v} ) );
	}
	$ansHash->{'correct_ans'} =~ s/Q/$differential/;
	$ansHash->{'original_correct_ans'} =~ s/Q/$differential/;
	$ansHash->{'student_ans'} =~ s/Q/$differential/;
	$ansHash->{'original_student_ans'} =~ s/Q/$differential/;
	$ansHash->{'preview_text_string'} =~ s/Q/$differential/;
	$ansHash->{'preview_latex_string'} =~ s/Q/$differential/;

	return $ansHash;
    } );
}

# numfun_cmp
# an answer evaluator that requires that the answer be 
# simplified to the number given without returning an error if 
# it's a function
#
sub numfun_cmp {
    my $cAns = shift();
    my %opts = @_;

    my $eval1 = fun_cmp( $cAns, @_ );
    my $eval2 = num_cmp( $cAns, @_ );

    return( sub {
        my $sAns = shift();
	my $ans1 = $eval1->evaluate( $sAns );
	my $ans2 = $eval2->evaluate( $sAns );

	if ( $ans2->{'score'} ) {
	    return( $ans2 );
	} else {
	    $ans1->{'score'} = 0;
	    return( $ans1 );
        }
    } );
}

# numorfun_cmp
# an answer evaluator that first checks to see if the student answer
# checks correctly as a number, and if so returns that result; if not,
# repeats the check with a function checker and returns that.
#
sub numorfun_cmp {
    my $cAns = shift();
    my ( $numOptsRef, $funOptsRef ) = @_;
    my $eval1 = fun_cmp( $cAns, %$funOptsRef );
    my $eval2 = num_cmp( $cAns, %$numOptsRef );

    return( sub {
        my $sAns = shift();
	my $ans1 = $eval1->evaluate( $sAns );
	my $ans2 = $eval2->evaluate( $sAns );

	if ( $ans2->{'score'} ) {
	    return( $ans2 );
	} else {
	    return( $ans1 );
        }
    } );
}

sub classify_num_cmp {
    return classify_cmp( @_, 'classifymode'=>'num' );
}
sub classify_fun_cmp {
    return classify_cmp( @_, 'classifymode'=>'fun' );
}
sub classify_cmp { 
    my $cAns = shift();
    my %opts = @_;

    my $classifymode = 'num';
    if ( defined( $opts{'classifymode'} ) ) {
	$classifymode = $opts{'classifymode'};
	delete( $opts{'classifymode'} );
    }

    my $ordered = 0;
    if ( defined( $opts{'order'} ) ) {
	$ordered = 1 if ( $opts{'order'} eq 'strict' );
	delete( $opts{'order'} );
    }

    my @pts = split(/\s*,\s*/, $cAns);

    my @xeval; my @ceval;
    foreach ( @pts ) {
        my ( $x, $c ) = split(/\s*=\s*/);
	$c = '' if ( ! defined($c) );
	if ( $classifymode eq 'num' ) {
	    push( @xeval, num_cmp( $x, %opts ) );
        } else {
	    push( @xeval, fun_cmp( $x, %opts ) );
	}
	push( @ceval, str_cmp( $c ) );
    }

    return( sub { 
	my $sAns = shift();
	my @sAnsList = split(/\s*,\s*/, $sAns);
	my @sAnsw = ();
	foreach ( @sAnsList ) {
	    my ( $x, $c ) = split(/\s*=\s*/);
	    $x = 'none' if ( ! defined( $x ) );
	    $c = '' if ( ! defined( $c ) );
	    push( @sAnsw, [ $x, $c ] );
        }

  # now build a set of answer hashes, one for each student answer
	my @results = ();
	my @undone = ();    # list of unused evaluators
	my $nummatched = 0; # number of student answers matched 
	for( my $j=0; $j<@xeval; $j++ ) {
	    my $done = 0;
	    if ( $ordered ) {
		if ( $j < @sAnsw ) {
		    my $x_hash = $xeval[$j]->evaluate($sAnsw[$j]->[0]);
		    my $c_hash = $xeval[$j]->evaluate($sAnsw[$j]->[1]);
		    my $res = $x_hash->AND($c_hash);
		    $res->{'preview_text_string'} = 
			$x_hash->{'preview_text_string'} . "=" .
			$c_hash->{'preview_text_string'};
		    $res->{'preview_latex_string'} = 
			$x_hash->{'preview_latex_string'} . "=" .
			$c_hash->{'preview_latex_string'};
		    $results[$j] = $res;
		    $nummatched++;
		} else {
		    last;
		}
	    } else {
		for ( my $i=0; $i<@sAnsw; $i++ ) {
		    my $x_hash = $xeval[$j]->evaluate($sAnsw[$i]->[0]);

		    if ( $x_hash->score() ) {
			my $c_hash = $ceval[$j]->evaluate($sAnsw[$i]->[1]);

			my $res = $x_hash->AND($c_hash);
			$res->{'preview_text_string'} = 
			    $x_hash->{'preview_text_string'};
			$res->{'preview_latex_string'} = 
			    $x_hash->{'preview_latex_string'};

			if ( defined($c_hash->{preview_text_string}) &&
			     $c_hash->{preview_text_string} ne '' ) {
			    $res->{preview_text_string} .= "=" .
				$c_hash->{'preview_text_string'};
			    $res->{preview_latex_string} .= "=" .
				$c_hash->{'preview_latex_string'};
			}
			$results[$i] = $res;
			$done = 1;
			$nummatched++;
		    }
		    last if ( $done );
		}
		if ( ! $done ) {
		    push( @undone, [ $xeval[$j], $ceval[$j] ] );
		}
	    }
	    last if ( $nummatched == @sAnsw );
	}
  # check any student answers we haven't yet matched
        if ( $nummatched < @sAnsw ) {
	    for ( my $i=0; $i<@sAnsw; $i++  ) {
	        next if ( ref($results[$i]) );
		my ( $x_hash, $c_hash, $res );
		if ( @undone ) {
		    my $aeval = shift(@undone);
		    $x_hash = $aeval->[0]->evaluate($sAnsw[$i]->[0]);
		    $c_hash = $aeval->[1]->evaluate($sAnsw[$i]->[1]);
		    $res = $x_hash->AND( $c_hash );
		} else {
		    $res = new AnswerHash;
		    $res->{'correct_ans'} = 'none';
		    $res->{'original_correct_ans'} = 'none';
		    $res->{'student_ans'} = $sAnsw[$i]->[0] . "=" . 
			$sAnsw[$i]->[1];
		    $res->{'original_student_ans'} = $sAnsw[$i]->[0] . "=" . 
			$sAnsw[$i]->[1];
		    $res->{'score'} = 0;
		    $x_hash = $xeval[0]->evaluate($sAnsw[$i]->[0]);
		    $c_hash = $ceval[0]->evaluate($sAnsw[$i]->[1]);
		}
	        $res->{'preview_text_string'} = 
		    $x_hash->{'preview_text_string'};
	        $res->{'preview_latex_string'} = 
		    $x_hash->{'preview_latex_string'};
		if ( defined( $c_hash->{preview_text_string} ) &&
		     $c_hash->{preview_text_string} ne '' ) {
		    $res->{preview_text_string} .=  "=" .
			$c_hash->{'preview_text_string'};
		    $res->{preview_latex_string} .=  "=" .
			$c_hash->{'preview_latex_string'};
		}
		$results[$i] = $res;
            }
	} 
  # and get any other results they didn't submit
	my @neededResults = ();
	foreach ( @undone ) {
	    my $r = $_->[0]->evaluate('');
	    $r->AND( $_->[1]->evaluate('') );
	    $r->{score} = 0;
	    push( @neededResults, $r );
	}

  # ok, now build a big and...
	my $endres = ( defined($results[0]) ) ? $results[0] : new AnswerHash;
	for ( my $i=1; $i<@results; $i++ ) {
	    $endres = $endres->AND( $results[$i] );
	}
#	for ( my $i=0; $i<@neededResults; $i++ ) {
#	    $endres = $endres->AND( $neededResults[$i] );
#	}
	$endres->{'student_ans'} = $sAns;
	$endres->{'score'} = 0 if ( @xeval > @sAnsw );

	return $endres;
    } );
}

1;

