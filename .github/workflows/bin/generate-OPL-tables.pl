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

# This script generates the database for the current content of the WeBWorK Open Problem Library (OPL).

use strict;
use warnings;

use File::Basename;
use File::Find;
use DBI;
use JSON;

use lib dirname(__FILE__);
use Tags;

# Taxonomy global variable.
my $taxo = {};

# Data for creating the database tables
my %tables = (
	dbsubject      => 'OPL_DBsubject',
	dbchapter      => 'OPL_DBchapter',
	dbsection      => 'OPL_DBsection',
	author         => 'OPL_author',
	path           => 'OPL_path',
	pgfile         => 'OPL_pgfile',
	keyword        => 'OPL_keyword',
	pgfile_keyword => 'OPL_pgfile_keyword',
	textbook       => 'OPL_textbook',
	chapter        => 'OPL_chapter',
	section        => 'OPL_section',
	problem        => 'OPL_problem',
	morelt         => 'OPL_morelt',
	pgfile_problem => 'OPL_pgfile_problem',
);

die 'ERROR: Port not set' if !defined $ENV{MYSQL_TCP_PORT};

# Get database connection
my $dbh = DBI->connect("DBI:MariaDB:database=OPL;host=127.0.0.1;port=$ENV{MYSQL_TCP_PORT}",
	'opl_user', $ENV{MYSQL_PWD}, { PrintError => 0, RaiseError => 1 });

$dbh->prepare("SET NAMES 'utf8mb4'")->execute();

my $libraryRoot = "$ENV{GITHUB_WORKSPACE}/OpenProblemLibrary";
my $contribRoot = "$ENV{GITHUB_WORKSPACE}/Contrib";

my $verbose = 0;
my $cnt2    = 0;

# auto flush printing
my $old_fh = select(STDOUT);
$| = 1;
select($old_fh);

sub dbug {
	my $msg            = shift;
	my $insignificance = shift || 2;
	print $msg if ($verbose >= $insignificance);
}

