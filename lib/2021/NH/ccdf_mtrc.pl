# =============================================================================#
#  CCDF Module -- 2021 – NH
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
# NH note: Please note that loss of eligibility for CCDF (child care scholarship) occurs 12 months after exceeding income limits. This limits the impact of benefit cliffs on these families, but benefit cliffs will still exist if income does not increase and unsubsidized child care exceeds subsidized rates.
#============================

sub ccdf
{
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};
    
  # outputs created
	our $ccdf_threshold = 2.50;           # ccdf income eligibility limit as a percent of poverty. Last checked 5/13/21.   
    our @ccdf_fpl_array =  (0,12490,16910,21330,25750,30170,34590,39010,43430,47850); #Poverty level from family size = 0 to 9. Last checked 5/13/21.
    our $ccdf_fpl = $ccdf_fpl_array[$in->{'family_size'}]; # poverty threshold used to determine copay level
    our @ccdf_85smi_array = (0,48422,63322,78221,93120,108019,122918,1225712,128506, 131299); # These SMIs included in the sliding fee schedule, from family size = 0 to family size = 9, based on NH Child Care Scholarship statutes (https://www.dhhs.nh.gov/sr_htm/html/sr_20-20_dated_07_20.htm) and, for larger families, the SMI number these are based on from US ACS from FY19, at https://www.acf.hhs.gov/ocs/resource/liheap-im-2019-02-state-median-income-estimates-fy-2019. These are the most recent numbers used by NH; they are based on annuallly published SMIs for use in the LIHEAP program, and while those numbers were last updated in July 2020, have not yet been implemented as the 85% SMI limit has been waived due to COVID. Last checked 5/13/21. 
    our $ccdf_85smi = $ccdf_85smi_array[$in->{'family_size'}]; 
    our $cc_subsidized_flag = 0;          # flag indicating whether or not child care is  subsidized
    our $ccdf_eligible_flag = 0;          # flag indicating whether eligible
    our $child_care_recd = 0;             # annual value of child care subsidies (cost  of care minus family expense)
 	our $ccdf_chargeabovespr = 1; #Some states, like NH, allow providers to charge parents an overage amount of the difference between the SPR and the equivalent rate they would have charged without subsidies. This mitigates and potentially minimizes the CCDF cliff (if co-pays can increase to 100% of SPRs), but also potentially increases child care costs for low-income workers. 
	our $parent_cost_share_percent = 0;	#The parent cost share percent,based on income.
	our $parent_cost_share = 0; #The parent cost share, based on income, for subsidized child care.
	our $child_care_copay = 0; #This variable will be the difference between SPRs and unsubsidized child care, which child care providers can charge parents as long as ccdf_chargeabovespr =1.

  # determined in module
    our $ccdf_income = 0;                 # income used to determine ccdf eligibility and copay 
    our $ccdf_poverty_percent = 0;        # family income as percent of poverty
  	our $ccdf_copay = 0;                   # annual copay charged to family (if copay exceeds state reimbursement for all children, then model assumes that family opts out of ccdf program)

 	our $child_care_expenses = 0; # total annual child care expenses
 	our $child_care_expenses_m = 0;
	our $ccdf_step = 0; #The NH designation for what child care scholarship "step" a family is on, used for determining eligibilty and parent share amounts. 

	our $ccdfpay_total_initial = 0;

	# STEP 1: Test if there is any child care need.
	# NH Note: Anyone on TANF has categorical eligibility for CCDF (child care scholarship). See 900 FAM. So in terms of assigning the ccdf flag, we could prioritize families who receive tanf but are not employed, meaning they do not yet need ccdf but would have a need for it if they start working.
    if ($out->{'unsub_all_children'} == 0 || ($in->{'ccdf'} == 0  && $out->{'ccdf_alt'} == 0)) {	
        $cc_subsidized_flag = 0;
        $ccdf_eligible_flag = 0;
        $child_care_recd = 0;

   } else {
		 
		#  STEP 2: DETERMINE FINANCIAL ELIGIBILITY FOR CCDF SUBSIDIES		#
		# Note: although Social Security income is included in income tabulations, child SSI is explicitly exempted, but adult SSI is not. As of 1/2020, we are only including adult SSI in the FRS and MTRC. 
		
		# Note regarding different relationships of adults in the household and whose income counts: decided upon looking at manual that all adults in family should have income counted and can take care of the child. Actually based on relation of adults to children in hh, but we are refraining from asking specific relationship questions. 
		$ccdf_income = $out->{'earnings'} + $out->{'interest'} + $out->{'child_support_recd'} + $out->{'tanf_recd'} + $out->{'ssi_recd'} + $out->{'ui_recd'} + $in->{'selfemployed_netprofit_total'}; #see FAM 511 - Benefits and Self-Employment sections. 
		$ccdf_poverty_percent = $ccdf_income / $ccdf_fpl;

		# Page 43  of the child care subsidy manual clarifies exit eligibility income requirements. 
		# Technically, there is an asset test for CCDF eligibilty, but the asset limit is $1,000,000 (931 FAM), so  I think we can leave out the millionaires for now. Return to include assets in this, time permitting.

		# One possible policy option for either reducing co-pays or qualifying for child care subsidies might be to use policy triggers to incentivize businesses to offer dependent care flexible spending accounts to their employees, which allow employees to deposit pre-tax earnings into an account dedicated to paying for costs such as child care. Having access to an account like this would seem to allow employee earnings to fall below income eligibility thresholds for a number of programs (e.g. CCDF, SNAP, and TANF), which would be helpful  if cash or near-cash benefits from those programs increase net resources by more than the amount that families might lose by no longer qualifying for the child and dependent care tax credit, which I think would no longer be available if enrolled in a dependent care FSA. For all these benefit programs, we'd also have to check whether funds in a dependent care FSA count as assets (or if assets that spent in the same month they are received are not actually assets).

		if($ccdf_poverty_percent > $ccdf_threshold || $ccdf_income > $ccdf_85smi) {
			$cc_subsidized_flag = 0;
			$ccdf_eligible_flag = 0;
			$child_care_recd = 0;
		} else {
			$ccdf_eligible_flag = 1;
			#
			#  STEP 3: DETERMINE VALUE OF  PARENT COST SHARE
			#

			if ($ccdf_eligible_flag == 1) {
			# We determine the parent's "cost share" of subsidized child care. NH defines "co-pay" as any  difference between the SPR ("Weekly Standard Rate") and the provider's market rate for care. While previous NCCP simulators use the term "co-pay" the way that NH is using "cost share," we will use variables with names more in accordance to NH definitions for this code.
				for ($ccdf_poverty_percent) {
					$parent_cost_share_percent = ($_ <= 1)		?	.0475	:
												 ($_ <= 1.2)	?	.075	:
												 ($_ <= 1.4)	?	.1		:
												 ($_ <= 1.6)	?	.125	:
												 ($_ <= 1.9)	?	.14		:
												 ($_ <= 2.2)	?	.17		:
																	.20;
				}
				for ($ccdf_poverty_percent) {
					$ccdf_step				   = ($_ <= 1)		?	1	:
												 ($_ <= 1.2)	?	2	:
												 ($_ <= 1.4)	?	3	:
												 ($_ <= 1.6)	?	4	:
												 ($_ <= 1.9)	?	5	:
												 ($_ <= 2.2)	?	6	:
																	7;
				}
								
				$parent_cost_share = &least($out->{'spr_all_children'},$parent_cost_share_percent * $ccdf_income);
				#
				# STEP 4. COMPARE THE UNSUBSIDIZED COST OF CARE TO COPAY)
				#
				if($parent_cost_share > $out->{'unsub_all_children'}) {
					# In this case, the unsubsidized cost of child care is cheaper, so the family will opt for that.
					$cc_subsidized_flag = 0;
				} else {
					$cc_subsidized_flag = 1;

					#We can use the ccdf_chargeabovespr as a dummy variable (1 or 0, with it being 1 in NH's case) in calculate the overage payment (co-pay in NH) as the difference between unsubsidized care and the state payment rate in states that operate this policy. We call this variable "overage payment" in other states. NH has this policy (938 FAM).
					
					#We are asking users to indicate their out-of-pocket costs for child care, which will include both the overage payment (child_care_copay) and the parent cost share (parent_cost_share), which is the sliding scale payment amount. We have to disentangle these.
					
					#We need to figure out any overage payments the family will be paying. This is called "co-pay" in New Hampshire. If a user has entered how much they currently pay for CCDF-subsidized child care, we incorporate this amount into the below calculations. If not, we derive it from the market rates.
					
					#For users who have not entered current payment amounts or for the hypothetical scenario in which the tool models CCDF where it hadn't before. 
					if ($in->{'ccdfpay_estimate_source'} eq 'fullcost_ccdf' || ($in->{'ccdf'} == 0  && $out->{'ccdf_alt'} == 1)) {
						$child_care_copay = $ccdf_chargeabovespr * &pos_sub($out->{'fullcost_all_children'},$out->{'spr_all_children'}); 
					} else {
						#User has entered their own child care costs for CCDF participation. We use these first to identify an initial overage amount that we will apply for future iterations.
						for(my $i=1; $i<=5; $i++) {
							if ($in->{'child'.$i.'_age'} >-1 || $in->{'child'.$i.'_age'} < 13) {
								if ($in->{'ccdf_payscale'.$i} eq 'year') {
									$ccdfpay_total_initial += $in->{'child'.$i.'_ccdfpay_amt_m'};
								} elsif ($in->{'ccdf_payscale'.$i} eq 'month') {
									$ccdfpay_total_initial += $in->{'child'.$i.'_ccdfpay_amt_m'} * 12;
								} elsif ($in->{'ccdf_payscale'.$i} eq 'biweekly') {
									$ccdfpay_total_initial += $in->{'child'.$i.'_ccdfpay_amt_m'} * 26;
								} elsif ($in->{'ccdf_payscale'.$i} eq 'week') {
									$ccdfpay_total_initial += $in->{'child'.$i.'_ccdfpay_amt_m'} * 52;
								}
							}
						}
						if ($out->{'scenario'} eq 'current') {
							#We define an input variable, overage_amount. Since the current scenario is always run first, this will set up the overage amount for the future scenarios once they are invoked.
							print "ccdfpay_total_initial: $ccdfpay_total_initial \n";
							print "parent_cost_share: $parent_cost_share \n";
							$in->{'overage_amount'} = &pos_sub($ccdfpay_total_initial, $parent_cost_share);
							print "overage amount: $in->{'overage_amount'} \n"; 
							#Also, if they are paying under the amount of their parent cost share but participating in CCDF, that means that their child care provider is not only charging under the market rate, but under the SPR amount for the care they provide. We therefore lower the care they receive by this amount as well. Like overage_amount above, we assume below that the discount amount is a constant, and not proportional to the amount of care received or how much the provider could charge for that are at their market rates.
														
							$in->{'discount_amount'} = &pos_sub($parent_cost_share, $ccdfpay_total_initial);
														
							#In frs.pm, run once before any of the scenarios or iterations, we define both overage_amount and discount_amount as 0, so the invocations of these variables outside of this if-block will still work.
						}
						#We identify the child care copay, using the overage_amount variable that was just defined or that was defined in the "current" scenario. This assumes that any markup child care providers charge above the SPR is constant. Alternatively, we could include a proportional markup  against the full cost of care (fullcost_all_children), with any increases in child care schedules that might demand higher rates, but the market rate study includes rates that already have a large enough jump betweeen part-time and full-time care (that this tool dampens to something more realistic by including a half-time rate), that making the markup proportional to the market rate of care would exacerbate marginal tax rates unrealistically -- for the amounts it would raise child care rates by, users would most likely simply switch providers. This could be changed easily in the code if desired.
						
						$child_care_copay =  $in->{'overage_amount'}; #No need to multiply this by $ccdf_chargeabovespr since if they are paying an overage amount and on CCDF (like can happen in NH), then obviously, that happens. The question ascertaining overage costs in the first place should not be asked in locations where this policy is not active.
					}
					$child_care_expenses = &pos_sub($parent_cost_share + $child_care_copay, $in->{'discount_amount'});
					$child_care_recd = &pos_sub($out->{'spr_all_children'}, $parent_cost_share) + $in->{'discount_amount'};

				}
			}
		}
	}
		        
    #
    # STEP 6. DETERMINE UNSUBSIDIZED COST OF CARE
    #
    if($cc_subsidized_flag == 0) {

		$child_care_expenses = pos_sub($out->{'unsub_all_children'}, $in->{'discount_amount'}); #We include a the discount_amount here, which is set to 0 unless a family both qualifies and has entered in an override amount that is less than the parent share (sliding scale payment) of child care. Adding that to families that lose CCDF subsidies models the access to below-market rates that the family has. 
		$child_care_recd = 0;
	}

 	$child_care_expenses_m = $child_care_expenses / 12;       

	#debugging
	 foreach my $debug (qw(child_care_recd child_care_expenses ccdf_eligible_flag ccdf_poverty_percent ccdf_step parent_cost_share_percent parent_cost_share cc_subsidized_flag child_care_copay child_care_recd)) {
		print $debug.": ".${$debug}."\n";
	}

  # outputs
    foreach my $name (qw(child_care_expenses child_care_expenses_m  cc_subsidized_flag ccdf_eligible_flag child_care_recd ccdf_step parent_cost_share_percent)) {
        $out->{$name} = ${$name};
    }
	
}

1;