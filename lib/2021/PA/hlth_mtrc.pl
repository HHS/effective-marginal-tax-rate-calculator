#=============================================================================#
#  Public Health Insurance -- PA 2021 
#=============================================================================#
#	
#Inputs referenced in this module:
#
#   INPUTS:
#   	hlth
#		child_number
#		family_structure
#		parent#_age
# 		child#_age
#		privateplan_type
#		hlth_amt_family_m
#		hlth_amt_parent_m
#		premium_tax_credit
#   	userplantype
#   	hlth_costs_oop_m
#		disability_parent#
#
#   FROM FEDHEALTH: 
#		max_income_pct_employer
#		hlth_gross_income_m
#		private_max
#		percent_of_poverty
#		percent_of_poverty_ssi
#		sub_minimum
#		sub_maximum
#
#	FROM SSI
#		ssi_recd
#
# ============================================================================#	
# NOTE: USING https://www.dhhs.nh.gov/mam_htm/newmam.htm. 
# NOTE: This code focuses on MAGI categories and SSI Medicaid, but can eventually be expanded to include non-MAGI Mediciad categories. It does not cover:
# 1. Medical assistance for the elderly, blind, and disabled, through the Old Age Assistance (OAA), Aid to the Needy Blind (ANB), and Aid to the Permanently and Totally Disabled (APTD) Programs;
# 2. The Medicare Savings Programs (MSP), which is the Qualified Medicare Beneficiary (QMB), Qualified Disabled and Working Individuals (QDWI), and Specified Low Income Medicare Beneficiary (SLMB and SLMB135) programs;
# 3. Medicaid for Employed Adults with Disabilities (MEAD);
# 4. Home Care for Children with Severe Disabilities (HC-CSD);
# OAA Cash-Related Medical Assistance
# ANB Cash-Related Medical Assistance
# APTD Cash-Related Medical Assistance
# NHEP Regular Cash-Related Medical Assistance
# FAP Regular Cash-Related Medical Assistance
# Health Insurance Premium Payment (HIPP) Program: https://www.dhhs.nh.gov/oii/hipp.htm
#
#=============================================================================#

