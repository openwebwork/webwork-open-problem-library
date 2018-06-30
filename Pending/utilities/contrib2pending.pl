#!/usr/bin/perl

use File::Find;
use File::Copy qw(copy);
use Cwd;

use lib "$ENV{WEBWORK_ROOT}/lib";
use WeBWorK::Utils::Tags;

my $rejectfile = "Pending/NotAccepted";

#do {
#	print "Usage: contrib2pending.pl path/to/main/directory\n";
#	print "       which has subdirectories of Contrib, Pending, etc.\n";
#	print "       It is best if the path is absolute.\n";
#	exit;
#} unless scalar(@ARGV);

my $topdir = '/home/jj/webwork/OPL-git/webwork-open-problem-library';
$topdir = $ARGV[0] if scalar(@ARGV);

opendir TOPDIR, $topdir or die "cannot read directory $topdir: $!";
my @allsubs = readdir TOPDIR;
closedir TOPDIR;

# Check to see that we were pointed to the right place
die "Top directory is wrong: " unless grep {$_ eq 'Contrib'} @allsubs;
die "Top directory is wrong: " unless grep {$_ eq 'Pending'} @allsubs;

my $olddir = cwd();
print "Starting in $olddir\n";
chdir $topdir;

my $cnt = 0;

# Read in reject file
my %reject = ();
open(REJ, "<$topdir/$rejectfile") or die "Cannot open reject file $topdir/$rejectfile";
while (my $line=<REJ>) {
	chomp $line;
	#$line =~ s/#.*$//; Cannot use # for comments, it is in some file names!
	$line =~ s/\s*$//;
	$line =~ s/^\s*//;
	#print "Reject line |$line|\n" if ($line =~ /\S/);
	$reject{$line} = 1 if ($line =~ /\S/);
}
close REJ;

sub scanfile {
	my $path = shift;
	# Flags to return
	my ($mo, $essay) = (0,0);
	open(INF, "<$path") or die "Cannot open $path for scanning";
	while(my $line = <INF>) {
		$line =~ s/#.*$//;
		$essay = 1 if $line =~ /essay_cmp/;
		$mo = 1 if $line =~ /->cmp/;
	}
	close(INF);
	#print "$path: $mo and $essay\n";
	return ($mo, $essay);
}


sub procfile {
	my $fn = $_;
	my $fdir = $File::Find::dir;
	my $ndir = cwd();
	return() if($fn !~ /\.pg$/);

	my $reldir = $fdir;
	$reldir =~ s/^(.*$topdir\/+)//;
	my $dirprefix = $1;
	$dirprefix =~ s/\/+$//;
	$reldir =~ s/^Contrib\/+//;

	# already rejected
	return () if (defined($reject{"$reldir/$fn"}));
	# already accepted
	return () if(-f "$dirprefix/OpenProblemLibrary/$reldir/$fn");
	# already in pending
	return () if(-f "$dirprefix/Pending/$reldir/$fn");

	# create directory
	print `mkdir -p $dirprefix/Pending/$reldir`;

	# copy file
	my $fullpath = "$dirprefix/Pending/$reldir/$fn";
	#print "Full $fullpath\n";
	copy "$dirprefix/Contrib/$reldir/$fn", $fullpath;
	#print "copy done\n";

	my ($mo, $essay) = scanfile("$fullpath");
	# warn if essay_cmp since we may need to add a comment to the file
	print "Essay question: $fullpath\n" if $essay;
	# modify tags in file (for MO)
	my $tags = WeBWorK::Utils::Tags->new("$fullpath");
	if($mo) {
		$tags->settag('MO', 1) ;
		$tags->write();
	}
	for my $res (@{$tags->{resources}}) {
		copy "$dirprefix/Contrib/$reldir/$res", "$dirprefix/Pending/$reldir/$res";
		print `git add $dirprefix/Pending/$reldir/$res`;
	}

	# git add file
	print `git add $fullpath`;
	$cnt++;

}

find({ wanted => \&procfile, follow_fast=>1}, "$topdir/Contrib");
chdir $olddir;

print "Added $cnt files\n";
print "\nDon't forget to git commit and push\n";