my @create_tables = (
	[
		$tables{dbsubject}, '
	DBsubject_id int(15) NOT NULL auto_increment,
	name varchar(245) NOT NULL,
	KEY DBsubject (name),
	PRIMARY KEY (DBsubject_id)'
	],
	[
		$tables{dbchapter}, '
	DBchapter_id int(15) NOT NULL auto_increment,
	name varchar(245) NOT NULL,
	DBsubject_id int(15) DEFAULT 0 NOT NULL,
	KEY DBchapter (name),
	KEY (DBsubject_id),
	PRIMARY KEY (DBchapter_id)'
	],
	[
		$tables{dbsection}, '
	DBsection_id int(15) NOT NULL auto_increment,
	name varchar(245) NOT NULL,
	DBchapter_id int(15) DEFAULT 0 NOT NULL,
	KEY DBsection (name),
	KEY (DBchapter_id),
	PRIMARY KEY (DBsection_id)'
	],
	[
		$tables{author}, '
	author_id int (15) NOT NULL auto_increment,
	institution tinyblob,
	lastname varchar (255) NOT NULL,
	firstname varchar (255) NOT NULL,
	email varchar (255),
	KEY author (lastname(100), firstname(100)),
	PRIMARY KEY (author_id)'
	],
	[
		$tables{path}, '
	path_id int(15) NOT NULL auto_increment,
	path varchar(245) NOT NULL,
	machine varchar(255),
	user varchar(255),
	KEY (path),
	PRIMARY KEY (path_id)'
	],
	[
		$tables{pgfile}, '
	pgfile_id int(15) NOT NULL auto_increment,
	DBsection_id int(15) NOT NULL,
	author_id int(15),
	institution tinyblob,
	libraryroot varchar(255) NOT NULL,
	path_id int(15) NOT NULL,
	filename varchar(255) NOT NULL,
	morelt_id int(127) DEFAULT 0 NOT NULL,
	level int(15),
	language varchar(255),
	static TINYINT,
	MO TINYINT,
	PRIMARY KEY (pgfile_id)'
	],
	[
		$tables{keyword}, '
	keyword_id int(15) NOT NULL auto_increment,
	keyword varchar(245) NOT NULL,
	KEY (keyword),
	PRIMARY KEY (keyword_id)'
	],
	[
		$tables{pgfile_keyword}, '
	pgfile_id int(15) DEFAULT 0 NOT NULL,
	keyword_id int(15) DEFAULT 0 NOT NULL,
	PRIMARY KEY pgfile_keyword (keyword_id, pgfile_id),
	KEY pgfile (pgfile_id)'
	],
	[
		$tables{textbook}, '
	textbook_id int (15) NOT NULL auto_increment,
	title varchar (255) NOT NULL,
	edition int (15) DEFAULT 0 NOT NULL,
	author varchar (255) NOT NULL,
	publisher varchar (255),
	isbn char (15),
	pubdate varchar (255),
	PRIMARY KEY (textbook_id)'
	],
	[
		$tables{chapter}, '
	chapter_id int (15) NOT NULL auto_increment,
	textbook_id int (15),
	number int(3),
	name varchar(245) NOT NULL,
	page int(4),
	KEY (textbook_id, name),
	KEY (number),
	PRIMARY KEY (chapter_id)'
	],
	[
		$tables{section}, '
	section_id int(15) NOT NULL auto_increment,
	chapter_id int (15),
	number int(3),
	name varchar(245) NOT NULL,
	page int(4),
	KEY (chapter_id, name),
	KEY (number),
	PRIMARY KEY section (section_id)'
	],
	[
		$tables{problem}, '
	problem_id int(15) NOT NULL auto_increment,
	section_id int(15),
	number int(4) NOT NULL,
	page int(4),
	#KEY (page, number),
	KEY (section_id),
	PRIMARY KEY (problem_id)'
	],
	[
		$tables{morelt}, '
	morelt_id int(15) NOT NULL auto_increment,
	name varchar(245) NOT NULL,
	DBsection_id int(15),
	leader int(15), # pgfile_id of the MLT leader
	KEY (name),
	PRIMARY KEY (morelt_id)'
	],
	[
		$tables{pgfile_problem}, '
	pgfile_id int(15) DEFAULT 0 NOT NULL,
	problem_id int(15) DEFAULT 0 NOT NULL,
	PRIMARY KEY (pgfile_id, problem_id)'
	]
);

# Reset the database tables.
for my $tableinfo (@create_tables) {
	$dbh->do("DROP TABLE IF EXISTS `$tableinfo->[0]`");
	$dbh->do("CREATE TABLE `$tableinfo->[0]` ($tableinfo->[1]) ENGINE='MYISAM' CHARACTER SET 'utf8mb4'");
}

# From pgfile
## DBchapter('Limits and Derivatives')
## DBsection('Calculating Limits using the Limit Laws')
## Date('6/3/2002')
## Author('Tangan Gao')
## Institution('csulb')
## TitleText1('Calculus Early Transcendentals')
## EditionText1('4')
## AuthorText1('Stewart')
## Section1('2.3')
## Problem1('7')

# Get an id, and add entry to the database if needed
sub safe_get_id {
	my ($tablename, $idname, $whereclause, $wherevalues, $addifnew, @insertvalues) = @_;

	for my $j (0 .. $#insertvalues) {
		$insertvalues[$j] =~ s/"/\\\"/g;
	}

	my $query = "SELECT $idname FROM `$tablename` $whereclause";
	my $sth   = $dbh->prepare($query);
	$sth->execute(@$wherevalues);
	my ($idvalue, @row);
	unless (@row = $sth->fetchrow_array()) {
		return 0 unless $addifnew;
		for my $j (0 .. $#insertvalues) {
			if ($insertvalues[$j] ne '') {
				$insertvalues[$j] = qq{"$insertvalues[$j]"};
			} else {
				$insertvalues[$j] = 'NULL';
			}
		}
		$dbh->do("INSERT INTO `$tablename` VALUES(" . join(',', @insertvalues) . ")");
		dbug "INSERT INTO $tablename VALUES( " . join(',', @insertvalues) . ")\n";
		$sth = $dbh->prepare($query);
		$sth->execute(@$wherevalues);
		@row = $sth->fetchrow_array();
	}
	$idvalue = $row[0];
	return ($idvalue);
}

