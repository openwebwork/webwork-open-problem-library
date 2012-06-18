loadMacros("pointAnswer.pl","vectorUtils.pl");

#
#  Just a renaming of the point comparisons.
#
sub num_vector_cmp {num_point_cmp(@_)}
sub fun_vector_cmp {fun_point_cmp(@_)}
sub std_vector_cmp {std_point_cmp(@_)}
sub vector_cmp {point_cmp(@_)}

1;
