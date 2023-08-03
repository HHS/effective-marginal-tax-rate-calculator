#=============================================================================#
#  School & Summer Meals Module – 2021 NH 
#=============================================================================#
#
# Inputs referenced in this module or outputs from other module needed for this module:
#
# INPUTS FROM USER INTERFACE
# 	child#_age
# 	nsbp 
# 	frpl 
# 	sfsp 
#
# INPUTS FROM NCCP_SIMULATOR.PHP MYSQL PULLS
#	schooldays
#	summerdays
#
# INPUTS FROM FRS.PM
# 	fpl 
#
# OUTPUTS FROM RUNFRS
# 	earnings
# 	(prek)  Removed from this code for now because NH doesn't have a Pre-K program distinct from other child care options covered in the MTRC
#
# OUTPUTS FROM INTEREST
# 	interest_m 
#
# OUTPUTS FROM SSI
# 	ssi_recd_mnth
#
# OUTPUTS FROM TANF
# 	tanf_recd_m
# 	tanf_recd
# 	child_support_recd_m
#
# FROM FSP
# 	fsp_recd
#
# FROM AFTERSCHOOL
# 	afterschool_child#
#
# FROM CHILD_CARE
# 	prek_age_min 	#Excluded for now -- see above.
# 	prek_age_max 	#Excluded for now -- see above.
#=============================================================================#
# NOTE: # Ignoring CACFP for now; it may be impossible to disentangle family savigns from CACFP from savings from CCDF, if food costs are part of the charges that child care centers charge for care. Likely not possible to attain which child care providers charge and which do not for food in the surveys that we are basing child care costs on.
#=============================================================================#

