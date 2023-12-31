#=============================================================================#
#  Child Care Module -- 2021 NH
#=============================================================================#
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

	our $summerweeks = 9; #For now, we're using this universally, based on NH's school calendar, but we could change this if we find that school calendars may differ markedly based on geography.
	our $schoolday_length = 6; #hours of school day. This is basically 6 hours per day for non-kindergarteners, as mandated by state law, per https://casetext.com/regulation/new-hampshire-administrative-code/title-ed-board-of-education/chapter-ed-300-administration-of-minimum-standards-in-public-schools/part-ed-306-minimum-standards-for-public-school-approval/section-ed-30618-school-year. Additionally, per https://www.nhpr.org/post/more-nh-kids-headed-full-day-kindergarten#stream/0, about 90% of schoool districts offer full-day Kindergarten, so we can make the assumption that every family that needs it can get it.
	# our $afterschool_length = 3; #hours of publicly provided afterschool, e.g. federal or state-funded Out-of-School-Time programs. 3 hours is a typical afterschool length (3pm-6pm). It does not appear that New Hampshire has an afterschool program outside of CCDF funding, though. But keeping this variable in here in case of a policy change. This variable will be important if adapting this code to jurisdictions that do have a public afterschool program, like DC, tied to its OSTP program and associated ostp flag variable. 
	
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

	our $schoolage_care_child1 = 0;
	our $schoolage_care_child2 = 0;
	our $schoolage_care_child3 = 0;
	our $schoolage_care_child4 = 0;
	our $schoolage_care_child5 = 0;

	our $max_headstart_length = 10; #This is the maximum number of hours that a Head Start provider in New Hampshire offers child care services. Like the other Head Start variables for suggesting Head Start as a potential solution to benefit cliffs, we are factoring in the most expansive version of this program.
	our $min_headstart_age_min = 2; #This is the minimum age for entry for at least one Head Start provider in NH.
	our $max_headstart_age_max = 4; #All NH Head Start programs have a maximum HS age of 4.
	our $headstart_summer = 1; #This is a flag indicating that Head Start is offered in summer, again modeling the most expansive program in NH. .

	our $max_earlyheadstart_length  = 8;
	our $min_earlyheadstart_age_min = 0;
	our	$max_earlyheadstart_age_max = 3;
	our	$earlyheadstart_summer = 1;
	
	# 1. DETERMINE NEED FOR CARE 
	#

	if ($in->{'children_under13'} == 0) { 
		$unsub_all_children = 0;
		$spr_all_children = 0;
	} else  {
		
		# NOTES, INCLUDING NOTES FOR ADJUSTMENTS: 
		# 1. The market rate study that informs the market rate costs we are using in this code as of 8/2020 details just the rates for LICENSED child care. This seems distinct from the "family, friend, and neighbor" settings that Marti Ilg mentioned as increasingly prevalent in COVID. So we should modle Family Friend and Neighbor Care, which Marti mentioned specifically in response to a question about child care on weekends, but we need rates for those. How do we get these rate? Should we just use the SPRs for license-exempt child care?
		# 2. NOTE FOR CLARIFICATION: The group labeled "Family, Friend, and Neighbor" providers are a subset (possibly the complete set) of license-exempt child care providres. See http://nh.childcareaware.org/wp-content/uploads/2018/09/2CDB-Rule-He-C-6917.pdf. 
		# 3. The market rate study for New Hampshire also does not differentiate between geographic areas for different child care settings. They do provide average and median costs of care across New Hampshire, so conceivably we could weight these by those,

				
		# 
		
		#NOTE ON SCHOOL-AGE CHILDREN RATES:
		#The latest market rate study in New Hampshire included separate market rates for before school, after school, and before&aftercare for school age children. So that's why school-age rates are included as inputs in drop-downs on Step 5, to capture that variation. It also seemed best to ask the number of child care hours per day that the family needs, as well as an option about nontraditional care outside of traditional before/aftercare for school-age children, since parents might need child care at those times. However, the market rate study did not cover market rates for care during weekends or during late nights / early mornings -- the text of the report indicates that this exclusion is a shortcoming of both its own study as well the state of child care in New Hampshire, where it can be difficult to find care during these times. To capture weekend care or nontradtional care for school-age children, estimates for part-time and full-time care for school-age children are based on  other figures in that market rate study (the average of the before&aftercare rate and the rates for part-time care and full-time care the oldest age group of non-schoolchildren, respectively). Because the above approximation includes both a part-time rate and a full-time rate for care during these nontraditional hours for NH schoolchildren, the questions about hours per day are still needed to determine whether the part-time rate (<30 hours per week) or full-time rate (>30 hours/week) is the applicable one per each scenario modeled. This is just for the "calculator estimates"; if users are entering their own rates, the before/aftercare distinction won't matter, since the user-entered rates are the ones that are important.
		
		# Legacy code that could be reinstituted, depending on interest. Belwo is a breakdown of how Head Start availabiltiy differs, genreally, in New Hampshire, based on residence id. We use the most expansive of these policies for the "max" and "min" Head Start and Early Head Start variables defined in the active code above.

		#For children 1-5 
						   
		# if ($in->{'headstart'} == 1) {
			#NEED TO USE LOOKUP SOMEHOW HERE to locate headstart lengths and early headstart lengths, per town or county, as well as Head Start eligibility limits, which can be up to 100% poverty but can also be higher than that depending on child needs or market demand. Emma is working on these variables. Let's call them these for now:
			#$headstart_length = qw(0 6 8 8 6 6 6 10 6 10 8 8 10 10 6 6 8 8 8 8 10 6 10 8 8 8 6 6 6 10 8 8 8 10 8 8 8 10 6 8 6 8 6 8 10 6 6 6 8 8 8 6 8 6 8 6 8 8 6 10 10 10 10 8 8 8 6 6 8 6 6 10 8 8 8 8 8 10 6 8 8 10 6 6 10 8 6 8 10 6 6 6 10 8 6 8 6 10 10 8 10 8 8 8 10 10 10 10 8 6 8 8 8 6 6 10 6 8 10 6 6 10 8 6 8 6 10 8 10 6 8 8 6 8 6 6 8 8 10 8 8 10 6 8 8 8 10 6 8 10 6 6 8 10 6 10 6 8 10 8 6 8 10 8 10 6 10 10 6 6 10 6 6 10 10 10 6 10 10 6 8 10 10 8 8 8 8 10 6 10 8 8 8 6 6 10 8 10 8 10 6 6 6 6 6 8 10 10 6 6 10 8 8 10 8 10 8 6 10 6 8 8 6 6 8 10 8 8 6 6 6 6 6 8 10 8 8 6 6 8 6 8 6 6 8 6 8 10 6 8 8 6 8 6 10 6 10 10 8 8)[$in->{'residence'}];
			#$headstart_age_min = qw(0 3 2 2 3 3 3 3 3 3 2 2 3 3 3 3 2 2 2 2 3 3 3 2 2 2 3 3 3 3 2 2 2 3 2 2 2 3 3 2 3 2 3 2 3 3 3 3 2 2 2 3 2 3 2 3 2 2 3 3 3 3 3 2 2 2 3 3 2 3 3 3 2 2 2 2 2 3 3 2 2 3 3 3 3 2 3 2 3 3 3 3 3 2 3 2 3 3 3 2 3 2 2 2 3 3 3 3 2 3 2 2 2 3 3 3 3 2 3 3 3 3 2 3 2 3 3 2 3 3 2 2 3 2 3 3 2 2 3 2 2 3 3 2 2 2 3 3 2 3 3 3 2 3 3 3 3 2 3 2 3 2 3 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 2 3 3 2 2 2 2 3 3 3 2 2 2 3 3 3 2 3 2 3 3 3 3 3 3 2 3 3 3 3 3 2 2 3 2 3 2 3 3 3 2 2 3 3 2 3 2 2 3 3 3 3 3 2 3 2 2 3 3 2 3 2 3 3 2 3 2 3 3 2 2 3 2 3 3 3 3 3 2 2)[$in->{'residence'}];
			#$headstart_age_max = 4; #All NH Head Start programs have a maximum HS age of 4.
			#$headstart_summer = qw(0 0 0 0 0 0 0 1 0 1 0 0 1 1 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 1 0 0 1 0 0 0 1 0 0 0 1 0 0 0 0 1 1 0 1 0 0 0 1 1 1 1 0 0 0 0 0 0 0 1 0 0 1 0 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 1 0 0 0 1 0 1 0 0 1 0 0 0 1 0 1 0 1 1 0 0 1 0 0 1 1 1 0 1 1 0 0 1 1 0 0 0 0 1 0 1 0 0 0 0 0 1 0 1 0 1 0 0 0 0 0 0 1 1 0 0 1 0 0 1 0 1 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 1 1 0 0)[$in->{'residence'}]; #This will be either 1 or 0, indicating whether the program runs during the summer.
		#}
		#if ($in->{'earlyheadstart'} == 1) {
			#NEED TO USE LOOKUP SOMEHOW HERE  call to locate headstart lengths and early headstart lengths, per town or county, as well as Head Start eligibility limits, which can be up to 100% poverty but can also be higher than that depending on child needs or market demand. Emma is working on these variables. Let's call them these for now:
			#$earlyheadstart_length  = qw(0 -1 -1 -1 8 -1 8 8 8 8 -1 -1 8 8 8 8 -1 -1 -1 -1 8 8 8 -1 -1 -1 8 8 8 8 -1 -1 -1 8 -1 -1 -1 8 8 -1 8 -1 -1 -1 8 -1 8 -1 -1 -1 -1 8 -1 -1 -1 -1 -1 -1 8 8 8 8 8 -1 -1 -1 8 -1 -1 8 8 8 -1 -1 -1 -1 -1 8 8 -1 -1 8 8 -1 8 -1 8 -1 8 8 8 -1 8 -1 -1 -1 -1 8 8 -1 8 -1 -1 -1 8 8 8 8 -1 -1 -1 -1 -1 8 8 8 -1 -1 8 8 8 8 -1 -1 -1 -1 8 -1 8 8 -1 -1 -1 -1 8 -1 -1 -1 8 -1 -1 8 8 -1 -1 -1 8 8 -1 8 -1 -1 -1 8 8 8 8 -1 8 -1 8 -1 8 -1 8 -1 8 8 8 8 8 8 8 8 8 8 -1 8 8 8 -1 8 8 -1 -1 -1 -1 8 8 8 -1 -1 -1 8 -1 8 -1 8 -1 8 -1 -1 8 8 -1 -1 8 8 8 8 8 -1 -1 8 -1 8 -1 8 8 -1 -1 -1 -1 8 -1 8 -1 -1 -1 -1 -1 8 -1 -1 8 -1 -1 8 -1 -1 -1 -1 -1 8 -1 -1 -1 8 8 -1 -1 -1 -1 8 8 -1 8 8 -1 -1)[$in->{'residence'}]; #If earlyheadstart_length equals -1, there is no Early Head Start program listed for the county where the family lives.
			#$earlyheadstart_age_min = qw(0 -1 -1 -1 0 -1 0 0 0 0 -1 -1 0 0 0 0 -1 -1 -1 -1 0 0 0 -1 -1 -1 0 0 0 0 -1 -1 -1 0 -1 -1 -1 0 0 -1 0 -1 -1 -1 0 -1 0 -1 -1 -1 -1 0 -1 -1 -1 -1 -1 -1 0 0 0 0 0 -1 -1 -1 0 -1 -1 0 0 0 -1 -1 -1 -1 -1 0 0 -1 -1 0 0 -1 0 -1 0 -1 0 0 0 -1 0 -1 -1 -1 -1 0 0 -1 0 -1 -1 -1 0 0 0 0 -1 -1 -1 -1 -1 0 0 0 -1 -1 0 0 0 0 -1 -1 -1 -1 0 -1 0 0 -1 -1 -1 -1 0 -1 -1 -1 0 -1 -1 0 0 -1 -1 -1 0 0 -1 0 -1 -1 -1 0 0 0 0 -1 0 -1 0 -1 0 -1 0 -1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 -1 0 0 -1 -1 -1 -1 0 0 0 -1 -1 -1 0 -1 0 -1 0 -1 0 -1 -1 0 0 -1 -1 0 0 0 0 0 -1 -1 0 -1 0 -1 0 0 -1 -1 -1 -1 0 -1 0 -1 -1 -1 -1 -1 0 -1 -1 0 -1 -1 0 -1 -1 -1 -1 -1 0 -1 -1 -1 0 0 -1 -1 -1 -1 0 0 -1 0 0 -1 -1)[$in->{'residence'}];
			#$earlyheadstart_age_max = qw(0 -1 -1 -1 3 -1 3 3 3 3 -1 -1 3 3 3 3 -1 -1 -1 -1 3 3 3 -1 -1 -1 3 3 3 3 -1 -1 -1 3 -1 -1 -1 3 3 -1 3 -1 -1 -1 3 -1 3 -1 -1 -1 -1 3 -1 -1 -1 -1 -1 -1 3 3 3 3 3 -1 -1 -1 3 -1 -1 3 3 3 -1 -1 -1 -1 -1 3 3 -1 -1 3 3 -1 3 -1 3 -1 3 3 3 -1 3 -1 -1 -1 -1 3 3 -1 3 -1 -1 -1 3 3 3 3 -1 -1 -1 -1 -1 3 3 3 -1 -1 3 3 3 3 -1 -1 -1 -1 3 -1 3 3 -1 -1 -1 -1 3 -1 -1 -1 3 -1 -1 3 3 -1 -1 -1 3 3 -1 3 -1 -1 -1 3 3 3 3 -1 3 -1 3 -1 3 -1 3 -1 3 3 3 3 3 3 3 3 3 3 -1 3 3 3 -1 3 3 -1 -1 -1 -1 3 3 3 -1 -1 -1 3 -1 3 -1 3 -1 3 -1 -1 3 3 -1 -1 3 3 3 3 3 -1 -1 3 -1 3 -1 3 3 -1 -1 -1 -1 3 -1 3 -1 -1 -1 -1 -1 3 -1 -1 3 -1 -1 3 -1 -1 -1 -1 -1 3 -1 -1 -1 3 3 -1 -1 -1 -1 3 3 -1 3 3 -1 -1)[$in->{'residence'}];
			#$earlyheadstart_summer = qw(0 -1 -1 -1 1 -1 1 1 1 1 -1 -1 1 1 1 1 -1 -1 -1 -1 1 1 1 -1 -1 -1 1 1 1 1 -1 -1 -1 1 -1 -1 -1 1 1 -1 1 -1 -1 -1 1 -1 1 -1 -1 -1 -1 1 -1 -1 -1 -1 -1 -1 1 1 1 1 1 -1 -1 -1 1 -1 -1 1 1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 1 -1 1 -1 1 -1 1 1 1 -1 1 -1 -1 -1 -1 1 1 -1 1 -1 -1 -1 1 1 1 1 -1 -1 -1 -1 -1 1 1 1 -1 -1 1 1 1 1 -1 -1 -1 -1 1 -1 1 1 -1 -1 -1 -1 1 -1 -1 -1 1 -1 -1 1 1 -1 -1 -1 1 1 -1 1 -1 -1 -1 1 1 1 1 -1 1 -1 1 -1 1 -1 1 -1 1 1 1 1 1 1 1 1 1 1 -1 1 1 1 -1 1 1 -1 -1 -1 -1 1 1 1 -1 -1 -1 1 -1 1 -1 1 -1 1 -1 -1 1 1 -1 -1 1 1 1 1 1 -1 -1 1 -1 1 -1 1 1 -1 -1 -1 -1 1 -1 1 -1 -1 -1 -1 -1 1 -1 -1 1 -1 -1 1 -1 -1 -1 -1 -1 1 -1 -1 -1 1 1 -1 -1 -1 -1 1 1 -1 1 1 -1 -1)[$in->{'residence'}]; #This will be either 1 or 0, indicating whether the program runs during the summer.
		#}
		
		
		for(my $i=1; $i<=5; $i++) {

			if ($in->{'child'.$i.'_age'} >=13 || $in->{'child'.$i.'_age'} == -1) {
				${'spr_child' . $i} = 0;
				${'unsub_child' . $i} = 0;
				${'fullcost_child' . $i} = 0;
				print "debugcc1 child $i \n";

			} else { 
				#We first do a little debugging, to make sure we have values for each of the hour-day variables we need to calculate total child care needs and costs.
				for(my $j=1; $j<=7; $j++) {							
					$in->{'day'.$j.'_hours_child'.$i} = $in->{'day'.$j.'_hours_child'.$i} // 0;
					#I don't think this is necessary anymore, given the JavaScript controls that prevent empty entries.
					if ($in->{'day'.$j.'_hours_child'.$i} eq '') {
						$in->{'day'.$j.'_hours_child'.$i} = 0;
					}
					
					#We need to make summer hours the same as reguar hours in the case of families who do not have any children under 5.
					if ($in->{'schoolage_children_under13'} == 0) {
						$in->{'summerday'.$j.'_hours_child'.$i} = $in->{'day'.$j.'_hours_child'.$i};					
						$in->{'summerday'.$j.'_future_hours_child'.$i} = $in->{'day'.$j.'_future_hours_child'.$i} // 0;
					} else {
						#I don't think this is necessary anymore, given the JavaScript controls that prevent empty entries.
						$in->{'summerday'.$j.'_hours_child'.$i} = $in->{'summerday'.$j.'_hours_child'.$i} // 0;					
						if ($in->{'summerday'.$j.'_hours_child'.$i} eq '') {
							$in->{'summerday'.$j.'_hours_child'.$i} = 0;
						}
					}
				}

				#We calculate the total hours per child, for both the non-summer and summer weeks:
				
				#We have to see which set of child care inputs to use -- the if-block below orients these calculations to the "current" child care schedules, and also uses those same schedules if child care doesn't change in future iterations.
				if ($out->{'scenario'} eq 'current' || ($out->{'scenario'} eq 'future' && ($in->{'future_scenario'} eq 'none' || $in->{'future_scenario'} eq 'wages'))) { 
			
					${'cc_hours_wk_child' . $i} = $in->{'day1_hours_child' . $i} + $in->{'day2_hours_child' . $i} + $in->{'day3_hours_child' . $i} + $in->{'day4_hours_child' . $i} + $in->{'day5_hours_child' . $i} + $in->{'day6_hours_child' . $i} + $in->{'day7_hours_child' . $i};

					${'summer_cc_hours_wk_child' . $i} = $in->{'summerday1_hours_child' . $i} + $in->{'summerday2_hours_child' . $i} + $in->{'summerday3_hours_child' . $i} + $in->{'summerday4_hours_child' . $i} + $in->{'summerday5_hours_child' . $i} + $in->{'summerday6_hours_child' . $i} + $in->{'summerday7_hours_child' . $i};

					${'schoolage_care_child'.$i} = $in->{'schoolage_care_initial_child'.$i};

				} else {

					${'cc_hours_wk_child' . $i} = $in->{'day1_future_hours_child' . $i} + $in->{'day2_future_hours_child' . $i} + $in->{'day3_future_hours_child' . $i} + $in->{'day4_future_hours_child' . $i} + $in->{'day5_future_hours_child' . $i} + $in->{'day6_future_hours_child' . $i} + $in->{'day7_future_hours_child' . $i};

					${'summer_cc_hours_wk_child' . $i} = $in->{'summerday1_future_hours_child' . $i} + $in->{'summerday2_future_hours_child' . $i} + $in->{'summerday3_future_hours_child' . $i} + $in->{'summerday4_future_hours_child' . $i} + $in->{'summerday5_future_hours_child' . $i} + $in->{'summerday6_future_hours_child' . $i} + $in->{'summerday7_future_hours_child' . $i};

					${'schoolage_care_child'.$i} = $in->{'schoolage_care_future_child'.$i};
					
				}


				#INCORPORATING HEAD START AND EARLY HEAD START SCENARIOS

				#For the Head Start and Early Head Start scenarios, we reduce hours of child care by the most expansive program(s) available in NH. We redefine teh child care hours totals here. While we coudl reduce these inputs above, we do not want to replace the inputs with lower values. We could also make this cleaner if we saved local day/hour variables, but that would signify the creation and tracking of a lot more variables. Easier this way. 
				if ($in->{'headstart'} == 0 && $out->{'headstart_alt'} == 1 && $in->{'child'.$i.'_age'} >= $min_headstart_age_min && $in->{'child'.$i.'_age'} <= $max_headstart_age_max && ($out->{'earnings'} + $out->{'tanf_recd '} + $out->{'ssi_recd'} + $out->{'interest'} + $out->{'child_support_recd'} + $in->{'alimony_paid_m'} * 12 + $out->{'gift_income'} + &pos_sub($out->{'ui_recd_m'}, $out->{'fpuc_recd'}/12) < $in->{'fpl'} || $out->{'tanf_recd'} > 0 || $out->{'ssi_recd'} > 0)) { #We only test this if the user has indicated they are NOT currently using Head Start services. We're modeling the potential benefits of doing so. TANF and SSI provide categorical eligibility here. Since this reduces child care need, that's a potential loop, since TANF receipt is also partially dependent on child care costs. This is why we first set tanf_recd to 0 in the parent_earnings code, then run the child care code first (with tanf_recd equal to 0), then tun TANF to determine TANF eligibility, then run this code again, in case TANF receipt is now positive. If this scenario will result in a household being eligible for Head Start, we model the below reductions. At this point, since we are modeling entrance eligibility standards for Head Start (unlike most other codes here), we are modeling that the family has gained eligibility for Head Start and that the child is enrolled. This may reduce child care need, possibly to the point that the family no longer is eligible for TANF (if child care costs contributed to their TANF eligibility), but the possibility that they no longer would satisfy entrance eligibiltiy guidelines for Head Start is moot, since they are already enrolled in Head Start. 
				
				# Children from birth to age five who are from families with incomes below the poverty guidelines are eligible for Head Start and Early Head Start services. Children from homeless families, and families receiving public assistance such as TANF or SSI are also eligible. Foster children are eligible regardless of their foster family’s income. (from https://eclkc.ohs.acf.hhs.gov/eligibility-ersea/article/poverty-guidelines-determining-eligibility-participation-head-start-programs)
				
				#Definition of Income for Head Start defined here: https://eclkc.ohs.acf.hhs.gov/policy/45-cfr-chap-xiii/1305-2-terms. Refers also to census definition from 1992, which is very inclusive.

					if ($in->{'future_scenario'} eq 'none' || $in->{'future_scenario'} eq 'wages') { #This is always going to be for the future scenario.
						${'cc_hours_wk_child' . $i} = pos_sub($in->{'day1_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'day2_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'day3_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'day4_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'day5_hours_child' . $i}, $max_headstart_length) + $in->{'day6_hours_child' . $i} + $in->{'day7_hours_child' . $i};
						
						if ($headstart_summer == 1) { #This will always be true since this variable is set to 1 in this same code. But keeping it here in case someone using this code decides against buiding in the avaialility of Head Start in the summer for this potential scenario.
							${'summer_cc_hours_wk_child' . $i} = pos_sub($in->{'summerday1_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'summerday2_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'summerday3_hours_child' . $i}, $max_headstart_length)  + pos_sub($in->{'summerday4_hours_child' . $i}, $max_headstart_length)  + pos_sub($in->{'summerday5_hours_child' . $i}) + $in->{'summerday6_hours_child' . $i} + $in->{'summerday7_hours_child' . $i};
						}
					} else {
						${'cc_hours_wk_child' . $i} = pos_sub($in->{'day1_future_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'day2_future_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'day3_future_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'day4_future_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'day5_future_hours_child' . $i}) + $in->{'day6_future_hours_child' . $i} + $in->{'day7_future_hours_child' . $i};

						if ($headstart_summer == 1) { #Same as above, this will always be true since this variable is set to 1 in this same code. But keeping it here in case someone using this code decides against buiding in the avaialility of Head Start in the summer for this potential scenario.
							${'summer_cc_hours_wk_child' . $i} = pos_sub($in->{'summerday1_future_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'summerday2_future_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'summerday3_future_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'summerday4_future_hours_child' . $i}, $max_headstart_length) + pos_sub($in->{'summerday5_future_hours_child' . $i}) + $in->{'summerday6_future_hours_child' . $i} + $in->{'summerday7_future_hours_child' . $i};
						}
					}
				}		
				
				#We do the same exercise as above for the "Early Head Start" alternative scenario:
				if ($in->{'earlyheadstart'} == 0 && $out->{'earlyheadstart_alt'} == 1 && $in->{'child'.$i.'_age'} >= $min_earlyheadstart_age_min && $in->{'child'.$i.'_age'} <= $max_earlyheadstart_age_max && ($out->{'earnings'} + $out->{'tanf_recd '} + $out->{'ssi_recd'} + $out->{'interest'} + $out->{'child_support_recd'} + $in->{'alimony_paid_m'} * 12 + $out->{'gift_income'} + &pos_sub($out->{'ui_recd_m'}, $out->{'fpuc_recd'}/12) < $in->{'fpl'} || $out->{'tanf_recd'} > 0 || $out->{'ssi_recd'} > 0)) { #Same considerations and rules apply for entry into Early Head Start programs.
				
					if ($in->{'future_scenario'} eq 'none' || $in->{'future_scenario'} eq 'wages') { 
						${'cc_hours_wk_child' . $i} = pos_sub($in->{'day1_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'day2_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'day3_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'day4_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'day5_hours_child' . $i}, $max_earlyheadstart_length) + $in->{'day6_hours_child' . $i} + $in->{'day7_hours_child' . $i};
						
						if ($earlyheadstart_summer == 1) { #This will always be true since this variable is set to 1 in this same code. But keeping it here in case someone using this code decides against buiding in the avaialility of Head Start in the summer for this potential scenario.
							${'summer_cc_hours_wk_child' . $i} = pos_sub($in->{'summerday1_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'summerday2_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'summerday3_hours_child' . $i}, $max_earlyheadstart_length)  + pos_sub($in->{'summerday4_hours_child' . $i}, $max_earlyheadstart_length)  + pos_sub($in->{'summerday5_hours_child' . $i}) + $in->{'summerday6_hours_child' . $i} + $in->{'summerday7_hours_child' . $i};
						}
					} else {
						${'cc_hours_wk_child' . $i} = pos_sub($in->{'day1_future_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'day2_future_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'day3_future_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'day4_future_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'day5_future_hours_child' . $i}) + $in->{'day6_future_hours_child' . $i} + $in->{'day7_future_hours_child' . $i};

						if ($earlyheadstart_summer == 1) { #Same as above, this will always be true since this variable is set to 1 in this same code. But keeping it here in case someone using this code decides against buiding in the avaialility of Head Start in the summer for this potential scenario.
							${'summer_cc_hours_wk_child' . $i} = pos_sub($in->{'summerday1_future_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'summerday2_future_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'summerday3_future_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'summerday4_future_hours_child' . $i}, $max_earlyheadstart_length) + pos_sub($in->{'summerday5_future_hours_child' . $i}) + $in->{'summerday6_future_hours_child' . $i} + $in->{'summerday7_future_hours_child' . $i};
						}
					}
				}


				#DETERMINING THE COMBINED MARKET RATE OF CHILD CARE

				#First, we set SPRs to young children in license-exempt centers to 0, since NH does not provide CCDF funds to license-exempt centers caring for young children. By assigning these to 0, parents who select this option for a child but also select ccdf=1 (indicating that they are receiving CCDF subsidies) will have their SPR set to 0 and will pay full cost for child care for these children.
				if ($in->{'child'.$i.'_age'} < 6 && $in->{'child'.$i.'_withbenefit_setting'} eq 'License-exempt child care center') {
					$in->{'child'.$i.'_withbenefit_cost_m_sub_pt'} = 0; 
					$in->{'child'.$i.'_withbenefit_cost_m_sub_ht'} = 0;  
					$in->{'child'.$i.'_withbenefit_cost_m_sub'} = 0; 
				}
				# Now we calcualte how much per weeek the parent pays in child care, first during the school year. Check if child needs any child care, is school-age and what type of school-age care, if any, they receive, and assign costs collected in PHP accordingly.
				if (${'cc_hours_wk_child' . $i} == 0) {
					${'spr_week_child' . $i} = 0;
					${'unsub_week_child' . $i} = 0;
					print "debugcc2 child $i \n";
				} elsif (${'cc_hours_wk_child' . $i} <= 15 && $in->{'child'.$i.'_age'} < 5) { #This accords to the SPR definition of part-time as less than or equal to 15 hours per week. We could make this a variable later.
					${'spr_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_sub_pt'}; #parttime, subsidized.
					${'fullcost_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_pt'};
					if ($in->{'ccdf'} == 1) {
						${'unsub_week_child' . $i} = $in->{'child'.$i.'_continue_cost_m_pt'};
					} else {
						${'unsub_week_child' . $i} = $in->{'child'.$i.'_nobenefit_cost_m_pt'};
					}
					print "debugcc3 child $i \n";
				} elsif (${'cc_hours_wk_child' . $i} < 30 && ($in->{'child'.$i.'_age'} > 5 || ($in->{'child'.$i.'_age'} == 5 && ${'schoolage_care_child'.$i} ne 'none'))) { #The child is school-age but not receiving full-time child care during the school year. We use the part-time and half-time rates. The exception for 5-year-olds enables parents of 5-year-olds not yet in Kindergarten to choose "none" in the schoolage care drop-downs.
					if (${'cc_hours_wk_child' . $i} <= 15) {
						${'spr_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_sub_pt'}; #parttime, subsidized.
					} else {
						${'spr_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_sub_ht'}; #half-time (less than 30 hours/week, subsidized.
					}
					#Now we use the before, after, and before&after market rates for these children. 
					if (${'schoolage_care_child'.$i} eq 'afterschool') {
						${'fullcost_week_child' . $i} = $in->{'child'.$i.'_withbenefit_aschoolonly_cost'};
						if ($in->{'ccdf'} == 1) {
							${'unsub_week_child' . $i} = $in->{'child'.$i.'_continue_aschoolonly_unsub'};
						} else {
							${'unsub_week_child' . $i} = $in->{'child'.$i.'_nobenefit_aschoolonly_unsub'};
						}
					} elsif (${'schoolage_care_child'.$i} eq 'beforeschool') {
						${'fullcost_week_child' . $i} = $in->{'child'.$i.'_withbenefit_bschoolonly_cost'};
						if ($in->{'ccdf'} == 1) {
							${'unsub_week_child' . $i} = $in->{'child'.$i.'_continue_bschoolonly_unsub'};
						} else {
							${'unsub_week_child' . $i} = $in->{'child'.$i.'_nobenefit_bschoolonly_unsub'};
						}
					} elsif (${'schoolage_care_child'.$i} eq 'bandaschool') {
						${'fullcost_week_child' . $i} = $in->{'child'.$i.'_withbenefit_baschool_cost'};
						if ($in->{'ccdf'} == 1) {
							${'unsub_week_child' . $i} = $in->{'child'.$i.'_continue_baschool_unsub'};
						} else {
							${'unsub_week_child' . $i} = $in->{'child'.$i.'_nobenefit_baschool_unsub'};
						}
					} elsif (${'schoolage_care_child'.$i} eq 'nontraditional' || ${'schoolage_care_child'.$i} eq 'none') {
						${'fullcost_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_pt'};
						if ($in->{'ccdf'} == 1) {
							${'unsub_week_child' . $i} = $in->{'child'.$i.'_continue_cost_m_pt'};
						} else {
							${'unsub_week_child' . $i} = $in->{'child'.$i.'_nobenefit_cost_m_pt'};
						}
					}		
					print "debugcc4 child $i \n";
				} elsif (${'cc_hours_wk_child' . $i} < 30) { #Children younger than school age needing half-time care. 
					${'spr_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_sub_ht'}; #parttime, subsidized.
					${'fullcost_week_child' . $i} = .5 * ($in->{'child'.$i.'_withbenefit_cost_m'} + $in->{'child'.$i.'_withbenefit_cost_m_pt'});
					#For unsubsidized rates, we approximate half-time care by taking the average of unsubsidized full-time care and unsubsidized part-time care.
					if ($in->{'ccdf'} == 1) {
						${'unsub_week_child' . $i} = .5 * ($in->{'child'.$i.'_continue_cost_m'} + $in->{'child'.$i.'_continue_cost_m_pt'}) ;
					} else {
						${'unsub_week_child' . $i} = .5 * ($in->{'child'.$i.'_nobenefit_cost_m'} + $in->{'child'.$i.'_nobenefit_cost_m_pt'});
					}
					print "debugcc5 child $i \n";
				} else { #Children need full-time care. This include younger and older children.
					${'spr_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_sub'}; #parttime, subsidized.
					${'fullcost_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m'};
					if ($in->{'ccdf'} == 1) {
						${'unsub_week_child' . $i} = $in->{'child'.$i.'_continue_cost_m'};
					} else {
						${'unsub_week_child' . $i} = $in->{'child'.$i.'_nobenefit_cost_m'};
					}
				}
			
				# Now we calculate the same, but in the summer, which cannot be reduced by rates for before and/or after school:
				if (${'summer_cc_hours_wk_child' . $i} == 0) {
					${'summer_spr_week_child' . $i} = 0;
					${'summer_unsub_week_child' . $i} = 0;
				} elsif (${'summer_cc_hours_wk_child' . $i} <= 15) { #This accords to the SPR definition of part-time as less than or equal to 15 hours per week. We could make this a variable later.
					${'summer_spr_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_sub_pt'}; #parttime, subsidized.
					${'summer_fullcost_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_pt'};
					if ($in->{'ccdf'} == 1) {
						${'summer_unsub_week_child' . $i} = $in->{'child'.$i.'_continue_cost_m_pt'};
					} else {
						${'summer_unsub_week_child' . $i} = $in->{'child'.$i.'_nobenefit_cost_m_pt'};
					}
				} elsif (${'summer_cc_hours_wk_child' . $i} < 30) { #This accords to the SPR definition of half-time as greater than 15 hours per week but lesss than 30 hours per week. We could make this a variable later.
					${'summer_spr_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_sub_ht'}; #halftime, subsidized.
					${'summer_fullcost_week_child' . $i} = .5 * ($in->{'child'.$i.'_withbenefit_cost_m'} + $in->{'child'.$i.'_withbenefit_cost_m_pt'});
					if ($in->{'ccdf'} == 1) {
						${'summer_unsub_week_child' . $i} = .5 * ($in->{'child'.$i.'_continue_cost_m'} + $in->{'child'.$i.'_continue_cost_m_pt'});
					} else {
						${'summer_unsub_week_child' . $i} = .5 * ($in->{'child'.$i.'_nobenefit_cost_m'} + $in->{'child'.$i.'_nobenefit_cost_m_pt'});
					}
				} else { 
					${'summer_spr_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m_sub'}; #parttime, subsidized.
					${'summer_fullcost_week_child' . $i} = $in->{'child'.$i.'_withbenefit_cost_m'};
					if ($in->{'ccdf'} == 1) {
						${'summer_unsub_week_child' . $i} = $in->{'child'.$i.'_continue_cost_m'};
					} else {
						${'summer_unsub_week_child' . $i} = $in->{'child'.$i.'_nobenefit_cost_m'};
					}
				}
									
				#Now we can total the child care costs for this child per year:
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
				
					#Reset the unsub variables, while keeping the spr and fullcost variables the same as calculated above. The latter two are important for calculating costs when the household receives CCDF. There is some risk here of a family understating the alternative payment they would be making if they started not receiving CCDF, since teh unsub variables are also used in the ccdf code, such as if the unsub values all equal 0, there is no CCDF given to the family, and when the CCDF payment amounts exceed the unsub total, the calclator defers to the unsub total. Perhaps the question could be phrased as something like "In the absence of CCDF funding, how much would you expect to pay...". But this doesn't seem too misleading -- if the family has access to less expensive child care, that they trust, there doesn't seem to be a great reason to default to more expensive care. So using this question to allow users to establish a ceiling amount for child care costs seems okay.
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
    foreach my $name (qw(spr_all_children unsub_all_children spr_child1 spr_child2 spr_child3 spr_child4 spr_child5 unsub_child1 unsub_child2 unsub_child3 unsub_child4 unsub_child5 fullcost_all_children fullcost_child1 fullcost_child2 fullcost_child3  fullcost_child4 fullcost_child5 child_care_expenses_m child_care_expenses cc_hours_wk_child1  summer_unsub_week_child1 unsub_week_child1 summer_cc_hours_wk_child1)) { 
       $out->{$name} = ${$name};
    }
	
}

1;