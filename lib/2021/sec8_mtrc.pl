#=============================================================================#
#  Section 8 Module – 2021  
#=============================================================================#
# Calculates section 8 benefits
# Inputs referenced in this module:
#
#   INPUTS OR OUTPUTS NEEDED FOR CODE:
#
#	INPUTS FROM USER INTERFACE (SOME VARIABLES MAY BE DEFINED OR REDEFINED IN FRS.PM AS WELL)
#       sec8
#       child_number
#       residence                   
#       family_size    
#       disability_parent#
#       disability_work_expenses_m
#		family_structure
#		parent#_age
#		parent#_ft_student
#		married1
#		married2
#		flatrent
#		housing_override
#		housing_override_amt
#
#	INPUTS FROM FRS.PM 
#       rent_cost_m
#		fmr
#		selfemployed_netprofit_total
#
#	INPUTS NEWLY DEFINED IN THIS MODULE
#		imputed_rent_difference
#
#	OUTPUTS FROM FRS.PL 
#		scenario
#
#	OUTPUTS FROM INTEREST
#       interest
#
#	OUTPUTS FROM PARENT EARNINGS
#       parent#_earnings
#       earnings
# 
#	OUTPUTS FROM SSI
#       ssi_recd
#
#	OUTPUTS FROM TANF
#       tanf_recd
#       child_support_recd
#
#	OUPUTS FROM CHILD CARE
#       child_care_expenses
#
#	OUTPUTS FROM HLTH
#		health_expenses
#
#	OUTPUTS FROM UI
#		ui_recd
#		fpuc_recd
#
#=============================================================================#

