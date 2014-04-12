# A group of macros used in the Alfred problem library.

sub _Alfredmacros_init {} #don't reload these macros.


# Given a point (x,y) this macro computes the angle with respect to x-axis. The angle will be between 0 and 2pi.
sub inversetrig
{my $refangle = arctan(abs($_[1]/$_[0]));
 if($_[0] == 0)
 {0}
 elsif ($_[0]>0)
 {if($_[1] == 0)
  {0}
  elsif($_[1]>0)
  {$refangle;}
  else
  {2*pi-$refangle;}
 }
 else
 {if($_[1] == 0)
  {pi}
  elsif($_[1]>0)
  {pi-$refangle;}
  else
  {pi+$refangle}
 }
}

## Compute the max and min of an array of numbers
sub max {
my $maximum = shift @_;
foreach(@_){
   if ($maximum < $_){$maximum = $_};
};
return $maximum;
} 
sub min {
my $minimum = shift @_;
foreach(@_){
   if ($minimum > $_){$minimum =  $_};
};
return $minimum;
} 



#This macro prevents students from double clicking in an answer box. This macro #is necessary for multiple integral problems where the answer box is typeset
#into the integration symbols. 
sub doubleclickprevent
{TEXT(MODES(
        TeX => "",
        HTML => "<SCRIPT>if (window.jsMath) {jsMath.Click.DblClick = function () {}}</SCRIPT>"
    ));
} 

#The problems that have the answer box in the limits must be displayed in JS
#math mode. This macro warns the user to use JS math mode if they are not.
sub jsMathwarn
{TEXT(MODES(
    TeX => '',
    HTML_jsMath => '',
    HTML => $HR."Warning: to use this problem, you need to".
                "select jsMath mode in the options panel at the left".$HR,
));
}

sub jsmathmode
{
TEXT(MODES(
    TeX => '',
    HTML_jsMath => '',
    HTML => $HR."Warning: to use this problem, you need to ".
                "select jsMath mode in the options panel at the left".$HR,
));
TEXT(MODES(
        TeX => "",
        HTML => "<SCRIPT>if (window.jsMath) {jsMath.Click.DblClick = function () {}}</SCRIPT>"
    ));

}

sub mathjaxmode
{TEXT(MODES(
    TeX => '',
    HTML_MathJax => '',
    HTML => $HR."Warning: to use this problem, you need to ".
                "select MathJax mode in the options panel at the left".$HR,
));
}

#This subroutine includes the Strang's textbook into a problem, you have to
#feed it the chapter and section. It is assumed that the book is in the course
#directory and is labeled strangtextbook. The parameters are
#strang(chapter,section,(optional) section title.
#example \{&strang(16,5,"surface integrals")\}.
$wwstrang = "http://webwork.alfred.edu/webwork2_course_files/strangcalculus";
sub strang
{
htmlLink(qq!$wwstrang/Strang-$_[0]-$_[1].pdf!,"$_[0].$_[1] $_[2] from Gilbert Strang's Calculus",q/TARGET="new_window"/)
}

#Inserts a link to a trig table in the problem.
#example \{&trig_table()\}
sub trig_table
{
htmlLink(qq!$wwstrang/trig_identities.pdf!,"Trig Identities",q/TARGET="new_window"/)
}

sub strang_index
{
htmlLink(qq!$wwstrang/Index.pdf!,"Index",q/TARGET="new_window"/)
}  

sub strang_TOC
{
htmlLink(qq!$wwstrang/TOC.pdf!,"Table of Contents",q/TARGET="new_window"/)
}

