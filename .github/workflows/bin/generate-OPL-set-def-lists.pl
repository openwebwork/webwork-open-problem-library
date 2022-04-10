#!/usr/bin/env perl
################################################################################
# WeBWorK Online Homework Delivery System
# Copyright &copy; 2000-2022 The WeBWorK Project, https://github.com/openwebwork
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of either: (a) the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version, or (b) the "Artistic License" which comes with this package.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See either the GNU General Public License or the
# Artistic License for more details.
################################################################################

use strict;
use warnings;

use File::Find;
use JSON;

my $libraryRoot = "$ENV{GITHUB_WORKSPACE}/OpenProblemLibrary";
my $contribRoot = "$ENV{GITHUB_WORKSPACE}/Contrib";

# Search the OPL directory for set definition files.
my @opl_set_defs;
find(
	{
		wanted => sub {
			push @opl_set_defs, $_ =~ s|^$libraryRoot/?|Library/|r if m|/set[^/]*\.def$|;
		},
		follow_fast => 1,
		no_chdir    => 1
	},
	$libraryRoot
);

# Search the Contrib directory for set definition files.
my @contrib_set_defs;
find(
	{
		wanted => sub {
			push @contrib_set_defs, $_ =~ s|^$contribRoot/?|Contrib/|r if m|/set[^/]*\.def$|;
		},
		follow_fast => 1,
		no_chdir    => 1
	},
	$contribRoot
);

sub depth_then_iname_sort {
	my $file_list = shift;
	my @file_depths;
	my @uc_file_names;
	for (@$file_list) {
		push @file_depths,   scalar(@{ [ $_ =~ /\//g ] });
		push @uc_file_names, uc($_);
	}
	@$file_list =
		@$file_list[ sort { $file_depths[$a] <=> $file_depths[$b] || $uc_file_names[$a] cmp $uc_file_names[$b] }
		0 .. $#$file_list ];
}

# Sort the files first by depth then by path.
depth_then_iname_sort(\@opl_set_defs);
depth_then_iname_sort(\@contrib_set_defs);

sub writeJSONtoFile {
	my ($data, $filename) = @_;

	open my $fh, ">", $filename or die "Cannot open $filename";
	print $fh JSON->new->utf8->encode($data);
	close $fh;
}

# Directory to hold the json files.
my $dataDir = "$ENV{GITHUB_WORKSPACE}/webwork-open-problem-library/JSON-SAVED";
`mkdir -p $dataDir` if !-d $dataDir;

# Write the lists to the files in ./DATA.
writeJSONtoFile(\@opl_set_defs,     "$dataDir/library-set-defs.json");
writeJSONtoFile(\@contrib_set_defs, "$dataDir/contrib-set-defs.json");

print 'Set definition list generation complete.';
