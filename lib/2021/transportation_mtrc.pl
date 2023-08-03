#=============================================================================#
#  TRANSPORTATION - 2021
#=============================================================================#
#
# INPUTS NEEDED:
#
#  	FROM USER INTERFACE:
#   family_structure (or parent_number, if we choose to rename this variable)
#   residence
#	parent#_age (this is just used to determine which of parent1, parent2, parent3, and parent4 to count -- we use "-1" in child_age to indicate whether a child is present, this assumes the same of parent_age)
#   parent#_ft_student
#   parent#_pt_student
#	disability_parent#
#
#	DERIVED FROM MYSQL IN NCCP_SIMULATOR.PHP
#	percent_nonsocial = 0;       # percent of miles driven for "nonsocial" purposes (used to determine parent1's transportation costs)
#	public_trans_cost_d = 0;         # daily cost of commuting (ie, cost of round-trip fare)
#	public_trans_cost_max = 0;       # maximum cost of public transportation (ie, cost of 12 monthly passes)
#	publictrans_cost_d_dis = 0;         # daily cost of commuting (ie, cost of round-trip fare) for #people with disabilities
#	publictrans_cost_max_dis = 0;       # maximum cost of public transportation (ie, cost of 12 #monthly passes) for people with disabilities
#       
#
# OUTPUTS NEEDED (from other modules):
#
#   FROM PARENT_EARNINGS:
#	parent1_employedhours_w
#	parent2_employedhours_w
#	parent3_employedhours_w
#	parent4_employedhours_w
#
#=============================================================================#