sub product_Rule_cmp {
my ( $correct, $student, $self ) = @_;
      my ( $f1stu, $f2stu,$f3stu,$f4stu ) = @{$student};
      my ( $f1, $f2, $f3, $f4 ) = @{$correct};
      my @fgrade = (0,0,0,0); 
      my @fstu = ($f1stu,$f2stu,$f3stu,$f4stu);
      my @fcorrect = ($f1,$f2,$f3,$f4);
      #we will associate each student answer with a prime number, noting which student answer is in which blank. This allows us to make use of the fundamental theorem of arithmetic.
      my @prime = (2,3,5,7);
      my @answerblank = (0,0,0,0);

      for($i=0;$i<4;$i++){
         for($j=0;$j<4;$j++){
            if(($fcorrect[$i]==$fstu[$j])&&($answerblank[$j]==0)){
              {$answerblank[$j] = $prime[$i];
               $j = 4 # you have to terminate the inner loop in this case for the special case of f=e^x where f and f' are the same.
              }
            }
         }
      };
      for($i=0;$i<4;$i++){
         if(!$answerblank[$i]){
           $self->setMessage($i+1,"All of your answers should be $f, $g, or a derivative of one of these functions");
         }
      }
#now we rely on the fact that products of primes are unique. First we check to see if all of the blanks are correct
      if ((($answerblank[0]*$answerblank[1] == 6)&&($answerblank[2]*$answerblank[3] == 35))||(($answerblank[0]*$answerblank[1] == 35)&&($answerblank[2]*$answerblank[3] == 6))){
         @fgrade = (1,1,1,1);         
      }
#now check to see if the first pair of blanks is correct, knowing one pair is not
     elsif ($answerblank[0]*$answerblank[1] == 6){
           if (($answerblank[2] == 5)||($answerblank[2] == 7)){
              @fgrade = (1,1,1,0);
           }
           elsif (($answerblank[3] == 5)||($answerblank[3] == 7)){
              @fgrade = (1,1,0,1);
           }
           else {@fgrade = (1,1,0,0);}
     }
     elsif ($answerblank[0]*$answerblank[1] == 35){
           if (($answerblank[2] == 2)||($answerblank[2] == 3)){
              @fgrade = (1,1,1,0);
           }
           elsif (($answerblank[3] == 2)||($answerblank[3] == 3)){
              @fgrade = (1,1,0,1);
           }
           else {@fgrade = (1,1,0,0);}
     }
#if both sets are not correct, and the first set is not correct, check to see if the last pair are
     elsif ($answerblank[2]*$answerblank[3] == 6){
           if (($answerblank[0] == 5)||($answerblank[0] == 7)){
              @fgrade = (1,0,1,1);
           }
           elsif (($answerblank[1] == 5)||($answerblank[1] == 7)){
              @fgrade = (0,1,1,1);
           }
           else {@fgrade = (0,0,1,1);}
     }
     elsif ($answerblank[2]*$answerblank[3] == 35){
           if (($answerblank[0] == 2)||($answerblank[0] == 3)){
              @fgrade = (1,0,1,1);
           }
           elsif (($answerblank[1] == 2)||($answerblank[1] == 3)){
              @fgrade = (0,1,1,1);
           }
           else {@fgrade = (0,0,1,1);}
     }
#at this point they don't have a matched set of blanks correct. look for a single function in each pair that is right. You have to make sure you only get one for each pair of answer blanks.
    else{
         if (($answerblank[0])&&($answerblank[2])&&($answerblank[0]*$answerblank[2] !=6)&&($answerblank[0]*$answerblank[2] !=35)&&($answerblank[0]!=$answerblank[2])){
            @fgrade = (1,0,1,0);
            }
         elsif (($answerblank[0])&&($answerblank[3])&&($answerblank[0]*$answerblank[3] !=6)&&($answerblank[0]*$answerblank[3] !=35)&&($answerblank[0]!=$answerblank[3])){
            @fgrade = (1,0,0,1);
            }
         elsif (($answerblank[1])&&($answerblank[2])&&($answerblank[1]*$answerblank[2] !=6)&&($answerblank[1]*$answerblank[2] !=35)&&($answerblank[1]!=$answerblank[2])){
            @fgrade = (0,1,1,0);
            }
         elsif (($answerblank[1])&&($answerblank[3])&&($answerblank[1]*$answerblank[3] !=6)&&($answerblank[1]*$answerblank[3] !=35)&&($answerblank[1]!=$answerblank[3])){
            @fgrade = (0,1,0,1);
            }
         elsif ($answerblank[0]){@fgrade = (1,0,0,0)}  
         elsif ($answerblank[1]){@fgrade = (0,1,0,0)}
         elsif ($answerblank[2]){@fgrade = (0,0,1,0)}  
         elsif ($answerblank[3]){@fgrade = (0,0,0,1)}     
        };   
     return [@fgrade];         
}



sub check_boundary_conditions {
my ( $correct, $student, $self ) = @_;
      return product_Rule_cmp(@_) ;
  }

sub Snxy(){
 my %args = @_;
 my @x = @{$args{inputs}};
 my @y = @{$args{outputs}};
 my $m = $args{m};
 my $n = $args{n};
 my $i = 0;
 my $sum = 0;
 if ($#x == $#y){
    for ($i=0;$i <= $#x;$i++){
    $sum = $sum + ($x[$i])**($n)*($y[$i])**($m);
    }
 }
 else {$sum = 0}; 
 return $sum;
}
