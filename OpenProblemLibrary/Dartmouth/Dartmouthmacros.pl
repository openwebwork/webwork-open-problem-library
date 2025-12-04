#!/usr/bin/perl

# this is equivalent to use strict, but can be used within the Safe compartment.
BEGIN{
        be_strict;
} 

## Some local macros

sub trs_mod{
    my @inputs = @_;
    my $a = $inputs[0];
    my $b = $inputs[1];
    my $zero = 1e-12;
    if ($b < 0) {$b = - $b;}

## Want mod(a,b) but perl and int are flawed
    my $modvalue = $a;
#    if ($a >= 0 && $a < $b) {$modvalue = $a;}

    while ($modvalue >= $b){$modvalue = $modvalue - $b;}
    while ($modvalue < 0) {$modvalue = $modvalue + $b;}
    if (abs($modvalue) <= $zero){$modvalue = 0;}
    if (abs($modvalue - $b) <= $zero){$modvalue = 0;}
## Fudge for roundoff error
    return $modvalue;
}

## Compute the product of a scalar and a vector (scalar first)
sub scalar_mult_vector{
    ## Put the parameters passed into an array of values
    my @vector = @_;
    
    ## Split off the first entry as the scalar, and the rest as the vector
    my $scalar = $vector[0];
    my @vectorb = @vector[(1 .. $#vector )];

    ## Initialize scalar multiple as empty vector
    my @scalar_multiple=();
    
    my $i;
    for ($i=0; $i <= $#vectorb; $i++)
        {
            $scalar_multiple[$i] = $scalar * $vectorb[$i];
        }
    return @scalar_multiple;
}



## Compute the sum of two vectors
## Perl doesn't seem to have builtin array arithmetic
sub vector_sum {
    ## Put the parameters passed into an array of values
    my @vector = @_;
    ## $#vector is the number of elements in vector minus 1
    my $halflength = ($#vector - 1)/2;
    ## Slice the input into two equal length vectors
    my @vectora = @vector[(0 .. $halflength)];
    my @vectorb = @vector[($halflength+1 .. $#vector )];

    ## Initialize vector sum to empty array
    my @vector_sum=();
    
    my $i;
    for ($i=0; $i <= $#vectora; $i++)
        {
            $vector_sum[$i] = $vectora[$i] + $vectorb[$i];
        }
    return @vector_sum;
}

## Compute the difference of two vectors
sub vector_diff{
    ## Put the parameters passed into an array of values
    my @vector = @_;
    ## $#vector is the number of elements in vector minus 1
    my $halflength = ($#vector - 1)/2;
    ## Slice the input into two equal length vectors
    my @vectora = @vector[(0 .. $halflength)];
    my @vectorb = @vector[($halflength+1 .. $#vector )];

    return vector_sum(@vectora, scalar_mult_vector(-1, @vectorb));
}


## Compute the length of a vector
sub vec_length {
    ## Put the paramaters passed into an array of values
    my @vector = @_;

    ## Initialize maximum value to first element
    my $vector_length = 0;
    
    my $i;
    for ($i=0; $i <= $#vector; $i++)
        {
            $vector_length = $vector_length + $vector[$i] * $vector[$i];
        }
    $vector_length = sqrt($vector_length);
    return $vector_length;
}

sub vector_length {
    my @vector = @_;
    return vec_length(@vector);
}

## Computes the dot product of two vectors (assumed of the same dimension)
sub dot_product {
    ## Put the parameters passed into an array of values
    my @vector = @_;
    ## $#vector is the number of elements in vector minus 1
    my $halflength = ($#vector - 1)/2;
    ## Split the input into two equal length vectors
    my @vectora = @vector[(0 .. $halflength)];
    my @vectorb = @vector[($halflength+1 .. $#vector )];

    ## Initialize dot product to zero
    my $dot = 0;
    
    my $i;
    for ($i=0; $i <= $#vectora; $i++)
        {
            $dot = $dot + $vectora[$i] * $vectorb[$i];
        }
    return $dot;
}

sub cross_product {
    ## Put the parameters passed into an array of values
    my @vector = @_;
    
    ## Slice the input into two equal length vectors
    my @vectora = @vector[(0 .. 2)];
    my @vectorb = @vector[(3 .. 5)];

    ## Initialize dot product to zero
    my @cross = ();
    
    $cross[0] = $vectora[1]*$vectorb[2] - $vectora[2]*$vectorb[1];
    $cross[1] = $vectora[2]*$vectorb[0] - $vectora[0]*$vectorb[2];
    $cross[2] = $vectora[0]*$vectorb[1] - $vectora[1]*$vectorb[0];
    return @cross;
}

## Compute the maximum value in a list
#sub max {
#    ## Put the paramters passed into an array of values
#    my @values = @_;
#
#    ## Initialize maximum value to first element
#    my $max = $values[0];
#    
#    my $i;
#    for ($i=1; $i <= $#values; $i++)
#        {
#        if ($values[$i] > $max) {
#            $max = $values[$i];
#            } 
#        }
#    return $max;
#}

## Compute the minimum value in a list
#sub min {
#    ## Put the paramters passed into an array of values
#    my @values = @_;
#
#    ## Initialize minimum value to first element
#    my $min = $values[0];
#    
#    my $i;
#    for ($i=1; $i <= $#values; $i++)
#        {
#        if ($values[$i] < $min) {
#            $min = $values[$i];
#            } 
#        }
#    return $min
#}    


## clean_scalar_string is invoked to make expressions like "$a x" look
## better when $a = 0, -1, 1
## Usage:  clean_scalar_string(scalar, "quoted string");
## Example:  clean_scalar_string(-1,"\pi") returns "-\pi"
sub clean_scalar_string{
    my $local_scalar = shift;
    my $local_fixed_object = shift;
    my $return_object;

    if ($local_scalar == 0) {$return_object = "0";}
    elsif ($local_scalar == 1) {$return_object = "$local_fixed_object";}
    elsif ($local_scalar == -1) {$return_object = "-$local_fixed_object";}
    else {$return_object = "${local_scalar}${local_fixed_object}";}
    return $return_object;
}

## Computes the greatest common divisor of two integers
## Example:  gcd(-300, 125) returns 25
sub trs_gcd{
    my $a = shift;
    my $b = shift;
    my $c;
    my $abs_a = abs($a);
    my $abs_b = abs($b);
    if ($abs_b == 0) {return $abs_a;}
    else {$c = $abs_a % $abs_b;
       return trs_gcd($abs_b, $c);}
}

## reduced_fraction takes a pair of integers $numerator, $denominator
## ($denominator != 0) and returns an array of two elements @fraction
## $fraction[0] is the reduced numerator; $fraction[1] the reduced
## denominator
## Puts the sign of the fraction, if negative, in the numerator
##
## Usage:  @fraction = reduced_fraction($numerator, $denominator)
##
sub reduced_fraction{
    my $local_numerator = shift;
    my $local_denominator = shift;
    my $sign_of_num = 1;
    my $sign_of_denom = 1;
    my $sign_of_quotient;
    my @local_fraction = ();

    if ($local_numerator < 0) {$sign_of_num = -1;}
    if ($local_denominator < 0) {$sign_of_denom = -1;}
    $sign_of_quotient = $sign_of_num * $sign_of_denom;

    my $local_gcd = trs_gcd($local_numerator, $local_denominator);
## reduced numerator
    $local_fraction[0] = ($sign_of_quotient * abs($local_numerator)) / $local_gcd;
## reduced denominator
    $local_fraction[1] = abs($local_denominator) / $local_gcd;
    return @local_fraction;
}


## Given Cartesian coordinates x and y returns an
## array the zeroth element which is the radius
## and the first element which is the argument
## 0 <= theta < 2*pi
##
## Returns r=0 theta=0 for the origin
##
sub coordinates_polar{
    my $x = shift;
    my $y = shift;
    my @polar=();
    my $radius = 0;
    my $theta = 0;
    my $pi = acos(-1);

    $radius = sqrt($x**2 + $y**2);
    if ($radius != 0){
    if ($x == 0) {if ($y > 0) {$theta = $pi/2;}
                  else {$theta = 3*$pi/2;}}
    else
        {
            if ($y > 0){if ($x > 0){$theta = atan($y/$x);}
                        else {$theta = $pi - atan(-$y/$x);}}
            else {if ($x > 0){$theta = 2*$pi + atan($y/$x);}
                        else {$theta = $pi + atan($y/$x);}}
        }
    }              
    @polar=($radius, $theta);
    return @polar;
}


## Cylindarical coordinates from polar routine
sub coordinates_cylindrical{
    my $x = shift;
    my $y = shift;
    my $z = shift;
    my @cylindrical=(coordinates_polar($x, $y), $z);
    return @cylindrical;
}

## Spherical Coordinates from polar routine
##
sub coordinates_spherical{
    my $x = shift;
    my $y = shift;
    my $z = shift;
    my $rho = 0;
    my $phi = 0;
    $rho = sqrt($x*$x + $y*$y + $z*$z);
    my @npolar = ();
    @npolar =  coordinates_polar($x, $y);
    my @spherical=();
    if ($x ==0 && $y == 0){if ($z >= 0) {$phi = 0;}
                          else {$phi = acos(-1);}
                          @spherical=($rho,0,$phi);}
    else{
    $rho = sqrt($x*$x + $y*$y + $z*$z);
        
    @spherical=($rho, $npolar[1], acos($z/$rho));
        }
    return @spherical;
}





1;



