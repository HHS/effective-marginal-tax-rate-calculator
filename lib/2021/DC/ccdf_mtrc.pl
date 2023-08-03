# =============================================================================#
#  CCDF Module -- 2021 – DC
#=============================================================================#
# Inputs referenced in this module:
#
#	INPUTS FROM USER INTERFACE
#		family_size
#		ccdf
#
#	OUTPUTS FROM PARENT EARNINGS:
#       earnings
#
#	OUTPUTS FROM INTEREST
#       interest
#       
#	OUTPUTS FROM TANF
#       child_support_recd
#       tanf_recd
#
#	OUTPUTS FROM SSI
#       ssi_recd
#
#	OUTPUTS FROM CHILD CARE
# 		unsub_all_children
# 		spr_all_children

#============================

#

sub ccdf
{
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};
    
	#Stil need check in online TANF handbook to see regulations specific to child care for TANF families. See CCDF regulations 3041.16.
  # outputs created
	our $summerweeks = 9; #For now, we're using this universally. It's a typical amount and exact school calendars won't be newly generated until after COVID subsides.
    our $ccdf_threshold = 2.50;             # ccdf income eligibility limit as a percent of poverty    
    #our @ccdf_85smi_array = ; apparently SMI and 85% SMI is not considered in PA CCDF.
	our $ccdf_training_hours_met = 0;	#Whether the family satisfies CCDF work hour requirements..
    our @ccdf_85smi_array = (0,53231,69610,85989,102338,118747,13526,138197,141268,144339); # The SMIs included in the sliding fee schedule; I'm not sure where these are from since they differ markedly from the latest Census data.
    our $ccdf_85smi = $ccdf_85smi_array[$in->{'family_size'}]; 

	#Created in macro
    our $cc_subsidized_flag = 0;          # flag indicating whether or not child care is  subsidized
    our $ccdf_eligible_flag = 0;          # flag indicating whether eligible
    our $child_care_recd = 0;             # annual value of child care subsidies (cost  of care minus family expense)
    our $ccdf_income = 0;                 # income used to determine ccdf eligibility and copay 
    our $ccdf_poverty_percent = 0;        # family income as percent of poverty

 	our $child_care_expenses = 0; # total annual child care expenses
 	our $child_care_expenses_m = 0;
    our $copay1_full_d = 0;                 # daily copay for child1, full-day care
    our $copay2_full_d = 0;                 # daily copay for child2, full-day care
    our $copay1_part_d = 0;                 # daily copay for child1, part-day care
    our $copay2_part_d = 0;                 # daily copay for child2, part-day care
	our $copay_exempt = 0;
	our $parent1_adult_hs_student = 0;
	our $parent2_adult_hs_student = 0;
	our $parent3_adult_hs_student = 0;
	our $parent4_adult_hs_student = 0;
	our $youngest_child = 0;	# the child number of the youngest child, needed for co-pay calculations
	our $secondyoungest = 0;	# the child number of the second-youngest child, needed for co-pay calculations

	# We also need to define all the copay variables, based on youngest (…copay1) and second-youngest  (=…copay2), by each day, for both non-summer and summer.
	our $day1copay1 = 0;
	our $day2copay1= 0;
	our $day3copay1= 0;
	our $day4copay1= 0;
	our $day5copay1= 0;
	our $day6copay1= 0;
	our $day7copay1= 0;
	our $summerday1copay1 = 0;
	our $summerday2copay1 = 0;
	our $summerday3copay1 = 0;
	our $summerday4copay1 = 0;
	our $summerday5copay1 = 0;
	our $summerday6copay1 = 0;
	our $summerday7copay1 = 0;
	our $day1copay2 = 0;
	our $day2copay2 = 0;
	our $day3copay2 = 0;
	our $day4copay2 = 0;
	our $day5copay2 = 0;
	our $day6copay2 = 0;
	our $day7copay2 = 0;
	our $summerday1copay2 = 0;
	our $summerday2copay2 = 0;
	our $summerday3copay2 = 0;
	our $summerday4copay2 = 0;
	our $summerday5copay2 = 0;
	our $summerday6copay2 = 0;
	our $summerday7copay2 = 0;
    our $ccdf_child1_copay = 0;             # daily copay for oldest child under 13 in family
    our $ccdf_child2_copay = 0;             # daily copay for second-oldest child under 13 in the family
	our $ccdf_copay = 0;                    # annual copay charged to family (if copay exceeds state reimbursement for all children, then model assumes that family opts out of ccdf program)
	our $child_care_expenses_child1 = 0;
	our $child_care_expenses_child2 = 0;
	our $child_care_expenses_child3 = 0;
	our $child_care_expenses_child4 = 0;
	our $child_care_expenses_child5 = 0;
	our $child_care_recd_flag_child1 = 0;	
	our $child_care_recd_flag_child2 = 0;	
	our $child_care_recd_flag_child3 = 0;	
	our $child_care_recd_flag_child4 = 0;	
	our $child_care_recd_flag_child5 = 0;	

 	our $ccdf_chargeabovespr = 0; #Some states, like NH and PA, allow providers to charge parents an overage amount of the difference between the SPR and the equivalent rate they would have charged without subsidies. This mitigates and potentially minimizes the CCDF cliff (if co-pays can increase to 100% of SPRs), but also potentially increases child care costs for low-income workers. PA CCDF regulations 3041.15

	# determined in module

	# STEP 1: Test if there is any child care need.
	#First, see if the caregiving parent's training hours count toward CCDF work requirements. Training hours are only counted if they exceed 10 hours per week, but after that requirement is met, then all of the hours are counted.

	$ccdf_training_hours_met = 1;
	for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
		if ($out->{'parent'.$i.'_transhours_w'} < 20 && $ccdf_training_hours_met == 1 && $in->{'disability_parent'.$i} == 0 && ($in->{'parent'.$i.'_ft_student'} == 0 || $in->{'parent'.$i.'_age'} >= 20)) { #Teen students do not have to meet this requirement.
			$ccdf_training_hours_met = 0; #This tests all adults and adjusts the hours met variable down to 0 if they don't meet the requirement
		}
	}

    if (($out->{'unsub_all_children'} > 0 && ($in->{'ccdf'} == 1  || $out->{'ccdf_alt'} == 1)) && $ccdf_training_hours_met > 0) {	
		#Families on TANF receive a child care allowance equivalent to the amount they would receive through CCDF, just covered by different funding. But they do not need to satisfy minimum work hour requirements. Presumably this was originally conceived as a policy because CCDF minimum work hours coincided with TANF work hours.
		#There are also exemptions for adults with disabilities. One is time-sensitive and is only works for half the year (a parent receivng CCDF and becoming disabled enough that they cannot work, after initial determination, is eligible for CCDF for up to 183 days), and the other is that in a two-parent/caretaker family, eligibility can be achieved is one parent has a disabiltiy such that they cannot care for the child. There are also special requirements for Head Start, but since we are primarily determining eligibitliy for parents who are already in CCDF (and maybe Head Start as well), we'll leave this out for now.
		#work hour requirements are waived for high school students younger than 22.
		#Families formerly receiving TANF benefits can also receive CCDF for up to 183 days.
		#  STEP 2: DETERMINE FINANCIAL ELIGIBILITY FOR CCDF SUBSIDIES		#
		# Note: although Social Security income is included in income tabulations, child SSI is explicitly exempted, but adult SSI is not. As of 1/2020, we are only including adult SSI in the FRS and MTRC. 
		
		# While in NH, had decided upon looking at manual that all adults in family should have income counted and can take care of the child. Actually based on relation of adults to children in hh, but we are refraining from asking specific relationship questions. 

		$ccdf_income = $out->{'earnings'}  + $in->{'selfemployed_netprofit_total'} + $out->{'child_support_recd'} + $out->{'ssi_recd'} + $out->{'ui_recd'} + $in->{'alimony_paid_m'} * 12; #see FAM 511 - Benefits and Self-Employment sections. #See p6 of PA CCDF regulations, also Appendix A Part 1.
		# TANF benefits are exempt. 
		# Capital gains (e.g. interest) are exempt
		 
		$ccdf_poverty_percent = $ccdf_income / $in->{'fpl'};
		# Page 43  of the child care subsidy manual clarifies exit eligibility income requirements. 

		#
		# One possible policy option for either reducing co-pays or qualifying for child care subsidies might be to use policy triggers to incentivize businesses to offer dependent care flexible spending accounts to their employees, which allow employees to deposit pre-tax earnings into an account dedicated to paying for costs such as child care. Having access to an account like this would seem to allow employee earnings to fall below income eligibility thresholds for a number of programs (e.g. CCDF, SNAP, and TANF), which would be helpful  if cash or near-cash benefits from those programs increase net resources by more than the amount that families might lose by no longer qualifying for the child and dependent care tax credit, which I think would no longer be available if enrolled in a dependent care FSA. For all these benefit programs, we'd also have to check whether funds in a dependent care FSA count as assets (or if assets that spent in the same month they are received are not actually assets).

		if($ccdf_poverty_percent > $ccdf_threshold && $ccdf_income > $ccdf_85smi) { 
			#
			$cc_subsidized_flag = 0;
			$ccdf_eligible_flag = 0;
			$child_care_recd = 0;
		} else {
			$ccdf_eligible_flag = 1;
			#
			# 
			#
			#  
			# 
			#

			#  DETERMINE VALUE OF SUBSIDIZED CARE AND FAMILY COPAYMENT
			#
			# TANF recipients “in countable activities other than employment” are exempt from co-payment. This would include parents whose transhours are larger than than their employed hours. (This may not make any difference if all TANF recipeints make incomes less than 50% of the poverty level, since that's when co-pays start accumulating.) Also, “TANF parent(s) with physical or mental disabilities” so that looks like even if they are able to work with their disability, they will not need to pay copays.
			

			#We estimate whether a head of household or other caretaker (married to head of household) is a teen parent in high school.
			if ($in->{'parent1_age'} < 20 && $in->{'parent1_ft_student'} == 1 && $in->{'parent1_educational_expenses'} == 0) {
				$parent1_adult_hs_student = 1;
			}

			if ($in->{'married1'} == 1) {
				for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
					if ($in->{'married2'} == $i && $in->{'parent'.$i.'_age'} < 20 && $in->{'parent'.$i.'_ft_student'} == 1 && $in->{'parent'.$i.'_educational_expenses'} == 0) { #The second married parent is a high school student.
					${'parent'.$i.'_adult_hs_student'} = 1;
					}
				}
			}

			for(my $i=1; $i<=$in->{'family_structure'}; $i++) {					
				if (($out->{'tanf_recd'} > 0 && (${'parent'.$i.'_transhours_w'} > ${'parent'.$i.'_employedhours_w'} || $in->{'disability_parent'.$i} == 1)) || ${'parent'.$i.'_adult_hs_student'}) { #Groups exempt from co-pays. These include TANF recipients in training, TANF recipients with disablities, and teen parents who are high school students. 
					$copay_exempt = 1;
				}
			}
			
			if ($copay_exempt == 1) { 
				$copay1_full_d = 0;
				$copay2_full_d = 0;
				$copay1_part_d = 0;
				$copay2_part_d = 0;
			}  else {
				# See note below: if a child in this household is in afterschool and no other kind of child care, and that afterschool fee is not waived due to TANF or Medicaid receipt, the full afterschool cost is deducted from parent earnings for this co-pay schedule. So if child care can follow the health modules, that would be ideal, but if not, we may need to either run an abbreviated correction for this after afterschool is calculated, or run health over again.
				for ($ccdf_poverty_percent) {
					 $copay1_full_d = ($_ <= 1)   ?   0       :
						($_ <= 1.1)  ?   1.06  :
						($_ <= 1.2)  ?   1.35  :
						($_ <= 1.3)  ?   1.67  :
						($_ <= 1.4)  ?   2.02  :
						($_ <= 1.5)  ?   2.4  :
						($_ <= 1.6)  ?   2.82  :
						($_ <= 1.7)  ?   3.27  :
						($_ <= 1.8)  ?   3.75  :
						($_ <= 1.9)  ?   4.26  :
						($_ <= 2)  	 ?   4.8  :
						($_ <= 2.1)  ?   5.38  :
						($_ <= 2.2)  ?   5.99  :
						($_ <= 2.3)  ?   6.63  :
						($_ <= 2.4)  ?   7.3  :
						($_ <= 2.5)  ?   8.01  :
						($_ <= 2.6)  ?   8.74  :
						($_ <= 2.7)  ?   9.51  :
						($_ <= 2.8)  ?   10.31  :
						($_ <= 2.9)  ?   11.14  :
						($_ <= 3)    ?   12.01  :
						($_ <= 3.5)  ?   12.91  :
										13.84;

					$copay2_full_d = ($_ <= 1)     ?   0       :
						($_ <= 1.1)  ?   0.37  :
						($_ <= 1.2)  ?   0.48  :
						($_ <= 1.3)  ?   0.59  :
						($_ <= 1.4)  ?   0.71  :
						($_ <= 1.5)  ?   0.85  :
						($_ <= 1.6)  ?   1  :
						($_ <= 1.7)  ?   1.16  :
						($_ <= 1.8)  ?   1.33  :
						($_ <= 1.9)  ?   1.51  :
						($_ <= 2)    ?   1.7  :
						($_ <= 2.1)  ?   1.9  :
						($_ <= 2.2)  ?   2.12  :
						($_ <= 2.3)  ?   2.35  :
						($_ <= 2.4)  ?   2.58  :
						($_ <= 2.5)  ?   2.83  :
						($_ <= 2.6)  ?   3.09  :
						($_ <= 2.7)  ?   3.37  :
						($_ <= 2.8)  ?   3.65  :
						($_ <= 2.9)  ?   3.94  :
						($_ <= 3)    ?   4.25  :
						($_ <= 3.5)  ?   4.57  :
										4.9;

					 $copay1_part_d = ($_ <= 1)     ?   0       :
						($_ <= 1.1)  ?   0.53  :
						($_ <= 1.2)  ?   0.67  :
						($_ <= 1.3)  ?   0.83  :
						($_ <= 1.4)  ?   1.01  :
						($_ <= 1.5)  ?   1.2  :
						($_ <= 1.6)  ?   1.41  :
						($_ <= 1.7)  ?   1.63  :
						($_ <= 1.8)  ?   1.87  :
						($_ <= 1.9)  ?   2.13  :
						($_ <= 2)    ?   2.4  :
						($_ <= 2.1)  ?   2.69  :
						($_ <= 2.2)  ?   2.99  :
						($_ <= 2.3)  ?   3.31  :
						($_ <= 2.4)  ?   3.65  :
						($_ <= 2.5)  ?   4  :
						($_ <= 2.6)  ?   4.37  :
						($_ <= 2.7)  ?   4.76  :
						($_ <= 2.8)  ?   5.16  :
						($_ <= 2.9)  ?   5.57  :
						($_ <= 3)    ?   6  :
						($_ <= 3.5)  ?   6.45  :
									6.92;

					$copay2_part_d = ($_ <= 1)     ?   0       :
						($_ <= 1.1)  ?   0.18  :
						($_ <= 1.2)  ?   0.23  :
						($_ <= 1.3)  ?   0.29  :
						($_ <= 1.4)  ?   0.35  :
						($_ <= 1.5)  ?   0.42  :
						($_ <= 1.6)  ?   0.49  :
						($_ <= 1.7)  ?   0.56  :
						($_ <= 1.8)  ?   0.65  :
						($_ <= 1.9)  ?   0.74  :
						($_ <= 2)    ?   0.83  :
						($_ <= 2.1)  ?   0.93  :
						($_ <= 2.2)  ?   1.04  :
						($_ <= 2.3)  ?   1.15  :
						($_ <= 2.4)  ?   1.26  :
						($_ <= 2.5)  ?   1.38  :
						($_ <= 2.6)  ?   1.51  :
						($_ <= 2.7)  ?   1.64  :
						($_ <= 2.8)  ?   1.78  :
						($_ <= 2.9)  ?   1.93  :
						($_ <= 3)    ?   2.13  :
						($_ <= 3.5)  ?   2.52  :
										2.99;
				}
			}
			#  There is no additional co-payment for more than two children in child care. We need to calculate co-pays for the two youngest children receiving subsidized child care.  No fee will be applied a second time, for children experiencing two bouts of care in the same day. Although it is doube-worth checking, it seems that no matter what the types of care for each child, the spr_child will always be higher for younger children. We can use the calculation of spr_child above, then, to determine the order of the co-pay accounting below, instead of the iterative method used below.
			# determine child order
			$youngest_child = 6; #There are only up to five chlidren, so the youngest child will be assigned a number less than this.
			for(my $i=1; $i<=$in->{'child_number'}; $i++) { 
				if ($out->{'unsub_child' . $i} > 0 && $in->{'child'.$i.'_age'} < $youngest_child) {
					$youngest_child = $i;
				}
			}

			$secondyoungest = 6;
			for(my $i=1; $i<=$in->{'child_number'}; $i++) {
				if ($out->{'unsub_child' . $i} > 0 && $in->{'child'.$i.'_age'} < $secondyoungest && $i !=  $youngest_child) {
					$secondyoungest = $i;
				}
			}
			
			if ($youngest_child == 6) {
				$youngest_child = 0;
			}
			if ($secondyoungest == 6) {
				$secondyoungest = 0;
			}
			
			# Parents only pay for one type of care per day; if they have nontraditional schedules that require two separate child care bouts in terms of provider billing, parents are only responsible for co-payments on the service with the largest number of hours, not the second bout. This is why we do not invoke the "extracare" variables that appear in the child_care code. See page 38 of Eligibility Determinations forSubsidized Child Care Policy Manual.  
			if ($youngest_child > 0) {
				for(my $i=1; $i<=7; $i++) {
				  # youngest child calcs:
					if ($out->{'cc_day'.$i.'_hours_child' . $youngest_child} >= $out->{'ft_hours_min'}) {
						${'day'. $i . 'copay1' } = $copay1_full_d;
					} elsif ($out->{'cc_day'.$i.'_hours_child' . $youngest_child} > 0) { 
						${'day'. $i . 'copay1' } = $copay1_part_d;
					} else {
						${'day'. $i . 'copay1' } = 0;
					}

					if($out->{'summer_cc_day'.$i.'_hours_child' . $youngest_child} >= $out->{'ft_hours_min'}) {
						${'summerday'. $i . 'copay1' } = $copay1_full_d;
					} elsif ($out->{'summer_cc_day'.$i.'_hours_child' . $youngest_child} > 0) { 
						${'summerday'. $i . 'copay1' } = $copay1_part_d;
					} else {
						${'summerday'. $i . 'copay1' } = 0;
					}
				}
			}
			if ($secondyoungest > 0) {
				for(my $i=1; $i<=7; $i++) {
						
					  # second youngest child calcs:
					if ($out->{'cc_day'.$i.'_hours_child' . $secondyoungest} >= $out->{'ft_hours_min'}) {
						${'day'. $i . 'copay2' } = $copay2_full_d;
					} elsif ($out->{'cc_day'.$i.'_hours_child' . $secondyoungest} > 0) { 
						${'day'. $i . 'copay2' } = $copay2_part_d; 
					} else {
						${'day'. $i . 'copay2' } = 0;
					}

					if($out->{'summer_cc_day'.$i.'_hours_child' . $secondyoungest} >= $out->{'ft_hours_min'}) {
						${'summerday'. $i . 'copay2' } = $copay2_full_d; 
					} elsif ($out->{'summer_cc_day'.$i.'_hours_child' . $secondyoungest} > 0) { 
						${'summerday'. $i . 'copay2' } = $copay2_part_d;
					} else {
						${'summerday'. $i . 'copay2' } = 0;
					}
				}
			}
			$ccdf_child1_copay = 	(52-$summerweeks)*($day1copay1 +$day2copay1 + $day3copay1 +$day4copay1 +$day5copay1 +$day6copay1 +$day7copay1) + $summerweeks * ($summerday1copay1 + $summerday2copay1 +  $summerday3copay1 + $summerday4copay1 +$summerday5copay1 +$summerday6copay1 +$summerday7copay1); #In this calculation, "child1" is the youngest child, not actually child 1.
			$ccdf_child2_copay = 	(52-$summerweeks)*($day1copay2 +$day2copay2 + $day3copay2 +$day4copay2 +$day5copay2 +$day6copay2 +$day7copay2) + $summerweeks * ($summerday1copay2 + $summerday2copay2 +  $summerday3copay2 + $summerday4copay2 +$summerday5copay2 +$summerday6copay2 +$summerday7copay2); #In this calculation, "child2" is the second-youngest child, not actually child 2.
			$ccdf_copay = $ccdf_child1_copay + $ccdf_child2_copay;
			#
			# 4. DETERMINE VALUE OF CARE (AND COMPARE TO COPAY)
			#
			if($ccdf_copay > $out->{'unsub_all_children'}) {
				# In this case, the unsubsidized cost of child care is cheaper, so the family will opt for that.
				$cc_subsidized_flag = 0;
				# skip to step 5
			} else {
				$cc_subsidized_flag = 1;
				if ($ccdf_copay > $out->{'spr_all_children'}) { 
					# This elsif will be true, and the above if will be false, if the user selects a cheaper subdized child care settting  than unsubdsidized setting, and in the event that both are more expensive than total ccdf co-pays.
					$child_care_expenses = $out->{'spr_all_children'};
					for(my $i = 1; $i <= $in->{'child_number'}; $i++) {		
						${'child_care_expenses_child'.$i} = $out->{'spr_child'.$i};
					}
				} else { 
					$child_care_expenses = $ccdf_copay;
					if ($youngest_child > 0) {
						${'child_care_expenses_child'.$youngest_child} = $ccdf_child1_copay;
					}
					if ($secondyoungest > 0) {
						${'child_care_expenses_child'.$secondyoungest} = $ccdf_child1_copay;
					}
				}
				$child_care_recd = &pos_sub($out->{'fullcost_all_children'}, $child_care_expenses);
				for(my $i = 1; $i <= $in->{'child_number'}; $i++) {		
					if ($out->{'unsub_child' . $i} > ${'child_care_expenses_child'.$i}) {
						${'child_care_recd_flag_child'.$i} = 1;
					}
				}
			}
		}
	} 	        
    #
    # STEP 6. DETERMINE UNSUBSIDIZED COST OF CARE
    #
    if($cc_subsidized_flag == 0) {
		$child_care_expenses = $out->{'unsub_all_children'}; #We include a the discount_amount here, which is set to 0 unless a family both qualifies and has entered in an override amount that is less than the parent share (sliding scale payment) of child care. Adding that to families that lose CCDF subsidies models the access to below-market rates that the family has. 
		$child_care_recd = 0;
		for(my $i = 1; $i <= $in->{'child_number'}; $i++) {		
			${'child_care_expenses_child'.$i} = $out->{'unsub_child' . $i};
		}
	}

 	$child_care_expenses_m = $child_care_expenses / 12;       

	#debugging
	 foreach my $debug (qw(child_care_recd child_care_expenses ccdf_eligible_flag ccdf_poverty_percent ccdf_step copay1_full_d copay2_part_d copay2_full_d copay2_part_d ccdf_child1_copay ccdf_child2_copay ccdf_copay cc_subsidized_flag child_care_recd ccdf_income)) {
		print $debug.": ".${$debug}."\n";
	}

  # outputs
    foreach my $name (qw(child_care_expenses child_care_expenses_m  cc_subsidized_flag ccdf_eligible_flag child_care_recd ccdf_step parent_copay_percent child_care_expenses_child1 child_care_expenses_child2 child_care_expenses_child3 child_care_expenses_child4 child_care_expenses_child5 child_care_recd_flag_child1 child_care_recd_flag_child2 child_care_recd_flag_child3 child_care_recd_flag_child4 child_care_recd_flag_child5)) {
        $out->{$name} = ${$name};
    }
	
}

1;