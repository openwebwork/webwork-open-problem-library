sub _unionVectors_init {}; # don't reload this file

######################################################################
#
#  A class that implements Vector and Point objects.  It allows you
#  to create them, perform arithmatic on them, and display them in
#  various formats.  
#
#  This is just a temprary hack until I finish the complete 
#  multi-variable parser that is in the works.  -- DPVC
#
#  Usage:
#
#     Point(x1,...,xn)     creates a point object with n coordinates
#     Vector(x1,...,xn)    creates a vector object with n coordinates
#
#     Norm(x)              computes the length of a vector
#     Unit(x)              computes a unit vector in the same direction as x
#
#     areParallel(x,y)     returns 1 if the vectors are parallel
#
#     vSum(x,y)            adds two points or vectors
#     vDiff(x,y)           computes x - y
#     vProd(a,x)           computes the scalar product ax for a point
#                            or vector x and scalar a
#     vDiv(x,a)            divides point or vector x by a
#     vDot(x,y)            computes the dot product x.y
#     vCross(x,y)          comptes the cross product of two vectors
#     vNeg(x)              computes -x
#     vEqual(x,y)          true when x and y are equal vectors
#     vCmp(x,y)            does a comparison of two points or vectors
#                            in lexicographic order (like <=> for vectors).
#                            when not of the same length, the shorter one
#                            is considered to be smaller.
#
#  These operations can be performed much easier by using the overload
#  package to overload the operators to work with point and vector
#  objects.  However, to do this in WeBWorK requires making this a
#  module and adding it to the PG_module_list.pl file (a system-level
#  change).  I'm working on a more complete multi-variable package
#  that will supersede this, and so wanted to keep it a local change
#  for now.
#
#  The Point and Vector routines can accept a variety of input
#  formats, for example, Point([1,2,3]) also produces the same result
#  as Point(1,2,3).  So you could do $x = [1,2,3], $y = Point($x), or
#  $x = vDiff([1,2,3],[4,5,6]) to obtain the point (-3,-3,-3).
#
#  You can also pass Point and Vector objects themselves, which
#  provides a means of converting one type to the other.  For example:
#
#      $x = Point(1,2,3);  $y = Point(4,5,6);
#      $v = Vector(vDiff($y,$x));
#
#  produces the vector from $x to $y (without the Vector call, the
#  result of vDiff would be a Point).
#
#  The various vector-based answer checkers all accept Vector or Point
#  objects as their inputs (and usually also accept strings like
#  "(1,2,3)", or arrays like [1,2,3]).
#
#  Once you have a Point or Vector object, $x, you can get a printable
#  version of the object using $x->string, $x->TeX or $x->answer.
#  Answer and string both produce text strings suitable for display as
#  the correct answer, while TeX produces a string for use within 
#  \( \)  in the problem itself.  For example:
#
#     $P = Point(1,2,3);
#     BEGIN_TEXT
#     Consider the point \(P = \{$P->TeX\}\).
#     END_TEXT
#

##################################################
#
#  Can't seem to get Exporter to work, so doing it by hand -- DPVC
#  (If you turn this into a .pm file, you need to make these
#  subroutines in PG_priv::, e.g., sub PG_priv::Point ...)
#

sub Point {unionVectors::Point(@_)}
sub Vector {unionVectors::Vector(@_)}

sub isVector {unionVectors::isVector(@_)}

sub Norm {unionVectors::norm(@_)}
sub Unit {unionVectors::unit(@_)}
sub areParallel {unionVectors::areParallel(@_)}

#
#  Can't use 'use overload' from loadMacros, so doing
#  explicit calls.  (If the file is made a .pm file and added
#  to PG_module_list.pl, then things can work much nicer.)
#
sub vSum   {unionVectors::add(@_)}
sub vDiff  {unionVectors::sub(@_)}
sub vProd  {unionVectors::mult($_[1],$_[0])}
sub vDiv   {unionVectors::div(@_)}
sub vDot   {unionVectors::dot(@_)}
sub vCross {unionVectors::cross(@_)}
sub vNeg   {unionVectors::neg(@_)}
sub vCmp   {unionVectors::compare(@_)}
sub vEqual {unionVectors::compare(@_) == 0}

