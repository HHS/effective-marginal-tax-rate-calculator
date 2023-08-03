#=============================================================================#
#  LIHEAP Module – ME 2021 
#=============================================================================#
# INPUTS AND OUTPUTS NEEDED FOR THIS SCRIPT TO RUN:

# INPUTS FROM USER INTERFACE:
#	liheap
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

	#Sources: Largely, this script is derived from the rules at https://www.mainehousing.org/docs/default-source/msha-rules/ch24-home-energy-assistance-program-rule.pdf. 
	
	#Maine's LIHEAP program consists of Heating Assistance (HEAP), Cooling Assistance, and Weatherization Assitance. This code focuses solely on the Heating Assistance portion of the LIHEAP program. To match the coding in other states, we are using the generic "LIHEAP" name below, but users will see the state name ("Home Energy Assistance Program" or "HEAP") when using the online tool.
	
	# outputs created
	our $liheap_recd = 0; # annual value of LIHEAP received

	# other variables used
	our @liheap_60percentsmi_array = (0,28133,36789,45445,54101,52757,71413, 73036, 74659, 76282); #2020-21 LIHEAP income limits, the latest available.
	our @fpl = (0,12880,17420,21960,26500,31040,35580,40120,44660,49200);
	our $liheap_dollars_per_point = 42; #Maine uses a point-based system and updates their LIHEAP program by adjusting teh amount of dollars provided per point -- the higher a household's points, the larger the LIHEAP subsidy. Each year Maine updates its point system based on two methods for calculating energy costs -- a consumption-based method when energy costs meet certain criteria, and a Design Heat Load Calculation (DHLC) when those criteria are not met. The criteria for the consumption-based method largely mirror the assumptions of the MTRC model, so we will be using the dollars for each point derived from that method. The dollars per poitn for the DHLC method is 31. Both these numbers are for FY21 as reported in the Proposed FY22 Maine LIHEAP State Plan.
	our $default_electric_portion = .3; #For households with electric heat, 30% of their bill is deducted for non-heating use of electricity.
	our $electric_heat = 0;
	
	#our $income_deduction = .2; # 20% of wage income can be deducted from income to determine benefits if the family is eligible for LIHEAP. (650.5)

	#Defined in macro:
	our $liheap_income_limit_smi = 0; 
	our $liheap_fpl = 0;
	our $liheap_income_m = 0;		# monthly countable income for LIHEAP eligibility and benefit level calculations. FAP income counts the following as income to determine eligibility and benefit levels for fap: alimony, annuity payments, chil support, dividends over $50, pensions, interest over $50/yr, insurance payments, rental income, salaries and money wages before deductions, social security, SSI (except for minor disabled children), state welfare payments, and unemployment, among others.
	our $liheap_income = 0;	    #annual countable income for determining LIHEAP benefit
	#our $child_support_exlusion_perchild = 100;
	#our $child_support_exclusion_max = 200;
	#our $interest_disregard = 25; #The dollar amount of interest or dividend income disregarded from income.
	#our $alimony_exclusion = 50;
	our $self_employment_inome_total_m = 0;
	our $electric_bill_m = 0;
	our $rent_paid = $out->{'rent_paid'};	#We'll be adjusting this output here.
	our $rent_paid_m = $out->{'rent_paid_m'};	#We'll be adjusting this output here.
	# LIHEAP benefits are modeled as reduction in rent costs because the Fair Market Rents include utilities and liheap benefits are paid directly to utility companies. LIHEAP is a federal block grant to states. (It is not an entitlement program). The amount of benefit depends of household size, income, type of unit (multi-family or single family), and fuel source. 
	our $liheap_static_unearned_income = 0;
    our $liheap_unearned_income_m = 0;	#monthly unearned income that is counted for fap eligibility and benefit calculation: social security, tanf, child support, interest over $50/yr, ssi, among others, listed on page 13 of FAP procedures manual
	our	$heat_bill_m = 0;
	our	$heatandelectric_cost_m = 0;
	our $liheap_points = 0;
	our $liheap_percentofpoverty = 0;
	our $liheap_point_pct = 0;
	our $excluded_earnings_m = 0;
	our $potential_excluded_earnings_m = 0;
	our $potential_excluded_hh_members = 0;
	our $liheap_excluded_hh_members = 0;
	our $potential_liheap_fpl = 0;
	our $potential_liheap_income_m = 0; 


	#our $liheap_minimum_benefit = 200; #For families who are eligible for LIHEAP based on income, they receive at least the minimum LIHEAP benefit in some states.

	#Variables that other LIHEAP policies use but that this PA LIHEAP code does not. Kept in here in case they come in handy when working on other states.
	#our $liheap_smi_m = qw(0 2978 3895 4811 5728 6644 7560 7732 7904 8076) [$in->{'family_size'}];		#60% of SMI - monthly income,  https://www.nh.gov/osi/energy/programs/fuel-assistance/eligibility.htm includes these thresholds for household sizes up to 8. NH calculates eligibility based on monthly income by taking annual income, dividing it by 365, and multiplying it by 30. This is the maximum that NH's LIHEAP income limit could be, but it is not invoked in current policy because the current NH income limit is below this amount. These limits are based on a baseline four-person household multiplied by percentages, as detailed here: https://www.law.cornell.edu/cfr/text/45/96.85. The nine-person household maximum is derived by taking the six-person household percentage above four person-housholds (132 percent) and adding three percentage points for every one additional household member. 132+3*3=141
	#our $liheap_minimum_heat_bill = 100;
	#our $liheap_poverty_level = 0;
	#our $eap_discount = 0;
	#our $eap_recd = 0;
	
	#our $max_liheap_benefit = 0; # the maximum liheap benefit, based on fuel source and family size.
	# our $room_num = 0;			#We need to make some assumptions about heating costs if we don't have the actual heating costs of the unit - commenting out for now but may need later if we get Appendix C-2.

	if($in->{'liheap'} == 1 && $out->{'housing_recd'} == 0) { # && $in->{'heat_in_rent'} == 0: commenting this out because it appears that if you pay for heat indirectrly through your rent bill, you are still eligible for LIHEAP. But changed to exclude anyone who lives in subsized housing -- they can still get a nominal LIHEAP payment to inflate their SNAP, but that's calculated in the SNAP codes.

		# 2. Calculating gross income according to LIHEAP rules.
		#
		#
		# Organizing non-disregarded income:
		$liheap_static_unearned_income = $in->{'unearn_gross_mon_inc_amt_ag'}; #This is set to 0 in the frs.pm module.
		#For a very advanced tool, we could go through these one by one and see if there are any differences between what's counted as underaned income for LIHEAP compared to unearned income for other programs, but any differences seem nominal or rare based on our reading.

		#Self-employment income needs to be tallied:
		for(my $i=1; $i<=4; $i++) {
			if($in->{'parent' . $i . '_age'} > 0) {
				$self_employment_inome_total_m += ($in->{'parent'.$i.'_selfemployed_netprofit'})/12; #These variables are also all zeroed out in the frs.pm code.
			}
		}
		
		#Combining other types of unearned income:
		$liheap_unearned_income_m = $liheap_static_unearned_income + $out->{'gift_income_m'} + $out->{'ssi_recd_mnth'} + $out->{'tanf_recd_m'} + $out->{'ui_recd_m'} + $out->{'child_support_recd_m'} + $in->{'alimony_paid_m'} + $out->{'interest'} + $in->{'other_income_m'}; 

		#Income from a full-time high school student is excluded (but the indidivual in high school is not excluded. We do this with other states by looking at tuition and full-time status.
		for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
			if ($in->{'parent'.$i.'_age'} <= 20 && $in->{'parent'.$i.'_ft_student'} == 1 && $in->{'parent'.$i.'_educational_expenses'} == 0) { #The maximum high school age in Maine is 20, and college attendance would likely incur at least some expenses, so we are assuming this adult is a high school student and that their income is not counted. 
				$excluded_earnings_m += $out->{'parent'.$i.'_earnings_m'};
			} elsif ($i > 1  && $in->{'parent'.$i.'_age'} <= 23 && $in->{'parent'.$i.'_ft_student'} == 1 && $in->{'parent'.$i.'_educational_expenses'} > 0) {
				#A full-time college student, up to age 23 years old, who is a dependent of the Household and resides in the Dwelling Unit on the Date of Application, may be excluded from the Household if the Primary Applicant chooses as long as the college student is not the Primary Applicant. If excluded from the Household, his or her income would not be counted. The Applicant must provide proof of student status and enrollment at a university, vocational college, business college, or other accredited institution for twelve (12) credit hours or more per semester.
				#Could simply exclude these individuals and remove them from new variable like liheap_unit_size. Or would we need to run this twice, to see whcih benefit is larger, if a lower household size might result in less benefits? Check once gone through policy.
				$potential_excluded_earnings_m += $out->{'parent'.$i.'_earnings_m'};
				$potential_excluded_hh_members += 1;
			}
		}

		$liheap_fpl = $fpl[$in->{'family_size'}];
		$liheap_income_m = pos_sub($out->{'earnings_mnth'}, $excluded_earnings_m) + $self_employment_inome_total_m + $liheap_unearned_income_m; 

		$potential_liheap_fpl = $fpl[$in->{'family_size'} - $potential_excluded_hh_members];
		$potential_liheap_income_m = pos_sub($out->{'earnings_mnth'}, $excluded_earnings_m + $potential_excluded_earnings_m) + $self_employment_inome_total_m + $liheap_unearned_income_m; 
				
		
		if ($potential_liheap_income_m * 12 / $potential_liheap_fpl < $liheap_income_m*12 / $liheap_fpl) {
			$liheap_income_m = $potential_liheap_income_m;
		} 
		$liheap_income = $liheap_income_m*12;
		$liheap_percentofpoverty = $liheap_income/$liheap_fpl;
		$liheap_income_limit_smi = $liheap_60percentsmi_array[$in->{'family_size'} - $liheap_excluded_hh_members]; 
				

		# 5. DETERMINE LIHEAP ELIGIBILITY AND BENEFITS:
		#
		# LIHEAP applies to all energy types. 
		#
		$liheap_income_limit = &greatest(1.5 * $liheap_fpl, $liheap_income_limit_smi);

		#"For any Household found ineligible due to being over income, the Subgrantee will deduct paid and documented medical expenses not reimbursed for the income period from the gross income in an amount only enough to make Household eligible. Medical expenses may include medical and dental insurance premiums and transportation to medical appointments. Subgrantees will use Internal Revenue Service Publication 502, as same may be amended from time to time, to identify eligible medical and dental expenses." -Maine LIHEAP rules
		if ($liheap_income  > $liheap_income_limit && $liheap_income - $out->{'health_expenses'} <= $liheap_income_limit) {
			$liheap_income = $liheap_income_limit;
		}

		if ($in->{'heat_fuel_source'} eq 'electric') {
			$electric_heat = 1;
		}

		#Determining the home's heating portion of their utility bills:
		if ($in->{'energy_cost_override'} == 0) { #We know the total heating costs and don't have to impute them based on how much they would have gotten in LIHEAP.
			if ($in->{'heat_fuel_source'} eq 'electric') {		
				#We use the natural average gas cost as the baseline energy cost, absent an override.
				$heat_bill_m = (1 - $default_electric_portion) * $out->{'average_naturalgas_cost'};
			} else {
				$heat_bill_m = $out->{'average_naturalgas_cost'};
			}
		} else {
			if ($out->{'scenario'} eq 'current') {
				
				#THIS WILL NEED SOME CHECKING
				
				#We need to use the LIHEAP formulas, basically in reverse, to see what their heat bill would be without LIHEAP coverage ($heat_bill_m), in their current situation, and then adjust it based on their new situation.
				for ($liheap_percentofpoverty) {
					$liheap_point_pct = ($_ <= .25)	? 1.3 :
										($_ <= .5)	? 1.2 :
										($_ <= .75)	? 1.1 :
										($_ <= 1)	? 1	 :
										($_ <= 1.25)? .9 :
										($_ <= 1.5) ? .8 :
												 .7;
				}
				
				#We can impute this because $liheap_points is a function only of $heat_bill_m
				#$liheap_recd = 12*($heat_bill_m - override_heat)
				#$liheap_recd = $liheap_points * liheap_point_pct * liheap_dollars_per_point;
				#12*($heat_bill_m - override_heat) = $liheap_points * liheap_point_pct * liheap_dollars_per_point;
				#$heat_bill_m - override_heat = ($liheap_points * liheap_point_pct * liheap_dollars_per_point)/12;
				#override_heat = $heat_bill_m - ($liheap_points * liheap_point_pct * liheap_dollars_per_point)/12;
				#if and only if ($liheap_points == 5) { #heat_bill_m <= 400/12
				#	override_heat <=  (400 / 12) - (5 * liheap_point_pct * liheap_dollars_per_point)/12);
				#	for electric, this would be:
				#	override_heat <=  .7 * (400 / 12) - (5 * liheap_point_pct * liheap_dollars_per_point)/12);
				#	
				#}
				#OR:
				#	if 	override_heat <=  (1 - default_electric_portion) * electric_heat * (400 / 12) - (5 * liheap_point_pct * liheap_dollars_per_point)/12);
				#		$liheap_points = 5;
				#	etc.
				#This translates to the following code to arrive at how much LIHEAP the household is initially receiving.
				#We then add that LIHEAP to the override to to get to the imputed heat cost.
				
				
				if 	($in->{'heating_cost_override_amt'} <=  (1 - $default_electric_portion) * $electric_heat * (400 / 12) - (5 * $liheap_point_pct * $liheap_dollars_per_point)/12) {
					$liheap_points = 5;
				} elsif ($in->{'heating_cost_override_amt'} <=  (1 - $default_electric_portion) * $electric_heat * (800 / 12) - (10 * $liheap_point_pct * $liheap_dollars_per_point)/12) {
					$liheap_points = 10;
				} elsif ($in->{'heating_cost_override_amt'} <=  (1 - $default_electric_portion) * $electric_heat * (1200 / 12) - (15 * $liheap_point_pct * $liheap_dollars_per_point)/12) {
					$liheap_points = 15;
				} elsif ($in->{'heating_cost_override_amt'} <=  (1 - $default_electric_portion) * $electric_heat * (1600 / 12) - (20 * $liheap_point_pct * $liheap_dollars_per_point)/12) {
					$liheap_points = 20;
				} elsif ($in->{'heating_cost_override_amt'} <=  (1 - $default_electric_portion) * $electric_heat * (2000 / 12) - (25 * $liheap_point_pct * $liheap_dollars_per_point)/12) {
					$liheap_points = 25;
				} elsif ($in->{'heating_cost_override_amt'} <=  (1 - $default_electric_portion) * $electric_heat * (2500 / 12) - (30 * $liheap_point_pct * $liheap_dollars_per_point)/12) {
					$liheap_points = 30;
				} else {
					$liheap_points = 35;
				}
				$liheap_recd = $liheap_points * $liheap_point_pct * $liheap_dollars_per_point;
				$in->{'imputed_heatcost_total'} = $in->{'heating_cost_override_amt'} + $liheap_recd;
				$heat_bill_m = $in->{'imputed_heatcost_total'};
			} else {
				$heat_bill_m = $in->{'imputed_heatcost_total'} ;
			}
		}

		#Determing the LIHEAP benefit:
		if ($liheap_income  <= $liheap_income_limit && $heat_bill_m > 0) {
		

			# We use the LIHEAP benefit matrix to determine discount. We will apply the reduction to this discount for natural gas and electric clients afteward.			
			
			for ($heat_bill_m * 12) {
				$liheap_points =($_ <= 400)	? 5 :
								($_ <= 800) ? 10 :
								($_ <= 1200) ? 15 :
								($_ <= 1600) ? 20 :
								($_ <= 2000) ? 25 :
								($_ <= 2500) ? 30 :
											 35;
			}
			for ($liheap_percentofpoverty) {
				$liheap_point_pct = ($_ <= .25)	? 1.3 :
									($_ <= .5)	? 1.2 :
									($_ <= .75)	? 1.1 :
									($_ <= 1)	? 1	 :
									($_ <= 1.25)? .9 :
									($_ <= 1.5) ? .8 :
											 .7;
			}
			$liheap_recd = $liheap_points * $liheap_point_pct * $liheap_dollars_per_point;
			
			# We now subtract the minimum between heating costs and the max liheap benefit.

			$liheap_recd = least($heat_bill_m * 12, $liheap_recd)

		} else {
			$liheap_recd = 0;
		}
	}	
	if ($in->{'heat_in_rent'} == 1 && $in->{'energy_cost_override'} == 0) {
		$electric_bill_m = 0;
		$heat_bill_m = 0;
		$heatandelectric_cost_m = 0;
	} else {
		if ($in->{'energy_cost_override'} == 1) { # This also means that the user has overriden the rent cost.
			#In this case, we do the same operation we do elsewhere with subsidized expenses -- first add back the subsidized expense for the "current" scenario to find the baseline expenses, and then subtract any benefits from that for the ultimate cost.
			$heatandelectric_cost_m = $in->{'energy_cost_override_amt'} - $in->{'heating_cost_override_amt'} + pos_sub($heat_bill_m, $liheap_recd);
		} else {
			$electric_bill_m = $out->{'average_electric_cost'};			
			$heat_bill_m = $out->{'average_naturalgas_cost'};
			$heatandelectric_cost_m = $electric_bill_m + $heat_bill_m;
		}
	}

	$heatandelectric_paid = pos_sub($heatandelectric_cost_m * 12, $liheap_recd);
	$heatandelectric_paid_m = $heatandelectric_paid /12;	
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
	foreach my $debug (qw(liheap_income liheap_recd rent_paid_m rent_paid liheap_unearned_income_m  liheap_income_limit self_employment_inome_total_m)) {
		print $debug.": ".${$debug}."\n";
	}

	# outputs
	foreach my $name (qw(liheap_recd rent_paid rent_paid_m heatandelectric_paid_m heatandelectric_paid)) {
       $out->{$name} = ${$name};
    }
	
}

1;