#=============================================================================#
#  School & Summer Meals Module – 2021 DC 
#=============================================================================#
# NOTE FOR FUTURE USE: 
# This code began as state-specific, but it is getting general enough that it may merit removal from here and consideration as a federal/generic code. The only state-level decision remaining is the treatment of the in-code cep_participation variable and the cep input variable, and where we want to build in state variation, that could be included in either the frs_locations tab or the fsp_assets module.

# Inputs referenced in this module or outputs from other module needed for this module:
#
# INPUTS FROM USER INTERFACE
# 	child#_age
# 	nsbp 
# 	frpl 
# 	sfsp 
#	prek
# 	cacfp = 1; #We could add this as an input, but so far have not; absent a public afterschool program, CACFP benefits are difficult to model. While for a public afterschool program, participation could be modeled as reducing food costs from the free provision of meals to participating children, it is difficult to determine whether these costs are included or not in the market rates of child care, and whether savings in child care generated by CCDF reductions already incorporate savings from free or low-cost provision of school meals.  
#
# INPUTS FROM NCCP_SIMULATOR.PHP MYSQL PULLS
#	schooldays
#	summerdays
#
# INPUTS FROM FRS.PM
# 	fpl 
#
# OUTPUTS FROM INTEREST
# 	interest_m 
#
# OUTPUTS FROM PARENT EARNINGS
# 	earnings
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
# FROM CHILD_CARE
# 	prek_age_min 	
# 	prek_age_max 	
#	
#=============================================================================#

