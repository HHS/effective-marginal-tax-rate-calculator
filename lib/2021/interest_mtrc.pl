#=============================================================================#
#  Interest Module -- 2021 
#=============================================================================#
#
# Inputs referenced in this module:
#
# FROM BASE
# Inputs:
#   passbook_rate
#	debt_payment_m
#
# FROM USER INPUTS
#	interest_m # The annual interest on savings. We have normally assumed rate is compounded annually -- compounding monthly or quarterly adds only a tiny fraction to the results)
#	savings 
#=============================================================================#

sub interest
{	
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};
		
	# OUTPUTS
	our $interest = 0;
	our $interest_m = 0;
	our $debt_payment = 0;
	our $other_income = 0;
	
	# set debt_payment to a yearly value, instead of monthly
	$debt_payment = 12 * $in->{'debt_payment_m'}; #In the online FRS, this is set in frs.pl, but for the sake of usefulness and clarity, setting it in this code instead.
	
	# Formulas in interest macro:
	$interest_m = $in->{'interest_m'}; 
	
	#For expediency's sake, we are using "interest" here as a proxy for taxable unarned income. Can come back to this once other changes have been implemented. 
	$interest_m += $in->{'other_income_m'};

	$interest = $interest_m * 12;
	
	#We need to separate alimony from the catch-all proxy for other unearned income (interest), since some programs treat alimony as separate from other unearned income, but combine them for the "other income" variable. 
	$other_income = $interest + $in->{'alimony_paid_m'} * 12;
	
    foreach my $name (qw(interest interest_m debt_payment other_income)) { 
       $out->{$name} = ${$name};
    }
	
}

1;