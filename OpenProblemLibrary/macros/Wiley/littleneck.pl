#*****************************
#   Question mode variables
#*****************************
$PRACTICE_MODE = 0;
loadMacros("problemRandomize.pl");
#********************************************
#   Set up a "generate new problem" button
#********************************************
sub rand_button
{
  if ($PRACTICE_MODE == 1)
  {
    ProblemRandomize(when=>"Always",onlyAfterDue=>0,style=>"Input");
  }
  elsif ($PRACTICE_MODE == 2)
  {
    ProblemRandomize(when=>"Always",onlyAfterDue=>0,label=>"Generate New Problem");
  }
}
#**********************************************************
#   Subroutine to reduce fractions
#   Input : Num, Denom
#   Output: Num, Denom, Wholenum (if != 0, = $num/$denom)
#
#   22Jul09 - Returned Wholenum < 0 if num or denom < 0
#**********************************************************
sub reduce_fraction
{
  $n = $_[0];
  $d = $_[1];
  $wholenum = 0;
#
# **********************
#    Remove negatives
# **********************
  if ($n < 0)
  {
    $num = -$n;
  }
  else
  {
    $num = $n;
  }
  if ($d < 0)
  {
    $denom = -$d;
  }
  else
  {
    $denom = $d;
  }
# ******************************
#    Check for a whole number  
# ******************************   
  if ($num/$denom == int($num/$denom))
  {
    $wholenum = $n/$d;
  }
# ***************
#   Find gcf   
# ***************
  else
  {
    if ($num > $denom)
    {
      $gcf = $denom;
    }
    else
    {
      $gcf = $num;
    }
    $found = 0;
    while ( ($found == 0) && ($gcf > 1) )
    {
      if ( ($num/$gcf == int($num/$gcf)) && ($denom/$gcf == int($denom/$gcf)) )
      {
        $found = 1;
      }
      else
      {
        $gcf--;
      }
    }
#   ********************************
#      If a GCF was found, reduce
#   ********************************
    if ($found == 1)
    {
      $num = $num/$gcf;
      $denom = $denom/$gcf;
    }
  }
# ***********************
#    Restore negatives
# ***********************
  if ($n < 0)
  {
    $num = -1*$num;
  }
  if ($d < 0)
  {
    $denom = -1*$denom;
  }
  return($num, $denom, $wholenum);
}
#
#**********************************************************
#   Subroutine to produce reduced display fraction 
#   Input : Num($n), Denom($d)
#   Output: Num($n), Denom($d), Wholenum($w),Display($display)
#  calls reduce_fraction to get, 
#   Output: Num($n), Denom($d), Wholenum($w),
#(if Wholenum > 0,$display = $w
#  else $Display=\(\frac{$n}{$d}\)
#**********************************************************
sub display_fraction_long
{  $n = $_[0];
  $d = $_[1];
  $w=0;
  $display=0;
#call reduce_fraction
($n,$d,$w)=reduce_fraction($n,$d,$w);
#Decide on display format
if ($w>0){ 
         $display=$wholenumber;
         }
else{
     $display="\\frac{$num}{$denom}";
    }
return($n, $d, $w,$display);
}
#
#
#
#
#**********************************************************
#   Subroutine to produce reduced display fraction 
#   Input : Num($n), Denom($d)
#   Output: Display($display)
#  calls reduce_fraction to get, 
#   Output: Num($n), Denom($d), Wholenum($w),
#(if Wholenum > 0,$display = $w
#  else $Display=\(\frac{$n}{$d}\)
#**********************************************************
sub display_fraction
{  $n = $_[0];
  $d = $_[1];
  $w=0;
  $display=0;
#call reduce_fraction
($n,$d,$w)=reduce_fraction($n,$d,$w);
#Decide on display format
if ($w>0){ 
          $display=$wholenumber;
          }
   else{
        $display="\\frac{$num}{$denom}";
       }
return($display);
}
#*******************************************************************************
#   sqrt_simplify(Num,Natnum,Radnum,Texstr,Error)
#
#   Description: Given a natural number, will find the greatest perfect square
#                that is a factor and use this to simplify the expression:
#                sqrt(number).
#   Input :
#     Num = Number whose sqrt is being taken
#
#   Output:
#     Natnum => Natural number portion of solution (= 1 if no perfect square
#               divides evenly)
#     Radnum => The value still inside the radical
#     Texstr => A LaTex string of the form "Natnum \sqrt{$Radnum}" to be used
#               for displaying the solution.
#     Error  => If == 1, then the number entered was bad (ie, negative, nonint)
#               (If necessary, this code can be made specific for the error)
#*******************************************************************************
sub sqrt_simplify
{
  $number = $_[0];
  ($Natnum,$Radnum) = (1,1);
  $Error = 0;

  #***********************************
  #   Check the number for validity
  #***********************************
  if ( ($number == int($number)) && ($number > 0) )
  {
    $perfsqr = 1;
    #*************************************************************************************
    #   Check all perfect squares up to the max and store the hightest one that divides
    #*************************************************************************************
    for ($i = 2; $i*$i <= $number; $i++)
    {
      $sqr = $i*$i;
      if ( int($number/$sqr) == $number/$sqr )
      {
        $perfsqr = $i;
      }
    }
    $Natnum = $perfsqr;
    $Radnum = $number/($Natnum*$Natnum);
    #************************************************************
    #   If radnum = 1, the original number is a perfect square
    #   If natnum = 1, it cannot be simplified
    #************************************************************
    if ($Radnum == 1)
    {
      $Texstr = "$Natnum";
    }
    elsif ($Natnum == 1)
    {
      $Texstr = "\\sqrt{$number}";
    }
    else
    {
      $Texstr = "$Natnum \\sqrt{$Radnum}";
    }
  }
  else
  {
    ($Natnum,$Radnum,$Error) = 1;
    $Texstr = "1";
  }  
  return($Num,$Natnum,$Radnum,$Texstr,$Error);
}