##################################################

package unionVectors;
my $pkg = 'unionVectors';

#use strict;
#use vars qw(%parens);

#use overload
#  '+'   => \&add,
#  '-'   => \&sub,
#  '*'   => \&mult,
#  '/'   => \&div,
#  '**'  => \&power,
#  '.'   => \&dot,
#  'x'   => \&cross,
#  '<=>' => \&compare,
#  'cmp' => \&compare,
#  'neg' => sub {$_[0]->neg},
#  'abs' => sub {$_[0]->abs},
#  '""'  => \&string,
#  'nomethod' => \&nomethod;

#
#  Usually we don't want to see the full precision, so
#  use this for display purposes (computation still at
#  full precision)
# 
my $numberFormat = '%.6g';  #  could be '%s' for full precision

#
#  What a number looks like
#
my $numPattern = '-?(\d+(\.\d*)?|\.\d+)(E[-+]?\d+)?';

#
#  What parentheses to use for points and vectors
#
%parens = (
   'Point'  => {open => '(', close => ')'},
   'Vector' => {open => '<', close => '>'},
);

##################################################

#
#  Create an object of the required type
#
sub Point {$pkg->new('Point',@_)}
sub Vector {$pkg->new('Vector',@_)}

#
#  Create a new object of the requested type using the given data
#
#  Check that the type is valid
#  Get the data into an array if there is more than one coordinate given
#  If the input is already a point or vector, use its data otherwise
#    Make it an array if it isn't already
#    Check that there is at least one coordinate
#    Check that each coordinate is a number or string
#  Return the new object
#
sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $type = shift;
  die "Unknown multivariable type '$type'" unless defined($parens{$type});
  my $p = shift; $p = [$p,@_] if (scalar(@_) > 0);
  if (isVector($p)) {$p = [$p->value]} else {
    $p = [$p] if (defined($p) && ref($p) ne 'ARRAY');
    die $type."s must have at least one coordinate"
      unless defined($p) && scalar(@{$p}) > 0;
    foreach my $x (@{$p}) {die "Can't use ".showType($x)." as a coordinate"
      if ref($x)}
  }
  bless {type => $type, data => $p}, $class;
}

#
#  Create a new object from data that is known to be good
#  (faster -- for use within the methods below)
#
sub make {
  my $self = shift; my $class = ref($self) || $self;
  my $type = $self->type;
  bless {type => $type, data => [@_]}, $class;
}

#
#  Get the object's data or type
#
sub value {@{(shift)->{data}}}
sub data {(shift)->{data}}
sub type {(shift)->{type}}

##################################################

#
#  Check if an item is of the required type
#
sub isNumber {my $n = shift; $n =~ m/^$numPattern$/oi}
sub isVector {ref(shift) eq $pkg}

#
#  Show an item's type for error messages
#
sub showType {
  my $value = shift;
  return "'".$value."'" unless ref($value);
  my $type = ref($value); $type = $value->type if ($type eq $pkg);
  return 'an '.$type if substr($type,0,1) =~ m/[aeio]/i;
  return 'a '.$type;
}

#
#  Return the object if it is a Point or Vector already,
#  otherwise make it into a Point.  (This guarantees that
#  we have a Point or Vector as a result.)
#
sub promote {
  my $x = shift;
  $x = [$x,@_] if scalar(@_) > 0 || isNumber($x);
  return $pkg->new('Point',$x) if ref($x) eq 'ARRAY';
  return $x if ref($x) eq $pkg;
  die "Can't convert ".showType($x)." to a Point";
}

#
#  Returns the object of highest precedence (where Vectors are
#  considered higher precedence than Points).
#
sub highestType {
  my ($l,$r) = @_;
  return $r if (isVector($r) && $r->type eq 'Vector');
  return $l;
}

##################################################
#
#  Implement the vector operations.  These are set up to be used
#  with the overload package, and the $flag argument is part of
#  that mechanism (it tells if the order of the operands has been
#  reversed).
#