sub isvalid {
	my $tags = shift;
	if (!defined $taxo->{ $tags->{DBsubject} }) {
		#print "\nInvalid subject $tags->{DBsubject}\n";
		return 0;
	}
	if (!($tags->{DBchapter} eq 'Misc.') && !defined $taxo->{ $tags->{DBsubject} }{ $tags->{DBchapter} }) {
		#print "\nInvalid chapter $tags->{DBchapter}\n";
		return 0;
	}
	if (!($tags->{DBsection} eq 'Misc.')
		&& !defined $taxo->{ $tags->{DBsubject} }{ $tags->{DBchapter} }{ $tags->{DBsection} })
	{
		#print "\nInvalid section $tags->{DBsection}\n";
		return 0;
	}
	return 1;
}

# First read in textbook information
if (open(my $fh, '<:encoding(UTF-8)', "$libraryRoot/Textbooks")) {
	print "Reading in textbook data from Textbooks in the library $libraryRoot.\n";
	my %textinfo = (TitleText => '', EditionText => '', AuthorText => '');
	my $bookid   = undef;
	while (my $line = <$fh>) {
		$line =~ s|#*$||;
		# Should have chapter or section information
		if ($line =~ /^\s*(.*?)\s*>>>\s*(.*?)\s*$/) {
			my $chapsec = $1;
			my $title   = $2;
			if ($chapsec =~ /(\d+)\.(\d+)/) {
				# We have a section
				if (defined $bookid) {
					my $chapid = $dbh->selectrow_array(qq{SELECT chapter_id FROM `$tables{chapter}`
						WHERE textbook_id="$bookid" AND number="$1"});
					if (defined $chapid) {
						my $sectid = safe_get_id(
							$tables{section}, 'section_id',
							qq{WHERE chapter_id = ? and name = ?},
							[ $chapid, $title ],
							1, '', $chapid, $2, $title, ''
						);
					} else {
						print
							"Cannot enter section $chapsec because textbook information is missing the chapter entry\n";
					}
				} else {
					print "Cannot enter section $chapsec because textbook information is incomplete\n";
				}
			} else {    # We have a chapter entry
				if (defined $bookid) {
					my $chapid = safe_get_id(
						$tables{chapter}, 'chapter_id',
						qq(WHERE textbook_id = ? AND number = ?),
						[ $bookid, $chapsec ],
						1, '', $bookid, $chapsec, $title, ''
					);

					# Add dummy section entry for problems tagged to the chapter without a section.
					my $sectid = $dbh->selectrow_array(
						qq{SELECT section_id FROM `$tables{section}` WHERE chapter_id="$chapid" AND number=-1});
					if (!defined $sectid) {
						$dbh->do(qq{INSERT INTO `$tables{section}` VALUES(NULL, "$chapid", "-1", "", NULL)});
						dbug qq{INSERT INTO section VALUES("", "$chapid", "-1", "", "")\n};
					}
				} else {
					print "Cannot enter chapter $chapsec because textbook information is incomplete\n";
				}
			}
		} elsif ($line =~ /^\s*(TitleText|EditionText|AuthorText)\(\s*'(.*?)'\s*\)/) {
			# Textbook information, maybe new
			my $type = $1;
			if (defined $textinfo{$type}) {    # signals new text
				%textinfo        = (TitleText => undef, EditionText => undef, AuthorText => undef);
				$textinfo{$type} = $2;
				$bookid          = undef;
			} else {
				$textinfo{$type} = $2;
				if (defined $textinfo{TitleText} && defined $textinfo{AuthorText} && defined $textinfo{EditionText}) {
					my $query = qq{SELECT textbook_id FROM `$tables{textbook}` WHERE title = "$textinfo{TitleText}"
						AND edition = "$textinfo{EditionText}" AND author="$textinfo{AuthorText}"};
					$bookid = $dbh->selectrow_array($query);
					if (!defined $bookid) {
						$dbh->do(qq{INSERT INTO `$tables{textbook}` VALUES(NULL, "$textinfo{TitleText}",
								"$textinfo{EditionText}", "$textinfo{AuthorText}", NULL, NULL, NULL)}
						);
						dbug qq{INSERT INTO textbook VALUES("", "$textinfo{TitleText}", "$textinfo{EditionText}",
							"$textinfo{AuthorText}", "", "", "")};
						$bookid = $dbh->selectrow_array($query);
					}
				}
			}
		}
	}
	close($fh);
}

