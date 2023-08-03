package Frs;

sub new
{
    my $class = shift;
    my $self = { in => {}, out => {}, debug => {} };
	bless($self, $class);
    return $self;
}

#Removing Perl DB commands:
#sub dbhConnect {
#	my $self = shift;
#	my $user = 'root';
#	my $password = 'root'; 
#	my $db = 'FRS';
#	my $host = 'localhost';
#	my $port = 8889;
#	my $db_connect_string = "DBI:mysql:database=$db;host=$host;port=$port";
#	
#	my $dbh = DBI->connect(
#	   $db_connect_string,
#	   $user,
#	   $password
#	) or die("Error connecting to the database: $DBI::errstr\n");
#	$self->{'dbh'} = $dbh;
#	return $dbh;
#}

# calculates additional values based on existing inputs, and looks up some state-specific values
sub setGeneral {

    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};
	#Removing Perl DB commands:
	#my $dbh = $self->{'dbh'};

	# set general values
    $in->{'child_number'} = 0; 
	if ($in->{'year'} >= 2020) { #Beginning in 2020, we are allowing users to model families with no children.
		if($in->{'child1_age'} != -1) { $in->{'child_number'}++; $in->{'child1'} = 1; }        # first child
	} else {
		$in->{'child_number'}++; #Before 2020, simulators always assumed at least one child.
	}
    if($in->{'child2_age'} != -1) { $in->{'child_number'}++; $in->{'child2'} = 1; }        # second child
    if($in->{'child3_age'} != -1) { $in->{'child_number'}++; $in->{'child3'} = 1; }        # third child
	if($in->{'year'} >= 2017){ #9/23: Changed "==" to "eq" since $state is a string variable. 5/8: Changed this to year>=2017, since we're planning on including up to 5 children going forward.
		if($in->{'child4_age'} != -1) { $in->{'child_number'}++; $in->{'child4'} = 1; }        # fourth child
		if($in->{'child5_age'} != -1) { $in->{'child_number'}++; $in->{'child5'} = 1; }        # fifth child
	}

	
    $in->{'family_size'} = $in->{'family_structure'} + $in->{'child_number'};
        
    $in->{'child1_under1'} = ($in->{'child1_age'} < 1 && $in->{'child1_age'} != -1 ? 1 : 0);
    $in->{'child2_under1'} = ($in->{'child2_age'} < 1 && $in->{'child2_age'} != -1 ? 1 : 0);
    $in->{'child3_under1'} = ($in->{'child3_age'} < 1 && $in->{'child3_age'} != -1 ? 1 : 0);
    $in->{'child4_under1'} = ($in->{'child4_age'} < 1 && $in->{'child4_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.
    $in->{'child5_under1'} = ($in->{'child5_age'} < 1 && $in->{'child5_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.

	$in->{'children_under1'} = $in->{'child1_under1'} + $in->{'child2_under1'} + $in->{'child3_under1'} + $in->{'child4_under1'} + $in->{'child5_under1'};

    $in->{'child1_under2'} = ($in->{'child1_age'} < 2 && $in->{'child1_age'} != -1 ? 1 : 0);
    $in->{'child2_under2'} = ($in->{'child2_age'} < 2 && $in->{'child2_age'} != -1 ? 1 : 0);
    $in->{'child3_under2'} = ($in->{'child3_age'} < 2 && $in->{'child3_age'} != -1 ? 1 : 0);
    $in->{'child4_under2'} = ($in->{'child4_age'} < 2 && $in->{'child4_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.
    $in->{'child5_under2'} = ($in->{'child5_age'} < 2 && $in->{'child5_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.

    $in->{'children_under2'} = $in->{'child1_under2'} + $in->{'child2_under2'} + $in->{'child3_under2'} + $in->{'child4_under2'} + $in->{'child5_under2'};

    $in->{'child1_under6'} = ($in->{'child1_age'} < 6 && $in->{'child1_age'} != -1 ? 1 : 0);
    $in->{'child2_under6'} = ($in->{'child2_age'} < 6 && $in->{'child2_age'} != -1 ? 1 : 0);
    $in->{'child3_under6'} = ($in->{'child3_age'} < 6 && $in->{'child3_age'} != -1 ? 1 : 0);
	$in->{'child4_under6'} = ($in->{'child4_age'} < 6 && $in->{'child4_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.
    $in->{'child5_under6'} = ($in->{'child5_age'} < 6 && $in->{'child5_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.

	$in->{'children_under6'} = $in->{'child1_under6'} + $in->{'child2_under6'} + $in->{'child3_under6'} + $in->{'child4_under6'} + $in->{'child5_under6'};

    $in->{'child1_under13'} = ($in->{'child1_age'} < 13 && $in->{'child1_age'} != -1 ? 1 : 0);
    $in->{'child2_under13'} = ($in->{'child2_age'} < 13 && $in->{'child2_age'} != -1 ? 1 : 0);
    $in->{'child3_under13'} = ($in->{'child3_age'} < 13 && $in->{'child3_age'} != -1 ? 1 : 0);
    $in->{'child4_under13'} = ($in->{'child4_age'} < 13 && $in->{'child4_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.
    $in->{'child5_under13'} = ($in->{'child5_age'} < 13 && $in->{'child5_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); #9/23: Changed variable here from "child4_under13" to "child5_under13"; I believe this was just a copy-and-paste error. # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.
	
    $in->{'children_under13'} = $in->{'child1_under13'} + $in->{'child2_under13'} + $in->{'child3_under13'} + $in->{'child4_under13'} + $in->{'child5_under13'};

    $in->{'child1_under17'} = ($in->{'child1_age'} < 17 && $in->{'child1_age'} != -1 ? 1 : 0);
    $in->{'child2_under17'} = ($in->{'child2_age'} < 17 && $in->{'child2_age'} != -1 ? 1 : 0);
    $in->{'child3_under17'} = ($in->{'child3_age'} < 17 && $in->{'child3_age'} != -1 ? 1 : 0);
	$in->{'child4_under17'} = ($in->{'child4_age'} < 17 && $in->{'child4_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.
    $in->{'child5_under17'} = ($in->{'child5_age'} < 17 && $in->{'child5_age'} != -1 && $in->{'year'} >= 2017 ? 1 : 0); # 5/8/18: added year condition so as not to affect pre-DC 2017 simulators.

	$in->{'children_under17'} = $in->{'child1_under17'} + $in->{'child2_under17'} + $in->{'child3_under17'} + $in->{'child4_under17'} + $in->{'child5_under17'};

    $in->{'parent_number'} = $in->{'family_structure'};

  # get the value of the rent -- we need fmr no matter what for the other expenses calculation
	#Removing Perl DB commands (but fmr is already a SESSION variable in the MTRC (from calc_page_2), so this is unnecesary anyway.
    #my $sql = "SELECT rent FROM FRS_Locations WHERE state = ? AND year = ? AND id = ? AND number_children = ?";
    #my $stmt = $dbh->prepare($sql) ||
    #    &fatalError("Unable to prepare $sql: $DBI::errstr");
    #my $result = $stmt->execute($in->{'state'}, $in->{'year'}, $in->{'residence'}, $in->{'child_number'}) ||
    #    &fatalError("Unable to execute $sql: $DBI::errstr");
	#$in->{'fmr'} = $stmt->fetchrow();
	
	# Grab rent_cost_m from the inputs and first assign it to the FMR amount.
	$in->{'fmr'} = $in->{'rent_cost_m'};
	
	#Then check for the housing override and assign it to rent_cost_m if it was entered.
    if($in->{'housing_override'})
    {
        $in->{'rent_cost_m'} = $in->{'housing_override_amt'};
    }
    else
    {
        $in->{'rent_cost_m'} = $in->{'fmr'};
    #    $stmt->finish();
    }
	
	#Adding in variables that, at least in the first course through the steps, may be defined by blank strings:
	for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
		for(my $j=1; $j<=$in->{'parent'.$i.'_future_jobs'}; $j++) {
			#We adjust any wage and work schedule information that have been entered once, then adjusted through going back to revise values. The $_SESSION variables may remain in place and may mess up the output in these situations.
			if ($in->{'future_scenario_parent'.$i} eq 'none') {
				$in->{'parent'.$i.'_future_workweek'.$j} = $in->{'parent'.$i.'_workweek'.$j};
				$in->{'parent'.$i.'_future_wage_'.$j} = $in->{'parent'.$i.'_wage_'.$j};
				$in->{'parent'.$i.'_future_payscale'.$j} = $in->{'parent'.$i.'_payscale'.$j};
			}
			if ($in->{'future_scenario_parent'.$i} eq 'wages') {
				$in->{'parent'.$i.'_future_workweek'.$j} = $in->{'parent'.$i.'_workweek'.$j};
			}
			if ($in->{'future_scenario_parent'.$i} eq 'hours') {
				$in->{'parent'.$i.'_future_wage_'.$j} = $in->{'parent'.$i.'_wage_'.$j};
				$in->{'parent'.$i.'_future_payscale'.$j} = $in->{'parent'.$i.'_payscale'.$j};
			}
			if ($in->{'future_scenario_parent'.$i} eq 'new') {
				if ($j < $in->{'parent'.$i.'_future_jobs'}) { #In this final case, we use the setup in the PHP that assigns the highest-numbered job as the new job.
					$in->{'parent'.$i.'_future_workweek'.$j} = $in->{'parent'.$i.'_workweek'.$j};
					$in->{'parent'.$i.'_future_wage_'.$j} = $in->{'parent'.$i.'_wage_'.$j};
					$in->{'parent'.$i.'_future_payscale'.$j} = $in->{'parent'.$i.'_payscale'.$j};
				}
			}
			
			#These are older revisions, which I think are obsolete with JavaScript validation added to the PHP, which removes the possibiltiy of blank inputs.
			if ($in->{'parent'.$i.'_future_workweek'.$j} eq "") {
				$in->{'parent'.$i.'_future_workweek'.$j} = $in->{'parent'.$i.'_workweek'.$j};
			}
			if ($in->{'parent'.$i.'_future_wage_'.$j} eq "") {
				$in->{'parent'.$i.'_future_wage_'.$j} = $in->{'parent'.$i.'_wage_'.$j};
			}
			if ($in->{'parent'.$i.'_future_payscale'.$j} eq "") {
				$in->{'parent'.$i.'_future_payscale'.$j} = $in->{'parent'.$i.'_payscale'.$j};
			}
		}
	}
	
	#We also need to adjust the married2 variable to identify the second adult in a two-parent adult household as married.
	if ($in->{'family_structure'} == 2 && $in->{'married1'} == 1) {
		$in->{'married2'} = 2;
	}

	#Also, adjusting the imputs to reflect individual pt or ft student status:
	for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
		$in->{'parent'.$i.'_pt_student'} = 0;
		$in->{'parent'.$i.'_pt_student'} = 0;
		if($in->{'parent'.$i.'_student_status'} eq 'pt_student') {
			$in->{'parent'.$i.'_pt_student'} = 1;
		} elsif ($in->{'parent'.$i.'_student_status'} eq 'ft_student') {
			$in->{'parent'.$i.'_ft_student'} = 1;
		}
	}

	$in->{'disability_count'} = 0;
	for(my $i=1; $i<=4; $i++) {
		if ($in->{'parent'.$i.'_age'} > 0) {
			if ($in->{'disability_parent'.$i} == 1) {
				$in->{'disability_count'} += 1;
			}
		}
	}	

	#Redefining the values of continuous coverage variables:
	for(my $i=1; $i<=$in->{'family_structure'}; $i++) { 
		if($in->{'parent'.$i.'_continuous_coverage'} == 2)  {
			$in->{'parent'.$i.'_continuous_coverage'} = 0;
		}
	}
	if($in->{'child_continuous_coverage'} == 2)  {
		$in->{'child_continuous_coverage'} = 0;
	}
	
	#Also, creating aggregate variable to capture any unearned income the user indicates their household receives. May be deleting this and replacing it with outptut variable of other_unearned_income. For now, just using interest variables to incorporprate these elements.
	$in->{'unearn_gross_mon_inc_amt_ag'} = 0;
	#$in->{'unearn_gross_mon_inc_amt_ag'} += $in->{'alimony_paid_m'};
	#$in->{'unearn_gross_mon_inc_amt_ag'} += $in->{'other_income_m'};
	
	#Variables we're not asking about in the MTRC, but are in some codes to reflect program rules. Rather than deleting rule elements that may prove useful later on, we're assigning zero values to these parameters.
	for(my $i=1; $i<=4; $i++) {
		$in->{'parent'.$i.'_selfemployed_netprofit'} = 0;
	}
	$in->{'selfemployed_netprofit_total'} = 0;

	#Also, setting some "initial" input variables that capture expenses above subsidized amounts. These amounts should be defined in the various benefit codes if users accurately indicate that they are eligible for benefits they say they receive, but it's possible that a current scenario - where these are defined - may be run wihtout these variables being defined.
	$in->{'overage_amount'} = 0;
	$in->{'discount_amount'} = 0;
	$in->{'family_foodcost_initial'} = 0;
	$in->{'phone_expenses_base'} = 0;
	$in->{'imputed_rent_difference'} = 0;
	$in->{'imputed_energycost_total'} = 0;

	#We now assign zero values to input variables that may not be defined as inputs, but that are necesssary for the codes to work. The // operator in Perl returns the right-hand-side value when the left-hand-side value is undefined. They need to include the check-marked variables (e.g. the variables of the benefits on step 3), but also others that may not return a value based on the way the PHP is written. 

    foreach my $name (qw(ccdf fsp hlth sec8 tanf wic ssi afterschool nsbp frpl fsmp liheap lifeline disability_parent1 disability_parent2 disability_parent3 disability_parent4 flatrent eap snap_training breastfeeding outgoing_child_support child_support_paid_m outgoing_alimony car_insurance_m car_payment_m renters_insurance_m student_debt debt_payment exclude_abawd_provision ui prek headstart earlyheadstart parent1_educational_expenses parent2_educational_expenses parent3_educational_expenses parent4_educational_expenses ccdf_payscale1 ccdf_payscale2 ccdf_payscale3 ccdf_payscale4 ccdf_payscale5 exclude_covid_policies_ending_1221 exclude_covid_policies_ending_0921 prek_mtrc ostp)) { 
        $in->{$name} = $in->{$name} // 0;
    }
	
	if ($in->{'prek_mtrc'} == 1) {
		$in->{'prek'} = 1;
	}

	#Also, setting the health override to just the adults if no child is present. We only ask one cost when the user indicates they are not receiving Medicaid.
	if ($in->{'hlth'} == 0 && $in->{'hlth_plan_estimate_source'} eq 'user-entered') {
		$in->{'hlth_amt_parent_m'} = $in->{'hlth_amt_family_m'};
	}


	#Redefining COVID-era policies based on actual expansions:
	#There are a few catch-all checkboxes in the 2021 simulator. For clarity's sake, we are using that to define more specific policy variables used throughout this code.
	#Right now (as of 4/19/21), planning on making it so that page 3 has bottom option of "Exclude at least some of the expansions that have been made to the above programs due to COIVD, scheduled to end betweeen September 2021 and December 2021?" with the sub-option of "Exclude just the expansions that are scheduled to end by the end of September 2021 (these include the $300/week Unemployment Compensation expansion and the 15% incerase in SNAP benefits), but include expansions scheduled to end after December 2021 (like most of the expanded tax credits such as those made to the child tax credit and child and dependent care tax credit)?" The sub-option would only be clickable if the user first clicked on the main (first) option.

	$in->{'covid_ptc_expansion'} = 1;			#Of all the temporary changes due to COVID, we are treating the expansion of the premium tax credit to be one that cannot be changed. It lasts through the end of 2022.
	
	#The rest of these expansions we assume will be affected by user choices, but we start by assigning them an "off" value of 0 in this code.
	
	$in->{'covid_fsp_work_exemption'} = 0; 		#Exempts ABAWDS from SNAP work requirements.
	$in->{'covid_ea_allotment'} = 0;			#Provides emergency allotment on top of SNAP benefits	
	$in->{'covid_fsp_15percent_expansion'} = 0;	#Expands maximum SNAP benefits by 15%. 
	$in->{'covid_eitc_expansion'} = 0;	#Expands maximum SNAP benefits by 15%. 
	$in->{'covid_sfsp_sso_expansion'} = 0;
	$in->{'covid_ui_expansion'} = 0;
	$in->{'covid_ctc_expansion'} = 0;
	$in->{'covid_cdctc_expansion'} = 0;
	$in->{'covid_ptc_ui_expansion'} = 0;
	$in->{'covid_medicaid_expansion'} = 0;

	if ($in->{'exclude_covid_policies_ending_1221'} == 0) {
		#These are policies set to expire at the end of December 2021:
		$in->{'covid_fsp_work_exemption'} = 1;
		$in->{'covid_ea_allotment'} = 1;
		$in->{'covid_eitc_expansion'} = 1;
		$in->{'covid_ctc_expansion'} = 1;
		$in->{'covid_cdctc_expansion'} = 1;
		$in->{'covid_ptc_ui_expansion'} = 1;
		$in->{'covid_medicaid_expansion'} = 1;
	}
	if ($in->{'exclude_covid_policies_ending_0921'} == 0) {
		#These are policies set to expire during or at the end of September 2021:
		$in->{'covid_fsp_15percent_expansion'} = 1;
		$in->{'covid_ui_expansion'} = 1;
		$in->{'covid_sfsp_sso_expansion'} = 1;
	}	
	print "debug covid: ".$in->{'covid_ctc_expansion'}."\n";

	#In case we also need to do this for variables generated from text fields, that may be blank, you can use the below code. We are not using this initially because we are includign JavaScript validations toe ensure no blank fields are entered. 
    #foreach my $name (qw(child_support_paid_m)) { 
	#	if ($in->{$name} == "") {
	#		$in->{$name} = 0;
	#	}
	#}
	#print "child_support_paid_m: $in->{'child_support_paid_m'} \n";
	
	
	for(my $i=1; $i<=4; $i++) {
		foreach my $name (qw(_transdays_w _traininghours _future_transdays_w _future_traininghours _ui_recd_initial)) { 
			$in->{'parent'.$i.$name} = $in->{'parent'.$i.$name} // 0;
		}
	}	

	# We assume everybody is getting their tax credits, via online tax filing services. This is different than what we do in the FRS, which is allow users to turn off and on these checkmarks to see their impacts.
	foreach my $name (qw(eitc ctc cadc premium_tax_credit state_eitc state_cadc familysize_credit state_dec state_ptfc state_stfc)) { 
        $in->{$name} = 1;
    }

	# Next, we assign zero values to inputs that may be empty strings.
	foreach my $name (qw(hlth_costs_oop_m)) { 
        if ($in->{$name} eq "") {
			$in->{$name} = 0;
		}
    }
	
	#For some states, like NH, we have codes that separate different types of fuel sources (e.g. between cooking and heating. For compatibiltiy with those codes, we assign heat_fuel_source to fuel_source.
	$in->{'heat_fuel_source'} = $in->{'fuel_source'};

#	our $child_premium_ratio = 0.654; 
#	our	$family_costfrs = 0;
#	our	$parent_costfrs = 0;
 #   our $a27yo_premium = 222;  # This is listed on the base tables. It’s the monthly premium for the second-lowest cost silver plan (SLCSP) for 27-year-olds in DC, and can be used to calculate the associated premiums for all other ages.
  #  our $a27yo_premium_ratio = 0.727;  # This is the premium ratio on DC’s standard age curve.
   # our $parent1_premium = 0;
    #our $parent2_premium = 0;	
#	our $parent1_premium_ratio = 0;
#	our $parent2_premium_ratio  = 0;
#	our @parent1_premium_ratioarray = (0.654,0.727,0.727,0.727,0.727,0.727,0.727,0.727,0.744,0.76,0.779,0.799,0.817,0.836,0.856,0.876,0.896,0.916,0.927,0.938,0.975,1.013,1.053,1.094,1.137,1.181,1.227,1.275,1.325,1.377,1.431,1.487,1.545,1.605,1.668,1.733,1.801,1.871,1.944,2.02,2.099,2.181);
#	 $parent1_premium_ratio = $parent1_premium_ratioarray[pos_sub($in->{'parent1_age'},20)]; 
#	 $parent2_premium_ratio = $parent1_premium_ratioarray[pos_sub($in->{'parent2_age'},20)]; 
	 
#	$parent1_premium = ($parent1_premium_ratio/$a27yo_premium_ratio) * $a27yo_premium;
	# Parent2:
#	if ($in->{'family_structure'} == 2) {
#		$parent2_premium = ($parent2_premium_ratio/$a27yo_premium_ratio) * $a27yo_premium;
#		}
#	$parent_costfrs = 12*($parent1_premium + $parent2_premium); 
#	$family_costfrs = ($parent_costfrs + $in->{'child_number'}*($child_premium_ratio/$a27yo_premium_ratio) *$a27yo_premium *12);
	
  # get state-specific values
	#Removing Perl DB commands (but fpl, smi, passbook_rate are already all $SESSION variables in the MTRC (from calc_page_2), so this is unnecesary anyway.
    #$sql = "SELECT fpl, smi, passbook_rate from FRS_General WHERE state = ? AND year = ? AND size = ?";
    #$stmt = $dbh->prepare($sql) ||
    #    &fatalError("Unable to prepare $sql: $DBI::errstr");
    #$result = $stmt->execute($in->{'state'}, $in->{'year'}, $in->{'family_size'}) ||
    #    &fatalError("Unable to execute $sql: $DBI::errstr");
    #($in->{'fpl'}, $in->{'smi'}, $in->{'passbook_rate'}) = $stmt->fetchrow();
    #$stmt->finish();
}

# saves values in a hash to display in testing interface, sorted by module
sub saveDebugValues {
    my $self = shift;
    my $in = $self->{'in'};
    my ($module, $name, $value, $detail) = @_;        
    my $elem = {};
    $elem->{'name'} = $name;
    $elem->{'value'} = $value;
    if($detail){
        push(@{$self->{'debug'}->{$module}->{'detail'}}, $elem);
    }
    else {
        push(@{$self->{'debug'}->{$module}->{'output'}}, $elem);
    }
}

1;