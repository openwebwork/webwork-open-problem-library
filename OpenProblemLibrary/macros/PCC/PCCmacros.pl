=head1 NAME

PCCmacros.pl - A collection of tools found to be useful during the development of the PCC problem library.

=head1 DESCRIPTION

This file implements subroutines developed for use in problems originally developed for a PCC problem library

To use it, load the macro file:

	loadMacros(
	  "PGstandard.pl",
	  "MathObjects.pl",
	  "PCCmacros.pl",
	);


=cut

###############################
#Name: perlround
#Input: a number to round, then a place to round to. e.g. 2=>hundredths, 0=>whole, -1=>tens
#Output: $x rounded to the $n place. This attempts to overcome quirks with rounding when the cut part is like 0.005
################################
sub perlround {
  # number to round
  my $x = shift;
  # place to round. e.g. 2=>hundredths, 0=>whole, -1=>tens
  my $n = shift;
  # "fix" non-integer input
  $n = int($n);
  # corresponding integer to round up or down
  my $X = $x*10**$n;
  $X = ($X-sprintf("%.0f", $X) eq 0.5) ? int($X+1) : sprintf("%.0f", $X);
  return $X/10**$n;
}


###############################
#Name: RandomName
#Input: None required
#Optional Input: 'sex' => male or female
#Output: A name that is randomly chosen from the list maintained here. 
#   If 'sex' is specified, the name is from the list of that sex.
################################
sub RandomName{
my %options = @_;

my($sex, $name, @femlist, @malelist);

$sex = $options{'sex'} if defined ($options{'sex'});

$sex = 'both' unless defined($sex);

@femlist = ('Adrian',
            'Alisa',
            'Alyson',
            'Amber',
            'Annaly',
            'Ashley',
            'Barbara',
            'Bobbi',
            'Briana',
            'Candi',
            'Carly',
            'Carmen',
            'Casandra',
            'Charity',
            'Charlotte',
            'Cheryl',
            'Dawn',
            'Diane',
            'dMarie',
            'Donna',
            'Eileen',
            'Elishua',
            'Emily',
            'Fabrienne',
            'Hannah',
            'Haley',
            'Heather',
            'Holli',
            'Irene',
            'Izabelle',
            'Janieve',
            'Jenny',
            'Jessica',
            'Julie',
            'Kara',
            'Kayla',
            'Kandace',
            'Katherine',
            'Kim',
            'Kristen',
            'Kylie',
            'Laney',
            'Laurie',
            'Lesley',
            'Lily',
            'Lindsay',
            'Lisa',
            'Maria',
            'Martha',
            'Maygen',
            'Morah',
            'Michele',
            'Nenia',
            'Nina',
            'Olivia',
            'Page',
            'Penelope',
            'Perlia',
            'Priscilla',
            'Rebecca',
            'Renee',
            'Rita',
            'Ronda',
            'Samantha',
            'Sarah',
            'Selena',
            'Sharell',
            'Sharnell',
            'Sherial',
            'Stephanie',
            'Subin',
            'Sydney',
            'Tammy',
            'Teresa',
            'Tiffany',
            'Tracei',
            'Virginia',
            'Wendy');

@malelist = ('Aaron',
             'Aleric',
             'Alejandro',
             'Andrew',
             'Anthony',
             'Benjamin',
             'Blake',
             'Brandon',
             'Brent',
             'Carl',
             'Chris',
             'Cody',
             'Connor',
             'Corey',
             'Daniel',
             'Dave',
             'Dennis',
             'Derick',
             'Devon',
             'Douglas',
             'Emiliano',
             'Eric',
             'Evan',
             'Farshad',
             'Gosheven',
             'Grant',
             'Gregory',
             'Gustav',
             'Hayden',
             'Henry',
             'Huynh',
             'Ivan',
             'James',
             'Jay',
             'Jeff',
             'Jerry',
             'Jon',
             'Joseph',
             'Joshua',
             'Ken',
             'Kenji',
             'Kimball',
             'Kurt',
             'Marc',
             'Matthew',
             'Michael',
             'Nathan',
             'Neil',
             'Nicholas',
             'Parnell',
             'Peter',
             'Phil',
             'Randi',
             'Ravi',
             'Ross',
             'Ryan',
             'Scot',
             'Sean',
             'Sebastian',
             'Shane',
             'Stephen',
             'Thanh',
             'Tien',
             'Timothy',
             'Wenwu',
             'Will');

if ($sex eq 'both')
 {$name = list_random(@femlist,@malelist);}
elsif ($sex eq 'female')
 {$name = list_random(@femlist);}
elsif ($sex eq 'male')
 {$name = list_random(@malelist);}

$name;
}

