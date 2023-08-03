#===========================================================================#
#  Food Stamps Module – 2021 
#=============================================================================#
# Inputs referenced in this module:
#
#	FROM USER INTERFACE
#	fsp
#	parent#_age
#	disability_parent#
#	family_size
#	family_structure
#	child_number
#	savings
#	checking
#	exclude_abawd_provision
#	disability_medical_expenses_mnth
#	heat_in_rent
#	energy_cost_override_amt
#
#   FROM PARENT EARNINGS:
#	earnings_mnth
#	earnings
#
#   FROM INTEREST
#	interest_m
#
#   FROM TANF
#	tanf_recd_m
#	tanf_sanctioned_amt
#	child_support_recd_m
#
#   FROM CHILD CARE
#	child_care_expenses_m
#
#   FROM FOOD STAMP ASSETS
#	fs_vehicle#
#	bbce_gross_income_pct
#	bbce_no_asset_limit
#	bbce_disability_no_asset_limit
#	bbce_asset_limit
#	heatandeat_nominal_payment
#	pha_ua
#	optional_sua_policy
#
#   FROM SECTION 8
#	rent_paid_m
#	housing_subsidized
#	rent_difference
#
#	FROM PARENT_EARNINGS
#	parent#_transhours_w
#	parent#_transhours_w
#	parent#_earnings_m
#
#	FROM SSI
#	ssi_recd_mnth
#
#	FROM UI		
#	ui_recd		
#	ui_recd_m	
#=============================================================================#

