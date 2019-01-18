=head1 NAME

stoutUtils.pl

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

TODO

=head1 AUTHOR

Alex Basyrov, basyrova@uwstout.edu

=cut


loadMacros(
"MathObjects.pl",
);

package stoutUtils;
=head1 NAME 

Stout Utils

=head1 DESCRIPTION

These are sub's that are used in various other packages

=over

=cut

=item $stoutDebug 

Set 
	$stoutDebug = 0 
to supress debug messages; 
otherwise debug messages will be shown.

=cut

our $stoutDebug = 1;

=item stoutDebugMessage
Usage: 
	stoutDebugMessage('text 1', 'text 2', ...);

=cut

sub stoutDebugMessage{
	# return undef if (!$stoutDebug);
	main::WARN_MESSAGE(@_);
	return undef;
}

=item stoutDebugShowVar

Usage: 
	stoutDebugShowVar("description", $variable);

=cut

sub stoutDebugShowVar{
	# return undef if (!$stoutDebug);
	my $name = shift;
	my $value = shift;
	$value = "" unless defined $value; 
	main::WARN_MESSAGE($name.": |$value|");
	return undef;
}

=item stoutDebugShowArrayRef

Usage: 
	stoutDebugShowArrayRef("description", $arrayReference);

=cut

sub stoutDebugShowArrayRef{
	# return undef if (!$stoutDebug);
	my $name = shift;
	my $value = shift;
	my $list_of_values = join("|,\n|",@{$value});
	$list_of_values = "" unless defined $list_of_values;
	main::WARN_MESSAGE($name.": |".$list_of_values."|\n");
	return undef;
}

=item stoutDebugShowHashRef

Usage: 
	stoutDebugShowHashRef("description",$hashReference);

This will show hash keyes and their values without special treatment of references, arrays, or hashes stored within the $hashReference. 

=cut

sub stoutDebugShowHashRef{
	# return undef if (!$stoutDebug);
	my $name = shift;
	my $value = shift;
	my @keys = keys %{$value};
	my @msg;
	
	push (@msg, $name.":");
	
	for my $key (@keys){
		my $val = $value->{$key};
		$val = "" unless defined $val;
		push(@msg, $key ." => |$val|");
	}
	main::WARN_MESSAGE(@msg);
	return undef;
}

=item matchUpToConstant

Usage: 
	matchUpToConstant($context, "Correct answer", "Student answer");
	matchUpToConstant($context, "Correct answer", "Student answer", non_trivial=>1);

We take Context, correct answer, and student answer, and see if they are equal -- up to a negative sign. 

Add non_trivial=>1 at the end to match up to a non-trivial constant, but this will use numeric matching: it takes longer, uses notrivial things, and the result will be approximate. 

=cut

sub matchUpToConstant{
	# we take Context, correct answer, and student answer, and see if they are equal -- up to a constant
	# add non_trivial=>1 at the end to use more sophisticated matching
	my $context = shift;
	my $correct = shift;
	my $student = shift;
	# the rest of the parameters are options, they go into this hash
	my %options = @_; 
	
	# set the default values for options if they are not already specified
	$options{non_trivial} = 0 unless defined $options{non_trivial};
	
	#let's be optimistic and hope for an easy match:
	my $f_student = main::Formula($context,$student);
	my $fp_correct = main::Formula($context,$correct); # positive version
	my $fn_correct = main::Formula($context,"-($correct)"); #negative version
	
	if ($f_student == $fp_correct){
		return 1;
	} elsif ($f_student == $fn_correct){
		return -1;
	}
	
	#if we're here, the easy match did not work for some reason
	#we have to use adaptive paramters to find non-trivial constant 
	#that makes student answer equal to the correct answer
	#this is an expensive process that sometimes goes wrong
	#FOR NOW WE DO NOT USE IT, unless we ask for it explicitly!
	
	if ($options{non_trivial}){
		# they should explicitly ask for this method of matching!
		my $a_context = $context->copy();
		$a_context->flags->set(no_parameters=>0);
		$pname='Az';
		$a_context->variables->add($pname=>'Parameter');
		my $c0 = main::Formula($a_context,$pname);
		my $fstudent = main::Formula($a_context,$student);
		my $fcorrect = main::Formula($a_context,"$c0 * ($correct)");
		
		#if any of the answers are zero, we have to handle them carefully
		if ($fstudent->isZero) {
			if ($fcorrect->isZero){
				# student answer is correctly zero
				return 1;
			} else {
				# student answer is zero when it should not be
				# the match failed, we return undef
				return undef;
			}
		}
		if ( $fcorrect == $fstudent ) {
			$parameterValue = $a_context->variables->value($pname);
			# this value is numerically generated. 
			# even if it should be an integer, 
			# it could be some close enough decimal
			return $parameterValue; 
		}
	}

	# matching failed -- we return undef
	return undef;
}

=back 

=head1 AUTHOR

Written by Alex Basyrov, basyrova@uwstout.edu

=cut

1;
