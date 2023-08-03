#=============================================================================#
#  State Taxes -- 2021 -- ME
#=============================================================================#
#
# Inputs referenced in this module:
#
# INPUTS:
#	heat_in_rent
#	disability_personal_expenses_m
#	state_cadc
#	state_eitc
#	state_dec 				# Input needs to be added
#	state_ptfc  			# Input needs to be added
#	state_stfc  			# Input needs to be added
#	parent1_incapacitated  	# Input needs to be added
#	parent2_incapacitated  	# Input needs to be added
#
# INPUTS FROM FRS.PM
#	family_structure
#	child_number
#
# OUTPUTS:
#
# FROM PARENT EARNINGS
# 	earnings
#
# FROM INTEREST
# 	interest
#
# FROM FEDERAL TAX
#   cadc_recd
#	cadc_percentage
#	filing status
#	federal_tax_gross
#
# FROM EITC
#	eitc_recd
#
# FROM CTC
#	federal_tax_credits
#
# FROM CHILD CARE
#	child_care_expenses
#	child_care_expenses_regular #Will need to be added to code
#	child_care_expenses_step4	#Will need to be added to code
#
# FROM LIHEAP OR SECTION 8
# 	rent_paid
#
# FROM FSP (SNAP)
#	energy_cost
#
#
#=============================================================================#

