sub _compoundProblem_init {};   # don't reload this file

#####################################################################
#
#  This package implements a method of handling multi-part problems
#  that show only a single part at any one time.  The students can
#  work on one part at a time, and then when they get it right (or
#  under other circumstances deterimed by the professor), they can
#  move on to the next part.  Students can not return to earlier parts
#  once they have been completed.  The score for problem as a whole is
#  made up from the scores on the individual parts, and the relative
#  weighting of the various parts can be specified by the problem
#  author.
#
#  To use the compoundProblem library, use
#
#      loadMacros("compoundProblem.pl");
#
#  at the top of your file, and then create a compoundProblem object
#  via the command
#
#      $cp = new compoundProblem(options)
#
#  where '$cp' is the name of a variable that you will use to
#  refer to the compound problem, and 'options' can include:
#
#    parts => n                The number of parts in the problem.
#                                Default: 1
#
#    weights => [n1,...,nm]    The relative weights to give to each
#                              part in the problem.  For example,
#                                  weights => [2,1,1]
#                              would cause the first part to be worth 50%
#                              of the points (twice the amount for each of
#                              the other two), while the second and third
#                              part would be worth 25% each.  If weights
#                              are not supplied, the parts are weighted
#                              by the number of answer blanks in each part
#                              (and you must provide the total number of
#                              blanks in all the parts by supplying the
#                              totalAnswers option).
#
#    totalAnswers => n         The total number of answer blanks in all
#                              the parts put together (this is used when
#                              computing the per-part scores, if part
#                              weights are not provided).
#
#    saveAllAnswers => 0 or 1  Usually, the contents of named answer blanks
#                              from previous parts are made available to
#                              later parts using variables with the
#                              same name as the answer blank.  Setting
#                              saveAllAnswers to 1 will cause ALL answer
#                              blanks to be available (via variables
#                              like $AnSwEr1, and so on).
#                                 Default:  0
#
#    parserValues => 0 or 1    Determines whether the answers from previous
#                              parts are returned as MathObjects (like
#                              those returned from Real(), Vector(), etc)
#                              or as strings (the unparsed contents of the
#                              student answer).  If you intend to use the
#                              previous answers as numbers, for example,
#                              you would want to set this to 1 so that you
#                              would get the final result of any formula
#                              the student typed, rather than the formula
#                              itself as a character string.
#                                 Default:  0
#
#    nextVisible => type       Tells when the "go on to the next part" option
#                              is available to the student.  The possible
#                              types include:
#
#                                 'ifCorrect'   next is available only when
#                                               all the answers are correct.
#
#                                 'Always'      next is always available
#                                               (but remember that students
#                                               can't go back once they go
#                                               on.)
#
#                                 'Never'       next is never allowed (the
#                                               problem will control going
#                                               on to the next part itself).
#
#                                Default:  'ifCorrect'
#
#    nextStyle => type         Determines the style of "next" indicator to display
#                              (when it is available).  The type can be one of:
#
#                                 'CheckBox'    a checkbox that allows the students
#                                               to go on to the next part when they
#                                               submit their answers.
#
#                                 'Button'      a button that submits their answers
#                                               and goes on to the next part.
#
#                                 'Forced'      forces the student to go on to the
#                                               next part the next time they submit
#                                               answers.
#
#                                 'HTML'        allows you to provide an arbitrary
#                                               HTML string of your own.
#
#                                Default:  'Checkbox'
#
#    nextLabel => string       Specifies the string to use as the label for the checkbox,
#                              the name of the button, the text of the message indicating
#                              that the next submit will move to the next part, or the
#                              HTML string, depending on the setting of nextStyle above.
#
#    nextNoChange => 0 or 1    Since the students must submit their answers again to go on
#                              to the next part, it is possible for them to change their
#                              answers before they submit, and if nextVisible is 'ifCorrect'
#                              they might go on to the next without having correct answers
#                              stored.  This option lets you control whether the answers
#                              are checked against the previous ones before going on to the
#                              next part.  If the answers don't match, a warning is issued
#                              and they are not allowed to move on.
#                                Default:  1
#
#    allowReset => 0 or 1      Determines whether a "Go back to the first part" checkbox
#                              is provided on parts 2 and later.  This is intended for
#                              the professor during testing of the problem (otherwise
#                              it would be impossible to go back to earlier parts).
#                                Default:  0
#
#    resetLabel => string      The string used to label the reset checkbox.
#
#  Once you have created a compoundProblem object, you can use $cp->part to
#  determine the part that the student is working on, and use 'if' statements
#  to display the proper information for the given part.  The compoundProblem
#  object takes care of maintaining the data as the parts change.  (See the
#  compoundProblem.pg file for an example of a compound problem.)
#
#  In order to handle the scoring of the problem as a whole when only part is
#  showing, the compoundProblem object uses its own problem grader to manage
#  the scores, and calls your own grader from there.  The default is to use
#  the one that was installed before the compoundProblem object was created,
#  or avg_problem_grader if none was installed.  You can specify a different
#  one using the $cp->useGrader() method (see below).  It is important that
#  you NOT call install_problem_grader() yourself once you have created the
#  compoundProblem object, as that would disable the special grader, causing
#  the compound problem to fail to work properly.
#
#  You may call the following methods once you have a compoundProblem:
#
#    $cp->part                   Returns the part the student is working on.
#    $cp->part(n)                Sets the part to be part n, as long as the
#                                student has finished the preceeding parts.
#                                If not, the part is set to the highest
#                                one the student hasn't completed, and he
#                                can work up to the given part.  (The
#                                nextVisible option is set to 'ifCorrect' if
#                                it was 'Never' so that students can go on
#                                once they finish the earlier parts.)
#
#    $cp->useGrader(code_ref)    Supplies your own grader to use in
#                                place of the default one.  For example:
#                                  $cp->useGrader(~~&std_problem_grader);
#
#    $cp->score                  Returns the (weighted) score for this part.
#                                Note that this is the score shown at the bottom
#                                of the page on which the student pressed submit
#                                (not the score for the answers the student is
#                                submitting -- that is not available until
#                                after the body of the problem has been created).
#
#    $cp->scoreRaw               Returns the unweighted score for this part.
#
#    $cp->scoreOverall           Returns the overall score for the problem
#                                so far.
#
#    $cp->addAnswers(list)       Make additional answer blanks be available
#                                from one part to another.  E.g.,
#                                   $cp->addAnswers('AnSwEr1');
#                                would make the first unnamed blank be available
#                                in later parts as well.  (This command should
#                                be issued only when the part containing the
#                                given answer blank is displayed.)
#
#    $cp->nextCheckbox(label)    Returns the HTML string for the "go on to next
#                                part" checkbox so you can use it in the body of
#                                the problem if you wish.  This should not be
#                                inserted when the $displayMode is 'TeX'.  If the
#                                label is not given or is blank, the default label
#                                is used.
#
#    $cp->nextButton(label)      Returns the HTML string for the "go on to next
#                                part" button so you can use it in the body of
#                                the problem if you wish.  This should not be
#                                inserted when the $displayMode is 'TeX'.  If the
#                                label is not given or is blank, the default label
#                                is used.
#
#    $cp->nextForces(label)      Returns the HTML string for the forced "go on to
#                                next part" so you can use it in the body of
#                                the problem if you wish.  This should not be
#                                inserted when the $displayMode is 'TeX'.  If the
#                                label is not given or is blank, the default label
#                                is used.
#
#    $cp->reset                  Go back to part 1, clearing the answers
#                                and score.  (Best used when debugging problems.)
#
#    $cp->resetCheckbox(label)   Returns the HTML string for the reset checkbox
#                                so that you can provide one within the body
#                                of the problem if you wish.  This should not be
#                                inserted when the $displayMode is 'TeX'.  If the
#                                label is not given or is blank, the default label
#                                will be used.
#
######################################################################

