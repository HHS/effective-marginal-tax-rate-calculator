#=============================================================================#
#  Child Care Module -- 2021 DC
#=============================================================================#
#NOTES FOR UNDERSTANDING SQL DATA:
#"fulltime" in data is subsidized full-time traditional.
#"parttime" in data is subsidized part-time traditional.
#"parttimetraditionalbora" is part-time traditional before OR after school. This is distinct from "parttimetraditional," which is, for school-age children, before AND after school. This category is only available to school-age children.
#There is no SPR for relative care for extended day or nontraditional care for pre-school age children. Not clear why, but we'll just have to deal with it.
#These are daily rates.


#

# INPUTS NEEDED:
	#
	# FROM USER SELECTIONS
	# day#_hours_child#
	# summerday#_hours_child#
	# child#_age
	# residence
	# headstart
	# earlyheadstart
	# child#_withbenefit_setting
	# schoolage_care_initial_child#
	# schoolage_care_future_child#
	# ccdf
	# child_care_nobenefit_estimate_source
	# cc_nobenefit_payscale#
	# child#_nobenefit_amt_m
	# child_care_continue_estimate_source
	# cc_continue_payscale# 
	# child#_continue_amt_m
	#
	# FROM VARIABLES DERIVED IN PHP FROM USER SELECTIONS
	# children_under13
	# future_scenario
	# child#_withbenefit_cost_m
	# child#_withbenefit_cost_m_pt
	# child#_withbenefit_aschoolonly_cost
	# child#_withbenefit_bschoolonly_cost
	# child#_withbenefit_baschool_cost
	# child#_withbenefit_cost_m_sub
	# child#_withbenefit_cost_m_sub_pt
	# child#_withbenefit_cost_m_sub_ht
	# child#_continue_cost_m
	# child#_continue_cost_m_pt
	# child#_continue_aschoolonly_unsub
	# child#_continue_bschoolonly_unsub
	# child#_continue_baschool_unsub
	# child#_nobenefit_cost_m
	# child#_nobenefit_cost_m_pt
	# child#_nobenefit_aschoolonly_unsub
	# child#_nobenefit_bschoolonly_unsub
	# child#_nobenefit_baschool_unsub
	#
	# FROM FRS.PM
	# fpl

# OUTPUTS NEEDED (from other modules):
	#
	# FROM FRS.PL
	# scenario
	# headstart_alt
	#
	# FROM TANF
	# tanf_recd
	#
	# FROM SSI
	# ssi_recd
	#
	# FROM PARENT_EARNINGS
	# parent_workhours_w
	# earnings
#=============================================================================#


