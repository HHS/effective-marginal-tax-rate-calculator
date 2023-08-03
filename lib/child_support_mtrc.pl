#------------------------------------
# CHILD SUPPORT 2021
#------------------------------------
#
# INPUTS FROM USER INTERFACE
#	child_support_recd_initial
#	child_support_retained_initial
#
#=============================================================================#

# CLARIFICATION:
# BECAUSE THERE ARE TOO MANY UNKNOWNS ABOUT NONCUSTODIAL PARENT CHARACTERISTICS FOR US TO ESTIMATE CHANGES IN CHILD SUPPORT FOLLOWING CUSTODIAL PARENT EARNINGS INCREASES, WE ARE HOLDING CHILD SUPPORT ORDERS CONSTANT FOR NOW. WE HAE DEVELOPED A ROBUST CODE FOR CHILD SUPPORT CALCULATIONS IF ADDITIONAL CLARIFICATIONS OR POLICY MODELING EXPERIMENTS ARE DESIRED. 

#Explanatory note: NCCP's FRS includes an extensive child care module that uses court order formulas to estimate the amount of child care a custodial parent household might receive, given characteristics of that household, which vary with income, and characteristics of the noncustodial parent household. For the MTRC, we have decided this calculation is unncessary because for the purposes of decisions regarding increased hours or increased wages, we are considering a one-year outlook at the most. It is unlikely that the custodial parent household will request a change in the court order due to attaining higher income. For that reason, we are merely using this code to convert an input variable (child_support_paid_m) to a monthtly and annual output variable, which is used in TANF and other codes. This will also make the variables compatible with the FRS and potentially other related tools.

sub child_support
{

    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	our $child_support_paid_m = 0;
	our $child_support_paid = 0;
	our $child_support_recd = 0; #These will be recalculated in the tanf module, but we need to know them for Head Start calculations in the child care module.
	our $child_support_recd_m = 0; #These will be recalculated in the tanf module, but we need to know them for Head Start calculations in the child care module.
		
	#Calcultion (see not above about clarification)
	$child_support_paid_m = $in->{'child_support_paid_m'}; #This is equivalent in other child support codes from administrative data as in->{'child_support_recd_m'}; + $in->{'child_support_retained_initial'}.
	$child_support_paid = 12* $child_support_paid_m;
	$child_support_recd = $child_support_paid; #These will be recalculated in the tanf module, but we need to know them for Head Start calculations in the child care module.
	$child_support_recd_m = $child_support_paid_m; #These will be recalculated in the tanf module, but we need to know them for Head Start calculations in the child care module.
	

	# outputs - needs some additions.
	foreach my $name (qw(child_support_paid child_support_paid_m child_support_recd_m child_support_recd)) {
        $out->{$name} = ${$name};
	}
}

1;
