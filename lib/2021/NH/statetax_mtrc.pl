#=============================================================================#
#  State Taxes -- 2021 NH
#
# It is likely safe to assume that no one using the MTRC will pay NH income taxes, which only cover interest income and not earnings, but this code helps universalize codes across states)
#
#
# NOTE THIS MODEL DOES NOT INCLUDE FEDERAL PROPERTY TAX DEDUCTIONS OR TAX CREDITS, NOR ANY STATE PROPERTY TAXES. THERE ARE SPECIFIC DEDUCTIONS AND CREDITS THAT HOMEOWNERS CAN TAKE, BUT FOR THE MTRC MODEL WE ARE WORKING OFF AN ASSUMPTION THAT THESE REDUCTIONS IN EXPENSES ARE OFFSET BY NEW HAMPSHIRE'S PROPERTY TAXES. THERE ARE NO BENEFIT CLIFFS OR MARGINAL TAX RATES ASSOCIATED WITH HOMEOWNERSHIP SEPARATE FROM RENTERS.
#
# ALONG WITH THE ABOVE ASSUMPTION ABOUT HOMEOWNERSHIP, WITH THE INPUTS FROM THE USER INTERFACE AND THE ASSUMPTIONS WE ARE MAKING ABOUT FAMILY FINANCES (THAT THEY ARE NOT RECEIVING SIGNIFICANT INTEREST REVENUE), THERE WILL NEVER BE ANY NEW HAMPSHIRE STATE TAXES OUTPUT FOR  FAMILIES USING THIS TOOL. FOR LATER USES OF THIS CODE, FOR EXAMPLE IF WE MODEL HOMEOWNERS MORE EXACLY, WE WILL NEED TO REMOVE THE ASSUMPTION THAT ANY TWO ADULTS IN A HOUSEHOLD ARE MARRIED AND BULD IN CODE HERE FOR ADDITIONAL ADULTS IN THE HOUSEHOLD. 
#=============================================================================#
#	INPUTS AND OUTPUTS FROM OTHER CODES
#
#	INPUTS 
#		disability_parent#
#		family_structure
#
#   OUTPUTS FROM INTEREST
#   	interest 
#  
#   OUTPUTS FROM FEDERAL TAX
#		federal_tax_gross
#		federal_tax_credits
#=============================================================================#


sub statetax
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

  # outputs created
	our $state_tax = 0;
    our $state_tax_income = 0;        	  	# Annual taxable income
    our $state_tax_gross = 0;				# Tax income after exclusions; 
    our $state_tax_credits = 0;				# Needed as variable for final tax calculations
    our $tax_before_credits = 0;            # Total federal and state tax liability
    our $tax_after_credits = 0;            	# Total federal and state tax liability after federal and state credits
	our $state_eic_recd = 0;				# Included because may be needed for final calcs.
	our $state_cadc_recd = 0;				# Included because may be needed for final calcs.
    our $state_tax_rate = 0.05;       		# State tax rate on interest income
	our $excluded_interest = 0;
	our $excluded_interest_single = 2400;	# Excluded amount for single tax filers.
	our $excluded_interest_joint = 4800;	# Excluded amount for joint tax filers.
	our $exemption_amount = 1200; 			# Exemption for disabled or 65+ self or spouse
	

	#New Hampshire has no income tax, but does charge a 5% tax on interest income. "Resident individuals, partnerships, and fiduciaries earning interest and dividend taxable income of more than $2,400 annually ( $4,800 for joint filers).  In addition, the following exemptions may also apply: 1) a $1,200 exemption is available for residents who are 65 years of age or older; 2) a $1,200 exemption is available for residents who are blind regardless of their age; and 3) a $1,200 exemption is available to disabled individuals who are unable to work, provided they have not reached their 65th birthday." None of these exceptions apply in the current populations that the FRS models. It is also unlikely that any individual has interest income exceeding this amount, but it's an easy rule to model, 

	# We need to add this last variable to make the frs.pl code calculate the net resources correctly.
 
	if ($in->{'family_structure'} == 1) {
		$excluded_interest = $excluded_interest_single;
	} else {
		$excluded_interest = $excluded_interest_joint;
	}
	
	# We calculate taxes according to the steps in the NH 2019 DP-10.
	# Since at least for the time being we are assuming the entire household does not earn interest, we are not dividing the household into tax filing units. The below code assumes that at least for NH taxes, all tax filers are part of the same state filing unit.
	
	$state_tax_income = pos_sub($out->{'interest'}, $excluded_interest + $exemption_amount*($in->{'disability_parent1'} + $in->{'disability_parent2'} + $in->{'disability_parent3'} + $in->{'disability_parent4'}));	
	$state_tax_gross = $state_tax_rate * $state_tax_income;

	#We now combine the state tax variables with the federal ones, to get the aggregate tax variables.
	$tax_before_credits = &round($out->{'federal_tax_gross'} + $state_tax_gross); 
	$tax_after_credits = &round($tax_before_credits - $out->{'federal_tax_credits'} - $state_tax_credits);

	#debugs:
	foreach my $debug (qw(state_tax_credits tax_before_credits  tax_after_credits)) {
		print $debug.": ".${$debug}."\n";
	}
	
  # outputs
    foreach my $name (qw(state_tax state_eic_recd state_tax_credits tax_before_credits  tax_after_credits state_cadc_recd)) { 
       $out->{$name} = ${$name};
	}
}

1;
