#=============================================================================#
#  TANF – 2021 DC
#=============================================================================#
#	
# INPUTS OR OUTPUTS NEEDED FOR CODE:
#
# INPUTS FROM USER 
#	parent#_employedhours_initial
#	unearn_gross_mon_inc_amt_ag			#the sum of all unearned income from assistance group 
#	parent#_selfemployed_netprofit			#earnings from self-employment per parent.
#   child_number
#	disability_personal_expenses_m
#	child#_age							#age of each child in family/assistance group
#	parent#_age							#age of each parent
#	
#	parent#_sanctioned_initial			#indicating whether parent # is sanctioned 
#	foster_care_pymnt_ag				#amount paid to foster parents for the entire ag
#	unearned_income_in_kind_ag
#	adoption_sub_pymnt_ag
#									
#	OUTPUT FROM CCDF/CHILD CARE
#	child_care_expenses_m
#   
#	OUTPUT FROM PARENT EARNINGS
#	parent1_earnings
#	parent2_earnings
#	parent3_earnings
#
#	OUTPUT FROM PARENT_EARNINGS
#	parent#_transhours_W
#
# 	OUTPUTS FROM SSI: 
#	parent#_SSI
#	ssi_recd_m
#
#	OUTPUTS FROM CHILD_SUPPORT
#	child_support_paid
#
#	OUTPUT FROM UNEMPLOYMENT
#	ui_recd_m
#=============================================================================#
# NOTE: FOR NOW, WE ARE NOT ACCOUNTING FOR INSTANCES OF MORE THAN ONE ASSISTANCE GROUP IN HH. THIS IS A POTENTIAL AREA FOR IMPROVEMENT IN THE MTRC.
#=============================================================================#

#Notes:
#Anyone who receives TANF also is eligible to receive Medicaid.