###############################
#
# Name: RandomVariableName
#
# Input: None required
#
# Optional Input: 'type' => variable, constant, integer, or function
#
# Output: A variable name like x, y, t, c, etc. that is randomly chosen from the list maintained here. 
#         If 'type' is specified, the name is from the list of that type.
#
# Sample use: 
################################
sub RandomVariableName{
my %options = @_;

my($type, $name, @varlist, @constlist, @intlist, @functionlist);

$type = $options{'type'} if defined ($options{'type'});

$type = 'all' unless defined($type);

@varlist = ('x',
            'y',
           # 'z',
            'r',
           # 's',
            't',);

@constlist = ('a',
             'b',
             'c',
             'A',
             'B',
             'C',);

@intlist = (         #'i', potential for context confusion with complex
                     #'j', and vector
                     #'k',
            'm',
            'n',
            'p',
            'q',);

@functionlist = ('f',
               'g', 
               'h',
                       #'k',
               'F',
               'G',
               'H',
               'K',);

if ($type eq 'all')
 {$name = list_random(@varlist,@constlist,@intlist);}
elsif ($type eq 'variable')
 {$name = list_random(@varlist);}
elsif ($type eq 'constant')
 {$name = list_random(@constlist);}
elsif ($type eq 'integer')
 {$name = list_random(@intlist);}
elsif ($type eq 'function')
 {$name = list_random(@functionlist);}

$name;
}

###############################
#
# Name: xPower
#
# This is just an auxiliary subroutine for the polynomial macros that follow
#      
################################


sub xPower{
    my ($power,$maxpower,$order) = @_;
    if ($order eq 'ascending') {return $power;}
    else {return ($maxpower-$power);};
}



###############################
#
# Name: PolyString
#
# Input: an arrays
#
#  PolyString(~~@poly1)
#
# Arrays elements should be numerical or Math Objects. The idea is that 
# these are coefficients of a polynomial, either starting from the
# constant term or from the leading term.
#  
# Optional Input: order=>ascending or descending, defaults to descending
#   order is ignored if output=>array
# Optional Input: var=> some string, defaulting to "x"
#
# Output: an polynomial string using var and ready to be fed to Compute 
#
#         For example, given 
#
#             @poly1 = (1,2);  # represents x+2
#             @poly2 = (3,-1,0,4); 
#
#         PolyString(~~@poly1);
#
#             'x^1+2x^0'
#
#         PolyString(~~@poly2,order=>ascending,var=>'z');
#
#             '3x^0+-1x^1+0x^2+4x^3'
#
#         Note that instance of +-, x^0, x^1, 0x^n, may be present, 
#         but Math Objectification will handle that.
#
# Note: If you intend to feed the output string to Compute() or Formula(),
#  you should set the context reductions appropriately and apply ->reduce
#  *twice* to remove excess parentheses from negative coefficients.
#      
################################