# Next read in the taxonomy
my $clsep   = '<<<';
my $clinner = '__';
my @cllist  = ();
# Record full taxonomy for tagging menus (does not include cross-lists)
my $tagtaxo = [];
my ($chaplist, $seclist) = ([], []);

my $fh;
if (open($fh, '<:encoding(UTF-8)', "$libraryRoot/Taxonomy2")) {
	print "Reading in OPL taxonomy from Taxonomy2 in the library $libraryRoot.\n";
} elsif (open($fh, '<:encoding(UTF-8)', "$libraryRoot/Taxonomy")) {
	print "Reading in OPL taxonomy from Taxonomy in the library $libraryRoot.\n";
} else {
	print "Taxonomy file was not found in library $libraryRoot. If the path to the problem library doesn't seem
	correct, make modifications in webwork2/conf/site.conf (\$problemLibrary{root}).  If that is correct then
	updating from git should download the Taxonomy file.\n";
}

# Taxonomy is a subset of Taxonomy2, so we can use the same code either way
if ($fh) {
	my ($cursub, $curchap);      # these are strings
	my ($subj, $chap, $sect);    # these are indices
	while (my $line = <$fh>) {
		$line =~ /^(\t*)/;
		my $count = length($1);
		my $oktag = 1;
		chomp($line);
		if ($line =~ m/$clsep/) {
			$oktag = 0;
			my @cross = split $clsep, $line;
			@cross = map(trim($_), @cross);
			if (scalar(@cross) > 1) {
				push @cllist, [ join($clinner, ($cursub, $curchap, $cross[0])), $cross[1] ];
			}
			$line = $cross[0];
		}
		$line = trim($line);

		# We put the line in the database in all cases
		# but crosslists are not put in the heierarchy of legal tags
		# instead they go in a list of crosslists to deal with after
		# the full taxonomy is read in
		if ($count == 0) {
			#DBsubject
			$cursub = $line;
			if ($oktag) {
				$taxo->{$line} = {};
				($chaplist, $seclist) = ([], []);
				push @{$tagtaxo}, { name => $line, subfields => $chaplist };
			}
			$subj = safe_get_id($tables{dbsubject}, 'DBsubject_id', qq(WHERE name = ?), [$line], 1, '', $line);
		} elsif ($count == 1) {
			#DBchapter
			if ($oktag) {
				$taxo->{$cursub}->{$line} = {};
				$seclist = [];
				push @{$chaplist}, { name => $line, subfields => $seclist };
			}
			$curchap = $line;
			$chap    = safe_get_id(
				$tables{dbchapter}, 'DBchapter_id',
				qq(WHERE name = ? and DBsubject_id = ?),
				[ $line, $subj ],
				1, '', $line, $subj
			);
		} else {
			#DBsection
			if ($oktag) {
				$taxo->{$cursub}->{$curchap}->{$line} = [];
				push @{$seclist}, { name => $line };
			}
			$sect = safe_get_id(
				$tables{dbsection}, 'DBsection_id',
				qq(WHERE name = ? and DBchapter_id = ?),
				[ $line, $chap ],
				1, '', $line, $chap
			);
		}
	}
	close($fh);
}

# Directory to hold the json files.
my $dataDir = "$ENV{GITHUB_WORKSPACE}/webwork-open-problem-library/JSON-SAVED";
`mkdir -p $dataDir` if !-d $dataDir;

