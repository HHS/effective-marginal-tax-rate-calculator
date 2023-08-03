#=============================================================================#
#  TANF – 2021 PA
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
#	ag_size_cnt							#Variable found in budget tab of samplev2.5(3) sheet. This is written assuming that this indicates the size of the assistance group counted for purposes of calculating the FANF grant
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
    our $tanf_recd  = 0;   		 #annual amount of tanf cash assistance received
    our $tanf_recd_m    = 0;   	 #monthly amount of tanf cash assistance received
    our $child_support_recd = 0;    
	our $child_support_recd_m   = 0;
   
	# HARD CODED POLICY VARIABLES USED            
	our $alimony_exclusion = 50;
	our $gift_exclusion = 30; #The exclusion of gifts per quarter.
	our $child_support_exlusion_perchild = 100;
	our $child_support_exclusion_max = 200;
	our $work_expense_deduction = 50; #See section 137.4 of the PA Cash Assistance handbook
	our $earnedincome_dis_curr = 0.50; 		#The earned income disregard on gross earned income is 0.50.
	our $tanf_fulltime_thresh = 30;	#The amount of hours that qualify as full-time work
 	our @tanf_maxben_array = (0,205, 316, 403, 497, 589, 670, 753, 836, 919); #PA family size allowance for Allegheny County. This varies by county. Last checked 5/25/21. 

	#OTHER VARIABLES USED
	our $meets_fulltime_thresh = 0;
	our $support_exlcusion = 0;
	our $child_support_passthrough = 0;
	our $children_under6 = 0;			# number of children under6
	our $incapacitated_num = 0;			#number of incapacitated adults that are being cared for by eligible individualsour 
	our $parent1_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent2_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent3_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent4_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent1_hs_student = 0; #Whether the adult is a full-time high school student and therefore has his earnings excluded from income.
	our $parent1_adult_hs_student = 0; #Whether the head of household qualies as a full high school student.
	our $parent2_adult_hs_student = 0; #Whether the head of household's spouse qualies as a full high school student.
	our $parent3_adult_hs_student = 0; #Whether the head of household's spouse qualies as a full high school student.
	our $parent4_adult_hs_student = 0; #Whether the head of household's spouse qualies as a full high school student.
	our $parent2_hs_student = 0;
	our $parent3_hs_student = 0;
	our $parent4_hs_student = 0;
	our $eligible_adult_students = 0;
	our $tanf_family_size = 0; #Who is counted in the budget group.
	our $tanf_potential_family_size = 0; #Who could be counted in the budget group, separate from sanction considerations.
	our $tanf_workhours_min = 0; #minimum number of hours engaged in work or eligibilty activity to satisfy TANF work requirements
	our $tanf_core_hours_min = 0;	#The core activities required for TANF families.
	our $tanf_workhours_min_total = 0; #Total work hours needed for family.
	our $tanf_core_hours_min_total = 0; #Total number of hours for core activities in a two parent family.
	our $total_work_hours = 0; #The total number of work hours in the family counting toward TANF work requirements.
	our $total_core_hours = 0; #The total number of work hours in the family counting toward TANF core work requirements.
	our $parent1_sanctioned = 0;		 
	our $parent2_sanctioned = 0;		 
	our $parent3_sanctioned = 0;		 
	our $parent4_sanctioned = 0;		 
	our $tanf_months_remaining = 0;
	our $meets_core_hours_min = 0;
	our $meets_work_hours_min = 0;
	our $family_sanctioned = 0;
	our $parents_sanctioned = 0;
	our $tanf_maxben = 0;				#TANF max benefit according to assistance group size
	# our $tanf_excluded_income = 0; 		# parental income excluded from TANF calculations when parent is on SSI. 
	our $tanf_potential_maxben = 0; 				
	our $tanf_potential_recd_m = 0;
	our $tanf_earnedincomep1 = 0;	
	our $tanf_earnedincomep2 = 0;
	our $tanf_earnedincomep3 = 0;
	our $tanf_earnedincomep4 = 0;
	our $tanf_earnedincome_m = 0;			#annual amt of counted earned income
	our $tanf_income_m = 0;               # adjusted (monthly) income for tanf benefits
	our $tanf_dep_ded_recd = 0;			# estimated amount of adult dependent care deduction
	our $tanf_unearnedincome_m = 0;		#monthly unearned income counted for eligibility
	our $tanf_sanctioned_amt = 0; 
	our $noncountable_tanf_income = 0;	#This is the amount of TANF income that is excluded from SNAP and Mediciad (and other programs) if states make any such exclusions

	if ($in->{'tanf'} == 1) {	 	 # These are flags indicating current TANF cash recipients. Since we are only looking at current TANF recipients, we will assign tanf_recd = 0 to all receipients not receiving one of these benefits. 
	
		#Defining some variables needed for work requirements, eligibility, etc.:
		
		#Whether a head of household is a high school student is necessary to determine work requirements.
		if ($in->{'parent1_age'} < 22 && $in->{'parent1_ft_student'} == 1 && $in->{'parent1_educational_expenses'} == 0) {
			$parent1_adult_hs_student = 1;
		}

		if ($in->{'married1'} == 1) {
			for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
				if ($in->{'married2'} == $i && $in->{'parent'.$i.'_age'} < 22 && $in->{'parent'.$i.'_ft_student'} == 1 && $in->{'parent'.$i.'_educational_expenses'} == 0) { #The second married parent is a high school student.
				${'parent'.$i.'_adult_hs_student'} = 1;
				}
			}
		}

		for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
			if ($in->{'parent'.$i.'_age'} == 18 && $in->{'parent'.$i.'_ft_student'} == 1 && $in->{'parent'.$i.'_educational_expenses'} == 0 && ${'parent'.$i.'_adult_hs_student'} != 1) { #We check for high school eligibility but not among the family spouses.
				${'parent'.$i.'_hs_student'} = 1;
				$eligible_adult_students += 1;
			}
		}
		#	calculate the number of incapacitated adults in the AG - they are counted towards the FANF cash grant. We may be able to use the variable ag_size_cnt to figure out number of people included in assistance group. incapacity of parents is established if they receive ANB, APTD, OAA, and SSI (must be receiving SSI based on disability, not age).
		for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
			if ($in->{'disability_parent'.$i} == 1) {	#PA seemingly has a more expansive definition of incapcaity than other states, or at least NH.
				$incapacitated_num++;
				${'parent'.$i.'_incapacitated_tanf'} = 1;
			}
		}
		
		for(my $i = 1; $i <= $in->{'child_number'}; $i++) {
			#calculate the number of children under 6 in the assistance group.
			#This is also defined as an input in frs.pm. Could check to see if calculations match and then replace this one with that one.
			if($in->{"child" . $i . "_age"} < 6) {
				$children_under6++;				
				}
		}
				
		# Check eligibility for ABAWDs.

		if ($in->{'child_number'} + $eligible_adult_students > 0) {			#families without children are NOT eligible for TANF. We assume that children ages 16-17 are full time students and thereby eligible. 	

			if ($in->{'tanfwork'} == 1) { #NH has asked that the tool include sanctions that are based on work requirements for the MTRC tool. Allegheny County has not, so although these work requirements are calculated, they are never invoked due to an always-false condition if 1=0) below.
			
				if ($in->{'family_structure'} == 1) { #We assume this is a two-parent family. Again, this gets into a relationships issue -- we are not asking who the parents of the child(ren) are. Doing so would require a bunch more questions, but may be worth it.
					if ($parent1_adult_hs_student == 1) {
						$tanf_workhours_min = 0; #If head of household is under 22 and is a high school student, they satisfy work requirements.
						$tanf_core_hours_min = 0;
					} elsif ($children_under6 > 0 || $parent1_age == 1) {
						$tanf_workhours_min = 20; 
						$tanf_core_hours_min = 20;
					} else {
						$tanf_workhours_min = 30; 
						$tanf_core_hours_min = 20; #At least 20 of these hours must be in "core activities." These are the same reqs for pregnant single parents without other children.
						#We are adding in the logic core vs non-core considerations here, but for the time being are considering all hours in training or working to be core activities. We can ask whether separate questions in the user interface should be targeted to determining whether training is in core or non-core activities.
					}
				} else { #2-parent family,
					if ($parent1_adult_hs_student + $parent2_adult_hs_student + $parent3_adult_hs_student + $parent4_adult_hs_student == 2) {
						$tanf_workhours_min = 0; #If head of household and other parent are both under 22 and  high school students, they satisfy work requirements.
						$tanf_workhours_min_total = 0;
						$tanf_core_hours_min = 0;
						$tanf_core_hours_min_total = 0;						
					} elsif ($incapacitated_num > 0) {
						$tanf_workhours_min = 30; 
						$tanf_workhours_min_total = 30;
						$tanf_core_hours_min = 20; 						
						$tanf_core_hours_min_total = 20;						
					} elsif($out->{'child_care_recd'} > 0) {  
						$tanf_workhours_min_total = 55;
						$tanf_core_hours_min_total = 50; 
						$tanf_core_hours_min = 30; #one parent must work at least 30 hours a week in core activities
						$tanf_workhours_min = 30;
						#If one parent is sanctioned (DS), disqualified (DF) or not eligible (NS), the other parent must participate for a minimum of 55 hours per week. At least 50 hours must be in core activities. The logic below should bear this out.
					} else {
						$tanf_workhours_min_total = 35;
						$tanf_core_hours_min = 30;
					}
				}

				#WHEN A PERSON IS ON TANF SANCTIONS, THEY ARE COUNTED AS PART OF THE BUDGET GROUP, BUT JUST DON'T RECEIVE ANY TANF BENEFITS. THIS MEANS THEIR INCOME COUNTS BUT THE FAMILY SIZE DOES NOT INCREASE TO GAIN ACCESS TO HIGHER BENEFITS.
				
				#Note: NCCP's FRS approaches TANF work requirements differently, by assuming that individuals on TANF who do not have wage work satisfying TANF work requirements will enroll in qualifying training opportunities to satisfy these work requirements. In the MTRC, however, we are asking specifically whether individuals are engaged in activities that satisfy work requirements, as the MTRC as a tool makes far fewer assumptions than the FRS does regarding work schedules.
				
				for(my $i = 1; $i <= $in->{'family_structure'}; $i++) { #Let's do up to 4 parents possibly on sanctions.
					# NH note: It appears that NH does not have separate two-parent work requirement standards, in contrast to other states that follow federal minimums. NH does, however, include a fairly broad array of activities that could be undertaken to satisfy job requirements, including job search activitities. "Job search" or other similarly vague-sounding activities cannot, however, lead toward satisfaction of work requirements without being part of a TANF recipient's Employability Plan (EP), which is determined at intake and presumably regularly reviewed throughout participation. We can therefore assume that people who are on sanctions are not satisfying their EP. Given this framework, it seems possible that someone may not be satisfying their work requirements not because of lower than required hours, but that they are not engaged in the activities detailed in their EP, even if they are working enough hours to satisfy work requirements. It seems plausible, however, that if an individual is both sanctioned and working below the work rquirement working hours, that gaining enough employment hours to satisfy the work requirements would allow an individual to at least temporarily be removed from sanctions.
					#See FAM 808.27 and FAM 808.37 for work requirement rules.
					$total_work_hours += $out->{'parent'.$i.'_transhours_w'};
					$total_core_hours += $out->{'parent'.$i.'_transhours_w'}; #For now, we are assuming that all work or training hours are core hours. Without further questions, the two are not easily distinguishable.
					
					if ($out->{'parent'.$i.'_transhours_w'} > $tanf_core_hours_min && ($in->{'family_structure'} == 1  || $in->{'disability_parent'.$i} == 0)) {
						$meets_core_hours_min = 1;
					}

					if ($out->{'parent'.$i.'_transhours_w'} > $tanf_workhours_min && ($in->{'family_structure'} == 1  || $in->{'disability_parent'.$i} == 0)) {
						$meets_work_hours_min = 1;
					}
					if ($out->{'parent'.$i.'_transhours_w'} > $tanf_fulltime_thresh && $in->{'disability_parent'.$i} == 0) {
						$meets_fulltime_thresh= 1;
					}
					
					
				}
				
				if ($meets_core_hours_min == 0 || $meets_work_hours_min == 0 || $total_work_hours < $tanf_workhours_min_total || $total_core_hours  < $tanf_core_hours_min_total) {
					if ($in->{'tanf_months_received'} < 24) {
						$parents_sanctioned = 1;
						#RESET compliance includes more than just compliance for work hours, so conceivably some parents could be in compliance while others are not. But for our questions, we can assume that if work requirements are not met, all adults are on sanctions.
					} else {
						$family_sanctioned = 1;
						#The difference here is that the children lose TANF too if sanction occurs after 24 months of receiving TANF.
					}
				}
			}


			if ($family_sanctioned == 1 && 1 == 0) { #While it's good that we worked out the TANF work requirements above, Allegheny County has a waiver on TANF work requirements and is not following them, as clarified by Allegheny County DHS.
				$tanf_recd_m = 0;
				$tanf_sanctioned_amt = 0;  #Since we are looking at TANF eligibilty over the course of a year and families including individuals who are  noncompliant with TANF for 10 weeks are kicked off TANF, they will simply not be getting any TANF and the additional cash assistance they would have made on top of tanf_recd will be irrelevant. Keeping this in here because we may want to reconsider the time horizon of this approach elsewhere.

			} else {
				#A child is considered deprived based on unemployment regardless of the work history of either parent. A child is considered deprived based on unemployment if:
					#Both parents have no work or
					#One or both parents:
					#Have work in which the net earned income of the budget group, after allowable deductions, is less than the Family Size Allowance (FSA) for the budget group...

			 
			
				# calculate unearned income of all assistance group members. 


				if ($meets_fulltime_thresh == 1) {
					$tanf_dep_ded_recd = &least($in->{'disability_personal_expenses_m'}, 175 * $incapacitated_num); #Write in the above numbers as policy variables.
				} elsif ($out->{'earnings'} > 0) {
					$tanf_dep_ded_recd = &least($in->{'disability_personal_expenses_m'}, 150 * $incapacitated_num); 
				}
				
				$tanf_unearnedincome_m = $in->{'unearn_gross_mon_inc_amt_ag'} + $out->{'ssi_recd_m'} + $out->{'ui_recd_m'} + $out->{'interest_m'} + $out->{'gift_income_m'};
				#From the codebooks, it seems that the first $30 of gift income per quarter is excluded. So this means $120 total over the year could be excluded. But upon clarification from Allegheny County, it appears this only applies to lump sum income, and we are at this poing considering only recurring gift income. For lump sum income, the following would be added: &pos_sub($out->{'gift_income_m'}, $gift_exclusion / 3).
				
				# calculate annual earned income for assistance group members
				# Do NOT count income from a dependent child if child is a student.	We assume all children under 18 are in school full-time and working, but must account the inclusion in the definition of "Adult Dependent Child" in NH (207.03) of assistance unit members who are less than age 20 and full-time students in high school or high school equivalency program. Even though we do not specifically ask users to identify whether adult students attend high school or college, we can impute this to a satisfactory degree through the identification of these inviduals as under 20, full-time students, who pay  no educational expenses (since we are assuming users' children go to public school or pay no tuition for high school):
				for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
					if ($out->{'parent'.$i.'_SSI'} == 1 || ($in->{'parent'.$i.'_age'} < 21 && ($in->{'parent'.$i.'_ft_student'} == 1 || $in->{'parent'.$i.'_pt_student'} == 1))) { #We're proxying here that a parent who is under age 21 and is a student is a child. Their income is not counted. Also parents on SSI are not included.
						${'tanf_earnedincomep'.$i} = 0;
					} else {
						${'tanf_earnedincomep'.$i} = $out->{'parent'.$i.'_earnings_m'} + $in->{'parent'.$i.'_selfemployed_netprofit'}/12;
					}
				}

				$tanf_earnedincome_m = $tanf_earnedincomep1 + $tanf_earnedincomep2 + $tanf_earnedincomep3 + $tanf_earnedincomep4;
				
				# calculate standard of need for deemers and all individuals in assistance group
				
				#assess tanf eligibility for current recipients of tanf
				
				$tanf_income_m = pos_sub($tanf_earnedincome_m, $earnedincome_dis_curr * $tanf_earnedincome_m + $tanf_dep_ded_recd) + $tanf_unearnedincome_m;  #tanf_income_m here refers to assessing eligbility, but a different variable is needed to assess amt of income to use for TANF grant calculation. child support recd is counted for eligibility for TANF, but not for computing the grant amount.
				#Cash assistance from public agencies for the same purposes as TANF cash assistance count as income.

				$tanf_family_size = $in->{'family_size'};
				$tanf_potential_family_size = $in->{'family_size'}; 
				for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
					if ($out->{'parent'.$i.'_SSI'} == 1) {	
						$tanf_potential_family_size -= 1; 
						$tanf_family_size -= 1; 
						#Adults on SSI are not counted in the budget group / assistance group. 110.4 of the Cash Assistance Manual. ALSO IF A PERSON RECEIVES MA THROUGH FORMER ELIGIBILTIY FOR SSI, THEY DO NOT COUNT.
						#We also remove all adults
					} elsif ($parents_sanctioned == 1 && ${'parent'.$i.'_hs_student'} == 0) {
						$tanf_family_size -= 1; 						
					}
				}

				$tanf_maxben = $tanf_maxben_array[$tanf_family_size]; 				
				$tanf_recd_m = int(&pos_sub($tanf_maxben, $tanf_income_m));
				#Adding in the work expense deduction, which must be logged separately from TANF benefits. SNAP and Medicaid calculatiosn 
				$noncountable_tanf_income = (1 - $parents_sanctioned) * $work_expense_deduction; #Families get $50 a month as an incentive to work as long as they are satisfying some basic conditions and not sanctioned.
				if ($tanf_recd_m > 0) {
					$tanf_recd_m += $noncountable_tanf_income;
				}

				#Now calculate the same way but assuming no sanctions:
				$tanf_potential_maxben = $tanf_maxben_array[$tanf_potential_family_size]; 				
				$tanf_potential_recd_m = int(&pos_sub($tanf_potential_maxben, $tanf_income_m));
				
				# We can then test whether an increase in hours would result in an individual coming off sanctions. No individual on sanctions would be satisyfing work requirements in the point in time when data is entered, but it is possible that with additional hours, they will be abe to satisfy work requirements and therefore gain a higher TANF cash asssisnace amount.

				# Now calcualte teh annual TANF benefit received.
				$tanf_months_remaining = pos_sub(60, $in->{'tanf_months_received'});
				$tanf_recd = $tanf_recd_m * least(12, $tanf_months_remaining); 

				$tanf_sanctioned_amt = &pos_sub($tanf_potential_recd_m, $tanf_recd_m); #This is important for some policies that require the inclusion of the amount of TANF received plus the amount that is sanctioned..
			}
		}
	}
	
	# Now calculate whether the family receives no child support because they get TANF. NH does not appear to have a pass through.
	#Calculate the maximum child support pass through. Note: this is identical to the calculation of the exclusion of child support and spousal support income in LIHEAP.
	if ($out->{'child_support_recd_m'} + $in->{'alimony_paid_m'} > 0) {
		$support_exclusion = &greatest(&least($in->{'alimony_paid_m'},$alimony_exclusion), &least($out->{'child_support_recd_m'}, $child_support_exlusion_perchild * $in->{'child_number'}, $child_support_exclusion_max));
		$child_support_passthrough =  pos_sub($out->{'child_support_recd_m'} + $in->{'alimony_paid_m'}, $support_exclusion);
	}

	if ($tanf_recd_m > 0 && $tanf_months_remaining >= 12) { #For families not receiving child support, this output variable wil be 0. For others, it compares child support payments against potential TANF benefits.
		$child_support_recd = 12*(&least($out->{'child_support_paid_m'},$child_support_passthrough));			#state takes child support from families receiving FANF but passes through some of it. NH has this policy, PA does not.  Potential policy change.
	} elsif ($tanf_recd_m > 0 && $out->{'child_support_paid_m'} > 0) {
		$child_support_recd = $tanf_months_remaining * (&least($out->{'child_support_paid_m'},$child_support_passthrough)) + (12 - $tanf_months_remaining) * $out->{'child_support_paid_m'}; #The family starts receiving child support once they run out of TANF months.
	} else { #Either the family does not get TANF or child support is always greater than potential TANF cas assistance.
		$child_support_recd = $out->{'child_support_paid'};	 
		$tanf_recd = 0;
	}			
	$child_support_recd_m = $child_support_recd / 12; #For families that receive some TANF and some child support, this is the average child support received. For programs that are calculated monthly, this may cause calculations to be off by a little, but likely not a lot.

	#A note about TANF transportation subsidies:
	#PA, as I believe other states, allows for transportation reimbursement for job-seeking activities, training, and some job retention activities. Conceivably, the trasnportation module could be moved to after the tanf module (or possibly re-run after TANF) to reduce transportation costs by these reimbursements. (In PA, the program that does this is called SPAL, for "sepcial allowances.") However, we are not doing this for Pennsylvania, because we are removing all work requirements from it (at least for Allegheny County), and the state's TANF program provides transportation reimbursement only up to the date that a first paycheck is received. Thus the program does not cover recurring transportatin costs to and from work, and while it would cover transportation to and from training, we are removing the questions about training and work requirements from the Allegheny County MTRC. But transportation reimbursements should still be considered for other states, and potentially for adaptation into any other tools or if Pennsylvania administrators of this tool eventually decide to put transportation subsidies into the code. (E.g. while Allegheny County may have a waiver for work requirements, other places that attempt to integrate this tool might not.)
	# Transportation allowances in TANF are described in Section 135.6 of the PA Cash Assistance Handbook. (http://services.dpw.state.pa.us/oimpolicymanuals/cash/135_Employment_and_Training_Requirements/135_6_Special_Allowances_for_Supportive_Services.htm as of 6/14/21).

	#debugging:
	foreach my $debug (qw(tanf_recd tanf_unearnedincome_m tanf_income_m parent1_sanctioned parent2_sanctioned parent3_sanctioned parent4_sanctioned)) {
		print $debug.": ".${$debug}."\n";
	}
	
	# outputs
    foreach my $name (qw(tanf_recd tanf_income_m  tanf_recd_m child_support_recd child_support_recd_m tanf_sanctioned_amt tanf_cc_ded_recd noncountable_tanf_income)) { 
       $out->{$name} = ${$name};
    }
	
}

1;