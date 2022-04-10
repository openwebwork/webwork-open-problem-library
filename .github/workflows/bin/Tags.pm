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

package Tags;
use base qw(Exporter);

use strict;
use warnings;

use Carp;
use IO::File;

our @EXPORT    = ();
our @EXPORT_OK = qw();

use constant BASIC =>
	qw(DBsubject DBchapter DBsection Date Institution Author MLT MLTleader Level Language Static MO Status);
use constant NUMBERED => qw(TitleText AuthorText EditionText Section Problem);

# KEYWORDS and RESOURCES are treated specially since each takes a list of values

my $basics   = join('|', BASIC);
my $re       = qr/#\s*\b($basics)\s*\(\s*'?(.*?)'?\s*\)\s*$/;

sub keywordcleaner {
	my $string = shift;
	my @spl1   = split /,/, $string;
	return (@spl1);
}

# Set a tag with a value
sub maybenewtext {
	my $textno   = shift;
	my $textinfo = shift;
	return $textinfo if defined($textinfo->[ $textno - 1 ]);

	$textinfo->[ $textno - 1 ] = {
		TitleText   => '',
		AuthorText  => '',
		EditionText => '',
		section     => '',
		chapter     => '',
		problems    => []
	};
	return $textinfo;
}

sub gettextnos {
	my $textinfo = shift;
	return grep { defined $textinfo->[$_] } (0 .. (scalar(@{$textinfo}) - 1));
}

sub tidytextinfo {
	my $self    = shift;
	my @textnos = gettextnos($self->{textinfo});
	my $ntxts   = scalar(@textnos);
	if ($ntxts and ($ntxts - 1) != $textnos[-1]) {
		$self->{modified} = 1;
		my @tmptexts = grep { defined $_ } @{ $self->{textinfo} };
		$self->{textinfo} = \@tmptexts;
	}
}

# name is a path
sub new {
	my $class = shift;
	my $name  = shift;
	my $self  = {};

	$self->{isplaceholder} = 0;
	$self->{modified}      = 0;
	my $lasttag = 1;

	my ($text, $edition, $textauthor, $textsection, $textproblem);
	my $textno;
	my $textinfo = [];

	open(IN, '<:encoding(UTF-8)', "$name") or die "can not open $name: $!";
	if ($name !~ /pg$/ && $name !~ /\.pg\.[-a-zA-Z0-9_.@]*\.tmp$/) {
		warn "Not a pg file";    #print caused trouble with XMLRPC
		$self->{file} = undef;
		bless($self, $class);
		return $self;
	}
	my $lineno = 0;
	$self->{file} = $name;

	# Initialize some values
	for my $tagname (BASIC) {
		$self->{$tagname} = '';
	}
	$self->{keywords}  = [];
	$self->{resources} = [];

	while (<IN>) {
		$lineno++;
		eval {
		SWITCH: {
				if (/#\s*\bKEYWORDS\((.*)\)/i) {

					my @keyword = keywordcleaner($1);
					@keyword          = grep { not /^\s*'?\s*'?\s*$/ } @keyword;
					$self->{keywords} = [@keyword];
					$lasttag          = $lineno;
					last SWITCH;
				}
				if (/#\s*\bRESOURCES\((.*)\)/i) {
					my @resc = keywordcleaner($1);
					s/["'\s]*$//g for (@resc);
					s/^["'\s]*//g for (@resc);
					@resc              = grep { not /^\s*'?\s*'?\s*$/ } @resc;
					$self->{resources} = [@resc];
					$lasttag           = $lineno;
					last SWITCH;
				}
				if (/$re/) {    # Checks all other un-numbered tags
					my $tmp1 = $1;
					my $tmp  = $2;
					$tmp =~ s/\s+$//;
					$tmp =~ s/^\s+//;
					$self->{$tmp1} = $tmp;
					$lasttag = $lineno;
					last SWITCH;
				}

				if (/#\s*\bTitleText(\d+)\(\s*'?(.*?)'?\s*\)/) {
					$textno = $1;
					$text   = $2;
					$text =~ s/'/\'/g;
					if ($text =~ /\S/) {
						$textinfo = maybenewtext($textno, $textinfo);
						$textinfo->[ $textno - 1 ]->{TitleText} = $text;
					}
					$lasttag = $lineno;
					last SWITCH;
				}
				if (/#\s*\bEditionText(\d+)\(\s*'?(.*?)'?\s*\)/) {
					$textno  = $1;
					$edition = $2;
					$edition =~ s/'/\'/g;
					if ($edition =~ /\S/) {
						$textinfo = maybenewtext($textno, $textinfo);
						$textinfo->[ $textno - 1 ]->{EditionText} = $edition;
					}
					$lasttag = $lineno;
					last SWITCH;
				}
				if (/#\s*\bAuthorText(\d+)\(\s*'?(.*?)'?\s*\)/) {
					$textno     = $1;
					$textauthor = $2;
					$textauthor =~ s/'/\'/g;
					if ($textauthor =~ /\S/) {
						$textinfo = maybenewtext($textno, $textinfo);
						$textinfo->[ $textno - 1 ]->{AuthorText} = $textauthor;
					}
					$lasttag = $lineno;
					last SWITCH;
				}
				if (/#\s*\bSection(\d+)\(\s*'?(.*?)'?\s*\)/) {
					$textno      = $1;
					$textsection = $2;
					$textsection =~ s/'/\'/g;
					$textsection =~ s/[^\d\.]//g;
					if ($textsection =~ /\S/) {
						$textinfo = maybenewtext($textno, $textinfo);
						if ($textsection =~ /(\d*?)\.(\d*)/) {
							$textinfo->[ $textno - 1 ]->{chapter} = $1;
							$textinfo->[ $textno - 1 ]->{section} = $2;
						} else {
							$textinfo->[ $textno - 1 ]->{chapter} = $textsection;
							$textinfo->[ $textno - 1 ]->{section} = -1;
						}
					}
					$lasttag = $lineno;
					last SWITCH;
				}
				if (/#\s*\bProblem(\d+)\(\s*(.*?)\s*\)/) {
					$textno      = $1;
					$textproblem = $2;
					$textproblem =~ s/\D/ /g;
					my @textproblems = (-1);
					@textproblems = split /\s+/, $textproblem;
					@textproblems = grep { $_ =~ /\S/ } @textproblems;
					if (scalar(@textproblems) or defined($textinfo->[$textno])) {
						@textproblems                          = (-1) unless (scalar(@textproblems));
						$textinfo                              = maybenewtext($textno, $textinfo);
						$textinfo->[ $textno - 1 ]->{problems} = \@textproblems;
					}
					$lasttag = $lineno;
					last SWITCH;
				}
			}
		};
		warn "error reading problem $name $!, $@ " if $@;
	}
	$self->{textinfo} = $textinfo;

	if (defined($self->{DBchapter}) and $self->{DBchapter} eq 'ZZZ-Inserted Text') {
		$self->{isplaceholder} = 1;
	}

	$self->{lasttagline} = $lasttag;
	bless($self, $class);
	$self->tidytextinfo();
	return $self;
}

sub istagged {
	my $self = shift;
	return 1 if (defined($self->{DBsubject}) and $self->{DBsubject} and (not $self->{isplaceholder}));
	return 0;
}

1;
