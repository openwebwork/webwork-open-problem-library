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
                "select jsMath mode in the Display Options panel at the left".$HR,
));
}

sub jsmathmode
{
TEXT(MODES(
    TeX => '',
    HTML_jsMath => '',
    HTML => $HR."Warning: to use this problem, you need to ".
                "select jsMath mode in the Display Options panel at the left".$HR,
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
                "select MathJax mode in the Display Options panel at the left".$HR,
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

### To use the macros your problem must include unionTables.pl, and of course Alfredmacros.pl
### Table integral returns a string that can be included in a Table to output an integral whose upper and lower limits
### of integration can be answer blanks. There are several optional parameters:
### width  - change the width of the answer blanks. defaults to 3.
### lowerwidth  - change the width of the lower answer blank. defaults to width
### upperwidth  - change the width of the upper answer blank. defaults to width.
### upper - the uppper limit of integration, does not have to be an answer blank, defaults to answer blank with width "width"
### lower - the lower limit of integration, does not have to be an answer blank,  defaults to answer blank with width "width"
### limits - boolean, if 1 puts the limits of integration above and below the integral symbol, if 0 puts them after the integral symbol.
###          default is 1.
### Your code must include unionTables.pl, and of course Alfredmacros.pl
### An example:
###   \{BeginTable(center=>0).
###      Row([tableintegral(),
###      ],separation=>2).
###     EndTable();
###   \}
### which will print an integral with answer blank on the upper and lower limits with the default length of 3
###
### This example prints out a double integral, the first integral with answer blanks with width 10, the second integral
### has 0 for the lower limit of integration and an answer blank with width 5 for the upper limit of integration.
### The default limits of integratin are answer blanks with width 3, in this case the default width was overridden to 5
### and the default lower limit was changed to a zero.
###   \{BeginTable(center=>0).
###      Row([tableintegral(width=>10,limits=>'\(0\)'),tableintegral(width=>5,lower=>'\(0\)',limits=>0),
###      ],separation=>2).
###     EndTable();
###   \}
###  An example where the width of the upper and lower answer blanks have different widths.
###   \{BeginTable(center=>0).
###      Row([tableintegral(lowerwidth=>10,upperwidth=>1)
###      ],separation=>2).
###     EndTable();
###   \}

sub tableintegral{
 my %arg = @_;
 my $width = delete $arg{width} //  3;
 my $lowerwidth = delete $arg{lowerwidth} //  $width;
 my $upperwidth = delete $arg{upperwidth} //  $width;
 my $lower = delete $arg{lower} //  ans_rule($lowerwidth);
 my $upper = delete $arg{upper} //  ans_rule($upperwidth);
 my $limits = delete $arg{limits} // 1;
 if ($limits == 1){
    return $upper.$BR.'\(\displaystyle\int\)'.$BR.$lower
 }
 else {
     return '\(\displaystyle\int\)',$upper.$BR.$BR.$lower
 }
};

# a sum with answer blanks for the summation variable, lower limit, and upper limit
#\{ BeginTable(center=>0).
#     Row([tablesum(width=>10),
#     ],separation=>2).
#   EndTable();
#\}
# a sum with answer blanks for the upper and lower limits, and the summation variable is i
#\{ BeginTable(center=>0).
#     Row([tablesum(width=>10,sumvariable=>'i'),
#     ],separation=>2).
#   EndTable();
#\}
# a sum with answer blanks for the upper and lower limits, and summation variable is not used.
#\{ BeginTable(center=>0).
#     Row([tablesum(width=>10,usesumvariable=>0),
#     ],separation=>2).
#   EndTable();
#\}
# sum from n = 1 to infinity
#\{ BeginTable(center=>0).
#      Row([tablesum(sumvariable=>'\(n\)',lower=>'\(1\)', upper=>'\(\hskip 3pt\infty\)') ],separation=>2).
#   EndTable();
#\}

sub tablesum{
 my %arg = @_;
 my $width = delete $arg{width} //  3;
 my $lowerwidth = delete $arg{lowerwidth} //  $width;
 my $upperwidth = delete $arg{upperwidth} //  $width;
 my $lower = delete $arg{lower} //  ans_rule($lowerwidth);
 my $upper = delete $arg{upper} //  ans_rule($upperwidth);
 my $limits = delete $arg{limits} // 1;
 my $sumvariable = delete $arg{sumvariable} // ans_rule($width);
 my $usesumvariable = delete $arg{usesumvariable} // 1;
 if ($usesumvariable == 0){ 
     if ($limits == 1){
        return $upper.$BR.'\(\displaystyle\sum\)'.$BR.$lower
     }
     else {
        return '\(\displaystyle\int\)',$upper.$BR.$BR.$lower
     }
 }
 else {
     if ($limits == 1){
        return $upper.$BR.'\(\displaystyle\sum\)'.$BR.$sumvariable.'\( = \)'.$lower
     }
     else {
        return '\(\displaystyle\int\)',$upper.$BR.$BR.$sumvariable.'\( = \)'.$lower
     }
 }
};


### Create a vertical bar with an upper and lower limit.
sub tableevaluate{
 my %arg = @_;
 my $width = delete $arg{width} //  3;
 my $lowerwidth = delete $arg{lowerwidth} //  $width;
 my $upperwidth = delete $arg{upperwidth} //  $width;
 my $lower = delete $arg{lower} //  ans_rule($lowerwidth);
 my $upper = delete $arg{upper} //  ans_rule($upperwidth);
 return
   '\(\Bigg\vert\)',$upper.$BR.$BR.$lower
};

### Create a subscripted character
sub tablesubscript{
 my %arg = @_;
 my $width = delete $arg{width} //  3;
 my $lower = delete $arg{lower} //  ans_rule($width);
 my $variable = delete $arg{variable} //  'c';
 return
   $variable,$BR.$BR.$lower
};

### Create a superscripted character
sub tablesuperscript{
 my %arg = @_;
 my $width = delete $arg{width} //  3;
 my $upper = delete $arg{upper} //  ans_rule($width);
 my $variable = delete $arg{variable} //  'c';
 return
   $variable,$upper.$BR.$BR.$BR
};



### A fraction
sub tablefrac{
 my %arg = @_;
 my $width = delete $arg{width} //  3;
 my $lower = delete $arg{lower} //  ans_rule($width);
 my $upper = delete $arg{upper} //  ans_rule($width);
 my $barwidth = delete $arg{barwidth} //  10+$width;
 my $divisionbar = "";
 for ($count = 1;$count <= $barwidth; $count++){
     $divisionbar = $divisionbar."-";
     }
 return $upper.$BR.$divisionbar.$BR.$lower
};