# Save the official taxonomy in json format
my $file = "$dataDir/tagging-taxonomy.json";
open my $taxo_fh, '>', $file or die "Cannot open $file";
print $taxo_fh JSON->new->utf8->encode($tagtaxo);
close $taxo_fh;

print "Saved taxonomy to $file.\n";

# Now deal with cross-listed sections
for my $clinfo (@cllist) {
	my @scs = split /$clinner/, $clinfo->[1];
	if (defined $taxo->{ $scs[0] }->{ $scs[1] }->{ $scs[2] }) {
		push @{ $taxo->{ $scs[0] }->{ $scs[1] }->{ $scs[2] } }, $clinfo->[0];
	} else {
		print "Faulty cross-list: pointing to $scs[0] / $scs[1] / $scs[2]\n";
	}
}

print "Converting data from tagged pgfiles into mysql.\n";
print "Number of files processed:\n";

# Now search for tagged problems
File::Find::find( { wanted => \&pgfiles, follow_fast => 1 }, $libraryRoot );
File::Find::find( { wanted => \&pgfiles, follow_fast => 1 }, $contribRoot );

sub trim {
	return shift =~ s/^\s+|\s+$//gr;
}

sub kwtidy {
	my $s = shift;
	$s =~ s/\W//g;
	$s =~ s/_//g;
	$s = lc($s);
	return ($s);
}

sub keywordcleaner {
	my $string = shift;
	my @spl1   = split /,/, $string;
	my @spl2   = map { kwtidy($_) } @spl1;
	return (@spl2);
}

# Save on passing these values around
my %textinfo;

# Initialize, if needed more text-info information;
sub maybenewtext {
	my $textno = shift;
	return if defined $textinfo{$textno};
	# So, not defined yet
	$textinfo{$textno} = { title => '', author => '', edition => '', section => '', chapter => '', problems => [] };
}

