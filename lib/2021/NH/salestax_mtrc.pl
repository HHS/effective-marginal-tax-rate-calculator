#=============================================================================#
#  Sales Tax – 2021 – NH
#=============================================================================#
#
# No inputs or outputs referenced in this module. It is used simply to generate sales tax policy information (if sales tax exist in a state) to feed to other modules.
#
#=============================================================================#

sub salestax
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};
  
    # outputs created
    our $statesalestax_rate_other = 0;	# The NH sales tax on tangible personal property. There is no sales tax in NH. This means that we could potentially simply assigna 0 value to the salestax outputs in the general Perl script, but this code could be used and modified to estimate the impact of imposing a sales tax on low-income New Hampshire families.
    our $localsalestax_rate_other = 0;	# Local sales tax rats in NH on tangible personal property. There are also no local sales taxes in NH.
    our $salestax_rate_other = 0;		# The applicable sales tax on tangible personal property, calculated below. This includes local sales taxes where they are applicable. 
	
    # outputs calculated in macro
    our $otherplussalestax = 0;
    our $salestaxbase = 0;
    our $salestax = 0;

    # In most places, the only applicable sales tax rate for the purposes of the FRS is a tax rate on tangible personal property, and these expenditures are captured completely in the “other” expenses calculation. It is important to consider what expenses are additionally included in state or local sales tax systems beyond the expenses captured in sales taxes, but in the case of NH, where there are no sales taxes whatsoever, this is irrelevant. Because later outcome mesaures include the salestax variable, though, we need to assign 0 values to these variables. 
	#
	# Combining state and local taxes:
	$salestax_rate_other = $statesalestax_rate_other + $localsalestax_rate_other;
    # Because our calculation of “other expenses” is based on the EPI calculation of other expenses, and because that in turn is based on national consumer expenditure statistics (which cannot be easily broken down by state), the below calculation carves out sales taxes from the “other expenses” calculation. 

	#debugging
	#foreach my $debug (qw(salestax_rate_other)) {
	#	print $debug.": ".${$debug}."\n";
	#}


    # outputs
    foreach my $name (qw(salestax_rate_other)) {
       $out->{$name} = ${$name};
    }
	
}

1;