
# Inputs or outputs referenced in this module:
#
#	INPUTS FROM USER
#		rent_cost_m
#		disability_work_expenses_m
#		disability_personal_expenses_m
#		other_override
#		other_override_amt
#
#   OUTPUTS FROM FOOD
#		family_foodcost
#
#   OUTPUTS FROM LIFELINE
#		lifeline_recd
#
#
#=============================================================================#

sub other
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};


	#Hard-coded policy variables:
	our $other_expenses_percentage = .1689;
	# The FRS (prior to the MTRC) formerly relied on EPI’s family budget calculator’s method of determining the cost of other necessities, which is based on Consumer Expenditure Survey data: http://www.epi.org/publication/family-budget-calculator-technical-documentation/. This estimates that the cost of items including “apparel, entertainment, personal care expenses, household supplies (including furnishings and equipment, household operations, housekeeping supplies, and telephone services), reading materials, school supplies, and other miscellaneous items of necessity” total to 48.3% of the cost of food and housing, based on 2014 Consumer Expenditure Survey data. This is a change from an earlier methodology that EPI used, that pegged this at 25.6% of food and housing. Upon closer analysis of their approach in August 2017, we decided to slightly adjust it by removing educational expenses (which includes private tuition and other costs that we already account for, elsewhere,  such as afterschool co-pays) as well as entertainment costs, which seems more a function of disposable income than costs that should be included in calculations for a basic, livable income. Based on 2015 Consumer Expenditure Survey data, the removal of these expenses brought the proportion of these costs compared to rent, utilities, and food down to 34%. Based on the 2017-2018 Consumer Expenditure Survey data, these same categories constituted 33.6% of spending. In conversation with HHS ASPE as part of the MTRC project, this percentage was further reduced to a little below 17%,a lower figure partially because the MTRC asks users about many other costs as inputs compared to the FRS.
	our $phone_expenses_national = 830; #Derived from Consumer Expenditure Survey data, second-to-lowest quintile. Thess are the costs that can be adjusted based on lifeline receipt.
	our $sales_tax_average = .0739; # To enable state-by-state comparisons, and to better estimate the impact of sales tax policy, beginning in 2019 in the FRS (and 2021 in the MTRC) we are reducing the calculation of other expenses by the average combined state and local tax rate, which is calculated annually by the Tax Foundation. That annual report does not include a national average, but that can easily be determined by weighting each of the state average rates by the population in that state relative to the population of the US. This is calculated from using the latest Tax Foundation publication on average sales tax rates by state, and finding a national average using the latest Census state popuilations, to weigh the state averages against the proportion they represent of the national population. For the 2019 Tax Foundation publication, this is the average sales tax facing Americans. According to that publication (https://files.taxfoundation.org/20190130115700/State-Local-Sales-Tax-Rates-2019-FF-633.pdf), most sales tax calculations use a base that is generally consistent with our calculation for other expenses. 2020 documentation is available at https://files.taxfoundation.org/20200115132659/State-and-Local-Sales-Tax-Rates-2020.pdf. 

    # outputs created
    our $other_expenses = 0;
	our $phone_expenses = 0;
	our $salestax = 0;
	
	#Intermediary variables
	our $other_expenses_postsalestax = 0;
	our $phone_expenses_presalestax = 0;
	our $disability_expenses = 0;
	our $other_expenses_national = 0;
	our $other_expenses_presalestax = 0;

	our $other_regular_payments = 0; #Adding this in here to aggregate the "other regular payments" inputs the MTRC is now asking users to fill out. These are defaulted to 0 in the frs.pm file if they are not filled in on the online form.
	
	# Note that rent_cost is included in here, not rent_paid. This represents the unsubsidized cost of housing, so that receipt of Section 8 does not impact costs of other necessities.

	# Note that by "rent" we are capturing all recurring housing expenses, at least for the NH analysis, including homeownership costs. If/when we include homeowners more explicitly in the FRS, we can return to this to see if this methodology requires any tweaking.
		
    if($in->{'other_override'}) {
        $other_expenses = $in->{'other_override_amt'} * 12;
		$salestax += ($out->{'salestax_rate_other'} / (1 + $out->{'salestax_rate_other'})) * $in->{'other_override_amt'} * 12; # This is the portion of sales tax a person would pay of the user-entered other expenses amount, which is post sales tax.
    } else {
		# Beginning in  2019 in the FRS and 2021 in the MTRC, this program is going to calculate this as a pre-sales tax base, meaning it will adjust this figure to remove the national average of sales taxes.	
		$other_expenses_national = ($other_expenses_percentage) * ($out->{'family_foodcost'} + $in->{'rent_cost_m'} * 12); 
		# Now we adjust to remove the estimated sales tax portion. This allows us to have an "other expenses" base that is unchanged by state or local sales taxes, enabling comparisons of sales tax policies across states and localities.
		$other_expenses_presalestax = $other_expenses_national / (1 + $sales_tax_average);
		$other_expenses = (1 + $out->{'salestax_rate_other'}) * $other_expenses_presalestax;
		$salestax += $out->{'salestax_rate_other'} * $other_expenses_presalestax;
    }
	
    if($in->{'phone_override'}) {
		#When users enter their own out-of-pocket costs, we add any current benefits they are receiving (after testing eligibilty), and then remove those benefits to see an increase in cost once they are no longer eligible. This follows a similar appproach in the ccdf and food modules.
		
		if ($out->{'scenario'} eq 'current') {			
			$in->{'phone_expenses_base'} = $in->{'phone_override_amt'} * 12;
			if ($out->{'lifeline_recd'} > 0) {
				#If the above conditions are met, that means that the user has indicated that they receive Lifeline telephone subsidies, which reduce phone bills. To esatimate how much they would pay without Lifeline, we use average expenditures at the national level.
				
				$in->{'phone_expenses_base'} += pos_sub((1 + $out->{'salestax_rate_other'}) * ($phone_expenses_national / (1 + $sales_tax_average)),$out->{'lifeline_cost'}); #If consumers have entered both an override phone cost and indicated they are receiving Lifeline subsidies, we add the national average cost to their stated costs, adjusted by the sales tax. 
			}
		}
		
		#We now see whether the user stays on Lifeline and pays the discounted cost or pays an unsubsidized cost. If the user has not selected Lifeline, this will always use their user-entered cost.
		if ($out->{'lifeline_recd'} > 0) {
			$phone_expenses = $in->{'phone_override_amt'} * 12;
		} else {
			$phone_expenses = $in->{'phone_expenses_base'};
		}
		
		#Salestax is calculated 
 		$salestax += ($out->{'salestax_rate_other'} / (1 + $out->{'salestax_rate_other'})) * $phone_expenses; #We assume override amounts include sales tax.  
		
	} else {
		if ($out->{'lifeline_recd'} > 0) {
			$phone_expenses_presalestax = $out->{'lifeline_cost'};
		} else {
			$phone_expenses_presalestax = $phone_expenses_national / (1 + $sales_tax_average);
		}
		$phone_expenses = (1 + $out->{'salestax_rate_other'}) * $phone_expenses_presalestax;
		$salestax += $out->{'salestax_rate_other'} * $phone_expenses_presalestax;
	}
	
    # Beginning in 2017, the FRS (and later MTRC) also included disability-related expenses, derived from user-entered inputs.

    $disability_expenses = 12* ($in->{'disability_work_expenses_m'} + $in->{'disability_personal_expenses_m'} + $in->{'disability_other_expenses_m'});
  
	if ($in->{'other_regular_override'} == 1) {
		$other_regular_payments = 12 * ($in->{'outgoing_child_support'} + $in->{'outgoing_alimony'} + $in->{'car_insurance_m car_payment_m'} + $in->{'renters_insurance_m'} + $in->{'student_debt'} + $in->{'debt_payment'} + $in->{'other_payments'});
	} else {
		$other_regular_payments = 0;
	}
	$other_regular_payments += $in->{'parent1_educational_expenses'} + $in->{'parent2_educational_expenses'} + $in->{'parent3_educational_expenses'} + $in->{'parent4_educational_expenses'};

	#debugging
	#foreach my $debug (qw(other_expenses phone_expenses salestax other_expenses_presalestax other_regular_payments)) {
	#	print $debug.": ".${$debug}."\n";
	#}

  # outputs
    foreach my $name (qw(other_expenses disability_expenses salestax phone_expenses other_expenses_presalestax phone_expenses_presalestax other_expenses_national other_regular_payments)) {
       $out->{$name} = ${$name};
    }
	
}

1;