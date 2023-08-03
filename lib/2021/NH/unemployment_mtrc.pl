#=============================================================================#
#  UI Module -- NH 2021 
#=============================================================================#
#
# Inputs referenced in this module:
#
#   FROM USER INTPUTS
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

	# VARIABLES NEEDED FOR MACRO: hard-coded outputs that would need to be updated to keep code up-to-date
	#our $fulltime_hours = 35; #The amount of hours under which an individual is never considered working full time. In some states, it appears that full-time workers are always ineligible for unemployment, but that does not appear to be the case in NH. 
	our $ui_benefit_year = 26; #"Benefit Year: Runs 52 weeks from the Sunday of the week in which you file your Initial Claim. You may be eligible for up to 26 full benefit payments during your Benefit Year." So over the course of a year, under normal economic conditions, UI can only be claimeed in 26 weeks. You can also refile after 26 weeks of being unemployed and not receiving unemployment benefits, seemingly.
	our $ui_earnings_disregard = 0; #amount disregarded from weekly earnings when individual is working and eligible for partial unemployment. It does not appear that NH has such a disregard.
	our $ui_earnings_disregard_pct = .3; #You are still eligible for unemployment when working as long as your earnings do not exceed 30% of your weekly benefit amount.
	our $ui_excess_earnings_disregard = 0; #NH does not apear to have a disregard for partial employment
	our $ui_dependency_allowance_perchild = 0; #NH has no dependency allowance (simplifying this code). 
	our $max_wba = 427; # Limit of weekly benefit amount an individual eligible for UI can receive, determined by states. From NH Employment Security Unemployment Compensation Quick Tips guide.	
	our $fpuc_amt = 300; #The amount of addditional pandemic unemployment compensation people receive through COVID legislation (last extended by ARPA, as of 4/2021). This is the Federal Pandemic Unemployment Compensation (FPUC) amount. Step 4 asks explicitly whether the amount of unemploymnent compensation they receive includes this amount, so that the calculator can include it or not going forward.
	our $parent1_wba = 0;	#weekly benefit amount individual receives.
	our $parent2_wba = 0;	#weekly benefit amount individual receives.
	our $parent3_wba = 0;	#weekly benefit amount individual receives.
	our $parent4_wba = 0;	#weekly benefit amount individual receives.
	#our $parent1_mba = 0;	#maximum  benefit amount individual receives.
	#our $parent2_mba = 0;	#maximum benefit amount individual receives.
	#our $parent3_mba = 0;	#maximum  benefit amount individual receives.
	#our $parent4_mba = 0;	#maximum benefit amount individual receives.
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

	# Note for potential additional populations: Only U.S. citizens and immigrants authorized to work in the U.S. can claim unemployment benefits. Currently the FRS/MTRC tool is not built for non-eligible populations, but if we eventually add them, this will be an important rule.
	
	if ($in->{'ui'} == 1) {

		#Incorporating ARPA's extension of unemployment compensation for 79 weeks, through September 6, 2021:
		#This is a little tricky:
		if ($in->{'covid_ui_expansion'} == 1) {
			$ui_benefit_year = 79;
		}
				
		for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
			if ($in->{'parent'.$i.'_ui_recd_initial'} == 0) { 
				${'parent'.$i.'_ui_recd'} = 0;
			} else { 				
				if ($in->{'fpuc'} == 1) { #This flag only means whether the current UI payments they are receiving include the FPUC payment. It is not a flag for whether they wish to continue projecting this payment into future weeks.
					$fpuc_recd_initial = $fpuc_amt; #We are not separating out FPUC payments per adult. So this is repeated across adults receiving UI.
				}

				#we calculate each adult's wba from the inputs they entered; their wba may be different from their current UI received amount because of partial unemployment. We also need to consider the dependency allowance. We will, for now, assume that the adult with the lowest parent identifier is the person who is receiving the dependent allowance.
				${'parent'.$i.'_wba'} = &pos_sub($in->{'parent'.$i.'_ui_recd_initial'}, $fpuc_recd_initial) + &pos_sub($out->{'parent'.$i.'_earnings_initial'} / 52, $ui_earnings_disregard); #There is no earnings disregard in NH, but keeping that in here and below to help generalize the code. We also remove any FPUC payments the adult is receiving. We'll add that back in if the adult is selecting to model contintinual COVID UI expansions.

				if ($in->{'child_number'} + $out->{'adult_children'} > 0 && $dependency_allowance_flag == 0) { #Keeping this in to generalize the code, but there is no dependency allowance in NH.
					${'parent'.$i.'_wba'} -= $ui_dependency_allowance_perchild * ($in->{'child_number'} + $out->{'adult_children'});
					$dependency_allowance_flag = 1;
				}
								
				#FRS coding (or code that can be adapted or improved elsewhere):
				#${'parent'.$i.'_mba'} = &least(${'parent'.$i.'_wba'} * $ui_benefit_year, (1/3) * ${'parent'$i.'_base_period_earnings'}); 
				
				#MTRC coding:				
				#Commenting out considerations of the maximum benefit amount. It is not relevant to New Hampshire, or at least how we model UI in New Hampshire, leave its usage to set a limit a mathematical tautology.
				
				#While in non-crisis times, the UI benefit year is always under 52 weeks, COVID legislation has expanded that and the maximum amount of weeks covered (aided by federal dollars) is now 79. But since this extended period exceeds a year, and the other amounts in our frame are annual, we must cap the projected UI benefits at the calendar year, at maximum.
				
				# Test for excess earnings or not qualifying for unemployemnt:
				#"An individual shall be deemed to be “partially unemployed” in any week of less than fulltime work if the wages computed to the nearest dollar payable to him with respect to such week fail to equal his weekly benefit amount." - 282-A:14(2), NHES Law Book
				if ($out->{'parent'.$i.'_earnings'} / 52 > ${'parent'.$i.'_wba'}) {
					${'parent'.$i.'_ui_recd'} = 0;
				} else {
					# Calculate unemployment benefits. Note that this is a pre-COVID calculation, without any stimulus funds directed to people who are unemployed. Unemployment benefits are reduced by earnings less the first $100 of earnings.
					# An individual's maximum weekly benefit amount shall be reduced by all wages and earnings in excess of 30 percent, rounded to the nearest dollar, of the individual's weekly benefit amount.
					${'parent'.$i.'_ui_recd_wk'} = pos_sub(${'parent'.$i.'_wba'}, pos_sub($out->{'parent'.$i.'_earnings'} / 52, $ui_earnings_disregard_pct * ${'parent'.$i.'_wba'})); #Earnings are subtracted less the earnings disregard, which varies by state.
					
					if ($in->{'covid_ui_expansion'} == 1 && ${'parent'.$i.'_ui_recd_wk'} > 0) { #If the user has opted to model the impacts of COVID legislation expanding UI benefits via FPUC, and receives UI, we adjust their UI by the FPUC amount. Anyone who receives at least some UI is eligible for FPUC payments.
						${'parent'.$i.'_fpuc_recd_wk'} = $fpuc_amt; #We are not separating out FPUC payments per adult. So this is repeated across adults receiving UI.
						${'parent'.$i.'_fpuc_recd'} = &least(52,&pos_sub($ui_benefit_year,$in->{'parent'.$i.'_unemployed_weeks'})) * ${'parent'.$i.'_fpuc_recd_wk'};
						$fpuc_recd += &least(52,&pos_sub($ui_benefit_year,$in->{'parent'.$i.'_unemployed_weeks'})) * ${'parent'.$i.'_fpuc_recd_wk'}; #The positive subtraction (pos_sub) here derives how many more weeks of unemployment insurance the parent has in the year. COVID note: To avoid generating more than one calendar year's worth of benefits, we keep maximum number of weeks of UI here to 52, despite the latest expansion of maximum weeks allowable for UI receipt (79 weeks under ARPA).
						${'parent'.$i.'_ui_recd_wk'} += ${'parent'.$i.'_fpuc_recd_wk'};
					}					
					
					${'parent'.$i.'_ui_recd'} = &least(52,&pos_sub($ui_benefit_year,$in->{'parent'.$i.'_unemployed_weeks'})) * ${'parent'.$i.'_ui_recd_wk'}; #The positive subtraction (pos_sub) here derives how many more weeks of unemployment insurance the parent has in the year. COVID note: To avoid generating more than one calendar year's worth of benefits, we keep maximum number of weeks of UI here to 52, despite the latest expansion of maximum weeks allowable for UI receipt (79 weeks under ARPA).
					
					#We determine how many weeks of dependency allowance the family receives. This is a looped variable, which will increase as UI benefits per adult are counted. This reflects maximizing behavior on the part of the family to claim that a parent who is on unemployment provides the whole or main support of a child. Whether or not the family gets a depedency allowance is determined below.
					$potential_dependency_allowance_weeks = &greatest(&pos_sub(&least($ui_benefit_year, 52),$in->{'parent1_unemployed_weeks'}),$potential_dependency_allowance_weeks); # Similarly keeping this in here to generalize the code, even though there is no dependency allowance in NH. COVID note: again, we're limiting tht term in which ui_benefit_year to 52 in order to ensure the calculator does not spit out more than 52 weeks of benefits in its annual projections.
					
				}
			}		
		}
	}
	
	#Totaling them all together
	$ui_recd = $parent1_ui_recd + $parent2_ui_recd + $parent3_ui_recd + $parent4_ui_recd ;
	$ui_recd_m = $ui_recd/12;
	
	#Dependency allowance:
	# Similarly keeping this in here to generalize the code, even though there is no dependency allowance in NH. From the "whole or main" language in Maine's UI protocols, it appears only one adult per household is allowed a dependency allowance. To maximize this benefit, we will be conferring the dependency allowance on the individual who will remain in UI the longest. 
	if ($ui_recd > 0) { 
		$dependency_allowance = $ui_dependency_allowance_perchild * ($in->{'child_number'} + $out->{'adult_children'}); 
		$ui_recd += $dependency_allowance * $potential_dependency_allowance_weeks;
	}

	#debugging
	foreach my $debug (qw(ui_recd parent1_ui_recd parent2_ui_recd parent3_ui_recd parent4_ui_recd parent1_wba parent2_wba)) {
		print $debug.": ".${$debug}."\n";
	}

	# outputs
    foreach my $name (qw(ui_recd ui_recd_m parent1_ui_recd parent2_ui_recd parent3_ui_recd parent4_ui_recd fpuc_recd parent1_fpuc_recd parent2_fpuc_recd parent3_fpuc_recd parent4_fpuc_recd)) {
       $out->{$name} = ${$name};
    }	
}

1;