#
#  A catch-all for operations that aren't defined
#  (when overloading is in effect).
#
sub nomethod {
  my ($l,$r,$flag,$op) = @_;
  die "Can't use '$op' with ".$l->type."-valued operands"
}

#
#  Add the vectors of they are of the same length.
#
sub add {
  my ($l,$r,$flag) = @_; my $self = highestType($l,$r);
  ($l,$r) = (promote($l)->data,promote($r)->data);
  die $self->type." addition with different number of coordiantes"
    unless scalar(@{$l}) == scalar(@{$r});
  my @s = ();
  foreach my $i (0..scalar(@{$l})-1) {push(@s,$l->[$i] + $r->[$i])}
  return $self->make(@s);
}

#
#  Subtract the vectors, if they are of the same length
#
sub sub {
  my ($l,$r,$flag) = @_; my $self = highestType($l,$r);
  ($l,$r) = (promote($l)->data,promote($r)->data);
  die $self->type." subtraction with different number of coordiantes"
    unless scalar(@{$l}) == scalar(@{$r});
  if ($flag) {my $tmp = $l; $l = $r; $r = $tmp};
  my @s = ();
  foreach my $i (0..scalar(@{$l})-1) {push(@s,$l->[$i] - $r->[$i])}
  return $self->make(@s);
}

#
#  Multiply a vector by a scalar.  (Adding 0 seems to avoid some funny
#  things like -0 as the result.  Don't know why.)
#
sub mult {
  my ($l,$r,$flag) = @_; my $self = $l;
  die $l->type."s can only be multiplied by numbers" unless isNumber($r);
  my @coords = ();
  foreach my $x ($l->value) {push(@coords,$x*$r+0)}
  return $self->make(@coords);
}

#
#  Divide a vector by a non-zer scalar
#
sub div {
  my ($l,$r,$flag) = @_; my $self = $l;
  die "Can't divide by a ".$self->type if $flag;
  die $self->type."s can only be divided by numbers" unless isNumber($r);
  die "Division by zero" if $r == 0;
  my @coords = ();
  foreach my $x ($l->value) {push(@coords,$x/$r+0)}
  return $self->make(@coords);
}

#
#  Warn that powers don't make sense for vectors
#  (when overloading is in effect)
#
sub power {
  my ($l,$r,$flag) = @_; my $self = $l;
  die "Can't raise ".$self->type."s to powers" unless $flag;
  die "Can't use ".$self->type."s in exponents";
}

#
#  Dot two vectors together
#
sub dot {
  my ($l,$r,$flag) = @_; my $self = $l;
  ($l,$r) = (promote($l)->data,promote($r)->data);
  die "Dot product with different number of coordiantes"
    unless scalar(@{$l}) == scalar(@{$r});
  my $s = 0;
  foreach my $i (0..scalar(@{$l})-1) {$s += $l->[$i] * $r->[$i]}
  return $s;
}

#
#  Take the cross product of two vectors in 3D
#
sub cross {
  my ($l,$r,$flag) = @_; my $self = $l; $self->{type} = "Vector";
  ($l,$r) = (promote($l)->data,promote($r)->data);
  die $self->type."s must be in 3-space for cross product"
    unless scalar(@{$l}) == 3 && scalar(@{$r}) == 3;
  $self->make($l->[1]*$r->[2] - $l->[2]*$r->[1],
            -($l->[0]*$r->[2] - $l->[2]*$r->[0]),
              $l->[0]*$r->[1] - $l->[1]*$r->[0]);
}

#
#  Do a lexicographic comparison of two vectors
#
sub compare {
  my ($l,$r,$flag) = @_;
  ($l,$r) = (promote($l)->data,promote($r)->data);
  return scalar(@{$l}) <=> scalar(@{$r}) unless scalar(@{$l}) == scalar(@{$r});
  if ($flag) {my $tmp = $l; $l = $r; $r = $tmp};
  my $cmp = 0;
  foreach my $i (0..scalar(@{$l})-1)
    {$cmp = $l->[$i] <=> $r->[$i]; last if $cmp}
  return $cmp;
}

