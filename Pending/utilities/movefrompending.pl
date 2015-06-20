#!/usr/bin/perl

use File::Find;
use Cwd;

use lib "$ENV{WEBWORK_ROOT}/lib";
use WeBWorK::Utils::Tags;

my $rejectfile = "Pending/NotAccepted";

do {
	print "Usage: movefrompending.pl path/to/main/directory\n";
	print "       which has subdirectories of Contrib, Pending, etc.";
	print "       It is best to use an absolute path.";
	exit;
} unless scalar(@ARGV);

my $topdir = $ARGV[0];
opendir TOPDIR, $topdir or die "cannot read directory $topdir: $!";
my @allsubs = readdir TOPDIR;
closedir TOPDIR;

# Check to see that we were pointed to the right place
die "Top directory is wrong: " unless grep {$_ eq 'Contrib'} @allsubs;
die "Top directory is wrong: " unless grep {$_ eq 'Pending'} @allsubs;

my $olddir = cwd();
print "Starting in $olddir\n";
chdir $topdir;

sub procfile {
	my $fn = $_;
	my $fdir = $File::Find::dir;
	my $ndir = cwd();
	return() if($fn !~ /\.pg$/);
	#print "Found $fdir / $fn\n";
	my $tags = WeBWorK::Utils::Tags->new("$fdir/$fn");
	return unless $tags->{Status};
	
	my $reldir = $fdir;
	$reldir =~ s/^(.*webwork-open-problem-library\/+)//;
	my $dirprefix = $1;
	$dirprefix =~ s/\/+$//;
	$reldir =~ s/^Pending\/+//;
	if($tags->{Status} =~ /^[rR]$/) { #reject
		open(REJ, ">>$topdir/$rejectfile") or die "Cannot open reject file $topdir/$rejectfile";
		print REJ "$reldir/$fn\n";
		close REJ;
		# remove file
		#system("git rm $fdir/$fn") or die "Cannot remove file $fdir/$fn ";
		print `git rm $fdir/$fn`;
		print "$fn REJECTED $tags->{Status}\n";

	}
	if($tags->{Status} =~ /^[aA]$/) { #accept
		#print "$fdir/$fn ACCEPT $tags->{Status}\n";
		print `mkdir -p $dirprefix/OpenProblemLibrary/$reldir`;
		#print "mkdir  $dirprefix/OpenProblemLibrary/$reldir\n";
		#print "A: $fdir/$fn\n";
		#print "B: $dirprefix OpenProblemLibrary $reldir $fn\n";
		$tags->settag('Status', 0, 1);
		$tags->write();
		print `git mv $dirprefix/Pending/$reldir/$fn $dirprefix/OpenProblemLibrary/$reldir/$fn`;
		for my $res (@{$tags->{resources}}) {
			print `git mv $dirprefix/Pending/$reldir/$res $dirprefix/OpenProblemLibrary/$reldir/$res`;
			print "Moved $reldir/$res\n";
		}

		#print "$reldir\n";
		#print "Prefix $dirprefix\n";
		#print "$dirprefix/OpenProblemLibrary/$reldir \n";
	}
	if($tags->{Status} =~ /^[nN]$/) { # needs resources, just print a message
		print "$fdir/$fn is missing a resource\n";
	}
	#print "Got $fn and $fdir\n";
}

find({ wanted => \&procfile, follow_fast=>1}, "$topdir/Pending");
chdir $olddir;

print "\nDon't forget to git commit and push\n";
