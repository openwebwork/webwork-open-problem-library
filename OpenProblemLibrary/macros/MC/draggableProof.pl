# Done: show possible choices in TeX mode
# To do: display student answers and correct answers in TeX mode properly.
# To do: put jquery.nestable.js in a universal spot on every webwork server.

loadMacros("PGchoicemacros.pl");

sub _draggableProof_init {
  PG_restricted_eval("sub DraggableProof {new draggableProof(\@_)}");

  $courseHtmlUrl = $envir{htmlURL};

#  if (-e "${wwHtmlDir}js/vendor/jquery/modules/jquery.nestable.js") {
#    $scriptPath = $wwHtmlUrl.'js/vendor/jquery/modules/';
#  } else {
#    $scriptPath = $courseHtmlUrl.'js/';
#  }

  # post global javascript
  main::POST_HEADER_TEXT(main::MODES(TeX=>"", HTML=><<"  END_SCRIPTS"));
<!--  The next to scripts may need to be included on older versions of WeBWoRK (before 2.9 or so.  
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.18/jquery-ui.min.js"></script>
-->
    <script src="$courseHtmlUrl/js/jquery.nestable.js"></script>

    <script>
      function _nestableUpdate (e) {
          var dd = e.length ? e : \$(e.target);
          var ans = dd["0"].getAttribute("data-ans");
          var li_tags = dd["0"].getElementsByTagName("li");
          var list = [];
          for (var i = 0, n = li_tags.length; i < n; i++) {
              list.push(li_tags[i].id);
          }
          \$("#"+ans).val(list.join(","));
      }
    </script>
  END_SCRIPTS
}

package draggableProof;

my $n = 0;  # number of nestable lists so far

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

# In principle, the styles (for example, color and size of the tiles)
# could be customized for each draggableProof instance. This is why
# each instance receives its own CSS container class.

sub ScriptAndStyles {
  my $self = shift; my $id = $self->{id};
  
  main::POST_HEADER_TEXT(main::MODES(TeX=>"", HTML=><<"  SCRIPT_AND_STYLE"));
    <script type="text/javascript">
      \$(document).ready(function() {
          \$("#nestable-$id-source").nestable({
              group: "$id",
              maxDepth: 1,
              scroll: true,
              callback: _nestableUpdate
          });
          \$("#nestable-$id-source").on('lostItem', _nestableUpdate);
          \$("#nestable-$id-target").nestable({
              group: "$id",
              maxDepth: 1,
              scroll: true,
              callback: _nestableUpdate
          });
          \$("#nestable-$id-target").on('lostItem', _nestableUpdate);
      });
    </script>

    <style type="text/css">
    .nestable-$id-container {
        width: 350px;
        float: left;
        margin: 10px;
        padding: 0;
        color: #000000;
        border:1 px solid #388E8E;
        text-align: center;
    }
    .nestable-label {
        margin: 10px 0 10px 0;
    }
    .dd, .dd-list, .dd-item {
        display: block;
        position: relative;
        list-style: none;
        margin: 0;
        padding: 0;
        min-height: 30px;
    }
    .dd-empty, .dd-handle, .dd-placeholder {
        display: block;
        position: relative;
        margin: 0 10px 10px 10px;
        padding: 4px;
        min-height: 30px;
        -moz-box-sizing: border-box;
        box-sizing: border-box;
    }   
    .dd-handle {
        background: #F5DEB3;
        border: 1px solid #388E8E;
        -webkit-border-radius: 5px;
        border-radius: 5px;
        text-align: center;
    }
    .dd-handle:hover {
        cursor: pointer;
    }
    .dd-placeholder {
        background: #f2fbff;
        border: 1px dashed #b6bcbf;
        -webkit-border-radius: 5px;
        border-radius: 5px;
    }
    .dd-dragel {
        position: absolute;
        pointer-events: none;
        z-index: 9999;
    }
    .dd-dragel > .dd-item .dd-handle {
        margin-top: 0;
    }
    .dd-dragel .dd-handle {
        -webkit-box-shadow: 2px 4px 6px 0 rgba(0,0,0,.1);
        box-shadow: 2px 4px 6px 0 rgba(0,0,0,.1);
        opacity: 0.8;
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

  # Retrieve the previous state of the right column.
  $previous = $main::inputs_ref->{$self->{tgtAns}} || "";
  $previous =~ s/$self->{id}-//g; $self->{previousTarget} = [split(/,/,$previous)];

  # Calculate the complement of the right column.
  my %prevTarget = map {$_ => 1} @{$self->{previousTarget}};
  my @diff = grep {not $prevTarget{$_}} (0..$self->{numProvided}-1);

  # If the previous state of the left column has been saved, use it. (This ensures that the tiles 
  # in the left column are kept in the same order that the user had arranged them). If it has not
  # been saved, use the complement of the right column.
  $previous = $main::inputs_ref->{$self->{srcAns}} || "$self->{id}-".join(",$self->{id}-",@diff);
  $previous =~ s/$self->{id}-//g; $self->{previousSource} = [split(/,/,$previous)];
}

sub Print {
  my $self = shift;

  if ($main::displayMode ne "TeX") { # HTML mode

    return join("\n",
       '<div style="min-width:750px;">',
          $self->Source,
          $self->Target,
       '<br clear="all" />',
      '</div>',
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

    my @lines = ();
    push(@lines, '<div class="nestable-'.$id.'-container">',
      '<div class="nestable-label">'.$label.'</div>',
      '<div class="dd" id="nestable-'.$id.'-'.$name.'" data-ans="'.$ans.'">'
    );
    if (scalar @{$previous} > 0) {
      push(@lines, '<ol class="dd-list">');
      foreach my $i (@{$previous}) {
        push(@lines, '<li class="dd-item" id="'.$id.'-'.$i.'"><div class="dd-handle">'.$self->{lines}[$self->{order}[$i]].'</div></li>');
      }
      push(@lines, '</ol>');
    }
    push(@lines, 
      '</div>',
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