sub schoolsummermeals
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

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
			$elem_lunch_paid = 2.48; #This is the average full-price lunch cost for elementary school students in 2016-2017, based on a 2018 School Nutrition Association report (widely respected), nationally, pre-covid. Normally we'd try to identify the cost per school district or average cost per state or locality, but during COVID all these lunches are free, at least through the end of the 2020-2021 school year. So any price here would be a bit of an abstraction. School lunch and breakfast prices don't vary much, beyond whether schools provide meals for free or not. See https://schoolnutrition.org/aboutschoolmeals/schoolmealtrendsstats/. 
			$elem_bkfst_paid = 1.46; #This is the average full-price breakfast cost for elementary school students nationally as of 2016-2017. 
			$ms_lunch_paid = 2.68; #This is the average full-price breakfast cost for middle school students nationally as of 2016-2017, pre-covid. 
			$ms_bkfst_paid = 1.53; #This is the average full-price breakfast cost for middle school students nationally as of 2016-2017, pre-covid. 
			$hs_lunch_paid = 2.74; #Same as above, for HS students.
			$hs_bkfst_paid =1.55;  #Same as above, for HS students.

			#Reduced price meal costs:
			$elem_lunch_red = 0.4; # In general, reduced-price lunch is $0.40. Previous FRS codes estimated the prices of school lunch at the town / school district level, but there is so little variation there, it's likely not worth the trouble.
			$elem_bkfst_red = 0.3; # In general, reduced-price breakfast is $0.30. Previous FRS codes estimated the prices of school lunch at the town / school district level, but there is so little variation there, it's likely not worth the trouble. The main difference is whether schools offer reduced price breakfast or not, but users are indicating in the input pages of the MTRC whether their children are participating in this program. Conceivably, we could ask exactly which children receive these benefits (since they may go to different schools), but it seems probable that if one child attends a school with reduced price meals, the other will as well. While we have done this data dig for NH, the process was onerous enough that it does not seem appropriate to ask for these fields to be updated beyond adjusting the standard prices set at the federal level.
			$ms_lunch_red = 0.4;
			$ms_bkfst_red = 0.3;
			$hs_lunch_red = 0.4;
			$hs_bkfst_red = 0.3;
			
			#These variables could be adjusted by locality or school district. We could also make them univesally 1, since most public schools offer free lunch and breakfast to all students, even pre-COVID.
			$elem_cep_lunch = 1; #after 2021-22 school year, consider changing thi to $in->{'cep'}; # This and all other below cep variables indicate whether there is a school in the jurisdiction the family lives in that participates in CEP. This is universal in Pittsburgh but parents in Allegheny County will be asked whether their child is in a school that offered free lunch or breakfast to everybody.
			$elem_cep_bkfst = 1; #after 2021-22 school year, consider changing thi to $in->{'cep'}; 
			$ms_cep_lunch = 1; #after 2021-22 school year, consider changing thi to $in->{'cep'}; 
			$ms_cep_bkfst = 1; #after 2021-22 school year, consider changing thi to $in->{'cep'}; 
			$hs_cep_lunch = 1; #after 2021-22 school year, consider changing thi to $in->{'cep'}; 
			$hs_cep_bkfst = 1; #after 2021-22 school year, consider changing thi to $in->{'cep'}; 

		}		
		
		# CALCULATING FAMILY INCOME FOR SCHOOL AND SUMMER MEAL ELIGIBILITY:
		#We can also run the income test for free lunch eligibility at this point, since that will be true across all children.  Identical to SSI income determinations, but SSI assistance is included. Reportable Income (https://www.ssa.gov/OP_Home/cfr20/416/416-app-k.htm) includes earnings, SSI, cash assistance, child support, and any other money available to pay for children’s meals. SNAP value is not counted. 

		$schoolmeals_inc_m = $out->{'earnings'}/12 + $out->{'child_support_recd_m'} + $in->{'alimony_paid_m'} + $out->{'gift_income_m'} + $out->{'ssi_recd_mnth'} + $out->{'tanf_recd_m'} +$in->{'other_income_m'} + $in->{'selfemployed_netprofit_total'}/12 +  $in->{'unearn_gross_mon_inc_amt_ag'} + $out->{'ui_recd_m'}; # Note: Nowhere in the Federal Register 3/20/19 definition of "income" for determining eligibility for school meals do the rules explicitly include payments that would have been included in a TANF cash assistance grant had a family member not been under sanctions.
		
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

			# Check eligibility for national school breakfast program for all children. Students attending schools or districts participating in the Community Eligibility Provision (CEP) receive both school breakfasts and school lunches for free regardless of income. All DC schools participate in this program, but in other locations, only some schools participate, meaning that we will need formulas for both school and breakfast meals based on how much schools charge for both the full cost of meals and the reduced-price cost of meals (both of which are determined by school). In these locations, students are eligible for free lunches if their family's incomes are below 130% FPG or if they receive SNAP or TANF. They are eligible for reduced-price meals if their incomes are below 185% FPG.


			# SCHOOL BREAKFAST

			if ($in->{'nsbp'}==1 && $in->{'child'.$i.'_age'} >= 5) { 
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
				
				#These first three if-condtions check to see if any of the ways that meals are free are satisified here. This could be a very large OR statement but we are separating it out for simplicity.
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

			if (($in->{'frpl'}==1 && $in->{'child'.$i.'_age'} >= 5) || ($in->{'prek'} == 1 && $in->{'child'.$i.'_age'} >= $out->{'prek_age_min'} && $in->{'child'.$i.'_age'} <= $out->{'prek_age_max'})) { 
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
					${'child'.$i.'_lunch_red'} = $in->{'schooldays'} * $permealcost;
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
			# All children are eligible for free summer meals through the federal Summer Food Service Program (SFSP), but we model the reduction for only children over 2 years because usually done breastfeeding and usually cannot feed themselves before this age. 
			# Because of the name of DC's program when we coded this in 2017, we are using the variable "fsmp" here.
			if ($in->{'fsmp'} == 0 || $in->{'child'.$i.'_age'}<=2) { 
				${'child'.$i.'_sfsp_red'} = 0; 
			} else {
				${'child'.$i.'_sfsp_red'} = $in->{'summerdays'} *$permealcost; #This will zero out in towns where there is no free summer meal program. 
				#This is inclusive of teh COVID expansion of this program, which essentially extends it into the school year regardless of whether meals are provided onsite.
			}

			#COVID NOTE: WE ARE NOT MODELING THE PANDEMIC-EBT PROGRAM, WHICH PROVIDES CASH BENEFITS TO CHILDREN WHO ARE NOT IN SCHOOL IN PLACE OF SCHOOL LUNCHES. WE ARE ASSUMING HERE THAT SCHOOL IS IN-PERSON OR THAT THE BENEFITS FROM THIS PROGRAM MATCH THE BENEFITS FROM SCHOOL MEALS.
			
			# TOTALING UP MEAL REDUCTIONS FOR THE CHILD
			${'child'.$i.'_foodcost_red'} = &round(${'child'.$i.'_bkfst_red'} + ${'child'.$i.'_lunch_red'} + ${'child'.$i.'_supper_recd'} + ${'child'.$i.'_sfsp_red'});

			#ADDING IN THE SFSP/SSO COVID EXPANSION TO PROVIDE FREE BREAKFAST AND SUMMER TO ALL CHILDREN, REGARDLESS OF AGE.
			if ($in->{'covid_sfsp_sso_expansion'} == 1 & 1==0) { #This is a model of free meal provision if adopted universally.  So we're limiting the use of the extended free meal eligibiltiy to just modeling the provision of free meals to all students. We use a nonsensical condition here (1=0) to make sure this code is not active right now, but could be turned on in jurisdictions with univeral free meal programs available to all children. 
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
	foreach my $debug (qw(child_foodcost_red_total child1_lunch_red child1_bkfst_red cep_participation_lunch)) {
		print $debug.": ".${$debug}."\n";
	}
	# outputs
	foreach my $name (qw(child_foodcost_red_total permealcost child1_foodcost_red  child2_foodcost_red child3_foodcost_red child4_foodcost_red child5_foodcost_red  child1_lunch_red child2_lunch_red child3_lunch_red child4_lunch_red child5_lunch_red)) {
      $out->{$name} = ${$name};
	}
}

1;
