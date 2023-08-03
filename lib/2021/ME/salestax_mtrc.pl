#=============================================================================#
#  Sales Tax – 2021 – ME
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
    our $statesalestax_rate_other = 0.055;	# The ME sales tax on tangible personal property. See  https://www.maine.gov/revenue/salesuse/salestax/ReferenceGuide2019.pdf. 
    our $localsalestax_rate_other = 0;	# There are  no local sales taxes in ME . https://legislature.maine.gov/legis/bills/display_ps.asp?LD=1254&snum=129. See also https://smartasset.com/taxes/maine-tax-calculator.
	
    # In most places, the only applicable sales tax rate for the purposes of the FRS/MTRC is a tax rate on tangible personal property, and these expenditures are captured completely in the “other” expenses calculation. It is important to consider what expenses are additionally included in state or local sales tax systems beyond the expenses captured in sales taxes. IN THE CASE OF MAINE, WE MAY NEED TO INCORPORATE CERTAIN ELECTRICITY COSTS. 
	#
	# Combining state and local taxes:
	$salestax_rate_other = $statesalestax_rate_other + $localsalestax_rate_other;

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