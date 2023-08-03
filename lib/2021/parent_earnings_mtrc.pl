#=============================================================================#
#  Parent Earnings -- 2021
#=============================================================================#
# Inputs referenced in this module:
#
# FROM INTERFACE INPUTS:
# parent#_future_jobs
# parent#_future_wage_#
# parent#_future_payscale#
# parent#_future_workweek#
# parent#_jobs_initial
# parent#_wage_#
# parent#_payscale_#
# parent#_workweek#

# parent#_age

# FROM FRS.PL
# scenario
 
#=============================================================================#

sub parent_earnings {
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};


	# outputs created
    our $parent1_employedhours_w = 0; # number of hours/week parent 1 works in paid employment. Because we are adding in additional hours due to training in order to satisfy work requirements, we are using the employedhours variables alone to estimate child care need.
    our $parent2_employedhours_w = 0; # number of hours/week parent 2 works in paid employment
	our $parent3_employedhours_w = 0; # number of hours/week parent 2 works in paid employment
	our $parent4_employedhours_w = 0; # number of hours/week parent 2 works in paid employment
	#our $parent0_employedhours_w = 0;
    our $parent1_employedhours_w_initial = 0; # number of hours/week parent 1 works in paid employment. Because we are adding in additional hours due to training in order to satisfy work requirements, we are using the employedhours variables alone to estimate child care need.
    our $parent2_employedhours_w_initial = 0; # number of hours/week parent 2 works in paid employment
	our $parent3_employedhours_w_initial = 0; # number of hours/week parent 2 works in paid employment
	our $parent4_employedhours_w_initial = 0; # number of hours/week parent 2 works in paid employment
    our $parent1_earnings = 0;        # parent 1's earnings per year
    our $parent2_earnings = 0;        # parent 2's earnings per year
    our $parent3_earnings = 0;        # parent 3's earnings per year
    our $parent4_earnings = 0;        # parent 4's earnings per year
    our $parent1_earnings_initial = 0;        # parent 1's earnings per year
    our $parent2_earnings_initial = 0;        # parent 2's earnings per year
    our $parent3_earnings_initial = 0;        # parent 3's earnings per year
    our $parent4_earnings_initial = 0;        # parent 4's earnings per year
    our $parent1_earnings_m = 0;	  # parent 1's earnings per month
    our $parent2_earnings_m = 0;      # parent 2's earnings per month
    our $parent3_earnings_m = 0;      # parent 3's earnings per month
    our $parent4_earnings_m = 0;      # parent 4's earnings per month
	our $parent_workhours_w = 0;
	our $parent1_transhours_w = 0;
	our $parent2_transhours_w = 0;
	our $parent3_transhours_w = 0;
	our $parent4_transhours_w = 0;
	
	#Here, we also set one  variable to zero in order for them to be used in later codes that involve loops and checks against these variables:
	our $tanf_recd = 0;			#We need this because checking against Head Start eligibility occurs in the child care code, and that is run both before and after tanf_recd is defined in the tanf subroutine/function.
	our $rent_paid_m = 0;		#Similarly, need this for a TANF-SEC8-TANF loop for at least Maine.
	
	#MTRC outputs:
	our $earnings = 0;				   # yearly earnings for the MTRC
	our $earnings_mnth = 0;            # monthly earnings for the MTRC
	our $earnings_week = 0;            # weekly earnings for the MTRC
	our $caregiver = 0;					# The least-working adult. (important for some CCDF eligibility determinations.)
	our $gift_income = 0;
	our $gift_income_m = 0;

	# We need to know initial earnings on the part of all parents for at least our UI module, if not other modules as well.
	print "debug1 \n";
	for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
		for(my $j=1; $j<=$in->{'parent'.$i.'_jobs_initial'}; $j++) {
			print "debug2 \n";
			${'parent'.$i.'_employedhours_w_initial'} += $in->{'parent'.$i.'_workweek'.$j};
			if ($in->{'parent'.$i.'_payscale'.$j} eq 'hour') {
				${'parent'.$i.'_earnings_initial'} += $in->{'parent'.$i.'_wage_'.$j} * $in->{'parent'.$i.'_workweek'.$j} * 52;
			} elsif ($in->{'parent'.$i.'_payscale'.$j} eq 'week') {
				${'parent'.$i.'_earnings_initial'} += $in->{'parent'.$i.'_wage_'.$j} *  52;
			} elsif ($in->{'parent'.$i.'_payscale'.$j} eq 'biweekly') {
				${'parent'.$i.'_earnings_initial'} += $in->{'parent'.$i.'_wage_'.$j} *  26;
			} elsif ($in->{'parent'.$i.'_payscale'.$j} eq 'month') {
				${'parent'.$i.'_earnings_initial'} += $in->{'parent'.$i.'_wage_'.$j} *  12;
			} elsif ($in->{'parent'.$i.'_payscale'.$j} eq 'year') {
				${'parent'.$i.'_earnings_initial'} += $in->{'parent'.$i.'_wage_'.$j};
			}
		}
	}
	
	if ($out->{'scenario'} eq 'current') {
		#We use "initial" (inputted) earnings to calculate current earnings. For the current scenario, earnings will be equal to initial earnings.
		for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
			${'parent'.$i.'_employedhours_w'} = ${'parent'.$i.'_employedhours_w_initial'};
			${'parent'.$i.'_earnings'} = &round(${'parent'.$i.'_earnings_initial'});
			${'parent'.$i.'_earnings_m'} = &round(${'parent'.$i.'_earnings_initial'}/12);
			${'parent'.$i.'_transhours_w'} = ${'parent'.$i.'_employedhours_w_initial'} + $in->{'parent'.$i.'_traininghours'};
			$earnings += ${'parent'.$i.'_earnings'};
		}		
	} elsif ($out->{'scenario'} eq 'future') {
		for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
			for(my $j=1; $j<=$in->{'parent'.$i.'_future_jobs'}; $j++) {
				${'parent'.$i.'_employedhours_w'} += $in->{'parent'.$i.'_future_workweek'.$j};
				if ($in->{'parent'.$i.'_future_payscale'.$j} eq 'hour') {
					${'parent'.$i.'_earnings'} += $in->{'parent'.$i.'_future_wage_'.$j} * $in->{'parent'.$i.'_future_workweek'.$j} * 52;
				} elsif ($in->{'parent'.$i.'_workweek'.$j} > 0) { #Per ASPE request, we are taking the proportion of any added hours compared to their currrent hours. But can only do this if there's a baseline comparison, so need to check if they are currently working first. If they are not, there will be a division by 0 error. 
					if ($in->{'parent'.$i.'_future_payscale'.$j} eq 'week') {
						${'parent'.$i.'_earnings'} += $in->{'parent'.$i.'_future_wage_'.$j} *  52 * $in->{'parent'.$i.'_future_workweek'.$j} / $in->{'parent'.$i.'_workweek'.$j}; 
					} elsif ($in->{'parent'.$i.'_future_payscale'.$j} eq 'biweekly') {
						${'parent'.$i.'_earnings'} += $in->{'parent'.$i.'_future_wage_'.$j} *  26 * $in->{'parent'.$i.'_future_workweek'.$j} / $in->{'parent'.$i.'_workweek'.$j};
					} elsif ($in->{'parent'.$i.'_future_payscale'.$j} eq 'month') {
						${'parent'.$i.'_earnings'} += $in->{'parent'.$i.'_future_wage_'.$j} *  12 * $in->{'parent'.$i.'_future_workweek'.$j} / $in->{'parent'.$i.'_workweek'.$j};
					} elsif ($in->{'parent'.$i.'_future_payscale'.$j} eq 'year') {
						${'parent'.$i.'_earnings'} += $in->{'parent'.$i.'_future_wage_'.$j} * $in->{'parent'.$i.'_future_workweek'.$j} / $in->{'parent'.$i.'_workweek'.$j};
					}
				} else { #If the adult is not currently working, we just use their future information.
					if ($in->{'parent'.$i.'_future_payscale'.$j} eq 'week') {
						${'parent'.$i.'_earnings'} += $in->{'parent'.$i.'_future_wage_'.$j} *  52;
					} elsif ($in->{'parent'.$i.'_future_payscale'.$j} eq 'biweekly') {
						${'parent'.$i.'_earnings'} += $in->{'parent'.$i.'_future_wage_'.$j} *  26;
					} elsif ($in->{'parent'.$i.'_future_payscale'.$j} eq 'month') {
						${'parent'.$i.'_earnings'} += $in->{'parent'.$i.'_future_wage_'.$j} *  12;
					} elsif ($in->{'parent'.$i.'_future_payscale'.$j} eq 'year') {
						${'parent'.$i.'_earnings'} += $in->{'parent'.$i.'_future_wage_'.$j};
					}
				}
			}
			${'parent'.$i.'_earnings'} = &round(${'parent'.$i.'_earnings'});
			${'parent'.$i.'_earnings_m'} = &round(${'parent'.$i.'_earnings'}/12);
			$earnings += ${'parent'.$i.'_earnings'};
			${'parent'.$i.'_transhours_w'} = ${'parent'.$i.'_employedhours_w'} + $in->{'parent'.$i.'_future_traininghours'};
		}
	}
	print $earnings."\n";

	$earnings_mnth = $earnings / 12;
	$earnings_week = $earnings / 52;

	#Identifying the least-working parent and assigning them child care duties, and also assigning transhours variables for child care.
	$parent_workhours_w = greatest($parent1_transhours_w, $parent2_transhours_w, $parent3_transhours_w, $parent4_transhours_w); #We start with the most of these and then use the following loop to wittle down to an existing parent in the household who works the least hours, or is tied with other parents for working the least hours.
	for(my $i=1; $i<=4; $i++) { 
		if ($in->{'parent'. $i.'_age'} > 0) {
			if (${'parent'.$i.'_transhours_w'} <= $parent_workhours_w) {
				$parent_workhours_w = ${'parent'.$i.'_transhours_w'};
				$caregiver = $i; #We define the caregiver as the adult who works the least.
				# print $parent_workhours_w; #Not sure why at one point it seemed important to print this.
			}
		}
	}

	#Last, we define the "gift" income a family is receiving, based on the inputs the user provided in response to questions specific to Pensylvania. This is specific to Pennsylvania because Pittsburgh is one of the cities experimenting with a "Guaranteed Income" project, which are distributed as gifts. These inputs are defined as 0 in states that are not engaging in this experiment.
	
	if ($out->{'scenario'} eq 'current') {
		$gift_income_m = $in->{'current_gift_income_m'};
	} else {
		$gift_income_m = $in->{'future_gift_income_m'};
	}
	$gift_income = 12 * $gift_income_m;

	#debugs
	foreach my $debug (qw(parent1_employedhours_w parent2_employedhours_w parent2_employedhours_w parent2_earnings parent1_employedhours_w_initial parent2_employedhours_w_initial)) {
		print $debug.": ".${$debug}."\n";
	}

    #outputs
    foreach my $name (qw(parent1_employedhours_w parent2_employedhours_w parent3_employedhours_w parent4_employedhours_w parent1_earnings parent2_earnings parent3_earnings parent4_earnings parent1_earnings_m parent2_earnings_m parent3_earnings_m parent4_earnings_m parent_workhours_w parent1_employedhours_w parent2_employedhours_w parent3_employedhours_w parent4_employedhours_w parent1_transhours_w parent2_transhours_w parent3_transhours_w parent4_transhours_w earnings earnings_mnth earnings_week parent1_earnings_initial parent2_earnings_initial parent3_earnings_initial parent4_earnings_initial tanf_recd caregiver gift_income gift_income_m rent_paid_m
	)) { 
        $out->{$name} = ${$name};
    }
	
}

1;