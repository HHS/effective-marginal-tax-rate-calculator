#=============================================================================#
#  LIHEAP Module – NH 2021 
#=============================================================================#

# INPUTS AND OUTPUTS NEEDED FOR THIS SCRIPT TO RUN:

# INPUTS FROM USER INTERFACE:
#	liheap
#	eap 			#This is NH's Electric Assistance Program (EAP), which provides a reduction in the energy bill of houses that rely on electric heat. It needs to be processed first, since it represents the customer responsibility for the energy bill. LIHEAP comes after and has benefits that are lower for electric heating customers because they already have access to this other benefit.
#	parent#_age
#  	heat_fuel_source
#	cooking_fuel_source	
#	family_size 
#
# INPUTS FROM FRS.PM
#	parent#_selfemployed_netprofit
#	unearn_gross_mon_inc_amt_ag
#	fpl
#
# OUTPUTS FROM PARENT_EARNINGS:
# 	earnings_mnth
#
# OUTPUTS FROM INTEREST:
#   interest
#
# OUTPUTS FROM SEC 8:
# 	housing_subsidized
#  	rent_paid
#	rent_paid_m 
#
# OUTPUTS FROM SSI:
#  	ssi_recd_m
#
# OUTPUTS FROM TANF
#  	tanf_recd_m	
#	child_support_recd_m
#
# OUTPUTS FROM FSP_ASSETS
#	heating_cost_pha
#	electric_cost_pha
#	cooking_cost_pha
# OUTPUTS FROM UNEMPLOYMENT
#	ui_recd_m
#	ui_recd
#=============================================================================#
sub liheap
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# outputs created
	our $liheap_recd = 0;				# annual value of LIHEAP received

	# other variables used
	our $interest_disregard = 50; #The dollar amount of interest or dividend income disregarded from income.
	our $liheap_smi_m = qw(0 2978 3895 4811 5728 6644 7560 7732 7904 8076) [$in->{'family_size'}];		#60% of SMI - monthly income,  https://www.nh.gov/osi/energy/programs/fuel-assistance/eligibility.htm includes these thresholds for household sizes up to 8. NH calculates eligibility based on monthly income by taking annual income, dividing it by 365, and multiplying it by 30. This is the maximum that NH's LIHEAP income limit could be, but it is not invoked in current policy because the current NH income limit is below this amount. These limits are based on a baseline four-person household multiplied by percentages, as detailed here: https://www.law.cornell.edu/cfr/text/45/96.85. The nine-person household maximum is derived by taking the six-person household percentage above four person-housholds (132 percent) and adding three percentage points for every one additional household member. 132+3*3=141
	our $liheap_minimum_heat_bill = 100;
	our $self_employment_inome_total_m = 0;
	our $liheap_inc_m = 0;		# monthly countable income for LIHEAP eligibility and benefit level calculations. FAP income counts the following as income to determine eligibility and benefit levels for fap: alimony, annuity payments, chil support, dividends over $50, pensions, interest over $50/yr, insurance payments, rental income, salaries and money wages before deductions, social security, SSI (except for minor disabled children), state welfare payments, and unemployment, among others.
	our $liheap_inc = 0;	    #annual countable income for liheap eligibility
	our $liheap_poverty_level = 0;
	our $eap_discount = 0;
	our $eap_recd = 0;
	our $electric_bill_m = 0;
	our $liheap_static_unearned_income = 0;
    our $liheap_unearned_income_m = 0;	#monthly unearned income that is counted for fap eligibility and benefit calculation: social security, tanf, child support, interest over $50/yr, ssi, among others, listed on page 13 of FAP procedures manual
	our	$countable_interest_m = 0;		# annual interest counted as income - only interest over $50/yr
	our $max_liheap_benefit = 0; # the maximum liheap benefit, based on fuel source and family size.
	# our $room_num = 0;			#We need to make some assumptions about heating costs if we don't have the actual heating costs of the unit - commenting out for now but may need later if we get Appendix C-2.
	our $rent_paid = $out->{'rent_paid'};	#We'll be adjusting this output here.
	our $rent_paid_m = $out->{'rent_paid_m'};	#We'll be adjusting this output here.
	# LIHEAP benefits are modeled as reduction in rent costs because the Fair Market Rents include utilities and liheap benefits are paid directly to utility companies. LIHEAP is a federal block grant to states. (It is not an entitlement program). The amount of benefit depends of household size, income, type of unit (multi-family or single family), and fuel source. 

	#alternate variables:
	our $liheap_base = 0;
	our $liheap_difference = 0;
	our $liheap_lowpercent = 0;
	our $liheap_shift = 0;
	our $liheap_stop = 0;

	our	$heat_bill_m = 0;
	our	$heatandelectric_cost_m = 0;

	# Sources: 
	# A. NH Fuel Assistance Program Procedures Manual https://www.nh.gov/osi/energy/programs/fuel-assistance/documents/fap-procedures-manual.pdf
	# B. NH LIHEAP Benefits Matrix (federal site)
	# C. NH LIEEAP State Plan (federal site)

	#We calculate LIHEAP and EAP benefits below, and also calculate energy costs.
		  
	# 1. We first see if the individual is assigned FAP or EAP eligbility:

	#Beginning in 2021 -- with the MTRC -- we are separating heating and energy as utilities separate from rent.
	#IMPORTANT NOTE: ALTHOUGH WE INCORPORATE USER-ENTERED VALUES BELOW BY ADDING THE ESTIMATED BENEFIT AMOUNT TO THE STATED ENERGY EXPENSES PEOPLE FACE, AT LEAST IN NH WE ARE NOT AT THIS TIME ABLE TO INCORPORATE THOSE COSTS IN CALCULATING THE VALUE OF THE LIHEAP BENEFIT, SINCE THE BENEFIT ITSELF IS PARTIALLY BASED ON TOTAL ENERGY COSTS. SO UNLESS WE ASK FOR HOW MUCH PEOPLE ARE PAYING ALONG WITH HOW MUCH THE TOTAL COSTS OF ENERGY ARE, WE WILL BE MISSING AT LEAST ONE VARIABLE NEEDED FOR THE BELOW CALCULATIONS. AS A PROXY, WE ARE USING THE PHA ALLOWANCES BASED ON DIFFERENT HEATING COSTS TO ESTIMATE THE VALUE OF A BENEFIT, AND THEN MAKING A SIMILAR CALCULATION THAT WE DO FOR OTHER PROGRAMS THAT SUBSIDIZE EXPENSES.

	if(($in->{'liheap'} == 1 || $in->{'eap'} == 1) && $in->{'heat_in_rent'} == 0) {

		# NH has two energy assistance programs for low-income individuals: the Fuel Assistance Program (FAP), which is the more general LIHEAP program, and the Electric Assistance Program (EAP), specific to electric heat consumers. 
		#
		# Both programs are designed to reduce the energy bills of people who are responsibile for their own energy bills. People with subsidized housing are eligible for benefits if they meet all other FAP requirements for eligibility, if they are responsible for paying own heating bill, and if they have annual heating costs of at least $100. We proxy total utility costs as heat costs here to meet this threshold. Those with utilities included in the rent and aren't responsible for paying own heating bill are not eligible for FAP benefits. 
		
		# 2. Calculating gross income according to LIHEAP rules.
		#
		# Since both programs are operated by the same agency and the EAP program does not appear to publish a clear indication of what counts as "gross income," we can assume they count different types of income the same way. Also the FY 2020 LIHEAP state plan indicates "The CAAs will also take an Electric Assistance Program (EAP) application in coordination with FAP and WAP as EAP uses mostly the same eligibility requirements, although it is a separate application." LIHEAP has a very specific accounting of what counts as income.
		#
		# Organizing non-disregarded income:
		$liheap_static_unearned_income = $in->{'unearn_gross_mon_inc_amt_ag'}; #For a very advanced tool, we could go through these one by one and see if there are any differences between what's counted as underaned income for LIHEAP compared to unearned income for other programs, but any differences seem nominal or rare based on our reading.

		#Adjusting for interest:
		# The first $50 of interest and dividents is disregarded.
		
		$countable_interest_m = (pos_sub($out->{'interest'}, $interest_disregard))/12; 
		
		#Combining other types of unearned income:
		$liheap_unearned_income_m = $liheap_static_unearned_income + $countable_interest_m + $out->{'child_support_recd_m'} + $in->{'alimony_paid_m'} + $out->{'ssi_recd_mnth'} + $out->{'tanf_recd_m'} + $out->{'ui_recd_m'}; 

		#NOTES: NEED TO REMOVE CHILD SSI RECEIVED AFTER INCORPORATING THAT CODE IN, BASED ON THOSE VARIABLES.
		
		#Self-employment income needs to be tallied:
		$self_employment_inome_total_m = 0;
		for(my $i=1; $i<=4; $i++) {
			if($in->{'parent' . $i . '_age'} > 0) {
				$self_employment_inome_total_m += ($in->{'parent'.$i.'_selfemployed_netprofit'})/12;
			}
		}

		$liheap_inc_m = $out->{'earnings_mnth'} + $self_employment_inome_total_m + $liheap_unearned_income_m; 
		$liheap_inc = $liheap_inc_m*12;
		$liheap_poverty_level = 12 * $liheap_inc_m / $in->{'fpl'};

		# 3. DETERMINE EAP ELIGIBILITY AND DISCOUNT:
		
		if ($in->{'eap'} == 1) {
			for ($liheap_poverty_level) {
				$eap_discount = ($_ <=  .75) ? .76 :
									($_ <= 1.00) ? .52 :
									($_ <= 1.25) ? .36 :
									($_ <= 1.50) ? .22 :
									($_ <= 2.00) ? .08 :
													 0;
			}
			# 
			#Removing additional cooking cost allowance for electric cooking because we are leaving out the question for now of what type of cooking fuel they use.
			# if ($in->{'cooking_fuel_source'} eq 'electric') {
			#	$electric_bill_m += $out->{'cooking_cost_pha'};
			#}
			
			#4. Calcuating the EAP reduction from the discount:
			
			$eap_recd = $eap_discount * $electric_bill_m * 12;
			
			#We now subtract this from the local rent_paid variable.
			
		}
				

		# 5. DETERMINE LIHEAP ELIGIBILITY AND BENEFITS:
		#
		# LIHEAP applies to all energy types. 
		#
		# In the absence of Attachment C-1, which allows LIHEAP applicants to add the electric costs of operating their heating source,  we will defer to the PHA utility allowances for energy costs for users not entering teheir costs. 

		if ($in->{'liheap'} == 1) {
		
			# We use the LIHEAP benefit matrix to determine discount. We will apply the reduction to this discount for natural gas and electric clients afteward.			
			
			# Please note that the pha_ua's are monthly, so must be multiplied by 12 here.
			
			if ($liheap_poverty_level < .75) {
				for ($out->{'heating_cost_pha'} * 12) {
					$max_liheap_benefit = 	($_ <=  600) ? 630 :
											($_ <= 900) ? 945 :
											($_ <= 1200) ? 1260 :
													 1575;
				}
			} elsif ($liheap_poverty_level < 1.00) {
				for ($out->{'heating_cost_pha'} * 12) {
					$max_liheap_benefit = 	($_ <=  600) ? 546 :
											($_ <= 900) ? 819 :
											($_ <= 1200) ? 1092 :
													 1365;
				}
			} elsif ($liheap_poverty_level < 1.25) {
				for ($out->{'heating_cost_pha'} * 12) {
					$max_liheap_benefit = 	($_ <=  600) ? 462 :
											($_ <= 900) ? 693 :
											($_ <= 1200) ? 924 :
													 1155;
				}
			} elsif ($liheap_poverty_level < 1.5) {
				for ($out->{'heating_cost_pha'} * 12) {
					$max_liheap_benefit = 	($_ <=  600) ? 378 :
											($_ <= 900) ? 567 :
											($_ <= 1200) ? 756 :
													 945;
				}
			} elsif ($liheap_poverty_level < 1.75) {
				for ($out->{'heating_cost_pha'} * 12) {
					$max_liheap_benefit = 	($_ <=  600) ? 294 :
											($_ <= 900) ? 441 :
											($_ <= 1200) ? 588 :
													 735;
				}
			} elsif ($liheap_poverty_level < 2.00) {
				for ($out->{'heating_cost_pha'} * 12) {
					$max_liheap_benefit = 	($_ <=  600) ? 210 :
											($_ <= 900) ? 315 :
											($_ <= 1200) ? 420 :
													 525;
				}
			} else {
				$max_liheap_benefit = 0;
			}
			
			if (1 == 0) { #The below code constitutes a check or an alternate way of updating these polices (or a model for adjusting LIHEAP). For now, we're adding in this false condition to make it never run. It could be turned on to make sure the output is the same and that the code is running correctly. 
				# The current LIHEAP programs would be modeled as follows: liheap_base = 630, liheap_difference = 84, liheap_lowpercent = .75, and liheap_shift = .25. One could program in a geometric progression to get the difference exactly right between two numbers, for further adjustments.
				
				$liheap_base = 630;
				$liheap_difference = 84;
				$liheap_lowpercent = .75; 
				$liheap_shift = .25; 
				$liheap_stop = 0;
				$max_liheap_benefit = 0;
				for(my $i=0; $i<=12; $i++) { #A max i of 5 represents current policy (.75, 1, 1.25, 1.5, 1.75, 2)
					if ($liheap_poverty_level < $liheap_lowpercent + $liheap_shift * $i &&  $liheap_stop == 0) {
						$liheap_stop = 1; #The liheap_stop variable effectively becomes active when the inequality is met and thus prevents further iterations from occuring to lower LIHEAP benefits.
						for ($out->{'heating_cost_pha'} * 12) {
							$max_liheap_benefit = 	($_ <=  600) ? 1 * ($liheap_base - $liheap_difference * $i):
													($_ <= 900) ? 1.5 * ($liheap_base - $liheap_difference * $i):
													($_ <= 1200) ? 2 * ($liheap_base - $liheap_difference * $i):
															 2.5 * ($liheap_base - $liheap_difference * $i);
						}
					}
				}
			}
			# LIHEAP benefits are reduced by 25% for households that use electric or natural gas. 
			
			if ($in->{'heat_fuel_source'} eq 'electric' || $in->{'heat_fuel_source'} eq 'natural_gas') {
				$max_liheap_benefit = .75 * $max_liheap_benefit;
			}
			
			# We now subtract the minimum between heating costs and the max liheap benefit. Technically, NH residents who qualify for LIHEAP can apply the remainder of any FAP funds to later bills when their benefit outweights their energy costs. But it can not be transferred to cash. So for people moving up the economic ladder, this becomes a benefit to offset higher energy costs when they are no longer eligible for LIHEAP benefits or eligible at a later time. While we could consider this a near-cash resource, since energy is a constant need, we are not doing that here because LIHEAP is paid to energy companies and pay for considerably fewer goods than SNAP dollars can. 
			
			$liheap_recd = least($out->{'heating_cost_pha'} * 12, $max_liheap_benefit);
		}
	}	

	if ($in->{'heat_in_rent'} == 1 && $in->{'energy_cost_override'} == 0) {
		$electric_bill_m = 0;
		$heat_bill_m = 0;
		$heatandelectric_cost_m = 0;
	} else {
		if ($in->{'energy_cost_override'} == 1) { # This also means that the user has overriden the rent cost.
			#In this case, we do the same operation we do elsewhere with subsidized expenses -- first add back the subsidized expense for the "current" scenario to find the baseline expenses, and then subtract any benefits from that for the ultimate cost.
			if ($out->{'scenario'} eq 'current') {
				$in->{'imputed_energycost_total'} = $in->{'energy_cost_override_amt'} + ($eap_recd + $liheap_recd)/12;
			}
			$heatandelectric_cost_m = $in->{'imputed_energycost_total'};
		} else {
			$electric_bill_m = $out->{'electric_cost_pha'};			
			if ($in->{'heat_fuel_source'} eq 'electric') {
				$electric_bill_m += $out->{'heating_cost_pha'};
			} else {
				$heat_bill_m = $out->{'heating_cost_pha'};
			}
			$heatandelectric_cost_m = $electric_bill_m + $heat_bill_m;
		}
	}

	$heatandelectric_paid_m = pos_sub($heatandelectric_cost_m, ($eap_recd + $liheap_recd)/12);
	$heatandelectric_paid = $heatandelectric_paid_m * 12;	
	
	#Rather than break this out into a separate "Heat and electric" cost, we build it into rent. Separating the two out is problematic for users who do not override rent costs, because FMR's build utility costs like heating and energy into their estimates.
	if ($in->{'housing_override'} == 1) {
		#For a user who has entered in their own rent cost, we assume that they are entering rent independent of utilities. Therefore we add utility costs, inclusive of any reductions in those costs from LIHEAP or EAP.
		$rent_paid = $rent_paid + $heatandelectric_paid; 		
	} else {
		#For a user who has chosen to use the calculator's rent defaults, which are based on FMR's that include utility costs, we subctract any utility cost savings from rent.
		$rent_paid = pos_sub($rent_paid, 12 * pos_sub($heatandelectric_cost_m, $heatandelectric_paid_m)); 
	}
	$rent_paid_m = $rent_paid / 12;

	#debugging:
	#foreach my $debug (qw(liheap_recd eap_recd rent_paid_m rent_paid liheap_unearned_income_m)) {
	#	print $debug.": ".${$debug}."\n";
	#}

	# outputs
	foreach my $name (qw(liheap_recd eap_recd rent_paid rent_paid_m heatandelectric_paid_m heatandelectric_paid)) {
       $out->{$name} = ${$name};
    }
	
}

1;