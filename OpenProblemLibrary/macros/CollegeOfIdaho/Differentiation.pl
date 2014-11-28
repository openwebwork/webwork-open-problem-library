#
#  Example of how to add new functionality to the Parser.
#  
#  Here we load new methods for the Parser object classes.  Note, however,
#  that these are PERSISTANT when used with webwork2 (mod_perl), and so we
#  need to take care not to load them more than once.  We look for the
#  variable $Parser::Differentiation::loaded, which is defined in the
#  differentiation package, in order to tell.
#  
#  DifferentiationDefs.pl is really just a copy of the
#  Parser::Differentiation.pm file, and you really could just preload the
#  latter instead by uncommenting the 'use Parser::Differentiation' line at
#  the bottom of Parser.pm.  (This file is really just a sample).  The way
#  it's done here will load it the first time it gets used, then will keep
#  it around, so not much overhead even this way.
#

loadMacros("DifferentiationDefs.pl") unless $Parser::Differentiation::loaded;

1;
