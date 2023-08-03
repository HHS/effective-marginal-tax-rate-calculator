#=============================================================================#
#  WIC (Women, Infants and Children) Module – 2021 
#=============================================================================#
# INPUTS OR OUTPUTS USED IN THIS MODULE:
#
# INPUTS FROM USER INTERFACE:
# 	child#_age
# 	wic
#	breastfeeding    	
#
# INPUTS FROM FRS.PM
# 	fpl
#	selfemployed_netprofit_total
#
# OUTPUTS FROM FRS.PL
#	earnings
#
# OUTPUTS FROM INTEREST
# 	interest
#
# OUPUTS FROM SSI
#	ssi_recd
# 
# OUTPUTS FROM HEALTH
#	hlth_cov_parent#
#	hlth_cov_child#
#
# OUTPUTS FROM FOOD STAMPS
#	fsp_recd
#
# OUTPUTS FROM TANF
#	tanf_recd
#	child_support_recd
#
# OUTPUTS FROM UI
#	ui_recd
#=============================================================================#

sub wic
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	#  my $dbh = $self->{'dbh'};

	# outputs created
	# Historical and methdologolical note: NCCP first started incorporating WIC into the FRS in the DC 2017 model, using estimates that included no methodology. The 2019 estimates come from  https://fns-prod.azureedge.net/sites/default/files/ops/WICFoodPackageCost2014.pdf, a much more rigorous study that included greater specificity. We have simplified the data from Table 3.2 for FRS users. This also assumes that a child just turned the age he is. (For exmaple, an infant is modeled as being just born; a 4-yo is not modeled as ever turning 5. Mothers are either partially or fully breastfeeding, but not partially breastfeeding. Conceivably we could build greater specficity into the model.)
	#The below figures are from the 2018 (latest) WIC study, table 4.2. Previous figures were from 2014 study, table 3.1.
    our $wic_breastfeeding = 48.92; #Group VII: Women who are fully breastfeeding [or] pregnant with, or partially (mostly) breastfeeding multiples; #  There seems to be a grammar errror introduced in the 2018 report compared to the 2014 report, but elsewhere the report clarifies that Group VII indeed includes fully breastfeeding women. 
    our $wic_notbreastfeeding = 32.27;   	# estimated monthly food package costs for Group VI, "Nonbreastfeeding postpartum; partially (minimally) breastfeeding (up to 6 months postpartum)."
    our $wic_breastfedinfants = 44; # estimated monthly food package costs for Group II-BF, fully breastfed infants 6-11.9 months. Note that the benefit is only for 6 months, since the infant is breastfed before then. 
    our $wic_formulafedinfants = 168.43; # estimated monthly food package costs for Group II-FF, fully formula-fed infants. This represents a weigthed average based on costs for formula fed infants 0-3.9 months (group II-FF-A), 4-5.9 months (group II-FF-B), and 6-11.9 months (group II-FF), to account for a monthly average. In 2018: (175.27 * 4 +  188.54 * 2 + 157.16 * 6) / 12 = 168.43 
    our $wic_1yochild = 33.64;   	# estimated monthly food package costs for Group IV-A, Children 1-1.9 years. 
    our $wic_2to4yochild = 33.65;   # estimated monthly food package costs for Group IV-B, Children 2-4.9 years. 
	our $foodathomecpi2018 = 240.147; # Needed to account for inflation from WIC study. Food at home CPI for all urban customers. Source: https://fred.stlouisfed.org/series/CUSR0000SAF11, from US BLS CPI estimates.
	our $foodathomecpi = 254.931; # Food at home CPI for all urban customers.  Source: https://fred.stlouisfed.org/series/CUSR0000SAF11, from US BLS CPI estimates. Updated 4/2021.
	#
    our $wic_inc_limit = 1.85;     	# The income eligibility limit as a % of federal poverty guideline.
    our $wic_income = 0;		# countable WIC income per FNS guidelines
    our $wic_recd = 0;             #  Estimated monetary value of WIC
	our $wic_mother_counted = 0;

	# RECERTIFICATION NOTE: Recertification occurs once  every 6 months to a year, see https://www.fns.usda.gov/wic/who-gets-wic-and-how-apply. Also according to that list, there can be waiting periods if enough people apply to WIC.
	#
	# POLICY NOTE REGARDING FARMER'S MARKET BENEFITS: In some areas, like DC, there are also farmer’s market nutrition program (FMNP), see https://www.fns.usda.gov/fmnp/wic-farmers-market-nutrition-program-fmnp. We are not including this benefit separately for now, given that we are relying on the aforementioned study to estimate the benefits from the WIC program. 

	# POLICY NOTE: WIC is not an entitlement. https://www.fns.usda.gov/wic/about-wic-wic-glance. But coverage rate is fairly high, according to USDA study posted on website, at about 60 percent of eligible, and about 85 percent of women and infants eligible.

	#  For the time being, we are then assuming that all dietary eligibility guidelines are met in all jurisdictions. See "Estimating Eligibility and Participation for the WIC Program: Final Report," (2002), Chapter 7, at https://www.ncbi.nlm.nih.gov/books/NBK221951/#ddd00086. For example, in DC, the state/jurisdiction we first used for an FRS WIC module, we found that WIC Policy & Procedure Number 8.007, page 18, makes it clear that administrators assume nutritional or medical conditions are met for all WIC applicants with children of eligible ages. Despite clear guidelines on how to fill out the dietary and nutritional assessments, it appears that when families apply for WIC, nearly all pregnant and postpardum mothers, and all children under 6, are eligible for the program when dietary eligibility guidelines are appropriately followed by the certified professional administrators (CPAs) at WIC offices.

	# Certain applicants can be determined income-eligible for WIC based on their participation in certain programs. These included individuals: 
	# * eligible to receive SNAP benefits, Medicaid, for Temporary Assistance for Needy Families (TANF, formerly known as AFDC, Aid to Families with Dependent Children),
	# * in which certain family members are eligible to receive Medicaid or TANF, or
	# * at State agency option, individuals that are eligible to participate in certain other State-administered programs.
	
	# POLICY NOTE: States with SNAP/TANF BBCE also increase WIC eligibility, and states can also confer WIC to families making under Medicaid income limits. Each child on Medicaid adds more to WIC benefits. There has been some literature on this but have concluded that Medicaid expansions above WIC guidelines likely do not increase WIC takeup because above 185% of poverty, most parents are on employer insurance.

	#
	# 1: Check for WIC flag
	#
	# WIC
	if ($in->{'wic'} == 0) {
		$wic_recd = 0;
	} else {
		# Determine countable income for determining WIC eligibility. Per https://www.fns.usda.gov/sites/default/files/2013-3-IncomeEligibilityGuidance.pdf.
		$wic_income  = $out->{'earnings'} + $in->{'selfemployed_netprofit_total'} + $out->{'ssi_recd'}+ $out->{'interest'}+ $out->{'tanf_recd'}+$out->{'child_support_recd'} + $out->{'ui_recd'} + $out->{'gift_income'}; 
		#COVID note: unlike SNAP and some other federal programs, the FPUC payments are not exempt from the calculation of income for WIC.
		#Gift income note: how gifts are counted may vary by state. In PA, it is counted as lump sum income in WIC.

		#1 . Mothers of infants:
		for(my $i=1; $i<=5; $i++) {
			if($in->{'child' . $i . '_age'} == 0) {
				#It seems safe to assume that if the household is receiving WIC, one and exactly one individual in the household will qualify for WIC by merit of being the mother of infant(s) in the household. That mother will be in tax filing unit 1, since all children are in tax filing unit 1. They will be assigned either filing status 1 in that home or, if married, filing status 2. We are only counting one mother, hence the "wic_mother_counted" variable that will limit WIC receipt to one instance. This approach will miss some instances -- for example, if an adult child is using the tool for their household, which includes their mother and an infant child
				for(my $j=1; $j<=$in->{'family_structure'}; $j++) {
					if ($wic_mother_counted == 0 && $j == $out->{'filing_status1_adult1'} || ($j == $out->{'filing_status1_adult2'} && ($j == $in->{'married1'} || $j == $in->{'married2'}))) {
						if ($wic_income / $in->{'fpl'} <= $wic_inc_limit || $out->{'hlth_cov_parent'.$j} eq 'Medicaid' || $out->{'fsp_recd'} > 0 || $out->{'tanf_recd'} > 0) { #This seems to match federal regulations for income, as captured in regulations for other states as well.
							$wic_mother_counted = 1;
							if ($in->{'breastfeeding'}==1) {
								$wic_recd += $wic_breastfeeding * 12;
							} else {
								# Non-breastfeeding mothers are only eligible to receive up to 6 months of WIC.
								$wic_recd += $wic_notbreastfeeding  * 6;
							}
						}
					}
				}
			}
		}

		# 2: Determine eligibility and benefit for children. 
		
		for(my $i=1; $i<=5; $i++) {
			if($in->{'child' . $i . '_age'} != -1 && $in->{'child' . $i . '_age'} < 5) {
				if ($wic_income / $in->{'fpl'} <= $wic_inc_limit || $out->{'fsp_recd'} > 0 || $out->{'tanf_recd'} > 0 || $out->{'hlth_cov_child'. $i } eq 'Medicaid' || ($out->{'wic_elig_nslp'} == 1 && $out->{'child' . $i . '_lunch_red'} > 0)) { 
					if ($in->{'child' . $i . '_age'} ==0) {
						if ($in->{'breastfeeding'}==1) {
							$wic_recd = $wic_recd + $wic_breastfedinfants * 6;
						} else {
							$wic_recd = $wic_recd + $wic_formulafedinfants * 12;
						}
					} elsif ($in->{'child' . $i . '_age'} == 1) {
							$wic_recd = $wic_recd + $wic_1yochild * 12;
					} else {
						$wic_recd = $wic_recd + $wic_2to4yochild * 12;
					}
				}
			}
		}
		# Adjust for inflation since 2014, since the study we are drawing this model from uses 2014 figures.
		$wic_recd = &round($wic_recd * $foodathomecpi / $foodathomecpi2018);
	}

	#debugging:
	foreach my $debug (qw(wic_recd)) {
		print $debug.": ".${$debug}."\n";
	}
	
	# outputs
	foreach my $name (qw(wic_recd)) {
       $out->{$name} = ${$name};
    }
	
}

1;