sub hlth
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};
	
	# Policy variables. These will need to be checked or updated annually. We may end up putting them in the database.
    our $a27yo_premium = 274.17;  # This is the monthly premium for the second-lowest cost silver plan (SLCSP) for 27-year-olds in Allegheny County. Attained from https://www.healthcare.gov/health-and-dental-plan-datasets-for-researchers-and-issuers/. Updated in 2021.
    our $a27yo_premium_ratio = 1.048;  # This is the federally-mandated premium ratio for 27-year-olds. As of 2021, this has not changed since 2016. Available at https://www.cms.gov/CCIIO/Resources/Regulations-and-Guidance/Downloads/Final-Guidance-Regarding-Age-Curves-and-State-Reporting-12-16-16.pdf. 

	our $child_1to5_medicaid_limit = 1.62;    # child income limit as % of FPG for children ages 1 to 5. This is 215% MAGI Medicaid income limit plus teh 5% MAGI disregard.
	our $child_6to18_medicaid_limit = 1.38;    # child income limit as % of FPG for children 6-18. This is 215% MAGI Medicaid income limit plus teh 5% MAGI disregard.
	our $child_age0_medicaid_limit = 2.20;    # child income limit as % of FPG for children less than 1 and pregnant women. This is 215% MAGI Medicaid income limit plus teh 5% MAGI disregard.
	our $child_chip_limit = 3.19;    # child income limit as % of FPG. This is the limit on CHIP, below which there are premiums.
	our $parent_medicaid_limit = 1.38;  # adult income limit as % of FPG. It's 133% plus the 5% MAGI disregard.
	our $mawd_medicaid_limit = 2.5; #The limit for eligibility for participants in PA's MAWD program, which covers former SSI and SSDI beneficiaries who are working. It is a non-MAGI Medicaid program. Income is based largely on SSI rules, and while there seem to be some slight differences, we are using SSI-determined income as a proxy for income for this program for now. THere are also premiums in this program, which are suspended during the COVID emergency period. See http://services.dpw.state.pa.us/oimpolicymanuals/ma/index.htm#t=316_MAWD%2F316_01_General_Policy.htm.
	our $mawd_single_income_limit = 2684; # The MAWD income limit at 250% of the federal poverty level in 2021, but specifically as published in the MA handbook. See http://services.dpw.state.pa.us/oimpolicymanuals/ma/316_MAWD/316_Appendix_A.htm
	our $mawd_married_income_limit = 3630;

	# outputs created
	our $hlth_cov_parent1 = 'NA';   #@ health insurance status of parent1 (Medicaid, employer, nongroup, user-entered). 
    our $hlth_cov_parent2 = 'NA';   #@ health insurance status of parent2. See above for explanation.
    our $hlth_cov_parent3 = 'NA';   #@ health insurance status of parent2. See above for explanation.
    our $hlth_cov_parent4 = 'NA';   #@ health insurance status of parent2. See above for explanation.
    our $hlth_cov_parent = 'NA';   #@ health insurance status of adults (Medicaid, employer, nongroup, user-entered, or a mix). It is a concatenated variable when adults do not have the same coverage.
	our $adult_medicaid_count = 0; #How many adults in the hh are on Medicaid.
	our $adult_chip_count = 0;
	our $hlth_cov_child_all = 'NA';  # health insurance status of all children (Medicaid, employer, individual, or a mix)
    our $hlth_cov_child1 = 'NA';  # health insurance status of Child 1 (Medicaid, employer, individual)
    our $hlth_cov_child2 = 'NA';  # health insurance status of child 2 (Medicaid, employer, individual)
    our $hlth_cov_child3 = 'NA';  # health insurance status of child 3 (Medicaid, employer, individual)
    our $hlth_cov_child4 = 'NA';  # health insurance status of child 4 (Medicaid, employer, individual). 
    our $hlth_cov_child5 = 'NA';  # health insurance status of child 5 (Medicaid, employer, individual). 
    our $health_expenses = 0;       # final annual cost of health insurance for family
	our $premium_credit_recd = 0;
    our $health_expenses_before_oop = 0;    # Health expenses before out-of-pocket medical costs are considered.  # This variable is only used by the BNBC program.                                  
    our $parent1_premium = 0;
    our $parent2_premium = 0;
    our $parent3_premium = 0;
    our $parent4_premium = 0;
	our $child1_premium_ratio = 0;  
	our $child2_premium_ratio = 0; 
	our $child3_premium_ratio = 0; 
	our $child4_premium_ratio = 0; 
	our $child5_premium_ratio = 0; 
	our $parent1_premium_ratio = 0;  
	our $parent2_premium_ratio = 0; 
	our $parent3_premium_ratio = 0; 
	our $parent4_premium_ratio = 0; 
	our $ssi_recipient_exclusion = 0; #States seem to have some discretion over who is included in assistance groups for determining MAGI eligibility, and how to treat the income of individuals in the assistance group. Some states or areas, like DC at least at one point, treat SSI recipients as their own assistance group, and exclude their income from eligibility determinations of other assistance groups in the household. According to the NH Medicaid rulebook, however, all people who file taxes jointly should be considered a single assistance group, meaning that their income is counted in determining eligibiltiy for MAGI Medicaid. (See MAM sections 505 ("Whose Income Counts?") and 259.03 ("Tax Filer Rules and Non-Filer Rules for MAGI (MAM)")

	# ADDITIONAL VARIABLES USED
    our $premium_tax_credit = $in->{'premium_tax_credit'};

    # CALCULATED IN MACRO 
    our $sub_family_cost = 0;            # The cost of marketplace insurance for family members covered, after considering federal subsidies   
    our $sub_parent_cost = 0;            # The cost of marketplace insurance for parents, after considering federal subsidies  
    our $parent_cost_individual = 0;        # The unsubsidized cost of health insurance premium(s) for the parent(s) in the family available on the federal marketplace   
    our $family_cost_individual = 0;        # The unsubsidized cost of health insurance premiums for the entire family available on the federal marketplace
    our $parent_cost_employer = 0;       # The cost of health insurance premiums for parent(s) available to employees based on a hypothetical health insurance plan using MEPS data.
    our $family_cost_employer = 0;       # The cost of health insurance premiums for the entire family available to employees based on a hypothetical health insurance plan using MEPS data.
    our $familyswitch_dummy = 0;         # A dummy variable that switches from N to Y if employer-provided family health insurance is unaffordable enough to necessitate a switch to nongroup (subsidized) insurance.																																							 
    our $parentswitch_dummy = 0;         # A dummy variable that switches from N to Y if employer-provided parent health insurance is unaffordable enough to necessitate a switch to nongroup (subsidized) insurance.
    our $family_cost = 0;
    our $parent_cost = 0;
	our $self_only_coverage = $in->{'self_only_coverage'}; #This is from the MEPS tables.
    our $hlth_costs_oop_m = $in->{'hlth_costs_oop_m'};
	our $parent1_premium_individual = 0;
	our $parent2_premium_individual = 0;		
	our $parent3_premium_individual = 0;		
	our $parent4_premium_individual = 0;

	#Added now that we're tracking this to filing status:
	our $parent1_cost_individual = 0;
	our $parent2_cost_individual = 0;
	our $parent3_cost_individual = 0;
	our $parent4_cost_individual = 0;
	our $parent_cost_individual_unit1 = 0;
	our $parent_cost_individual_unit2 = 0;
	our $parent_cost_individual_unit3 = 0;
	our $parent_cost_individual_unit4 = 0;
	our $parent_cost_employer_unit1  = 0;
	our $parent_cost_employer_unit2  = 0;
	our $parent_cost_employer_unit3  = 0;
	our $parent_cost_employer_unit4  = 0;
	our $unit1_medicaid_flag = 0;
	our $unit1_medicaid_count = 0;
	our $sub_parent_cost1 = 0;
	our $sub_parent_cost2 = 0;
	our $sub_parent_cost3 = 0;
	our $sub_parent_cost4 = 0;
	our $parent_cost1 = 0;
	our $parent_cost2 = 0;
	our $parent_cost3 = 0;
	our $parent_cost4 = 0;
	our $parentswitch_dummy_otherunits  = 0;
	our $parentswitch_dummy1 = 0;
	our $parentswitch_dummy2 = 0;
	our $parentswitch_dummy3 = 0;
	our $parentswitch_dummy4 = 0;
	our $parent_cost_individual_total = 0;
	our $family_cost_individual_total = 0;
	our $child_medicaid_count = 0;
	our $child_chip_count = 0;
	our $chip_premiums = 0;
	our $adult_medicaidchip_premiums = 0;
	our $marketplace_flag = 0;
	our $parent1_mawd = 0; #Helpful for assigning MAWD premiums.						
	our $parent2_mawd = 0; #Helpful for assigning MAWD premiums.						
	our $parent3_mawd = 0; #Helpful for assigning MAWD premiums.						
	our $parent4_mawd = 0; #Helpful for assigning MAWD premiums.						


    # Start debug variables
    our $hlth = $in->{'hlth'};
    our $family_structure = $in->{'family_structure'};
    our $child_number = $in->{'child_number'};
    # our $magi_disregard = $out->{'magi_disregard'}; 
    our $privateplan_type = $in->{'privateplan_type'};
    #our $userplantype = $in->{'userplantype'};
    #our $userplantype = $in->{'userplantype'};
	our $hlth_plan_estimate_source = $in->{'hlth_plan_estimate_source'};
	our $sub_minimum = $out->{'sub_minimum'};
    our $sub_maximum = $out->{'sub_maximum'};
    our $premium_tax_credit = $in->{'premium_tax_credit'};
    our $max_income_pct_employer = $out->{'max_income_pct_employer'};
    our $hlth_gross_income_m = $out->{'hlth_gross_income_m'};

	#Set up dummy variable to indicate whether or not child care has been run yet. (This can be important for later codes) 
	our $firstrunchildcare = 1;
    # End debug variables

 
	# TABLE ARRAYS
	our @premium_ratioarray = (0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.833, 0.859, 0.885, 0.851, 0.941, 0.97, 1, 1, 1, 1, 1.004, 1.024, 1.048, 1.087, 1.119, 1.135, 1.159, 1.183, 1.198, 1.214, 1.222, 1.23, 1.238, 1.246, 1.262, 1.278, 1.302, 1.325, 1.357, 1.397, 1.444, 1.5, 1.563, 1.635, 1.706, 1.786, 1.865, 1.952, 2.04, 2.135, 2.23, 2.333, 2.437, 2.548, 2.603, 2.714, 2.81, 2.873, 2.952, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3); #These are the age curve ratios from 0 to 100, established by the federal government.

	for(my $i=1; $i<=4; $i++) {
		if ($in->{'parent'.$i.'_age'} > -1) {
			${'parent'.$i.'_premium_ratio'} = $premium_ratioarray[$in->{'parent'.$i.'_age'}];  
		}
	}
	for(my $i=1; $i<=5; $i++) {
		if ($in->{'child'.$i.'_age'} > -1) {
			${'child'.$i.'_premium_ratio'} = $premium_ratioarray[$in->{'child'.$i.'_age'}];  
		}
	}
	

    # 1.  Check Public Health flag and premium tax credit flag
    #

    if ($in->{'hlth_plan_estimate_source'} eq 'user-entered' && ($in->{'privateplan_type'} eq 'employer' || $in->{'premium_tax_credit'} == 0)) { #premium_tax_credit will always be set to 1 in the MTRC. Including it here to illustrate that if a user has entered their own health cost for an employer plan, it will not change with income, but if  a user has entered their own health costs and it's a marketplace plan, it can change with income.
        $parent_cost = $in->{'hlth_amt_parent_m'} * 12;
		if ($in->{'child_number'} > 0) {
			$family_cost = $in->{'hlth_amt_family_m'} * 12;
		}
    }

	if ($in->{'hlth'} == 0 && $in->{'premium_tax_credit'} == 0) { #No Medicaid, no PTC. This doesn't happen in the MTRC since we always set premium_tax_credit to 1. So not worrying too much about this if-block for now.
		if ($in->{'privateplan_type'} eq 'employer' && $in->{'hlth_plan_estimate_source'} eq 'calc_estimate') {	#The user has opted to use the calculator estimates for employer insurance.			
			# For the MTRC, we generate employer healthcare costs from inputs generated by database lookups within the user interface:
			$parent_cost = $in->{'hlthins_parent_cost_m_'.$in->{'family_structure'}.'adult'} * 12;
			$family_cost = $in->{'hlthins_family_cost_m_'.$in->{'family_structure'}.'adult'} * 12;

			# For the MTRC, the below hardcoding has been replaced by inputs generated from database lookups in the user interface:
			# $self_only_coverage = 1618;
			# if ($in->{'family_structure'} == 1) {
			#	$parent_cost =  1618;
			#	$family_cost = qw(0 4066 5535 5535 5535 5535)[$in->{'child_number'}];
			#} elsif ($in->{'family_structure'} >= 2) {
			#	#This is from MEPS. So we need to figure out how to model unsubsidized health care for larger families. I think reasonably, you could 
			#	$parent_cost = 4066; #average employee plus one coverage for NH, according to MEPS
			#	$family_cost = 5535; #average employee plus family coverage for NH, according to MEPS
			#}
				
			for (my $i=1; $i<=4; $i++) {
				if ($in->{'parent'.$i.'_age'} > -1) {
					${'hlth_cov_parent'.$i} = 'employer';
				}
			}
		} elsif ($in->{'hlth_plan_estimate_source'} ne 'user-entered') { #Marketplace plans, unless the user has entered overrides:
			# We use the premiums for 27-year-olds to determine the cost for parents and children.
			# Parent1:
			for(my $i=1; $i<=4; $i++) {
				if ($in->{'parent'.$i.'_age'} > -1) {
					${'parent'.$i.'_premium'} = (${'parent'.$i.'_premium_ratio'}/$a27yo_premium_ratio) * $a27yo_premium;
				}
			}
			$parent_cost = 12*($parent1_premium + $parent2_premium + $parent3_premium + $parent4_premium );
			$family_cost = $parent_cost;
			for(my $i=1; $i<=5; $i++) {
				if ($in->{'child'.$i.'_age'} > -1) {
					$family_cost += (${'child'.$i.'_premium_ratio'}/$a27yo_premium_ratio) *$a27yo_premium *12;
				}
			}
		}
		
	} else {

		# 1. Determine family’s eligibility for coverage
		#
		# We now apply MAGI income limits and disregards based on adult and child limits. There may be separate eligibility criteria for non-MAGI Medicaid options, beyond Medicaid covered by SSI, but we are not including them in the MTRC for now. 

		if ($in->{'hlth'}== 1) { 

			# ADULT MEDICAID COVERAGE
			
			# Check for eligibility for adult Medicaid. Unlike predecessores to the MTRC, we are assigning this for each adult in the household rather than tryign to figure out a collective variable (hlth_cov_parent) initially that was made assuming that parents were either jointly eligible or jointly ineligible for Medicaid. As the code has become more complicated, it has become necessary to separate out eligibility for each adult. There are numerous paths each adult can become eligible for Medicaid.

			for(my $i=1; $i<=4; $i++) {
				if ($in->{'parent'.$i.'_age'} > -1) {
					if ($out->{'percent_of_poverty_parent'.$i.'_medicaid'} <= $parent_medicaid_limit) {
						${'hlth_cov_parent'.$i} = 'Medicaid';
					} elsif ($in->{'parent'.$i.'_age'}==18 && $out->{'percent_of_poverty_parent'.$i.'_medicaid'} <= $child_medicaid_limit) {  
						${'hlth_cov_parent'.$i} = 'Medicaid';
					} elsif (${'parent'.$i.'_SSI'} == 1) {  #Anyone on SSI is eligible for Medicaid.
						${'hlth_cov_parent'.$i} = 'Medicaid';
					} elsif ($in->{'parent'.$i.'_continuous_coverage'} == 1 && $in->{'covid_medicaid_expansion'} == 1) {  #This is continuous coverage under COVID expansion rules.
						${'hlth_cov_parent'.$i} = 'Medicaid';
					} elsif ($in->{'disability_parent'.$i} == 1 && $out->{'parent'.$i.'_earnings'} > 0 && (($out->{'parent'.$i.'ssi_married'} == 0 && $out->{'parent'.$i.'_ssi_income'}  <= $mawd_single_income_limit) || ($out->{'parent'.$i.'ssi_married'} == 1 && $out->{'parent'.$i.'_ssi_income'} <= $mawd_married_income_limit))) { 
						#These are the non-resource eligibility criteria the MAWD program in Pennsylvania. Other states have similar programs. We are definiing disability as former receipt of SSI or SSDI, which is a qualifying condition for MAWD Medicaid. As we are not asking about assets/resources in the MTRC, we are excluding those criteria for this program for now. THe program has a $10,000 asset test. This covers the "Worker with a Disability" category in PA; we are not considering (for now) the "Worker with a Medically Improved Disability." The distinction between the two is largely whether the person formerly has received SSI/SSDI or not, with the latter being non-beneficiaries, and therefore there is a work requirement attached to that category (40 hours/month). We are defining disability in the MTRC as whether someone received SSI/SSDI int the past, so only the "Worker with a disabiltiy" category is relevant here. 
						#Note that for MAWD, the unit is composed of only the SSI eligible individual and their spouse if they have one. Children are not counted.
						${'hlth_cov_parent'.$i} = 'Medicaid';
						${'parent'.$i.'_mawd'} = 1; #Helpful for assigning MAWD premiums.						
						print "debug4 \n";
					} elsif ($ssi_recipient_exclusion == 1 && ($out->{'percent_of_poverty_ssi'}  <= $parent_medicaid_limit || ($in->{'parent'.$i.'_age'} == 18 && $out->{'percent_of_poverty_ssi'} <= $child_medicaid_limit))) { 
						${'hlth_cov_parent'.$i} = 'Medicaid'; 
					} elsif ($in->{'parent'.$i.'_age'}==18 && $out->{'percent_of_poverty_parent'.$i.'_medicaid'} <= $child_chip_limit) {  
						${'hlth_cov_parent'.$i} = 'CHIP';
						# print "debug1 hlth_cov_parent$i: ${'hlth_cov_parent'.$i} \n"; 
						# print "debug1 hlth_cov_parent: $hlth_cov_parent \n"; 
					} elsif ($ssi_recipient_exclusion == 1 && ($out->{'percent_of_poverty_ssi'}  <= $parent_medicaid_limit || ($in->{'parent'.$i.'_age'} == 18 && $out->{'percent_of_poverty_ssi'} <= $child_chip_limit))) { 
						${'hlth_cov_parent'.$i} = 'CHIP';
					}
					
					if (${'hlth_cov_parent'.$i} eq 'Medicaid') {
						$adult_medicaid_count +=1;
					}
					if (${'hlth_cov_parent'.$i} eq 'CHIP') {
						$adult_chip_count +=1;
						#CHIP premiums (for adults)
						#Because it's easier to do this up here rather than down below.
						if ($out->{'percent_of_poverty_parent'.$i.'_medicaid'} <= 2.08) {
							$adult_medicaidchip_premiums += 0;	#monthly chip premiums are $52 for this low income bracket.
						} elsif ($out->{'percent_of_poverty_parent'.$i.'_medicaid'} <= 2.62) {
							$adult_medicaidchip_premiums += 52*12;	#monthly chip premiums are $52 for this low income bracket.
						} elsif ($out->{'percent_of_poverty_parent'.$i.'_medicaid'} <= 2.88) {
							$adult_medicaidchip_premiums += 75*12;	
						} elsif ($out->{'percent_of_poverty_parent'.$i.'_medicaid'} <= 3.19) {
							$adult_medicaidchip_premiums += 86*12;
						}
					}
					
					if (${'parent'.$i.'_mawd'} == 1 && $in->{'covid_medicaid_expansion'} == 0) { #Participation in the MAWD programs includes a premium, but those are largely waived durig the COVID pandemic. Technically they are only waived for individuals enrolling in MAWD after the pandemic hit, but to reduce question burden, we are not asking when, exactly, people enrolled in certain types of Medicaid programs.
						$adult_medicaidchip_premiums += .5 * $out->{'parent'.$i.'_ssi_income'} * 12;
					}
				}
			} 
			# We now define the concatenated "hlth_cov_parent" variable.
			if ($adult_medicaid_count + $adult_chip_count > 0) {
				if ($adult_medicaid_count > 0) {
					$hlth_cov_parent = 'Medicaid'; #We first set this to Medicaid and then adjust it if any of the other adults int eh family are not Medicaid eligible.
					if ($adult_chip_count > 0) {
						$hlth_cov_parent = 'Medicaid and CHIP'; #We first set this to Medicaid and then adjust it if any of the other adults int eh family are not Medicaid eligible.
						for(my $i=1; $i<=4; $i++) {	
							if ($in->{'parent'.$i.'_age'} > -1 && ${'hlth_cov_parent'.$i} ne 'Medicaid' && ${'hlth_cov_parent'.$i} ne 'CHIP') {
								$hlth_cov_parent = 'Medicaid, CHIP, and private';
								${'hlth_cov_parent'.$i} = $in->{'privateplan_type'};
							} 
						}
					} else {
						for(my $i=1; $i<=4; $i++) {	
							if ($in->{'parent'.$i.'_age'} > -1 && ${'hlth_cov_parent'.$i} ne 'Medicaid') {
								$hlth_cov_parent = 'Medicaid and private';
								${'hlth_cov_parent'.$i} = $in->{'privateplan_type'};
							} 
						}
					}
				} else {
					$hlth_cov_parent = 'CHIP'; #We first set this to Medicaid and then adjust it if any of the other adults int eh family are not Medicaid eligible.
					for(my $i=1; $i<=4; $i++) {	
						if ($in->{'parent'.$i.'_age'} > -1 && ${'hlth_cov_parent'.$i} ne 'CHIP' && ${'hlth_cov_parent'.$i} ne 'CHIP') {
							$hlth_cov_parent = 'CHIP and private';
							${'hlth_cov_parent'.$i} = $in->{'privateplan_type'};
						} 
					}
				}	
			} else {
				$hlth_cov_parent = $in->{'privateplan_type'}; 
				for(my $i=1; $i<=4; $i++) {	
					if ($in->{'parent'.$i.'_age'} > -1) {
						${'hlth_cov_parent'.$i} = $in->{'privateplan_type'};
					}
				}
			}

			#
			# CHILDREN'S COVERAGE  	
			# Note that in PA, there are several potential Medicaid limits for children. We need to decouple this coverage from CHIP because CHIP has premiums and some program -- like WIC -- may rely on Medicaid eligibility as categorical but not CHIP.
			for(my $i=1; $i<=$in->{'child_number'}; $i++) {
				if (($in->{'child'.$i.'_age'} == 0 && $out->{'percent_of_poverty_children_medicaid'} <= $child_age0_medicaid_limit) || ($in->{'child'.$i.'_age'} >= 1 && $in->{'child'.$i.'_age'} <= 5 && $out->{'percent_of_poverty_children_medicaid'} <= $child_1to5_medicaid_limit) || $out->{'percent_of_poverty_children_medicaid'} <= $child_6to18_medicaid_limit) { 
					${'hlth_cov_child'.$i} = 'Medicaid';
					$child_medicaid_count +=1;
					print "debug1 \n";
				} elsif ($in->{'child_continuous_coverage'} == 1 && $in->{'covid_medicaid_expansion'} == 1) {  #This is continuous coverage under COVID expansion rules. At this point in time, we are asssuming that if one child is continuously covered, they all are. We do not yet include child disability, which is really the only case where certain children are on Medicaid/CHIP and others aren't in the same tax filing unit.
					${'hlth_cov_child'.$i} = 'Medicaid';
					$child_medicaid_count +=1;
					print "debug2 \n";
				} elsif ($out->{'percent_of_poverty_children_medicaid'} <= $child_chip_limit) {
					${'hlth_cov_child'.$i} = 'CHIP';
					$child_chip_count += 1;
					
					#CHIP premiums
					#Because it's easier to do this up here rather than down below.
					if ($out->{'percent_of_poverty_children_medicaid'} <= 2.08) {
						$chip_premiums += 0;	#monthly chip premiums are $52 for this low income bracket.
					} elsif ($out->{'percent_of_poverty_children_medicaid'} <= 2.62) {
						$chip_premiums += 52*12;	#monthly chip premiums are $52 for this low income bracket.
					} elsif ($out->{'percent_of_poverty_children_medicaid'} <= 2.88) {
						$chip_premiums += 75*12;	
					} elsif ($out->{'percent_of_poverty_children_medicaid'} <= 3.19) {
						$chip_premiums += 86*12;
					}
				}
			}
			if ($in->{'child_number'} == $child_medicaid_count) {
					#Not sure this is necessary.
					$hlth_cov_child_all = 'Medicaid';
			} elsif ($in->{'child_number'} == $child_chip_count) {
					#Not sure this is necessary.
					$hlth_cov_child_all = 'CHIP';
			} elsif ($in->{'child_number'} == $child_medicaid_count + $child_chip_count) {
					$hlth_cov_child_all = 'Medicaid and CHIP';
			}
				# See note above – this applies a similar methodology as above for determining eligibility when one or both parents are on SSI. If both parents are on SSI, they will both be on Medicaid due to categorical eligibility. This accounts completely for categorical eligibility for Medicaid among families in which all parents receive SSI.
				
				#Commenting this out for now. It doesn't seem relevant for MAGI Medicaid in PA.
				#} elsif ($out->{'ssi_recd'} > 0 && $out->{'percent_of_poverty_ssi'} <= $child_medicaid_limit && $ssi_recipient_exclusion == 1) { 
				#	$hlth_cov_child_all = 'Medicaid';
				#	for(my $i=1; $i<=5; $i++) {
				#		if ($in->{'child'.$i.'_age'} > -1) {
				#			${'hlth_cov_child'.$i} = 'Medicaid';
				#		}
				#	}
				#}	
		} 
		print "1. hlth_cov_child_all: $hlth_cov_child_all \n";
		# 3. Determine parent health care program
		# We now incorporate health care subsidies into the calculation of health care costs for employer or individual plans. Note that these factor into the FRS only by reducing costs, and not by being calculated as a separate benefit. None of the code in this step applies to user-entered fields, so conceivably this step could be skipped for users entering health data themselves, but none of the operations below relate to any variables necessary for calculating costs for user-entered data, so going through these steps is also a harmless exercise if health data is user-entered.

		# Use 'Health' table in base tables to determine parent_cost and family_cost based on residence, family_structure, and child_number, 
		# both for privateplan_type=individual (labeling the associated values parent_cost_individual and family_cost_individual) 
		# and for privateplan_type = employer (labeling the associated values parent_cost_employer and family_cost_employer).  Unlike previous years, we calculate premiums on the individual market based on age, using a formula instead of a lookup.

		# We use the premiums for 27-year-olds to determine the cost for parents and children.
		# The below calculation uses the “Age curve” table in  public health tables to determine premium_ratio by using parent1_age for age, and identify this as parent1_premium_ratio. Note to programmer  
		for(my $i=1; $i<=4; $i++) {	#This i is for each adult in the family.
			if ($in->{'parent'.$i.'_age'} > -1) {
				${'parent'.$i.'_premium_individual'} = (${'parent'.$i.'_premium_ratio'}/$a27yo_premium_ratio) * $a27yo_premium;
				if (${'hlth_cov_parent'.$i} ne 'Medicaid' && ${'hlth_cov_parent'.$i} ne 'CHIP') {
					${'parent'.$i.'_cost_individual'} = 12 * ${'parent'.$i.'_premium_individual'};
					# This accounts for families where at least one parent is on SSI and at least one is not eligible for Mediciad.
				}
			}
		}

		for(my $i=1; $i<=4; $i++) { #This i is for tax filing unit.
			if ($i == $out->{'filing_status1_adult1'} || $i == $out->{'filing_status1_adult2'} || $i == $out->{'filing_status1_adult3'} || $i == $out->{'filing_status1_adult4'}) {
				$parent_cost_individual_unit1 += ${'parent'.$i.'_cost_individual'};
				if (($in->{'married1'} == $i || $in->{'married2'} == $i) && (${'hlth_cov_parent'.$i} eq 'Medicaid' || ${'hlth_cov_parent'.$i} eq 'CHIP')) {
					$unit1_medicaid_flag = 1; #Useful for below calculation of employer cost for households with mixed adult Medicaid eligibility. In this case, we can treat CHIP as Medicaid.
					$unit1_medicaid_count += 1; #Useful for below calculation of employer cost for households with mixed adult Medicaid eligibility. In this case, we can treat CHIP as Medicaid.
				}
			} elsif ($i == $out->{'filing_status2_adult1'}) {
				$parent_cost_individual_unit2 += ${'parent'.$i.'_cost_individual'};
			} elsif ($i == $out->{'filing_status3_adult1'}) {
				$parent_cost_individual_unit3 += ${'parent'.$i.'_cost_individual'};
			} elsif ($i == $out->{'filing_status4_adult1'}) {
				$parent_cost_individual_unit4 += ${'parent'.$i.'_cost_individual'};
			}
		}
		
		# Including child health costs in family cost:

		#Family cost will be for just filing unit 1, since they are the only unit with children.
		
		$family_cost_individual = $parent_cost_individual_unit1;		
		# This calculation uses data from the “Age curve” table in the DC public health tables to determine premium_ratio by using child#_age for age, and identify this as child_premium_ratio. 
		for(my $i=1; $i<=5; $i++) {
			if ($in->{'child'.$i.'_age'} > -1) {
				$family_cost_individual += (${'child'.$i.'_premium_ratio'}/$a27yo_premium_ratio) *$a27yo_premium *12;
			}
		}

		for(my $i=1; $i<=$out->{'filers_count'}; $i++) { #Looking at each tax filing unit,
			if ($in-> {'privateplan_type'} eq 'employer') {		
			#	$self_only_coverage = 1618;
				if ($i == 1 && $out->{'filing_status1'} eq 'Married') {
					$parent_cost_employer_unit1 = $in->{'hlthins_parent_cost_m_2adult'} * 12;
					$family_cost_employer = $in->{'hlthins_family_cost_m_2adult'} * 12;
				} elsif ($i == 1) { #if ($out->{'filing_status1'} eq 'Head of Household' or 'Single'  
					${'parent_cost_employer_unit'.$i} = $in->{'hlthins_parent_cost_m_1adult'} * 12;
					$family_cost_employer = $in->{'hlthins_family_cost_m_1adult'} * 12; #qw(0 4066 5535 5535 5535 5535)[$in->{'child_number'}];
				} else { #for other filing units, there are no children.
					${'parent_cost_employer_unit'.$i} = $in->{'hlthins_parent_cost_m_1adult'} * 12;
				}
			}
			# Continuing our rejiggering in case of families where one parent is on Medicaid and the other not, we need to add the same outputs from SQL call again, but for a family structure of 1 instead of 2. 

			if ($i == 1 && $unit1_medicaid_flag == 1 && $unit1_medicaid_count == 1) { # In this case, tax filing unit 1 is eithe r single or a married couple in which only 1 person gets Medicaid.
				$parent_cost_employer_unit1 = $in->{'hlthins_parent_cost_m_1adult'} * 12; #costs for family_structure = 1
				$family_cost_employer = $in->{'hlthins_family_cost_m_1adult'} * 12;	#costs for family_structure = 1
			}

			if ($out->{'percent_of_poverty'.$i} >= $sub_minimum  && $in->{'premium_tax_credit'} == 1 && ($out->{'percent_of_poverty'.$i} <= $sub_maximum || $in->{'covid_ptc_expansion'} == 1)) { #ARPA removed the subsidy maximum
				# This follows IRS form 8962 in ensuring that maximum health coverage cost is the subsidized health care cost or the SLCSP, whichever is lower.
				# Note: This code, and the fed_hlth_insurance code, assumes that no one with access to employer plans and without eligibility for premium tax credits will elect a marketplace plan. This may be worth reassessing, as families in the "family glitch" may have cheaper health costs if one spouse remains on their employer plan while another takes on an unsubsidized marketplace plan. We may also be more easily able to address this by splitting up hlth_cov_parent to hlth_cov_parent1 and hlth_cov_parent2.
				${'sub_parent_cost'.$i} = &least(${'parent_cost_individual_unit'.$i}, $out->{'private_max'.$i});
				if ($i == 1) {
					$sub_family_cost = &least($family_cost_individual, $out->{'private_max1'});
				}
			} else {
				${'sub_parent_cost'.$i} = ${'parent_cost_individual_unit'.$i};
				if ($i == 1) {
					$sub_family_cost = $family_cost_individual;
				}
			}
			
			if ($in->{'privateplan_type'} eq 'individual') { #We calculate the subsidized market rate for healthcare, even when   $in->{'hlth_plan_estimate_source'} equals 'user-entered'. For users who select marketplace plans and enter a cost, we will use these figures later on to compare against the entries they make, to add or subtract from the premium.
				${'parent_cost'.$i} = ${'sub_parent_cost'.$i};
				if ($i == 1) {
					$family_cost = $sub_family_cost;
				}
			}
			# We then incorporate the ACA rule that employees whose employers don’t offer “affordable” health insurance can opt for the marketplace rates, which could also include subsidies. Per healthcare.gov, “A job-based health plan is considered ‘affordable’ if the employee’s  share of monthly premiums for the lowest-cost self-only coverage that meets the minimum value standard is less than 9.56% of their family’s income.” (This percentage has since changed with inflation, and was adjusted downward with the passage of ARPA through 2022.) While this approach could also be used for moving user-entered plans to marketplace plans (the code for that would be very similar to that below), we assume that a user-entered agent is not necessarily a rationally optimizing one and is sticking with those numbers for a reason. 

			if ($in->{'privateplan_type'} eq 'employer' && $in->{'hlth_plan_estimate_source'} ne 'user-entered') {
				# Use 'Health' table in base tables to determine self_only_coverage for privateplan_type = employer. This number changes by state.
				if ($i == 1) {
					if ($self_only_coverage > $out->{'max_income_pct_employer'} * $out->{'hlth_gross_income'.$i.'_m'} * 12 && $family_cost_employer > $sub_family_cost) {
						$familyswitch_dummy = 1;
						$family_cost = $sub_family_cost;
						for(my $j=1; $j<=4; $j++) {
							if ($in->{'parent'.$j.'_age'} > -1) {
								if (${'hlth_cov_parent'.$j} ne 'Medicaid' && ${'hlth_cov_parent'.$j} ne 'CHIP' && ($j == $out->{'filing_status1_adult1'} || $j == $out->{'filing_status1_adult2'} || $j == $out->{'filing_status1_adult3'} || $j == $out->{'filing_status1_adult4'})) {
									${'hlth_cov_parent'.$j} = 'individual';
								}
							}
						}
					} else {
						$family_cost = $family_cost_employer;
					}
				}
				
				# We also recalculate parent_cost following similar rules. Parent_cost is only used to calculate health_expenses when children are covered by Medicaid, and nowhere else. So the below calculation will only have an effect on families when their children are covered by Medicaid, and their employer plans for adults in the family are unaffordable.
				if ($self_only_coverage > $out->{'max_income_pct_employer'} * $out->{'hlth_gross_income'.$i.'_m'} * 12 && ${'parent_cost_employer_unit'.$i} > ${'sub_parent_cost'.$i}) {
					${'parent_cost'.$i} = ${'sub_parent_cost'.$i};
					$parentswitch_dummy += 1;
					${'parentswitch_dummy'.$i} = 1;
					if ($i != 1) {
						$parentswitch_dummy_otherunits += 1;
					}
					for(my $j=1; $j<=4; $j++) {
						if ($in->{'parent'.$j.'_age'} > -1) {
							if (${'hlth_cov_parent'.$j} ne 'Medicaid' && ${'hlth_cov_parent'.$j} ne 'CHIP' && ($j == $out->{'filing_status'.$i.'_adult1'} || ($i == 1 && ($j == $out->{'filing_status1_adult1'} || $j == $out->{'filing_status1_adult2'} || $j == $out->{'filing_status1_adult3'} || $j == $out->{'filing_status1_adult4'})))) {
								${'hlth_cov_parent'.$j} = 'individual';
							}	
						}
					}
				} else {
					${'parent_cost'.$i} = ${'parent_cost_employer_unit'.$i};
				}
			}
		}
	} 
	
	#    4. Determine health insurance premiums and final coverage type
	#    Medicaid programs have no premiums.  CHP programs have premiums based on income ranges. 

	if ($in->{'privateplan_type'} eq 'individual' || ($in->{'privateplan_type'} eq 'employer' && $in->{'hlth_plan_estimate_source'} ne 'user-entered')) { 
		#Early on in this code, we set parent_cost and family_cost to user entries for employer insurance, so we do not change those depending on the above calculations for employer coverage. But for marketplace coverage, we make this calculation first regardless of user overrides, and then compare this calculation against the entries provided below. 
		$parent_cost = $parent_cost1 + $parent_cost2 + $parent_cost3 + $parent_cost4; #We add the different parent costs across filing units.
		$family_cost = $family_cost + $parent_cost2 + $parent_cost3 + $parent_cost4; #Up until here, family_cost only applied to the costs in filing unit 1. We are joining it with the costs of other tax filing units to aggregage the household costs.

		#The above costs include reductions from ACA subsidies. We also gather the total unsubsidzed also gather the total unsubsidized costs for the household, so we can compare it against user overrides and estimate the value of the premium tax credit the family receives.
		
		$parent_cost_individual_total = $parent_cost_individual_unit1 + $parent_cost_individual_unit2 + $parent_cost_individual_unit3 + $parent_cost_individual_unit4;
		$family_cost_individual_total = $family_cost_individual + $parent_cost_individual_unit2 + $parent_cost_individual_unit3 + $parent_cost_individual_unit4;
	}

	#Now, we incorporate any user overrides for marketplace insurance. This gets a little complicated, but essentially for people who are already receiving ACA subsidies, we are incorporating this in a similar manner as we are other subsidies -- using any user override to determine the difference between what a household pays at baseline and the value of the subsidy at baseline, and then using that difference to adjust any future values. For people who are not receiving subsidies -- which would include people who (1) are currently on Medicaid (2) are Medicaid-eligible but who are not on Medicaid, or (3) make over 400% FPL and therefore are eligible for neither subsidies nor Medicaid -- we treat the user-entered marketplace as a cap on their premium payments. 
	if ($in->{'privateplan_type'} eq 'individual' &&  $in->{'hlth_plan_estimate_source'} eq 'user-entered') { 
		if ($out->{'scenario'} eq 'current') {
			$in->{'subsidy_initial'} = 0; #This is a flag/dummy variable that indicates whether family is  receiving subsidies initially. It will be changed to 1 below if the family is receiving subsidies.
			if ($parent_cost_individual_total > $parent_cost && $adult_medicaid_count + $adult_chip_count < $in->{'family_structure'}) { #meaning they receive subsidized healthcare, because their total subsidized health insurance (parent_cost) is less than their unsubsidized todal insurance (parent_cost_individual_total) and there is at least one adult in the home who is not covered by public insurance.
				print "yes \n";
				$in->{'subsidy_initial'} = 1; #This is a flag/dummy variable that indicates the family is receiving subsidies initially.
				$in->{'parent_cost_difference'} = $in->{'hlth_amt_parent_m'} * 12 - $parent_cost; #This could be positive or negative. It indicates how much more or less the adult(s) in the unit are paying for.
				print "parent_cost_difference: $in->{'parent_cost_difference'} \n";
			}
			if ($in->{'child_number'} > 0 && $family_cost_individual_total > $family_cost && $adult_medicaid_count + $adult_chip_count + $child_medicaid_count + $child_chip_count < $in->{'family_size'}) { #same rationale as above, but for the whole family.
				print "yes2 \n";
				$in->{'subsidy_initial'} = 1;
				$in->{'family_cost_difference'} = $in->{'hlth_amt_family_m'} * 12 - $family_cost;
				print "family_cost_difference: $in->{'family_cost_difference'} \n";
			} 
		}
		
		#We now account for the input variables defined in the current scenario to either the current scenario or to future scenarios. 
		if ($in->{'subsidy_initial'} == 1) {
			#For families that start out receiving a subsidy, we add or subtract this difference to the parent (adult) cost or family cost, which will be the same as in the subtraction above for the current scenario, but may be different for future scenarios.
			$parent_cost = &greatest(0,$parent_cost + $in->{'parent_cost_difference'}); #We want to avoid this being a negative number
			if ($in->{'child_number'} > 0) {
				$family_cost = &greatest(0,$family_cost + $in->{'family_cost_difference'});
			}
		} else {
			#There are several situations to consider here:
			if ($in->{'hlth'} == 1) {
				#1. The family selected Medicaid (hlth=1) and indicated a cost they'd expect to pay if coming off Medicaid, but they are actually already both inelgible for Medicaid and ineigible for premium tax credits:
				#2. The family selected Medicaid (hlth=1) and indicated a cost they'd expect to pay if coming off Medicaid, and is currently elgible for Medicaid, but will not be in the future scenario.
				#In both these scenarios, the family already has indicated what cost they will incur when losing Medicaid coverage. We do not need to compare against a separate, subsidized amount.
				$parent_cost = $in->{'hlth_amt_parent_m'} * 12; 
				if ($in->{'child_number'} > 0) {
					$family_cost = $in->{'hlth_amt_family_m'} * 12;
				}
			} else {
				#3. The family did not select Medicaid, and indicated an amount they pay, and is currently not making an income that allows them eligibility for premium tax credits. They may later qualify for permium tax credits, which will lower their health costs. For families not initially receiving subsidies, we compare their parent cost calculated above -- which may or may not be reduced by subsidies -- with the amount they are initially paying or would expect to pay.	
				$parent_cost = &least($parent_cost, $in->{'hlth_amt_parent_m'} * 12) ; 
				if ($in->{'child_number'} > 0) {
					$family_cost = &least($family_cost, $in->{'hlth_amt_family_m'} * 12);
				}
			}
		}
	}

	print "2. hlth_cov_child_all: $hlth_cov_child_all \n";
	
	if ($hlth_cov_parent eq 'Medicaid') {
		$health_expenses = 0 + $adult_medicaidchip_premiums; #This is because the adult Medicaid income limits are always lower than the children's limits. So if the parents are covered by Medicaid, the children are as well. 
				
		#
		#
		#In some states states, parents on Medicaid are liable for some out of pocket costs like copays.
		
	} elsif ($hlth_cov_child_all eq 'Medicaid' || $in->{'child_number'} == 0 || $child_chip_count > 0) { 
		$health_expenses = $parent_cost + $chip_premiums + $adult_medicaidchip_premiums;
		if ($hlth_cov_parent ne 'Medicaid and private' && $hlth_cov_parent ne 'CHIP and private' && $hlth_cov_parent ne 'Medicaid, CHIP, and private' && $hlth_cov_parent ne 'Medicaid and CHIP' && $hlth_cov_parent ne 'CHIP') { 
			#At this point, we're not going to try to determine exactly which type of private plan families are on when one adult is on CHIP.
			if ($parentswitch_dummy == $out->{'filers_count'}) { #If all filing units switch from employer to individual plans due to employer plans being unaffordable,
				$hlth_cov_parent = 'individual';
				for(my $i=1; $i<=4; $i++) {
					if ($in->{'parent'.$i.'_age'} > -1) {
						${'hlth_cov_parent'.$i} = 'individual';
					}
				}
			} elsif ($parentswitch_dummy > 0) { #If at least one but not all filing units switch from employer to individual plans due to employer plans being unaffordable,
				$hlth_cov_parent = 'individual and employer';
			} else {
				$hlth_cov_parent = $in->{'privateplan_type'};
			}
		}

	} else {
		$health_expenses = $family_cost + $adult_medicaidchip_premiums;

		# There are no Medicaid premiums in NH.   
		if ($familyswitch_dummy == 1) {			 
			$hlth_cov_child_all = 'individual';
			for(my $i=1; $i<=5; $i++) {
				if ($in->{'child'.$i.'_age'} > -1) {
					${'hlth_cov_child'.$i} = 'individual';
				}
			}
			if ($familyswitch_dummy + $parentswitch_dummy_otherunits == $out->{'filers_count'}) {
				$hlth_cov_parent = 'individual';
				for(my $i=1; $i<=4; $i++) {
					if ($in->{'parent'.$i.'_age'} > -1) {
						${'hlth_cov_parent'.$i} = 'individual';
					}
				}
			} else { 
				$hlth_cov_parent = 'individual and employer';
			}	
		} else {
			$hlth_cov_parent = $in->{'privateplan_type'};
			$hlth_cov_child_all = $in->{'privateplan_type'};
			for(my $i=1; $i<=5; $i++) {
				if ($in->{'child'.$i.'_age'} > -1) {
					${'hlth_cov_child'.$i} = $in->{'privateplan_type'};
				}
			}
		}		
	}

	if($in->{'child_number'} == 0) {
		$hlth_cov_child_all = 'no children';
	}

	# We calculate premium_credit_recd, to use in the FRS charts.
	#To do this, we need to create a variable that captures all the possibilities that a parent could get subsidized health insurance.
	for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
		if (${'hlth_cov_parent'.$i} eq 'individual') {
			$marketplace_flag = 1;
		}
	}
	
	print "3. hlth_cov_child_all: $hlth_cov_child_all \n";
	
	#All units totaled together:
	if ($hlth_cov_child_all eq 'individual' && $in->{'hlth_plan_estimate_source'} ne 'user-entered') {
		print "debuga \n";
		$premium_credit_recd = pos_sub($family_cost_individual + $parent_cost_individual_unit2 + $parent_cost_individual_unit3 + $parent_cost_individual_unit4, $sub_family_cost + $sub_parent_cost2 + $sub_parent_cost3 + $sub_parent_cost4); #The latter term could likely be $family_cost. Maybe should for simplicity.
	} elsif ($marketplace_flag == 1 && $in->{'hlth_plan_estimate_source'}  ne 'user-entered') {
		$premium_credit_recd = pos_sub($parent_cost_individual_total, $sub_family_cost + $sub_parent_cost2 + $sub_parent_cost3 + $sub_parent_cost4); #The latter term could likely just be $family_cost or $parent_cost. Maybe should for simplicity.
		print "debugb \n";
	} else {
		if ($in->{'privateplan_type'} eq 'individual' && $familyswitch_dummy == 1) { #This will capture the switch situations for tax filing unit 1. May need to reassess if using this code for other FRS codes. #6/15: changing this from an OR statement to an AND one. Not sure why it was an OR before; this seems specific to people who switch from employer to individual.
			$premium_credit_recd = pos_sub($family_cost_individual, $sub_family_cost);
			print "debugc \n";
		}
		for(my $i=2; $i<=$out->{'filers_count'}; $i++) { #We've already calculated the premium credit for tax filing unit 1, above.
			if ($in->{'privateplan_type'} eq 'individual' && ${'parentswitch_dummy'.$i} == 1) {
				$premium_credit_recd += pos_sub(${'parent_cost_individual_unit'.$i}, ${'sub_parent_cost'.$i});
				print "debugd \n";
			}
		}
		#We have to account for users entering lower premiums than the savings that going for the lowest-cost silver plan would provide them:  
		if ($in->{'privateplan_type'} eq 'individual' &&  $in->{'hlth_plan_estimate_source'} eq 'user-entered') {
			if ($in->{'family_cost_difference'} < 0) { 
				$premium_credit_recd = &greatest(0,$premium_credit_recd + $in->{'family_cost_difference'});
				print "debuge \n";
			} elsif ($in->{'parent_cost_difference'} < 0) { 
				$premium_credit_recd = &greatest(0,$premium_credit_recd + $in->{'parent_cost_difference'});
				print "debugf \n";
			}
			#If the difference is greater than 0, they stil get the maximum premium tax credit received.
		}
	}

	$health_expenses_before_oop = $health_expenses;
	
	#New Hampshire's Medicaid program does not cover all health costs. So we add in out of pocket costs that the user can enter. See  https://www.dhhs.nh.gov/ombp/medicaid/documents/med77l.pdf.

	$health_expenses = $health_expenses + (12 * $hlth_costs_oop_m); 

	# Additional  Medicaiid eligibility concerns
	
	#Note that there is no asset test for Medicaid programs. Some states set asset limits as a requirement to participate in Medically Needy programs, discussed more below.
	
	# "Spend Down", "Medically Needy," or "Medicaid buy-in" programs:
    # Medically Needy programs, "spend down" programs, or "In and Out Medical Assistance," enrolls individuals into Medicaid when their income  is higher than Medicaid income limits, but is pushed down below MAGI Medicaid income limits or other income  limits when subtracting health care costs. As a way to understand this program,  one can think about it as “buying into” the state’s Medicaid program, with the cost of that purchase the difference between current income and  the relevant income eligibility limit. That difference is the amount that families pay toward their medical bills before Medicaid covers the rest. 
	
	# if ($out->{'percent_of_poverty'} > $parent_medicaid_limit && $out->{'hlth_gross_income_m'} - $health_expenses / 12 < $medically_needy_medicaid_limit && $in->{'hlth'}) {
	#   $medically_needy = 1;
	#	... ;
	#}


	#debugging
	foreach my $debug (qw(hlth_cov_parent health_expenses parent_cost family_cost family_cost_individual_total child_number parentswitch_dummy familyswitch_dummy adult_medicaidchip_premiums child_medicaid_count hlth_cov_child_all chip_premiums)) {
		print $debug.": ".${$debug}."\n";
	}

	# outputs
	foreach my $name (qw(firstrunchildcare hlth_cov_parent hlth_cov_parent1 hlth_cov_parent2 hlth_cov_parent3 hlth_cov_parent4 hlth_cov_child_all 
		hlth_cov_child1 hlth_cov_child2 hlth_cov_child3 hlth_cov_child4 hlth_cov_child5 
		premium_tax_credit health_expenses premium_credit_recd health_expenses_before_oop chip_premiums)) { 
        $out->{$name} = ${$name};
	}
}

1;
