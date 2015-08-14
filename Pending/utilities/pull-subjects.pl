#!/usr/bin/perl

use File::Find;
use Cwd;

use lib "$ENV{WEBWORK_ROOT}/lib";
use WeBWorK::Utils::Tags;

#do {
#	print "Usage: pull-subjects.pl path/to/main/directory\n";
#	print "       which has subdirectories of Contrib, Pending, etc.";
#	print "       It is best to use an absolute path.";
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

sub procfile {
	my $fn = $_;
	my $fdir = $File::Find::dir;
	my $ndir = cwd();
	return() if($fn !~ /\.pg$/);
	my $tags = WeBWorK::Utils::Tags->new("$fdir/$fn");

	unless ($tags->{Status} and ($tags->{Status} =~ /^[rRaA]$/) and $tags->{DBsubject}) {
		my $reldir = $fdir;
		$reldir =~ s/^(.*webwork-open-problem-library\/+)//;
		my $dirprefix = $1;
		$dirprefix =~ s/\/+$//;
		$reldir =~ s/^Pending\/+//;
		my $dbsub = $tags->{DBsubject};
		$dbsub =~ s/ //g;
		$dbsub = 'NoSubject' if $dbsub eq '';
		unless (-e "$topdir/Pending/set$dbsub.def") {
			open(SDF, ">>$topdir/Pending/set$dbsub.def") or die "Cannot open set def file $topdir/Pending/set$dbsub.def";
			print SDF << 'EOT';
paperHeaderFile=set1/SetHeader.pg
screenHeaderFile=set1/screenHeader.pg 
openDate = 9/9/96 at 9:00  AM         
dueDate = 09/24/96 at 1:00  PM 
answerDate = 09/25/96 at 11:30 PM 

problemList =
EOT
			close(SDF);
		}
		open(SDF, ">>$topdir/Pending/set$dbsub.def") or die "Cannot open set def file $topdir/Pending/set$dbsub.def";
		print SDF "Pending/$reldir/$fn\n";
		close(SDF);
	}
	return;
}

print `rm -f $topdir/Pending/set*.def`;

find({ wanted => \&procfile, follow_fast=>1}, "$topdir/Pending");
chdir $olddir;

print "\nSet definition files printed\n";
