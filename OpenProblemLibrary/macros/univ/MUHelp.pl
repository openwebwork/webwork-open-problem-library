sub BBRED { 
  MODES(TeX => '{\\color{red} ', HTML => '<span style="color:red; font-weight:bold">'); 
};

sub EBRED { 
  MODES( TeX => '}', HTML => '</span>'); 
};

$main::BBRED = BBRED();
$main::EBRED = EBRED();

$badmessage = "$BBRED Something helpful should go here. Please inform your instructor that it is missing! $EBRED";

sub MUHelp {
  my $type = shift;
  return $badmessage unless defined($type);

  my $rString = "";
  my $typeOkay = 0;
  
  if ($type =~ m/sqrt/i) {
    $rstring = "If necessary, type ${BBOLD}sqrt()${EBOLD} to enter a square root. For example, to enter \\(\\sqrt{7x}\\), you would type your answer as sqrt(7x). You must put parentheses around everything you want to take the square root of!!";
    $typeOkay = 1;
  } elsif ($type =~ m/absvaleqn/i) {
    $rstring = "Enter your answers as a comma separated list if there is more than one correct answer. Type ${BBOLD}no solution${EBOLD} if the equation has no solution.";
    $typeOkay = 1;
  } elsif ($type =~ m/logans/i) {
    $rstring = "Give an exact answer. If necessary, type ${BBOLD}log(b,x)${EBOLD} to enter \\(\\log_b(x)\\) as an answer. For example, type ${BBOLD}log(3,5)${EBOLD} to enter \\(\\log_3(5)\\). You may also use  ${BBOLD}ln(15)${EBOLD} for \\(\\ln(15)\\), and ${BBOLD}log10(20)${EBOLD} for \\(\\log(20)\\). Enter your answers as a comma separated list if there is more than one correct answer. Type ${BBOLD}no solution${EBOLD} if the equation has no solution.";
    $typeOkay = 1;
  } elsif ($type =~ m/lineareqns/i) {
    $rstring = "If necessary, type ${BBOLD}no solutions${EBOLD} if the equation has no solution or type ${BBOLD}infinitely many${EBOLD} if there are infinitely many solutions.";
    $typeOkay = 1;
  } elsif ($type =~ m/quadeqns/i) {
    $rstring = "Enter your answers as a comma separated list if there is more than one correct answer. Type ${BBOLD}no solution${EBOLD} if the equation has no solution. If necessary, type ${BBOLD}sqrt()${EBOLD} to enter a square root. For example, to enter \\(\\sqrt{7x}\\), you would type your answer as sqrt(7x). You must put parenthesis are everything you want to take the square root of!!";
    $typeOkay = 1;
  }
  
  if ($typeOkay == 1) {return $rstring;};
  return $badmessage;
}

1;


## Append .helpLink("exponents","Click here for further help.") to a string to add a help link.