#
#  Negate a vector
#
sub neg {
  my $self = shift; $self = promote(@_) unless isVector($self);
  my @coords = ();
  foreach my $x ($self->value) {push(@coords,-$x)}
  return $self->make(@coords);
}

#
#  Get the length of a vector
#
sub abs {(shift)->norm}
sub norm {
  my $self = shift; $self = promote($self,@_) unless isVector($self);
  my $s = 0;
  foreach my $x ($self->value) {$s += $x*$x}
  return CORE::sqrt($s);
}

#
#  Produce a unit vector in the same direction as the given
#  vector (or return the zero vector if the original is the zero
#  vector).
#
sub unit {
  my $self = shift; $self = promote($self,@_) unless isVector($self);
  my $s = $self->norm; $s = 1/$s unless $s == 0;
  return $self->mult($s);
}

#
#  Check if two vectors are parallel
#
sub areParallel {
  my $sameDirection = $_[2];
  my @u = (promote($_[0]))->value;
  my @v = (promote($_[1]))->value;
  if (scalar(@u) != scalar(@v)) {return 0}
  my $epsilon = 1E-6;  # tolerance for equal to zero
  my $k = '';          # scaling factor for u = k v
  foreach $i (0..$#u) {
    if ($k ne '') {
      return 0 if (CORE::abs($v[$i] - $k*$u[$i]) >= $epsilon);
    } else {
      #
      #  if one is zero and the other isn't then not parallel
      #  otherwise use the ratio of the two as k
      #
      if (CORE::abs($u[$i]) < $epsilon) {
	return 0 if (CORE::abs($v[$i]) >= $epsilon);
      } else {
	return 0 if (CORE::abs($v[$i]) < $epsilon);
	$k = $v[$i]/$u[$i];
        return 0 if $k < 0 && $sameDirection;
      }
    }
  }
  #
  #  Note: it will return 1 if both are zero vectors.  This is a
  #  feature, since one is provided by the problem writer, and he
  #  should only supply the zero vector if he means it.  One could
  #  return ($k ne '') to return 0 if both are zero.
  #
  return 1;
}

##################################################
#
#  Produce the various output formats
#
#    ->string      gets a printable string (for output)
#    ->answer      gets a sting for the answer checkers
#                   (currently just calls string)
#    ->TeX         produces TeX commands suitable for use within \( \).
#    ->ijk         produces TeX version of vector using i,j, and k
#                  vectors (must include the vectorUtils.pl file
#                   in order to use this, or define $i, $j and $k
#                   to be the TeX values you want to use for these).
#

sub string {
  my $self = shift; my $paren = $parens{$self->type};
  my @p = ();
  foreach my $x ($self->value) {
    if (isNumber($x)) {push(@p,sprintf($numberFormat,$x))} else {push(@p,$x)}
  }
  $paren->{open}.join(',',@p).$paren->{close};  
}

sub answer {(shift)->string(@_)}

sub TeX {
  my $self = shift; my $paren = $parens{$self->type};
  my $open = $paren->{TeX_open}   || '\left'.$paren->{open};
  my $close = $paren->{TeX_close} || '\right'.$paren->{close};
  my @p = ();
  foreach my $x ($self->value) {
    if (isNumber($x)) {push(@p,sprintf($numberFormat,$x))} else {push(@p,$x)}
  }
  $open.join(',',@p).$close
}

sub ijk {
  my $self = shift; my @p = ();
  foreach my $x ($self->value) {
    if (isNumber($x)) {push(@p,sprintf($numberFormat,$x))}
    else {push(@p,'('.$x.')')}
  }
  "$p[0]$main::i + $p[1]$main::j + $p[2]$main::k";
}

##################################################

#
#  Set the number output format to the given sprintf string.
#  E.g., '%s' would give the full precision of the number.
#
#  Default:  '%.6g'
#
sub numberFormat {shift; $numberFormat = shift}

###########################################################################
########################################################################### 

1;
