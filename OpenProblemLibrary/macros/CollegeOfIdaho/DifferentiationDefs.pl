#
#  Extend differentiation to multiple variables
#  Check differentiation for complex functions
#  Do derivatives for norm and unit.
#  
#  Make shortcuts for getting numbers 1, 2, and sqrt, etc.
#  

##################################################
#
#  Differentiate the formula in terms of the given variable
#
sub Parser::D {
  my $self = shift; my $x = shift;
  if (!defined($x)) {
    my @vars = keys(%{$self->{variables}});
    my $n = scalar(@vars);
    if ($n == 0) {
      return $self->new('0') if $self->{isNumber};
      $x = 'x';
    } else {
      $self->Error("You must specify a variable to differentiate by") unless $n ==1;
      $x = $vars[0];
    }
  } else {
    return $self->new('0') unless defined $self->{variables}{$x};
  }
  return $self->new($self->{tree}->D($x));
}

sub Item::D {
  my $self = shift;
  my $type = ref($self); $type =~ s/.*:://;
  $self->Error("Differentiation for '$type' is not implemented",$self->{ref});
}


#########################################################################

sub Parser::BOP::comma::D {Item::D(shift)}
sub Parser::BOP::union::D {Item::D(shift)}

sub Parser::BOP::add::D {
  my $self = shift; my $x = shift;
  $self = Parser::BOP->new(
    $self->{equation},$self->{bop},
    $self->{lop}->D($x),$self->{rop}->D($x)
  );
  return $self->reduce;
}


sub Parser::BOP::subtract::D {
  my $self = shift; my $x = shift;
  $self = Parser::BOP->new(
    $self->{equation},$self->{bop},
    $self->{lop}->D($x),$self->{rop}->D($x)
  );
  return $self->reduce;
}

sub Parser::BOP::multiply::D {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  $self =
    Parser::BOP->new($equation,'+',
      Parser::BOP->new($equation,$self->{bop},
        $self->{lop}->D($x),$self->{rop}->copy($equation)),
      Parser::BOP->new($equation,$self->{bop},
        $self->{lop}->copy($equation),$self->{rop}->D($x))
    );
  return $self->reduce;
}

sub Parser::BOP::divide::D {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  $self =
    Parser::BOP->new($equation,$self->{bop},
      Parser::BOP->new($equation,'-',
        Parser::BOP->new($equation,'*',
          $self->{lop}->D($x),$self->{rop}->copy($equation)),
        Parser::BOP->new($equation,'*',
          $self->{lop}->copy($equation),$self->{rop}->D($x))
      ),
      Parser::BOP->new($equation,'^',
        $self->{rop},Parser::Number->new($equation,2)
      )
    );
  return $self->reduce;
}

sub Parser::BOP::power::D {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  my $vars = $self->{rop}->getVariables;
  if (defined($vars->{$x})) {
    $vars = $self->{lop}->getVariables;
    if (defined($vars->{$x})) {
      $self =
        Parser::Function->new($equation,'exp',
          [Parser::BOP->new($equation,'*',$self->{rop}->copy($equation),
            Parser::Function->new($equation,'log',[$self->{lop}->copy($equation)],0))]);
       return $self->D($x);
    }
    $self = Parser::BOP->new($equation,'*',
      Parser::Function->new($equation,'log',[$self->{lop}->copy($equation)],0),
      Parser::BOP->new($equation,'*',
        $self->copy($equation),$self->{rop}->D($x))
    );
  } else {
    $self =
      Parser::BOP->new($equation,'*',
        Parser::BOP->new($equation,'*',
          $self->{rop}->copy($equation),
          Parser::BOP->new($equation,$self->{bop},
            $self->{lop}->copy($equation),
            Parser::BOP->new($equation,'-',
              $self->{rop}->copy($equation),
              Parser::Number->new($equation,1)
            )
          )
        ),
        $self->{lop}->D($x)
      );
  }
  return $self->reduce;
}