package compoundProblem;
#
#  The state data that is stored between invocations of
#  the problem.
#
our %defaultStatus = (
  part => 1,                # the current part
  answers => "",            # answer labels from previous parts
  new_answers => "",        # answer labels for THIS part
  ans_rule_count => 0,      # the ans_rule count from previous parts
  new_ans_rule_count => 0,  # the ans_rule count from THIS part
  score => 0,               # the (weighted) score on this part
  total => 0,               # the total on previous parts
  raw => 0,                 # raw score on this part
);
#
#  Create a new instance of the compound Problem and initialize
#  it.  This includes reading the status from the previous
#  parts, defining the variables from the answers to previous parts,
#  and setting up the grader so that the current data can be saved.
#

sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $cp = bless {
    parts => 1,
    totalAnswers => undef,
    weights => undef,            # array of weights per part
    saveAllAnswers => 0,         # usually only save named answers
    parserValues => 0,           # make Parser objects from the answers?
    nextVisible => "ifCorrect",  # or "Always" or "Never"
    nextStyle   => "Checkbox",   # or "Button", "Forced", or "HTML"
    nextLabel   => undef,        # Checkbox text or button name or HTML
    nextNoChange => 1,           # true if answer can't change for new part
    allowReset => 0,             # true to show "back to part 1" button
    resetLabel => undef,         # label for reset button
    grader => $main::PG_FLAGS{PROBLEM_GRADER_TO_USE} || \&main::avg_problem_grader,
    @_,
    status => $defaultStatus,
  }, $class;
  die "You must provide either the totalAnswers or weights"
    unless $cp->{totalAnswers} || $cp->{weights};
  $cp->getTotalWeight if $cp->{weights};
  main::loadMacros("Parser.pl") if $cp->{parserValues};
  $cp->reset if $cp->{allowReset} && $main::inputs_ref->{_reset};
  $cp->getStatus;
  $cp->initPart;
  return $cp;
}

