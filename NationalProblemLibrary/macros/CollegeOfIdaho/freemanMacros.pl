sub textbook_ref {
    my ($text, $sec, $ex) = @_;
    return "$text section $sec, exercise $ex";
}

sub textbook_ref_corr {
    return "Similar to " . textbook_ref(@_) . ".";
}

sub textbook_ref_exact {
    return "From " . textbook_ref(@_) . ".";
}

sub list_random_multi_uniq($@) {
	my ($n, @list) = @_;
	my @result;
	while (@result < $n) {
		my $i = random(0,$#list,1);
		if ($i==0) {
			push @result, shift @list;
		} elsif ($i==$#list) {
			push @result, pop @list;
		} else {
			push @result, $list[$i];
			$list[$i] = pop @list;
		}
	}
	return @result;
}

#sam# copied from bkellMacros.pl -- no reason to maintain two macro files.
#sam# FIXME -- these should probably lose their "bkell_" prefixes.

# bkellMacros.pl
# Brian Kell <bkell@cse.unl.edu>
# Last updated 3:24 CDT, 24 Jun 2007

###############################################################################
# bkell_linear_simplify($a, $b)
#
# Returns a string representing $a*x+$b in simplified form, where "simplified"
# means something along the lines of the following:
#
#  a    b   output
# ---  ---  ------
#  0    0      0
#  1    1     x+1
# -1   -1    -x-1
# -1    5     5-x
#  2    0     2x
# -4    3    3-4x
# -4   -3    -4x-3
#
sub bkell_linear_simplify
{
	my ($a, $b) = @_;

	if ($a == 0) {
		return "$b";
	} elsif ($b == 0) {
		if ($a == -1) {
			return "-x";
		} elsif ($a == 1) {
			return "x";
		} else {
			return "${a}x";
		}
	} elsif ($a < 0 && $b > 0) {
		if ($a == -1) {
			return "$b-x";
		} else {
			return "$b-".(abs $a)."x";
		}
	} elsif ($a == 1) {
		return "x".sprintf("%+d", $b);
	} elsif ($a == -1) {
		return "-x".sprintf("%+d", $b);
	} else {
		return "${a}x".sprintf("%+d", $b);
	}
}

###############################################################################
# bkell_simplify_fraction($num, $denom)
#
# Simplifies the fraction $num/$denom; returns the list ($num, $denom).
#
sub bkell_simplify_fraction
{
	my ($num, $denom) = @_;
	
	if ($num == 0) { return (0, 1); }
	
	my $sign = +1;
	if ($num < 0) { $sign *= -1; $num *= -1; }
	if ($denom < 0) { $sign *= -1; $denom *= -1; }
	
	for ($i = 2; $i <= $num && $i <= $denom; ++$i) {
		while ($num % $i == 0 && $denom % $i == 0) {
			$num /= $i;
			$denom /= $i;
		}
	}
	
	return ($sign*$num, $denom);
}

###############################################################################
# bkell_simplify_fraction_string($num, $denom [, $flags])
#
# Returns a string like "$num/$denom" in simplified form. If the string $flags
# contains "+", then a leading "+" is included if the fraction is non-negative.
# If $flags contains "0", then a fraction with a value of 0 will cause the
# empty string to be returned. If $flags contains "1", then a fraction with a
# value of 1 or -1 will cause only the sign to be returned (or the empty
# string, if the fraction is non-negative and $flags does not contain "+"). If
# $flags contains "(", then parentheses will be placed around "$num/$denom"
# (the sign, if it exists, will be outside the parentheses); if $flags contains
# "[", then parentheses will be used only if a sign is used and the denominator
# is other than 1. A flag of "(" overrides "]". If $flags contains "f", then
# the string returned will be in the form "{$num \over $denom}" instead of the
# normal slashed version.
#
sub bkell_simplify_fraction_string
{
	my ($num, $denom, $flags) = @_;
	if (!defined $flags) { $flags = ""; }
	
	($num, $denom) = bkell_simplify_fraction($num, $denom);
	
	my $sign = ($num >= 0 ? ($flags =~ /\+/ ? "+" : "") : "-");
	$num = abs $num;

	my ($pre, $post);
	if ($flags =~ /\(/ || ($flags =~ /\[/ && $sign ne "" && $denom != 1)) {
		($pre, $post) = ("(", ")");
	} else {
		($pre, $post) = ("", "");
	}
	
	if ($num == 0 && $flags =~ /0/) { return ""; }
	if ($denom == 1) {
		if ($num == 1 && $flags =~ /1/) { return "$sign"; }
		return "$sign$pre$num$post";
	}
	if ($flags =~ /f/) { return "$sign$pre {$num \\over $denom}$post"; }
	return "$sign$pre$num/$denom$post";
}

###############################################################################
# bkell_poly_term($coeff_num, $coeff_denom, $var [, "+"])
#
# Produces and simplifies a term of a polynomial of the general form
# "($coeff_num/$coeff_denom)$var". Handles special cases (such as $num==0,
# $denom==1, etc.). If the fourth argument is "+", then a leading "+" is
# included if the term is positive.
#
sub bkell_poly_term
{
	my ($coeff_num, $coeff_denom, $var, $plus) = @_;
	if (!defined $plus) { $plus = ""; }
	
	if ($coeff_num == 0) { return ""; }

	my $sign = +1;
	if ($coeff_num < 0) { $sign *= -1; $coeff_num *= -1; }
	if ($coeff_denom < 0) { $sign *= -1; $coeff_denom *= -1; }
	$sign = ($sign > 0 ? ($plus eq "+" ? "+" : "") : "-");
	
	my ($num, $denom) = bkell_simplify_fraction($coeff_num, $coeff_denom);
	
	if ($denom == 1) {
		if ($num == 1) {
			return "$sign$var";
		} else {
			return "$sign$num$var";
		}
	}
	
	return "$sign($num/$denom)$var";
}

###############################################################################
# bkell_gcd($x, $y)
#
# Returns the greatest common divisor of $x and $y.
#
sub bkell_gcd {
	my ($x, $y) = @_;
	$x = abs $x;
	$y = abs $y;
	if ($x > $y) { ($x, $y) = ($y, $x); }
	if ($x == 0) { return $y; }
	my $r = $y % $x;
	if ($r == 0) { return $x; }
	return bkell_gcd($x, $r);
}

###############################################################################
# bkell_poly_eval($x, $a_n, ..., $a_0)
#
# Evaluates the polynomial a_n*x^n + ... + a_1*x + a_0 at the given value of x.
#
sub bkell_poly_eval
{
	my $x = shift;
	my $value = shift;
	while (@_) { $value *= $x; $value += shift; }
	return $value;
}

###############################################################################
# bkell_real_zeros_finder($a_n, ..., $a_0)
#
# Returns a list of numerical approximations of the zeros of the polynomial
# a_n*x^n + ... + a_1*x + a_0, in order from least to greatest.
#
# The possibility of overflow or underflow is ignored. Overflow is likely to be
# a bigger problem than underflow.
#
# Do not use this code to guide missiles or control nuclear power plants.
#
sub bkell_real_zeros_finder
{
	my @coeffs = @_;
	
	while (@coeffs && $coeffs[0] == 0) { shift @coeffs; }
	my $deg = $#coeffs;

	if ($deg == -1) {
		return ("x");  # zero polynomial is zero everywhere
	} elsif ($deg == 0) {
		return ();  # constant nonzero polynomial has no zeros
	} elsif ($deg == 1) {
		return (-$coeffs[1]/$coeffs[0]);  # linear polynomial has one zero
	}
	
	# find critical points
	my @derivative = @coeffs;
	pop @derivative;
	for (my $i = 0; $i < $#derivative; ++$i) {
		$derivative[$i] *= @derivative - $i;
	}
	my @cp = bkell_real_zeros_finder(@derivative);
	
	# if no critical points, we have a monotone function
	if (!@cp) {
		my ($lb, $rb) = (-1, 1);
		my $y1 = bkell_poly_eval($lb, @coeffs);
		my $y2 = bkell_poly_eval($rb, @coeffs);
		my $sign = ($y1 < $y2 ? +1 : -1);
		while ($sign * $y1 > 0) {
			$lb *= 2;
			$y1 = bkell_poly_eval($lb, @coeffs);
		}
		while ($sign * $y2 < 0) {
			$rb *= 2;
			$y2 = bkell_poly_eval($rb, @coeffs);
		}
		my $guess_x = ($lb + $rb) / 2;
		while ($lb < $guess_x && $guess_x < $rb &&
			(my $guess_y = bkell_poly_eval($guess_x, @coeffs)) != 0)
		{
			if ( ($y1 < 0 && $guess_y < 0) || ($y1 > 0 && $guess_y > 0) ) {
				$lb = $guess_x;
			} else {
				$rb = $guess_x;
			}
			$guess_x = ($lb + $rb) / 2;
		}
		return ($guess_x);
	}
	
	my @zeros = ();

	# search for a zero to the left of the first critical point
	{
		my $y = bkell_poly_eval($cp[0], @coeffs);
		# we catch this case when we check between critical points:
		last if $y == 0;
		# not really the limit, but only the sign matters:
		my $lim = $coeffs[0] * ($deg % 2 ? -1 : +1);
		if ( ($y > 0 && $lim < 0) || ($y < 0 && $lim > 0) ) {
			my ($lb, $rb) = (undef, $cp[0]);
			my $guess_x = $rb - 10;
			if ($guess_x >= 0) { $guess_x = -10; }
			while ((!defined $lb || $lb < $guess_x) && $guess_x < $rb &&
				(my $guess_y = bkell_poly_eval($guess_x, @coeffs)) != 0)
			{
				if ( ($y > 0 && $guess_y > 0) || ($y < 0 && $guess_y < 0) ) {
					$rb = $guess_x;
					if (defined $lb) {
						$guess_x = ($lb + $guess_x) / 2;
					} else {
						$guess_x *= 2;
					}
				} else {
					$lb = $guess_x;
					$guess_x = ($guess_x + $rb) / 2;
				}
			}
			push @zeros, $guess_x;
		}
	}
	
	# search for zeros between critical points
	for (my $i = 0; $i < $#cp; ++$i) {
		my $y1 = bkell_poly_eval($cp[$i], @coeffs);
		if ($y1 == 0) {
			push @zeros, $cp[$i];
			next;
		}
		my $y2 = bkell_poly_eval($cp[$i+1], @coeffs);
		if ($y2 == 0) {
			push @zeros, $cp[$i+1];
			++$i;
			next;
		}
		next if ($y1 > 0 && $y2 > 0) || ($y1 < 0 && $y2 < 0);
		my ($lb, $rb) = ($cp[$i], $cp[$i+1]);
		my $guess_x = ($lb + $rb) / 2;
		while ($lb < $guess_x && $guess_x < $rb &&
			(my $guess_y = bkell_poly_eval($guess_x, @coeffs)) != 0)
		{
			if ( ($y1 > 0 && $guess_y > 0) || ($y1 < 0 && $guess_y < 0) ) {
				$lb = $guess_x;
			} else {
				$rb = $guess_x;
			}
			$guess_x = ($lb + $rb) / 2;
		}
		push @zeros, $guess_x unless @zeros && $zeros[-1] == $guess_x;
	}

	# search for a zero to the right of the last critical point
	{
		my $y = bkell_poly_eval($cp[-1], @coeffs);
		if ($y == 0 && $zeros[-1] != $cp[-1]) {
			push @zeros, $cp[-1];
			last;
		}
		if ( ($y > 0 && $coeffs[0] < 0) || ($y < 0 && $coeffs[0] > 0) ) {
			my ($lb, $rb) = ($cp[-1], undef);
			my $guess_x = $lb + 10;
			if ($guess_x <= 0) { $guess_x = 10; }
			while ($lb < $guess_x && (!defined $rb || $guess_x < $rb) &&
				(my $guess_y = bkell_poly_eval($guess_x, @coeffs)) != 0)
			{
				if ( ($y > 0 && $guess_y > 0) || ($y < 0 && $guess_y < 0) ) {
					$lb = $guess_x;
					if (defined $rb) {
						$guess_x = ($guess_x + $rb) / 2;
					} else {
						$guess_x *= 2;
					}
				} else {
					$rb = $guess_x;
					$guess_x = ($lb + $guess_x) / 2;
				}
			}
			push @zeros, $guess_x unless @zeros && $zeros[-1] == $guess_x;
		}
	}
	
	return @zeros;
}

###############################################################################
# bkell_floor($x)
#
# Returns the floor of $x. Normally this would be done with POSIX::floor, but
# WeBWorK doesn't allow you to use standard modules like POSIX.
#
sub bkell_floor
{
	my $x = shift;
	my $floor = int $x;
	if ($x < 0 && $x != $floor) { $floor -= 1; }
	return $floor;
}

###############################################################################
# bkell_ceil($x)
#
# Returns the ceiling of $x.
#
sub bkell_ceil
{
	return -bkell_floor(-shift);
}

###############################################################################
# bkell_sigfigs($x, $n)
#
# Returns a string containing $x rounded to $n significant figures.
#
sub bkell_sigfigs
{
	my ($x, $n) = @_;
	
	if ($x == 0) { return "0".($n > 1 ? "." : "").("0" x ($n-1)); }
	
	my $minus = "";
	if ($x < 0) {
		$minus = "-";
		$x = -$x;
	}
	
	my $floor_log = bkell_floor(log($x)/log(10));
	
	if ($floor_log+1 >= $n) {
		my $sf = 10**($floor_log-$n+1);
		return $minus.(sprintf("%.0f", $x/$sf)*$sf);
	} else {
		my $digits = $n-$floor_log-1;
		return $minus.sprintf("%.${digits}f", $x);
	}
}

###############################################################################
# bkell_125($x)
#
# Returns the value logarithmically nearest $x in the sequence
#     ..., -1000, -500, -200, -100, -50, -20, -10, -5, -2, -1, -0.5, -0.2,
#          -0.1, -0.05, -0.02, -0.01, ..., 0, ..., 0.01, 0.02, 0.05, 0.1,
#          0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, ... .
#
sub bkell_125
{
	my $x = shift;
	
	if ($x == 0) { return 0; }
	
	my $sign = +1;
	if ($x < 0) { $sign = -1;  $x = -$x; }
	
	my $log = log($x)/log(10);
	my $characteristic = bkell_floor($log);
	my $mantissa = $log - $characteristic;
	
	my $log2 = log(2)/log(10);
	my $log5 = log(5)/log(10);
	my $m;
	if ($mantissa < $log2 / 2) {
		$m = 0;
	} elsif ($mantissa < ($log2 + $log5) / 2) {
		$m = $log2;
	} elsif ($mantissa < ($log5 + 1) / 2) {
		$m = $log5;
	} else {
		$m = 1;
	}
	
	return $sign * (10 ** ($characteristic + $m));
}

###############################################################################
# bkell_list_random_selection($n, @list)
#
# Returns a selection of $n distinct elements of @list. This is like
# list_random_multi_uniq in freemanMacros.pl, except that this function will
# always return the elements in the same order as they appear in @list.
#
sub bkell_list_random_selection
{
	my $n = int abs shift;  # so strange $n won't cause infinite loop
	my @list = @_;
	
	my $needed = $n;
	my @result = ();
	while ($needed && @list) {
		if (random(1, scalar @list) <= $needed) {
			push @result, shift @list;
			--$needed;
		} else {
			shift @list;
		}
	}
	
	return @result;
}

###############################################################################
# bkell_graph_axis($a, $b)
#
# Returns a list ($min, $max, $step), where $min <= $a, $max >= $b, $step is a
# power of 10, $min and $max are multiples of $step, abs($min) <= 9*$step, and
# abs($max) <= 9*$step. Useful for deciding bounds for the axis of a graph. For
# example, to make a graph axis that can handle values between $a and $b, call
# bkell_graph_axis, and then set the minimum value of the axis to $min and the
# maximum to $max, and put tick marks every $step units.
#
sub bkell_graph_axis
{
	my ($a, $b) = @_;
	
	if ($a > $b) { ($a, $b) = ($b, $a); }
	
	my $s1 = 0;
	my $s2 = 0;
	
	if ($a != 0) { $s1 = bkell_floor(log(abs $a)/log(10)); }
	if ($b != 0) { $s2 = bkell_floor(log(abs $b)/log(10)); }
	
	my $s = ($s1 > $s2 ? $s1 : $s2);
	
	$step = 10**$s;
	$min = $step * bkell_floor($a/$step);
	$max = $step * bkell_ceil($b/$step);

	return ($min, $max, $step);
}

####################################################################### EOF ###