sub schoolsummermeals
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};
	#  my $dbh = $self->{'dbh'};

	# outputs created

	
	#NOTE: The input screens (on step 7) will ask whether the parent is sending their children to a school that takes up the community eligibility provision or Provision 2 of federal school meal legislation in counties where there are schools that have taken up this provision. The Commnuity Eligibility Provision (CEP)  allows schools or school districts to provide free breakfasts and lunches to all students, regardless of income or SNAP participation. Schools or districts are eligible to participate in this program if 40% or more of students are calculated as eligible for participate. Incentives for schools participating in this program include lower administrative costs (no one needs to check student income or confirm eligibility in the lunch line) and a higher federal reimbursement rate for meals (at 1.6 times the normal reimbursement rate). Schools still pay the difference between the total federal reimbursements and the costs of providing school meals, but schools also determine the costs of meals students receive. 

 	our $permealcost = 0;		#per meal cost for each child
	our $child1_bkfst_red = 0;	#reduction in child food costs due to free breakfast 
	our $child2_bkfst_red = 0;	#reduction in child food costs due to free breakfast 
	our $child3_bkfst_red = 0;	#reduction in child food costs due to free breakfast 
	our $child4_bkfst_red = 0;	#reduction in child food costs due to free breakfast 
	our $child5_bkfst_red = 0;	#reduction in child food costs due to free breakfast 
	our $child1_lunch_red = 0;	#reduction in child food costs due to free lunch 
	our $child2_lunch_red = 0;	#reduction in child food costs due to free lunch 
	our $child3_lunch_red = 0;	#reduction in child food costs due to free lunch 
	our $child4_lunch_red = 0;	#reduction in child food costs due to free lunch 
	our $child5_lunch_red = 0;	#reduction in child food costs due to free lunch 
	our $child1_supper_recd = 0;	# reduc. in child food cost due to free afterschool snack/supper 
	our $child2_supper_recd = 0;	# reduc. in child food cost due to free afterschool snack/supper 
	our $child3_supper_recd = 0;	# reduc. in child food cost due to free afterschool snack/supper 
	our $child4_supper_recd = 0;	# reduc. in child food cost due to free afterschool snack/supper 
	our $child5_supper_recd = 0;	# reduc. in child food cost due to free afterschool snack/supper 
	our $child1_sfsp_red = 0;	#reduction in child food costs due to summer meals 
	our $child2_sfsp_red = 0;	#reduction in child food costs due to summer meals 
	our $child3_sfsp_red = 0;	#reduction in child food costs due to summer meals 
	our $child4_sfsp_red = 0;	#reduction in child food costs due to summer meals 
	our $child5_sfsp_red = 0;	#reduction in child food costs due to summer meals 
	our $bkfst_paid_price = 0;
	our $bkfst_red_price = 0;
	our $cep_participation_bkfst = 0;
	our $lunch_paid_price = 0;
	our $lunch_red_price = 0;
	our $cep_participation_lunch = 0;
	our $child_foodcost_red_total = 0; #Total reduction in children’s food costs due to meal programs
	our $schoolmeals_inc_m = 0;	#countable income to assess eligibility for free lunch
	our $schoolmeals_inc = 0;	#annual countable income to assess eligibility
	our $child1_foodcost_red = 0;
	our $child2_foodcost_red = 0;
	our $child3_foodcost_red = 0;
	our $child4_foodcost_red = 0;
	our $child5_foodcost_red = 0;
	our $child1_foodcost_m = 0;
	our $child2_foodcost_m = 0;
	our $child3_foodcost_m = 0;
	our $child4_foodcost_m = 0;
	our $child5_foodcost_m = 0;	
	our $elem_cep_lunch	= 0; #whether there is an elementary school in the district that offers free school lunch to all studets.
	our $elem_cep_bkfst	= 0; #whether there is an elementary school in the district that offers free school breakfast to all studets.
	our $ms_cep_lunch = 0; #whether there is an middle school in the district that offers free school lunch to all studets.
	our $ms_cep_bkfst = 0; #whether there is an middle school in the district that offers free school breakfast to all studets.
	our $hs_cep_lunch = 0; #whether there is an high school in the district that offers free school lunch to all studets.
	our $hs_cep_bkfst = 0; #whether there is an high school in the district that offers free school breakfast to all studets.
	our $elem_lunch_paid = 0; #the price of non-reduced lunch in the county public elementary school in the county
	our $elem_lunch_red	= 0; #the price of reduced-priced lunch in the county public elementary school in the county
	our $elem_bkfst_paid = 0; #the price of non-reduced breakfast in the county public elementary school in the county
	our $elem_bkfst_red	= 0; #the price of reduced-priced breakfast in the county public elementary school in the county
	our $ms_lunch_paid = 0; #the price of non-reduced lunch in the county public middle school in the county
	our $ms_lunch_red = 0; #the price of reduced-priced lunch in the county public middle school in the county
	our $ms_bkfst_paid = 0; #the price of non-reduced breakfast in the county public middle school in the county
	our $ms_bkfst_red = 0; #the price of reduced-priced breakfast in the county public middle school in the county
	our $hs_lunch_paid = 0; #the price of non-reduced lunch in the county public high school in the county
	our $hs_lunch_red = 0; #the price of reduced-priced lunch in the county public high school in the county
	our $hs_bkfst_paid = 0;#the price of non-reduced breakfast in the county public high school in the county
	our $hs_bkfst_red = 0; #the price of reduced-priced breakfast in the county public high school in the county
	our $sfsp_program = 0;

	if ($in->{'child_number'} == 0) {
		$child_foodcost_red_total = 0;
	} else {
		if ($in->{'nsbp'}==1 || $in->{'frpl'} == 1 || $in->{'fsmp'} == 1) {
			
			#Full price meal costs:
			$elem_lunch_paid = 2.69; #This is the average full-price lunch cost for elementary school students in New Hampshire as of 2020, pre-covid. There is, at most, a $1-per-meal difference in this price. So the variation we'd be getting in terms of household costs is at most about $220 per year. The payoff for separating this out by region is not worth the time it will take to accumulate the data. An average or approximation seems more appropriate here.
			$elem_bkfst_paid = 1.49; #This is the average full-price breakfast cost for elementary school students in New Hampshire as of 2020, pre-covid. See above note for why it makes more sense to use a general figure than one broken down by geography.
			$ms_lunch_paid = 2.89; #This is the average full-price breakfast cost for middle school students in New Hampshire as of 2020, pre-covid. See above note for why it makes more sense to use a general figure than one broken down by geography.
			$ms_bkfst_paid = 1.6; #This is the average full-price breakfast cost for middle school students in New Hampshire as of 2020, pre-covid. See above note for why it makes more sense to use a general figure than one broken down by geography.
			$hs_lunch_paid = 3.04;
			$hs_bkfst_paid =1.69;

			#Reduced price meal costs:
			$elem_lunch_red = 0.4; # In general, reduced-price lunch is $0.40. Previous FRS codes estimated the prices of school lunch at the town / school district level, but there is so little variation there, it's likely not worth the trouble.
			$elem_bkfst_red = 0.3; # In general, reduced-price breakfast is $0.30. Previous FRS codes estimated the prices of school lunch at the town / school district level, but there is so little variation there, it's likely not worth the trouble. The main difference is whether schools offer reduced price breakfast or not, but users are indicating in the input pages of the MTRC whether their children are participating in this program. Conceivably, we could ask exactly which children receive these benefits (since they may go to different schools), but it seems probable that if one child attends a school with reduced price meals, the other will as well. While we have done this data dig for NH, the process was onerous enough that it does not seem appropriate to ask for these fields to be updated beyond adjusting the standard prices set at the federal level.
			$ms_lunch_red = 0.4;
			$ms_bkfst_red = 0.3;
			$hs_lunch_red = 0.4;
			$hs_bkfst_red = 0.3;

			#There were very few districts in New Hampshire as of early 2020 eligible to participate in the Community Eligibility Provision (CEP), which allows schools to offer free lunch or breakfast to anybody in their school or school district (or possibly county or state), based on the percentage of eligible students being above a certain percentage (40%). In other states, the MTRC uses CEP eligibility broken down by school district, tracked to county; in this manner and the way we track meal prices below, this approach zeroes out meal prices when all schools in a district (or county) participate in CEP. But, the most recent New Hampshire pre-COVID data indicated very little eligibility among schools and school districts (SAUs), so even if we had data on what schools and school districts participated in this program pre-COVID, there would be very little participation. Looking to situations of New Hampshire pulling out of the COVID health and economic crisis, though, there may be many more schools and counties eligible for participation, and given that this is a school/SAU choice, it may be worth considering encouraging schools to take up CEP. So we are leaving this option in here, in the code for now. We could switch $cep to 1 above in order to see the impact of this program if adopted across New Hampshire.
			
			#These variables could be adjusted by locality if there were any schools or school districts that reliably offered free school meals in New Hampshire.
			$elem_cep_lunch = 0; # This and all other below cep variables indicate whether there is a school in the jurisdiction the family lives in that participates in CEP. As discussed above, there were very few schools pre-COVID that did this.
			$elem_cep_bkfst = 0;
			$ms_cep_lunch = 0;
			$ms_cep_bkfst = 0;
			$hs_cep_lunch = 0; #There do not appear to be 
			$hs_cep_bkfst = 0;

		}
		
		# CALCULATING FAMILY INCOME FOR SCHOOL AND SUMMER MEAL ELIGIBILITY:
		$schoolmeals_inc_m = $out->{'earnings'}/12 + $out->{'child_support_recd_m'} + $out->{'ssi_recd_mnth'} + $out->{'tanf_recd_m'} +$out->{'interest_m'} + $in->{'selfemployed_netprofit_total'}/12 +  $in->{'unearn_gross_mon_inc_amt_ag'} + $out->{'ui_recd_m'}; # Note: Nowhere in the Federal Register 3/20/19 definition of "income" for determining eligibility for school meals do the rules explicitly include payments that would have been included in a TANF cash assistance grant had a family member not been under sanctions.

		$schoolmeals_inc = $schoolmeals_inc_m *12;

		#CALCULATE FOR EACH CHILD:
		# Calculate per meal costs for each child according to age, divided by the number of weeks in a month, further divided by the number of meals per week (7 days per week * 3 meals per day).

		# Use food cost table to find value for child#foodcost_m based on child age:
		for (my $i = 1; $i <= 5; $i++) {
			if ($in->{'child'.$i.'_age'} == -1) { 
				${"child".$i."_foodcost_m"} = 0;
			} else {
				${"child".$i."_foodcost_m"} = qw(133.30 133.30 139.80 139.80 143.20 143.20 202.00 202.00 202.00 216.10 216.10 216.10 232.40 232.40 234.60 234.60 234.60 234.60)[$in->{"child".$i."_age"}]; #See food_mtrc.pl code for derivation and sources for child food costs as of January 2021.
			} 

			$permealcost = (${'child'.$i.'_foodcost_m'}/4.33)/(7*3);

			#Calculate meal prices for school breakfasts and lunches.

			# SCHOOL BREAKFAST

			# Check eligibility for national school breakfast program for all children. Students attending schools or districts participating in the Community Eligibility Provision (CEP) receive both school breakfasts and school lunches for free regardless of income. In some states, only some schools participate, meaning that  need formulas for both school and breakfast meals based on how much schools charge for both the full cost of meals and the reduced-price cost of meals (both of which are determined by school). In these locations, students are eligible for free lunches if their family's incomes are below 130% FPG or if they receive SNAP or TANF. They are eligible for reduced-price meals if their incomes are below 185% FPG.


			if ($in->{'nsbp'}==1 && $in->{'child'.$i.'_age'} >= 5) { #Removed from codes, since NH has no state pre-K program: (($in->{'prek'} == 1 && ($in->{'child'.$i.'_age'} >= $prek_age_min && $in->{'child'.$i.'_age'} <= $prek_age_max))|| 
				if($in->{'child'.$i.'_age'} < 11) {
					$bkfst_red_price = $elem_bkfst_red;
					$bkfst_paid_price = $elem_bkfst_paid;
					$cep_participation_bkfst = $elem_cep_bkfst;
				} elsif ($in->{'child'.$i.'_age'} < 15) {
					$bkfst_red_price = $ms_bkfst_red;
					$bkfst_paid_price = $ms_bkfst_paid;
					$cep_participation_bkfst = $ms_cep_bkfst;
				} elsif ($in->{'child'.$i.'_age'} < 18) {
					$bkfst_red_price = $hs_bkfst_red;
					$bkfst_paid_price = $hs_bkfst_paid;
					$cep_participation_bkfst = $hs_cep_bkfst;
				}
				
				# Now we use the above school, school district, and parent choice variable to determine reductions in school breakfasts:
				if($in->{'nsbp'} == 1 && $cep_participation_bkfst == 1) {
					${'child'.$i.'_bkfst_red'} = $in->{'schooldays'} *$permealcost;
				} elsif (($out->{'tanf_recd'}>0 || $out->{'fsp_recd'}>0) || $schoolmeals_inc < $in->{'fpl'}*1.3 || $in->{'covid_sfsp_sso_expansion'} == 1) {
					${'child'.$i.'_bkfst_red'} = $in->{'schooldays'}*$permealcost;
				} elsif ($schoolmeals_inc <$in->{'fpl'}*1.85) {
					${'child'.$i.'_bkfst_red'} = $in->{'schooldays'} * &pos_sub($permealcost,$bkfst_red_price);
				} else {
					${'child'.$i.'_bkfst_red'} = $in->{'schooldays'} * &pos_sub($permealcost,$bkfst_paid_price);
				}
			} else {
				${'child'.$i.'_bkfst_red'} = 0;
			}
			# SCHOOL LUNCH
			# Similarly, we check for eligigibility for free or reduced-price lunch, which works exactly the same as breakfast above, but with different pricing. 

			if ($in->{'frpl'}==1 && $in->{'child'.$i.'_age'} >= 5) { #Removing from code, not relevant to NH since it has no state Pre-K program:  (($in->{'prek'} == 1 && $in->{'child'.$i.'_age'} >= $prek_age_min && $in->{'child'.$i.'_age'} <= $prek_age_max)|| 
				if($in->{'child'.$i.'_age'} < 11) {
					$lunch_red_price = $elem_lunch_red;
					$lunch_paid_price = $elem_lunch_paid;
					$cep_participation_lunch = $elem_cep_lunch;
				} elsif ($in->{'child'.$i.'_age'} < 15) {
					$lunch_red_price = $ms_lunch_red;
					$lunch_paid_price = $ms_lunch_paid;
					$cep_participation_lunch = $ms_cep_lunch;
				} elsif ($in->{'child'.$i.'_age'} < 18) {
					$lunch_red_price = $hs_lunch_red;
					$lunch_paid_price = $hs_lunch_paid;
					$cep_participation_lunch = $hs_cep_lunch;
				}

				if ($in->{'frpl'} == 1 && $cep_participation_lunch == 1) {
					${'child'.$i.'_lunch_red'} = $in->{'schooldays'}*$permealcost;
				} elsif (($out->{'tanf_recd'}>0 || $out->{'fsp_recd'}>0) || $schoolmeals_inc < $in->{'fpl'}*1.3 || $in->{'covid_sfsp_sso_expansion'} == 1) {
					${'child'.$i.'_lunch_red'} = $in->{'schooldays'}*$permealcost;
				} elsif ($schoolmeals_inc <$in->{'fpl'}*1.85) {
					${'child'.$i.'_lunch_red'} = $in->{'schooldays'}*&pos_sub($permealcost,$lunch_red_price);
				} else {
					${'child'.$i.'_lunch_red'} = $in->{'schooldays'}*&pos_sub($permealcost,$lunch_paid_price);
				}
			} else {
				${'child'.$i.'_lunch_red'} = 0;
			}

			# AFTERSCHOOL SNACK/SUPPER
			# If a family has enrolled their child in an afterschool program that is participating in the federal CACFP program, they also get a free snack or supper. We are defaulting to supper here but can change that later on. For states where we are modeling the impact of public afterschool programs, we will be able to demonstrate the savings to families generated by this program separate from afterschol.
			#if ($out->{'afterschool_child'.$i} == 1 && $in->{'cacfp'} == 1 && (($in->{'prek'} == 1 && ($in->{'child'.$i.'_age'}==3 || $in->{'child'.$i.'_age'}==4))|| $in->{'child'.$i.'_age'} >= 5)) { 

			#	${'child'.$i.'_supper_recd'}  = $schooldays*$permealcost; 
			#}

			# SUMMER 
			# All children are eligible for free summer meals through the federal Summer Food Service Program (SFSP), but we model the reduction for only children over 2 years because usually done breastfeeding and usually cannot feed themselves before this age. The input variable we used fro DC was 'fsmp' because that was what the program was called locally, and we have kept that variable name for compatibility. 
			# 
			if ($in->{'fsmp'} == 0 || $in->{'child'.$i.'_age'}<=2) { 
				${'child'.$i.'_sfsp_red'} = 0; 
			} else {
				${'child'.$i.'_sfsp_red'} = $in->{'summerdays'} *$permealcost; #This will zero out in towns where there is no free summer meal program. We use this input name even though the federel program is called "SFSP," as this was the local name for the program in DC in 2017, when we introduced this variable. A cleanup of the code could convert this input and all uses of it to "sfsp".
				#This is inclusive of teh COVID expansion of this program, which essentially extends it into the school year regardless of whether meals are provided onsite.
			}

			#COVID NOTE: NEW HAMPSHIRE IS NOT CURRENTLY PARTICIPATING IN THE PANDEMIC-EBT PROGRAM. IF IT WERE, CODE HERE COULD BE INCLUDED BASED ON THE ADDITIONAL EBT SUPPLEMENTS THAT FAMILIES IN PARTICIPATING STATES ARE ELIGIBLE TO RECEIVE. SEE https://www.fns.usda.gov/snap/state-guidance-coronavirus-pandemic-ebt-pebt FOR LISTING OF PARTICIPATING STATES.
			
			# TOTALING UP MEAL REDUCTIONS FOR THE CHILD
			${'child'.$i.'_foodcost_red'} = &round(${'child'.$i.'_bkfst_red'} + ${'child'.$i.'_lunch_red'} + ${'child'.$i.'_supper_recd'} + ${'child'.$i.'_sfsp_red'});

			#ADDING IN THE SFSP/SSO COVID EXPANSION TO PROVIDE FREE BREAKFAST AND SUMMER TO ALL CHILDREN, REGARDLESS OF AGE.
			if ($in->{'covid_sfsp_sso_expansion'} == 1 & 1==0) { #This is a model of free meal provision if adopted universally. But it appears that free meals are not offered universally in NH. So we're limiting the use of the extended free meal eligibiltiy to just modeling the provision of free meals to all students. We use a nonsensical condition here (1=0) to make sure this code is not active for NH now, but could be turned on in the future or other states . 
				if ($in->{'fsmp'} == 1) {
					#This program simply provides meals to all children who need it. It covers breakfast and lunch. Afterschool snacks are allowed, but for simplicity's sake, we are limiting our model of thesse meals to breakfast and lunch. Schools have flexibility for whether they are participating in this program via the various school nutrition programs. 
					#We still check for the fsmp flag (called "SFSP" in the list of benefits) because these meals are distributed at SFSP sites.
					#This calculation will supersede the previous calculations by simply covering the full cost of breakfast and lunch.
					#Administratively, this is done through SFSP/SSO, but federal waivers allowed for flexibiltiy to convert school nutrition programs to SFSP funding. So, it is reasonable to assume that a user will not necesssarily now which among these programs they are receiving meals from.
					${'child'.$i.'_foodcost_red'} = $permealcost *2 * 365;
				} else {
					#If the user has not clicked on free summer meals, we check for free or reduced price lunch or breakfast, and assume they can get free lunch or breakfast that way. We first reset the variable for the food cost reduction. We do this for every day of the year.
					${'child'.$i.'_foodcost_red'} = 0;
					if ($in->{'frpl'}==1) {
						${'child'.$i.'_foodcost_red'} = $permealcost * 365;
					}
					if ($in->{'nsbp'}==1) {
						${'child'.$i.'_foodcost_red'} += $permealcost *365;
					}
				}
			}

			#END OF PER-CHILD CALCULATION
		}

		$child_foodcost_red_total = $child1_foodcost_red + $child2_foodcost_red + $child3_foodcost_red + $child4_foodcost_red + $child5_foodcost_red; 
	}
	
	#debugs
	foreach my $debug (qw(child_foodcost_red_total)) {
		print $debug.": ".${$debug}."\n";
	}
	# outputs
	foreach my $name (qw(child_foodcost_red_total permealcost child1_foodcost_red  child2_foodcost_red child3_foodcost_red child4_foodcost_red child5_foodcost_red  child1_lunch_red child2_lunch_red child3_lunch_red child4_lunch_red child5_lunch_red)) {
      $out->{$name} = ${$name};
	}
}

1;