sub PolyString{

my  ($xref,%options) = @_;
my  @local_x = @{$xref};

my ($order, $var, $exponentVar, $string);

if (defined ($options{'order'})) {
    $order = $options{'order'};
    }
    else {$order = 'descending'};

if (defined ($options{'var'})) {
    $var = $options{'var'};
    }
    else {$var = 'x'};

# new, cmh 6/18/13
if (defined ($options{'exponentVar'})) {
    $exponentVar = $options{'exponentVar'};
    }
    else {$exponentVar = ''};

# original 6/18/13
#   $string = "$local_x[0]".$var.'^'.xPower(0,$#local_x,$order);
#   for my $i (1..$#local_x) {
#     $string = $string.'+'."$local_x[$i]".$var.'^'.xPower($i,$#local_x,$order);
#   }

# modified, cmh 6/18/13
$string = "$local_x[0]".$var.'^{'.xPower(0,$#local_x,$order).$exponentVar.'}';
   for my $i (1..$#local_x) {
     $string = $string.'+'."$local_x[$i]".$var.'^{'.xPower($i,$#local_x,$order).$exponentVar.'}';
   }
return $string;
}  

###############################
#
# Name: PolyMult
#
# Input: two arrays, for example
#
#  PolyMult(~~@poly1, ~~@poly2)
#
# Arrays elements should be numerical or Math Objects 
# where multiplication and addition are allowed. The idea is that 
# these are coefficients of a polynomial, either starting from the
# constant term or from the leading term.
#  
# Optional Input: order=>ascending or descending, defaults to descending
#   order is ignored if output=>array
# Optional Input: var=> some string, defaulting to "x"
# Optional Input: output=>array, simplified, unsimplified
#   which is either an array of coefficients, an expanded and simplified
#   polynomial string using var and ready to be fed to Compute, or the same
#   but unsimplified. Default is array.
# cmh, 6/18/13
# Optional Input: exponentVar=> some string, defaulting to ''
#   to be used if the polynomial looks like, for example
#            x^{3n}+x^{2n}+x^{n}
#
# Output: described in Optional Input 
#
#         For example, given 
#
#             @poly1 = (1,2);  # represents x+2
#             @poly2 = (3,-1,4);  # represents 3x^2-x+4
#
#         PolyMult(~~@poly1, ~~@poly2, 
#             order=>ascending, var=>'z', output=>unsimplified)
#
#             '3z^3+-1z^2+4z+6z^2+-2z^1+8z^0'
#
#         Note that instance of +- may be present, but Math Objectification
#         will handle that.
#
#         
#         Given 
#
#           @poly1 = (Fraction(1,3),2);  # represents 1/3x+2
#           @poly2 = (Fraction(1,2),Fraction(-1,3));  # represents 1/2x-1/3
#
#         PolyMult(~~@poly1, ~~@poly2)
#
#             (Frac(1,6),Frac(8,9),Frac(-1,9))
#
#
# Note: If you intend to feed the output string to Compute() or Formula(),
#  you should set the context reductions appropriately and apply ->reduce
#  *twice* to remove excess parentheses from negative coefficients.
#      
################################

sub PolyMult{
my  ($xref,$yref,%options) = @_;
my  @local_x = @{$xref};
my  @local_y = @{$yref};

my ($order, $var, $output, @productArray, $productString);

$order = $options{'order'} if defined ($options{'order'});
$order = 'descending' unless defined ($options{'order'});

$var = $options{'var'} if defined ($options{'var'});
$var = 'x' unless defined ($options{'var'});

$output = $options{'output'} if defined ($options{'output'});
$output = 'array' unless defined ($options{'output'});

# cmh, 6/18/13
$exponentVar= $options{'exponentVar'} if defined ($options{'exponentVar'});
$exponentVar = '' unless defined ($options{'exponentVar'});

if ($output eq 'array' or $output eq 'simplified'){
  for my $i (0..($#local_x+$#local_y)) {
   $productArray[$i]= 0;
   foreach my $j (0..$i) {
   if ($j <= $#local_x and $i-$j <= $#local_y)
   {$productArray[$i] = $productArray[$i]+$local_x[$j]*$local_y[$i-$j];}
   }
  }

  if ($output eq 'array') {return @productArray;}

  if ($output eq 'simplified') {
   return PolyString(\@productArray,order=>$order,var=>$var,exponentVar=>$exponentVar); #cmh, 6/18/13
  }  
}

if ($output eq 'unsimplified') {
   $productString = '';
   for my $i (0..$#local_x) {
     for my $j (0..$#local_y) {
#     $productString = $productString.'+'.$local_x[$i]*$local_y[$j].$var.'^'.xPower($i+$j,$#local_x+$#local_y,$order);
# cmh, 6/18/13
     $productString = $productString.'+'.$local_x[$i]*$local_y[$j].$var.'^{'.xPower($i+$j,$#local_x+$#local_y,$order).$exponentVar.'}';
     }
   }
   return $productString;
}  
}

#
# Accepts an array of the form that PolyTerms outputs
# Inserts '&' between array entries for use in array environments
# Converts Math Object entries to their TeX form
# Inserts a spacing command after nonempty entries - the command
#   \setlength\arraycolsep{0em} should precede the \begin{array}
# $Spacing should be something like "\hspace{0.4em}"
# Also creates an alignment string for the \begin{array} command
# $align should be "r", "c", or "l"
# Not part of PGpolynomialMacros.pl
# 

sub PolyTermsTeXPrep{
        my ($temp, $spacing, $align) = @_;
        my @terms = @{$temp};
        my @void = ();
        $alignment = "$align";
        foreach my $i (0..$#terms-1) {
              @void = splice(@terms,2*$i+1,0,('&'));              
              if ($terms[2*$i] ne '')
              {if (($terms[2*$i] ne '-') && ($terms[2*$i] ne '+')) {$terms[2*$i] = Compute($terms[2*$i])->TeX}
                  else {$terms[2*$i] = '{}'.$terms[2*$i].'{}';};
               $terms[2*$i] = $terms[2*$i].$spacing;};
              $alignment = $alignment."$align";
        };
        $terms[$#terms] = Compute($terms[$#terms])->TeX;
        $terms[$#terms] = $terms[$#terms].$spacing;
        return (@terms,$alignment);

}

# PolyTerms(~~@coefficientArray,x,order)

#
# Accepts an array containing the coefficients of a polynomial
#   in descending order
# Assumes coefficients have numerical values, but may be Math Objects
# Returns an array of size 2n-1 of the form
#   (a_nx^n,  +/-,  |a_{n-1}| x^{n-1},  +/-,  ...) 
#   where the variable is x is the second argument, the terms are Math Objects
#   Formulas, and the +/- are Perl strings.
# The third argument can be "ascending" to reverse the order
# If a_j is 0, then the corresponding term and preceding sign are empty
#   strings.
# Trims beginning and ending, so that first and last terms are nonzero
# Not part of PGpolynomialMacros.pl
#

#=cut


sub PolyTerms{
	my ($temp, $v, $order) = @_;
	my @poly = @{$temp};
        while (($poly[0] == 0) && ($#poly != 0)) {shift(@poly);};
        my $degree = $#poly;

        while (($poly[$#poly] == 0) && ($#poly != 0)) {pop(@poly);};
        my $lowestdegree = $degree - $#poly;

        if ($order eq "ascending") {@poly = reverse(@poly);};

	my @terms = ();
        my @abspoly = (); 
	foreach my $i (0..$#poly) {
                $abspoly[$i] = abs($poly[$i]);
		my $j = $#poly-$i+$lowestdegree;
                if ($order eq "ascending") {$j = $i+$lowestdegree;};
		if ($i == 0) {	if ($abspoly[$i] != 1){
                                        if ($j == 0)
                                          {$terms[2*$i] = Compute("$poly[$i]")->reduce;}
                                        elsif ($j == 1)
                                          {$terms[2*$i] = Compute("$poly[$i] $v")->reduce;}
                                        else
                                          {$terms[2*$i] = Compute("$poly[$i] $v^{$j}")->reduce;};
                                }
				elsif ($poly[$i] == 1){
                                        if ($j == 0)
                                          {$terms[2*$i] = Compute("1")->reduce;}
                                        elsif ($j == 1)
                                          {$terms[2*$i] = Compute("$v")->reduce;}
                                        else
                                          {$terms[2*$i] = Compute("$v^{$j}")->reduce;};
                                }			
				else{
                                        if ($j == 0)
                                          {$terms[2*$i] = Compute("-1")->reduce;}
                                        elsif ($j == 1)
                                          {$terms[2*$i] = Compute("-$v")->reduce;}
                                        else
                                          {$terms[2*$i] = Compute("-$v^{$j}")->reduce;};
                                };
		        	
		}
		elsif ($j > 1) {
			if ($poly[$i] > 0) {$terms[2*$i-1] = '+';
				if ($poly[$i] != 1){
					$terms[2*$i] = Compute("$poly[$i] $v^{$j}");
				}
				else {$terms[2*$i] = Compute("$v^{$j}");};
                        }
			elsif ($poly[$i] == 0) 
                                {$terms[2*$i-1] = ''; $terms[2*$i] = '';}
			elsif ($poly[$i] == -1) {$terms[2*$i-1] = '-'; 
                                                 $terms[2*$i] = Compute("$v^{$j}");}
			else {$terms[2*$i-1] = '-';
                              $terms[2*$i] = Compute("$abspoly[$i] $v^{$j}");};
		}
		elsif ($j == 1) {
			if ($poly[$i] > 0) {$terms[2*$i-1] = '+';
		  		if ($poly[$i] != 1){
					$terms[2*$i] = Compute("$poly[$i] $v");
				}
		  		else {$terms[2*$i] = Compute("$v");}
		  	}
			elsif ($poly[$i] == 0) 
                                {$terms[2*$i-1] = ''; $terms[2*$i] = '';}
			elsif ($poly[$i] == -1){$terms[2*$i-1] = '-';
                                                $terms[2*$i] = Compute("$v");}
			else {$terms[2*$i-1] = '-';
                              $terms[2*$i] = Compute("$abspoly[$i] $v");};
		}
		else {
			if ($poly[$i] > 0) {$terms[2*$i-1] = '+';
		  		$terms[2*$i] = Compute("$poly[$i]");}
			elsif ($poly[$i] == 0) 
                                {$terms[2*$i-1] = ''; $terms[2*$i] = '';}
			else {$terms[2*$i-1] = '-';
                              $terms[2*$i] = Compute("$abspoly[$i]");};
		};
	};
        
	return @terms;
}

###############################
# Name: PolySub
sub PolySub{
my  ($xref,$yref,%options) = @_;
my  @local_x = @{$xref};
my  @local_y = @{$yref};
foreach my $y (@local_y) { $y = $y * -1; }
return PolyAdd(\@local_x, \@local_y, %options);
}


###############################
# Name: PolyAdd
#
# Input: two arrays, for example
#
#  PolyAdd(~~@poly1, ~~@poly2)
#
# Arrays elements should be numerical or Math Objects 
# where addition are allowed. The idea is that 
# these are coefficients of a polynomial, either starting from the
# constant term or from the leading term.
#  
# Optional Input: order=>ascending or descending, defaults to descending
#   order is ignored if output=>array
# Optional Input: var=> some string, defaulting to "x"
# Optional Input: subtract=> 1 will subtract; default 0
# Optional Input: output=>array, simplified, unsimplified
#   which is either an array of coefficients, a simplified
#   polynomial string using var and ready to be fed to Compute, or the same
#   but unsimplified with like terms near each other. Default is array.
#
# Output: described in Optional Input 
#
#         For example, given 
#
#             @poly1 = (1,2);  # represents x+2 (assuming descending)
#             @poly2 = (3,-1,4);  # represents 3x^2-x+4
#
#         PolyAdd(~~@poly1, ~~@poly2,var=>'z', output=>unsimplified)
#
#             '3z^2+1z+-1z+2+4'
#
#         Note that instance of +- may be present, but Math Objectification
#         will handle that.
#
#         
#         Given 
#
#           @poly1 = (Fraction(1,3),2);  # represents 1/3+2x (assuming ascending)
#           @poly2 = (Fraction(1,2),0,Fraction(-1,3));  
#
#         PolyAdd(~~@poly1, ~~@poly2,order=>ascending)
#
#             (Frac(5,6),2,Frac(-1,3))
#
#
# Note: If you intend to feed the output string to Compute() or Formula(),
#  you should set the context reductions appropriately and apply ->reduce
#  *twice* to remove excess parentheses from negative coefficients.
#      
################################

sub PolyAdd{
my  ($xref,$yref,%options) = @_;
my  @local_x = @{$xref};
my  @local_y = @{$yref};

my ($order, $var, $output, @sumArray, $sumString, $subtract, $plusMinus);

$order = $options{'order'} if defined ($options{'order'});
$order = 'descending' unless defined ($options{'order'});

$var = $options{'var'} if defined ($options{'var'});
$var = 'x' unless defined ($options{'var'});

$subtract = $options{'subtract'} if defined ($options{'subtract'});
$subtract = 0 unless defined ($options{'subtract'});

$output = $options{'output'} if defined ($options{'output'});
$output = 'array' unless defined ($options{'output'});

my $Nx = max($#local_x,$#local_y)-($#local_x);
my $Ny = max($#local_x,$#local_y)-($#local_y);

if ($order eq 'ascending') {
  for my $i (1..$Nx)
    {push(@local_x,0);}
  for my $i (1..$Ny)
    {push(@local_y,0);}
}
else {
  for my $i (1..$Nx)
    {unshift(@local_x,0);}
  for my $i (1..$Ny)
    {unshift(@local_y,0);}
}


if ($output eq 'array' or $output eq 'simplified') {
  for my $i (0..$#local_x) {
   $sumArray[$i]= $local_x[$i]+(-1)**($subtract)*$local_y[$i];
   }

  if ($output eq 'array') {return @sumArray;}
  if ($output eq 'simplified') {return PolyString(\@sumArray,order=>$order,var=>$var);}  
}


if ($output eq 'unsimplified') {
   if ($subtract == 1)
    {$plusMinus = '-'}
   else {$plusMinus = '+'};
   $sumString = '';
   for my $i (0..$#local_x) {
     $sumString = $sumString.'+'.$local_x[$i].$var.'^'.xPower($i,$#local_x,$order).$plusMinus.$local_y[$i].$var.'^'.xPower($i,$#local_x,$order);
     }
   return $sumString;
}
   
}  


###############################
# Name: numberWord
#
# Input: either a whole number <100 or a fraction with numerator and denominator less than 100. If fraction, set denominator parameter.
# Optional Input: capital => 1 (default is 0)
# Optional Input: denominator=> 4 (default is 1)
#  numberWord($n)
#
# Output: a string spelling that number
#      
################################

sub numberWord{
my  ($n,%options, $return, $capital, $denominator, $numerator) = @_;

$capital = $options{'capital'} if defined ($options{'capital'});
$denominator = $options{'denominator'} if defined ($options{'denominator'});

$capital= 0 unless defined($capital);
$denominator = 1 unless defined($denominator);

return $n if (abs($n*$denominator) > 99);

my %wordNumber = (0=>'zero',
         1=>'one',
         2=>'two',
         3=>'three',
         4=>'four',
         5=>'five',
         6=>'six',
         7=>'seven',
         8=>'eight',
         9=>'nine',
         10=>'ten',
         11=>'eleven',
         12=>'twelve',
         13=>'thirteen',
         14=>'fourteen',
         15=>'fifteen',
         16=>'sixteen',
         17=>'seventeen',
         18=>'eighteen',
         19=>'nineteen',
         20=>'twenty',
         30=>'thirty',
         40=>'forty',
         50=>'fifty',
         60=>'sixty',
         70=>'seventy',
         80=>'eighty',
         90=>'ninety');

my %wordFraction = (
         1=>'first',
         2=>'second',
         3=>'third',
         4=>'fourth',
         5=>'fifth',
         6=>'sixth',
         7=>'seventh',
         8=>'eighth',
         9=>'ninth',
         12=>'twelfth',
         20=>'twentieth',
         30=>'thirtieth',
         40=>'fortieth',
         50=>'fiftieth',
         60=>'sixtieth',
         70=>'seventieth',
         80=>'eightieth',
         90=>'ninetieth');

$return = '';
if ($n < 0) {$return = 'negative ';};

$n = abs($n);

if ($denominator == 1) {
  if (($n <= 20) or ($n%10 == 0)) {$return = $return.$wordNumber{$n}}
  else {$return = $return.numberWord($n-($n%10)).'-'.numberWord($n%10)}; 
}

else {
  $numerator = round($n*$denominator);
  $return = $return.numberWord($numerator);
  if (($denominator == 2) and ($numerator != 1))
    {$return = $return.' halves';}
  elsif (($denominator == 2) and ($numerator == 1))
    {$return = $return.' half'}
  elsif (defined($wordFraction{$denominator}))
    {$return = $return.' '.$wordFraction{$denominator};
     $return = $return.'s' if ($numerator != 1)}
  elsif (defined($wordNumber{$denominator}))
    {$return = $return.' '.$wordNumber{$denominator}.'th';
     $return = $return.'s' if ($numerator != 1)}
  else
    {$return = $return.' '.numberWord($denominator-$denominator%10).'-'.$wordFraction{$denominator%10};
     $return = $return.'s' if ($numerator != 1)}    
}


$return = ucfirst($return) if ($capital == 1);
return $return;

}

# radicalListCheck
#
# Used when multiple answers are needed (e.g for quadratic) equations
# that may or may *not* contain radicals.
#
# Sample use:
#
#         ANS($ans->cmp(limits => [1,2],list_checker => ~~&radicalListCheck));
#
#
sub radicalListCheck {
     my ($correct,$student,$ansHash,$value) = @_;
     my $score = 0;              # number of correct student answers
     my @errors = ();            # stores error messages
     my ($i, $j, $k);              # loop counters
     return (0, @errors) if $ansHash->{isPreview};
     my $fullStudent = $ansHash->{student_formula};
     #in line below, correct_ans seems the right thing to do. In some problems, this is blank, so I'm just going with correct_value
     # for those problems. But changing to correct_value broke other problems... so the conditional hack
     my $fullCorrect = ($ansHash->{correct_ans}) ? Formula($ansHash->{correct_ans}) : Formula($ansHash->{correct_value});

     my @fullStudentValue = $fullStudent->value;
     my @fullCorrectValue = $fullCorrect->value;
     my $n = scalar(@fullStudentValue);  # number of student answers
     my $m = scalar(@fullCorrectValue);  # number of correct answers

     #
     #  Loop though the student answers
     ##
     for ($i = 0; $i < $n; $i++) {
       my $ith = Value::List->NameForNumber($i+1);
       my $p = $fullStudentValue[$i];   # i-th student answer

       #
       #  Check that the student's answer is an assignment (or whatever the right type)
       #
       my $assingmentMessageGiven = 0;
       my $nosolutionMessageGiven = 0;
       if (defined($p)) {
           if($p eq "no real solutions")
           {
              push(@errors,"This equation does have some solutions.");
              $nosolutionMessageGiven = 1;
           }
           elsif($p->type ne "Assignment") {
           push(@errors,"Your $ith entry should be written $var=_____");
           $assingmentMessageGiven = 1;
           }
       }

       #
       #  Check that the answer hasn't been given before
       #
       for ($j = 0, $used = 0; $j < $i; $j++) {
         if ($p == $fullStudentValue[$j]) {
           push(@errors,"Your $ith solution is the same as a previous one");
           $used = 1; last;
         }
       }

       #
       #  If not already used, check that it is a correct and reduced answer
       #
       if (!$used) {
          my ($numericallyCorrect, $reduced);
          for ($k = 0, $numericallyCorrect = 0; ($k < $m) ; $k++) {
                    $q = $fullCorrectValue[$k];
                    if (Formula($q) == Formula($p)) {
                          $numericallyCorrect = 1;
                          my ($setSqrt, $setRoot) = (Context()->flag("setSqrt"), Context()->flag("setRoot"));
                          Context()->flags->set(checkSqrt => $setSqrt, checkRoot => $setRoot, bizarroAdd => 1, bizarroSub => 1, bizarroMul => 1, bizarroDiv => 1);
                          delete $p->{test_values};
                          delete $q->{test_values};
                             if ($p == $q) {$reduced = 1} else {$reduced = 0}; # check if form is correct

                          Context()->flags->set(checkSqrt => 0, checkRoot => 0, bizarroAdd => 0, bizarroSub => 0, bizarroMul => 0, bizarroDiv => 0);
                          $score++ if ($numericallyCorrect and $reduced);
                          push(@errors,"Your $ith solution is not fully simplified") if ($numericallyCorrect and !$reduced and ($n>1));
                          push(@errors,"Your solution is not fully simplified") if ($numericallyCorrect and !$reduced and ($n==1));
                          last;
                  }
         }
         push(@errors,"Your $ith solution is not correct") if (!$numericallyCorrect and ($n>1) and !$assingmentMessageGiven );
         push(@errors,"Your solution is not correct") if (!$numericallyCorrect and ($n==1) and !$assingmentMessageGiven and !$nosolutionMessageGiven );
       }
     }

     #
     #  Check that there are the right number of answers
     #
     if (!$ansHash->{isPreview}) {
       #push(@errors,"Do you have all the solutions?") if (($n < 2) and ($score < 2) and !$nosolutionMessageGiven );
       #push(@errors,"Should a quadratic equation have more than two solutions?") if ($n > 2);
       push(@errors,"Do you have all the solutions?") if (($n < $m) and ($score < $m) and !$nosolutionMessageGiven );
       push(@errors,"Should this equation have more than $m solution?") if ($n > $m and $m==1);
       push(@errors,"Should this equation have more than $m solutions?") if ($n > $m and $m>1);
  
     }
     return ($score,@errors);
   }

# Keyboard instructions should only be displayed in HTML output
sub KeyboardInstructions {
   my $in = shift;
   if ($displayMode =~ /HTML/) {return $in}
}


1;