# Process each file returned by the find command.
sub pgfiles {
	my $name = $File::Find::name;
	my ($text, $edition, $textauthor, $textsection, $textproblem);
	%textinfo = ();
	my @textproblems = (-1);

	if ($name =~ /\.pg$/) {
		++$cnt2;
		printf('%6d', $cnt2) if ($cnt2 % 100) == 0;
		print "\n"           if ($cnt2 % 1000) == 0;

		my $pgfile = basename($name);
		my $pgpath = dirname($name);
		$pgpath =~ s|^$libraryRoot|Library|;
		$pgpath =~ s|^$contribRoot|Contrib|;
		$pgpath =~ m|^([^/]*)/(.*)|;
		my ($pglib, $pgpath) = ($1, $2);

		my $tags = Tags->new($name);

		if ($tags->istagged()) {
			# Fill in missing data with Misc. instead of blank
			#print "\nNO SUBJECT $name\n" unless ($tags->{DBsubject} =~ /\S/);

			$tags->{DBsubject} = 'Misc.' unless $tags->{DBchapter} =~ /\S/;
			$tags->{DBchapter} = 'Misc.' unless $tags->{DBchapter} =~ /\S/;
			$tags->{DBsection} = 'Misc.' unless $tags->{DBsection} =~ /\S/;

			my $aDBsection_id;

			# DBsubject table
			if (isvalid($tags)) {
				my $DBsubject_id = safe_get_id(
					$tables{dbsubject}, 'DBsubject_id',
					qq(WHERE BINARY name = ?),
					[ $tags->{DBsubject} ],
					1, '', $tags->{DBsubject}
				);
				if (not $DBsubject_id) {
					print "\nInvalid subject '$tags->{DBsubject}' in $name\n";
					return;
				}

				# DBchapter table
				my $DBchapter_id = safe_get_id(
					$tables{dbchapter}, 'DBchapter_id',
					qq(WHERE BINARY name = ? and DBsubject_id = ?),
					[ $tags->{DBchapter}, $DBsubject_id ],
					1, '', $tags->{DBchapter}, $DBsubject_id
				);
				if (not $DBchapter_id) {
					print "\nInvalid chapter '$tags->{DBchapter}' in $name\n";
					return;
				}

				# DBsection table
				$aDBsection_id = safe_get_id(
					$tables{dbsection}, 'DBsection_id',
					qq(WHERE BINARY name = ? and DBchapter_id = ?),
					[ $tags->{DBsection}, $DBchapter_id ],
					1, '', $tags->{DBsection}, $DBchapter_id
				);
				if (!$aDBsection_id) {
					print "\nInvalid section '$tags->{DBsection}' in $name\n";
					return;
				}
			} else {
				# Tags are not valid, error printed by validation part.
				#print "File $name\n";
				return; # next is not valid for subs
			}

			my @DBsection_ids = ($aDBsection_id);
			# Now add crosslisted section
			my @CL_array = @{ $taxo->{ $tags->{DBsubject} }{ $tags->{DBchapter} }{ $tags->{DBsection} } // [] };
			for my $clsect (@CL_array) {
				my @np = map { trim($_) } split /$clinner/, $clsect;
				my $new_dbsubj_id =
					safe_get_id($tables{dbsubject}, 'DBsubject_id', qq(WHERE name = ?), [ $np[0] ], 1, '', $np[0]);
				my $new_dbchap_id = safe_get_id(
					$tables{dbchapter}, 'DBchapter_id',
					qq(WHERE name = ? and DBsubject_id = ?),
					[ $np[1], $new_dbsubj_id ],
					1, '', $np[1], $new_dbsubj_id
				);
				my $new_dbsect_id = safe_get_id(
					$tables{dbsection}, 'DBsection_id',
					qq(WHERE name = ? and DBchapter_id = ?),
					[ $np[2], $new_dbchap_id ],
					1, '', $np[2], $new_dbchap_id
				);
				push @DBsection_ids, $new_dbsect_id;
			}

			# author table

			my $author_id = 0;
			if ($tags->{Author} =~ /(.*?)\s(\w+)\s*$/) {
				my $firstname = $1;
				my $lastname  = $2;
				# Remove leading and trailing spaces from firstname, which includes any middle name too.
				$firstname =~ s/^\s*|\s*$//g;
				$lastname  =~ s/^\s*|\s*$//g;

				if ($lastname) {
					$author_id = safe_get_id(
						$tables{author}, 'author_id',
						qq(WHERE lastname = ? AND firstname = ?),
						[ $lastname, $firstname ],
						1, '', $tags->{Institution}, $lastname, $firstname, ''
					);
				}
			}

			# path table

			my $path_id = safe_get_id($tables{path}, 'path_id', qq(WHERE path = ?), [$pgpath], 1, '', $pgpath, '', '');

			# pgfile table -- set 4 defaults first
			my $level   = ($tags->{Level} =~ /\d/) ? $tags->{Level} : 0;
			my $lang    = $tags->{Language} || 'en';
			my $mathobj = $tags->{MO}       || 0;
			my $static  = $tags->{Static}   || 0;


			# TODO this is where we have to deal with crosslists, and pgfileid will be an array of id's
			# Make an array of DBsection-id's above
			my @pgfile_ids;
			for my $DBsection_id (@DBsection_ids) {
				my $pgfile_id = safe_get_id(
					$tables{pgfile}, 'pgfile_id',
					qq(WHERE filename = ? AND path_id = ? AND DBsection_id = ? AND libraryroot = ?),
					[ $pgfile, $path_id, $DBsection_id, $pglib ], 1, '', $DBsection_id, $author_id, $tags->{Institution},
					$pglib, $path_id, $pgfile, 0, $level, $lang, $static, $mathobj
				);
				push @pgfile_ids, $pgfile_id;
			}

			# morelt table

			my $morelt_id;
			if ($tags->{MLT}) {
				for my $DBsection_id (@DBsection_ids) {
					$morelt_id = safe_get_id(
						$tables{morelt}, 'morelt_id', qq(WHERE name = ?), [ $tags->{MLT} ],
						1,               '',          $tags->{MLT},       $DBsection_id,
						''
					);

					for my $pgfile_id (@pgfile_ids) {
						$dbh->do(qq{UPDATE `$tables{pgfile}` SET morelt_id="$morelt_id" WHERE pgfile_id="$pgfile_id"});

						dbug "UPDATE pgfile morelt_id for $pgfile_id to $morelt_id\n";
						if ($tags->{MLTleader}) {
							$dbh->do(qq{UPDATE `$tables{morelt}` SET leader="$pgfile_id" WHERE morelt_id="$morelt_id"});
							dbug "UPDATE morelt leader for $morelt_id to $pgfile_id\n";
						}
					}
				}
			}

			# keyword table, and problem_keyword many-many table

			foreach my $keyword (@{ $tags->{keywords} }) {
				$keyword =~ s/[\'\"]//g;
				$keyword = kwtidy($keyword);
				# skip it if it is empty
				next unless $keyword;
				my $keyword_id =
					safe_get_id($tables{keyword}, 'keyword_id', qq(WHERE keyword = ?), [$keyword], 1, '', $keyword);

				for my $pgfile_id (@pgfile_ids) {
					my $ok = $dbh->selectrow_array(qq{SELECT pgfile_id FROM `$tables{pgfile_keyword}`
						WHERE keyword_id="$keyword_id" and pgfile_id="$pgfile_id"});
					if (!defined($ok)) {
						$dbh->do(
							"INSERT INTO `$tables{pgfile_keyword}`
							VALUES(
								\"$pgfile_id\",
								\"$keyword_id\"
							)"
						);
						dbug qq{INSERT INTO pgfile_keyword VALUES("$pgfile_id", "$keyword_id")\n};
					}
				}
			}

			# Textbook section
			# problem table contains textbook problems

			for my $texthashref (@{ $tags->{textinfo} }) {
				# textbook table
				$text    = $texthashref->{TitleText};
				$edition = $texthashref->{EditionText} || 0;
				$edition =~ s/[^\d\.]//g;
				$textauthor = $texthashref->{AuthorText};
				next unless ($text && $textauthor);
				my $chapnum           = $texthashref->{chapter} || -1;
				my $secnum            = $texthashref->{section} || -1;
				my $textbook_id_query = qq{SELECT textbook_id FROM `$tables{textbook}`
					WHERE title="$text" AND edition="$edition" AND author="$textauthor"};
				my $textbook_id = $dbh->selectrow_array($textbook_id_query);

				if (!defined($textbook_id)) {
					# make sure edition is an integer
					$edition = 0 unless $edition;
					$dbh->do(qq{INSERT INTO `$tables{textbook}`
						VALUES( NULL, "$text", "$edition", "$textauthor", NULL, NULL, NULL)});
					$textbook_id = $dbh->selectrow_array($textbook_id_query);
					unless ($textbook_id) {
						warn qq{INSERT INTO textbook VALUES("", "$text", "$edition", "$textauthor", "", "", "")\n};
						warn qq{\nLate add into $tables{textbook} "$text", "$edition", "$textauthor"\n};
					}
				}

				# chapter weak table of textbook
				my $chapter_id_query = qq{SELECT chapter_id FROM `$tables{chapter}`
					WHERE textbook_id="$textbook_id" AND number="$chapnum"};
				my $chapter_id = $dbh->selectrow_array($chapter_id_query);
				if (!defined($chapter_id) && defined($textbook_id)) {
					$dbh->do(qq{INSERT INTO `$tables{chapter}`
						VALUES(NULL, "$textbook_id", "$chapnum", "$tags->{DBchapter}", NULL)});
					dbug qq{\nLate add into $tables{chapter} "$text", "$edition",
					   	"$textauthor", $chapnum $tags->{DBchapter} from $name\n}, 1;
					dbug qq{INSERT INTO chapter VALUES("", "$textbook_id", "$chapnum", "$tags->{DBchapter}", NULL)\n};
					$chapter_id = $dbh->selectrow_array($chapter_id_query);
				}

				# section weak table of textbook
				$tags->{DBsection} = '' if ($secnum < 0);
				my $section_id_query = qq{SELECT section_id FROM `$tables{section}`
					WHERE chapter_id="$chapter_id" AND number="$secnum"};
				my $section_id = $dbh->selectrow_array($section_id_query);
				if (!defined($section_id) && defined($chapter_id) && defined($textbook_id)) {
					$dbh->do(qq{INSERT INTO `$tables{section}`
						VALUES(NULL, "$chapter_id", "$secnum", "$tags->{DBsection}", NULL)});
					dbug qq{INSERT INTO section VALUES("", "$textbook_id", "$secnum", "$tags->{DBsection}", "" )\n};
					dbug qq{\nLate add into $tables{section} "$text", "$edition", "$textauthor",
						$secnum $tags->{DBsection} from $name\n}, 1;
					$section_id = $dbh->selectrow_array($section_id_query);
				}

				@textproblems = @{ $texthashref->{problems} };
				if ($section_id) {
					for my $tp (@textproblems) {
						my $problem_id_query = qq{SELECT problem_id FROM `$tables{problem}`
							WHERE section_id="$section_id" AND number="$tp"};
						my $problem_id = $dbh->selectrow_array($problem_id_query);
						if (!defined($problem_id)) {
							$dbh->do(qq{INSERT INTO `$tables{problem}` VALUES(NULL, "$section_id", "$tp", NULL)});
							dbug qq{INSERT INTO problem VALUES("", "$section_id", "$tp", "")\n};
							$problem_id = $dbh->selectrow_array($problem_id_query);
						}

						# pgfile_problem table associates pgfiles with textbook problems
						for my $pgfile_id (@pgfile_ids) {
							my $pg_problem_id = $dbh->selectrow_array(qq{SELECT problem_id FROM `$tables{pgfile_problem}`
								WHERE problem_id="$problem_id" AND pgfile_id="$pgfile_id"});
							if (!defined($pg_problem_id)) {
								$dbh->do(qq{INSERT INTO `$tables{pgfile_problem}` VALUES("$pgfile_id", "$problem_id")});
								dbug qq{INSERT INTO pgfile_problem VALUES("$pgfile_id", "$problem_id")\n};
							}
						}
					}
				}

				# Reset tag vars, they may not match the next text/file.
				$textauthor  = '';
				$textsection = '';
			}
		}
	}
}

print "\n\n";

my $dbsects = $dbh->selectall_arrayref("SELECT DBsection_id from `$tables{dbsection}`");
for my $sect (@{$dbsects}) {
	$sect = $sect->[0];
	my $srar = $dbh->selectall_arrayref("SELECT * FROM `$tables{pgfile}` WHERE DBsection_id=$sect");
	if (scalar(@{$srar}) == 0) {
		$dbh->do("DELETE FROM `$tables{dbsection}` WHERE DBsection_id=$sect");
	}
}

my $dbchaps = $dbh->selectall_arrayref("SELECT DBchapter_id from `$tables{dbchapter}`");
for my $chap (@{$dbchaps}) {
	$chap = $chap->[0];
	my $srar = $dbh->selectall_arrayref("SELECT * FROM `$tables{dbsection}` WHERE DBchapter_id=$chap");
	if (scalar(@{$srar}) == 0) {
		$dbh->do("DELETE FROM `$tables{dbchapter}` WHERE DBchapter_id=$chap");
	}
}

$dbh->disconnect;

# Dump the database to a file.
my $tablesDir = "$ENV{GITHUB_WORKSPACE}/webwork-open-problem-library/TABLE-DUMP";
`mkdir -p $tablesDir` if !-d $tablesDir;

my $OPL_tables_to_dump =
	'OPL_DBsubject OPL_DBchapter OPL_DBsection OPL_author OPL_path OPL_pgfile OPL_keyword OPL_pgfile_keyword '
	. 'OPL_textbook OPL_chapter OPL_section OPL_problem OPL_morelt OPL_pgfile_problem';

my $cmd = '/usr/bin/mysqldump --user=opl_user --host=127.0.0.1 --default-character-set=utf8mb4 '
	. "--column-statistics=0 OPL $OPL_tables_to_dump > $tablesDir/OPL-tables.sql";

`$cmd`;

print "\nDone.\n";