sub sec8
{
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};

  # Variables used here
    our $sec8_dependent_ded     = 480;  	# exemption per dependent 
    our $sec8_dis_ded = 400; 		#exemption for any disabled family member 
    our $sec8_dis_ded_recd = 0; 		#amount received from exemption for any disabled family member in sec8 calcs.
  # outputs created
    our $rent_paid = 0;               # Annual rent paid by family: Tenant rent burden or full rent for families w/out subsidies
    our $rent_paid_m = 0;             # Monthly rent paid by family
    our $housing_recd = 0;            # Housing subsidy (Section 8 voucher) value, annual
    our $housing_subsidized = 0;      # a logical value indicating whether housing is subsidized
	
  # Variables created
    our $sec8_cc_ded_recd   = 0;     # child care deduction
    our $sec8_gross_income  = 0;    # gross income for determining tenant rent burden
    our $sec8_net_income    = 0;      # adjusted income for determining tenant rent burden
    our $rent_preliminary   = 0;     # preliminary rent [assuming (continuing) eligibility for vouchers]
    our $sec8_payment_standard = 0;  # HUD payment standard used to determine subsidy, based on Fair Market Rents.
    our $verylow_income_limit = 0;   #	very-low income limit used by HUD as a base to determine entrance eligibility
    our $low_income_limit = 0;      # low income limit used by HUD as a base to determine exit eligibility
	our $adult_children_students_sec8 = 0;
	#OUTDATED:
	# our $ami_adjustment  = qw(0 0.7 0.8 0.9 1 1.08 1.16 1.24 1.32 1.4)[$in->{'family_size'}];       # The family-size adjustment factors that HUD uses to determine income limits based on the 4-person base numbers. Source: see page 4 in https://www.huduser.gov/portal/datasets/il/il17/HUD-sec8-FY17.pdf. Only needed for applicant eligibility, so commented out here but kept as a note for collaborator adaptations or future improvements.
	# our $base_50_percent_ami = 0; # Only needed for applicant eligibility, so commented out here but kept as a note for collaborator adaptations or future improvements.
	# our $base_80_percent_ami = 0; # Only needed for applicant eligibility, so commented out here but kept as a note for collaborator adaptations or future improvements.
	our $fmr_1 = 0;
	our $fmr_2 = 0;
	our $fmr_3 = 0;
	our $fmr_4 = 0;
	our $fmr_5 = 0;
    our $dis_asst_ded = 0;			# disability expenses deduction for determining net income
    our $med_expenses_ded = 0; 		#medical expenses deduction for determining net income 
    our $rent_difference = 0; #Variable added in 2019, to account for voucher programs where renters can pay the difference between Section 8 standards and available rent costs.

	#NOTE: In previous FRS iterations (2017 and earlier), we used the initial entrance criteria (50% of the AMI) and a perceived exit income criteria (80% of the AMI) to determine continuing eligibiltiy and eligibility for reentry into Section 8. However, upon further review of HUD 2019 documentation, the project team found that these criteria are inappropriate to use in this context. Once you are in Section 8 or HCVP, no more income tests are applied. The benefit of the program can go down to 0 as adjusted income rises, or go back up again if adjusted income drops as gross income rises (e.g. if the family loses child care subsidies, raising the value of HCVP's child care deduction), but there is no income above which people lose their voucher or their project-based apartment. 

  
    if($in->{'sec8'} != 1) {
        $rent_paid = $in->{'rent_cost_m'} * 12;
        $rent_paid_m = $rent_paid / 12;
        $housing_recd = 0;
    } else {
        # Determine eligibility

		
        # Deriving the payment standard from the MySQL "Locations" table to determine fair market rent, already derived in the user interface. We use this for the section 8 payment standard, based on year, state, residence, and number_children, labeling the associated value as sec8_payment_standard. 
		
		if ($in->{'state'} eq 'DC') { #Consider moving this to fsp_assets to capture all state variations in SNAP, school meals, and Section 8 policies.
			$sec8_payment_standard = 1.87 * $in->{'fmr'}; #This higher percentage for DC is technically just for the HCVP program, and seemingly also for the project-based (voucher) Section 8 programs. Since we are not distinguishing between those and Public Housing, this is an abstraction. But we have also built this same abstraction into our model for Public Housing, which does not operate based on FMRs -- there is no ceiling for rents except for the flat rent option. This is a controversial issue -- and one that cannot be modeled easily -- as each public housing facility establishes their own flat rent policy (as in, how much flat rent to charge tenants, typically at least 80% of FMR). Since DC has raised its payment standard well above the HUD-determined FMR, that likely exacerbates the abstraction we are making in claiming that we model public housing. In reality, most public housing tenants who are paying close to the FMR rent will opt for flat rents. We provide a flat rent option in the MTRC, but people who are not yet making high enough incomes will not know their flat rents; the problem is more one of lack of knowledge and user data than one that we can fix in this model.
		} else {
			$sec8_payment_standard = $in->{'fmr'};			
		}

        # Compute gross income
        $sec8_gross_income = $out->{'earnings'} + &pos_sub($out->{'tanf_recd'}, 12*$out->{'noncountable_tanf_income'}) + $out->{'child_support_recd'} + $out->{'interest'} + $out->{'gift_income'} + $out->{'ssi_recd'} + $in->{'selfemployed_netprofit_total'} + &pos_sub($out->{'ui_recd'}, $out->{'fpuc_recd'}); #types of income counted in  subpart K 982.516 https://www.ecfr.gov/cgi-bin/text-idx?SID=db1fea8115baa15484288904baa7548e&mc=true&node=se24.4.982_1516&rgn=div8

		#Gifts note: The HUD definition of income for Section 8 (24 CFR, Part 5, Subpart F (Section 5.609)) specifically excludes lump sum gift income but includes recurring gift income. 
		
		#COVID legislation note: FPUC (the federal $300/wk supplement to UI payments) is exempt from Section 8 income calculations acccording to HUD guidelines.
	
        # Note about the evolution of this code: Prior to 2019, NCCP's FRS first calculated rent for instances either when the user accepts the fair market rent (the FRS default value) or when the user-entered rent value is lower than fair market rate. If anything, this only applied for project-based Section 8, since otherwise, at $0 earnings, the family would be paying more than 40% of their earnings on rent they need to pay the landlord, since that will be the difference between the payment standard (the maximum subsidy) and the rent on the unit. We had also been assuming that this family, once having earnings of $0, still lives in an appropriate unit that would meet this federal standard. But, decided/realized in 2019 that  the above is too restrictive and may just be for place-based section 8, and not the voucher program. It also removes people from Section 8 eligibiltiy when the section 8 payment standards in certain areas, like Allegheny County, PA, are lower than the fair market rents, which we use as defaults.
		# Further note about evoluation of this code: As we now (beginning in 2020) include homeownership in the FRS/MTRC model, it is importnat to note that homeownership does not exclude individuals from Section 8 / HCV participation. On the contrary, HUD can help you pay for maintenance as well as mortgage payments. As we are working to use the "rent" variable to capture these costs, since rent capture the entirety of shelter costs, the section 8 code works the same way for homeowners as it does for renters.
		# SSI income is included as  income for eligibility determination, there is a memo from 2012 that indicates as such. 
		
 
		# Calculate child care deduction
		$sec8_cc_ded_recd = &least($out->{'child_care_expenses'}, $sec8_gross_income); 
		
		#Calculate disabled household allowance, disability assistance expenses, and medical expenses allowances for non-disabled populations.  
		#Calculate disability assistance expenses and medical expenses deductions for disabled households. While there are separate calculations for each, when a household qualifies for both (which would be the case if any parent is disabled), then there are specific instructions. 
		#The disability assistance expenses deduction is for unreimbursed expenses to cover any expenses that allow a family member to be employed, which we assume is disability_work_expenses_m. The allowance is capped at the amount of income made by the disabled individual. See HCV guidebook 5-30/33.  

		#It's easiest to do this in a loop testing for disability for each parent. We start by reaffirming 0 values for the relevant variables:
		$sec8_dis_ded_recd = 0;
		$dis_asst_ded = 0; 
		$med_expenses_ded = 0;
		for(my $i=1; $i<=4; $i++) {
			if ($in->{'parent'.$i.'_age'} > -1) {
				if ($in->{'disability_parent'.$i} == 1)  {
					$sec8_dis_ded_recd = $sec8_dis_ded;  #There is only one household deduction for disability, even if more than one adult in the household are disabled. See 5-28 in HCV guidebook.
					# The deduction for costs allowing an adult to work cannot exceed the earnings generated by that adult. It's possible that expenses related to working among people with disabilities exceeds a single individual's earnings, however, so if there are any remaining disability_work_expenses, we apply them to the second parent or third parent if they also have a disability. Technically these expenses should be broken down by adult, so having each adult draw down those expenses to the maximum extent assumes these expenses are distributed optimally.
					$dis_asst_ded += &least(&pos_sub(&pos_sub($in->{'disability_work_expenses_m'}*12,$dis_asst_ded), $sec8_gross_income*.03), $out->{'parent'.$i.'_earnings'});
				}
			}
		} 

		if ($sec8_dis_ded_recd > 0) { # This checks if the household includes an adult with a disability.

			#Calculate medical expenses deduction. This deduction is only available to elderly or disabled households. Any unreimbursed medical expenses the family incurs, regardless of whether medical expenses are for people with disabilities, are eligible for this deduction.
			$med_expenses_ded = &pos_sub($out->{'health_expenses'}, &pos_sub($sec8_gross_income*.03, $dis_asst_ded));
			
		}
		
		# Include adult students as dependents. The students cannot be the head of household or married to the head of household to be counted as a dependent. Technically, all income of students younger than 24 above $480 is also excluded from income (which in most cases will essentially mean that all income for adult students are excluded, as $480 is also the dependent deduction) but since we are adding income to students (but not hours) to model increases in earnings, allowing the household to remain at the same rent despite increases in earnings by full-time students due to wage increases rather than working more hours diverges too far from reality for the resulting analysis to make sense. Therefore, we assume in this case that although the other outputs may assign higher income based on wage increases to the adult students, the Section 8 module will assume this higher income is due to higher wages among other individuals in the household.
		for (my $i = 2; $i <= 4; $i++) {
			if ($in->{'parent'.$i.'_age'} > 0) {
				if ($in->{'parent'.$i.'_ft_student'} == 1 && $in->{'married1'} != $i && $in->{'married2'} != $i ) { 
					$adult_children_students_sec8 += 1;
				}
			}
		}
	
		# Compute adjusted income
		$sec8_net_income = &pos_sub($sec8_gross_income, ($sec8_dependent_ded * ($in->{'child_number'} + $adult_children_students_sec8) + $sec8_cc_ded_recd + $sec8_dis_ded_recd + $dis_asst_ded + $med_expenses_ded)); 

		# 2. DETERMINE RENT

		# While we use the variable name rent_preliminary below, this is actually a calculation of the "Total Tenant Payment" (TTP) per HUD guidelines. When rent_cost_m is equal to the rent listed in the base tables, and that rent is based on the 50th percentile market rate  (fair market rent), we can use it as the “Payment Standard” that constitutes the maximum subsidy that HUD provides through the Housing Choice Voucher Program. 

		#This code is broadly applicable to HCVP, project-based Section 8, and Public Housing. In the case of public housing and the HCVP program (but not project-based Section 8), the minimum rent can be set by the PHA -- not to exceed $50, with a hardship exemption -- and a recent CBPP study found that about 73 percent of public housing authorities impoase the maximum minimum rent of $50 on tenants. Project-based Section 8 includes a universal $25 minimum rent. However, for the sake of this study, we can assume that families in project-based Section 8 or are in Public Housing and have incomes low enough that rent would be the minimum rent qualify for a hardship exemption (this can include that a family would be evicted if paying minimum rent), reverting the TTP back to the percentage-of-income version below. See https://www.law.cornell.edu/cfr/text/24/5.630. 

		$rent_preliminary = &greatest(0.3 * $sec8_net_income, 0.1 * $sec8_gross_income);

		if ($in->{'flatrent'} == 1) {
			$rent_paid  = $in->{'rent_cost_m'} * 12;
		} else {
			if ($in->{'housing_override'} == 1) {
				if ($out->{'scenario'} eq 'current') {
					#For a user who has entered that they receive Section 8 or live in Public Housing and who also enters a housing cost override, and who has indicated this is not a flat rent, we use that cost to determine whether they are living in a unit whose market rent exceeds the Section 8 payment standard, usually the fair market rent, based on how much they indicate they are currently making (which we use to determine how much rent they would be paying based on income alone). We also use this to adjust the rent_cost_m input variable, to reflect the full market rate of the unit they are livign in. The rent_cost_m variable will then be used here as an upper bound for how much rent is paid. We only make these calculations once -- for the "current" scenario -- and then use these variables as inputs for determining rent in both the current scenario and in future scenarios.
					$in->{'imputed_rent_difference'} = $in->{'housing_override_amt'} - $rent_preliminary / 12; #This could be negative if they are living in a place with a market rate below the payment standard.
					$in->{'rent_cost_m'} = &greatest(0,$sec8_payment_standard + $in->{'imputed_rent_difference'}); #including min of 0 here to avoid possible negative numbers, which should not come up here, but could if someone is entering weird/incorrect values for their rent.
				}
				
				#We then calculate the rent payment. The only difference in the below calculation compared to one without the user override is that we use the imputed rent difference instead of the rent difference calculated in this code. While the rent difference calcualted in this code could conceivably be positive, it will be 0 for NH and other states as long as the MTRC estimates rent as the FMR and as long as the section 8 payment standard is that same FMR.
				$rent_paid = &least($rent_preliminary + $in->{'imputed_rent_difference'} * 12, $in->{'rent_cost_m'} * 12);
				
			} else {
				if ($in->{'rent_cost_m'} > $sec8_payment_standard) {
					$rent_difference = pos_sub($in->{'rent_cost_m'}, $sec8_payment_standard);
				}
				$rent_paid = &least($rent_preliminary + $rent_difference * 12, $in->{'rent_cost_m'} * 12); #Note: rent_difference is added beginning in 2019 and beyond. This will allow better modeling of non-project based Section 8 vouchers.
			}
		}

		if ($rent_paid < $in->{'rent_cost_m'} * 12 || $in->{'flatrent'} == 1) {
			$housing_subsidized = 1;
		} else {
			$housing_subsidized = 0;
		}

		$rent_paid_m = $rent_paid / 12;

		# 3. DETERMINE SUBSIDY VALUE
		if ($in->{'flatrent'} == 1) {
			$housing_recd = &pos_sub(($in->{'fmr'} * 12), $rent_paid); #Flat rents are only available in public housing. We are not modeling a scenario that can happen when a family is over-rent for two years in a row, which allows PHAs to request that families pay a "market rate" of public housing rent. Unlike HCVP, there is no option for housing assistance recipients to opt for housing with higher rent than the payment standard, set at the FMR. We are indicating here that people in Public Housing paying flat rents are "receiving" a benefit of the difference in what they pay for rent and what they would pay for an apartment of the size their family needs on the open market.
		} else {
			$housing_recd = ($in->{'rent_cost_m'} * 12) - $rent_paid;
		}
    }
     
	#debugging:
	#foreach my $debug (qw(housing_recd rent_paid_m rent_paid housing_subsidized rent_preliminary sec8_net_income rent_difference)) {
	#	print $debug.": ".${$debug}."\n";
	#}

	# outputs
    foreach my $name (qw(rent_paid rent_paid_m housing_recd housing_subsidized rent_difference)) {  # last_received_sec8
        $out->{$name} = ${$name};
    }
	
}

1;