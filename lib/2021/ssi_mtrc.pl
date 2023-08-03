#=============================================================================#
#  SSI (Supplemental Security Income) Module – 2021 
#=============================================================================#
#
# Inputs referenced in this module:
#
# FROM USER INTERFACE (note: we are removing vehicle equity variables for now; see reasons below.)
# savings
# checking	#not asked
# disability_parent1
# disability_parent2
# disability_parent3
# disability_parent4
# disability_work_expenses_m 
# parent1_ssi_recd_m_initial
# parent2_ssi_recd_m_initial
# parent3_ssi_recd_m_initial
# parent4_ssi_recd_m_initial
# 
# family_structure
# child_number
#
# FROM INTEREST
# interest_m
#
# FROM PARENT EARNINGS
# parent1_earnings
# parent2_earnings
# parent3_earnings
# parent4_earnings
# earnings_mnth 
#
# FROM SSP 
# ssp_couple 		
# ssp_individual	
#=============================================================================#

sub ssi
{
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# outputs created in macro:
	our $fbr_couple = 1191; 		# monthly max SSI benefit for couple. Updated for 2021.
	our $fbr_individual = 794;		# monthly max SSI benefit for individual.  Updated for 2021.
	our $student_earned_income_exclusion = 7770/12; #This is the maximum annual student exclusion, divided by months in the year. Conceivably students can get $1,900 monthly up to this maximum, but we do not know how many months these students wil be working.  Updated for 2021.
	our $ssi_couple_asset_limit = 3000;	# SSI asset limit for couples
	our $ssi_indiv_asset_limit = 2000;	# SSI asset limit for individuals
	our $applicable_asset_limit = 0;		# The asset limit applicable to the family
	our $ssi_assets = 0;			# SSI asset calculation
	our $ssi_earn_income_m = 0;
	our $ssi_income = 0;			# Countable income according to SSI rules
	our $ssi_recd_mnth = 0;		# monthly SSI payment
	our $ssi_recd_m = 0;		# monthly SSI payment, but another name. This is redundant with ssi_recd_mnth, but including it because codes have (somewhat sloppily) used the "_m" suffix instead of the _mnth one. At this point, it's easier to just repeat this value across two variables.
	our $ssi_recd = 0;			# yearly SSI payment
	our $deemed_child_allocation	 = 0;	# Income deemed to children (excluded from SSI income)
	our $eligible_parent_earnings = 0;	# Delineates disabled parent earnings from non-disabled  parent earnings.
	our $ineligible_parent_earnings = 0; 	# Delineates non-disabled parent earnings from disabled  parent earnings.
	our $ineligible_parent_unearned_income = 0;	# Separates non-disabled parent’s unearned income  	# based on SSI eligibility formula.
	our $ineligible_parent_earned_income = 0;	# Separates non-disabled parent’s earned income  # based on SSI eligibility formula.

	# variables used in this script 
	our $applicable_asset_limit = 0; 
	our $interest_m = $out->{'interest_m'};
	our $parent1_earnings = $out->{'parent1_earnings'};
	our $parent2_earnings = $out->{'parent2_earnings'}; 
	our $earnings_mnth = $out->{'earnings_mnth'};
	our $parent1_SSI = 0; #needed so that the tanf code can be run correctly.
	our $parent2_SSI = 0; #needed so that the tanf code can be run correctly.
	our $parent3_SSI = 0; #needed so that the tanf code can be run correctly.
	our $parent4_SSI = 0; #needed so that the tanf code can be run correctly.
	our $parent1_ssimarried = 0;
	our $parent2_ssimarried = 0;
	our $parent3_ssimarried = 0;
	our $parent4_ssimarried = 0;
	our $ssi_unearn_income_m = 0;
	our $ssi_earn_income_m = 0;
	our $ssi_unearn_income_m_each = 0;
	our $adult_children_students = 0;
	our $remaining_SEIE = 0; #For cases in which there are adult students who may be eligible for deemed income calculations. 
	our $ssi_lefttocount = 0;
	our $parent1_ssi_income = 0; #Need individual assignments of SSI income as outputs to later calculate non-MAGI Medicaid eligibility.
	our $parent2_ssi_income = 0;
	our $parent3_ssi_income = 0;
	our $parent4_ssi_income = 0;
	our $parent1_ssi_unearned_income = 0;
	our $parent2_ssi_unearned_income = 0;
	our $parent3_ssi_unearned_income = 0;
	our $parent4_ssi_unearned_income = 0;
	
	for (my $i = 1; $i <= 4; $i++) {
		if ($in->{'parent'.$i.'_age'} > 0) {
			if ($in->{'disability_parent'.$i} == 1) { 
				$ssi_lefttocount += 1; #We are switching to counting all disabled adults here, for the purposes of calculating non-MAGI eligibility for former recipients of SSI or SSDI. Moving the actual SSI calculations below.
			}
		}
	}
	
	# There are also state supplements to SSI, grouped here as SSP variables. We capture these in the ssp_mtrc.pl code.

	#In that we are modeling SSI recipients could conceivably be reentering the workforce, we are assuming that they are able-bodied enough to pay their own expenses, at their current incomes or higher incomes. If SSI recipients do not pay their fair share of income, their SSI benefits are reduced based on rules detailed at https://www.ssa.gov/ssi/text-living-ussi.htm. 
	
	#Given the presence of up to 4 adults in the household, we need to identify any spouses in the unit in order to determine their SSI benefits. 
	
	if ($ssi_lefttocount == 0) { #No one has a disability. All outputs are zeros.
		$ssi_recd_mnth  = 0;
		$ssi_recd = 0;
	} else {
		# For parents, from https://www.ssa.gov/OP_Home/ssact/title16b/1600.htm, https://www.ssa.gov/ssi/text-understanding-ssi.htm.  

		# Resource and disability test
		# One vehicle is excluded regardless of value if used for transportation for you or member of your household. The below formula would therefore only count the lowest value vehicle in the asset calculation.

		# One vehicle is excluded. According to https://secure.ssa.gov/poms.nsf/lnx/0501130200, exclude vehicles such that the exclusion is most advantageous to the recipient. These instructions also indicate that vehicle equity (not current market value) is used for this determination. 
		
		# Commenting out asset test, including vehicle values and home value (for people who own their home), at least for now, since we are only considering people who are already on SSI but who might be kicked off it with higher household earnings. Since the ssi flag will only be selected by households already receiving ssi, running the asset test is unnecessary, since this test was presumably already run at program entry. Our model does not include the accumulation of savings.
		
		#We can do a shorthand of assuming the asset test has already been passed by assigning ssi_assets a value of 0:
		$ssi_assets = 0;
		
		# $ssi_assets = ($in->{'savings'} + $in->{'checking'} + &least(($in->{'vehicle1_value'} - $in->{'vehicle1_owed'}), ($in->{'vehicle2_value'} - $in->{'vehicle2_owed'}))); #This is what the SSI asset test would look like if we hadn't known that individuals had already passed the asset test. Keeping it in here for potential FRS replication/adaptation.
		
		if ($in->{'family_structure'} == 1 ) {	
			# These limits have remained unchanged since 1989.
			# single-parent unit
			$applicable_asset_limit = $ssi_indiv_asset_limit;
		} else {
			# two-parent unit (All resources from a family unit are deemed resources, regardless of whether they can be attributed to an individual eligible or ineligible for SSI.)
			$applicable_asset_limit = $ssi_couple_asset_limit;
		}

		if ($ssi_assets > $applicable_asset_limit ) {  
			$ssi_recd_mnth = 0;
		} else {
			# Determination based on income (from https://www.ssa.gov/ssi/text-income-ussi.htm) :
			#
			# First $20 received in each month “of most income received in a month” is a disregard. Another $65 is also deducted from earnings, and half that is also deducted. Additional expenses needed for a disabled adult to get to work (Impairment-Related Work Expenses) can also be deducted.  The below series of pos_sub commands allows $20 to be deducted first from unearned income and then, if $20 exceeds unearned income, the remainder to be applied to unearned income. $65 of earned income is excluded before an exclusion of half of that remainder is applied.

			# Scenario 1: single disabled parent, no spouse:

			if ($in->{'family_structure'} == 1)  {	
				#We calculate earned income to be used for SSI, inclusive of the student earned income exclusion. We  use the ft and pt student variables as dummies here, taking advantage of the fact that no parent can be both an ft student and a pt student. This exclusion is counted first.
				
				$ssi_earn_income_m = pos_sub($earnings_mnth + $in->{'selfemployed_netprofit_total'}/12, ($in->{'parent1_ft_student'} + $in->{'parent1_pt_student'})* $student_earned_income_exclusion);
				
				$ssi_income = &pos_sub(((&pos_sub($interest_m + $out->{'gift_income_m'} + $out->{'ui_recd_m'}, 20)) + (.5 * (&pos_sub($ssi_earn_income_m, (65 + &pos_sub(20, $interest_m)))))), ($in->{'disability_work_expenses_m'})); 
				
				$parent1_ssi_income = $ssi_income;
				
				if ($in->{'ssi'} == 1 || $in->{'ssp'} == 1) {
					$ssi_recd_mnth = &pos_sub($fbr_individual  + $out->{'ssp_individual_thresh'}, $ssi_income);
					
					if ($ssi_recd_mnth > 0 ) {
						$parent1_SSI = 1;
					}
				}
			} else {
				#For families greater than 1 person that include adults who have been receiving SSI, we need to determine whether the adult family members are married and consider arrangements of an individual who is not married living with two other individuals who may or may not be. 
				for (my $i = 1; $i <= 4; $i++) {
					if ($in->{'parent'.$i.'_age'} > 0) {
						if ($ssi_lefttocount > 0 && $in->{'disability_parent'.$i} == 1) { 
							for (my $j = 1; $j <= 4; $j++) {
								if ($in->{'parent'.$j.'_age'} > 0) {
									if (${'parent'.$i.'_ssimarried'} == 0 && ${'parent'.$i.'_ssimarried'} == 0 && (($in->{'married1'} == $i && $in->{'married2'} == $j) || ($in->{'married1'} == $j && $in->{'married2'} == $i))) { #i married to j and neither of them have been counted before:
										${'parent'.$i.'_ssimarried'} = 1;
										${'parent'.$j.'_ssimarried'} = 1;
										if ($in->{'disability_parent'.$j} == 1) { #j is also a disabled adult receiving SSI.
											$ssi_earn_income_m = $out->{'parent'.$i.'_earnings_m'} + $in->{'parent'.$i.'_selfemployed_netprofit'}/12 + $out->{'parent'.$j.'_earnings_m'} + $in->{'parent'.$j.'_selfemployed_netprofit'}/12;
											
											# In order for a couple to claim SSI's student earned income exclusion, at least one member of the couple must be working and a student. The exclusion is only counted once.
											
											if (($in->{'parent'.$i.'_ft_student'} + $in->{'parent'.$i.'_pt_student'} == 1 && $out->{'parent'.$i.'_earnings_m'} + $in->{'parent'.$i.'_selfemployed_netprofit'}/12 > 0) || ($in->{'parent'.$j.'_ft_student'} + $in->{'parent'.$j.'_pt_student'} == 1 && $out->{'parent'.$j.'_earnings_m'} + $in->{'parent'.$j.'_selfemployed_netprofit'}/12 > 0)) {
												$ssi_earn_income_m = pos_sub($ssi_earn_income_m, $student_earned_income_exclusion);
											}
											
											$ssi_income = &pos_sub(((&pos_sub(($interest_m + $out->{'gift_income_m'})*2/$in->{'family_structure'} + $out->{'parent'.$i.'ui_recd'}/12 + $out->{'parent'.$j.'ui_recd'}/12, 20)) + (.5 * (&pos_sub($ssi_earn_income_m, (65 + &pos_sub(20, ($interest_m + $out->{'gift_income_m'})*2/$in->{'family_structure'})))))), ($in->{'disability_work_expenses_m'})); 
											
											if ($fbr_couple + $out->{'ssp_couple_thresh'}> $ssi_income && ($in->{'ssi'} == 1 || $in->{'ssp'} == 1)) {
												$ssi_recd_mnth += &pos_sub($fbr_couple + $out->{'ssp_couple_thresh'}, $ssi_income);
												${'parent'.$i.'_SSI'} = 1;
												${'parent'.$j.'_SSI'} = 1;
											}
											$ssi_lefttocount -= 2;
											
											${'parent'.$i.'_ssi_income'} = $ssi_income;
											${'parent'.$j.'_ssi_income'} = $ssi_income;
											
											#For Working While Disabled Medicaid coverage in some states, we need to know the unearned income of people based on SSI rules.
											${'parent'.$i.'_ssi_unearned_income'} = ($interest_m + $out->{'gift_income_m'})*2/$in->{'family_structure'} + $out->{'parent'.$i.'ui_recd'}/12 + $out->{'parent'.$j.'ui_recd'}/12;
											${'parent'.$j.'_ssi_unearned_income'} = ($interest_m + $out->{'gift_income_m'})*2/$in->{'family_structure'} + $out->{'parent'.$i.'ui_recd'}/12 + $out->{'parent'.$j.'ui_recd'}/12;
											
										} else {
											# One parent in a married family is disabled, the other is not.
											# First, we need to determine how many additional "children" are in the household under SSI rules. This includes any child under 18 (already captured in the child_number variable) but also any adult students under age 22 not on SSI in the household. In order to be counted as a child, the student cannot be married nor can they be head of household. Since we do not know the parentage of all children in the home, we only search for marriage. Because we are excluding adult students of this age range who are on SSI (they are technically children), we know that these students are not eligible for the student earned income exclusion.
											for (my $k = 1; $k <= 4; $k++) {
												if ($in->{'parent'.$k.'_age'} > 0 && $in->{'parent'.$k.'_age'} < 22) {
													if (($in->{'parent'.$k.'_ft_student'} == 1 || $in->{'parent'.$k.'_pt_student'} == 1) && $in->{'married1'} != $k && $in->{'married2'} != $k) { 
														$adult_children_students += 1;
													}
												}
											}
										
											# We now follow the steps for deeming income from an ineligible spouse. From https://secure.ssa.gov/poms.nsf/lnx/0501320400, it appears that child support is not included as income to the ineligible child for the purposes of reducing the ineligible child allocation. There does not seem to be any deeming calculated for the income of single eligible parents – or income of children – toward ineligible children. https://www.ssa.gov/policy/docs/issuepapers/ip2003-01.html, https://www.ssa.gov/OP_Home/ssact/title16b/1600.htm, and http://www.worksupport.com/documents/parentChildDeemFeb08.pdf are also helpful.
											
											# Also see https://www.ssa.gov/OP_Home/cfr20/416/416-1160.htm#:~:text=Ineligible%20child%20means%20your%20natural,same%20household%20with%20you%2C%20and.
											#if ($out->{'tanf_recd'} == 0) { #TANF falls under the definition of public income maintenance.
											$deemed_child_allocation = ($in->{'child_number'} + $adult_children_students) * ($fbr_couple - $fbr_individual); 
											#}
											# It seems reasonable to assume that families who have people with disabilities transfer all interest-generating accounts to the non-disabled individual, in order to maximize their SSI receipt. Therefore, all interest will be considered unearned income for any non-disabled parents. We need to make a note of this in our list of assumptions.

											# In order to make this work, and to generalize this so that we can use efficient code to describe two different situations (one where parent1 is disabled but not parent2, and the other where parent2 is disabled but not parent1), we can use the following shortcut:

											# The student earned income exclusion gets applied once in this case, to the earnings of both parents. But only applies to working parents. For clarity, and to avoid too much calculations on a single line, since we need to separate eligible parent/adult from ineligble parent/adult income, we're adding a remainder variable to calculate the remaining student earned income exclusion (SEIE) after first reducing the eligible parent by the largest amount possible. The ineligble adult can clain the remaining SEIE. See https://secure.ssa.gov/poms.nsf/lnx/0500820510. 
											
											$eligible_parent_earnings = pos_sub($out->{'parent'.$i.'_earnings_m'}+$in->{'parent'.$i.'_selfemployed_netprofit'}/12, ($in->{'parent'.$i.'_ft_student'} + $in->{'parent'.$i.'_pt_student'})* $student_earned_income_exclusion);
											
											$remaining_SEIE = pos_sub(($in->{'parent'.$i.'_ft_student'} + $in->{'parent'.$i.'_pt_student'})* $student_earned_income_exclusion, $out->{'parent'.$i.'_earnings_m'}+$in->{'parent'.$i.'_selfemployed_netprofit'}/12);
											
											$ineligible_parent_earnings = pos_sub($out->{'parent'.$j.'_earnings_m'} +$in->{'parent'.$j.'_selfemployed_netprofit'}/12, ($in->{'parent'.$j.'_ft_student'} + $in->{'parent'.$j.'_pt_student'})* $remaining_SEIE);
											
											# The child allocation is subtracted from the ineligible’s parent’s unearned income, and any remainder is applied to their earned income.
											
											# For later consideration: we are also giving the non-disabled married parent in the family all the unearned income in the household. This is a simplifying assumption and may impact families with more than 2 adults in the home.
											$ineligible_parent_unearned_income = &pos_sub($interest_m + $out->{'gift_income_m'} + $out->{'parent'.$j.'ui_recd'}/12, $deemed_child_allocation);

											if ($deemed_child_allocation > $interest_m + $out->{'gift_income_m'}) {
												$ineligible_parent_earned_income = &pos_sub($ineligible_parent_earnings, ($deemed_child_allocation - $interest_m - $out->{'gift_income_m'}));
											
											} else {
												$ineligible_parent_earned_income = $ineligible_parent_earnings;
											}

											# When the remaining income is lower than the difference between the FBR for a couple and the FBR for an individual, there is no income to deem from the ineligible spouse to the eligible individual, and only the eligible individual’s income is considered for SSI eligibility and receipt (assuming each parent’s incomes are consistent across all months in a year). Also, since we are considering all interest will be held by the ineligible parent, there is only earned income to consider:

											if ($ineligible_parent_unearned_income + $ineligible_parent_earned_income <=  $fbr_couple - $fbr_individual) { 

												$ssi_income = &pos_sub((.5 * (&pos_sub($eligible_parent_earnings, 85))), ($in->{'disability_work_expenses_m'}));
												if ($fbr_individual + $out->{'ssp_individual_thresh'} > $ssi_income && ($in->{'ssi'} == 1 || $in->{'ssp'} == 1)) {
													$ssi_recd_mnth += &pos_sub($fbr_individual + $out->{'ssp_individual_thresh'}, $ssi_income); 
													${'parent'.$i.'_SSI'} = 1;
												}
												
											} else {
												# Deeming applies when remaining income is higher than the difference between the FBR for a couple and the FBR for an individual. They are treated as an eligible couple, but with the ineligible parent’s income lowered based on the deeming above.
												

												$ssi_income = &pos_sub(&pos_sub($ineligible_parent_unearned_income, 20) + .5 * &pos_sub($ineligible_parent_earned_income + $eligible_parent_earnings, 65) + &pos_sub(20, $ineligible_parent_unearned_income), $in->{'disability_work_expenses_m'}); 
												if ($fbr_couple + $out->{'ssp_couple_thresh'} > $ssi_income&& ($in->{'ssi'} == 1 || $in->{'ssp'} == 1)) {
													$ssi_recd_mnth += &pos_sub($fbr_couple + $out->{'ssp_couple_thresh'}, $ssi_income); 
													${'parent'.$i.'_SSI'} = 1;
												}
												# Note: “The SSI benefit under these deeming rules cannot be higher than it would be if deeming did not apply,” but for the variables we are considering, this would never happen. It could happen if earnings are inconsistent between months. 
											}
											$ssi_lefttocount -= 1;
											${'parent'.$i.'_ssi_income'} = $ssi_income;
											${'parent'.$i.'_ssi_unearned_income'} = $out->{'parent'.$i.'ui_recd'}/12; #Seems like we need to adjust above code to include UI benefits as unearned for this adult. But since this is a varibale needed for other codes (Medicaid While Disabled), adding it in for now. Otherwise, as indidcated above, this would be 0.
										}
									}
								}
							}
							if (${'parent'.$i.'_ssimarried'} == 0 && $ssi_lefttocount > 0) { #if after all the runs through other adult in the house, no adult is found to be married to parent/adult i, then parent i is on SSI as an individual and not a couple.
								$ssi_earn_income_m = pos_sub($out->{'parent'.$i.'_earnings_m'} + $in->{'parent'.$i.'_selfemployed_netprofit'}, ($in->{'parent'.$i.'_ft_student'} + $in->{'parent'.$i.'_pt_student'})* $student_earned_income_exclusion);
								
								$ssi_income = &pos_sub(&pos_sub($interest_m + $out->{'gift_income_m'} +$out->{'parent'.$i.'ui_recd'}/12, 20) + .5 * &pos_sub($ssi_earn_income_m, 65 + &pos_sub(20, $interest_m + $out->{'gift_income_m'})), $in->{'disability_work_expenses_m'}); #We are making a simplifying assumption here that unearned income is shared by household members This could be improved by future versions of this tool. 
								if ($fbr_individual  + $out->{'ssp_individual_thresh'} > $ssi_income && ($in->{'ssi'} == 1 || $in->{'ssp'} == 1)) {
									$ssi_recd_mnth += &pos_sub($fbr_individual  + $out->{'ssp_individual_thresh'}, $ssi_income);
									${'parent'.$i.'_SSI'} = 1;
								}
								$ssi_lefttocount -= 1;
								${'parent'.$i.'_ssi_income'} = $ssi_income;
								${'parent'.$i.'_ssi_unearned_income'} = $interest_m + $out->{'gift_income_m'} +$out->{'parent'.$i.'ui_recd'}/12;
							}
						}
					}
				}
			}							
		}
	}		
	$ssi_recd_m = $ssi_recd_mnth;
	$ssi_recd = 12 * $ssi_recd_mnth;
	
	# Children are also eligible for SSI, and while modeling SSI benefits for children is possible, it would not be realistic to include them in this model without also including a variety of other benefits aimed at children with disabilities. We are forgoing their inclusion at this time. See https://www.ssa.gov/ssi/text-child-ussi.htm and other related pages if considering including children in the future.

	#debugs
	foreach my $debug (qw(ssi_lefttocount parent1_ssi_income ssi_recd ssi_recd_mnth parent1_SSI parent2_SSI )) {
		print $debug.": ".${$debug}."\n";
	}
	
	 # outputs
	foreach my $name (qw(ssi_recd ssi_recd_mnth parent1_SSI parent2_SSI parent3_SSI parent4_SSI parent1_ssi_income parent2_ssi_income parent3_ssi_income parent4_ssi_income parent1_ssimarried parent2_ssimarried parent3_ssimarried parent4_ssimarried ssi_recd_m parent1_ssi_unearned_income  parent2_ssi_unearned_income parent3_ssi_unearned_income parent4_ssi_unearned_income 
	)) {
       $out->{$name} = ${$name};
    }	
}

1;

# Limitations: 
# 1. We are assuming no individual in the house qualifies as an "essential person." The shorthand definition of an Essential Person is "someone who was identified as essential to your welfare under a State program that preceded the SSI program." The more formal definiition is someone who: "(A) has continuously lived in the individual's home since December 1973; and (B) was not eligible for State assistance in December 1973; and (C) has never been eligible for SSI benefits as an eligible individual or as an eligible spouse; and (D) State records show that, under a State plan in effect for June 1973, the State took that person's needs into account in determining the qualified individual's need for State assistance for December 1973."