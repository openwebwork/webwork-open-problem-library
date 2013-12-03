#R. Byerly, Texas Tech University, 2005

sub _Generic{}   #Don't reload this file.


#Documentation:

=head1 Generic Answer Checker

(Based on David Cervone's vector_cmp.  See
doc/parser/extensions/8-answer.pg under the webwork2 directory.)
Place in macros directory and load this file (Generic.pl) using the
loadMacros command.  (To just copy it into a pg file, replace
occurences of "\&" by "~~&".)

 Usage:

  ANS(  generic_cmp(<prof_answer>, <optional and mandatory arguments>) );
where <prof_answer> is a parser object or syntactically correct string
for a parser object.

Mandatory arguments:

  type => <type>
where <type> is a recognized parser type (e.g., Number, Point, Vector,
Matrix, etc.)

  checker => <checker>
where <checker> is a reference to a subroutine that will be passed (in
order) the parsed (and, if possible, evaluated) student answer, the
parsed professor's answer, and a reference to the answer hash.  (The
last is so that it can return error messages if desired.) In simple
evaluators, the last two are typically not used.

Optional arguments:

 correct_ans => <answer_string>
where <answer_string> is a string that will show up as the correct
answer when solutions are available.

 variables_allowed => 0 or 1 
(default 0 (false).  Determines whether student's answer is allowed to
contain variables.  In this case the checker must take care of
evaluating it.)

 length => n
where n is the number of elements in an expected answer of type list,
vector, or points.  Returns error message to student if answer of wrong
length is entered.


####################Example:##########################
DOCUMENT();        # This should be the first executable line in the problem.

loadMacros(
"PG.pl",
"PGbasicmacros.pl",
"PGanswermacros.pl",
"Parser.pl",
"Generic.pl",
);

TEXT(&beginproblem);

Context("Vector");
$A=Vector(1,2,1);
$B=Vector(1,3,1);
$C=Vector(1,4,1);

BEGIN_TEXT
Show that the vectors \(\{$A->TeX\}, \{$B->TeX\}, \{$C->TeX\}\) do
not span \(R^3\) by giving a vector not in their span:
\{ans_rule()\}
END_TEXT

#Easy to get by guessing!

sub check{
  my $stu=shift();
  $x1=$stu->extract(1); $x3=$stu->extract(3);
  $x1 != $x3; #any vectors with different 1st and 3rd coordinates
}

ANS(generic_cmp("23",type => 'Vector', length => 3, checker => ~~&check));

ENDDOCUMENT(); # This should be the last executable line in the problem.

####################End of Example########################

=cut

#End of Documentation



#From parserUtils.pl:
sub protectHTML {
    my $string = shift;
    $string =~ s/&/\&amp;/g;
    $string =~ s/</\&lt;/g;
    $string =~ s/>/\&gt;/g;
    $string;

}



sub generic_cmp {
    my $v = shift;
    my %opts=@_;
    die "generic_cmp requires an argument as answer" unless defined $v;
    die "generic_cmp requires a checker" unless defined $opts{'checker'};
    die "generic_cmp requires a type" unless defined $opts{'type'};
    $v=Formula($v);

    $opts{'correct_ans'}=$v->string  if(!defined($opts{'correct_ans'}));
    $opts{'variables_allowed'}=0 if (!defined($opts{'variables_allowed'}));
    $opts{$opts{'type'}}=$v;

    my $ans = new AnswerEvaluator;

    $ans->ans_hash( (%opts) );
#    $ans->install_evaluator(~~&generic_cmp_check);
    $ans->install_evaluator(\&generic_cmp_check);
    return $ans;
}

sub generic_cmp_check {
    my $ans = shift;
    my $type=$ans->{type};my $v = $ans->{$type};
    $ans->score(0);  # assume failure
    my $f = Parser::Formula($ans->{student_ans});
    my @vars = (keys(%{$f->{variables}}));
    if(@vars == 0){
	$V = Parser::Evaluate($f);
    }elsif($ans->{variables_allowed}){
	$V=$f;  #if there are variables in the students answer,  let the checker have it.
    }else{
	$ans->{ans_message} = $ans->{error_message} =
	    "Your answer contains variables ".join(",", @vars);
	return $ans;
    }
    if (defined $V) {
	$V = Formula($V) unless Value::isValue($V);  #  make sure we can call Value methods
	$ans->{preview_latex_string} = $V->TeX;
	$ans->{preview_text_string} = $V->string;
	$ans->{student_ans} = $V->string;
	#Some checks:
	if (($type eq 'List') && !($V->type eq 'List')){
	    $V=List($V); #promote single element to list
	}

	if(defined $ans->{length}){
	    if ($ans->{length} != $V->length){
		$ans->{ans_message}=$ans->{error_message}=
		    "Wrong number of entries in answer";
		return $ans;
	    }
	}

	if (($V->type eq $type) ) {
	    $ans->score(1) if ($ans->{checker}->($V,$v,$ans));

	} else {
	    $ans->{ans_message} = $ans->{error_message} =
         "Your answer doesn't seem to be a $type (it looks like ".Value::showClass($V).")"
	 unless $inputs_ref->{previewAnswers};
	}
    } else {
    #
    #  Student answer evaluation failed.
    #  Report the error, with formatting, if possible.
    #
	my $context = Context();
	my $message = $context->{error}{message};
	if ($context->{error}{pos}) {
	    my $string = $context->{error}{string};
	    my ($s,$e) = @{$context->{error}{pos}};
	    $message =~ s/; see.*//;  # remove the position from the message
	    $ans->{student_ans} = protectHTML(substr($string,0,$s)) .
                 '<SPAN CLASS="parsehilight">' . 
                    protectHTML(substr($string,$s,$e-$s)) .
                 '</SPAN>' .
                 protectHTML(substr($string,$e));
	}
	$ans->{ans_message} = $ans->{error_message} = $message;
    }
    return $ans;
}

1;