sub Parser::BOP::cross::D      {Item::D(shift)}
sub Parser::BOP::dot::D        {Item::D(shift)}
sub Parser::BOP::underscore::D {Item::D(shift)}

#########################################################################

sub Parser::UOP::plus::D {
  my $self = shift; my $x = shift;
  return $self->{op}->D($x)
}

sub Parser::UOP::minus::D {
  my $self = shift; my $x = shift;
  $self = Parser::UOP->new($self->{equation},'u-',$self->{op}->D($x));
  return $self->reduce;
}

sub Parser::UOP::factorial::D  {Item::D(shift)}

#########################################################################

sub Parser::Function::D {
  my $self = shift;
  $self->Error("Differentiation of '$self->{name}' not implemented",$self->{ref});
}

sub Parser::Function::D_chain {
  my $self = shift; my $x = $self->{params}[0];
  my $name = "D_" . $self->{name};
  $self = Parser::BOP->new($self->{equation},'*',$self->$name($x->copy),$x->D(shift));
  return $self->reduce;
}

#############################

sub Parser::Function::trig::D {Parser::Function::D_chain(@_)}

sub Parser::Function::trig::D_sin {
  my $self = shift; my $x = shift;
  return Parser::Function->new($self->{equation},'cos',[$x]);
}

sub Parser::Function::trig::D_cos {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return 
    Parser::UOP->new($equation,'u-',
      Parser::Function->new($equation,'sin',[$x])
    );
}

sub Parser::Function::trig::D_tan {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return 
    Parser::BOP->new($equation,'^',
      Parser::Function->new($equation,'sec',[$x]),
      Parser::Number->new($equation,2)
    );
}

sub Parser::Function::trig::D_cot {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return 
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'^',
        Parser::Function->new($equation,'csc',[$x]),
        Parser::Number->new($equation,2)
      )
    );
}
 
sub Parser::Function::trig::D_sec {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return 
    Parser::BOP->new($equation,'*',
      Parser::Function->new($equation,'sec',[$x]),
      Parser::Function->new($equation,'tan',[$x])
    );
}

sub Parser::Function::trig::D_csc {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'*',
        Parser::Function->new($equation,'csc',[$x]),
        Parser::Function->new($equation,'cot',[$x])
      )
    );
}

sub Parser::Function::trig::D_asin {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::BOP->new($equation,'/',
      Parser::Number->new($equation,1),
      Parser::Function->new($equation,'sqrt',[
        Parser::BOP->new($equation,'-',
          Parser::Number->new($equation,1),
          Parser::BOP->new($equation,'^',
            $x,Parser::Number->new($equation,2)
          )
        )]
      )
    );
}

sub Parser::Function::trig::D_acos {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'/',
        Parser::Number->new($equation,1),
        Parser::Function->new($equation,'sqrt',[
          Parser::BOP->new($equation,'-',
            Parser::Number->new($equation,1),
            Parser::BOP->new($equation,'^',
              $x,Parser::Number->new($equation,2)
            )
          )]
        )
      )
    );
}

sub Parser::Function::trig::D_atan {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::BOP->new($equation,'/',
      Parser::Number->new($equation,1),
      Parser::BOP->new($equation,'+',
        Parser::Number->new($equation,1),
        Parser::BOP->new($equation,'^',
          $x, Parser::Number->new($equation,2)
        )
      )
    );
}

sub Parser::Function::trig::D_acot {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'/',
        Parser::Number->new($equation,1),
        Parser::BOP->new($equation,'+',
          Parser::Number->new($equation,1),
          Parser::BOP->new($equation,'^',
            $x, Parser::Number->new($equation,2)
          )
        )
      )
    );
}

sub Parser::Function::trig::D_asec {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::BOP->new($equation,'/',
      Parser::Number->new($equation,1),
      Parser::BOP->new($equation,'*',
        Parser::Function->new($equation,'abs',[$x]),
        Parser::Function->new($equation,'sqrt',[
          Parser::BOP->new($equation,'-',
            Parser::BOP->new($equation,'^',
              $x, Parser::Number->new($equation,2)
            ),
            Parser::Number->new($equation,1)
          )]
        )
      )
    );
}

