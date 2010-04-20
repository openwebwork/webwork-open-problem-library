sub _AnswerFormatHelp_init {}; # don't reload this file

sub AnswerFormatHelp {

my $helptype = shift;
my $customstring = shift;
my $helpstring = "";

##########################################
if ($helptype =~ m/angle/i) {

if (!$customstring) { $helpstring = "help (angles)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Angles.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');

##########################################
} elsif ($helptype =~ m/decimal/i) {

# works, taken from helpLink at PGbasicmacros.pl
if (!$customstring) { $helpstring = "help (decimals)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Decimals.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');

# works but opens in a new tab without window focus
#  return htmlLink( alias("${htmlDirectory}Entering-Decimals.html"), "Answer format help", "TARGET=\"_new\"");


###################################################
} elsif ($helptype =~ m/exponent/i) {

if (!$customstring) { $helpstring = "help (exponents)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Exponents.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');


###################################################
} elsif ($helptype =~ m/equation/i) {

if (!$customstring) { $helpstring = "help (equations)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Equations.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');


###################################################
} elsif ($helptype =~ m/formula/i) {

if (!$customstring) { $helpstring = "help (formulas)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Formulas.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');


###################################################
} elsif ($helptype =~ m/fraction/i) {

if (!$customstring) { $helpstring = "help (fractions)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Fractions.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');


###################################################
} elsif ($helptype =~ m/inequalit/i) {

if (!$customstring) { $helpstring = "help (inequalities)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Inequalities.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');


###################################################
} elsif ($helptype =~ m/interval/i) {

return helpLink('interval notation');

###################################################
} elsif ($helptype =~ m/log/i) {

if (!$customstring) { $helpstring = "help (logarithms)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Logarithms.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');

###################################################
} elsif ($helptype =~ m/limit/i) {

if (!$customstring) { $helpstring = "help (limits)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Limits.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');


###################################################
} elsif ($helptype =~ m/number/i) {

if (!$customstring) { $helpstring = "help (numbers)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Numbers.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');


###################################################
} elsif ($helptype =~ m/point/i) {

if (!$customstring) { $helpstring = "help (points)"; } else { $helpstring = $customstring; }
return htmlLink( alias("${htmlDirectory}Entering-Points.html"), "$helpstring",
'target="ww_help" onclick="window.open(this.href,this.target,\'width=550,height=550,scrollbars=yes,resizable=on\'); return false;"');


###################################################
} elsif ($helptype =~ m/syntax/i) {

return helpLink('syntax');


###################################################
} elsif ($helptype =~ m/unit/i) {

return helpLink('units');



} else { }


} # end AnswerFormatHelp

1;
