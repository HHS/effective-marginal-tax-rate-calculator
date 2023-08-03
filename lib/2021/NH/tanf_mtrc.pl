#=============================================================================#
#  TANF – 2021 NH
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
   
	# HARD CODED VARIABLES USED            
	our $earnings_thresh_ded = 377;			#threshold for determining whether an individual is a full time earnings (earnings >= $377/mo) or part time worker. There are different max dependent care deductions allowed depending on full-time/part-time work status or monthly earnings	
	our $tanf_perchild_cc_ded_pt = 87.50;	# Maximum monthly deduction per child per month for a part-time employee
	our $tanf_under2_add_cc_pt = 12.50;		# Additional monthly deduction per child under 2 per month for part-time employees 
    our $tanf_perchild_cc_ded = 175;    	#Maximum monthly deduction per child age 2 and over and each incapacitated parent per month for a full-time employee.
    our $tanf_under2_add_cc = 25;       	#Additional monthly deduction per child under 2 per month for full time employees 	
    our $earnedincome_dis_curr = 0.50; 		#The earned income disregard on gross earned income is 0.50 for those who have received FANF in last 6 months. Last checked 5/13/21.
	our @tanf_maxben_array = (0,644,871,1098,1325,1552,1779,2006,2233,2460,2687,2914,3141); #NH maximum payment standard, but may need to move this down in the code. according to FANF assistance group size. up to 12 people. Each additional person is $221. payment standard set at 60% of FPG. Rate effective 3/21. Last checked 5/13/21.

	#OTHER VARIABLES USED
	our $parent1_sanctioned = 0;		 
	our $parent2_sanctioned = 0;		 
	our $parent3_sanctioned = 0;		 
	our $parent4_sanctioned = 0;		 
	our $ssi_recd_tanf_m = 0;			#the monthly amount of SSI benefits counted for tanf. Equals the total amount of SSI received by the assistance group minus the SSI benefits received by a dependent child.
	our $children_under2 = 0;			# there are different maximum allowable deduction limits for children under age 2 and those over age 2
	our $children_under6 = 0;			# number of children under6
	our $children_under13 = 0;			# number of children under 13
	our $incapacitated_num = 0;			#number of incapacitated adults that are being cared for by eligible individualsour 
	our $parent1_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent2_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent3_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent4_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	# our $children_ssi_num = 0;			# number of children receiving SSI in the family
	our $tanf_dep_ded_recd = 0;			# estimated amount of adult dependent care deduction
	our $tanf_cc_ded_recd = 0;          # tanf child care deduction
	our $tanf_earnedincomep1 = 0;	
	our $tanf_earnedincomep2 = 0;
	our $tanf_earnedincomep3 = 0;
	our $tanf_earnedincomep4 = 0;
	our $tanf_earnedincome_m = 0;			#annual amt of counted earned income
	our $tanf_unearnedincome_m = 0;		#monthly unearned income counted for eligibility
	our $allowable_ded = 0;				# allowable deductions, assuming that there are inputs available from NH data to calculate this
	our $AG_netincome = 0;				#net income to assess eligibility and grant amount (earned and unearned income - disregard - allowable deductions).
	our $tanf_income_m = 0;               # adjusted (monthly) income for tanf benefits
	our $tanf_maxben = 0;				#TANF max benefit according to assistance group size
	# our $tanf_excluded_income = 0; 		# parental income excluded from TANF calculations when parent is on SSI. 
	our $tanf_workhours_min = 0; #minimum number of hours engaged in work or eligibilty activity to satisfy TANF work requirements
	our $tanf_sanctioned_amt = 0; #This will always be 0, for reasons explained below. But we need it as an output for the SNAP code, so we need to define it.
	our $sanction_amt = 0; #Asking a question about this. See below.
	our $tanf_months_remaining = 0;
	our $parent1_hs_student = 0; #Whether the adult is a full-time high school student and therefore has his earnings excluded from income.
	our $parent2_hs_student = 0;
	our $parent3_hs_student = 0;
	our $parent4_hs_student = 0;
	our $noncountable_tanf_income = 0;	#This is the amount of TANF income that is excluded from SNAP and Mediciad (and other programs) if states make any such exclusions

	if ($in->{'tanf'} == 1){	 	 # These are flags indicating current TANF cash recipients. Since we are only looking at current TANF recipients, we will assign tanf_recd = 0 to all receipients not receiving one of these benefits. 

		# Check eligibility for ABAWDs.

		if ($in->{'child_number'} > 0) {			#families without children are NOT eligible for TANF. We assume that children ages 16-17 are full time students and thereby eligible. 	

			# Note on asset test: there is no need for asset tes --  we are only calculating TANF benefits for people who already are receiving TANF, meaning they have passed the asset test, and the MTRC assumes that households are not building their assets between current and future scenarios.
		 
			for(my $i = 1; $i <= 5; $i++) {
				# calculate the number of children under 2 in the assistance group
				if($in->{"child" . $i . "_age"} != -1 && $in->{"child" . $i . "_age"} < 2) {
					$children_under2++;				# diff deductions if child is under 2 yrs of age
				}
				#calculate the number of children under 13 in the assistance group to calculate max child care deductions allowed
				if($in->{"child" . $i . "_age"} != -1 && $in->{"child" . $i . "_age"} < 13) {
					$children_under13++;				
				}
				#calculate the number of children under 6 in the assistance group
				if($in->{"child" . $i . "_age"} != -1 && $in->{"child" . $i . "_age"} < 6) {
					$children_under6++;				
				}
				# calculate the number of children receiving ssi, eligibility for fap program. Commenting this out until we get children in the SSI code.
				#if($out->{'child' . $i . '_ssi'} = 1) {
				#	$children_ssi_num++;
				#}
			}
			
			#	calculate the number of incapacitated adults in the AG - they are counted towards the FANF cash grant. We may be able to use the variable ag_size_cnt to figure out number of people included in assistance group. incapacity of parents is established if they receive ANB, APTD, OAA, and SSI (must be receiving SSI based on disability, not age).
			for(my $i = 1; $i <= 4; $i++) {
				if($in->{'parent'.$i.'_age'} > -1) {
					if ($out->{"parent" . $i . "_SSI"} == 1) {	#flags for whether either parent receives SSI, OAA, APTD, or ANB, which would mean they are considered incapacitated)
						$incapacitated_num++;
						${'parent'.$i.'_incapacitated_tanf'} = 1;
					}
				}
			}
			# calculate the number of children receiving ssi, eligibility for fap program and calculate the maximum allowable child/dependent care deduction - must include expenses related to the care of an incapacitated parent too, if available
			# WE incorporate an individual deduction on earnings, with different rates used based on the earnings of the TANF recipient who would otherwise be providing child care if they were not working. Since it seems that we could assign any adult in the family this caregiving role, it seems reasonable to simply check these thresholds against any of the earners. We can start by assigning the lower values to the family and then checking for eligibiltiy for the higher value deductions.
			$tanf_dep_ded_recd = &least($in->{'disability_personal_expenses_m'},$tanf_perchild_cc_ded_pt * $incapacitated_num);	
			$tanf_cc_ded_recd = &least($out->{'child_care_expenses_m'},$tanf_perchild_cc_ded_pt * $children_under13 + $children_under2 * $tanf_under2_add_cc_pt); 
			for(my $i = 1; $i <= 4; $i++) {
				if($in->{'parent'.$i.'_age'} > -1) {
					if ($out->{'parent'.$i.'_earnings_m'} >= $earnings_thresh_ded){
						$tanf_dep_ded_recd = &least($in->{'disability_personal_expenses_m'},$tanf_perchild_cc_ded * $incapacitated_num); 	#this is assuming we have the amount for dependent_care expenses for incapacitated adults being cared for by people in the assistance group. We can assume that a disabled member of the household is incapacitated for these purposes. 
						$tanf_cc_ded_recd = &least($out->{'child_care_expenses_m'},$tanf_perchild_cc_ded * $children_under13 + $children_under2 * $tanf_under2_add_cc); 
					}
				}
			}
			
			# Calculate earned and unearned income for the entire assistance group.
			# calculate the amount of ssi benefits counted as unearned income. SSI benefits received by the dependent children are NOT counted as unearned income. 
			$ssi_recd_tanf_m = $out->{'ssi_recd_m'}; # - $out->{'ssi_recd_depchild_m'};	# Commenting out SSI received by children; right now, the MTRC does not model benefits for  children with disabilities.
		
			# calculate unearned income of all assistance group members. 

			$tanf_unearnedincome_m = $in->{'unearn_gross_mon_inc_amt_ag'} + $ssi_recd_tanf_m + $out->{'ui_recd_m'}; 			
			
			# calculate annual earned income for assistance group members

			# Do NOT count income from a dependent child if child is a student.	We assume all children under 18 are in school full-time and working, but must account the inclusion in the definition of "Adult Dependent Child" in NH (207.03) of assistance unit members who are less than age 20 and full-time students in high school or high school equivalency program. Even though we do not specifically ask users to identify whether adult students attend high school or college, we can impute this to a satisfactory degree through the identification of these inviduals as under 20, full-time students, who pay  no educational expenses (since we are assuming users' children go to public school or pay no tuition for high school):
			for(my $i = 1; $i <= $in->{'family_structure'}; $i++) {
				if ($in->{'parent'.$i.'_age'} < 20 && $in->{'parent'.$i.'_ft_student'} == 1 && $in->{'parent'.$i.'_educational_expenses'} == 0) {
					${'parent'.$i.'_hs_student'} = 1;
				} else {
					${'tanf_earnedincomep'.$i} = $out->{'parent'.$i.'_earnings_m'} + $in->{'parent'.$i.'_selfemployed_netprofit'}/12;
				}
			}

			$tanf_earnedincome_m = $tanf_earnedincomep1 + $tanf_earnedincomep2 + $tanf_earnedincomep3 + $tanf_earnedincomep4;
			
			# calculate standard of need for deemers and all individuals in assistance group
			
			#assess tanf eligibility for current recipients of tanf
			
			$tanf_income_m = pos_sub($tanf_earnedincome_m + $tanf_unearnedincome_m, $earnedincome_dis_curr * $tanf_earnedincome_m + $tanf_cc_ded_recd + $tanf_dep_ded_recd) ;  #tanf_income_m here refers to assessing eligbility, but a different variable is needed to assess amt of income to use for TANF grant calculation. child support recd is counted for eligibility for TANF, but not for computing the grant amount
						
			$tanf_maxben = $tanf_maxben_array[$in->{'family_size'}]; 
			
			$AG_netincome = &pos_sub($tanf_income_m, $allowable_ded);	
			
			$tanf_recd_m = int(&pos_sub($tanf_maxben, $AG_netincome));
			
			# We can then test whether an increase in hours would result in an individual coming off sanctions. No individual on sanctions would be satisyfing work requirements in the point in time when data is entered, but it is possible that with additional hours, they will be abe to satisfy work requirements and therefore gain a higher TANF cash asssisnace amount.
			
			if ($in->{'tanfwork'} == 1) { #NH has asked that the tool include sanctions that are based on work requirements for the MTRC tool. (Please note, however, that in a separate analyis, specific to analyzing New HEIGHTS data, there were only 5 families on TANF that are listed in New HEIGHTS as having sanctioned amounts in a 2020 cross section.)
			
				#Note: NCCP's FRS approaches TANF work requirements differently, by assuming that individuals on TANF who do not have wage work satisfying TANF work requirements will enroll in qualifying training opportunities to satisfy these work requirements. In the MTRC, however, we are asking specifically whether individuals are engaged in activities that satisfy work requirements, as the MTRC as a tool makes far fewer assumptions than the FRS does regarding work schedules.
				
				for(my $i = 1; $i <= $in->{'family_structure'}; $i++) { #Let's do up to 4 parents possibly on sanctions.
					# It appears that NH does not have separate two-parent work requirement standards, in contrast to other states that follow federal minimums. NH does, however, include a fairly broad array of activities that could be undertaken to satisfy job requirements, including job search activitities. "Job search" or other similarly vague-sounding activities cannot, however, lead toward satisfaction of work requirements without being part of a TANF recipient's Employability Plan (EP), which is determined at intake and presumably regularly reviewed throughout participation. We can therefore assume that people who are on sanctions are not satisfying their EP. Given this framework, it seems possible that someone may not be satisfying their work requirements not because of lower than required hours, but that they are not engaged in the activities detailed in their EP, even if they are working enough hours to satisfy work requirements. It seems plausible, however, that if an individual is both sanctioned and working below the work rquirement working hours, that gaining enough employment hours to satisfy the work requirements would allow an individual to at least temporarily be removed from sanctions.
					#See FAM 808.27 and FAM 808.37 for work requirement rules.
					
					if ($in->{'children_under13'} == 0) {
						$tanf_workhours_min = 30;
					} else {
						$tanf_workhours_min = 20;
					}
					print "parent.$i.transhours: $out->{'parent'.$i.'_transhours_w'} \n";
					if ($out->{'parent'.$i.'_transhours_w'} < $tanf_workhours_min && $in->{'disability_parent'.$i} == 0) { 
						${'parent'.$i.'_sanctioned'} = 1;
					} else {
						${'parent'.$i.'_sanctioned'} = 0; # $in->{'parent'.$i.'_sanctioned_initial'};
					}
					#Note: we only check work requirements against parents who are initially sanctioned. If the parent does not satisfy the minimum TANF work requirements, but receives TANF, they are likely exempt from work requirements and we do can keep the initial assignement of parent#_sanctioned = 0, allowing the family to keep a higher TANF benefit than if no one in the family was santioned. 
				}
							
				if ($parent1_sanctioned + $parent2_sanctioned + $parent3_sanctioned + $parent4_sanctioned > 0) {
					# At this point, we will know whether any of the parents in the household have been on sanctions, and if they have, whether they still qualify for sanctions. Below is the formulas needed to reduce TANF benefits when one or more parent is on sanctions, which become progressively more punitive the longer a parent does not satisfy work requirements. Conceivably, we could use parent variables sanctionlevel_parent# to determine the reductions in TANF benefits as a result. It would be possible to impute some approximation of those based on how much cash asssistance we calculate a family should be eligible for based on what they receive and how many parents are on sanctions. However, this imputation would not support a yearly impact of sanctions, as "after 4 weeks of continued noncompliance without good cause at LEVEL 3, [the policy is to ] terminate financial assistance for all members of the assistance group." This means that after 10 weeks of not satisfying work requirements, the family will get kicked off of FANF and NHEP. Because being sanctioned for any length longer than 4 weeks is therefore not a permanent financial picture (we cannot "model" that existence over the course of a year), we can, for the purposes of this model, simply assume that this family will not be getting these benefits as long as anyone in the assistance group will not receive TANF benefits. 
					
					#Commented-out code that incorporates sanctions. Keeping this in here in case it comes in handy later.
					#for(my $i = 1; $i <= 4; $i++) { 
					#if ${'sanction_level_parent'.$i} = 1 {
					#	$tanf_recd_m = int($tanf_recd_m - ($tanf_recd_m/$in->{'ag_size_cnt'})); #reduce payment standard by monetary value of the needs of non-compliant individual	
					#}
					#if ${'sanction_level_parent'.$i} = 2 {
					#	$tanf_recd_m = int($tanf_recd_m - (4/3) * ($tanf_recd_m/$in->{'ag_size_cnt'})); 
					#} 
					#if ${'sanction_level_parent'.$i} = 3 { 
					#	$tanf_recd_m = int($tanf_recd_m - (5/3) * ($tanf_recd_m/$in->{'ag_size_cnt'})); 
					#	
					#}
					$tanf_recd_m = 0;
					$tanf_sanctioned_amt = 0;  #Since we are looking at TANF eligibilty over the course of a year and families including individuals who are  noncompliant with TANF for 10 weeks are kicked off TANF, they will simply not be getting any TANF and the additional cash assistance they would have made on top of tanf_recd will be irrelevant. Keeping this in here because we may want to reconsider the time horizon of this approach elsewhere.
				}
			}
			# Now calcualte teh annual TANF benefit received.
			$tanf_months_remaining = pos_sub(60, $in->{'tanf_months_received'});
			$tanf_recd = $tanf_recd_m * least(12, $tanf_months_remaining); 
			$tanf_sanctioned_amt = 0; #As above, we are not modeling a separate, long-term sanction amount over the course of a year. The maximum length of time that a family in NH can be on TANF and be on sanctions appears to be 10 weeks, so the value of modeling the addition of some TANF for some family members during that time, while also using the sanctioned amount to reduce SNAP benefits accordingly (since SNAP income includes the amount of TANF cash assistance that has been sanctioned), does not seem to add substantially to the MTRC tool. It seems better to present that if a family is currently receiving TANF but is either not satisfying work requirements now or not planning on satisfying work requirements in the future, that we do not reflect the TANF cash assistance, reduced by TANF, that they could receive if not meeting work requirements. In terms of sustainabiltiy of family finances, it also seems prudent to indicate that they cannot rely on TANF as a source of cash assistance if they are not exempt from work requirements.
		}
	}
			
	# Now calculate whether the family receives no child support because they get TANF. NH does not appear to have a pass through.
	
	#The below code because while it is reflective of NH policy with regards to TANF programs that claim child support for the state. NHEP or FAP do, FWOC and IDP don't, acccording to https://www.dhhs.nh.gov/dfa/tanf/eligibility.htm. We are only concerned with adjustments based on IDP below, as FWOC is only for households with children over 18, and those children do not receive child support. IDP eligibiltiy is described here: https://www.dhhs.nh.gov/fam_htm/html/203_09_interim_disabled_parent_idp_fam.htm#:~:text=Interim%20Disabled%20Parent%20(IDP)%20financial,Families%20(FANF)%20financial%20assistance. For the purposes of this code, it covers families of more than one adult in which at least one but not all adults receive SSI.
	
	if ($out->{'ssi_recd'} > 0 && $out->{'parent1_SSI'} + $out->{'parent2_SSI'} + $out->{'parent3_SSI'} + $out->{'parent4_SSI'} < $in->{'family_structure'}) {
		#In this case, the family receies SSI but not for all adult family members: there are fewer adults in the household on SSI than the total number of adults in the household, meaning that the family is likely eligible for IDP instead of the other NH TANF options.
		$child_support_recd = $out->{'child_support_paid'};	 		
	} elsif ($tanf_recd_m > $out->{'child_support_paid_m'} && $tanf_months_remaining >= 12) { #For families not receiving child support, this output variable wil be 0. For others, it compares child support payments against potential TANF benefits.
		$child_support_recd = 0;			#state takes child support from families receiving FANF. NH does not appear to have a pass through. some states also automatically compare child support paid to tanf recd, and if the child support paid is larger, then they would end tanf so the family receives child support.  Potential policy change.
	} elsif ($tanf_recd_m > $out->{'child_support_paid_m'} && $out->{'child_support_paid_m'} > 0) {
		$child_support_recd = (12 - $tanf_months_remaining) * $out->{'child_support_paid_m'}; #The family starts receiving child support once they run out of TANF months.
	} else { #Either the family does not get TANF or child support is always greater than potential TANF cas assistance.
		#When child support payments exceed tanf benefits in NH, the client receives the child support but not the TANF. This appears to be an unwritten rule but was confirmed via email.
		$child_support_recd = $out->{'child_support_paid'};	 
		$tanf_recd = 0;
	}			
	$child_support_recd_m = $child_support_recd / 12; #For families that receive some TANF and some child support, this is the average child support received. For programs that are calculated monthly, this may cause calculations to be off by a little, but likely not a lot.

	#debugging:
	foreach my $debug (qw(tanf_recd tanf_unearnedincome_m tanf_income_m parent1_sanctioned parent2_sanctioned parent3_sanctioned parent4_sanctioned)) {
		print $debug.": ".${$debug}."\n";
	}
	
	# outputs
    foreach my $name (qw(tanf_recd tanf_income_m  AG_netincome tanf_recd_m child_support_recd child_support_recd_m tanf_sanctioned_amt tanf_cc_ded_recd noncountable_tanf_income)) { 
       $out->{$name} = ${$name};
    }
	
}

1;