sub tanf
{

    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# OUTPUTS     
    our $tanf_asset_limit = 2000;       # TANF asset limit
    our $tanf_perchild_cc_ded = 175;    # Max per child care deduction
    our $tanf_under2_add_cc = 25;       # Additional per child care deduction for child < 2
	our $no_tanf_lifetime_limit = 1; #DC does not impose a lifetime TANF time limit.
	our $tanf_eligible_adult_children = 0;
	our @tanf_maxben_array = (0,414,515,658,804,928,1091,1251,1382,1522,1653); 
    our $workexpense_ded = 160; 	#The first income deduction, of up to the first $160 earned per TANF unit member.
    our $earnedincome_dis= 2/3; 	#The earned income disregard, reducing countable income above the amount of the work expense deduction by this portion of earnings.
    our $passthrough_max = 150; # maximum child support pass-through per month

	#CALCULATED IN MACRO
    our $tanf_recd  = 0;   		 #annual amount of tanf cash assistance received
    our $tanf_recd_m    = 0;   	 #monthly amount of tanf cash assistance received
    our $child_support_recd = 0;    
	our $child_support_recd_m   = 0;
	our $tanf_maxben = 0;
    our $tanf_family_structure = 0;
    our $unit_size = 0;
	our $tanf_excluded_income = 0; 	# parental income excluded from TANF calculations when parent is on SSI.
    our $tanf_parent1_earnings_m = 0; 	# non-excluded parent 1 earnings
    our $tanf_parent2_earnings_m  = 0;	# non-excluded parent 2 earnings
    our $tanf_parent3_earnings_m  = 0;	# non-excluded parent 3 earnings
    our $tanf_parent4_earnings_m  = 0;	# non-excluded parent 4 earnings
    our $tanf_cc_ded_recd = 0;          # tanf child care deduction
    our $tanf_earned_ded_recd = 0;      # earned income deduction
    our $tanf_earnings = 0;             # adjusted (monthly) earnings for tanf benefits, after child care and earnings ded
    our $tanf_income_m = 0;               # adjusted (monthly) income for tanf benefits
	our $members_exempt_from_workreq = 0;
	our $noncountable_tanf_income = 0;	#This is the amount of TANF income that is excluded from SNAP and Mediciad (and other programs) if states make any such exclusions
	our $potential_unit_size = 0;
	our $tanf_potential_maxben = 0; 				
	our $tanf_potential_recd_m = 0;
	our $tanf_workhours_min_total = 0; #Total work hours needed for family.
	our $tanf_months_remaining = 0;
	our $family_sanctioned = 0;
	our $tanf_sanctioned_amt = 0; 
    our $stipend_amt = 0; 
	our $total_work_hours = 0;

 	#our $tanfworkbonus_approx = 200;	 # Approximate (or placeholder) TANF work bonus. 


	# 
    #
    #
	#
	#

	#Defining some variables needed for work requirements, eligibility, etc.:
	
			
	# Check eligibility for ABAWDs.
	for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
		if ($in->{'parent'.$i.'_age'} == 18) { #We check for high school eligibility but not among the family spouses.
			$tanf_eligible_adult_children += 1;
		}
	}

	if ($in->{'tanf'} == 1 && $in->{'child_number'} + $tanf_eligible_adult_children > 0) {	 #In DC, you can only get TANF if you have a child in the home. 

		if ($out->{'ssi_recd'}) {  
			$unit_size = $in->{'family_size'} - $in->{'disability_count'}; 
			$tanf_family_structure = $in->{'family_structure'} - $in->{'disability_count'}; 
			for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
				if ($in->{'disability_parent'.$i}) {
					$tanf_excluded_income += $out->{'parent'.$i.'_earnings_m'};
					${'tanf_parent'.$i.'_earnings_m'} = 0;			 
				} else {
					${'tanf_parent'.$i.'_earnings_m'} = $out->{'parent'.$i.'_earnings_m'}; 
				}
			}
		} else {
			$unit_size = $in->{'family_size'};
			$tanf_family_structure = $in->{'family_structure'};
			$tanf_parent1_earnings_m = $out->{'parent1_earnings_m'};
			$tanf_parent2_earnings_m = $out->{'parent2_earnings_m'};
			$tanf_parent3_earnings_m = $out->{'parent3_earnings_m'};
			$tanf_parent4_earnings_m = $out->{'parent4_earnings_m'};
	   
		}
		
		#IS WORKER MEETING WORK REQUIREMENTS?
		if ($in->{'tanfwork'} == 1 && 1 == 0) { #DC, like some other states, has asked that the tool not include sanctions that are based on work requirements for the MTRC tool. Hence the always-false condition above.


			#WHEN A PERSON IS ON TANF SANCTIONS, THEY ARE COUNTED AS PART OF THE BUDGET GROUP, BUT JUST DON'T RECEIVE ANY TANF BENEFITS. THIS MEANS THEIR INCOME COUNTS BUT THE FAMILY SIZE DOES NOT INCREASE TO GAIN ACCESS TO HIGHER BENEFITS.
			
			#Note: NCCP's FRS approaches TANF work requirements differently, by assuming that individuals on TANF who do not have wage work satisfying TANF work requirements will enroll in qualifying training opportunities to satisfy these work requirements. In the MTRC, however, we are asking specifically whether individuals are engaged in activities that satisfy work requirements, as the MTRC as a tool makes far fewer assumptions than the FRS does regarding work schedules.

			#Aside from units with characteristics outside the scope of the MTRC, the following TANF applicants/recipients are exempt from work participation:
			#• a single custodial parent with a child under 12 months;
			#• a recipient 60 years old or older;
			#• a person who is ill, injured, or incapacitated as determined by competent medical evidence (and his/her condition is expected to last longer than four weeks);
			
			for(my $i = 1; $i <= $in->{'family_structure'}; $i++) { #Let's do up to 4 parents possibly on sanctions.
				# NH note: It appears that NH does not have separate two-parent work requirement standards, in contrast to other states that follow federal minimums. NH does, however, include a fairly broad array of activities that could be undertaken to satisfy job requirements, including job search activitities. "Job search" or other similarly vague-sounding activities cannot, however, lead toward satisfaction of work requirements without being part of a TANF recipient's Employability Plan (EP), which is determined at intake and presumably regularly reviewed throughout participation. We can therefore assume that people who are on sanctions are not satisfying their EP. Given this framework, it seems possible that someone may not be satisfying their work requirements not because of lower than required hours, but that they are not engaged in the activities detailed in their EP, even if they are working enough hours to satisfy work requirements. It seems plausible, however, that if an individual is both sanctioned and working below the work rquirement working hours, that gaining enough employment hours to satisfy the work requirements would allow an individual to at least temporarily be removed from sanctions.
				#See FAM 808.27 and FAM 808.37 for work requirement rules.
				$total_work_hours += $out->{'parent'.$i.'_transhours_w'};
				if ($in->{'parent'.$i.'_age'} > 59 || $in->{'disability_parent'.$i}) {
					$members_exempt_from_workreq += 1;
				}
			}
			
			if ($in->{'family_structure'} - $members_exempt_from_workreq <= 0) {
				#No adults in the household need to satisfy work requirements.
				$tanf_workhours_min_total = 0;				
			} elsif ($in->{'family_structure'} - $members_exempt_from_workreq == 1) { 
				if ($in->{'children_under1'} > 0) {
					$tanf_workhours_min_total = 0;
				} elsif ($in->{'children_under6'} > 0) {
					$tanf_workhours_min_total = 20;
				} else {
					$tanf_workhours_min_total = 30;
				}
			} else { #2-parent family,
				if ($out->{'child_care_recd'} > 0) {  
					$tanf_workhours_min_total = 55;
					#If one parent is sanctioned (DS), disqualified (DF) or not eligible (NS), the other parent must participate for a minimum of 55 hours per week. At least 50 hours must be in core activities. The logic below should bear this out.
				} else {
					$tanf_workhours_min_total = 35;
				}
			}

			if ($total_work_hours < $tanf_workhours_min_total) {
				$family_sanctioned = 1;
				#The difference here is that the children lose TANF too if sanction occurs after 24 months of receiving TANF.
			}
		}

		$potential_unit_size = $unit_size; 
		if ($family_sanctioned == 1) {
			$unit_size = &pos_sub($unit_size , &pos_sub($in->{'family_structure'}, $members_exempt_from_workreq));
		}
		
		$tanf_maxben = $tanf_maxben_array[$unit_size];  # max TANF benefit (monthly) 
		$tanf_potential_maxben = $tanf_maxben_array[$potential_unit_size]; 						

			
		#CHANGE FOR 2021:
		#ADDED CHILD_CARE_EXPENSES_CHILDX TO TO CCDF CODE. IF NEEDED, FORM AN AVERAGE PER CHILD. THIS IS POSSIBLE DESPITE THE CONSIDERATIONS ABOVE BECAUSE CCDF DOES NOT NEED TANF INCOME, JUST CHILD SUPPORT INCOME. SINCE WE ARE ASKING WHETHER THE USER IS CURRENTLY ON TANF, AND THEIR CHILD SUPPORT OWED, WE CAN ESTIMATE THAT CHILD SUPPORT RECEIVED IS THE LOWER BETWEEN 150 (THE CHILD SUPPORT PASS-THROUGH) AND THEIR CHILD SUPPORT OWED/PAID. SO WE CAN RUN CHILD CARE AND CCDF SOMEWHAT ACCURATELY PRIOR TO TEH CALCULATION OF TANF, AND CAN USE CHILD CARE EXPENSES PER CHILD (AFTER CCDF IS RUN) TO DETERMINE THE SIZE OF THE TANF DEPENDENT CARE DEDUCTION.
		
		#Note: The ESA policy manual indicates that if a family receiving TANF is also receiving CCDF subsidies, then the costs eligible for the TANF dependent care deduction can include CCDF co-payments. But while the TANF dependent care deduction is applied per child -- up to $175 or $200 per child to cover child care -- the CCDF co-payments are determined per family, and calculated such that parents pay co-payments based on income and the type of care used by the two youngest children in child care. Additional child care use by any older children does not increase the amount of co-pays a family pays. For determining the value of the TANF dependent care deduction for CCDF recipients, considering the co-pays as specific to each child for whom co-pays are calculated or considering them as a family payment -- possibly divided evenly across all children in care -- could conceivably affect how much in TANF child care deductions a family receives. However, in many if not all instances, a family on TANF and CCDF would not pay any co-pays, since co-pays start at incomes above 100% of the federal poverty level, and the amount of copay per child only potentially exceeds the maximum TANF child care deduction at incomes greater than 210% FPL, when the daily co-payment for full-time care exceeds the smallest maximum TANF dependent care deduction ($175) divided by the maximum number of days in a month (31), or $5.64 per day. (The daily copayment for full-time care for the youngest child in care is is $5.38 at 210% FPL , and $5.99 beteween 210% and 220% FPL). This means that whether a family pays more depending on whether this deduction is based on co-pays counted individually or as a whole only is a concern if families are on TANF above 210% FPL.  Even with DC's relatively generous TANF program compared to other states, this appears to be either mathematically impossible or so rare that it is not worth clarifying at this point, so we are just incorporating co-payments made to cover the youngest two children receiving CCDF child care. (But if anyone in DC is reading this, and feel that the policy needs to be represented differently, the codes for determining this are in the ccdf_mtrc.pl code.)
		
		for(my $i = 1; $i <= $in->{'child_number'}; $i++) {		
			if($in->{"child" . $i . "_age"} < 13) {				
				if($in->{"child" . $i . "_age"} < 2) {		
					$tanf_cc_ded_recd += &least($out->{'child_care_expenses_child'.$i}/12, ($tanf_perchild_cc_ded + $tanf_under2_add_cc));
				} else {
					$tanf_cc_ded_recd += &least($out->{'child_care_expenses_child'.$i}, $tanf_perchild_cc_ded); 
				}
			}	
		}
		
		if ($in->{'disability_count'} > 0)  {
			$tanf_cc_ded_recd += &least($in->{'disability_personal_expenses_m'}, $tanf_perchild_cc_ded);	
		}
	
		#
        # 3. CALCULATE EARNED INCOME DEDUCTION
        #


		for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
			$tanf_earned_ded_recd += &least(${'tanf_parent'.$i.'_earnings_m'}, ($workexpense_ded + (&pos_sub(${'tanf_parent'.$i.'_earnings_m'}, $workexpense_ded) * $earnedincome_dis))); 
		}
		#
		# 4. INCOME TEST FOR RECIPIENTS
		#
								  
	
		# “The SSR should never deem the income and/or assets of an SSI recipient to the group” (p101).  
		# So, we need to reduce the TANF income of this group by the income of the adults receiving SSI. 
		# This is consistent with our removal of SSI recipients from the unit above. 
		$tanf_earnings = &pos_sub($out->{'earnings_mnth'}, ($tanf_excluded_income + $tanf_earned_ded_recd + $tanf_cc_ded_recd));
		# It seems that the ESA manual excludes earnings from interest as income, for all programs (see p258). That seems weird, and inconsistent with federal policy. Check with DC, is interest counted in Medicaid and TANF (and SNAP) determinations, as one would expect?
		 
		# See ESA policy manual page 260: for TANF recipients (not applicants), assume that all child support paid from the absent parent  is being collected by CSSD, after the first two months of TANF enrollment. So, unlike previous FRS versions, we are not counting child support in the calculation of TANF income.
		# Social Security benefits count as countable income, including SSDI. But since SSI recipients are not a part of the TANF unit, SSI benefits do not count toward TANF income, even if the SSI recipient shares that SSI income with TANF unit members (ESA manual page 275). # Note WIC income is also excluded, as is SNAP (p268). From the definition of “capital gains/interest/divdends” in ESA policy manual page 258, it does not appear that interest counts as income.
		
		#If we separateed self-employed earnings from earnings, they would be counted here as well.
		$tanf_income_m = $tanf_earnings + $in->{'alimony_paid_m'} + $out->{'ui_recd_m'};
		
		if ($tanf_income_m >= $tanf_maxben) { 
			$tanf_recd = 0;
			$tanf_recd_m = 0;
		} else  {


			# 5. CALCULATE TANF BENEFIT LEVEL FOR ELIGIBLE RECIPIENTS
			#
			# The tanf_recd_m calculation must be a rounded-down difference between tanf_maxben and tanf_earnings. 
			$tanf_recd_m = floor(&pos_sub($tanf_maxben, $tanf_income_m));
			$tanf_potential_recd_m = floor(&pos_sub($tanf_potential_maxben, $tanf_income_m));
			# We now reduce a family’s TANF grant if they are under sanctions. According to the most recent ESA policy manual, people on sanctions means they cannot get TANF assistnace, apparently due to a household's maximum benefit being reduced.
			$tanf_sanctioned_amt = &pos_sub($tanf_potential_recd_m, $tanf_recd_m); #This is important for some policies that require the inclusion of the amount of TANF received plus the amount that is sanctioned..
			#Tried to include work bonuses in 2017; it ended up being not as demonstrative as hoped, and was an abstraction anyway. There are one-time workbonuses for TANF recipients who keep jobs for certain periods of time, but they are one-time, so don't really work in the MTRC model. Commenting out for now.
			
			#if ($in->{'workbonuses'} && $in->{'tanfwork'} && $tanf_recd_m >0 && $out->{'earnings_mnth'} > 0) { 
				# We build in work bonuses now, based on an approximate bonus for time spent working. I’m thinking we should use an “elsif” here so that families on sanctions are not allowed to get work bonuses (since the main reason why they are sanctioned is because they are either not working or have recently not worked). It similarly also makes sense to model bonuses only to families that are currently meeting TANF work requirements (tanfwork equals 1). However, the tanfwork variable is still important for the work module, because leaving it unselected allows families to avoid paying extra child care and transportation costs while still on TANF. Depending on whether they also select workbonuses, they may or may not be sacrificing the additional benefit that comes with those bonuses, but I don’t believe these should be mutually exclusive, meaning that these three variables (sanctioned, workbonuses, and tanfwork) all should be retained in the model, at least for now. 
			#	$tanf_recd_m = $tanf_recd_m + $tanfworkbonus_approx;
			#}

			# We can now also account for TANF transportation stipends, which are actually subsidies rather than reimbursements. We can take an average to approximate the transit stipends, although this might be worth looking at more closely because in some cases, a parent might be working much more on one day than on the next day. Per conversation with DC DHS in 2017, and as verified in the ESA policy manual 2017 we are only modeling travel stipends when parent(s) in the family is/are not working, but are in training. 
			for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
				if ($tanf_recd_m > 0 && $out->{'earnings'} == 0 && $in->{'parent'.$i.'_traininghours'} > 0) { 
					if ($in->{'parent'.$i.'_transdays_w'} / $in->{'parent'.$i.'_traininghours'} >= 4) { 
						$stipend_amt += 15 * $in->{'parent'.$i.'_transdays_w'} * 4.33; 
					} 
				}
			}
			$tanf_recd_m += $stipend_amt; 

			$tanf_recd = 12 * $tanf_recd_m;
			# From ESA manual, p226: “If support is collected and is less than the grant, it is retained by CSED to defray the costs of providing assistance to the group. After two consecutive months of collections that are greater than the current TANF grant, the TANF case is closed, and the child support is sent directly to the family. All support collected by CSED in excess of the TANF grant must be returned to the family and
			# counted as unearned income (see Section 4.9: Child Support in Part VI).” ESA manual p261 clarifies that when two months of child support exceed the TANF grant by $150, the TANF grant is terminated. Presumably, the excess amount (at least $150) is returned to the family, per the guidance on page 226. 

			if ( ($out->{'child_support_paid_m'} - $tanf_recd_m ) > $passthrough_max) { 
				$tanf_recd_m = 0;
				$tanf_recd = 0;
			}
		}
	
		#

		# Now calcualte teh annual TANF benefit received.
		#If living in a state with no lifetime TANF limit, do not count TANF months. If not, count them.
		if ($no_tanf_lifetime_limit == 0) {
			$tanf_months_remaining = pos_sub(60, $in->{'tanf_months_received'});
		} else {
			$tanf_months_remaining = 12;
		}
		$tanf_recd = $tanf_recd_m * least(12, $tanf_months_remaining); 
	}
	# Now calculate whether the family receives no child support because they get TANF. NH does not appear to have a pass through.
	#Calculate the maximum child support pass through. Note: this is identical to the calculation of the exclusion of child support and spousal support income in LIHEAP.
	#if ($out->{'child_support_recd_m'} + $in->{'alimony_paid_m'} > 0) {
	#	$support_exclusion = &greatest(&least($in->{'alimony_paid_m'},$alimony_exclusion), &least($out->{'child_support_recd_m'}, $child_support_exlusion_perchild * $in->{'child_number'}, $child_support_exclusion_max));
	#	$child_support_passthrough =  pos_sub($out->{'child_support_recd_m'} + $in->{'alimony_paid_m'}, $support_exclusion);
	#}

	#}
	if ($tanf_recd_m > 0 && $tanf_months_remaining >= 12) { #For families not receiving child support, this output variable wil be 0. For others, it compares child support payments against potential TANF benefits.
		$child_support_recd = 12*(&least($out->{'child_support_paid_m'},$passthrough_max));			#state takes child support from families receiving FANF but passes through some of it. NH has this policy, PA does not.  Potential policy change.
	} elsif ($tanf_recd_m > 0 && $out->{'child_support_paid_m'} > 0) {
		$child_support_recd = $tanf_months_remaining * (&least($out->{'child_support_paid_m'},$passthrough_max)) + (12 - $tanf_months_remaining) * $out->{'child_support_paid_m'}; #The family starts receiving child support once they run out of TANF months.
	} else { #Either the family does not get TANF or child support is always greater than potential TANF cas assistance.
		$child_support_recd = $out->{'child_support_paid'};	 
		$tanf_recd = 0;
	}			
	$child_support_recd_m = $child_support_recd / 12; #For families that receive some TANF and some child support, this is the average child support received. For programs that are calculated monthly, this may cause calculations to be off by a little, but likely not a lot.

	#A note about TANF transportation subsidies:
	#Some states allow for transportation reimbursement for job-seeking activities, training, and some job retention activities. Conceivably, the trasnportation module could be moved to after the tanf module (or possibly re-run after TANF) to reduce transportation costs by these reimbursements. Transportation reimbursements should still be considered for other states.

	#debugging:
	foreach my $debug (qw(tanf_recd tanf_income_m parent1_sanctioned parent2_sanctioned parent3_sanctioned parent4_sanctioned)) {
		print $debug.": ".${$debug}."\n";
	}
	
	# outputs
    foreach my $name (qw(tanf_recd tanf_income_m  tanf_recd_m child_support_recd child_support_recd_m tanf_sanctioned_amt tanf_cc_ded_recd noncountable_tanf_income)) { 
       $out->{$name} = ${$name};
    }
	
}

1;