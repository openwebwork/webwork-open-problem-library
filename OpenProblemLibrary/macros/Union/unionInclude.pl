######################################################################
#
#  Routines to make it easier to include additional PG files within
#  a given one.  These files don't have to be in the courseScripts
#  directory; rather, they are assumed to be relative to the directory
#  containing the calling PG file.
#

sub _unionInclude_init {}; # don't reload this file

######################################################################
#
#  Usage:  includePGfile(name)
#
#  where name is the name of a PG file (relative to the directory
#  of the file containing this call).
#
sub includePGfile {
  my $name = shift;
  my $PGfile = $main::envir{'fileName'};
  $PGfile =~ s![^/]+$!!; $PGfile .= $name;
  while ($PGfile =~ s![^/]*/../!!) {}
  $PGfile =~ s!^tmpEdit/!!;
#  warn("file is $PGfile, directory is $main::templateDirectory");
  my $problem = read_whole_problem_file($main::templateDirectory.$PGfile);

  my ($oldpname,$oldname) = 
     ($main::envir{'probFileName'},$main::envir{'fileName'});
  $main::envir{'probFileName'} = $PGfile;
  $main::envir{'fileName'} = $PGfile;
  includePGtext($problem,%main::envir);
  ($main::envir{'probFileName'},$main::envir{'fileName'}) =
     ($oldpname,$oldname);
}

######################################################################
#
#
#  Usage:  includeRandomProblem(file1,file2,...,fileN);
#
#  where the fileNs are the names of the files from which
#  to choose (relative to the directory of the file containing
#  this call).
#
#  To use this, make one PG file that include the call to this
#  random routine, and then include it the set definition file
#  as many times as you want (up to N times).  A different problem
#  will be included for each instance in the set definition file.
#
sub includeRandomProblem {
  my @flist = @_;
  my @shuffle = _NchooseK(scalar(@flist),scalar(@flist));
  my $start = $initialProblemNumber; $start = 1 unless defined $start;
  WARN_MESSAGE("There is an error in initializing this random problem. initialProblemNumber $start is greater than the current problem number $probNum")
     if $probNum-$start < 0 ;
  my $n = (@shuffle)[$probNum-$start];
  includePGfile($flist[$n]);
  #$main::problemPostamble->{HTML} = "";  # Hack to prevent ENDDOCUMENT from adding it again
                                          # commenting this out is another hack which prevents nesting on quizzes -- go figure
}

#
#  Legacy code no longer needed.  The included file can contain
#  BEGIN_INCLUSION(); and END_INCLUSION(); in place of DOCUMENT()
#  and ENDDOCUMENT(); calls.
#
sub BEGIN_INCLUSION {}
sub END_INCLUSION {}

######################################################################
#
#  This is a service routine for includeRandomProblem() above.
#  It an array of k numbers chosen from 0 to n-1, but preserves the
#  random seed so that the included problem won't be affected by
#  this function, and replaces it by the psvn, so that the list
#  produced will be the same each time it is called.
#
sub _NchooseK {
  my ($n,$k)=@_;
  my @array = 0..($n-1);
  my @out = ();
  my $seed = ($main::psvn || 23)*101 + ($initialProblemNumber || 1);
  my $oldseed = $main::PG_random_generator->{seed};
  $main::PG_random_generator->srand($seed);
  while (@out<$k) {
    push(@out,
         splice(@array,$main::PG_random_generator->random(0,$#array,1),1));
  }
  $main::PG_random_generator->srand($oldseed);
  return @out;
}

1;
