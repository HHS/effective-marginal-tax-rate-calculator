#=============================================================================#
#  Federal Health Insurance  Module – 2021 
#=============================================================================#
#
# Inputs referenced in this module:
#
# 	FROM USER
#		disability_parent1
#		disability_parent2
#		disability_parent3
#		family_size
#
#	FROM PARENT_EARNINGS
#		parent1_earnings_m
#		parent2_earnings_m
#		parent3_earnings_m
#
#   FROM PARENT EARNINGS
#       earnings_mnth
#
#   FROM INTEREST 
#       interest_m
#
#	FROM SSI
#		ssi_recd
#=============================================================================#


sub fed_hlth_insurance
{
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};

    # outputs created

    our $max_income_pct_employer = 0.0983;    #  Maximum percentage of income dedicated for self-coverage under employer-based. This is the required contribution percentage for the 2019 tax year, as indicated at https://www.irs.gov/pub/irs-drop/rp-18-34.pdf.
                                              #  plan in order to be ineligible for marketplace coverage
    our $magi_disregard =  0.05;              #  MAGI  disregard (as % of FPG)
    our $sub_minimum = 1.0;                   #  Minimum % of income compared to poverty to be eligible for the premium tax credit.
    our $sub_maximum = 4.0;                   #  Maximum % of income compared to poverty to be eligible for the premium tax credit.

    our $medically_needy = 0;                   #  This is a variable that introducing to the 2019 fed health code because some states (like Florida) have Medically Needy provisions in their Medicaid policies, which confer categorical eligibilty to federal progams like Lifeline. In order to make these otehr codes (e.g. Lifeline)  work across states (including Florida), it's important to define this variable somewhere. For states without a medically needy program, it will just stay at 0. 

    # outputs calculated in macro
    our $hlth_gross_income_m = 0;             #   Modified Adjusted Gross Income

    # OTHER VARIABLES USED  
    our @subsidy_pov_level_m = qw(0 1041 1409 1778 2146 2514 2883 3251 3619 3987); 
	# Note about the poverty guidelines used to determine eligibility for premium tax credits: The sources for these 2019 values are https://www.irs.gov/affordable-care-act/individuals-and-families/eligibility-for-the-premium-tax-credit, https://www.irs.gov/affordable-care-act/individuals-and-families/questions-and-answers-on-the-premium-tax-credit, https://www.healthcare.gov/blog/when-is-2019-open-enrollment/, https://www.federalregister.gov/documents/2019/02/01/2019-00621/annual-update-of-the-hhs-poverty-guidelines and https://www.federalregister.gov/documents/2018/01/18/2018-00814/annual-update-of-the-hhs-poverty-guidelines. These IRS documents  indicate that the applicable federal poverty level is the most recently published poverty level at the beginning of the open enrollment period, adn the Q&A document indicates that for 2018, hte most recently published levels were the 2017 federal poverty level. The open enrollment period for 2019 marketplace plans began on 11/1/2018, according to the healthcare link above. The 2019 federeal poverty guidelines were published 2/1/2019, while the 2018 federal poverty guidelines were published on 1/18/18, so the 2018 guidelines apply.
	#2020 values avialable at: https://www.irs.gov/pub/irs-pdf/i8962.pdf 
    our $private_max1 = 0;                     #   Maximum payment toward coverage of Second Lowest Priced Silver Plan
    our $private_max2 = 0;                     #   Maximum payment toward coverage of Second Lowest Priced Silver Plan
    our $private_max3 = 0;                     #   Maximum payment toward coverage of Second Lowest Priced Silver Plan
    our $private_max4 = 0;                     #   Maximum payment toward coverage of Second Lowest Priced Silver Plan
    our $percent_of_poverty1 = 0;              #   Income as representative of  percent of applicable poverty level
    our $percent_of_poverty2 = 0;              #   Income as representative of  percent of applicable poverty level
    our $percent_of_poverty3 = 0;              #   Income as representative of  percent of applicable poverty level
    our $percent_of_poverty4 = 0;              #   Income as representative of  percent of applicable poverty level
	our $subsidy_pov_level1_m = 0;
	our $subsidy_pov_level2_m = 0; 
	our $subsidy_pov_level3_m = 0;
	our $subsidy_pov_level4_m = 0;
	our $hlth_gross_income1_m = 0;
	our $hlth_gross_income2_m = 0;
	our $hlth_gross_income3_m = 0;
	our $hlth_gross_income4_m = 0;	
	our $hlth_gross_income1_m_medicaid = 0;
	our $hlth_gross_income2_m_medicaid = 0;
	our $hlth_gross_income3_m_medicaid = 0;
	our $hlth_gross_income4_m_medicaid = 0;	
	our $percent_of_poverty1_medicaid = 0; 
	our $percent_of_poverty2_medicaid = 0; 
	our $percent_of_poverty3_medicaid = 0; 
	our $percent_of_poverty4_medicaid = 0;
	our $percent_of_poverty_children_medicaid = 0;
	our $percent_of_poverty_parent1_medicaid = 0;
	our $percent_of_poverty_parent2_medicaid = 0;
	our $percent_of_poverty_parent3_medicaid = 0;
	our $percent_of_poverty_parent4_medicaid = 0;
	our $hlth_unit_size1 = 0;
	our $hlth_unit_size2 = 0;
	our $hlth_unit_size3 = 0;
	our $hlth_unit_size4 = 0;	
	our $unit1_recd_ui = 0;
	our $unit2_recd_ui = 0;
	our $unit3_recd_ui = 0;
	our $unit4_recd_ui = 0;
	our $percent_of_poverty_children = 0;
	our $percent_of_poverty_parent1 = 0;
	our $percent_of_poverty_parent2 = 0;
	our $percent_of_poverty_parent3 = 0;
	our $percent_of_poverty_parent4 = 0;
    our $subsidy_pov_level_ssi = 0;
    our $percent_of_poverty_min = 0;          
    our $percent_of_poverty_max = 0;          
    our $premium_cap_pct = 0;                 
	our $percent_of_poverty_ssi = 0;		 
	our $hlth_gross_income_m_ssi = 0;
    our $subsidy_pov_level_m_ssi = qw(0 1041 1409 1778 2146 2514 2883 3251 3619 3987) [($in->{'family_size'} - ($in->{'disability_parent1'} + $in->{'disability_parent2'} + $in->{'disability_parent3'} + $in->{'disability_parent4'})) ]; #This  allows the FRS/MTRC to reassess Medicaid eligibility when families have at least one family member receiving SSI. Whether or not this variable and subsequent variables related to health insurance that use the _ssi suffix are used for a specific state is determined by the hlth codes for each state in any given FRS year. Given research in 2021, this variable may never be invoked, since it seems that states are no longer excluding people with SSI from the Medicaid family unit.
	
    # Debug variables
    our $earnings_mnth = $out->{'earnings_mnth'};
    our $interest_m = $out->{'interest_m'};

    # 1.  Calculate Modified Adjusted Gross Income (MAGI), BY TAX FILING UNIT:

	for(my $i=1; $i<=4; $i++) { 
		if($out->{'filing_status'.$i} ne 'none') { 
			for(my $j=1; $j<=4; $j++) {
				if ($in->{'parent'.$j.'_age'} > -1) {
					if (
					$j == $out->{'filing_status'.$i.'_adult1'} 
					|| ($i==1 && ($j == $out->{'filing_status1_adult2'} 
								|| $j == $out->{'filing_status1_adult3'} 
								|| $j == $out->{'filing_status1_adult4'}))) {
						${'hlth_gross_income'.$i.'_m'} += ($out->{'parent'.$j.'_earnings'} + ($out->{'interest'} + $in->{'unearn_gross_mon_inc_amt_ag'})/$in->{'family_structure'} + &pos_sub($out->{'parent'.$j.'_ui_recd'}, $out->{'parent'.$j.'_fpuc_recd'}) + $in->{'parent'.$j.'_selfemployed_netprofit'})/12;
						${'hlth_gross_income'.$i.'_m_medicaid'} += ($out->{'parent'.$j.'_earnings'} + ($out->{'interest'} + $in->{'unearn_gross_mon_inc_amt_ag'} + $in->{'gift_income'})/$in->{'family_structure'} + &pos_sub($out->{'parent'.$j.'_ui_recd'}, $out->{'parent'.$j.'_fpuc_recd'}) + $in->{'parent'.$j.'_selfemployed_netprofit'})/12; #Some states (like PA) count recurring gift income in Medicaid/CHIP considerations, but federal rules bar states from counting it for the amount of ACA subsidies a family can receive.
						${'hlth_unit_size'.$i} +=1;
						if ($out->{'parent'.$j.'_ui_recd'} > 0) {
							${'unit'.$i.'_recd_ui'} = 1; #This is important just for the ARPA expansion. If the unit received UI, they are treated as having 133% FPL for the purposes of the subsidy.
						#Note that gift income is explicity excluded from MAGI income.
						}
					}
				}
			}
		}
	}
	$hlth_unit_size1 += $in->{'child_number'};

    # 2. Determine potential health care subsidy level 


	for(my $i=1; $i<=$out->{'filers_count'}; $i++) {
		${'subsidy_pov_level'.$i.'_m'} = $subsidy_pov_level_m[${'hlth_unit_size'.$i}]; 		
		${'percent_of_poverty'.$i} = ${'hlth_gross_income'.$i.'_m'} / ${'subsidy_pov_level'.$i.'_m'};
		${'percent_of_poverty'.$i.'_medicaid'} = ${'hlth_gross_income'.$i.'_m_medicaid'} / ${'subsidy_pov_level'.$i.'_m'};
 
		# Use premium_cap table to find applicable premium_cap_pct for 'percent_of_poverty'. This table ashould be derived from the IRS notices regarding employer plan affordability and calculating an individuals's premium tax credit, available for 2020 plans (for open enrollment beginning in November 2019) at https://www.irs.gov/pub/irs-drop/rp-19-29.pdf. This is an annually-issued document. This includes both the required employer contribution level for 2019 (9.86%) as well as the applicable percentages for calcluating the premium tax credit, which are the percentages at 100%, 133%, 150%, 200%, 250%, 300%, and 400%. IRS rule § 36B(b)(3)(A)(i) indicates that between these percentages, the applicable percentages increases linearly, on a sliding scale, allowing for the rest of these rows to be filled in based on this formula.

		#

		if ($in->{'covid_ptc_expansion'} == 0) { #There are the "normal" maximum income payments, but ARPA has superseded these through 2022.
			for (${'percent_of_poverty'.$i}) {
				$premium_cap_pct =  
									($_ < 1)    ?    0 :
									($_ < 1.33)    ? 0.0207 :
									($_ < 1.34)    ? 0.0219 :
									($_ < 1.35)    ? 0.0231 :
									($_ < 1.36)    ? 0.0244 :
									($_ < 1.37)    ? 0.0256 :
									($_ < 1.38)    ? 0.0268 :
									($_ < 1.39)    ? 0.028 :
									($_ < 1.4)    ? 0.0292 :
									($_ < 1.41)    ? 0.0304 :
									($_ < 1.42)    ? 0.0317 :
									($_ < 1.43)    ? 0.0329 :
									($_ < 1.44)    ? 0.0341 :
									($_ < 1.45)    ? 0.0353 :
									($_ < 1.46)    ? 0.0365 :
									($_ < 1.47)    ? 0.0377 :
									($_ < 1.48)    ? 0.039 :
									($_ < 1.49)    ? 0.0402 :
									($_ < 1.5)    ? 0.0414 :
									($_ < 1.51)    ? 0.0419 :
									($_ < 1.52)    ? 0.0424 :
									($_ < 1.53)    ? 0.0428 :
									($_ < 1.54)    ? 0.0433 :
									($_ < 1.55)    ? 0.0438 :
									($_ < 1.56)    ? 0.0443 :
									($_ < 1.57)    ? 0.0447 :
									($_ < 1.58)    ? 0.0452 :
									($_ < 1.59)    ? 0.0457 :
									($_ < 1.6)    ? 0.0462 :
									($_ < 1.61)    ? 0.0466 :
									($_ < 1.62)    ? 0.0471 :
									($_ < 1.63)    ? 0.0476 :
									($_ < 1.64)    ? 0.0481 :
									($_ < 1.65)    ? 0.0485 :
									($_ < 1.66)    ? 0.049 :
									($_ < 1.67)    ? 0.0495 :
									($_ < 1.68)    ? 0.05 :
									($_ < 1.69)    ? 0.0504 :
									($_ < 1.7)    ? 0.0509 :
									($_ < 1.71)    ? 0.0514 :
									($_ < 1.72)    ? 0.0519 :
									($_ < 1.73)    ? 0.0523 :
									($_ < 1.74)    ? 0.0528 :
									($_ < 1.75)    ? 0.0533 :
									($_ < 1.76)    ? 0.0538 :
									($_ < 1.77)    ? 0.0543 :
									($_ < 1.78)    ? 0.0547 :
									($_ < 1.79)    ? 0.0552 :
									($_ < 1.8)    ? 0.0557 :
									($_ < 1.81)    ? 0.0562 :
									($_ < 1.82)    ? 0.0566 :
									($_ < 1.83)    ? 0.0571 :
									($_ < 1.84)    ? 0.0576 :
									($_ < 1.85)    ? 0.0581 :
									($_ < 1.86)    ? 0.0585 :
									($_ < 1.87)    ? 0.059 :
									($_ < 1.88)    ? 0.0595 :
									($_ < 1.89)    ? 0.06 :
									($_ < 1.9)    ? 0.0604 :
									($_ < 1.91)    ? 0.0609 :
									($_ < 1.92)    ? 0.0614 :
									($_ < 1.93)    ? 0.0619 :
									($_ < 1.94)    ? 0.0623 :
									($_ < 1.95)    ? 0.0628 :
									($_ < 1.96)    ? 0.0633 :
									($_ < 1.97)    ? 0.0638 :
									($_ < 1.98)    ? 0.0642 :
									($_ < 1.99)    ? 0.0647 :
									($_ < 2)    ? 0.0652 :
									($_ < 2.01)    ? 0.0656 :
									($_ < 2.02)    ? 0.0659 :
									($_ < 2.03)    ? 0.0663 :
									($_ < 2.04)    ? 0.0666 :
									($_ < 2.05)    ? 0.067 :
									($_ < 2.06)    ? 0.0674 :
									($_ < 2.07)    ? 0.0677 :
									($_ < 2.08)    ? 0.0681 :
									($_ < 2.09)    ? 0.0685 :
									($_ < 2.1)    ? 0.0688 :
									($_ < 2.11)    ? 0.0692 :
									($_ < 2.12)    ? 0.0695 :
									($_ < 2.13)    ? 0.0699 :
									($_ < 2.14)    ? 0.0703 :
									($_ < 2.15)    ? 0.0706 :
									($_ < 2.16)    ? 0.071 :
									($_ < 2.17)    ? 0.0714 :
									($_ < 2.18)    ? 0.0717 :
									($_ < 2.19)    ? 0.0721 :
									($_ < 2.2)    ? 0.0724 :
									($_ < 2.21)    ? 0.0728 :
									($_ < 2.22)    ? 0.0732 :
									($_ < 2.23)    ? 0.0735 :
									($_ < 2.24)    ? 0.0739 :
									($_ < 2.25)    ? 0.0743 :
									($_ < 2.26)    ? 0.0746 :
									($_ < 2.27)    ? 0.075 :
									($_ < 2.28)    ? 0.0753 :
									($_ < 2.29)    ? 0.0757 :
									($_ < 2.3)    ? 0.0761 :
									($_ < 2.31)    ? 0.0764 :
									($_ < 2.32)    ? 0.0768 :
									($_ < 2.33)    ? 0.0771 :
									($_ < 2.34)    ? 0.0775 :
									($_ < 2.35)    ? 0.0779 :
									($_ < 2.36)    ? 0.0782 :
									($_ < 2.37)    ? 0.0786 :
									($_ < 2.38)    ? 0.079 :
									($_ < 2.39)    ? 0.0793 :
									($_ < 2.4)    ? 0.0797 :
									($_ < 2.41)    ? 0.08 :
									($_ < 2.42)    ? 0.0804 :
									($_ < 2.43)    ? 0.0808 :
									($_ < 2.44)    ? 0.0811 :
									($_ < 2.45)    ? 0.0815 :
									($_ < 2.46)    ? 0.0819 :
									($_ < 2.47)    ? 0.0822 :
									($_ < 2.48)    ? 0.0826 :
									($_ < 2.49)    ? 0.0829 :
									($_ < 2.5)    ? 0.0833 :
									($_ < 2.51)    ? 0.0836 :
									($_ < 2.52)    ? 0.0839 :
									($_ < 2.53)    ? 0.0842 :
									($_ < 2.54)    ? 0.0845 :
									($_ < 2.55)    ? 0.0848 :
									($_ < 2.56)    ? 0.0851 :
									($_ < 2.57)    ? 0.0854 :
									($_ < 2.58)    ? 0.0857 :
									($_ < 2.59)    ? 0.086 :
									($_ < 2.6)    ? 0.0863 :
									($_ < 2.61)    ? 0.0866 :
									($_ < 2.62)    ? 0.0869 :
									($_ < 2.63)    ? 0.0872 :
									($_ < 2.64)    ? 0.0875 :
									($_ < 2.65)    ? 0.0878 :
									($_ < 2.66)    ? 0.0881 :
									($_ < 2.67)    ? 0.0884 :
									($_ < 2.68)    ? 0.0887 :
									($_ < 2.69)    ? 0.089 :
									($_ < 2.7)    ? 0.0893 :
									($_ < 2.71)    ? 0.0896 :
									($_ < 2.72)    ? 0.0899 :
									($_ < 2.73)    ? 0.0902 :
									($_ < 2.74)    ? 0.0905 :
									($_ < 2.75)    ? 0.0908 :
									($_ < 2.76)    ? 0.0911 :
									($_ < 2.77)    ? 0.0914 :
									($_ < 2.78)    ? 0.0917 :
									($_ < 2.79)    ? 0.092 :
									($_ < 2.8)    ? 0.0923 :
									($_ < 2.81)    ? 0.0926 :
									($_ < 2.82)    ? 0.0929 :
									($_ < 2.83)    ? 0.0932 :
									($_ < 2.84)    ? 0.0935 :
									($_ < 2.85)    ? 0.0938 :
									($_ < 2.86)    ? 0.0941 :
									($_ < 2.87)    ? 0.0944 :
									($_ < 2.88)    ? 0.0947 :
									($_ < 2.89)    ? 0.095 :
									($_ < 2.9)    ? 0.0953 :
									($_ < 2.91)    ? 0.0956 :
									($_ < 2.92)    ? 0.0959 :
									($_ < 2.93)    ? 0.0962 :
									($_ < 2.94)    ? 0.0965 :
									($_ < 2.95)    ? 0.0968 :
									($_ < 2.96)    ? 0.0971 :
									($_ < 2.97)    ? 0.0974 :
									($_ < 2.98)    ? 0.0977 :
									($_ < 2.99)    ? 0.098 :
									($_ < 3)    ? 0.0983 :
									($_ < 4)    ?    0.0983 :
													   0;
			}
		} else {
			for (${'percent_of_poverty'.$i}) {
				$premium_cap_pct =  
									($_ < 1.5)    ? 0 :
									($_ < 1.51)    ? 0.0004 :
									($_ < 1.52)    ? 0.0008 :
									($_ < 1.53)    ? 0.0012 :
									($_ < 1.54)    ? 0.0016 :
									($_ < 1.55)    ? 0.002 :
									($_ < 1.56)    ? 0.0024 :
									($_ < 1.57)    ? 0.0028 :
									($_ < 1.58)    ? 0.0032 :
									($_ < 1.59)    ? 0.0036 :
									($_ < 1.6)    ? 0.004 :
									($_ < 1.61)    ? 0.0044 :
									($_ < 1.62)    ? 0.0048 :
									($_ < 1.63)    ? 0.0052 :
									($_ < 1.64)    ? 0.0056 :
									($_ < 1.65)    ? 0.006 :
									($_ < 1.66)    ? 0.0064 :
									($_ < 1.67)    ? 0.0068 :
									($_ < 1.68)    ? 0.0072 :
									($_ < 1.69)    ? 0.0076 :
									($_ < 1.7)    ? 0.008 :
									($_ < 1.71)    ? 0.0084 :
									($_ < 1.72)    ? 0.0088 :
									($_ < 1.73)    ? 0.0092 :
									($_ < 1.74)    ? 0.0096 :
									($_ < 1.75)    ? 0.01 :
									($_ < 1.76)    ? 0.0104 :
									($_ < 1.77)    ? 0.0108 :
									($_ < 1.78)    ? 0.0112 :
									($_ < 1.79)    ? 0.0116 :
									($_ < 1.8)    ? 0.012 :
									($_ < 1.81)    ? 0.0124 :
									($_ < 1.82)    ? 0.0128 :
									($_ < 1.83)    ? 0.0132 :
									($_ < 1.84)    ? 0.0136 :
									($_ < 1.85)    ? 0.014 :
									($_ < 1.86)    ? 0.0144 :
									($_ < 1.87)    ? 0.0148 :
									($_ < 1.88)    ? 0.0152 :
									($_ < 1.89)    ? 0.0156 :
									($_ < 1.9)    ? 0.016 :
									($_ < 1.91)    ? 0.0164 :
									($_ < 1.92)    ? 0.0168 :
									($_ < 1.93)    ? 0.0172 :
									($_ < 1.94)    ? 0.0176 :
									($_ < 1.95)    ? 0.018 :
									($_ < 1.96)    ? 0.0184 :
									($_ < 1.97)    ? 0.0188 :
									($_ < 1.98)    ? 0.0192 :
									($_ < 1.99)    ? 0.0196 :
									($_ < 2)    ? 0.02 :
									($_ < 2.01)    ? 0.0204 :
									($_ < 2.02)    ? 0.0208 :
									($_ < 2.03)    ? 0.0212 :
									($_ < 2.04)    ? 0.0216 :
									($_ < 2.05)    ? 0.022 :
									($_ < 2.06)    ? 0.0224 :
									($_ < 2.07)    ? 0.0228 :
									($_ < 2.08)    ? 0.0232 :
									($_ < 2.09)    ? 0.0236 :
									($_ < 2.1)    ? 0.024 :
									($_ < 2.11)    ? 0.0244 :
									($_ < 2.12)    ? 0.0248 :
									($_ < 2.13)    ? 0.0252 :
									($_ < 2.14)    ? 0.0256 :
									($_ < 2.15)    ? 0.026 :
									($_ < 2.16)    ? 0.0264 :
									($_ < 2.17)    ? 0.0268 :
									($_ < 2.18)    ? 0.0272 :
									($_ < 2.19)    ? 0.0276 :
									($_ < 2.2)    ? 0.028 :
									($_ < 2.21)    ? 0.0284 :
									($_ < 2.22)    ? 0.0288 :
									($_ < 2.23)    ? 0.0292 :
									($_ < 2.24)    ? 0.0296 :
									($_ < 2.25)    ? 0.03 :
									($_ < 2.26)    ? 0.0304 :
									($_ < 2.27)    ? 0.0308 :
									($_ < 2.28)    ? 0.0312 :
									($_ < 2.29)    ? 0.0316 :
									($_ < 2.3)    ? 0.032 :
									($_ < 2.31)    ? 0.0324 :
									($_ < 2.32)    ? 0.0328 :
									($_ < 2.33)    ? 0.0332 :
									($_ < 2.34)    ? 0.0336 :
									($_ < 2.35)    ? 0.034 :
									($_ < 2.36)    ? 0.0344 :
									($_ < 2.37)    ? 0.0348 :
									($_ < 2.38)    ? 0.0352 :
									($_ < 2.39)    ? 0.0356 :
									($_ < 2.4)    ? 0.036 :
									($_ < 2.41)    ? 0.0364 :
									($_ < 2.42)    ? 0.0368 :
									($_ < 2.43)    ? 0.0372 :
									($_ < 2.44)    ? 0.0376 :
									($_ < 2.45)    ? 0.038 :
									($_ < 2.46)    ? 0.0384 :
									($_ < 2.47)    ? 0.0388 :
									($_ < 2.48)    ? 0.0392 :
									($_ < 2.49)    ? 0.0396 :
									($_ < 2.5)    ? 0.04 :
									($_ < 2.51)    ? 0.0404 :
									($_ < 2.52)    ? 0.0408 :
									($_ < 2.53)    ? 0.0412 :
									($_ < 2.54)    ? 0.0416 :
									($_ < 2.55)    ? 0.042 :
									($_ < 2.56)    ? 0.0424 :
									($_ < 2.57)    ? 0.0428 :
									($_ < 2.58)    ? 0.0432 :
									($_ < 2.59)    ? 0.0436 :
									($_ < 2.6)    ? 0.044 :
									($_ < 2.61)    ? 0.0444 :
									($_ < 2.62)    ? 0.0448 :
									($_ < 2.63)    ? 0.0452 :
									($_ < 2.64)    ? 0.0456 :
									($_ < 2.65)    ? 0.046 :
									($_ < 2.66)    ? 0.0464 :
									($_ < 2.67)    ? 0.0468 :
									($_ < 2.68)    ? 0.0472 :
									($_ < 2.69)    ? 0.0476 :
									($_ < 2.7)    ? 0.048 :
									($_ < 2.71)    ? 0.0484 :
									($_ < 2.72)    ? 0.0488 :
									($_ < 2.73)    ? 0.0492 :
									($_ < 2.74)    ? 0.0496 :
									($_ < 2.75)    ? 0.05 :
									($_ < 2.76)    ? 0.0504 :
									($_ < 2.77)    ? 0.0508 :
									($_ < 2.78)    ? 0.0512 :
									($_ < 2.79)    ? 0.0516 :
									($_ < 2.8)    ? 0.052 :
									($_ < 2.81)    ? 0.0524 :
									($_ < 2.82)    ? 0.0528 :
									($_ < 2.83)    ? 0.0532 :
									($_ < 2.84)    ? 0.0536 :
									($_ < 2.85)    ? 0.054 :
									($_ < 2.86)    ? 0.0544 :
									($_ < 2.87)    ? 0.0548 :
									($_ < 2.88)    ? 0.0552 :
									($_ < 2.89)    ? 0.0556 :
									($_ < 2.9)    ? 0.056 :
									($_ < 2.91)    ? 0.0564 :
									($_ < 2.92)    ? 0.0568 :
									($_ < 2.93)    ? 0.0572 :
									($_ < 2.94)    ? 0.0576 :
									($_ < 2.95)    ? 0.058 :
									($_ < 2.96)    ? 0.0584 :
									($_ < 2.97)    ? 0.0588 :
									($_ < 2.98)    ? 0.0592 :
									($_ < 2.99)    ? 0.0596 :
									($_ < 3)    ? 0.06 :
									($_ < 3.01)    ? 0.0603 :
									($_ < 3.02)    ? 0.0605 :
									($_ < 3.03)    ? 0.0608 :
									($_ < 3.04)    ? 0.061 :
									($_ < 3.05)    ? 0.0613 :
									($_ < 3.06)    ? 0.0615 :
									($_ < 3.07)    ? 0.0618 :
									($_ < 3.08)    ? 0.062 :
									($_ < 3.09)    ? 0.0623 :
									($_ < 3.1)    ? 0.0625 :
									($_ < 3.11)    ? 0.0628 :
									($_ < 3.12)    ? 0.063 :
									($_ < 3.13)    ? 0.0633 :
									($_ < 3.14)    ? 0.0635 :
									($_ < 3.15)    ? 0.0638 :
									($_ < 3.16)    ? 0.064 :
									($_ < 3.17)    ? 0.0643 :
									($_ < 3.18)    ? 0.0645 :
									($_ < 3.19)    ? 0.0648 :
									($_ < 3.2)    ? 0.065 :
									($_ < 3.21)    ? 0.0653 :
									($_ < 3.22)    ? 0.0655 :
									($_ < 3.23)    ? 0.0658 :
									($_ < 3.24)    ? 0.066 :
									($_ < 3.25)    ? 0.0663 :
									($_ < 3.26)    ? 0.0665 :
									($_ < 3.27)    ? 0.0668 :
									($_ < 3.28)    ? 0.067 :
									($_ < 3.29)    ? 0.0673 :
									($_ < 3.3)    ? 0.0675 :
									($_ < 3.31)    ? 0.0678 :
									($_ < 3.32)    ? 0.068 :
									($_ < 3.33)    ? 0.0683 :
									($_ < 3.34)    ? 0.0685 :
									($_ < 3.35)    ? 0.0688 :
									($_ < 3.36)    ? 0.069 :
									($_ < 3.37)    ? 0.0693 :
									($_ < 3.38)    ? 0.0695 :
									($_ < 3.39)    ? 0.0698 :
									($_ < 3.4)    ? 0.07 :
									($_ < 3.41)    ? 0.0703 :
									($_ < 3.42)    ? 0.0705 :
									($_ < 3.43)    ? 0.0708 :
									($_ < 3.44)    ? 0.071 :
									($_ < 3.45)    ? 0.0713 :
									($_ < 3.46)    ? 0.0715 :
									($_ < 3.47)    ? 0.0718 :
									($_ < 3.48)    ? 0.072 :
									($_ < 3.49)    ? 0.0723 :
									($_ < 3.5)    ? 0.0725 :
									($_ < 3.51)    ? 0.0728 :
									($_ < 3.52)    ? 0.073 :
									($_ < 3.53)    ? 0.0733 :
									($_ < 3.54)    ? 0.0735 :
									($_ < 3.55)    ? 0.0738 :
									($_ < 3.56)    ? 0.074 :
									($_ < 3.57)    ? 0.0743 :
									($_ < 3.58)    ? 0.0745 :
									($_ < 3.59)    ? 0.0748 :
									($_ < 3.6)    ? 0.075 :
									($_ < 3.61)    ? 0.0753 :
									($_ < 3.62)    ? 0.0755 :
									($_ < 3.63)    ? 0.0758 :
									($_ < 3.64)    ? 0.076 :
									($_ < 3.65)    ? 0.0763 :
									($_ < 3.66)    ? 0.0765 :
									($_ < 3.67)    ? 0.0768 :
									($_ < 3.68)    ? 0.077 :
									($_ < 3.69)    ? 0.0773 :
									($_ < 3.7)    ? 0.0775 :
									($_ < 3.71)    ? 0.0778 :
									($_ < 3.72)    ? 0.078 :
									($_ < 3.73)    ? 0.0783 :
									($_ < 3.74)    ? 0.0785 :
									($_ < 3.75)    ? 0.0788 :
									($_ < 3.76)    ? 0.079 :
									($_ < 3.77)    ? 0.0793 :
									($_ < 3.78)    ? 0.0795 :
									($_ < 3.79)    ? 0.0798 :
									($_ < 3.8)    ? 0.08 :
									($_ < 3.81)    ? 0.0803 :
									($_ < 3.82)    ? 0.0805 :
									($_ < 3.83)    ? 0.0808 :
									($_ < 3.84)    ? 0.081 :
									($_ < 3.85)    ? 0.0813 :
									($_ < 3.86)    ? 0.0815 :
									($_ < 3.87)    ? 0.0818 :
									($_ < 3.88)    ? 0.082 :
									($_ < 3.89)    ? 0.0823 :
									($_ < 3.9)    ? 0.0825 :
									($_ < 3.91)    ? 0.0828 :
									($_ < 3.92)    ? 0.083 :
									($_ < 3.93)    ? 0.0833 :
									($_ < 3.94)    ? 0.0835 :
									($_ < 3.95)    ? 0.0838 :
									($_ < 3.96)    ? 0.084 :
									($_ < 3.97)    ? 0.0843 :
									($_ < 3.98)    ? 0.0845 :
									($_ < 3.99)    ? 0.0848 :
									($_ < 4)    ? 0.085 :
												.085; # A main difference is that there is no cliff at 400% FPL.
			}
			
			if (${'unit'.$i.'_recd_ui'} == 1 && $in->{'covid_ptc_ui_expansion'} == 1) {
				$premium_cap_pct = 0; #Under ARPA, any taxpayer -- which is defined by the applicable health law as either a one-person filer or either filer in an application -- that receives UI cannot have the subsidy calculated as if their income exceeds 133 percent of the poverty rate. Under the same ARPA section, the maximum payment for premiums for 133% of the federal poverty level is 0% of income. This means that anyone receiving UI who did not have acces to employer insurance during 2021.  
			}
		}
		${'private_max'.$i} = $premium_cap_pct * ${'hlth_gross_income'.$i.'_m'} * 12;
	}
	
	if ($in->{'child_number'} > 0)  {
		$percent_of_poverty_children = $percent_of_poverty1;
		$percent_of_poverty_children_medicaid = $percent_of_poverty1_medicaid;
	}
	for(my $i=1; $i<=4; $i++) {
		if ($i == $out->{'filing_status1_adult1'} || $i == $out->{'filing_status1_adult2'} || $i == $out->{'filing_status1_adult3'} || $i == $out->{'filing_status1_adult4'}) {
			${'percent_of_poverty_parent'.$i} = $percent_of_poverty1;
			${'percent_of_poverty_parent'.$i.'_medicaid'} = $percent_of_poverty1_medicaid;
		} elsif ($i == $out->{'filing_status2_adult1'}) {
			${'percent_of_poverty_parent'.$i} = $percent_of_poverty2;
			${'percent_of_poverty_parent'.$i.'_medicaid'} = $percent_of_poverty2_medicaid;
		} elsif ($i == $out->{'filing_status3_adult1'}) {
			${'percent_of_poverty_parent'.$i} = $percent_of_poverty3;
			${'percent_of_poverty_parent'.$i.'_medicaid'} = $percent_of_poverty3_medicaid;
		} elsif ($i == $out->{'filing_status4_adult1'}) {
			${'percent_of_poverty_parent'.$i} = $percent_of_poverty4;
			${'percent_of_poverty_parent'.$i.'_medicaid'} = $percent_of_poverty4_medicaid;
		}
	}


	
	if ($out->{'ssi_recd'} > 0 && ($in->{'family_size'} - ($in->{'disability_parent1'} + $in->{'disability_parent2'} + $in->{'disability_parent3'} + $in->{'disability_parent4'})) > 0) { #See note above and in the hlth code to use this calculation in some states that treat SSI recipients in a family separately than non-SSI receipients. The inequality is important here because otherwise, we could possibly divide by 0.
	#
		$hlth_gross_income_m_ssi = $hlth_gross_income_m;
		if ($in->{'disability_parent1'} == 1) {
			$hlth_gross_income_m_ssi = &pos_sub($hlth_gross_income_m_ssi, $out->{'parent1_earnings_m'} + $out->{'parent1_ui_recd'});
		}
		if ($in->{'disability_parent2'} == 1) {
			$hlth_gross_income_m_ssi = &pos_sub($hlth_gross_income_m_ssi, $out->{'parent2_earnings_m'}  + $out->{'parent2_ui_recd'});
		}
		if ($in->{'disability_parent3'} == 1) {
			$hlth_gross_income_m_ssi = &pos_sub($hlth_gross_income_m_ssi, $out->{'parent3_earnings_m'}  + $out->{'parent3_ui_recd'});
		}
		if ($in->{'disability_parent4'} == 1) {
			$hlth_gross_income_m_ssi = &pos_sub($hlth_gross_income_m_ssi, $out->{'parent4_earnings_m'}  + $out->{'parent4_ui_recd'});
		}
		
		$percent_of_poverty_ssi = $hlth_gross_income_m_ssi / $subsidy_pov_level_m_ssi;
									  
	}

	#debugging
	foreach my $debug (qw(percent_of_poverty_children percent_of_poverty_parent1 percent_of_poverty_parent2 hlth_unit_size1 percent_of_poverty2 percent_of_poverty_parent1_medicaid)) {
		print $debug.": ".${$debug}."\n";
	}
	
  # outputs
    foreach my $name (qw(max_income_pct_employer magi_disregard sub_minimum sub_maximum  percent_of_poverty_ssi medically_needy
	private_max1
    private_max2 
    private_max3 
    private_max4 
	percent_of_poverty1 
	percent_of_poverty2 
	percent_of_poverty3 
	percent_of_poverty4 
	subsidy_pov_level1_m 
	subsidy_pov_level2_m 
	subsidy_pov_level3_m 
	subsidy_pov_level4_m 
	hlth_gross_income1_m 
	hlth_gross_income2_m
	hlth_gross_income3_m
	hlth_gross_income4_m 
	hlth_unit_size1 
	hlth_unit_size2 
	hlth_unit_size3 
	hlth_unit_size4
	percent_of_poverty_children 
	percent_of_poverty_parent1
	percent_of_poverty_parent2
	percent_of_poverty_parent3
	percent_of_poverty_parent4 	
	hlth_gross_income1_m_medicaid
	hlth_gross_income2_m_medicaid
	hlth_gross_income3_m_medicaid
	hlth_gross_income4_m_medicaid	
	percent_of_poverty1_medicaid  
	percent_of_poverty2_medicaid  
	percent_of_poverty3_medicaid  
	percent_of_poverty4_medicaid 
	percent_of_poverty_children_medicaid 
	percent_of_poverty_parent1_medicaid 
	percent_of_poverty_parent2_medicaid 
	percent_of_poverty_parent3_medicaid 
	percent_of_poverty_parent4_medicaid 
	)) {
       $out->{$name} = ${$name};
    }
	
}

1;