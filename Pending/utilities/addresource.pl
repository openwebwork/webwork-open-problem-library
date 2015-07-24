#!/usr/bin/perl

use lib "$ENV{WEBWORK_ROOT}/lib";
use WeBWorK::Utils::Tags;

do {
	print "Usage: addresource.pl pgfile resourcefile\n";
	print "       where the path to the resource file is relative to the pgfile\n";
	exit;
} unless scalar(@ARGV)==2;

my $pgfile = $ARGV[0];

my $tags = WeBWorK::Utils::Tags->new("$pgfile");
$tags->addresource($ARGV[1]) ;
$tags->write();