sub Parser::Function::trig::D_acsc {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'/',
        Parser::Number->new($equation,1),
        Parser::BOP->new($equation,'*',
          Parser::Function->new($equation,'abs',[$x]),
          Parser::Function->new($equation,'sqrt',[
            Parser::BOP->new($equation,'-',
              Parser::BOP->new($equation,'^',
                $x, Parser::Number->new($equation,2)
              ),
              Parser::Number->new($equation,1)
            )]
          )
        )
      )
    );
}


#############################

sub Parser::Function::hyperbolic::D {Parser::Function::D_chain(@_)}

sub Parser::Function::hyperbolic::D_sinh {
  my $self = shift; my $x = shift;
  return Parser::Function->new($self->{equation},'cosh',[$x]);
}

sub Parser::Function::hyperbolic::D_cosh {
  my $self = shift; my $x = shift;
  return Parser::Function->new($self->{equation},'sinh',[$x]);
}

sub Parser::Function::hyperbolic::D_tanh {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return 
    Parser::BOP->new($equation,'^',
      Parser::Function->new($equation,'sech',[$x]),
      Parser::Number->new($equation,2)
    );
}

sub Parser::Function::hyperbolic::D_coth {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return 
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'^',
        Parser::Function->new($equation,'csch',[$x]),
        Parser::Number->new($equation,2)
      )
    );
}
 
sub Parser::Function::hyperbolic::D_sech {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return 
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'*',
        Parser::Function->new($equation,'sech',[$x]),
        Parser::Function->new($equation,'tanh',[$x])
      )
    );
}

sub Parser::Function::hyperbolic::D_csch {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'*',
        Parser::Function->new($equation,'csch',[$x]),
        Parser::Function->new($equation,'coth',[$x])
      )
    );
}

sub Parser::Function::hyperbolic::D_asinh {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::BOP->new($equation,'/',
      Parser::Number->new($equation,1),
      Parser::Function->new($equation,'sqrt',[
        Parser::BOP->new($equation,'+',
          Parser::Number->new($equation,1),
          Parser::BOP->new($equation,'^',
            $x, Parser::Number->new($equation,2)
          )
        )]
      )
    );
}

sub Parser::Function::hyperbolic::D_acosh {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::BOP->new($equation,'/',
      Parser::Number->new($equation,1),
      Parser::Function->new($equation,'sqrt',[
        Parser::BOP->new($equation,'-',
          Parser::BOP->new($equation,'^',
            $x, Parser::Number->new($equation,2)
          ),
          Parser::Number->new($equation,1)
        )]
      )
    );
}

sub Parser::Function::hyperbolic::D_atanh {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::BOP->new($equation,'/',
      Parser::Number->new($equation,1),
      Parser::BOP->new($equation,'-',
        Parser::Number->new($equation,1),
        Parser::BOP->new($equation,'^',
          $x, Parser::Number->new($equation,2)
        )
      )
    );
}

sub Parser::Function::hyperbolic::D_acoth {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::BOP->new($equation,'/',
      Parser::Number->new($equation,1),
      Parser::BOP->new($equation,'-',
        Parser::Number->new($equation,1),
        Parser::BOP->new($equation,'^',
          $x, Parser::Number->new($equation,2)
        )
      )
    );
}

sub Parser::Function::hyperbolic::D_asech {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'/',
        Parser::Number->new($equation,1),
        Parser::BOP->new($equation,'*',
          $x,
          Parser::Function->new($equation,'sqrt',[
            Parser::BOP->new($equation,'-',
              Parser::Number->new($equation,1),
              Parser::BOP->new($equation,'^',
                $x, Parser::Number->new($equation,2)
              )
            )]
          )
        )
      )
    );
}

