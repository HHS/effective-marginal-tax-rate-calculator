#=============================================================================#
#  UI Module -- ME 2021
#=============================================================================#
#
# Inputs referenced in this module:
#
#   FROM BASE
#	ui
#	parent1_ui_recd_wk_initial
#	parent2_ui_recd_wk_initial
#	parent1_unemployed_weeks			#The number of weeks the person or person being modeled has been receiving unemployment prior to using the tool. We can assume a default of  0 weeks to compare the cliff from leaving unemployment to working at a wage for a year. 
#	parent2_unemployed_weeks
#=============================================================================#

sub unemployment
{
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# This subroutine is new for 2021 and is especially important to include in light of the COVID-19 pandemic.
	# We are starting with a state-by-state approach but may end up creating a more generic code that uses state variables defined or hard-coded elsewhere.
	

	# VARIABLES NEEDED FOR MACRO: hard-coded outputs that would need to be updated to keep code up-to-date
	our $fulltime_hours = 35; #The amount of hours under which an individual is never considered working full time, meaning that they will still be considered to be working part time in Maine's unemployment law.
	our $ui_benefit_year = 26; #"Benefit Year: Runs 52 weeks from the Sunday of the week in which you file your Initial Claim. You may be eligible for up to 26 full benefit payments during your Benefit Year." So over the course of a year, under normal economic conditions, UI can only be claimeed in 26 weeks. You can also refile after 26 weeks of being unemployed and not receiving unemployment benefits, seemingly.
	our $ui_earnings_disregard = 100; #amount disregarded from weekly earnings plus the excess earnings disregard when individual is working and eligible for partial unemployment. 
	our $ui_excess_earnings_disregard = 5;
	our $ui_dependency_allowance_perchild = 10; #The dependency allowance per child; Capped at ½ WBA; Max. for min benefit is $37 and max for max benefit is $215. 
	our $max_wba = 462.46; # Limit of weekly benefit amount an individual eligible for UI can receive, determined by states. Max WBA is 52% of AWW. The most recent AWW is 889.34 so 52% of that is $462.46.  https://www.newscentermaine.com/article/life/state-unemployment-maximum-weekly-benefit-to-increase-june-1/97-418983ad-4001-43f6-8465-61a3787a21c3. The max benefit amount that an indiviaul can receive over the course of a year. Max. benefit amount = $11,570; $17,342 (including DA)
	our $fpuc_amt = 300; #The amount of addditional pandemic unemployment compensation people receive through COVID legislation (last extended by ARPA, as of 4/2021). This is the Federal Pandemic Unemployment Compensation (FPUC) amount. Step 4 asks explicitly whether the amount of unemploymnent compensation they receive includes this amount, so that the calculator can include it or not going forward.

	our $parent1_wba = 0;	#weekly benefit amount individual receives.
	our $parent2_wba = 0;	#weekly benefit amount individual receives.
	our $parent3_wba = 0;	#weekly benefit amount individual receives.
	our $parent4_wba = 0;	#weekly benefit amount individual receives.
	our $parent1_mba = 0;	#maximum  benefit amount individual receives.
	our $parent2_mba = 0;	#maximum benefit amount individual receives.
	our $parent3_mba = 0;	#maximum  benefit amount individual receives.
	our $parent4_mba = 0;	#maximum benefit amount individual receives.
	our $parent1_ui_recd = 0;	#Total UI received per parent
	our $parent2_ui_recd = 0;
	our $parent3_ui_recd = 0;	#Total UI received per parent
	our $parent4_ui_recd = 0;
	our $ui_recd = 0;
	our $ui_recd_m = 0;
	our $dependency_allowance = 0; #How much one parent in the family who is unemployed can get in UI dependency allowances.
	our $potential_dependency_allowance_weeks = 0; #How many weeks of depednency allowance the family will get.
	our $dependency_allowance_flag = 0; #A flag for whether we have considered a dependency allowance yet in determining intial weekly benefit amounts.
	our $fpuc_recd_initial = 0; #The amount of FPUC each unemployed person is initially receiving.
	our $parent1_fpuc_recd_wk = 0; #The amount of FPUC each unemployed person is initially receiving.
	our $parent2_fpuc_recd_wk = 0; #The amount of FPUC each unemployed person is initially receiving.
	our $parent3_fpuc_recd_wk = 0; #The amount of FPUC each unemployed person is initially receiving.
	our $parent4_fpuc_recd_wk = 0; #The amount of FPUC each unemployed person is initially receiving.
	our $parent1_fpuc_recd = 0; #The amount of FPUC each unemployed person is initially receiving.
	our $parent2_fpuc_recd = 0; #The amount of FPUC each unemployed person is initially receiving.
	our $parent3_fpuc_recd = 0; #The amount of FPUC each unemployed person is initially receiving.
	our $parent4_fpuc_recd = 0; #The amount of FPUC each unemployed person is initially receiving.
	our $fpuc_recd = 0;
	
	# Note about child support: If you owe child support and are also filing for unemployment benefits, Maine DOL may send up to 50% of unemployment benefits to Maine DHHS. This does not affect the calculation of benefits, since the model assumes all child support is paid or received as dictated by child support orders or current payments. 
	
	# Note for potential additional populations: Only U.S. citizens and immigrants authorized to work in the U.S. can claim unemployment benefits. Currently the FRS/MTRC tool is not built for non-eligible populations, but if we eventually add them, this will be an important rule.
		
	if ($in->{'ui'} == 1) {

		#Incorporating ARPA's extension of unemployment compensation for 79 weeks, through September 6, 2021:
		#This is a little tricky:
		if ($in->{'covid_ui_expansion'} == 1) {
			$ui_benefit_year = 79;
		}

		for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
			# Check to see if parent is working full-time. In Maine, likely elsewhere, individuals are not eligible to receive any unemployment if they are working an industry standard of what qualifies as full time, but not less than 35 horus per week.
			if ($out->{'parent'.$i.'_employedhours_w'} >= $fulltime_hours || $in->{'parent'.$i.'_ui_recd_initial'} == 0) { 
				${'parent'.$i.'_ui_recd'} = 0;
			} else { 
				if ($in->{'fpuc'} == 1) { #This flag only means whether the current UI payments they are receiving include the FPUC payment. It is not a flag for whether they wish to continue projecting this payment into future weeks.
					$fpuc_recd_initial = $fpuc_amt; #We are not separating out FPUC payments per adult. So this is repeated across adults receiving UI.
				}
				#we calculate each adult's wba from the inputs they entered; their wba may be different from their current UI received amount because of partial unemployment. We also need to consider the dependency allowance. We will, for now, assume that the adult with the lowest parent identifier is the person who is receiving the dependent allowance.
				${'parent'.$i.'_wba'} = &pos_sub($in->{'parent'.$i.'_ui_recd_initial'}, $fpuc_recd_initial) + &pos_sub($out->{'parent'.$i.'_earnings_initial'} / 52, $ui_earnings_disregard);

				#if ($in->{'child_number'} + $out->{'adult_children'} > 0 && $dependency_allowance_flag == 0) {
				#	${'parent'.$i.'_wba'} -= $ui_dependency_allowance_perchild * ($in->{'child_number'} + $out->{'adult_children'});
				#	$dependency_allowance_flag = 1;
				#}
				#MTRC coding:
				#For simplicity's sake, we are not asking individuals receiving unemployment what their base period earnings are. The check for maximum benefit amounts is really a check on whether the two-quarter average earnings across the different base periods is uneven enough that receive a disproportionaely high amount of UI assistance. In general, the WBA will be about half, if not less than half, of base period earnings. As the UI benefit year is only 26 weeks, usually the most amount that people in Maine are going to get from UI assistance is abotu 1/4 of their regular wages. It does therefore not seem mathematically commmon that the maximum beneift amount over the course of an unemployment year would be encountered.
				${'parent'.$i.'_mba'} = ${'parent'.$i.'_wba'} * $ui_benefit_year; 
				
				# Test for excess earnings or not qualifying for unemployemnt:
				if ($out->{'parent'.$i.'_earnings'} / 52 > $ui_excess_earnings_disregard + ${'parent'.$i.'_wba'}) {
					${'parent'.$i.'_ui_recd'} = 0;
				} else {
					${'parent'.$i.'_ui_recd_wk'} = &pos_sub(${'parent'.$i.'_wba'},&pos_sub($out->{'parent'.$i.'_earnings'} / 52, $ui_earnings_disregard)); #Earnings are subtracted less the earnings disregard, which varies by state.
					if ($in->{'covid_ui_expansion'} == 1 && ${'parent'.$i.'_ui_recd_wk'} > 0) { #If the user has opted to model the impacts of COVID legislation expanding UI benefits via FPUC, and receives UI, we adjust their UI by the FPUC amount. Anyone who receives at least some UI is eligible for FPUC payments.
						${'parent'.$i.'_fpuc_recd_wk'} = $fpuc_amt; #We are not separating out FPUC payments per adult. So this is repeated across adults receiving UI.
						${'parent'.$i.'_fpuc_recd'} = &least(52,&pos_sub($ui_benefit_year,$in->{'parent'.$i.'_unemployed_weeks'})) * ${'parent'.$i.'_fpuc_recd_wk'};
						$fpuc_recd += &least(52,&pos_sub($ui_benefit_year,$in->{'parent'.$i.'_unemployed_weeks'})) * ${'parent'.$i.'_fpuc_recd_wk'}; #The positive subtraction (pos_sub) here derives how many more weeks of unemployment insurance the parent has in the year. COVID note: To avoid generating more than one calendar year's worth of benefits, we keep maximum number of weeks of UI here to 52, despite the latest expansion of maximum weeks allowable for UI receipt (79 weeks under ARPA).
						${'parent'.$i.'_ui_recd_wk'} += ${'parent'.$i.'_fpuc_recd_wk'};
						print "test3ui \n";
					}					
					
					${'parent'.$i.'_ui_recd'} = &least(52,&pos_sub($ui_benefit_year,$in->{'parent'.$i.'_unemployed_weeks'})) * ${'parent'.$i.'_ui_recd_wk'}; #The positive subtraction (pos_sub) here derives how many more weeks of unemployment insurance the parent has in the year. COVID note: To avoid generating more than one calendar year's worth of benefits, we keep maximum number of weeks of UI here to 52, despite the latest expansion of maximum weeks allowable for UI receipt (79 weeks under ARPA).
					
					#We determine how many weeks of dependency allowance the family receives. This is a looped variable, which will increase as UI benefits per adult are counted. This reflects maximizing behavior on the part of the family to claim that a parent who is on unemployment provides the whole or main support of a child. Whether or not the family gets a depedency allowance is determined below.
					$potential_dependency_allowance_weeks = &greatest(&pos_sub(&least($ui_benefit_year,52),$in->{'parent1_unemployed_weeks'}),$potential_dependency_allowance_weeks); 
					
				}
			}		
		}
	}
	
	#Totaling them all together
	$ui_recd = $parent1_ui_recd + $parent2_ui_recd + $parent3_ui_recd + $parent4_ui_recd ;
	
	#Dependency allowance:
	# "If you are the whole or main support of a child who is under the age of 18, is a student between the ages of 18 and 23, or has a disability, you may be eligible for a dependency allowance of $10 for each child." Capped at ½ WBA; $37 for min benefits and $215 for max benefits.
	if ($ui_recd > 0) { #From the "whole or main" language in Maine's UI protocols, it appears only one adult per household is allowed a dependency allowance. To maximize this benefit, we will be conferring the dependency allowance on the individual who will remain in UI the longest. 
		$dependency_allowance = $ui_dependency_allowance_perchild * ($in->{'child_number'} + $out->{'adult_children'}); 
		$ui_recd += $dependency_allowance * $potential_dependency_allowance_weeks;
	}
	#Average UI received per month over a year:
	$ui_recd_m = $ui_recd/12;
	#debugging
	#foreach my $debug (qw(ui_recd parent1_ui_recd parent2_ui_recd parent3_ui_recd parent4_ui_recd parent1_wba parent2_wba fpuc_recd_initial fpuc_amt parent1_wba)) {
	#	print $debug.": ".${$debug}."\n";
	#}

	# outputs
    foreach my $name (qw(ui_recd ui_recd_m parent1_ui_recd parent2_ui_recd parent3_ui_recd parent4_ui_recd fpuc_recd parent1_fpuc_recd parent2_fpuc_recd parent3_fpuc_recd parent4_fpuc_recd)) {
       $out->{$name} = ${$name};
    }	
}

1;