sub statetax
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};
    
	# policy variables
    our $state_tax_rate1 = .058;          # state tax rate for incomes under first tax threshold
    our $state_tax_rate2 = .0675;          # state tax rate for incomes under second tax threshold
	our $state_tax_rate3 = .0715;
	our $state_standard_deduction = 0; #Maine's standard deduction depends on income.
	our $state_exemption = 4300; #Amount of the exemption from state tax, 2020
	our $state_exemption_amt = 0; #Amount of the exemption from state tax
	our $dep_exempt_credit_potential = 0;
	our $dep_exempt_max_thresh = 200000; #The gross income at which the dependent exemption credit starts declining.
	our $dep_credit_max_perchild = 300;
	our $refundable_cadc_max = 500; # Maximum refundable child care credit.
	our $refundable_adultcare_credit_max = 500; # Maximum refundable adult care credit.
	our $state_pftc_max_credit_nonelderly = 750;  # Maximum allowable PTFC amount
	our $state_ptfc_phaseout_rate = .05; #The phase-out rate of the PTFC as income rises above the highest income that generates the maximum allowable PTFC amount. NOTE: This changed from 6% in 2019 to 5% in 2020, which has an impact on reducing marginal tax rates. This variable should be double-checked in future years.
	our $state_eitc_pct = .12; #Increased from 5% to 12% in 2020.
	our $state_childless_eitc_pct = .25; #Increased from 5% to 12% in 2020.
	our $state_cadc_pct_regular = .25; #State CDCTC percent of federal credit for child care in settings considered "regular" 
	our $state_cadc_pct_step4 = .5; #State CDCTC percent of federal credit for child care in Step 4 child care settings 
	our $dep_exempt_phaseout_rate = .0075; #The marginal rate of decline on the dependent exemption tax credit for incomes above the threhold for receiving the highest credit amount.
	our $state_adultcare_pct = .25; #Separate state % of federal cdctc for adult care.
	our $state_pftc_util_portion_est = .15; #How much the state is estimating utilty costs would be for people whose rent bills include utilities.
	our $state_ptfc_rent_portion =.15; #The maximum portion of a filer's rent covered by the PTFC benefit base.

	#outputs created
	our $tax_before_credits = 0;
	our $tax_after_credits = 0;
    our $state_tax = 0;
	our $state_tax_gross = 0;       # ME tax liability for unit 1
	
	#other intermediary variables created
	our $state_tax_gross1 = 0;       # ME tax liability for unit 1
	our $state_tax_gross2 = 0;       # ME tax liability
	our $state_tax_gross3 = 0;       # ME tax liability
	our $state_tax_gross4 = 0;       # ME tax liability
    our $county_tax = 0;
    our $state_gross_income = 0;
    our $state_tax_income = 0;         # ME taxable income (earnings + interest)  
	our $cadc_percentage = 0;
	our $potential_state_eitc_recd = 0;
	our $eitc_phasein_rate = 0;
	our $eitc_phaseout_rate = 0;
	our $eitc_plateau_start =  0;
	our $eitc_max_value = 0;
	our $eitc_plateau_end  = 0;
	our $eitc_income_limit = 0;
	our $regular_fed_cadc_portion = 0;
	our $step4_fed_cadc_portion = 0;
	our $state_cadc_potential = 0;
	our $state_cadc_refundable = 0;
	our $state_cadc_nonrefundable = 0;
	our $state_adultcare_credit_potential = 0;
	our $state_adultcare_credit_refundable = 0;
	our $state_adultcare_credit_nonrefundable = 0;
	our $regular_cc_costs_percent = 0;
	our $step4_cc_costs_percent = 0;
	our $state_cadc_recd = 0;
	our $state_tax_credits = 0;
	our $limited_deduction_min = 0;
	our $max_limited_deduction = 0;
	our $limited_deduction_percent = 0;
	our $total_refundable_credits = 0;
	our $income_above_limited_deduction_min = 0;
	our $state_eitc_recd = 0;
	our $total_nonrefundable_credits = 0;
	our $state_tax_net= 0;
	our $state_ptfc_applicable_rent	= 0;
	our $state_ptfc_rent_base = 0;
	our $state_ptfc_max_base = 0;
	our $state_ptfc_benefit_base = 0;
	our $state_ptfc_recd = 0;
	our $state_ptfc_benefit_base_reduced = 0;
	our $state_stfc_recd = 0;
	our $state_tax_threshold1 = 0;
	our $state_tax_base1 = 0;
	our $state_tax_threshold2 = 0;
	our $state_tax_base2 = 0;
	our $total_nonrefundable_credits1 = 0;
	our $total_nonrefundable_credits2 = 0;
	our $total_nonrefundable_credits3 = 0;
	our $total_nonrefundable_credits4 = 0;
	our $total_refundable_credits1 = 0;
	our $total_refundable_credits2 = 0;
	our $total_refundable_credits3 = 0;
	our $total_refundable_credits4 = 0;


	#There are no local or county income taxes in Maine. See https://taxfoundation.org/local-income-taxes-city-and-county-level-income-and-wage-taxes-continue-wane/.

	# Determine state filing status. Per Maine income tax instructions, this is the same as the federal filing status.
	for(my $i=1; $i<=$out->{'filers_count'}; $i++) { 
  
		# Determine thresholds and tax bases based on filing status, per 2020 rate schedules. We are using the 2019 tax forms as a guide, but the 2020 updates as published where possible.
		if ($out->{'filing_status'.$i} eq "Single") {
			$state_tax_threshold1 = 22450;
			$state_tax_base1 = 1302;
			$state_tax_threshold2 = 53150;
			$state_tax_base2 = 3374;
		} elsif ($out->{'filing_status'.$i} eq "Head of Household") {
			$state_tax_threshold1 = 33650;
			$state_tax_base1 = 1952;
			$state_tax_threshold2 = 79750;
			$state_tax_base2 = 5064;
		} else { # for "Married"
			$state_tax_threshold1 = 44950;
			$state_tax_base1 = 2607;
			$state_tax_threshold2 = 106350;
			$state_tax_base2 = 6752;
		}

		# determine state tax liability
		$state_gross_income = $out->{'gross_income'.$i}; #Maine uses federal adjusted gross income (AGI)
		
		# The following is based on an adjustment to the standard deduction made on higher income earners, based on instructions for line 17 of the 2019  Maine 1040 general instructions. It's unclear what these numbers are based on, if they tie into the federal codes or not. They are not updated in the 2020 income tax update: 
		if ($out->{'filing_status'.$i} eq 'Single') {
			$limited_deduction_min = 82900;
			$max_limited_deduction = 75000;
		} elsif ($out->{'filing_status'.$i} eq 'Head of Household') {
			$limited_deduction_min = 124350;
			$max_limited_deduction = 112500;
		} else { # for "Married"
			$limited_deduction_min = 165800;
			$max_limited_deduction = 150000;
		}	

		if ($state_gross_income <= $limited_deduction_min) {
			$state_standard_deduction = $out>{'standard_deduction'.$i};
		} else {
			$income_above_limited_deduction_min =  $state_gross_income - $limited_deduction_min;
			$limited_deduction_percent = $income_above_limited_deduction_min / $max_limited_deduction;
			$state_standard_deduction = $state_standard_deduction - $limited_deduction_percent * $out>{'standard_deduction'};
		}
			
		# Calculate state exemption amounts. In Maine, these track with whether an individual is single/head of household or married filing jointly.
		if ($i == 1 && $out->{'filing_status1'} eq 'Married') { 
			$state_exemption_amt = 2 * $state_exemption; 
		} else {
			$state_exemption_amt = 1 * $state_exemption; 
		}
		
		$state_tax_income = &pos_sub($state_gross_income, $state_standard_deduction + $state_exemption_amt);
		
		if ($state_tax_income < $state_tax_threshold1) {
			${'state_tax_gross'.$i} = $state_tax_rate1 * $state_tax_income;
		} elsif ($state_tax_income < $state_tax_threshold2) {
			${'state_tax_gross'.$i} = $state_tax_base1 + $state_tax_rate2 * ($state_tax_income - $state_tax_threshold1);
		} else { 
			${'state_tax_gross'.$i} = $state_tax_base2 + $state_tax_rate3 * ($state_tax_income - $state_tax_threshold2);
		}

		#TAX CREDITS:
		
		#Dependent Exemption Credit: 
		#As detailed in the worksheet in Schedule A, this gradually decilines at gross incomes exceeding $200,000. While the tool will likely rarely invoke tax calculations at these high incomes, we are keeping it in here for now to ensure accuracy. The below formula is  simplified version of the worksheet instructions. 
		if ($in->{'state_dec'}) {
			$dep_exempt_credit_potential = &pos_sub($in->{'child_number'} * $dep_credit_max_perchild, &pos_sub($state_gross_income - $dep_exempt_max_thresh) * $dep_exempt_phaseout_rate);
		}	
		
		#Child care credit (refundable and nonrefundable):
			
		if ($in->{'state_cadc'}) {
			if ($out->{'child_care_expenses'} > 0) {
				#Note: Maine provides a higher child care credit for families that enroll their children in Step 4 ("quality") child care. Per clarification from Maine officials, the higher (step 4) credit is available to a family for all their children as long as one of their children is enrolled in Step 4 care, meaning that a family will be able to claim the higher credit for all child care costs as long as one child is enrolled in Step 4 care, even if other children are not.
				if ($out->{'child_care_expenses_step4'} > 0) {
					$state_cadc_potential = $state_cadc_pct_step4 * $out->{'cadc_recd'};
				} else {
					$state_cadc_potential = $state_cadc_pct_regular * $out->{'cadc_recd'};
				}
				$state_cadc_refundable = &least($state_cadc_potential, $refundable_cadc_max);
				$state_cadc_nonrefundable = &pos_sub($state_cadc_potential, $state_cadc_refundable);

			}
			
			#Adult dependent care creditds
			#NOTE: WE NEED TO MAKE SURE TO HAVE The parent#_incapacitated variables as inputs. I believe right now they're outputs or in various codes, but we need to remove the assumptions those are built on and just ask people if any adult in the house has an incapacitating disability.
			if ($i == 1 && $out->{'parent_incapacitated_total'} > 0) {
				#Calculate the percentage of adult and dependent care costs covered by Maine's credit. While the federal credit has expanded due to temporary legislation, Maine's credit has expanded only for the child portion, and not for the adult care portion.
				for ($gross_income1) {
					$cadc_percentage = ($_ <= 15000)  ?   0.35   :
										 ($_ <= 17000)  ?   0.34   :
										 ($_ <= 19000)  ?   0.33   :
										 ($_ <= 21000)  ?   0.32   :
										 ($_ <= 23000)  ?   0.31   :
										 ($_ <= 25000)  ?   0.30   :
										 ($_ <= 27000)  ?   0.29   :
										 ($_ <= 29000)  ?   0.28   :
										 ($_ <= 31000)  ?   0.27   :
										 ($_ <= 33000)  ?   0.26   :
										 ($_ <= 35000)  ?   0.25   :
										 ($_ <= 37000)  ?   0.24   :
										 ($_ <= 39000)  ?   0.23   :
										 ($_ <= 41000)  ?   0.22   :
										 ($_ <= 43000)  ?   0.21   :
															0.20;
				}

				$state_adultcare_credit_potential = $in->{'disability_personal_expenses_m'} * $cadc_percentage * $state_adultcare_pct;
				$state_adultcare_credit_refundable = &least($state_adultcare_credit_potential, $refundable_adultcare_credit_max);
				$state_adultcare_credit_nonrefundable = &pos_sub($state_adultcare_credit_potential, $state_adultcare_credit_refundable);
			}
		}
		#EITC - for full-year residents, this is a completely refundable credit.
		if ($in->{'state_eitc'}) {
			if ($in->{'child_number'} + $out->{'adult_children'} > 0 && $i == 1) {
				$state_eitc_recd = $state_eitc_pct * $out->{'eitc_recd'};
			} elsif ($out->{'eitc_recd'.$i} > 0 && $i > 1) { #we are assuming there is only 1 tax filing unit in the home with child or adult dependents, tax unit 1. We therefore know that all other units in the home are childless and eligible for the higher Maine EITC for childless filers.
				$state_eitc_recd = $state_childless_eitc_pct * $out->{'eitc_recd'};
			} elsif ($out->{'eitc_recd'.$i} == 0 && $out->{'meetsagemin_unit'.$i} == 0 && $in->{'child_number'} + $out->{'adult_children'} == 0){
				#Maine provides an EITC to adults 18 and over. This is more expansive than the federal credit, even with the expanded COVID populations, which is still 19. As each tax filing unit in the MTRC tool must include an adult at least 18 years old, we can use the above shorthand to capture the remaining units who are eligible for the Maine credit. It is possibly simpler to do this in the federal EITC code, by generating "potential" EITC amounts per tax filing unit before checking the ages, but that will take some rejiggering of the federal EITC code, and further testing, and it's working fine now. Given the increase in the number of states expanding age minimums for the EITC, this is something for the future.
				if ($in->{'covid_eitc_expansion'} == 1) { #Here's the expansion:
					$eitc_phasein_rate = 0.153;
					$eitc_phaseout_rate = 0.153;
					$eitc_plateau_start =  9820;
					$eitc_max_value = 1502;
					$eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 11610 : 17550);
					$eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 21427 : 27367);
					
				} else {
					#Below are the regular, non-COVID EITC policy data for childless tax filers:
					$eitc_phasein_rate = 0.0765;
					$eitc_plateau_start = 7100;
					$eitc_max_value = 543;
					$eitc_phaseout_rate = 0.0765;
					$eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 8880 : 14820);
					$eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 15980 : 21920);
				}
			
				#First, we calculated EITC based on earned income alone.
				$potential_state_eitc_recd = 0; #setting this back to zero because this is a loop and a variable that gets recycled as we loop through the tax filing units.
				if ($out->{'gross_income'.$i} >= $eitc_income_limit || $out->{'earnings_unit'.$i}  >= $eitc_income_limit) { 
					$potential_state_eitc_recd = 0;
				} elsif($out->{'earnings_unit'.$i} < $eitc_plateau_start) { 
					$potential_state_eitc_recd = &round($state_childless_eitc_pct * $eitc_phasein_rate * $out->{'earnings_unit'.$i}); 
				} elsif($out->{'earnings_unit'.$i} >= $eitc_plateau_start && $out->{'earnings_unit'.$i} < $eitc_plateau_end) { 
					$potential_state_eitc_recd = &round($state_childless_eitc_pct * $eitc_max_value); 
				} elsif($out->{'earnings_unit'.$i} >= $eitc_plateau_end && $out->{'earnings_unit'.$i} < $eitc_income_limit) { 
					$potential_state_eitc_recd = &round($state_childless_eitc_pct * $eitc_phaseout_rate * ($eitc_income_limit - $out->{'earnings_unit'.$i})); 
				}
					
				#Then, we check if the conditions are met for the EITC to be determined by gross income, which occurs when gross income is higher than earned income and gross income exceeds the beginning of the EITC's phase-out period. The EITC is the smaller of these two calculations. 
				
				if ($out->{'gross_income'.$i} > $out->{'earnings_unit'.$i} && $out->{'gross_income'.$i} >= $eitc_plateau_end && $out->{'gross_income'.$i} < $eitc_income_limit) {
					$state_eitc_recd = &round(&least($potential_state_eitc_recd,$state_childless_eitc_pct * $eitc_phaseout_rate * ($eitc_income_limit - $out->{'gross_income'.$i})));
				}
			}
		}
		#ADDITIONAL REFUNDABLE CREDITS
		
		#Somewhat counterintuitively given their names, you do not have to pay property tax to receive the property tax fairness credit, and the Sales Tax Fairness Credit is not at all contingent on how much you pay in sales tax.
		
		#Property Tax Fairness Credit (Schedule PTFC/STFC and instructions)
		# It's notable that Maine is one of the few states that offer a tax credit based on rent paid.
		
		#Schedule PTFC/STFC begins with income limits for the PTFC. We can ignore these limits, however, because that criteria is built into the the maximum credit allowable; there is no mathematical way a filer can receive the credit with incomes above the income limits.
		
		if ($in->{'state_ptfc'} && $i == 1) { #Only doing this once, for the first filing unit. This seems realistic and optimizing, because only the first filing unilt can include chldren and therefore may be entitled to a higher credit.
			if ($in->{'heat_in_rent'} == 1) {
				$state_ptfc_applicable_rent = $out->{'rent_paid'} - $state_pftc_util_portion_est * $out->{'rent_paid'};
			} else {
				$state_ptfc_applicable_rent = &pos_sub($out->{'rent_paid'}, 12 * $out->{'energy_cost'}) #We multiply energy costs (an output in the fsp (SNAP) module by 12 to get annual utility costs.
			}
			
			$state_ptfc_rent_base = $state_ptfc_rent_portion * $state_ptfc_applicable_rent;
			
			if ($out->{'filing_status'.$i} eq 'Single') {
				$state_ptfc_max_base = 2100; 
			} elsif ($out->{'filing_status'.$i} eq 'Head of Household') {
				if ($in->{'child_number'} <= 1) {
					$state_ptfc_max_base = 2700; 
				} else {
					$state_ptfc_max_base = 3350; 
				}
			} else { # for "Married". Does not seem like this credit is offered to married filing separately.
				if ($in->{'child_number'} == 0) {
					$state_ptfc_max_base = 2700; 
				} else {
					$state_ptfc_max_base = 3350; 
				}
			}
			
			$state_ptfc_benefit_base = &least($state_ptfc_rent_base, $state_ptfc_max_base);
			if ($state_ptfc_phaseout_rate * $state_gross_income > $state_ptfc_benefit_base) {
				$state_ptfc_recd = 0;
			} else {
				$state_ptfc_benefit_base_reduced =  $state_ptfc_benefit_base - $state_ptfc_phaseout_rate * $state_gross_income;
				$state_ptfc_recd = &least($state_ptfc_benefit_base_reduced, $state_pftc_max_credit_nonelderly);
			}
		}
		
		#Sales Tax Fairness Credit:
		if ($in->{'state_stfc'}) {
			if ($out->{'filing_status'.$i} eq 'Single') {
				for ($state_gross_income) {
					$state_stfc_recd =  ($_ <= 21100)  ?    125 :
										($_ <= 21600)  ?    115 :
										($_ <= 22100)  ?    105 :
										($_ <= 22600)  ?    95 :
										($_ <= 23100)  ?    85 :
										($_ <= 23600)  ?    75 :
										($_ <= 24100)  ?    65 :
										($_ <= 24600)  ?    55 :
										($_ <= 25100)  ?    45 :
										($_ <= 25600)  ?    35 :
										($_ <= 26100)  ?    25 :
										($_ <= 26600)  ?    15 :
										($_ <= 27100)  ?    5 :
												  0;
				}
			} elsif ($out->{'filing_status'.$i} eq 'Married') {
				if ($in->{'child_number'} == 0) {
					$state_stfc_recd =  ($_ <= 42200)  ?    180 :
										($_ <= 43200)  ?    160 :
										($_ <= 44200)  ?    140 :
										($_ <= 45200)  ?    120 :
										($_ <= 46200)  ?    100 :
										($_ <= 47200)  ?    80 :
										($_ <= 48200)  ?    60 :
										($_ <= 49200)  ?    40 :
										($_ <= 50200)  ?    20 :
										($_ <= 51200)  ?    0 :
										($_ <= 52200)  ?    0 :
										($_ <= 53200)  ?    0 :
										($_ <= 54200)  ?    0 :
												  0;
				} elsif ($in->{'child_number'} == 1) {
					$state_stfc_recd =  ($_ <= 42200)  ?    205 :
										($_ <= 43200)  ?    185 :
										($_ <= 44200)  ?    165 :
										($_ <= 45200)  ?    145 :
										($_ <= 46200)  ?    125 :
										($_ <= 47200)  ?    105 :
										($_ <= 48200)  ?    85 :
										($_ <= 49200)  ?    65 :
										($_ <= 50200)  ?    45 :
										($_ <= 51200)  ?    25 :
										($_ <= 52200)  ?    5 :
										($_ <= 53200)  ?    0 :
										($_ <= 54200)  ?    0 :
												  0;
				} else { # if ($in->{'child_number'} > 1) {
					$state_stfc_recd =  ($_ <= 42200)  ?    230 :
										($_ <= 43200)  ?    210 :
										($_ <= 44200)  ?    190 :
										($_ <= 45200)  ?    170 :
										($_ <= 46200)  ?    150 :
										($_ <= 47200)  ?    130 :
										($_ <= 48200)  ?    110 :
										($_ <= 49200)  ?    90 :
										($_ <= 50200)  ?    70 :
										($_ <= 51200)  ?    50 :
										($_ <= 52200)  ?    30 :
										($_ <= 53200)  ?    10 :
										($_ <= 54200)  ?    0 :
												  0;
				}
			} else { # $out->{'filing_status'.$i} eq 'Head of Household'
				if ($in->{'child_number'} <= 1) {
					$state_stfc_recd =  ($_ <= 31650)  ?    180 :
										($_ <= 32400)  ?    165 :
										($_ <= 33150)  ?    150 :
										($_ <= 33900)  ?    135 :
										($_ <= 34650)  ?    120 :
										($_ <= 35400)  ?    105 :
										($_ <= 36150)  ?    90 :
										($_ <= 36900)  ?    75 :
										($_ <= 37650)  ?    60 :
										($_ <= 38400)  ?    45 :
										($_ <= 39150)  ?    30 :
										($_ <= 39900)  ?    15 :
										($_ <= 40650)  ?    0 :
										($_ <= 41400)  ?    0 :
										($_ <= 42150)  ?    0 :
										($_ <= 42900)  ?    0 :
												  0;
				} elsif ($in->{'child_number'} == 1) {
					$state_stfc_recd =  ($_ <= 31650)  ?    205 :
										($_ <= 32400)  ?    190 :
										($_ <= 33150)  ?    175 :
										($_ <= 33900)  ?    160 :
										($_ <= 34650)  ?    145 :
										($_ <= 35400)  ?    130 :
										($_ <= 36150)  ?    115 :
										($_ <= 36900)  ?    100 :
										($_ <= 37650)  ?    85 :
										($_ <= 38400)  ?    70 :
										($_ <= 39150)  ?    55 :
										($_ <= 39900)  ?    40 :
										($_ <= 40650)  ?    25 :
										($_ <= 41400)  ?    10 :
										($_ <= 42150)  ?    0 :
										($_ <= 42900)  ?    0 :
												  0;
				} elsif ($in->{'child_number'} == 1) {
					$state_stfc_recd =  ($_ <= 31650)  ?    230 :
										($_ <= 32400)  ?    215 :
										($_ <= 33150)  ?    200 :
										($_ <= 33900)  ?    185 :
										($_ <= 34650)  ?    170 :
										($_ <= 35400)  ?    155 :
										($_ <= 36150)  ?    140 :
										($_ <= 36900)  ?    125 :
										($_ <= 37650)  ?    110 :
										($_ <= 38400)  ?    95 :
										($_ <= 39150)  ?    80 :
										($_ <= 39900)  ?    65 :
										($_ <= 40650)  ?    50 :
										($_ <= 41400)  ?    35 :
										($_ <= 42150)  ?    20 :
										($_ <= 42900)  ?    5 :
												  0;
				}
			}
		}
		
		#Totals, including some cumulative totals:
		${'total_nonrefundable_credits'.$i} = &least(${'state_tax_gross'.$i}, $dep_exempt_credit_potential + $state_cadc_nonrefundable + $state_adultcare_credit_nonrefundable);

		${'total_refundable_credits'.$i} = $state_cadc_refundable + $state_adultcare_credit_refundable +  $state_eitc_recd + $state_ptfc_recd + $state_stfc_recd;

		$state_tax_net = ${'state_tax_gross'.$i} - ${'total_nonrefundable_credits'.$i};
		
		$state_tax += $state_tax_net - ${'total_refundable_credits'.$i};

		$state_tax_credits += ${'total_nonrefundable_credits'.$i} + ${'total_refundable_credits'.$i};			
	}
	
	$state_tax_gross = $state_tax_gross1 + $state_tax_gross2 + $state_tax_gross3 + $state_tax_gross4; 
	
	# Determine local taxes, if any:
	# As indicated above, there are no local income taxes in Maine.
	
	# We use the term "tax before credits" to refer to tax before refundable credits, as it is used for the "total expenses" calculation, but this may deserve some rethinking.
    $tax_before_credits = $out->{'federal_tax_gross'} + $state_tax_gross;
    $tax_after_credits = $tax_before_credits - $out->{'federal_tax_credits'} - $state_tax_credits;

	#debugs
    foreach my $debug (qw(state_tax_net state_tax county_tax state_tax_gross state_tax_credits tax_before_credits tax_after_credits dep_exempt_credit_potential state_cadc_nonrefundable state_adultcare_credit_nonrefundable state_cadc_refundable state_adultcare_credit_refundable state_eitc_recd state_ptfc_recd state_stfc_recd state_cadc_potential)) {
		print $debug.": ".${$debug}."\n";
	}
	
	# outputs
    foreach my $name (qw(state_tax county_tax state_tax_gross state_tax_credits tax_before_credits tax_after_credits dep_exempt_credit_potential state_cadc_nonrefundable state_adultcare_credit_nonrefundable state_cadc_refundable state_adultcare_credit_refundable state_eitc_recd state_ptfc_recd state_stfc_recd)) {
       $out->{$name} = ${$name};
    }

}
1;