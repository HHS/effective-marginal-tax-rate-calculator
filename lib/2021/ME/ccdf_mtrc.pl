# =============================================================================#
#  CCDF Module -- 2021 – ME
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


sub ccdf
{
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};
    
	#policy variables
	our @smi_array = (0,46887,61314,75741,90168,104594,119021,121726,124431, 127136); #These are the SMIs as listed in the latest (2021) LIHEAP publication in the federal register.
    our $ccdf_85smi = .85 * $smi_array[$in->{'family_size'}]; 
 	our $ccdf_chargeabovespr = 0; #Some states, like NH, allow providers to charge parents an overage amount of the difference between the SPR and the equivalent rate they would have charged without subsidies. This mitigates and potentially minimizes the CCDF cliff (if co-pays can increase to 100% of SPRs), but also potentially increases child care costs for low-income workers. But ME does not have this.
    our @ccdf_fpl_array =  (0,12490,16910,21330,25750,30170,34590,39010,43430,47850); #Poverty level from family size = 0 to 9. Last checked 5/13/21.
    our $ccdf_fpl = $ccdf_fpl_array[$in->{'family_size'}]; # poverty threshold used to determine copay level
	our $step4_copay_reduction = .2;
	our $step3_copay_reduction = .1;

  # outputs created
	our $child_care_expenses_step4 = 0; #We need to know this for state taxes, as families are compensated for a higher percentage of child care costs when children are enrolled in higher-quality settings.
    our $cc_subsidized_flag = 0;          # flag indicating whether or not child care is  subsidized
    our $ccdf_eligible_flag = 0;          # flag indicating whether eligible
    our $child_care_recd = 0;             # annual value of child care subsidies (cost  of care minus family expense)
 	our $child_care_expenses = 0; # total annual child care expenses
 	our $child_care_expenses_m = 0;
    our $ccdf_income = 0;                 # income used to determine ccdf eligibility and copay 
    our $ccdf_poverty_percent = 0;        # family income as percent of poverty
	our $parent_copay_pct = 0;
	our $parent_copay = 0; #This variable will be the difference between SPRs and unsubsidized child care, which child care providers can charge parents as long as ccdf_chargeabovespr =1.
	our $overage_amount_paid  = 0; #This variable will be the difference between SPRs and unsubsidized child care, which child care providers can charge parents as long as ccdf_chargeabovespr =1.
	our $ccdfpay_total_initial = 0;
	our $subsidized_chidren = 0;
	our $step4_count = 0;

	# STEP 1: Test if there is any child care need.
    if ($out->{'unsub_all_children'} == 0 || ($in->{'ccdf'} == 0  && $out->{'ccdf_alt'} == 0)) {	
        $cc_subsidized_flag = 0;
        $ccdf_eligible_flag = 0;
        $child_care_recd = 0;

   } else {
		#  STEP 2: DETERMINE FINANCIAL ELIGIBILITY FOR CCDF SUBSIDIES		#
		#NOTE: While there are specific rules in Maine's (and other states') CCDF programs regarding unit composition, we are unable to incorporate those now (as of 8/2021) into the MTRC tool, as it would require asking additional relationship questions that we have not yet built into the tool in order to avoid overwhelming the user. We have flagged the addition of these rules for potential future additions. For now, we assume all members of a household are part of the CCDF/TANF assistance unit.
		
		$ccdf_income = $out->{'earnings'} + $in->{'selfemployed_netprofit_total'} + $out->{'interest'}+ $out->{'ssi_recd'} + $out->{'tanf_recd'} + $out->{'ui_recd'} + $out->{'child_support_recd'};
		$ccdf_poverty_percent = $ccdf_income / $ccdf_fpl;
		# Technically, there is an asset test for CCDF eligibilty, but the asset limit is $1,000,000 (931 FAM), so  I think we can leave out the millionaires for now. Return to include assets in this, time permitting.

		if($ccdf_income > $ccdf_85smi || $out->{'parent1_transhours_w'} + $out->{'parent2_transhours_w'} + $out->{'parent3_transhours_w'} + $out->{'parent4_transhours_w'} == 0) {
			#Income must be less than 85% SMI and at least one parent must be working in training in order to receive child care subsidies.
			$cc_subsidized_flag = 0;
			$ccdf_eligible_flag = 0;
			$child_care_recd = 0;
		} else {
			$ccdf_eligible_flag = 1;
			#
			#  STEP 3: DETERMINE VALUE OF  PARENT COST SHARE
			#
			if ($ccdf_eligible_flag == 1) {
			# We determine the parent's copays for subsidized child care. 
			#"All Parents will be assessed, and a Parent Fee will be determined by the number of individuals in the Family, the Gross Income or Allowable Net Income, and QRIS level of program. The Parent Fee does not vary with the number of Children receiving Child Care Services, the amount of Child Care Services they need, or the type of Child Care Services the Parent chooses to use."
			#"Parents choosing a Provider at a Step 3 QRIS will receive a ten percent (10%) reduction in their Parent Fee determination or at a Step 4 QRIS will receive a twenty percent (20%) reduction in their Parent Fee determination."
			#For a family with one child in Step 3 or Step 4, it appears that copays would be reduced by the highest possible amount.
			
				for ($ccdf_poverty_percent) {
					$parent_copay_pct = ($_ <= .25)		?	.02	:
									($_ <= .5)		?	.04	:
									($_ <= .75)		?	.05	:
									($_ <= 1)		?	.06	:
									($_ <= 1.25	)	?	.08	:
									($_ <= 1.5)		?	.09	:
														.1;
				}
				
				
				if ($out->{'spr_step4_portion'} > 0) {
					$parent_copay_pct = (1 - $step4_copay_reduction) * $parent_copay_pct;
				} elsif ($out->{'spr_step3_portion'} > 0) {
					$parent_copay_pct = (1 - $step3_copay_reduction) * $parent_copay_pct;
				}
				
				$parent_copay = &least($out->{'spr_all_children'},$parent_copay_pct * $ccdf_income);
				#
				# STEP 4. COMPARE THE UNSUBSIDIZED COST OF CARE TO COPAY)
				#
				if($parent_copay > $out->{'unsub_all_children'}) {
					# In this case, the unsubsidized cost of child care is cheaper, so the family will opt for that. This will not happen in Maine unless a family enters their own child care costs, which are incorporated separately, below.
					$cc_subsidized_flag = 0;
				} else {
					$cc_subsidized_flag = 1;

					#Other states have calculations here for incorporating "overage" amounts that providers can charge families above their reimbursement rates. But Maine bars providers from doing that, so there are no additional costs here. Code using the "ccdfpay" variables in the PHP code could be invoked if that Maine policy changes. 
					
					#We can use the ccdf_chargeabovespr as a dummy variable (1 or 0, with it being 1 in NH's case) in calculate the overage payment (co-pay in NH) as the difference between unsubsidized care and the state payment rate in states that operate this policy. We call this variable "overage payment" in other states. NH has this policy (938 FAM).
					
					#We are asking users to indicate their out-of-pocket costs for child care, which will include both the overage payment  and the copays, which is the sliding scale payment amount. We have to disentangle these.
					
					#We need to figure out any overage payments the family will be paying. If a user has entered how much they currently pay for CCDF-subsidized child care, we incorporate this amount into the below calculations. If not, we derive it from the market rates.
					
					#For users who have not entered current payment amounts or for the hypothetical scenario in which the tool models CCDF where it hadn't before. 
					$child_care_expenses = $parent_copay;
					$child_care_recd = &pos_sub($out->{'spr_all_children'}, $parent_copay);
					
					#Since we need a tabulation for Step 4 child care, we can divide the number of children receiving Step 4 child care by the number of children receiving care to find the proportion parents can use to claim the higher credit.
					for(my $i=1; $i<=$in->{'children_under13'}; $i++) {
						if ($out->{'spr_child'.$i} > 0) {
							$subsidized_chidren += 1;
							if ($in->{'child'.$i.'_withbenefit_setting'} eq 'licensed_center_step3' || $in->{'child'.$i.'_withbenefit_setting'} eq 'licensed_fcc_home_step3') {
								$step4_count += 1;
							}
						}
					}
					if ($subsidized_children > 0) { #This is to ensure non-division by 0. Conceivably someone may overwrite the child care costs such that SPR's are zeroed, meaning the tally above will not go above 0.
						$child_care_expenses_step4 = ($step4_count/$subsidized_chidren) * $child_care_expenses;
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
		$child_care_expenses_step4 = $out->{'unsub_step4_portion'};
		$child_care_recd = 0;
	}

 	$child_care_expenses_m = $child_care_expenses / 12;       

	#debugging
	 foreach my $debug (qw(child_care_recd child_care_expenses ccdf_eligible_flag ccdf_poverty_percent parent_copay cc_subsidized_flag child_care_recd)) {
		print $debug.": ".${$debug}."\n";
	}

	# outputs
    foreach my $name (qw(child_care_expenses child_care_expenses_m  cc_subsidized_flag ccdf_eligible_flag child_care_recd child_care_expenses_step4)) {
        $out->{$name} = ${$name};
    }
	
}

1;