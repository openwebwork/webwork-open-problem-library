#!/usr/bin/perl

# Problem library must be in Library
# This shortens all pointer chains to have length 1

use File::Slurp;
use File::Find;

$max = 0;

sub ispointer {
  my $fn = shift;
  #print "reading $fn\n";
  $text = read_file($fn);
  if($text =~ /is just a pointer/ and $text =~ /ZZZ-Inserted Text/ 
	and $text =~ /includePGproblem\((.*)\)/) {
	return $1;
  }
  return '';
}

sub findendpoint {
  my $start = shift;
  my $count =0;
  my $cur = $start;
  while ($node=ispointer($cur)) {
	$node =~ s/["']//g;
    $count++;
	#print "$node\n";
	$cur=$node;
  }
  return [$cur, $count];
}

sub newendpoint {
  my $start = shift;
  my $end1 = shift;
  my $newend = shift;
  #print "Trying $fn\n";
  $text = read_file($start);
  my $node = ispointer($start);
  my ($val, $cnt) = @{$node};
  $text =~ s/$end1/"$newend"/g;
  open(OUTF, ">$start");
  print OUTF $text;
  close(OUTF);
}

sub wanted {
  my $fn = $_;
  my $fdir = $File::Find::dir;
  return() if($fn !~ /\.pg$/);
  #print "|$fdir|  |$fn|\n";
  my $end1;
  return() unless  $end1=ispointer($fn);

  my $res = findendpoint($fn);
  return unless($res->[1]>1);
  newendpoint($fn, $end1, $res->[0]);
  $max = $res->[1] if($res->[1]>$max);
}

find({ wanted => \&wanted, follow_fast=>1, no_chdir=>1}, "Library");

#ispointer($ARGV[0]);
#print findendpoint($ARGV[0]);
#print "\n";

print "\nMax $max\n";