sub child_care
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# Variables reflecting policies. 
	our $summerweeks = 9; #For now, we're using this universally. It's a typical amount and exact school calendars won't be newly generated until after COVID subsides.
	our $max_headstart_length = 10; #This is the maximum number of hours that a Head Start provider in Allegheny County offers child care services. Like the other Head Start variables for suggesting Head Start as a potential solution to benefit cliffs, we are factoring in the most expansive version of this program.
	our $min_headstart_age_min = 3; #This is the minimum age for entry for at least one Head Start provider in DC.
	our $max_headstart_age_max = 4; #All DC Head Start programs have a maximum HS age of 4.
	our $headstart_summer = 1; #This is a flag indicating that Head Start is offered in summer, again modeling the most expansive program in DC.

	our $max_earlyheadstart_length  = 8;
	our $min_earlyheadstart_age_min = 0;
	our	$max_earlyheadstart_age_max = 3;
	our	$earlyheadstart_summer = 1;

	our $prek_age_min = 3; #minimum age for partipation in DC PK3 and PK4 program.
	our $prek_age_max = 4; #maximum age for partipation in DC PK3 and PK4 program. Actually this is just up to Kindergarten age, but we are saying that's 5 years old for all children in our model.


	# NOTE FOR DC COUNTY RE FREE PRE-K
	# All age-eligible children in DC can receive free Pre-K
	# 
	# 
	#
	# 
	# There is no annual recertification once children are in free Pre-K.
	# Half-day programs provide 2.5 hours of instructional time per year.
	# Full-day programs provide 5 hours of instructional time per year.
	# Half-day programs must provide at least one meal per day to participating children.
	# Full-day programs must provide at least one meal and one snack per day to participating children.
	
	#our $prek_fpl_income_limit = 3; # There is no income requirement in DC's pre-K program.
	our $max_prek_length = 6.5;
	
	our $ft_hours_min = 6; #The minimum number of hours for care provided during a single day to be counted as full-time in DC. 
	our $ft_hours_max = 11; #The maximum number of hours for care provided during a single day to be counted as full-time and not extended day full time in DC. 
	our $extended_hours_max = 14; #The maximum number of hours for care provided during a single day to be counted as extended day full-time and not an additional child care shift in DC.

	#Outputs that we will need for other modules:
	our $spr_all_children = 0;    # total annual state reimbursement rate to all children's providers
	our $unsub_all_children = 0; 	# unsubsidized cost of child care for all children
	our $fullcost_all_children = 0; 	# full cost of child care for all children whose care is partially supported by CCDF subsidies
	our $spr_child1 = 0;
	our $spr_child2	= 0;
	our $spr_child3 = 0;
	our $spr_child4 = 0;
	our $spr_child5 = 0;
	our $unsub_child1 = 0;
	our $unsub_child2 = 0;
	our $unsub_child3 = 0;
	our $unsub_child4 = 0;
	our $unsub_child5 = 0;
	our $fullcost_child1 = 0;
	our $fullcost_child2 = 0;
	our $fullcost_child3 = 0;
	our $fullcost_child4 = 0;
	our $fullcost_child5 = 0;
	our $child_care_expenses_m = 0; #We establish this here and then assign it to the output set so that the TANF code can run the first time. It gets recalculated in ccdf.
	our $child_care_expenses = 0; #We establish this here and then assign it to the output set so that the TANF code can run the first time. It gets recalculated in ccdf.
	
	#Intermediary variables
	
	our $cc_day1_hours_child1 = 0;
	our $cc_day2_hours_child1 = 0;
	our $cc_day3_hours_child1 = 0;
	our $cc_day4_hours_child1 = 0;
	our $cc_day5_hours_child1 = 0;
	our $cc_day6_hours_child1 = 0;
	our $cc_day7_hours_child1 = 0;
	our $summer_cc_day1_hours_child1 = 0;
	our $summer_cc_day2_hours_child1 = 0;
	our $summer_cc_day3_hours_child1 = 0;
	our $summer_cc_day4_hours_child1 = 0;
	our $summer_cc_day5_hours_child1 = 0;
	our $summer_cc_day6_hours_child1 = 0;
	our $summer_cc_day7_hours_child1 = 0;

	our $cc_day1_hours_child2 = 0;
	our $cc_day2_hours_child2 = 0;
	our $cc_day3_hours_child2 = 0;
	our $cc_day4_hours_child2 = 0;
	our $cc_day5_hours_child2 = 0;
	our $cc_day6_hours_child2 = 0;
	our $cc_day7_hours_child2 = 0;
	our $summer_cc_day1_hours_child2 = 0;
	our $summer_cc_day2_hours_child2 = 0;
	our $summer_cc_day3_hours_child2 = 0;
	our $summer_cc_day4_hours_child2 = 0;
	our $summer_cc_day5_hours_child2 = 0;
	our $summer_cc_day6_hours_child2 = 0;
	our $summer_cc_day7_hours_child2 = 0;

	our $cc_day1_hours_child3 = 0;
	our $cc_day2_hours_child3 = 0;
	our $cc_day3_hours_child3 = 0;
	our $cc_day4_hours_child3 = 0;
	our $cc_day5_hours_child3 = 0;
	our $cc_day6_hours_child3 = 0;
	our $cc_day7_hours_child3 = 0;
	our $summer_cc_day1_hours_child3 = 0;
	our $summer_cc_day2_hours_child3 = 0;
	our $summer_cc_day3_hours_child3 = 0;
	our $summer_cc_day4_hours_child3 = 0;
	our $summer_cc_day5_hours_child3 = 0;
	our $summer_cc_day6_hours_child3 = 0;
	our $summer_cc_day7_hours_child3 = 0;

	our $cc_day1_hours_child4 = 0;
	our $cc_day2_hours_child4 = 0;
	our $cc_day3_hours_child4 = 0;
	our $cc_day4_hours_child4 = 0;
	our $cc_day5_hours_child4 = 0;
	our $cc_day6_hours_child4 = 0;
	our $cc_day7_hours_child4 = 0;
	our $summer_cc_day1_hours_child4 = 0;
	our $summer_cc_day2_hours_child4 = 0;
	our $summer_cc_day3_hours_child4 = 0;
	our $summer_cc_day4_hours_child4 = 0;
	our $summer_cc_day5_hours_child4 = 0;
	our $summer_cc_day6_hours_child4 = 0;
	our $summer_cc_day7_hours_child4 = 0;

	our $cc_day1_hours_child5 = 0;
	our $cc_day2_hours_child5 = 0;
	our $cc_day3_hours_child5 = 0;
	our $cc_day4_hours_child5 = 0;
	our $cc_day5_hours_child5 = 0;
	our $cc_day6_hours_child5 = 0;
	our $cc_day7_hours_child5 = 0;
	our $summer_cc_day1_hours_child5 = 0;
	our $summer_cc_day2_hours_child5 = 0;
	our $summer_cc_day3_hours_child5 = 0;
	our $summer_cc_day4_hours_child5 = 0;
	our $summer_cc_day5_hours_child5 = 0;
	our $summer_cc_day6_hours_child5 = 0;
	our $summer_cc_day7_hours_child5 = 0;

	our $cc_hours_wk_child1 = 0;
	our $cc_hours_wk_child2 = 0;
	our $cc_hours_wk_child3 = 0;
	our $cc_hours_wk_child4 = 0;
	our $cc_hours_wk_child5 = 0;
	our $summer_cc_hours_wk_child1 = 0;
	our $summer_cc_hours_wk_child2 = 0;
	our $summer_cc_hours_wk_child3 = 0;
	our $summer_cc_hours_wk_child4 = 0;
	our $summer_cc_hours_wk_child5 = 0;

	our $spr_week_child1 = 0;
	our $spr_week_child2 = 0;
	our $spr_week_child3 = 0;
	our $spr_week_child4 = 0;
	our $spr_week_child5 = 0;
	our $summer_spr_week_child1 = 0;
	our $summer_spr_week_child2 = 0;
	our $summer_spr_week_child3 = 0;
	our $summer_spr_week_child4 = 0;
	our $summer_spr_week_child5 = 0;

	our $unsub_week_child1 = 0;
	our $unsub_week_child2 = 0;
	our $unsub_week_child3 = 0;
	our $unsub_week_child4 = 0;
	our $unsub_week_child5 = 0;
	our $summer_unsub_week_child1 = 0;
	our $summer_unsub_week_child2 = 0;
	our $summer_unsub_week_child3 = 0;
	our $summer_unsub_week_child4 = 0;
	our $summer_unsub_week_child5 = 0;

	our $fullcost_week_child1 = 0;
	our $fullcost_week_child2 = 0;
	our $fullcost_week_child3 = 0;
	our $fullcost_week_child4 = 0;
	our $fullcost_week_child5 = 0;
	our $summer_fullcost_week_child1 = 0;
	our $summer_fullcost_week_child2 = 0;
	our $summer_fullcost_week_child3 = 0;
	our $summer_fullcost_week_child4 = 0;
	our $summer_fullcost_week_child5 = 0;

	our $unsub_child1_nonsummer = 0 ;
	our $unsub_child1_summer = 0;
	our $unsub_child2_nonsummer = 0 ;
	our $unsub_child2_summer = 0;
	our $unsub_child3_nonsummer = 0 ;
	our $unsub_child3_summer = 0;
	our $unsub_child4_nonsummer = 0 ;
	our $unsub_child4_summer = 0;
	our $unsub_child5_nonsummer = 0 ;
	our $unsub_child5_summer = 0;
	our $unsub_nonsummer = 0;
	our $unsub_summer = 0;

	our $cc_day1_nontrad_hours_child1 = 0;
	our $cc_day2_nontrad_hours_child1 = 0;
	our $cc_day3_nontrad_hours_child1 = 0;
	our $cc_day4_nontrad_hours_child1 = 0;
	our $cc_day5_nontrad_hours_child1 = 0;
	our $cc_day6_nontrad_hours_child1 = 0;
	our $cc_day7_nontrad_hours_child1 = 0;

	our $cc_day1_nontrad_hours_child2 = 0;
	our $cc_day2_nontrad_hours_child2 = 0;
	our $cc_day3_nontrad_hours_child2 = 0;
	our $cc_day4_nontrad_hours_child2 = 0;
	our $cc_day5_nontrad_hours_child2 = 0;
	our $cc_day6_nontrad_hours_child2 = 0;
	our $cc_day7_nontrad_hours_child2 = 0;

	our $cc_day1_nontrad_hours_child3 = 0;
	our $cc_day2_nontrad_hours_child3 = 0;
	our $cc_day3_nontrad_hours_child3 = 0;
	our $cc_day4_nontrad_hours_child3 = 0;
	our $cc_day5_nontrad_hours_child3 = 0;
	our $cc_day6_nontrad_hours_child3 = 0;
	our $cc_day7_nontrad_hours_child3 = 0;

	our $cc_day1_nontrad_hours_child4 = 0;
	our $cc_day2_nontrad_hours_child4 = 0;
	our $cc_day3_nontrad_hours_child4 = 0;
	our $cc_day4_nontrad_hours_child4 = 0;
	our $cc_day5_nontrad_hours_child4 = 0;
	our $cc_day6_nontrad_hours_child4 = 0;
	our $cc_day7_nontrad_hours_child4 = 0;

	our $cc_day1_nontrad_hours_child5 = 0;
	our $cc_day2_nontrad_hours_child5 = 0;
	our $cc_day3_nontrad_hours_child5 = 0;
	our $cc_day4_nontrad_hours_child5 = 0;
	our $cc_day5_nontrad_hours_child5 = 0;
	our $cc_day6_nontrad_hours_child5 = 0;
	our $cc_day7_nontrad_hours_child5 = 0;

	our $summer_cc_day1_nontrad_hours_child1 = 0;
	our $summer_cc_day2_nontrad_hours_child1 = 0;
	our $summer_cc_day3_nontrad_hours_child1 = 0;
	our $summer_cc_day4_nontrad_hours_child1 = 0;
	our $summer_cc_day5_nontrad_hours_child1 = 0;
	our $summer_cc_day6_nontrad_hours_child1 = 0;
	our $summer_cc_day7_nontrad_hours_child1 = 0;

	our $summer_cc_day1_nontrad_hours_child2 = 0;
	our $summer_cc_day2_nontrad_hours_child2 = 0;
	our $summer_cc_day3_nontrad_hours_child2 = 0;
	our $summer_cc_day4_nontrad_hours_child2 = 0;
	our $summer_cc_day5_nontrad_hours_child2 = 0;
	our $summer_cc_day6_nontrad_hours_child2 = 0;
	our $summer_cc_day7_nontrad_hours_child2 = 0;

	our $summer_cc_day1_nontrad_hours_child3 = 0;
	our $summer_cc_day2_nontrad_hours_child3 = 0;
	our $summer_cc_day3_nontrad_hours_child3 = 0;
	our $summer_cc_day4_nontrad_hours_child3 = 0;
	our $summer_cc_day5_nontrad_hours_child3 = 0;
	our $summer_cc_day6_nontrad_hours_child3 = 0;
	our $summer_cc_day7_nontrad_hours_child3 = 0;

	our $summer_cc_day1_nontrad_hours_child4 = 0;
	our $summer_cc_day2_nontrad_hours_child4 = 0;
	our $summer_cc_day3_nontrad_hours_child4 = 0;
	our $summer_cc_day4_nontrad_hours_child4 = 0;
	our $summer_cc_day5_nontrad_hours_child4 = 0;
	our $summer_cc_day6_nontrad_hours_child4 = 0;
	our $summer_cc_day7_nontrad_hours_child4 = 0;

	our $summer_cc_day1_nontrad_hours_child5 = 0;
	our $summer_cc_day2_nontrad_hours_child5 = 0;
	our $summer_cc_day3_nontrad_hours_child5 = 0;
	our $summer_cc_day4_nontrad_hours_child5 = 0;
	our $summer_cc_day5_nontrad_hours_child5 = 0;
	our $summer_cc_day6_nontrad_hours_child5 = 0;
	our $summer_cc_day7_nontrad_hours_child5 = 0;

	our $remaining_nontrad_hours = 0;
	our $remaining_hours = 0;
	# 1. DETERMINE NEED FOR CARE 
	#

	if ($in->{'children_under13'} == 0) { 
		$unsub_all_children = 0;
		$spr_all_children = 0;
	} else  {
		#
		for(my $i=1; $i<=5; $i++) {

			if ($in->{'child'.$i.'_age'} >=13 || $in->{'child'.$i.'_age'} == -1) {
				${'spr_child' . $i} = 0;
				${'unsub_child' . $i} = 0;
				${'fullcost_child' . $i} = 0;
			} else { 
				#We first do a little debugging, to make sure we have values for each of the hour-day variables we need to calculate total child care needs and costs.
				for(my $j=1; $j<=7; $j++) {							
					$in->{'day'.$j.'_hours_child'.$i} = $in->{'day'.$j.'_hours_child'.$i} // 0;
					$in->{'day'.$j.'_nontrad_hours_child'.$i} = $in->{'day'.$j.'_nontrad_hours_child'.$i} // 0; 
					#I don't think this is necessary anymore, given the JavaScript controls that prevent empty entries. But it's harmless to keep in here.
					if ($in->{'day'.$j.'_hours_child'.$i} eq '') {
						$in->{'day'.$j.'_hours_child'.$i} = 0;
					}
					if ($in->{'day'.$j.'_nontrad_hours_child'.$i} eq '') {
						$in->{'day'.$j.'_nontrad_hours_child'.$i} = 0;
					}
					
					#We need to make summer hours the same as reguar hours in the case of families who do not have any children under 5.
					if ($in->{'schoolage_children_under13'} == 0) {
						$in->{'summerday'.$j.'_hours_child'.$i} = $in->{'day'.$j.'_hours_child'.$i};					
						$in->{'summerday'.$j.'_future_hours_child'.$i} = $in->{'day'.$j.'_future_hours_child'.$i} // 0;
						$in->{'summerday'.$j.'_nontrad_hours_child'.$i} = $in->{'day'.$j.'_hours_child'.$i};
						$in->{'summerday'.$j.'_nontrad_future_hours_child'.$i} = $in->{'day'.$j.'_future_hours_child'.$i} // 0;
					} else {
						#I don't think this is necessary anymore, given the JavaScript controls that prevent empty entries.
						$in->{'summerday'.$j.'_hours_child'.$i} = $in->{'summerday'.$j.'_hours_child'.$i} // 0;					
						if ($in->{'summerday'.$j.'_hours_child'.$i} eq '') {
							$in->{'summerday'.$j.'_hours_child'.$i} = 0;
							$in->{'summerday'.$j.'_nontrad_hours_child'.$i} = 0;					
						}
					}
					#We calculate the total hours per child, for both the non-summer and summer weeks:
					
					#We have to see which set of child care inputs to use -- the if-block below orients these calculations to the "current" child care schedules, and also uses those same schedules if child care doesn't change in future iterations.
					
					#Note that unlike NH, PA and DC pay providers by the day, and its market rates are tied to daily rates.
					if ($out->{'scenario'} eq 'current' || ($out->{'scenario'} eq 'future' && ($in->{'future_scenario'} eq 'none' || $in->{'future_scenario'} eq 'wages'))) { 
				
						${'cc_day'.$j.'_hours_child'.$i} = $in->{'day'.$j.'_hours_child'.$i};
						${'summer_cc_day'.$j.'_hours_child'.$i} = $in->{'summerday'.$j.'_hours_child'.$i};
						${'cc_day'.$j.'_nontrad_hours_child'.$i} = $in->{'day'.$j.'_nontrad_hours_child'.$i};					
						${'summer_cc_day'.$j.'_nontrad_hours_child'.$i} = $in->{'summerday'.$j.'_nontrad_hours_child'.$i};
						${'schoolage_care_child'.$i} = $in->{'schoolage_care_initial_child'.$i};

					} else {

						${'cc_day'.$j.'_hours_child'.$i} = $in->{'day'.$j.'_future_hours_child' . $i};
						${'summer_cc_day'.$j.'_hours_child'.$i} = $in->{'summerday'.$j.'_future_hours_child'.$i};
						${'cc_day'.$j.'_nontrad_hours_child'.$i} = $in->{'day'.$j.'_nontrad_future_hours_child'.$i};
						${'summer_cc_day'.$j.'_nontrad_hours_child'.$i} = $in->{'summerday'.$j.'_nontrad_future_hours_child'.$i};
						${'schoolage_care_child'.$i} = $in->{'schoolage_care_future_child'.$i};
					}

					#INCORPORATING HEAD START AND EARLY HEAD START SCENARIOS

					#For the Head Start and Early Head Start scenarios, we reduce hours of child care by the most expansive program(s) available in the state or jurisdiction. We redefine teh child care hours totals here. While we coudl reduce these inputs above, we do not want to replace the inputs with lower values. We could also make this cleaner if we saved local day/hour variables, but that would signify the creation and tracking of a lot more variables. Easier this way. 
					if ($in->{'headstart'} == 0 && $out->{'headstart_alt'} == 1 && $in->{'child'.$i.'_age'} >= $min_headstart_age_min && $in->{'child'.$i.'_age'} <= $max_headstart_age_max && ($out->{'earnings'} + $out->{'tanf_recd '} + $out->{'ssi_recd'} + $out->{'interest'} + $out->{'child_support_recd'} + $in->{'alimony_paid_m'} * 12 + $out->{'gift_income'} + &pos_sub($out->{'ui_recd_m'}, $out->{'fpuc_recd'}/12) < $in->{'fpl'} || $out->{'tanf_recd'} > 0 || $out->{'ssi_recd'} > 0)) { #We only test this if the user has indicated they are NOT currently using Head Start services. We're modeling the potential benefits of doing so. TANF and SSI provide categorical eligibility here. Since this reduces child care need, that's a potential loop, since TANF receipt is also partially dependent on child care costs. This is why we first set tanf_recd to 0 in the parent_earnings code, then run the child care code first (with tanf_recd equal to 0), then tun TANF to determine TANF eligibility, then run this code again, in case TANF receipt is now positive. If this scenario will result in a household being eligible for Head Start, we model the below reductions. At this point, since we are modeling entrance eligibility standards for Head Start (unlike most other codes here), we are modeling that the family has gained eligibility for Head Start and that the child is enrolled. This may reduce child care need, possibly to the point that the family no longer is eligible for TANF (if child care costs contributed to their TANF eligibility), but the possibility that they no longer would satisfy entrance eligibiltiy guidelines for Head Start is moot, since they are already enrolled in Head Start. 

						# Children from birth to age five who are from families with incomes below the poverty guidelines are eligible for Head Start and Early Head Start services. Children from homeless families, and families receiving public assistance such as TANF or SSI are also eligible. Foster children are eligible regardless of their foster family�s income. (from https://eclkc.ohs.acf.hhs.gov/eligibility-ersea/article/poverty-guidelines-determining-eligibility-participation-head-start-programs).
						
						#Definition of Income for Head Start defined here: https://eclkc.ohs.acf.hhs.gov/policy/45-cfr-chap-xiii/1305-2-terms. Refers also to census definition from 1992, which is very inclusive.

						if ($j<=5) { #Just making this adjustments for the weekdays:
							${'cc_day'.$j.'_hours_child'.$i} = pos_sub(${'cc_day'.$j.'_hours_child'.$i}, $max_headstart_length);
						}		
						if ($headstart_summer == 1 && $j<=5) { #This will always be true since this variable is set to 1 in this same code. But keeping it here in case someone using this code decides against buiding in the avaialility of Head Start in the summer for this potential scenario.
							${'summer_cc_day'.$j.'_hours_child'.$i} =  pos_sub(${'summer_cc_day'.$j.'_hours_child'.$i}, $max_headstart_length);
						}
					}		
					
					#We do the same exercise as above for the "Early Head Start" alternative scenario:
					if ($in->{'earlyheadstart'} == 0 && $out->{'earlyheadstart_alt'} == 1 && $in->{'child'.$i.'_age'} >= $min_earlyheadstart_age_min && $in->{'child'.$i.'_age'} <= $max_earlyheadstart_age_max && ($out->{'earnings'} + $out->{'tanf_recd '} + $out->{'ssi_recd'} + $out->{'interest'} + $out->{'child_support_recd'} + $in->{'alimony_paid_m'} * 12 + $out->{'gift_income'} + &pos_sub($out->{'ui_recd_m'}, $out->{'fpuc_recd'}/12) < $in->{'fpl'} || $out->{'tanf_recd'} > 0 || $out->{'ssi_recd'} > 0)) { #Same considerations and rules apply for entry into Early Head Start programs.
						if ($j<=5) { #Just making this adjustments for the weekdays:
							${'cc_day'.$j.'_hours_child'.$i} = pos_sub(${'cc_day'.$j.'_hours_child'.$i}, $max_earlyheadstart_length);
						}		
						if ($earlyheadstart_summer == 1 && $j<=5) { #This will always be true since this variable is set to 1 in this same code. But keeping it here in case someone using this code decides against buiding in the avaialility of Head Start in the summer for this potential scenario.
							${'summer_cc_day'.$j.'_hours_child'.$i} =  pos_sub(${'summer_cc_day'.$j.'_hours_child'.$i}, $max_earlyheadstart_length);
						}
					}		

					#INCORPORATING THE PRE-K SCENARIO (FOR JURISDICTIONS LIKE PA THAT OFFER FREE PRE-K).
					
					if ($in->{'prek'} == 0 && $out->{'prek_alt'} == 1 && $in->{'child'.$i.'_age'} >= $prek_age_min && $in->{'child'.$i.'_age'} <= $prek_age_max) { 
						if ($j<=5) { #Just making this adjustments for the weekdays:
							${'cc_day'.$j.'_hours_child'.$i} = pos_sub(${'cc_day'.$j.'_hours_child'.$i}, $max_prek_length);
						}		
					}

					#For DC, where we are including nontraditional hours but days that could be reduced by HS, EHS, or Pre-K enrollment, need to again check that the nontraditional hours don't exceed the number of total child care hours.
					${'cc_day'.$j.'_nontrad_hours_child'.$i} = &least(${'cc_day'.$j.'_nontrad_hours_child'.$i},${'cc_day'.$j.'_hours_child'.$i});
					${'summer_cc_day'.$j.'_nontrad_hours_child'.$i} = &least(${'summer_cc_day'.$j.'_nontrad_hours_child'.$i},${'summer_cc_day'.$j.'_hours_child'.$i});										
					
					#

					#DETERMINING THE COMBINED MARKET RATE OF CHILD CARE

					# Now we calcualte how much per weeek the parent pays in child care, first during the school year. Check if child needs any child care, is school-age and what type of school-age care, if any, they receive, and assign costs collected in PHP accordingly.
					$remaining_hours = 0; #redefininig these at the beginning of each loop. Including day and child designations for this variable seems overly unnecesary and busy.
					$remaining_nontrad_hours = 0; 
					if (${'cc_day'.$j.'_hours_child'.$i} == 0) {
						${'spr_week_child' . $i} += 0;
						${'unsub_week_child' . $i} += 0;
						${'fullcost_week_child' . $i} += 0;
					} elsif (${'cc_day'.$j.'_hours_child'.$i} < $ft_hours_min) {
						if (${'cc_day'.$j.'_nontrad_hours_child'.$i} == 0 && $j < 6 && ($in->{'child'.$i.'_age'} < 6 || ${'schoolage_care_child'.$i} eq 'bandaschool')) { #weekday traditional care:
							${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_sub_pt'};
							${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_pt'};
							if ($in->{'ccdf'} == 1) {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_cost_m_pt'};
							} else {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_cost_m_pt'};
							}
						} elsif (${'cc_day'.$j.'_nontrad_hours_child'.$i} == 0) { #weekday traditional care:
							${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_parttimetraditionalbora_sub'};
							${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_parttimetraditionalbora_cost'};
							if ($in->{'ccdf'} == 1) {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_parttimetraditionalbora_unsub'};
							} else {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_parttimetraditionalbora_unsub'};
							}
						} elsif (${'cc_day'.$j.'_nontrad_hours_child'.$i} / ${'cc_day'.$j.'_hours_child'.$i} < .5 && $j < 6) {
							${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayparttime_sub'};
							${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayparttime_cost'};
							if ($in->{'ccdf'} == 1) {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_extendeddayparttime_unsub'};
							} else {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_extendeddayparttime_unsub'};
							}
						} else {
							${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalparttime_sub'};
							${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalparttime_cost'};
							if ($in->{'ccdf'} == 1) {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_nontraditionalparttime_unsub'};
							} else {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_nontraditionalparttime_unsub'};
							}
						}
					} else {
						if (${'cc_day'.$j.'_nontrad_hours_child'.$i} == 0 && $j < 6 && ${'cc_day'.$j.'_hours_child'.$i} < $ft_hours_max) { #weekday full-time traditional care:
							${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_sub'};
							${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m'};
							if ($in->{'ccdf'} == 1) {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_cost_m'};
							} else {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_cost_m'};
							}
						} elsif (${'cc_day'.$j.'_nontrad_hours_child'.$i} / ${'cc_day'.$j.'_hours_child'.$i} < .5 && ${'cc_day'.$j.'_hours_child'.$i} <= $extended_hours_max && $j < 6) {
							${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayfulltime_sub'};
							${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayfulltime_cost'};
							if ($in->{'ccdf'} == 1) {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_extendeddayfulltime_unsub'};
							} else {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_extendeddayfulltime_unsub'};
							}
						} else {
							#For all other scenarios, which may include child care need above 11 hours or 14 hours, we first assign them a nontraditional full time unit of care.
							${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalfulltime_sub'};
							${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalfulltime_cost'};
							if ($in->{'ccdf'} == 1) {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_nontraditionalfulltime_unsub'};
							} else {
								${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_nontraditionalfulltime_unsub'};
							}
							$remaining_hours = pos_sub(${'cc_day'.$j.'_hours_child'.$i},$ft_hours_max);
							$remaining_nontrad_hours = pos_sub(${'cc_day'.$j.'_nontrad_hours_child'.$i},$ft_hours_max);
						}
					}
						

					if ($remaining_hours > 0) { #child either (1) needs between 11 hours and 14 hours of care, either (a) on the weekend or (b) during the week when the majority of hours are nontraditional, or (2) needs more than 14 hours of care. Mathematically, the most additional care they will need is 10 more hours. So there is no possibility for a third unit of care.
						if ($remaining_hours < $ft_hours_min) {
							if ($remaining_nontrad_hours == 0 && $j < 6) { #weekday traditional care:
								${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_sub_pt'};
								${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_pt'};
								if ($in->{'ccdf'} == 1) {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_cost_m_pt'};
								} else {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_cost_m_pt'};
								}
							#We're not adding in before or after school here. If it's this many hours, it would have to be both before and after school. 
							} elsif ($remaining_nontrad_hours / $remaining_hours  < .5 && $j < 6) {
								${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayparttime_sub'};
								${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayparttime_cost'};
								if ($in->{'ccdf'} == 1) {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_extendeddayparttime_unsub'};
								} else {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_extendeddayparttime_unsub'};
								}
							} else {
								${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalparttime_sub'};
								${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalparttime_cost'};
								if ($in->{'ccdf'} == 1) {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_nontraditionalparttime_unsub'};
								} else {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_nontraditionalparttime_unsub'};
								}
							}
						} else {
							if ($remaining_nontrad_hours == 0 && $j < 6 && $remaining_hours < $ft_hours_max) { #weekday full-time traditional care:
								${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_sub'};
								${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m'};
								if ($in->{'ccdf'} == 1) {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_cost_m'};
								} else {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_cost_m'};
								}
							} elsif ($remaining_nontrad_hours /  $remaining_hours < .5 &&  $remaining_hours <= $extended_hours_max && $j < 6) {
								${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayfulltime_sub'};
								${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayfulltime_cost'};
								if ($in->{'ccdf'} == 1) {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_extendeddayfulltime_unsub'};
								} else {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_extendeddayfulltime_unsub'};
								}
							} else {
								${'spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalfulltime_sub'};
								${'fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalfulltime_cost'};
								if ($in->{'ccdf'} == 1) {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_continue_nontraditionalfulltime_unsub'};
								} else {
									${'unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_nontraditionalfulltime_unsub'};
								}
							}
						}
					}

							
					#summers:
					#identical to non-summer hours, just with summer variables:

					$remaining_hours = 0; #redefininig these at the beginning of each loop. Including day and child designations for this variable seems overly unnecesary and busy.
					$remaining_nontrad_hours = 0; 
					if (${'summer_cc_day'.$j.'_hours_child'.$i} == 0) {
						${'summer_spr_week_child' . $i} += 0;
						${'summer_unsub_week_child' . $i} += 0;
						${'summer_fullcost_week_child' . $i} += 0;
					} elsif (${'summer_cc_day'.$j.'_hours_child'.$i} < $ft_hours_min) {
						if (${'summer_cc_day'.$j.'_nontrad_hours_child'.$i} == 0 && $j < 6) { #weekday traditional care:
							${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_sub_pt'};
							${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_pt'};
							if ($in->{'ccdf'} == 1) {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_cost_m_pt'};
							} else {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_cost_m_pt'};
							}
						} elsif (${'summer_cc_day'.$j.'_nontrad_hours_child'.$i} / ${'summer_cc_day'.$j.'_hours_child'.$i} < .5 && $j < 6) {
							${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayparttime_sub'};
							${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayparttime_cost'};
							if ($in->{'ccdf'} == 1) {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_extendeddayparttime_unsub'};
							} else {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_extendeddayparttime_unsub'};
							}
						} else {
							${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalparttime_sub'};
							${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalparttime_cost'};
							if ($in->{'ccdf'} == 1) {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_nontraditionalparttime_unsub'};
							} else {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_nontraditionalparttime_unsub'};
							}
						}
					} else {
						if (${'summer_cc_day'.$j.'_nontrad_hours_child'.$i} == 0 && $j < 6 && ${'summer_cc_day'.$j.'_hours_child'.$i} < $ft_hours_max) { #weekday full-time traditional care:
							${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_sub'};
							${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m'};
							if ($in->{'ccdf'} == 1) {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_cost_m'};
							} else {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_cost_m'};
							}
						} elsif (${'summer_cc_day'.$j.'_nontrad_hours_child'.$i} / ${'summer_cc_day'.$j.'_hours_child'.$i} < .5 && ${'cc_day'.$j.'_hours_child'.$i} <= $extended_hours_max && $j < 6) {
							${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayfulltime_sub'};
							${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayfulltime_cost'};
							if ($in->{'ccdf'} == 1) {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_extendeddayfulltime_unsub'};
							} else {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_extendeddayfulltime_unsub'};
							}
						} else {
							#For all other scenarios, which may include child care need above 11 hours or 14 hours, we first assign them a nontraditional full time unit of care.
							${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalfulltime_sub'};
							${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalfulltime_cost'};
							if ($in->{'ccdf'} == 1) {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_nontraditionalfulltime_unsub'};
							} else {
								${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_nontraditionalfulltime_unsub'};
							}
							$remaining_hours = pos_sub(${'summer_cc_day'.$j.'_hours_child'.$i},$ft_hours_max);
							$remaining_nontrad_hours = pos_sub(${'summer_cc_day'.$j.'_nontrad_hours_child'.$i},$ft_hours_max);
						}
					}
						

					if ($remaining_hours > 0) { #child either (1) needs between 11 hours and 14 hours of care, either (a) on the weekend or (b) during the week when the majority of hours are nontraditional, or (2) needs more than 14 hours of care. Mathematically, the most additional care they will need is 10 more hours. So there is no possibility for a third unit of care.
						if ($remaining_hours < $ft_hours_min) {
							if ($remaining_nontrad_hours == 0 && $j < 6) { #weekday traditional care:
								${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_sub_pt'};
								${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_pt'};
								if ($in->{'ccdf'} == 1) {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_cost_m_pt'};
								} else {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_cost_m_pt'};
								}
							} elsif ($remaining_nontrad_hours / $remaining_hours  < .5 && $j < 6) {
								${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayparttime_sub'};
								${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayparttime_cost'};
								if ($in->{'ccdf'} == 1) {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_extendeddayparttime_unsub'};
								} else {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_extendeddayparttime_unsub'};
								}
							} else {
								${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalparttime_sub'};
								${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalparttime_cost'};
								if ($in->{'ccdf'} == 1) {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_nontraditionalparttime_unsub'};
								} else {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_nontraditionalparttime_unsub'};
								}
							}
						} else {
							if ($remaining_nontrad_hours == 0 && $j < 6 && $remaining_hours < $ft_hours_max) { #weekday full-time traditional care:
								${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m_sub'};
								${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_cost_m'};
								if ($in->{'ccdf'} == 1) {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_cost_m'};
								} else {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_cost_m'};
								}
							} elsif ($remaining_nontrad_hours /  $remaining_hours < .5 &&  $remaining_hours <= $extended_hours_max && $j < 6) {
								${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayfulltime_sub'};
								${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_extendeddayfulltime_cost'};
								if ($in->{'ccdf'} == 1) {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_extendeddayfulltime_unsub'};
								} else {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_extendeddayfulltime_unsub'};
								}
							} else {
								${'summer_spr_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalfulltime_sub'};
								${'summer_fullcost_week_child' . $i} += $in->{'child'.$i.'_withbenefit_nontraditionalfulltime_cost'};
								if ($in->{'ccdf'} == 1) {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_continue_nontraditionalfulltime_unsub'};
								} else {
									${'summer_unsub_week_child' . $i} += $in->{'child'.$i.'_nobenefit_nontraditionalfulltime_unsub'};
								}
							}
						}
					}

					#Last, we accumulate the total number of hours of child care a child needs per week. This is helpful for adjusting below due to overrides.
					${'cc_hours_wk_child'.$i} += ${'cc_day'.$j.'_hours_child'.$i} ;
					${'summer_cc_hours_wk_child'.$i} += ${'summer_cc_day'.$j.'_hours_child'.$i} ;

				}
				
				#Now we can total the child care costs for this child per year:
				${'unsub_child'.$i.'_nonsummer'} = (52-$summerweeks) * ${'unsub_week_child' . $i}; #This variable is ONLY important for whether is's equal to 0 or not, like the summer one below. It acts as a check for wehther the parents are paying copayments in the summer.
				${'unsub_child'.$i.'_summer'} = $summerweeks * ${'summer_unsub_week_child' . $i};
				${'spr_child' . $i} = (52-$summerweeks) * ${'spr_week_child' . $i} + $summerweeks * ${'summer_spr_week_child' . $i};
				${'unsub_child' . $i} = (52-$summerweeks) * ${'unsub_week_child' . $i} + $summerweeks * ${'summer_unsub_week_child' . $i};
				${'fullcost_child' . $i} = (52-$summerweeks) * ${'fullcost_week_child' . $i} + $summerweeks * ${'summer_fullcost_week_child' . $i};
				
				
				#ADJUSTING VARIABLES IF USERS HAVE ENTERED OVERRIDES:
				
				if ($in->{'ccdf'} == 0 && $in->{'child_care_nobenefit_estimate_source'} eq 'amt') {
					#Reset the unsub and fullcost variables, while keeping the spr variables the same as calculated above.
					${'unsub_child'.$i} = 0;
					${'fullcost_child'.$i} = 0;					
					if ($in->{'cc_nobenefit_payscale'.$i} eq 'hour') {	
						#If they are paying by the hour, we just calculate this against the number of hours in either current or future scenarios.
						${'unsub_child'.$i} = $in->{'child'.$i.'_nobenefit_amt_m'} * ((52-$summerweeks) * ${'cc_hours_wk_child'.$i} + $summerweeks * ${'summer_cc_hours_wk_child'.$i});
					} elsif ($in->{'cc_nobenefit_payscale'.$i} eq 'day') {
						#If the user selects the "day" payscale, we assume a flat rate for the course of a day.
						if ($out->{'scenario'} eq 'current' || ($out->{'scenario'} eq 'future' && ($in->{'future_scenario'} eq 'none' || $in->{'future_scenario'} eq 'wages'))) { 
							for(my $j=1; $j<=7; $j++) {							
								#As long as there are some hours in the day needed for child care, we count the day, not the hours.
								if ($in->{'day'.$j.'_hours_child' . $i} > 0) {
									${'unsub_child'.$i} += (52-$summerweeks) * $in->{'child'.$i.'_nobenefit_amt_m'} ;
								}
								if ($in->{'summerday'.$j.'_hours_child' . $i} > 0) {
									${'unsub_child'.$i} += $summerweeks * $in->{'child'.$i.'_nobenefit_amt_m'} ;
								}
							}
						} else {
							for(my $j=1; $j<=7; $j++) {							
								#As long as there are some hours in the day needed for child care, we count the day, not the hours.
								if ($in->{'day'.$j.'_future_hours_child' . $i} > 0) {
									${'unsub_child'.$i} += (52-$summerweeks) * $in->{'child'.$i.'_nobenefit_amt_m'} ;
								}
								if ($in->{'summerday'.$j.'_future_hours_child' . $i} > 0) {
									${'unsub_child'.$i} += $summerweeks * $in->{'child'.$i.'_nobenefit_amt_m'} ;
								}
							}							
						}
					} elsif ($in->{'cc_nobenefit_payscale'.$i} eq 'year' || $in->{'cc_nobenefit_payscale'.$i} eq 'month' || $in->{'cc_nobenefit_payscale'.$i} eq 'biweekly' || $in->{'cc_nobenefit_payscale'.$i} eq 'week'){
						#If a user selects any of these options, we assume that more hours of child care will proportionately increase their child care bill over this time period. Conceivably, they could be paying a flat rate for child care, but since we are modeling the possibility of increased costs, it seems prudent to assume some higher number for more care.
						if ($out->{'scenario'} eq 'current') {
							$in->{'cc_hours_wk_child'.$i.'_initial'} = ${'cc_hours_wk_child'.$i};
							$in->{'summer_cc_hours_wk_child'.$i.'_initial'} = ${'summer_cc_hours_wk_child'.$i};
							if ($in->{'cc_nobenefit_payscale'.$i} eq 'year') {
								$in->{'unsub_child' .$i.'_initial'} = $in->{'child'.$i.'_nobenefit_amt_m'};
							} elsif ($in->{'cc_nobenefit_payscale'.$i} eq 'month') {
								$in->{'unsub_child' .$i.'_initial'} = $in->{'child'.$i.'_nobenefit_amt_m'} * 12;
							} elsif ($in->{'cc_nobenefit_payscale'.$i} eq 'biweekly') {
								$in->{'unsub_child' .$i.'_initial'} = $in->{'child'.$i.'_nobenefit_amt_m'} * 26;
							} elsif ($in->{'cc_nobenefit_payscale'.$i} eq 'week') {
								$in->{'unsub_child' .$i.'_initial'} = $in->{'child'.$i.'_nobenefit_amt_m'} * 52;
							}
							${'unsub_child'.$i} = $in->{'unsub_child'.$i.'_initial'} 
						} else {
							if ($in->{'cc_hours_wk_child'.$i.'_initial'} + $in->{'summer_cc_hours_wk_child'.$i.'_initial'} == 0) {
								#This will only happen if a user enters a number for their cost of care using one of the non-daily, non-hourly options and does not enter any number of hours of care they're paying for. While we could try to find a complex way of preventing this nonsensical set of inputs in the PHP, it is both easier and more reactive to user entries if we just assume that the household will incur the same cost.
								${'unsub_child'.$i} = $in->{'unsub_child'.$i.'_initial'};
							} else {
								${'unsub_child'.$i} = $in->{'unsub_child'.$i.'_initial'} * ((52-$summerweeks) * ${'cc_hours_wk_child'.$i} + $summerweeks * ${'summer_cc_hours_wk_child'.$i}) / ((52-$summerweeks) * $in->{'cc_hours_wk_child'.$i.'_initial'} + $summerweeks * $in->{'summer_cc_hours_wk_child'.$i.'_initial'});
							}
						}
					}
					
					${'fullcost_child'.$i} = ${'unsub_child'.$i}; #Important for the alternate CCDF scenario.
					
				} elsif ($in->{'ccdf'} == 1 && $in->{'child_care_continue_estimate_source'} eq 'amt') {
				
					#Reset the unsub variables, while keeping the spr and fullcost variables the same as calculated above. The latter two are important for calculating costs when the household receives CCDF. There is some risk here of a family understating the alternative payment they would be making if they started not receiving CCDF, since the unsub variables are also used in the ccdf code, such as if the unsub values all equal 0, there is no CCDF given to the family, and when the CCDF payment amounts exceed the unsub total, the calclator defers to the unsub total. Perhaps the question could be phrased as something like "In the absence of CCDF funding, how much would you expect to pay...". But this doesn't seem too misleading -- if the family has access to less expensive child care, that they trust, there doesn't seem to be a great reason to default to more expensive care. So using this question to allow users to establish a ceiling amount for child care costs seems okay.
					${'unsub_child'.$i} = 0;
					if ($in->{'cc_continue_payscale'.$i} eq 'hour') {	
						#If they are paying by the hour, we just calculate this against the number of hours in either current or future scenarios.
						${'unsub_child'.$i} = $in->{'child'.$i.'_continue_amt_m'} * ((52-$summerweeks) * ${'cc_hours_wk_child'.$i} + $summerweeks * ${'summer_cc_hours_wk_child'.$i});
					} elsif ($in->{'cc_continue_payscale'.$i} eq 'day') {
						#If the user selects the "day" payscale, we assume a flat rate for the course of a day.
						if ($out->{'scenario'} eq 'current' || ($out->{'scenario'} eq 'future' && ($in->{'future_scenario'} eq 'none' || $in->{'future_scenario'} eq 'wages'))) { 
							for(my $j=1; $j<=7; $j++) {							
								#As long as there are some hours in the day needed for child care, we count the day, not the hours.
								if ($in->{'day'.$j.'_hours_child' . $i} > 0) {
									${'unsub_child'.$i} += (52-$summerweeks) * $in->{'child'.$i.'_continue_amt_m'} ;
								}
								if ($in->{'summerday'.$j.'_hours_child' . $i} > 0) {
									${'unsub_child'.$i} += $summerweeks * $in->{'child'.$i.'_continue_amt_m'} ;
								}
							}
						} else {
							for(my $j=1; $j<=7; $j++) {							
								#As long as there are some hours in the day needed for child care, we count the day, not the hours.
								if ($in->{'day'.$j.'_future_hours_child' . $i} > 0) {
									${'unsub_child'.$i} += (52-$summerweeks) * $in->{'child'.$i.'_continue_amt_m'} ;
								}
								if ($in->{'summerday'.$j.'_future_hours_child' . $i} > 0) {
									${'unsub_child'.$i} += $summerweeks * $in->{'child'.$i.'_continue_amt_m'} ;
								}
							}							
						}
					} elsif ($in->{'cc_continue_payscale'.$i} eq 'year' || $in->{'cc_continue_payscale'.$i} eq 'month' || $in->{'cc_continue_payscale'.$i} eq 'biweekly' || $in->{'cc_continue_payscale'.$i} eq 'week') {
						#If a user selects any of these options, we assume that more hours of child care will proportionately increase their child care bill over this time period. Conceivably, they could be paying a flat rate for child care, but since we are modeling the possibility of increased costs, it seems prudent to assume some higher number for more care.
						if ($out->{'scenario'} eq 'current') {
							$in->{'cc_hours_wk_child'.$i.'_initial'} = ${'cc_hours_wk_child'.$i};
							$in->{'summer_cc_hours_wk_child'.$i.'_initial'} = ${'summer_cc_hours_wk_child'.$i};
							if ($in->{'cc_continue_payscale'.$i} eq 'year') {
								$in->{'unsub_child' .$i.'_initial'} = $in->{'child'.$i.'_continue_amt_m'};
							} elsif ($in->{'cc_continue_payscale'.$i} eq 'month') {
								$in->{'unsub_child' .$i.'_initial'} = $in->{'child'.$i.'_continue_amt_m'} * 12;
							} elsif ($in->{'cc_continue_payscale'.$i} eq 'biweekly') {
								$in->{'unsub_child' .$i.'_initial'} = $in->{'child'.$i.'_continue_amt_m'} * 26;
							} elsif ($in->{'cc_continue_payscale'.$i} eq 'week') {
								$in->{'unsub_child' .$i.'_initial'} = $in->{'child'.$i.'_continue_amt_m'} * 52;
							}
							${'unsub_child'.$i} = $in->{'unsub_child'.$i.'_initial'} 
						} else {

							if ($in->{'cc_hours_wk_child'.$i.'_initial'} + $in->{'summer_cc_hours_wk_child'.$i.'_initial'} == 0) {
								#This will only happen if a user enters a number for their cost of care using one of the non-daily, non-hourly options and does not enter any number of hours of care they're paying for. While we could try to find a complex way of preventing this nonsensical set of inputs in the PHP, it is both easier and more reactive to user entries if we just assume that the household will incur the same cost.
								${'unsub_child'.$i} = $in->{'unsub_child'.$i.'_initial'};
							} else {
								${'unsub_child'.$i} = $in->{'unsub_child'.$i.'_initial'} * ((52-$summerweeks) * ${'cc_hours_wk_child'.$i} + $summerweeks * ${'summer_cc_hours_wk_child'.$i}) / ((52-$summerweeks) * $in->{'cc_hours_wk_child'.$i.'_initial'} + $summerweeks * $in->{'summer_cc_hours_wk_child'.$i.'_initial'});
							}
						}
					}				
				}			
			}
		}
		$unsub_nonsummer = $unsub_child1_nonsummer + $unsub_child2_nonsummer + $unsub_child3_nonsummer + $unsub_child4_nonsummer  + $unsub_child5_nonsummer;
		$unsub_summer = $unsub_child1_summer + $unsub_child2_summer + $unsub_child3_summer + $unsub_child4_summer  + $unsub_child5_summer;
		(52-$summerweeks) * ${'unsub_week_child' . $i} ;
		$unsub_summer = $summerweeks * ${'summer_unsub_week_child' . $i};

		# Now we total up all these rates by child.
		$spr_all_children = $spr_child1 + $spr_child2 + $spr_child3 + $spr_child4 + $spr_child5; 			
		$unsub_all_children = $unsub_child1 + $unsub_child2 + $unsub_child3 + $unsub_child4 + $unsub_child5;
		$fullcost_all_children = $fullcost_child1 + $fullcost_child2 + $fullcost_child3 + $fullcost_child4 + $fullcost_child5;
		#We will use these output to determine child care rates in the ccdf code, after seeing if families are eligible for CCDF and what subsidies they might receive through that program.
		$child_care_expenses = $unsub_all_children;
		$child_care_expenses_m = $child_care_expenses / 12; #We establish this here and then assign it to the output set so that the TANF code can run the first time. It gets recalculated in ccdf.
		# }	
	}
	
	#debugging:
	foreach my $debug (qw(spr_all_children unsub_all_children fullcost_all_children spr_week_child1 child_care_expenses unsub_child1  fullcost_child1)) {
		print $debug.": ".${$debug}."\n";
	}
	
	# outputs
    foreach my $name (qw(spr_all_children unsub_all_children spr_child1 spr_child2 spr_child3 spr_child4 spr_child5 unsub_child1 unsub_child2 unsub_child3 unsub_child4 unsub_child5 fullcost_all_children fullcost_child1 fullcost_child2 fullcost_child3  fullcost_child4 fullcost_child5 child_care_expenses_m child_care_expenses cc_hours_wk_child1  summer_unsub_week_child1 unsub_week_child1 summer_cc_hours_wk_child1 prek_age_min prek_age_max unsub_nonsummer unsub_summer ft_hours_min
	cc_day1_hours_child1 
	cc_day2_hours_child1 
	cc_day3_hours_child1 
	cc_day4_hours_child1 
	cc_day5_hours_child1 
	cc_day6_hours_child1 
	cc_day7_hours_child1 
	summer_cc_day1_hours_child1 
	summer_cc_day2_hours_child1 
	summer_cc_day3_hours_child1 
	summer_cc_day4_hours_child1 
	summer_cc_day5_hours_child1 
	summer_cc_day6_hours_child1 
	summer_cc_day7_hours_child1 
	cc_day1_hours_child2 
	cc_day2_hours_child2 
	cc_day3_hours_child2 
	cc_day4_hours_child2 
	cc_day5_hours_child2 
	cc_day6_hours_child2 
	cc_day7_hours_child2 
	summer_cc_day1_hours_child2 
	summer_cc_day2_hours_child2 
	summer_cc_day3_hours_child2 
	summer_cc_day4_hours_child2 
	summer_cc_day5_hours_child2 
	summer_cc_day6_hours_child2 
	summer_cc_day7_hours_child2 
	cc_day1_hours_child3 
	cc_day2_hours_child3 
	cc_day3_hours_child3 
	cc_day4_hours_child3 
	cc_day5_hours_child3 
	cc_day6_hours_child3 
	cc_day7_hours_child3 
	summer_cc_day1_hours_child3 
	summer_cc_day2_hours_child3 
	summer_cc_day3_hours_child3 
	summer_cc_day4_hours_child3 
	summer_cc_day5_hours_child3 
	summer_cc_day6_hours_child3 
	summer_cc_day7_hours_child3 
	cc_day1_hours_child4 
	cc_day2_hours_child4 
	cc_day3_hours_child4 
	cc_day4_hours_child4 
	cc_day5_hours_child4 
	cc_day6_hours_child4 
	cc_day7_hours_child4 
	summer_cc_day1_hours_child4 
	summer_cc_day2_hours_child4 
	summer_cc_day3_hours_child4 
	summer_cc_day4_hours_child4 
	summer_cc_day5_hours_child4 
	summer_cc_day6_hours_child4 
	summer_cc_day7_hours_child4 
	cc_day1_hours_child5 
	cc_day2_hours_child5 
	cc_day3_hours_child5 
	cc_day4_hours_child5 
	cc_day5_hours_child5 
	cc_day6_hours_child5 
	cc_day7_hours_child5 
	summer_cc_day1_hours_child5 
	summer_cc_day2_hours_child5 
	summer_cc_day3_hours_child5 
	summer_cc_day4_hours_child5 
	summer_cc_day5_hours_child5 
	summer_cc_day6_hours_child5 
	summer_cc_day7_hours_child5
	)) { 
       $out->{$name} = ${$name};
    }
	
}
1;