#
#  Compute the total of the weights so that the parts can
#  be properly scaled.
#
sub getTotalWeight {
  my $self = shift;
  $self->{totalWeight} = 0; $self->{totalAnswers} = 1;
  foreach my $w (@{$self->{weights}}) {$self->{totalWeight} += $w}
  $self->{totalWeight} = 1 if $self->{totalWeight} == 0;
}

#
#  Look up the status from the previous invocation
#  and see if we need to go on to the next part.
#
sub getStatus {
  my $self = shift;
  main::RECORD_FORM_LABEL("_next");
  main::RECORD_FORM_LABEL("_status");
  $self->{status} = $self->decode;
  $self->{isNew} = $main::inputs_ref->{_next} || ($main::inputs_ref->{submitAnswers} && 
     $main::inputs_ref->{submitAnswers} eq ($self->{nextLabel} || "Go on to Next Part"));
  if ($self->{isNew}) {
    $self->checkAnswers;
    $self->incrementPart unless $self->{nextNoChange} && $self->{answersChanged};
  }
}

#
#  Initialize the current part by setting the ans_rule
#  count (so that later parts will get unique answer names),
#  installing the grader (to save the data), and setting
#  the variables for previous answers.
#
sub initPart {
  my $self = shift;
  $main::ans_rule_count = $self->{status}{ans_rule_count};
  main::install_problem_grader(\&compoundProblem::grader);
  $main::PG_FLAGS{compoundProblem} = $self;
  $self->initAnswers($self->{status}{answers});
}

#
#  Look through the list of answer labels and set
#  the variables for them to be the associated student
#  answer.  Make it a Parser value if requested.
#  Record the value so that is will be available
#  again on the next invocation.
#
sub initAnswers {
  my $self = shift; my $answers = shift;
  foreach my $id (split(/;/,$answers)) {
    my $value = $main::inputs_ref->{$id}; $value = '' unless defined($value);
    if ($self->{parserValues}) {
      my $parser = Parser::Formula($value);
      $parser = Parser::Evaluate($parser) if $parser && $parser->isConstant;
      $value = $parser if $parser;
    }
    ${"main::$id"} = $value unless $id =~ m/$main::ANSWER_PREFIX/o;
    $value = quoteHTML($value);
    main::TEXT(qq!<input type="hidden" name="$id" value="$value" />!);
    main::RECORD_FORM_LABEL($id);
  }
}

#
#  Look to see is any answers have changed on this
#  invocation of the problem.
#
sub checkAnswers {
  my $self = shift;
  foreach my $id (keys(%{$main::inputs_ref})) {
    if ($id =~ m/^previous_(.*)$/) {
      if ($main::inputs_ref->{$id} ne $main::inputs_ref->{$1}) {
        $self->{answersChanged} = 1;
        $self->{isNew} = 0 if $self->{nextNoChange};
        return;
      }
    }
  }
}

#
#  Go on to the next part, updating the status
#  to include the data from the old part so that
#  it will be properly preserved when the next
#  part is showing.
#
sub incrementPart {
  my $self = shift;
  my $status = $self->{status};
  if ($status->{part} < $self->{parts}) {
    $status->{part}++;
    $status->{answers} .= ';' if $status->{answers};
    $status->{answers} .= $status->{new_answers};
    $status->{ans_rule_count} = $status->{new_ans_rule_count};
    $status->{total} += $status->{score};
    $status->{score} = $status->{raw} = 0;
    $status->{new_answers} = '';
  }
}

