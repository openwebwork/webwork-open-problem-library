######################################################################
#Description:  macro to load parserAssignment and change the error 
#              message to be more specific for a function.  Requires 
#              answers be submitted in the form: 
#              y=formula or f(x)=formula
######################################################################
loadMacros("parserAssignment.pl");

        sub parser::Assignment::Formula::cmp_equal {
          my $self = shift; my $ans = shift;
          Value::cmp_equal($self,$ans);
          if ($ans->{ans_message} =~ m/Your answer isn't.*it looks like/s) {
            $ans->{ans_message} =
               "Warning: Your answer should be of the form: '".$self->{tree}{lop}->string."= formula'";
          }
        }

######################################################################

1;
