#=============================================================================#
#  TANF – 2021 ME
#=============================================================================#
#	
# INPUTS OR OUTPUTS NEEDED FOR CODE:
#
# 	USER-ENTERED INPUTS
#	child#_age							#age of each child in family/assistance group
#	parent#_age							#age of each parent
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
# see Maine TANF manual: https://www.maine.gov/sos/cec/rules/10/ch331.htm (chapters are also saved in Dropbox)
#=============================================================================#
#NOTE: It appears this code already incorporates the LIFT bill, passed in 2019 which remove the gross income test from TANF. https://www.maine.gov/governor/mills/news/governor-mills-signs-law-bipartisan-bills-combat-poverty-maine-2019-06-27

sub tanf
{

    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# OTHER VARIABLES USED            
    #our $tanf_asset_limit = 2000;  	     	#ME asset limit is $2000, but don't need asset limit as we are only including current TANF recipients 
	our @tanf_maxben_array = (0,294,463,620,781,936,1094,1254,1413); #ME maximum payment grant according to TANF assistance group size. up to 8 people. Each additional person is $157. payment standard set at 60% of FPG. Rate effective 12/30/19	- updated for ME by SS 4/15/21 and again on 9/2/21 144c331 - Maine TANF handbook. rates for FFY 2021 - Oct 20-Sept 21. 
	our @tanf_son_array = (0,358,563,755,950,1141,1334,1528,1722); #ME uses the standard of need (SON) to determine eligibility for ongoing TANF recipients. For each additional member, add $192 to standard of need. updated for ME by SS 4/15/21 and again on 9/2/21 144c331 - Maine TANF handbook. rates for FFY 2021 - Oct 20-Sept 21. 
	our @tanf_son_array_childonly = (0,212,404,598,790,985,1177,1370,1562); #ME uses the standard of need (SON) to determine eligibility for ongoing TANF recipients. For each additional member, add $192 to standard of need. updated for ME by SS 4/15/21 and again on 9/2/21 144c331 - Maine TANF handbook. rates for FFY 2021 - Oct 20-Sept 21.  This is to be used when the adult is not included in the filing unit. (see guidance 144331ap) #SS 9/7 - have not programmed in code for child_only households - should this be an input?
	our @tanf_maxben_array_childonly = (0,176,334,493,649,966,1125,1282); #ME maximum payment grant according to TANF assistance group size. up to 8 people. Each additional person is $157. payment standard set at 60% of FPG. Rate effective 12/30/19	- updated for ME by SS 4/15/21 and again on 9/2/21 144c331 - Maine TANF handbook. rates for FFY 2021 - Oct 20-Sept 21. This is to be used when the adult is not included in the filing unit. (see guidance 144331ap and 144c331)
	#For Special Need Housing Households, add $300 to each figure. - see Maine TANF handbook, 144c331, found SS 9/2
	# our $tanf_excluded_income = 0; 		# parental income excluded from TANF calculations when parent is on SSI. COME BACK TO THIS															 
	our $child_support_passthrough = 50;	# amt of child support passed thru to assistance unit. ME 2021.
	our $tanf_perchild_cc_ded = 175;    	#Maximum monthly deduction per child age 2 and over and each incapacitated parent per month for a full-time employee.  
    our $tanf_under2_add_cc = 25;       	#Additional monthly deduction per child under 2 per month for full time employees
	our $tanf_perchild_cc_ded_pt = 87.50;	# Maximum monthly deduction per child per month for a part-time employee
	our $tanf_perchild_cc_ded_pt  = 12.50;		#Additional monthly deduction per child under 2 per month for part-time employees 
	our $earnedincome_dis_standard = 108;	 # new variable for ME 2021. ME includes a standard disregard of for the $108/month of earning of each employed individual in the assistance unit.
	our $earnedincome_dis_curr = 0.50; 		#ME - The earned income disregard on earnings is 0.50 of earnings after standard deduction for current TANF recipients. 
	#our $earnings_thresh_ded = 377;			#threshold for determining whether an individual is a full time earnings (earnings >= $377/mo) or part time worker. There are different max dependent care deductions allowed depending on full-time/part-time work status or monthly earnings. Not relevant for ME 2021. 
	our $snha_max = 300;				#maximum special needs housing allowance payment. "TANF assistance groups that incur housing costs that equal or exceed 50% of their countable income may be eligible for a SNHA payment of up to $300 per month."

	# OUTPUTS CREATED
    our $tanf_recd  = 0;   		 #annual amount of tanf cash assistance received
    our $tanf_recd_m    = 0;   	 #monthly amount of tanf cash assistance received
    our $child_support_recd = 0;    
	our $child_support_recd_m   = 0;
	our $snha = 0;				#maximum special needs housing allowance payment. "TANF assistance groups that incur housing costs that equal or exceed 50% of their countable income may be eligible for a SNHA payment of up to $300 per month."
   
    #OTHER INTERMEDIARY VARIABLES
	our $parent1_sanctioned = 0;		#indicating whether parent 1 is sanctioned 
	our $parent2_sanctioned = 0;		#indicating whether parent 2 is sanctioned 
	our $parent3_sanctioned = 0;		#indicating whether parent 3 is sanctioned 
	our $parent4_sanctioned = 0;		#indicating whether parent 4 is sanctioned 
	our $ssi_recd_tanf_m = 0;			#the monthly amount of SSI benefits counted for tanf. Equals the total amount of SSI received by the assistance group minus the SSI benefits received by a dependent child. In Maine, any person who receives SSI is ineligible for TANF and needs to be removed from the assistance unit.
	our $children_under2 = 0;			# there are different maximum allowable child care deduction limits for children under age 2 and those over age 2
	our $children_under6 = 0;			# number of children under 6. This is needed because there are different work requirements for parents of children under 6.
	our $children_under13 = 0;			# number of children under 13 to calculate child care deductions.
	our $incapacitated_num = 0;			#number of incapacitated adults that are being cared for by eligible individualsour 
	our $parent1_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent2_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent3_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	our $parent4_incapacitated_tanf = 0;		#flag for whether parent is incapacitated, based on TANF rules
	# our $children_ssi_num = 0;			# number of children receiving SSI in the family
	our $tanf_dep_ded_recd = 0;			# estimated amount of adult dependent care deduction
	our $tanf_cc_ded_recd = 0;          # tanf child care deduction
	our $tanf_earnedincomep1_step1 = 0;	
	our $tanf_earnedincomep1_step1 = 0;	
	our $tanf_earnedincomep1_step1 = 0;	
	our $tanf_earnedincomep1_step1 = 0;	
	our $tanf_earnedincomep1_step2 = 0;
	our $tanf_earnedincomep2_step2 = 0;
	our $tanf_earnedincomep3_step2 = 0;
	our $tanf_earnedincomep4_step2 = 0;
	our $tanf_earnedincome_step2 = 0;	# total amt of hh earned income for step 2
	our $tanf_earnedincomep1 = 0;	
	our $tanf_earnedincomep2 = 0;
	our $tanf_earnedincomep3 = 0;
	our $tanf_earnedincomep4 = 0;
	our $tanf_earnedincome_m = 0;			#annual amt of counted earned income
	our $tanf_unearnedincome_m = 0;		#monthly unearned income counted for eligibility
	our $tanf_income_m_step1 = 0; #added for ME 2021
	our $tanf_earnedincome_step1 = 0; #added for ME 2021
	our $tanf_income_m_step2 = 0; #added for ME 2021
	our	$tanf_earnedincome_step2 = 0; #added for ME 2021
	our $tanf_recd_step1 = 0;	#added for ME 2021
	our $tanf_recd_step2 = 0;	#added for ME 2021
	# our $allowable_ded = 0;				# allowable deductions - not needed for ME 2021
	# our $AG_netincome = 0;				#net income to assess eligibility and grant amount (earned and unearned income - disregards - allowable deductions).- not needed for ME 2021
	our $tanf_earnedincome_initial_m = 0;	
	our $tanf_income_m = 0;               # adjusted (monthly) income for tanf benefits
	our $tanf_maxben = 0;				#TANF max benefit according to assistance group size 
	our $tanf_son = 0;				#TANF standard of need, used to determine max benefit for current TANF recipients, varies by family size.
	
	our $tanf_workhours_min = 0; #minimum number of hours engaged in work or eligibilty activity to satisfy TANF work requirements
	our $tanf_sanctioned_amt = 0; #This will always be 0, for reasons explained below. But we need it as an output for the SNAP code, so we need to define it.
	our $sanction_amt = 0; #Asking a question about this. See below.
	our $tanf_months_remaining = 0;
	our $snha_m = 0;
	our $snha_step1 = 0;
	our $tanf_recd_step1_m  = 0;
	our $snha_step2 = 0;
	our $tanf_recd_step2_m  = 0;
	our $basic_grant_amt = 0;
	our $basic_grant_amt_m = 0;
	
	our $noncountable_tanf_income = 0;	#This is the amount of TANF income that is excluded from SNAP and Mediciad (and other programs) if states make any such exclusions
	our $tanf_family_size = 0;
	
	if ($in->{'tanf'} == 1) {	 	 # These are flags indicating current TANF cash recipients. Since we are only looking at current TANF recipients, we will assign tanf_recd = 0 to all receipients not receiving one of these benefits. We are assuming for Maine that these are participants in only the ASPIRE-TANF and Parents as Scholars (PaS) programs in TANF.
	
		# Check eligibility for ABAWDs.

		if ($in->{'child_number'} > 0) {			#families without children are NOT eligible for TANF. We assume that children ages 16-17 are full time students and thereby eligible. 	

			# Note on asset test: While there is an asset test in the TANF program, there is no need for asset test	for now  because we are only calculating TANF benefits for current recipients, meaning they have passed the asset test. 
		 
			for(my $i = 1; $i <= $in->{'child_number'}; $i++) {
				# calculate the number of children under 2 in the assistance group
				if($in->{"child" . $i . "_age"} < 2) {
					$children_under2++;				# diff deductions if child is under 2 yrs of age
				}
				#calculate the number of children under 13 in the assistance group to calculate max child care deductions allowed
				if($in->{"child" . $i . "_age"} < 13) {
					$children_under13++;				
				}
				#calculate the number of children under 6 in the assistance group
				if($in->{"child" . $i . "_age"} < 6) {
					$children_under6++;				
				}
				# calculate the number of children receiving ssi, eligibility for fap program. Commenting this out until we get children in the SSI code.
				#if($out->{'child' . $i . '_ssi'} = 1) {
				#	$children_ssi_num++;
				#}
			}
			
			#	calculate the number of incapacitated adults in the AG - they are counted towards the TANF cash grant. incapacity of parents is established if they receive SSI (must be receiving SSI based on disability, not age).
			for(my $i = 1; $i <= 4; $i++) {
				if($in->{'parent'.$i.'_age'} > -1) {
					if ($out->{"parent" . $i . "_SSI"} == 1) {	#flags for whether either parent receives SSI, which would mean they are considered incapacitated and also exempt from work requirements in ME TANF program)
						$incapacitated_num++;
						${'parent'.$i.'_incapacitated_tanf'} = 1;
						
					}
				}
			}
			$tanf_family_size =  &pos_sub($in->{'family_size'}, $incapacitated_num); #Haven't yet incorporated others who might be excluded from the tanf family assistance unit for other reasons. e.g., need to check if adult students are excluded. In page 58 of Maine's TANF policy manual:  "A TANF/PaS eligible individual who is also eligible for SSI or State Supplement benefits may choose to receive one or the other but may not receive both TANF/PaS and SSI/State Supplement. If the child chooses to receive SSI/State Supplement the otherwise eligible specified relative may receive TANF/PaS.
			
			# We then incorporate individual deductions on earnings, with different rates used based on the earnings of the TANF recipient who would otherwise be providing child care if they were not working. Since it seems that we could assign any adult in the family this caregiving role, it seems reasonable to simply check these thresholds against any of the earners. We can start by assigning the lower values to the family and then checking for eligibiltiy for the higher value deductions.
			for(my $i = 1; $i <= 4; $i++) {
				if($in->{'parent'.$i.'_age'} > -1) {
					if ($out->{'parent'.$i.'_earnings_m'} >= 0){ #each individual in the assistance unit who is employed is eligible for disregards. 
						$tanf_dep_ded_recd = &least($in->{'disability_personal_expenses_m'},$tanf_perchild_cc_ded * $incapacitated_num); 	#this is assuming we have the amount for dependent_care expenses for incapacitated adults being cared for by people in the assistance group. the disability_personal_expenses_m is defined in page_7.php code.  We can assume that a disabled member of the household is incapacitated for these purposes, I think. We may need to rethink this once we include children with disabilities, to separate out each individual's disability-related expenses.
						$tanf_cc_ded_recd = &least($out->{'child_care_expenses_m'},$tanf_perchild_cc_ded * $children_under13 + $children_under2 * $tanf_under2_add_cc); 
					}
				}
			}
					
			# calculate unearned income of all assistance group members. 
			$tanf_unearnedincome_m = $in->{'unearn_gross_mon_inc_amt_ag'} + $out->{'ui_recd_m'} + $out{'interest_m'};
			
			
			#calculate standard of need and max benefit for the tanf family
			
			if ($incapacitated_num < $in->{'family_structure'}) {
				$tanf_son = $tanf_son_array[$tanf_family_size]; # added for ME 2021 need to add other exclusions to tanf assistance unit for determining the SON and max benefit - right now, only excluding adult SSI recipients.
				$tanf_maxben = $tanf_maxben_array[$tanf_family_size]; #moved this up for ME 2021.
			} else {
				$tanf_son = $tanf_son_array_childonly[$tanf_family_size]; # added for ME 2021 need to add other exclusions to tanf assistance unit for determining the SON and max benefit - right now, only excluding adult SSI recipients.
				$tanf_maxben = $tanf_maxben_array_childonly[$tanf_family_size]; #moved this up for ME 2021.
			}
			# calculate the base earned income for each adult and the tanf unit, applying earned income disregard for each adult. Do NOT count income from a dependent child if child is a student. We assume all children under 18 are in school.

			$tanf_earnedincomep1 = &pos_sub($out->{'parent1_earnings_m'}+ $in->{'parent1_selfemployed_netprofit_m'},$earnedincome_dis_standard)*$earnedincome_dis_curr; 		#This is the formula used for current recipients. 
			$tanf_earnedincomep2 = &pos_sub($out->{'parent2_earnings_m'}+ $in->{'parent2_selfemployed_netprofit_m'},$earnedincome_dis_standard)*$earnedincome_dis_curr; 
			$tanf_earnedincomep3 = &pos_sub($out->{'parent3_earnings_m'}+ $in->{'parent3_selfemployed_netprofit_m'},$earnedincome_dis_standard)*$earnedincome_dis_curr;
			$tanf_earnedincomep4 = &pos_sub($out->{'parent4_earnings_m'}+ $in->{'parent4_selfemployed_netprofit_m'},$earnedincome_dis_standard)*$earnedincome_dis_curr;  
					
			$tanf_earnedincome_initial = $tanf_earnedincomep1 + $tanf_earnedincomep2 + $tanf_earnedincomep3 +$tanf_earnedincomep4; #this is a monthly amount
			
			$tanf_income_m = &pos_sub($tanf_earnedincome_initial + $tanf_unearnedincome_m,$tanf_cc_ded_recd + $tanf_dep_ded_recd);  #tanf_income_m here refers to amount used to determine benefit amount
		
			#Determine the number of months remaining for tanf recipients
			
			$tanf_months_remaining = &pos_sub(60, $in->{'tanf_months_received'}); #moved this up for ME 2021 
			
			
			#Calculate standard tanf amount received prior to checking for and incorporating step disregards. "a)	TANF assistance groups that incur housing costs that equal or exceed 50% of their countable income may be eligible for a SNHA payment of up to $300 per month. A separate application for SNHA is not required. The TANF or PaS application or redetermination is considered a request for SNHA. A person can receive an SNHA even if not receiving a TANF basic grant. Assignment of child support and ASPIRE participation is required in this circumstance. Child only assistance units may be eligible for the SNHA." 
			
			$tanf_recd_m = floor(least(&pos_sub($tanf_son,$tanf_income_m),$tanf_maxben)); #authorize the difference between the standard of need and the countable tanf income up to the payment maximum. This is rounded down. Also, note: No TANF grants of $1. In the ME policy manual, it says, "(5) If the result is less than $1 before application of any recoupment or proration, no benefit is issued." This rule seems to apply AFTER the special need housing allowance is calculated and incorporated. 

			#determine whether the unit qualifies for the Special Needs Housing Allowance.
			$snha_m = least(pos_sub($out->{'rent_paid_m'}, .5 * ($tanf_income_m + $tanf_recd_m + $out->{'child_support_paid_m'})), $snha_max); #This is the amount of costs paid by the TANF family AFTER SEC 8 IS CALCULATED. Mortgage payments are eligible under the special needs housing allowance as well. It adds a payment of up to $300 for a housing allowance. This is done by increasing the standard of need by $300, and can be isolated mathematically by this operation.
								
			$basic_grant_amt_m = $tanf_recd_m;

			# Re-calculation of tanf_benefit if step 1 or step 2 disregards are applicable, and, if not, a calculation of tanf_recd based on non-step-baed tanf monthly amounts, limited by the remaining amount of months they have against their TANF lifetime limit.
			
			if ($in->{'tanf_months_received'} < 3) { 
				#Added below new disregards formulas for ME 2021. In ME, 100% of earned income is disregarded for the recipients with a change in earned income for a maximum of 3 months. Here, we assume this applies to tanf recipients who have less than 4 months of tanf_received. 
				$tanf_earnedincome_step1 = 0;
				$tanf_income_m_step1 = $tanf_earnedincome_step1 + $tanf_unearnedincome_m;

				$tanf_recd_step1_m = least(&pos_sub($tanf_son + $snha, $tanf_income_m_step1),$tanf_maxben + $snha);
				$tanf_recd_step1 = floor((3-$in->{'tanf_months_received'})* $tanf_recd_step1_m); #authorize the difference between the standard of need and the countable tanf income up to the payment maximum
				$tanf_recd = $tanf_recd_step1 + ($tanf_recd_m * &pos_sub(12,3-$in->{'tanf_months_received'})); #total annual amt of tanf for people receiving tanf for less than 3 months. ME 2021.

				$snha_step1 = (3-$in->{'tanf_months_received'})* least(pos_sub($out->{'rent_paid_m'}, .5 * ($tanf_income_m_step1 + $tanf_recd_step1_m + $out->{'child_support_paid_m'})), $snha_max);
				$snha = $snha_step1 + ($snha_m * &pos_sub(12,3-$in->{'tanf_months_received'})); #total annual amt of tanf for people receiving tanf for less than 6 months receiving step 2 disregards. ME 2021. 				

			} elsif	($in->{'tanf_months_received'} < 6 && $in->{'tanf_months_received'} >= 3) {# ME 2021. Below, we calculate the tanf earned income including disregards for step 2. In ME, 75% of earned income is disregarded for the recipients with a change in earned income between the first 4-6th months of tanf reciept. Here, we assume this applies to tanf_recipients who have more than 3 but less than 7 months of tanf_months_received.	
				$tanf_earnedincome_step2 = .75 * ($out->{'earnings_mnth'} + $in->{'selfemployed_netprofit_total'});  
				$tanf_income_m_step2 = &pos_sub($tanf_earnedincome_step2,$tanf_cc_ded_recd + $tanf_dep_ded_recd) + $tanf_unearnedincome_m;

				$tanf_recd_step2_m = least(&pos_sub($tanf_son + $snha,$tanf_income_m_step2),$tanf_maxben + $snha);
				$tanf_recd_step2 = floor((6-$in->{'tanf_months_received'})* $tanf_recd_step2_m ); #amount of step 2 tanf received annually. authorize the difference between the standard of need and the countable tanf income up to the payment maximum.
				$tanf_recd = $tanf_recd_step2 + ($tanf_recd_m * &pos_sub(12,6-$in->{'tanf_months_received'})); #total annual amt of tanf for people receiving tanf for less than 6 months receiving step 2 disregards. ME 2021. 				

				$snha_step2 = (6-$in->{'tanf_months_received'})* least(pos_sub($out->{'rent_paid_m'}, .5 * ($tanf_income_m_step2 + $tanf_recd_step2_m + $out->{'child_support_paid_m'})), $snha_max);
				$snha = $snha_step2 + ($snha_m * &pos_sub(12,6-$in->{'tanf_months_received'})); #total annual amt of tanf for people receiving tanf for less than 6 months receiving step 2 disregards. ME 2021. 				

			} else {
				#Calculate total tanf received annually for others outside of step disregard program (those receiving tanf for 6 or more months) 
				$tanf_recd = $tanf_recd_m * least($tanf_months_remaining,12); #total annual amt of tanf for people receiving tanf for less than 6 months. ME 2021.
				$snha = $snha_m * least($tanf_months_remaining,12);
			}
			
			#Recalculating output variables for use in other codes:
			$basic_grant_amt = $tanf_recd;
			$tanf_recd = $tanf_recd + $snha;
			$tanf_recd_m = $tanf_recd / 12;
			$noncountable_tanf_income = $snha / 12;

			# We can then test whether an increase in hours would result in an individual coming off sanctions. It is possible that with additional hours, they will be abe to satisfy work requirements and therefore gain a higher TANF cash asssisnace amount.
			
			if ($in->{'tanfwork'} == 1) { #NH has asked that the tool include sanctions that are based on work requirements for the MTRC tool. But Maine has requested that TANF calculations should not include work requirements, so this input is always set to 0 in the user interface of the Maine tool (in inc/page_4.php) 
			
				#Note: NCCP's FRS approaches TANF work requirements differently, by assuming that individuals on TANF who do not have wage work satisfying TANF work requirements will enroll in qualifying training opportunities to satisfy these work requirements. In the MTRC, however, we are asking specifically whether individuals are engaged in activities that satisfy work requirements, as the MTRC as a tool makes far fewer assumptions than the FRS does regarding work schedules.
				
				for(my $i = 1; $i <= $in->{'family_structure'}; $i++) { #Let's do up to 4 parents possibly on sanctions.
					#Look at ASPIRE rules to determine work requirments for family in Maine. Each family receiving TANF is required participate in ASPIRE, and this program is where the work requirements are located.
					if ($in->{'children_under6'} == 0) { #changed for ME 2021 
						$tanf_workhours_min = 30;
					} else {
						$tanf_workhours_min = 20;
					} #need to incorporate 2 parents households for ME 2021
					# print "parent.$i.transhours: $out->{'parent'.$i.'_transhours_w'} \n"; #"print" is a debugging code. can delete or comment out anything that has "print" in it. 
					if ($out->{'parent'.$i.'_transhours_w'} < $tanf_workhours_min && $in->{'disability_parent'.$i} == 0) { #the parent#_transhours = number of hrs in work or training. It is an output from the transportation code. checking whether they are fulfilling work requirements. 
						${'parent'.$i.'_sanctioned'} = 1;
					} else {
						${'parent'.$i.'_sanctioned'} = 0; # $in->{'parent'.$i.'_sanctioned_initial'};
					}
					#Note: we only check work requirements against parents who are initially sanctioned. If the parent does not satisfy the minimum TANF work requirements, but receives TANF, they are likely exempt from work requirements and we do can keep the initial assignement of parent#_sanctioned = 0, allowing the family to keep a higher TANF benefit than if no one in the family was santioned. 
				}
							
				if ($parent1_sanctioned + $parent2_sanctioned + $parent3_sanctioned + $parent4_sanctioned > 0) {
					# At this point, we will know whether any of the parents in the household have been on sanctions, and if they have, whether they still qualify for sanctions. Below is the formulas needed to reduce TANF benefits when one or more parent is on sanctions, which become progressively more punitive the longer a parent does not satisfy work requirements. Conceivably, we could use parent variables sanctionlevel_parent# to determine the reductions in TANF benefits as a result. For now, since we are not incorporating work requirements in ME, we are setting the TANF amount to 0 in this case, but this is where sanctions could be included to lower TANF receipt.  
					
					$tanf_recd_m = 0;
					$tanf_sanctioned_amt = 0;  #Since we are looking at TANF eligibilty over the course of a year and families including individuals who are  noncompliant with TANF for 10 weeks are kicked off TANF, they will simply not be getting any TANF and the additional cash assistance they would have made on top of tanf_recd will be irrelevant. Keeping this in here because we may want to reconsider the time horizon of this approach elsewhere.
				}
			}
			# Now calculate the annual TANF benefit received.
			
			
			$tanf_sanctioned_amt = 0; #May need to change this for Maine. As above, we are not modeling a separate, long-term sanction amount over the course of a year. The maximum length of time that a family in ME can be on TANF and be on sanctions appears to be a few months, so the value of modeling the addition of some TANF for some family members during that time, while also using the sanctioned amount to reduce SNAP benefits accordingly (since SNAP income includes the amount of TANF cash assistance that has been sanctioned), does not seem to add substantially to the MTRC tool. It seems better to present that if a family is currently receiving TANF but is either not satisfying work requirements now or not planning on satisfying work requirements in the future, that we do not reflect the TANF cash assistance, reduced by TANF, that they could receive if not meeting work requirements. In terms of sustainabiltiy of family finances, it also seems prudent to indicate that they cannot rely on TANF as a source of cash assistance if they are not exempt from work requirements.
		}
	}
			
	if ($tanf_recd_m > $out->{'child_support_paid_m'} && $tanf_months_remaining >= 12) { #For families not receiving child support, this output variable wil be 0. For others, it compares child support payments against potential TANF benefits.
		$child_support_recd = 12 * &least($child_support_passthrough, $out->{'child_support_paid_m'}); #ME's pass through is $50.
	} elsif ($tanf_recd_m > $out->{'child_support_paid_m'} && $out->{'child_support_paid_m'} > 0) {
		$child_support_recd = (12 - $tanf_months_remaining) * &least($child_support_passthrough, $out->{'child_support_paid_m'}); #The family starts receiving child support once they run out of TANF months. 
	} else { #Either the family does not get TANF or child support is always greater than potential TANF cas assistance.
		#When child support payments exceed tanf benefits in NH, the client receives the child support but not the TANF. This appears to be an unwritten rule but was confirmed via email.
		$child_support_recd = $out->{'child_support_paid'};	 
		$tanf_recd = 0;
		$tanf_recd_m = 0;
	}			
	$child_support_recd_m = $child_support_recd / 12; #For families that receive some TANF and some child support, this is the average child support received per month. For programs that are calculated monthly, this may cause calculations to be off by a little, but likely not a lot.

	#debugging:
	foreach my $debug (qw(tanf_recd tanf_unearnedincome_m tanf_income_m parent1_sanctioned parent2_sanctioned parent3_sanctioned parent4_sanctioned tanf_son tanf_maxben snha basic_grant_amt basic_grant_amt_m)) {
		print $debug.": ".${$debug}."\n";
	}
	
	# outputs
    foreach my $name (qw(tanf_recd tanf_income_m  AG_netincome tanf_recd_m child_support_recd child_support_recd_m tanf_sanctioned_amt tanf_cc_ded_recd noncountable_tanf_income)) { 
       $out->{$name} = ${$name};
    }
	
}

1;