######################################################################
#
#  Encode all the status information so that it can be
#  maintained as the student submits answers.  Since this
#  state information includes things like the score from
#  the previous parts, it is "encrypted" using a dumb
#  hex encoding (making it harder for a student to recognize
#  it as valuable data if they view the page source).
#
sub encode {
  my $self = shift; my $status = shift || $self->{status};
  my @data = (); my $data = "";
  foreach my $id (main::lex_sort(keys(%defaultStatus))) {push(@data,$status->{$id})}
  foreach my $c (split(//,join('|',@data))) {$data .= toHex($c)}
  return $data;
}

#
#  Decode the data and break it into the status hash.
#
sub decode {
  my $self = shift; my $status = shift || $main::inputs_ref->{_status};
  return {%defaultStatus} unless $status;
  my @data = (); foreach my $hex (split(/(..)/,$status)) {push(@data,fromHex($hex)) if $hex ne ''}
  @data = split('\\|',join('',@data)); $status = {%defaultStatus};
  foreach my $id (main::lex_sort(keys(%defaultStatus))) {$status->{$id} = shift(@data)}
  return $status;
}

#
#  Hex encoding is shifted by 10 to obfuscate it further.
#  (shouldn't be a problem since the status will be made of
#  printable characters, so they are all above ASCII 32)
#
sub toHex {main::spf(ord(shift)-10,"%X")}
sub fromHex {main::spf(hex(shift)+10,"%c")}

#
#  Make sure the data can be properly preserved within
#  an HTML <INPUT TYPE="HIDDEN"> tag.
#
sub quoteHTML {
  my $string = shift;
  $string =~ s/&/\&amp;/g; $string =~ s/"/\&quot;/g;
  $string =~ s/>/\&gt;/g;  $string =~ s/</\&lt;/g;
  return $string;
}

######################################################################
#
#  Set the grader for this part to the specified one.
#
sub useGrader {
  my $self = shift;
  $self->{grader} = shift;
}

#
#  Make additional answer blanks from the current part
#  be preserved for use in future parts.
#
sub addAnswers {
  my $self = shift;
  $self->{extraAnswers} = [] unless $self->{extraAnswers};
  push(@{$self->{extraAnswers}},@_);
}

#
#  Go back to part 1 and clear the answers and scores.
#
sub reset {
  my $self = shift;
  if ($main::inputs_ref->{_status}) {
    my $status = $self->decode($main::inputs_ref->{_status});
    foreach my $id (split(/;/,$status->{answers})) {delete $main::inputs_ref->{$id}}
    foreach my $id (1..$status->{ans_rule_count})
      {delete $main::inputs_ref->{"${main::QUIZ_PREFIX}${main::ANSWER_PREFIX}$id"}}
  }
  $main::inputs_ref->{_status} = $self->encode(\%defaultStatus);
  $main::inputs_ref->{_next} = 0;
}

#
#  Return the HTML for the "Go back to part 1" checkbox.
#
sub resetCheckbox {
  my $self = shift;
  my $label = shift || " <b>Go back to Part 1</b> (when you submit your answers).";
  my $par = shift; $par = ($par ? $main::PAR : '');
  qq'$par<input type="checkbox" name="_reset" value="1" />$label';
}

#
#  Return the HTML for the "next part" checkbox.
#
sub nextCheckbox {
  my $self = shift;
  my $label = shift || " <b>Go on to next part</b> (when you submit your answers).";
  my $par = shift; $par = ($par ? $main::PAR : '');
  $self->{nextInserted} = 1;
  qq!$par<input type="checkbox" name="_next" value="next" />$label!;
}

#
#  Return the HTML for the "next part" button.
#
sub nextButton {
  my $self = shift;
  my $label = quoteHTML(shift || "Go on to Next Part");
  my $par = shift; $par = ($par ? $main::PAR : '');
  $par . qq!<input type="submit" name="submitAnswers" value="$label" !
       .      q!onclick="document.getElementById('_next').value=1" />!;
}

#
#  Return the HTML for when going to the next part is forced.
#
sub nextForced {
  my $self = shift;
  my $label = shift || "<b>Submit your answers again to go on to the next part.</b>";
  $label = $main::PAR . $label if shift;
  $self->{nextInserted} = 1;
  qq!$label<input type="hidden" name="_next" id="_next" value="Next" />!;
}

#
#  Return the raw HTML provided
#
sub nextHTML {shift; shift}

######################################################################
#
#  Return the current part, or try to set the part to the given
#  part (returns the part actually set, which may be earlier if
#  the student didn't complete an earlier part).
#
sub part {
  my $self = shift; my $status = $self->{status};
  my $part = shift;
  return $status->{part} unless defined $part && $main::displayMode ne 'TeX';
  $part = 1 if $part < 1; $part = $self->{parts} if $part > $self->{parts};
  if ($part > $status->{part} && !$main::inputs_ref->{_noadvance}) {
    unless ((lc($self->{nextVisible}) eq 'ifcorrect' && $status->{raw} < 1) ||
             lc($self->{nextVisible}) eq 'never') {
      $self->initAnswers($status->{new_answers});
      $self->incrementPart; $self->{isNew} = 1;
    }
  }
  if ($part != $status->{part}) {
    main::TEXT('<input type="hidden" name="_noadvance" value="1" />');
    $self->{nextVisible} = 'IfCorrect' if lc($self->{nextVisible}) eq 'never';
  }
  return $status->{part};
}

#
#  Return the various scores
#
sub score {shift->{status}{score}}
sub scoreRaw {shift->{status}{raw}}
sub scoreOverall {
  my $self = shift;
  return $self->{status}{score} + $self->{status}{total};
}

######################################################################
#
#  The custom grader that does the work of computing the scores
#  and saving the data.
#
sub grader {
  my $self = $main::PG_FLAGS{compoundProblem};

  #
  #  Get the answer names and the weight for the current part.
  #
  my @answers = keys(%{$_[0]});
  my $weight = scalar(@answers)/$self->{totalAnswers};
  $weight = $self->{weights}[$self->{status}{part}-1]/$self->{totalWeight}
    if $self->{weights} && defined($self->{weights}[$self->{status}{part}-1]);
  @answers = grep(!/$main::ANSWER_PREFIX/o,@answers) unless $self->{saveAllAnswers};
  push(@answers,@{$self->{extraAnswers}}) if $self->{extraAnswers};
  my $space = '<img src="about:blank" style="height:1px; width:3em; visibility:hidden" />';

  #
  #  Call the original grader, but put back the old recorded_score
  #  (the grader will have updated it based on the score for the PART,
  #  not the problem as a whole).
  #
  my $oldScore = ($_[1])->{recorded_score};
  my ($result,$state) = &{$self->{grader}}(@_);
  $state->{recorded_score} = $oldScore;

  #
  #  Update that state information and encode it.
  #
  my $status = $self->{status};
  $status->{raw}   = $result->{score};
  $status->{score} = $result->{score}*$weight;
  $status->{new_ans_rule_count} = $main::ans_rule_count;
  $status->{new_answers} = join(';',@answers);
  my $data = quoteHTML($self->encode);

  #
  #  Update the recorded score
  #
  my $newScore = $status->{total} + $status->{score};
  $state->{recorded_score} = $newScore if $newScore > $oldScore;
  $state->{recorded_score} = 0 if $self->{allowReset} && $main::inputs_ref->{_reset};

  #
  #  Add the compoundProblem message and data
  #
  $result->{type} = "compoundProblem ($result->{type})";
  $result->{msg} .= '</i><p><b>Note:</b> <i>' if $result->{msg};
  $result->{msg} .= 'This problem has more than one part.'
                 .  '<br/>'.$space.'<small>Your score for this attempt is for this part only;</small>'
                 .  '<br/>'.$space.'<small>your overall score is for all the parts combined.</small>'
                 .  qq!<input type="hidden" name="_status" value="$data" />!;

  #
  #  Warn if the answers changed when they shouldn't have
  #
  $result->{msg} .= '<p><b>You may not change your answers when going on to the next part!</b>'
    if $self->{nextNoChange} && $self->{answersChanged};

  #
  #  Include the "next part" checkbox, button, or whatever.
  #
  my $par = 1;
  if ($self->{parts} > $status->{part} && !$main::inputs_ref->{previewAnswers}) {
    if (lc($self->{nextVisible}) eq 'always' ||
       (lc($self->{nextVisible}) eq 'ifcorrect' && $result->{score} >= 1)) {
      my $method = "next".$self->{nextStyle}; $par = 0;
      $result->{msg} .= $self->$method($self->{nextLabel},1).'<br/>';
    }
  }

  #
  #  Add the reset checkbox, if needed
  #
  $result->{msg} .= $self->resetCheckbox($self->{resetLabel},$par)
    if $self->{allowReset} && $status->{part} > 1;

  #
  #  Make sure we don't go on unless the next button really is checked
  #
  $result->{msg} .= '<input type="hidden" name="_next" value="0" />'
    unless $self->{nextInserted};

  return ($result,$state);
}
