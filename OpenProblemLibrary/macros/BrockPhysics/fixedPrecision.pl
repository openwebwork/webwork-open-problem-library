sub _fixedPrecision_init {}

package FixedPrecision;
our @ISA = ("Value::Real");

sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $context = (Value::isContext($_[0]) ? shift : $self->context);
  my $x = shift; my $n = shift;
  Value::Error("Too many arguments") if scalar(@_) > 0;
  if (defined($n)) {
    $x = main::prfmt($x,"%.${n}f");
  } else {
    $x =~ s/\s+//g;
    my ($int,$dec) = split(/\./,$x);
    $n = length($dec);
  }
  $self = bless $self->SUPER::new($context,$x), $class;
  $self->{decimals} = $n; $self->{isValue} = 1;
  return $self;
}

sub string {
  my $self = shift;
  main::prfmt($self->value,"%.".$self->{decimals}."f");
}

sub compare {
  my ($self,$l,$r) = Value::checkOpOrder(@_);
  $l cmp $r;
}

package FixedPrecisionNumber;
our @ISA = ("Parser::Number");

sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $equation = shift; my $context = $equation->{context};
  $self = bless $self->SUPER::new($equation,@_), $class;
  $self->{value} = FixedPrecision->new($self->{value_string});
  return $self;
}

sub string {(shift)->{value}->string(@_)}
sub TeX {(shift)->{value}->TeX(@_)}

package main;

Context()->{parser}{Number} = "FixedPrecisionNumber";

sub FixedPrecision {FixedPrecision->new(@_)};

1;
