# interpMacros.pl
# Rename this file (with .pl extension) and place it in your course macros directory, 

sub interpVals {
     $arrayLength = ($#_ )/2;
     @A_ARRAY = @_[0..($arrayLength-1)];
     @B_ARRAY = @_[$arrayLength .. ($#_-1)];
     $A_VAL = @_[$#_];
     $arrayLength2 = $#A_ARRAY;
     

     for ($i = 1; $i < ($#A_ARRAY+1); $i++) {
       if($A_VAL == $A_ARRAY[$i-1]) {
            $B_VAL = $B_ARRAY[$i-1];
            last;
       } elsif ($A_ARRAY[$i-1] < $A_VAL && $A_VAL < $A_ARRAY[$i]) {
            $AL = $A_ARRAY[$i-1];
            $AR = $A_ARRAY[$i];
            $BL = $B_ARRAY[$i-1];
            $BR = $B_ARRAY[$i];
            $B_VAL = (($A_VAL-$AL)/($AR - $AL)*($BR-$BL))+$BL;
            last;
       } elsif($A_VAL == $A_ARRAY[$i]) {
            $B_VAL = $B_ARRAY[$i];
            last;
       } else {
            $B_VAL = $B_ARRAY[0];
       }
    }

    return $B_VAL;
}

1; #required at end of file - a perl thing