sub Parser::Function::hyperbolic::D_acsch {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::UOP->new($equation,'u-',
      Parser::BOP->new($equation,'/',
        Parser::Number->new($equation,1),
        Parser::BOP->new($equation,'*',
          Parser::Function->new($equation,'abs',[$x]),
          Parser::Function->new($equation,'sqrt',[
            Parser::BOP->new($equation,'+',
              Parser::Number->new($equation,1),
              Parser::BOP->new($equation,'^',
                $x, Parser::Number->new($equation,2)
              )
            )]
          )
        )
      )
    );
}


#############################

sub Parser::Function::numeric::D {Parser::Function::D_chain(@_)}

sub Parser::Function::numeric::D_log {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return Parser::BOP->new($equation,'/',Parser::Number->new($equation,1),$x);
}

sub Parser::Function::numeric::D_log10 {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::BOP->new($equation,'/',
      Parser::Number->new($equation,1),
      Parser::BOP->new($equation,'*',
        Parser::Number->new($equation,CORE::log(10)), $x
      )
    );
}

sub Parser::Function::numeric::D_exp {
  my $self = shift; my $x = shift;
  return $self->copy();
}

sub Parser::Function::numeric::D_sqrt {
  my $self = shift; my $x = shift;
  my $equation = $self->{equation};
  return
    Parser::BOP->new($equation,'/',
      Parser::Number->new($equation,1),
      Parser::BOP->new($equation,'*',
        Parser::Number->new($equation,2),
        $self->copy
      )
    );
}
 
sub Parser::Function::numeric::D_abs {Parser::Function::D(@_)} 
sub Parser::Function::numeric::D_int {Parser::Function::D(@_)} 
sub Parser::Function::numeric::D_sgn {Parser::Function::D(@_)} 

#########################################################################

sub Parser::List::D {
  my $self = shift; my $x = shift;
  $self = $self->copy($self->{equation});
  foreach my $f (@{$self->{coords}}) {$f = $f->D($x)}
  return $self->reduce;
}


sub Parser::List::Interval::D {
  my $self = shift;
  $self->Error("Can't differentiate intervals",$self->{ref});
}

sub Parser::List::AbsoluteValue::D {
  my $self = shift;
  $self->Error("Can't differentiate absolute values",$self->{ref});
}


#########################################################################

sub Parser::Number::D {Parser::Number->new(shift->{equation},0)}

#########################################################################

sub Parser::Complex::D {Parser::Number->new(shift->{equation},0)}

#########################################################################

sub Parser::Constant::D {Parser::Number->new(shift->{equation},0)}

#########################################################################

sub Parser::Value::D {
  my $self = shift; my $x = shift; my $equation = $self->{equation};
  return Parser::Value->new($equation,$self->{value}->D($x,$equation));
}

sub Value::D {
  my $self = shift; my $x = shift; my $equation = shift;
  return 0 if $self->isComplex;
  my @coords = @{$self->{data}};
  foreach my $n (@coords)
    {if (ref($n) eq "") {$n = 0} else {$n = $n->D($x,$equation)->data}}
  return $self->new([@coords]);
}

sub Value::List::D {
  my $self = shift; my $x = shift; my $equation = shift;
  my @coords = @{$self->{data}};
  foreach my $n (@coords)
    {if (ref($n) eq "") {$n = 0} else {$n = $n->D($x)}}
  return $self->new([@coords]);
}

sub Value::Interval::D {
  shift; shift; my $self = shift;
  $self->Error("Can't differentiate intervals",$self->{ref});
}

sub Value::Union::D {
  shift; shift; my $self = shift;
  $self->Error("Can't differentiate unions",$self->{ref});
}

#########################################################################

sub Parser::Variable::D {
  my $self = shift; my $x = shift;
  my $d = ($self->{name} eq $x)? 1: 0;
  return Parser::Number->new($self->{equation},$d);
}

#########################################################################

sub Parser::String::D {Parser::Number->new(shift->{equation},0)}

#########################################################################

package Parser::Differentiation;
our $loaded = 1;

#########################################################################

1;