sub transportation {
 
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# outputs created
    our $cost_per_mile = 0.56;       	# IRS cost per mile (varies by year). This is up to date as of tax year 2021. See https://www.irs.gov/newsroom/irs-issues-standard-mileage-rates-for-2021
	our $parent1_transhours_w = 0;	#Hours away from home due to work or school attendance by the parent.
	our $parent2_transhours_w = 0;
	our $parent3_transhours_w = 0;
	our $parent4_transhours_w = 0;
	our $parent_workhours_w = 0;	#The hours away from home due to work or school attendance by the least working parent. 
	our $trans_expenses = 0;          # family transportation costs

	# variables used in this script
    our $parent1_transdays_w = 0;   # number of days of transportation needed by parent 1, including education
    our $parent2_transdays_w = 0;
    our $parent3_transdays_w = 0;
    our $parent4_transdays_w = 0;
    our $percent_work = 0;            # percent of miles driven for "work" purposes (used to determine parent2's transportation costs)
    our $avg_miles_driven = 0;        # avg annual miles driven, based on size of place of residence
    our $parent1_transcost_full = 0;     # parent 1's transportation costs when parent 1 is working full time
    our $parent2_transcost_full = 0;
    our $parent3_transcost_full = 0;
    our $parent4_transcost_full = 0;
    our $parent1_transcost = 0;          # parent's transportation costs when parent is working full time
    our $parent2_transcost = 0;
    our $parent3_transcost = 0;
    our $parent4_transcost = 0;
	our $caregiver = 0;					# We'll use this variabel to assign the caregiver role to the parent who works the least, and is therefore engaged in child care.
	our $transhours_least = 0;			# We need this in our formulas to assign the caregiver role.
	our $transcost_nonsocialnonwork = 0;
	our $nonsocialnonwork_portion_public = 0;
	our $transcost_nonsocialnonwork_dis = 0;
	our $transdays_total = 0;
	our $fulltime_work_travel = 0; #Needed in case the user has entered overrides but without working any hours initially. 

	
	# Transportation costs:
   
	for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
		#Adult students: We can assume that a full-time student attends 5 classes a week for 15 hours/week. We can assume that a part-time students attends 3 classes a week for 10 hours/week.
		if ($out->{'scenario'} eq 'current') {
			print "$i".": $in->{'parent'.$i.'_transdays_w'} \n";
			${'parent'.$i.'_transdays_w'} = $in->{'parent'.$i.'_transdays_w'};
			${'parent'.$i.'_transhours_w'} = $out->{'parent'.$i.'_employedhours_w'} + $in->{'parent'.$i.'_traininghours'};	
		} elsif ($out->{'scenario'} eq 'future') {
			${'parent'.$i.'_transdays_w'} = $in->{'parent'.$i.'_future_transdays_w'};
			${'parent'.$i.'_transhours_w'} = $out->{'parent'.$i.'_employedhours_w'} + $in->{'parent'.$i.'_future_traininghours'};	
		}
	}

    if($in->{'trans_override'}) {		
		if ($out->{'scenario'} eq 'current') {
			#We first use the overrides entered for each adult to calculate how much is initially spends on transportation, including for work and for other activities:
			$in->{'transcost_initial'} = 0;
			$in->{'transdays_total_initial'} = 0;
			$in->{'transcost_work_initial'} = 0;
			$in->{'transcost_nonwork'} = 0;
			for(my $i=1; $i<=$in->{'family_structure'}; $i++) { 
				$in->{'transcost_initial'} += $in->{'trans_override_parent'.$i.'_amt'} * 12;
				$in->{'transdays_total_initial'} += ${'parent'.$i.'_transdays_w'};
				#We estimate how much of these costs are attributable to non-work related errands, based on national data.
			}
			$in->{'transcost_work_initial'} = $in->{'percent_work'} * $in->{'transcost_initial'};
			$in->{'transcost_nonwork'} = (1 - $in->{'percent_work'}) * $in->{'transcost_initial'};
			$trans_expenses = $in->{'transcost_initial'}; #This is obviously approximate, but it's better to carve out some portion than to assume that all costs will increase proportionately with more work.
		} else {
			#We use the input variables established through the "current" situation to see how the household's expenses could change with more work.
			for(my $i=1; $i<=$in->{'family_structure'}; $i++) { 
				$transdays_total += ${'parent'.$i.'_transdays_w'};
			}
			if ($in->{'transdays_total_initial'} == 0) {
				#When 0, we can consider the initial transit cost to be the transcost_nonwork  nonwork costs, and use the ratios from the transportation survey as if they reflect a 5-day workweek, and that the percent_work is the percentage of time during that 5-day workweek devoted to work travel.
				$fulltime_work_travel = $in->{'transcost_initial'} * $in->{'percent_work'} / (1 - $in->{'percent_work'});
				$trans_expenses = $in->{'transcost_initial'} + ($transdays_total / 5) * $fulltime_work_travel; #If they are not currently working, and enter in a transportation cost, enter 0 in total costs, and do not select to let the calculator make estimates, we have to output this at 0, since we have no baseline to work from. Conceivably, we could add in an option of "0 transportation costs now, but use the calculator to estimates costs for more work" or something along those lines.
			} else {
				$trans_expenses = $in->{'transcost_nonwork'} + ($transdays_total / $in->{'transdays_total_initial'}) *  $in->{'transcost_work_initial'};
			}
        }
	} else {
		#We calcualte the hours that the least-working parent works, useful for child care and possibly other codes.
		if ($in->{'family_structure'} == 1) {
			$parent_workhours_w = $parent1_transhours_w;
		} elsif ($in->{'family_structure'} == 2) {
			$parent_workhours_w = &least($parent1_transhours_w, $parent2_transhours_w); 
		} elsif ($in->{'family_structure'} == 3) {
			$parent_workhours_w = &least($parent1_transhours_w, $parent2_transhours_w, $parent3_transhours_w);
		} elsif ($in->{'family_structure'} == 4) {
			$parent_workhours_w  = &least($parent1_transhours_w, $parent2_transhours_w, $parent3_transhours_w, $parent4_transhours_w);
		}
		#We identify the least-working non-disabled parent (or a parent tied for least working), to assign additional nonsocial transportation activities to them.
		#	$transhours_least = &greatest($parent1_transhours_w, $parent2_transhours_w, $parent3_transhours_w, $parent4_transhours_w);
		if ($in->{'family_structure'} == 1 || $in->{'family_structure'} == $in->{'disability_count'}) {
			$caregiver = 1; #in single-parent homes or homes in which all parents have a disability, we assign caregiver transportation responsibilities to the casehead, parent1.
		} else {
			$caregiver = 1; # We start by assuming the casehead is the adult in the household who does chores, drives to appointments, picks up food, etc.
			for(my $i=1; $i<=4; $i++) { 
				if ($in->{'parent'. $i.'_age'} > 0) { # && ${'parent'.$i.'_transhours_w'} < $transhours_least) {
					for(my $j=1; $j<=4; $j++) { 
						if ($i != $j && $in->{'parent'. $j.'_age'} > 0 && (${'parent'.$i.'_transdays_w'} <  ${'parent'.$j.'_transdays_w'} || $in->{'disability_parent'.$j}==1)) { 
		#					$transhours_least = ${'parent'.$i.'_transhours_w'};
							$caregiver = $i;
						}
					}
				}
			}
		}
		# Use “Private transportation cost” table to determine percent_nonsocial, percent_work, and avg_miles_driven 
		# according to residence_size.
			#The breakdown fo transportation costs is somewhat arbitrary, but we can assign the higher "nonsocial" value to the least-working parent. This number includes percent_work but also other non-social activities, like doctors' appointments. There may be a better way of doing this.

		for(my $i=1; $i<=4; $i++) { 
			if ($in->{'parent'. $i.'_age'} > 0) {
				if ($in->{'trans_type'} eq 'private' || ($in->{'user_trans_type'} eq 'car' || $in->{'user_trans_type'} eq 'private')) { 
					print "debug trans1 \n";
					$transcost_nonsocialnonwork = ($in->{'percent_nonsocial'} - $in->{'percent_work'}) * $in->{'avg_miles_driven'} * $cost_per_mile;
					${'parent'.$i.'_transcost_full'} = $in->{'percent_work'} * $in->{'avg_miles_driven'} * $cost_per_mile;
					if ($i == $caregiver) {
						${'parent'.$i.'_transcost'} = $transcost_nonsocialnonwork + ${'parent'.$i.'_transdays_w'}/5 * ${'parent'.$i.'_transcost_full'};
					} else {
						${'parent'.$i.'_transcost'} = (${'parent'.$i.'_transdays_w'}/5) * ${'parent'.$i.'_transcost_full'};
					}
				} else { #Public transportation:
					$transcost_nonsocialnonwork = $in->{'nonsocialnonwork_portion_public'} * (5 * $in->{'publictrans_cost_d'} * 52);
					$transcost_nonsocialnonwork_dis = $in->{'nonsocialnonwork_portion_public'} * (5 * $in->{'publictrans_cost_d_dis'} * 52);
					if ($i == $caregiver) {
						if ($in->{'disability_parent'.$i}==0) {
							${'parent'.$i.'_transcost'} = &least($transcost_nonsocialnonwork + ${'parent'.$i.'_transdays_w'} * $in->{'publictrans_cost_d'} * 52, $in->{'publictrans_cost_max'});
						} else {
							${'parent'.$i.'_transcost'} = &least($transcost_nonsocialnonwork_dis + ${'parent'.$i.'_transdays_w'} * $in->{'publictrans_cost_d_dis'} * 52, $in->{'publictrans_cost_max_dis'});
						}
					} else {
						if ($in->{'disability_parent'.$i}==0) {
							${'parent'.$i.'_transcost'} = &least(${'parent'.$i.'_transdays_w'} * $in->{'publictrans_cost_d'} * 52, $in->{'publictrans_cost_max'});
						} else {
							${'parent'.$i.'_transcost'} = &least(${'parent'.$i.'_transdays_w'} * $in->{'publictrans_cost_d_dis'} * 52, $in->{'publictrans_cost_max_dis'});
						}
					}
				}
			}
		}
		$trans_expenses = &round($parent1_transcost + $parent2_transcost + $parent3_transcost + $parent4_transcost);
	}
	#debugging
	foreach my $debug (qw(parent_workhours_w parent1_transhours_w parent2_transhours_w parent3_transhours_w parent4_transhours_w trans_expenses)) {
		print $debug.": ".${$debug}."\n";
	}

	# outputs
    foreach my $name (qw(parent_workhours_w parent1_transhours_w parent2_transhours_w parent3_transhours_w parent4_transhours_w trans_expenses)) { 
       $out->{$name} = ${$name};
    }	
}

1;