sub fsp
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};


	#2021 SNAP benefits - last checked 4/15/21. 
	our @fs_gross_income_limit_array = 	(0,	1383,	1868,	2353,	2839,	3324,	3809,	4295,	4780); #the gross income limits, per household size, up to 8 people.
	our @fs_net_income_limit_array = 	(0,	1064,	1437,	1810, 	2184,	2557,	2930,	3304,	3677); #the net income limits, per household size, up to 8 people.
	our @fs_max_ben_array = 			(0,	204,	374,	535,	680,	807,	969,	1071,	1224); #the maximum benefit amounts, per household size, up to 8 people.
	our @fs_standard_ded_array = 		(0,	167,	167,	167,	181,	212,	243,	243,	243);  #The SNAP standard deductions, per household size, up to 8 people
	our $gross_income_limit_additional = 486; #amount added to the gross income limit for each additional person in the household above 8 people.
	our $net_income_limit_additional = 374; #amount added to the net income limit for each additional person in the household above 8 people.
	our $maxben_additional = 153; #amount added to the maximum benefit for each additional person in the household above 8 people.
    our $fs_earned_ded_per        = 0.20;    # percent of earned income disregarded
    our $fs_max_shelter_ded       = 586;    # max excess shelter deduction
    our $fs_min_ben               = 16;     # Monthly minimum benefit amount (for 1-2-person housholds)
    our $fs_asset_limit           = 2250;   # Maximum assets a household can have to receive SNAP
    our $fs_asset_limit_disability = 3500;   # Maximum assets a household can have to receive SNAP.
	our $bbce_gross_income_pct_max = 2;	# The highest ratio of gross income to the federal poverty allowable that BBCE or other categorical elgibility policies allow to be eligible for SNAP. This absolute number is also important for determining whether families containing people with disabilities pass the asset test.
    our $heatandeat_min           = 20;     # Minimum LIHEAP benefit needed to be categorically eligible to claim SUA for purposes of SNAP benefits, in households that would not otherwise be eligible for the SUA (which predmominantly includes households that pay their heat in rent).
	our $abawd_workreq			= 80;	#Number or hours in a month that able bodied adults without dependents need to work in order to receive more than 3 months of SNAP benefits. We divide this by 4.33 below to compare adults' weekly work schedule to these requirements.

    # outputs created
    our $fsp_recd = 0;          # annual value of food stamps received
    our $fsp_recd_m = 0;        # monthly value of food stamps received
    our $fs_assets = 0;         # assets counted in calculating total income for food stamps/SNAP eligibility

    # Additional variables used within the macro:
	our $abawd1_excluded = 0;
	our $abawd2_excluded = 0;
	our $abawd3_excluded = 0;
	our $abawd4_excluded = 0;
	our $abawds_excluded = 0; # total ABAWDs excluded
	our $fs_earned_income_excluded = 0;
	our $fs_unearned_income_excluded = 0;
	our $abawd_proration_shelter = 0;
    our $fs_gross_income_limit  = 0;    # monthly gross income limit
    our $fs_net_income_limit	= 0;    # monthly net income limit
    our $fs_max_ben				= 0;    # monthly max benefit amount
    our $fs_standard_ded		= 0;    # standard deduction (note: varies by family size beginning FY2003)
    our $fs_gross_income        = 0;    # gross income for food stamps (set to 0 when categorically eligible)
    our $fs_income              = 0;    # gross income for determining deductions and net income
    # (equal to fs_gross_income unless categorically eligible)
    our $minben_flag            = 0;   # flag indicating whether family is categorically eligible for food stamps
    # and has family size of either 1 or 2 and is therefore eligible for a minimum benefit of $16
    our $fs_net_income          = 0;    # adjusted net income for food stamp calculations
    our $fs_shelter_ded_recd    = 0;    # excess shelter deduction
    our $fs_cc_ded_recd         = 0;    # child care deduction
    our $fs_adjusted_income     = 0;    # adjusted income, meaning income inclusive of all deductions except excess shelter deduction 
    our $sua_m                  = 0;    # monthly standard utility allowance used in shelter deduction calculations
    our $fs_perchild_cc_ded     = 0;    # TODO NIP max per child care deduction
    our $fs_under2_add_cc       = 0;    # TODO NIP additional per child care deduction for child <2
	our $energy_cost = 0; 
	our $abawd_proration_dis = 0;
	our $abawd_reincluded = 0;
	our $liheap_recd_snap = 0;
	our $ea_recd_m = 0; # The Emergency Allotment received, as established by FFCRA and later continued through ARPA and subsequent federal action.

	#our $liheap_recd = 0;		# Old, outdated variable, kept in case it becomes useful with later iterations. At one point in this tool's development, we needed to define this variable in this code, and calculate its initial value based on whether the state has a heat and eat program that provides nominal payments from LIHEAP or a local utility subsidy program, conferring eligibility to claim the full SUA in SNAP calculations. But later defined this as "liheap_recd_snap", which serves the same purpose.

	#Adult student note: The below code accounts for ABAWD work requirements in SNAP. College students also face work requirements, and additional restrictions on SNAP eligibility. We are not including these college student restrictions. They would only apply to full time college students. Restrictions do not apply to (a) college students attending college less than half-time do not face these restrictions, (b) students attending vocational certificate programs, (c) college students who are unable to work because of disability status, with disability exemptions wider than just eligibiltiy for SSI or SSDI, (d) parents caring for and living with a child under 6, (e) single parents enrolled full time with a child under 12, (f) parents responsible for a child between 6 and 11 years old who cannot obtain adequate child care, (g) students who are employed at least 20 hours per week, (h) students participating in a state or federal work-study program, (i) students receiving TANF cash assistance OR who have received TANF assistance in the past, or (j) students engaged in SNAP E&T or other work programs. There are simply too many unknowns to ask about in order to accurately account for this restriction. 
	
	#COVID note: This code  code checks for policy variables defined in the frs.pm using the flags users can select in Step 3, to account for whether the user has selected to model COVID-era policy expansions. All these policies have the prefix "covid" in their variable names.
	
    if($in->{'fsp'} != 1) {
        # if food stamp module not used
        $fsp_recd = 0;
        $fsp_recd_m = 0;
    } else {
		#Check for satisfaction of ABAWD work requirements, along with whether user is modeling the exclusion of ABAWDS who don't satsify work requirements (exclude_abawd_provision) AND is not modeling the availability of training to ABAWDS when they work too few hours to qualify for SNAP work requirements (snap_training):
		
		# The exclude_abawd_provision input in the calculator (added beginning with the FRS for KY in 2020) indicates whether the user wants to eclude ABAWDs who are not satisfying work requirements from receving SNAP, assuming that they have run through the 3 months every 3 years that they can get SNAP without satisfying these requirements. In states with no statewide or partial ABAWD waiver, ABAWDs will be facing this requirement once again after any federal waiver due to COVID is lifted.  
		
		#All ABAWD work requirements are suspended during COVID emergency, until the federal decleration of public health emergency has been lifted. The federal government has issued a memorandum indicating the national public health emergency is expected to last through December 2021. 

		if ($in->{'child_number'} == 0 && $in->{'exclude_abawd_provision'} == 1	&& $in->{'snap_training'} == 0 && $in->{'covid_fsp_work_exemption'} == 0) {				  
			for(my $i=1; $i<=4; $i++) {
				if ($in->{'parent'.$i.'_age'} >= 18 && $in->{'parent'.$i.'_age'} <=49) {
					if ($out->{'parent'.$i.'_transhours_w'} < $abawd_workreq/4.33 && $in->{'disability_parent'.$i} == 0){
						# If exclude_abawd_provision = 0, the user is opting to ignore ABAWD requirements, so the following code will not be activated. If exclude_abawd_provision = 1 but snap_training = 1, then the recipient ABAWD will not lose SNAP but will instead opt to attend training to make up the difference in hours. The increased transportation hours that will result from training will be addressed in a repeat of the work code, which will happen sequentially after this SNAP code.
						
						# If this condition is met, we first need to exclude ABAWDS who are not satisyfing work requirements from the household; the possibility for reducting household size is why we need to check this here, near the top of the code, rather than later. We also also need to check the case of a multi-ABAWD HH in which one ABAWD needs to satisfy work reqs, and another doesn't. In this case, one adult can receive some SNAP benefits while the other can't, and part of the excluded individual's income is "deemed" to the included individual's income for calculating eligibility and receipt. 
											
						#We use our disabiltiy_parent[x] here since that input is derived from benefits specific to disability, which seem to all allow an individual to be exempt from SNAP work requirements. 
						
						${'abawd'.$i.'_excluded'} = 1;
						$abawds_excluded += 1;
						#We need to determine the gross income of the excluded individual, in order to prorate the SNAP benefits approprirately. 
						$fs_earned_income_excluded = $out->{'parent'.$i.'_earnings_m'} +  $in->{'parent'.$i.'_selfemployed_netprofit'}/12 - (1- $fs_earned_ded_per)*($out->{'parent'.$i.'_earnings_m'} + $in->{'parent'.$i.'_selfemployed_netprofit'}/12) / $in->{'family_structure'}; #This is income deemed to the second adult in the household. Another way to think about deeming is by defining SNAP's gross income with deeming as  $parent2_earnings_m + (1- $fs_earned_ded_per)*$parent1_earnings/2
						#For unearned income like interest and TANF, we can assume that bank accounts are shared by the household and that these amounts can be split in two. This includes TANF, even though in many states (like NH), families without children cannot get TANF. For simplicity's sake, if translating some of these codes to where states childless households are not eligible for TANF, the TANF variables can be removed from this block referring to ABAWDs. 
						$fs_unearned_income_excluded += ($out->{'interest_m'} + $out->{'gift_income_m'} + &pos_sub($out->{'tanf_recd_m'}, $out->{'noncountable_tanf_income'}) + $in->{'unearn_gross_mon_inc_amt_ag'} + $out->{'tanf_sanctioned_amt'})/$in->{'family_structure'};
						$abawd_proration_shelter += 1/$in->{'family_structure'}; #This is the portion of the deduction that will need to be subtracted from the shelter deducation for non-excluded household members.
					}
				}
			# Commenting out this section because we are not modeling the impact of ABAWD work requirements on people who qualify for  disability medical expenses deductions under SNAP rules but do not qualify for ABAWD exemptions due to disability.
			#if ($in->{'disability_parent1'} + $in->{'disability_parent2'} > 0) {
			#	$abawd_proration_dis = ($in->{'disability_parent1'} * $abawd1_excluded + $in->{'disability_parent2'} * $abawd2_excluded) / ($in->{'disability_parent1'} + $in->{'disability_parent2'});
			#}
			}
		}
		if ($in->{'family_size'} - $abawds_excluded == 0) {
			#If this statement is true, we know that at least one ABAWD in the household is noted as receiving SNAP benefits (since fsp=1, as fsp is the input that, when true (=1), means that the user or dataset has noted tha the household is receiving SNAP benefits) despite not satisfying work requirements. This likely means that at least one person in the household has some exemption we are not account for above in the code (such as participation in a substance abuse treatment program). Since SNAP is given to the household, at this point it makes the most sense to remove the ABAWD exclusions calculated above. 
			$abawd1_excluded = 0;
			$abawd2_excluded = 0;
			$abawd3_excluded = 0;
			$abawd4_excluded = 0;
			$abawds_excluded = 0;
			$abawd_reincluded = 1; #We can use this output for checking how often this reinclusion occurs.
			$fs_earned_income_excluded = 0;
			$fs_unearned_income_excluded = 0;
			$abawd_proration_shelter = 0;
		} else {
			# get variables based on family size
			if ($in->{'family_size'} -  $abawds_excluded <= 8) {
				$fs_gross_income_limit =  $fs_gross_income_limit_array[$in->{'family_size'} -  $abawds_excluded]; 
				$fs_net_income_limit =  $fs_net_income_limit_array[$in->{'family_size'} -  $abawds_excluded]; 
				$fs_max_ben =  $fs_max_ben_array[$in->{'family_size'} -  $abawds_excluded]; 
				$fs_standard_ded =  $fs_standard_ded_array[$in->{'family_size'} -  $abawds_excluded];
			} else {
				$fs_gross_income_limit =  $fs_gross_income_limit_array[8] + $gross_income_limit_additional * ($in->{'family_size'} -  $abawds_excluded - 8); 
				$fs_net_income_limit =  $fs_net_income_limit_array[8] + $net_income_limit_additional * ($in->{'family_size'} -  $abawds_excluded - 8);
				$fs_max_ben =  $fs_max_ben_array[8] + $maxben_additional * ($in->{'family_size'} -  $abawds_excluded - 8);
				$fs_standard_ded =  $fs_standard_ded_array[8];
			}

			#We now raise the maximum SNAP benefit by 15%, based on the American Rescue Plan's changes, which last through September 2021. (After this time, SNAP benefits are set to return to their previous rates plus inflation. But since we don't know the inflation amount, we set it at the previous rate, above.
			if ($in->{'covid_fsp_15percent_expansion'} == 1) {
				$fs_max_ben = $fs_max_ben * 1.15;
			}
			
			# 1. Categorical Eligibility Test


			# Families of 1 or 2 who are categorically eligible but in fact do not qualify for a can receive a minimum benefit ($16 in 2021) if they are either categorically eligible or meet the asset, gross, and net income tests. There is no min benefit for families of more than 2. 

			# set the minben_flag here instead of using the same block of code inside each if-block below
			if($in->{'family_size'} <= 2) {
				$minben_flag = 1;
			}
			#Note: In some states (like DC), no asset test is applied for families that include people with disabilities. In other states, asset tests are applied when gross income exceeds the maximum BBCE gross income limit (which can be above the BBCE gross income limit per state, since for example PA had a BBCE gross income limit of 160% in 2019, whereas the maximum limit is 200%.) In all states, no gross income test is applied to these households.
			$fs_gross_income = &pos_sub($out->{'earnings'}/12 + $in->{'selfemployed_netprofit_total'}/12 + $out->{'interest_m'} + $out->{'gift_income_m'} + $out->{'child_support_recd_m'} + &pos_sub($out->{'tanf_recd_m'}, $out->{'noncountable_tanf_income'}) + $out->{'ssi_recd_mnth'} + $in->{'unearn_gross_mon_inc_amt_ag'} + $out->{'tanf_sanctioned_amt'} + &pos_sub($out->{'ui_recd_m'}, $out->{'fpuc_recd'}/12), $fs_earned_income_excluded + $fs_unearned_income_excluded); 
			
			if(($out->{'tanf_recd'} > 0 && $fs_gross_income < $bbce_gross_income_pct_max * $fs_net_income_limit) || $out->{'ssi_recd_mnth'} > 0 || ($out->{'bbce_disability_no_asset_limit'} == 1 && $in->{'disability_count'} > 0)) { #In states where $bbce_disability_no_asset_limit = 1, households with people with disabilities face no asset test or gross income limit. The MTRC tool does not check for asset limits (since if someone has checked on the SNAP box, we can assume they have already passed any asset test, and we are not building assets in the tool), but if future iterations of this tool were to build in asset tests, this condition should be changed to first testing tanf, ssi, or disability_count, and assigning no gross income to those families. And then, a subcondition (another if-block nested within this if-block) would  check for bbce_disability_no_asset_limit and only assign fs_assets=0 when that condition within this condition is met.
				$fs_assets = 0;
				$fs_gross_income = 0; #Households in which all members receive TANF or SNAP do not need to pass the gross income test.

			} elsif ($fs_gross_income < $out->{'bbce_gross_income_pct'} * $fs_net_income_limit && $out->{'bbce_no_asset_limit'}==1) {  
				$fs_assets = 0;
				$fs_gross_income = 0; 
			} else {
				#ALL STATES
				# asset calculation
				if($out->{'bbce_disability_no_asset_limit'} == 1 && $in->{'disability_count'} > 0) { 
					$fs_assets = 0;
				} else {
					$fs_assets = $in->{'savings'} + $out->{'fs_vehicle1'} + $out->{'fs_vehicle2'}
				}
			}
			# 2. Asset test

			if ($in->{'disability_count'} > 0 && ($fs_assets > $fs_asset_limit_disability && $fs_gross_income > $bbce_gross_income_pct_max * $fs_net_income_limit))  { #Checking for disability.
				$fsp_recd = 0;	
				$fsp_recd_m = 0; 
			} elsif ($fs_assets > $fs_asset_limit && $fs_assets > $out->{'bbce_asset_limit'}) {
				$fsp_recd = 0;	
				$fsp_recd_m = 0; 
			#
			# 3. GROSS INCOME TEST
			#

			} elsif($fs_gross_income > $fs_gross_income_limit) {
				$fsp_recd = 0;
				$fsp_recd_m = 0;
			} else {
				#
				# 4. CALCULATE ADJUSTED INCOME
				#

				$fs_income = &pos_sub($out->{'earnings_mnth'} + $in->{'selfemployed_netprofit_total'}/12 + $out->{'interest_m'} + $out->{'gift_income_m'} + $out->{'child_support_recd_m'} + &pos_sub($out->{'tanf_recd_m'}, $out->{'noncountable_tanf_income'}) + $out->{'ssi_recd_mnth'}  + $in->{'unearn_gross_mon_inc_amt_ag'} +  $out->{'tanf_sanctioned_amt'} + &pos_sub($out->{'ui_recd_m'}, $out->{'fpuc_recd'}/12), $fs_earned_income_excluded + $fs_unearned_income_excluded);

				$fs_adjusted_income = &pos_sub($fs_income, ((pos_sub($out->{'earnings_mnth'} + $in->{'selfemployed_netprofit_total'}/12, $fs_earned_income_excluded)) * $fs_earned_ded_per) + $fs_standard_ded + $out->{'child_care_expenses_m'} + (1- $abawd_proration_dis) * &pos_sub($in->{'disability_medical_expenses_mnth'}, 35)); 

				# 4a. calculate shelter cost for purpose of calculating shelter deduction
				# Incorporate any state or local heat-and-eat nominal payments to confer eligibility for the SUA.
				#
				# Adjusted: When SNAP needs to be run before LIHEAP, the liheap module can later be run to recalculate liheap_recd if LIHEAP is selected as a benefit, but could we use it here to allow for the HCSUA to be claimed in families participating in heat-and-eat programs by families othewise ineligible for it, since all LIHEAP recipients are eligible to receive HCSUA. However, in NH, LIHEAP can be run before SNAP since it does not rely on any variables produced by this module. Also in NH, there is no nominal heat and eat payment. We are including it below to help universalize the code or allow for policy analysis. 
				#			
				if ($out->{'heatandeat_nominal_payment'} >= $heatandeat_min) {
					$liheap_recd_snap =  $out->{'heatandeat_nominal_payment'};
				} else {
					$liheap_recd_snap = $out->{'liheap_recd'};
				}

				if ((($out->{'housing_subsidized'} == 1 && $out->{'rent_difference'} <= 0) || $in->{'heat_in_rent'} == 1) && $liheap_recd_snap  < $heatandeat_min) {
					#This restricts the Heating SUA against people who pay utilities out of their rent (heat-in-rent) and people who are in project-based housing choice or public housing (which we assume when people receive Section 8 and pay at or below the FMR level) from receiving SUAs, unless their state provides heat-and-eat nominal LIHEAP payments. This seems reaonable but needs to be assessed in terms of potential additional SUAs (non heating or cooling) that families might be entitled to.  This is a new condition beginning with the 2019 version of NCCP's Family Resource Simulator, carried over to the MTRC. 
					
					#We now incorporate differnet SUAs. These are the polices for NH, they may be generalized elsewhere as we apply the MTRC to other states. See fsp_assets code for explanations as to why this is applicable.
					if ($in->{'energy_cost_override'} == 0) {
						$sua_m = $out->{'sua_utilities_only'}; #This is 256 for NH.
					} elsif ($in->{'energy_cost_override_amt'} > 0) {
						$sua_m = $out->{'sua_utilities_only'};
					} elsif ($in->{'phone_override'} == 0) {
						$sua_m = $out->{'sua_phoneandinternet_only'};
					} elsif ($in->{'phone_override_amt'} > 0) {
						$sua_m = $out->{'sua_phoneandinternet_only'};
					} else {
						$sua_m = 0;
					}	
				} else {
					$sua_m = $out->{'sua_heat'}; #This is 701 for NH
				}
				
				# Note: There is no cap on the shelter deduction for people with disabilities. The below code also accounts for states that use optional SUAs; for those staes, the dummy variable  is 1; otherwise it is 0 and will not be active in the below calculations.
				# Since FMRs include utilities such as heating and cooling, we cannot include both the FMR and the SUA_m as separate parts of the shelter deduction; that would be double-counting. Instead, unless users enter their own utility costs, we use county PHA’s utility allowances (used in housing programs) for a closer approximation of utility costs than the (inflated) SUAs offer, to separate the rent component of the FMR separate from utilities. For states with a mandatory SUA (when optional_sua_policy = 0), the SUA replaces the cost of utilities as long as individuals pay some of their utility costs. In states that do not have mandatory SUA policies, recipients can claim a higher utility allowance with higher energy bills. In states with "heat-and-eat" program, SNAP recipients who do not pay separate utilities (whose rent includes utilitie) can also claim the SUA because they receive a nominal LIHEAP payment, as federal statutes allow anyone who receives LIHEAP to claim a state's SUA. This is why the beneficiaries of heat-and-eat progrms disproportionaely live in project-based Section 8 or public housing, because many of those buildings include utilities in rent bills. 
				# Please note even though  “housing assistance  payments made through a State or local housing authority” are excluded as SNAP income, since those payments for programs like Section 8 are made by the government to landlords, and not as a pass through to landlords via residents, Section 8 recipients will be able to claim only the amount of (reduced) rent they pay to landlords for this decuction, and not the full value of market rate rent.
				
				if($in->{'energy_cost_override_amt'} > 0) {
					$energy_cost = $in->{'energy_cost_override_amt'};
				} else {
					$energy_cost = $out->{'pha_ua'};
				}
				
				#Note re homeowners: Mortgage costs and payments like property management fees are allowable for the SNAP shelter deduction. As indicated earlier, we are using "rent" to cover recurring homeownership costs as well. 
				
				if($in->{'disability_count'} > 0) { 
					$fs_shelter_ded_recd = (1 - $abawd_proration_shelter) * &pos_sub($out->{'rent_paid_m'} - $energy_cost + &greatest($sua_m, $out->{'$optional_sua_policy'} * $energy_cost), 0.5 * $fs_adjusted_income); 
				} else { 
					$fs_shelter_ded_recd = (1 - $abawd_proration_shelter) * &least($fs_max_shelter_ded, &pos_sub(($out->{'rent_paid_m'} - $energy_cost + &greatest($sua_m,$out->{'optional_sua_policy'} * $energy_cost)), 0.5 * $fs_adjusted_income));
				}
				  # 5. net income test
				$fs_net_income = &pos_sub($fs_adjusted_income, $fs_shelter_ded_recd);

				if($fs_net_income > $fs_net_income_limit && $minben_flag == 0) {
					$fsp_recd = 0;
					$fsp_recd_m = 0;
				} elsif($fs_net_income > $fs_net_income_limit && $minben_flag == 1) {
					$fsp_recd = 12 * $fs_min_ben;
					$fsp_recd_m = $fs_min_ben;
				# 6. Calculate benefits
				} elsif($in->{'family_size'} > 2) {
					$fsp_recd_m = &pos_sub($fs_max_ben, (0.3 * $fs_net_income));
				} else { #Family size is 1 or 2, allowing the family to claim the minimum SNAP benefit.
					print "debug10 \n";
					$fsp_recd_m = &pos_sub($fs_max_ben, (0.3 * $fs_net_income));
					$fsp_recd_m = &greatest($fs_min_ben, $fsp_recd_m);
				}
				print "fsp_recd_m before ea: $fsp_recd_m \n";
				#Adding in Emergency Allotments (EA), which FFCRA expanded such that each SNAP recipient would receive additional EBT assitance so that their SNAP benefit plus EA would equal the maximum SNAP benefit. For those already receiving the maximum SNAP benefit or close to that amount, court ruling and executive orders adjusted this that any SNAP household would receive a minimum of $95 in EA.
				if ($in->{'covid_ea_allotment'} == 1 && $fsp_recd_m > 0) {
					$ea_recd_m = &greatest(95, $fs_max_ben - $fsp_recd_m);
					# We add this amount to the SNAP benefit to get the total "SNAP" benefit provided, even though this is actually the combination of the SNAP benefit plus the Emergency Allotment.
					$fsp_recd_m += $ea_recd_m; 
				}
			}
			
			#Making it annual:
			$fsp_recd = $fsp_recd_m * 12;
		}
	}
	#debugging:
	foreach my $debug (qw(fsp_recd fsp_recd_m fs_assets abawd1_excluded abawd2_excluded abawd3_excluded abawd4_excluded abawd_reincluded fs_gross_income fs_net_income fs_adjusted_income fs_gross_income_limit fs_net_income_limit ea_recd_m)) {
		print $debug.": ".${$debug}."\n";
	}
	
    # outputs
    foreach my $name (qw(fsp_recd fsp_recd_m fs_assets abawd1_excluded abawd2_excluded abawd3_excluded abawd4_excluded abawd_reincluded fs_gross_income fs_net_income fs_adjusted_income fs_gross_income_limit energy_cost)) {
       $out->{$name} = ${$name};
    }
	
}

1;