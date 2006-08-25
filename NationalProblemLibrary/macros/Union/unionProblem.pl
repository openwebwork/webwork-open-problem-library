#!/usr/local/bin/perl

sub _unionProblem_init {
  problem_Table();
};

######################################################################
##
##  These routines implement a border and background color for
##  the WeBWorK problem that helps set it off from the rest
##  of the information that is on screen.  It could have been 
##  made part of TEXT(&beginproblem).
##
##  To use these routines, put BEGIN_PROBLEM after the
##  TEXT(&beginproblem), and END_PROBLEM before the ENDDOCUMENT().
##  For those who don't want to have these tables, they can put
##  a problem_NoTable() call in their PGcourse.pl file in
##  templates/macros, which will prevent the tables from being
##  included in any of the problems.
##

##################################################
#
#  Set up the variables needed for the table macros
#  (you can call this directly to specify the colors and sizes
#   of the table).
#
#  Usage:  problem_Table(bd,bw,pd,bgc,bdc)
#
#  where
#
#     bd          gives the BORDER size (depth of the border)
#     bw          gives the CELLSPACING (width of the border)
#     pd          gives the CELLPADDING (space between border and problem)
#     bgc         gives the background color for the problem
#     bdc         gives the border color for the table
#
sub problem_Table {
    my ($bd,$bw,$pd,$bgc,$bdc) = @_;
    $bd = 1 if (!defined($bd) || $bd eq "");
    $bw = 1 if (!defined($bw) || $bw eq "");
    $pd = 15 if (!defined($pd) || $pd eq "");
    $bgc = "#E8E8E8" if (!defined($bgc) || $bgc eq "");
    $bdc = "#AAAAAA" if (!defined($bdc) || $bdc eq "");

    $problem_beginTable =
      "<BLOCKQUOTE>\n".
      "<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 BGCOLOR=$bdc><TR><TD>" .
      "<TABLE BORDER=$bd CELLSPACING=$bw CELLPADDING=$pd BGCOLOR=$bgc>".
      "<TR><TD>";
    $problem_endTable =
      "</TD></TR>\n</TABLE></TD></TR>\n</TABLE>\n".
      "</BLOCKQUOTE>\n";
    $problem_beginTable = "";
}

#
#  Call this to prevent the use of tables.
#
sub problem_NoTable {$problem_beginTable = ""}

##################################################
#
#  Insert the table for the Union problem format
#  (Should follow the TEXT(&beginproblem).)
#
sub BEGIN_PROBLEM {
  return if ($problem_beginTable eq "");
  TEXT(HTML($problem_beginTable));
}

#
#  (Should preceed the ENDDOCUMENT().)
#
sub END_PROBLEM {
  return if ($problem_beginTable eq "");
  TEXT(HTML($problem_endTable));
}

1;
