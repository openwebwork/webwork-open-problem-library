# Done: show possible choices in TeX mode
# To do: fix css clash for <ul> between draggableProof.pl and the webwork instructor tools menu.
# To do: display student answers and correct answers in TeX mode properly.
# To do: get the drag and drop features in draggableProof.pl to work on iPad using jquery.ui.touch-punch.min.js and also put this js library in a universal spot on every webwork server.

loadMacros("PGchoicemacros.pl");

sub _draggableProof_init {
  PG_restricted_eval("sub DraggableProof {new draggableProof(\@_)}");

  $courseHtmlUrl = $envir{htmlURL};

  main::POST_HEADER_TEXT(main::MODES(TeX=>"", HTML=><<'  END_SCRIPTS'));
<!--  The next to scripts may need to be included on older versions of WeBWoRK (before 2.9 or so.  
    <script type="text/javascript" src=" https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.18/jquery-ui.min.js"></script>
-->
    <script type="text/javascript" src="$courseHtmlUrl/js/jquery.ui.touch-punch.min.js"></script>
    <script>
    function _sortableUpdate () {
      var id = this.getAttribute("data-id"), ans = this.getAttribute("data-ans");
      var list = [], li = this.getElementsByTagName("li");
      for (var i = 0, n = li.length; i < n; i++) {list.push(li[i].id)}
      $("#"+ans).val(list.join(","));  
    }
    </script>
  END_SCRIPTS
}

package draggableProof;

my $n = 0;  # number of sortable lists so far

sub new {
  $n++;
  my $self = shift; my $class = ref($self) || $self;
  my $proof = shift || []; my $extra = shift || [];
  my %options = (
    SourceLabel => "Choose from these sentences:",
    TargetLabel => "Your Proof:",
    id => "P$n",
    @_
  );
  my $lines = [@$proof,@$extra];
  my $numNeeded = scalar(@$proof);
  my $numProvided = scalar(@$lines);    
  my @order = main::shuffle($numProvided);
  my @unorder = main::invert(@order);
  $self = bless {
    lines => $lines,
    numNeeded => $numNeeded, numProvided => $numProvided,
    order => \@order, unordered => \@unorder,
    proof => "$options{id}-".join(",$options{id}-",@unorder[0..$numNeeded-1]),
    %options
  }, $class;
  $self->AnswerRule;
  $self->ScriptAndStyles;
  $self->GetAnswer;
  return $self;
}

sub lines {my $self = shift; return @{$self->{lines}}}
sub numNeeded {(shift)->{numNeeded}}
sub numProvided {(shift)->{numProvided}}
sub order {my $self = shift; return @{$self->{order}}}
sub unorder {my $self = shift; return @{$self->{unorder}}}

sub ScriptAndStyles {
  my $self = shift; my $id = $self->{id};
  main::POST_HEADER_TEXT(main::MODES(TeX=>"", HTML=><<"  SCRIPT_AND_STYLE"));
    <script type="text/javascript">
      \$(document).ready(function() {
        \$(".sortable-$id").sortable({
          connectWith: ".sortable-$id",
          update: _sortableUpdate
        });
      });
    </script>
    <style type="text/css">
      .sortable-$id-container {
        color: #000000; /*#388E8E;*/
        width: 300px;
        float: left;
        border:1 px solid #388E8E;
        margin: 10px;
        padding: 0;
        text-align: center;
      }
      .sortable-$id {
         margin: 0; padding: 0;
         min-height: 1em;
      }
      .sortable-label {
        margin: 10px 0 10px 0;
      }
      .sortable-$id li {
        text-align: center;
        display: block;
        background: #F5DEB3;
        margin: 0 10px 10px 10px;
        padding: 4px;
        border: 1px solid #388E8E;
      }
      .sortable-$id li:hover {
        cursor: pointer;
      }
    </style>
  SCRIPT_AND_STYLE
}

sub AnswerRule {
  my $self = shift;
  my $rule = main::ans_rule(1);
  $self->{tgtAns} = ""; $self->{tgtAns} = $1 if $rule =~ m/id="(.*?)"/;
  $self->{srcAns} = $self->{tgtAns}."-src";
  main::RECORD_FORM_LABEL($self->{srcAns}); # use this for release 2.13 and comment out for develop
  #$main::PG->store_persistent_data;  # uncomment this for develop and releases beyond 2.13
  my $ext = main::NAMED_ANS_RULE_EXTENSION($self->{srcAns},1,answer_group_name=>$self->{srcAns}.'-src');
  main::TEXT( main::MODES(TeX=>"", HTML=>'<div style="display:none" id="Proof">'.$rule.$ext.'</div>'));
}

sub GetAnswer {
  my $self = shift; my $previous;
  $previous = $main::inputs_ref->{$self->{srcAns}} || "$self->{id}-".join(",$self->{id}-",0..$self->{numProvided}-1);
  $previous =~ s/$self->{id}-//g; $self->{previousSource} = [split(/,/,$previous)];
  $previous = $main::inputs_ref->{$self->{tgtAns}} || "";
  $previous =~ s/$self->{id}-//g; $self->{previousTarget} = [split(/,/,$previous)];
}

sub Print {
  my $self = shift;

  if ($main::displayMode ne "TeX") { # HTML mode

    return join("\n",
       '<div style="min-width:650px;">',
          $self->Source,
          $self->Target,
       '<br clear="all" />',
      '</div>'
    );

  } else { # TeX mode

    return join("\n",
          $self->Source,
          $self->Target,
    );

  }

}

sub Source {
  my $self = shift;
  return $self->Bucket("source",$self->{srcAns},$self->{SourceLabel},$self->{previousSource});
}

sub Target {
  my $self = shift;
  return $self->Bucket("target",$self->{tgtAns},$self->{TargetLabel},$self->{previousTarget});
}

sub Bucket {
  my $self = shift; my $id = $self->{id};
  my ($name,$ans,$label,$previous) = @_;

  if ($main::displayMode ne "TeX") { # HTML mode

    my @lines = (
      '<div class="sortable-'.$id.'-container">',
      '<div class="sortable-label">'.$label.'</div>',
      '<ul class="sortable-'.$id.'" id="'.$id.'-'.$name.'" data-id="'.$id.'" data-ans="'.$ans.'">'
    );
    foreach my $i (@{$previous}) {
      push(@lines,'<li id="'.$id.'-'.$i.'">'.$self->{lines}[$self->{order}[$i]].'</li>')
    }
    push(@lines,
      '</ul>',
      '</div>'
    );
    return join("\n",@lines);

  } else { # TeX mode

    if (@{$previous}) { # array is nonempty
      my @lines = ('\\begin{itemize}');
      foreach my $i (@{$previous}) {
        push(@lines,'\\item '.$self->{lines}[$self->{order}[$i]] )
      }
      push(@lines,'\\end{itemize}');
      return join("\n",@lines);
    } else {
      return '';
    }
  }

}

sub cmp {
  my $self = shift;
  return main::str_cmp($self->{proof})->withPreFilter("erase")->withPostFilter(sub {$self->filter(@_)});
}

sub filter {
  my $self = shift; my $ans = shift;
  my @line = $self->lines; my @order = $self->order;
  my $correct = $ans->{correct_ans}; $correct =~ s/$self->{id}-//g;
  my $student = $ans->{student_ans}; $student =~ s/$self->{id}-//g;
  my @correct = @line[map {@order[$_]} split(/,/,$correct)];
  my @student = @line[map {@order[$_]} split(/,/,$student)];
  $ans->{preview_latex_string} = "\\begin{array}{l}\\text{".join("}\\\\\\text{",@student)."}\\end{array}";
  $ans->{student_ans} = "(see preview)";
  $ans->{correct_ans_latex_string} = "\\begin{array}{l}\\text{".join("}\\\\\\text{",@correct)."}\\end{array}";
  $ans->{correct_ans} = join("<br />",@correct);
  return $ans;
}

1;