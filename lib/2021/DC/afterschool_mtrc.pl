#=============================================================================#
#  Afterschool (officially “Out of School Time Program) Module – 2021 – DC
#=============================================================================#

# Overview:
#
# This module models afterschool as provided in 55 schools funded by the Out-of-School-Time Program (OSTP) as described at https://dcps.dc.gov/afterschool.
# Prior to the the 2021-22 school year, afterschool co-pays constituted the entirety of afterschool expenses for children attending OSTP afterschool. Parents or guardians pick up children from afterschool just like they would be picked up from regular school, or can sign off saying it’s okay to let their child walk home. Since afterschool is offered at the same location as a child’s regular school, there are no additional transportation costs (or parent pick-up costs).  See Afterschool Parent Handbook 2015_0 for these descriptions. 
# The first participating child pays the full copay fee. The second participating child pays half the fee. Subsequent children are free. 
# Afterschool ends at 6:15pm each school day. 
# Schools not participating in the OSTP program can also offer their own afterschool programs.
#
# Inputs referenced in this module:
#
# FROM BASE
#  afterschool 	#This is a flag representing whether users select “OSTP Afterschool?” as a potential benefit to receive  in the “public benefits” checklist. .
#  prek
#  child#_age
#
# FROM TANF
#  tanf_recd
# 
# FROM HEALTH
#  hlth_cov_child#

#=============================================================================#

sub afterschool
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

    # Hardcoded variables
    our $afterschool_copay_max_perchild = 94.5 * 8;   #  The maximum DC fee for afterschool for one child when fee is not waived was scheduled to be $94.50 from October to May in the 2019-2020.
    our $afterschool_copay_reduced_perchild = $afterschool_copay_max_perchild/2;   #  The DC fee for afterschool for one additional child when fee is not waived was half the rate for the first child. 

    our $afterschool_copay_max = $afterschool_copay_max_perchild + $afterschool_copay_reduced_perchild;   #  The maximum DC fee for unsubsidized OSTP afterschool for the entire family  when fee is not waived. One child's fee is the maximum fee per child, one additional child's fee is half the maximum fee per child, and other children in the family can participate for free.

    # Outputs created 
    our $afterschool_child1 = 0;        #  Binary indicator as to whether child1 is enrolled in afterschool
    our $afterschool_child2 = 0;		
    our $afterschool_child3 = 0;		
    our $afterschool_child4 = 0;		
    our $afterschool_child5 = 0;		

    our $afterschool_child1_copay = 0;
    our $afterschool_child2_copay = 0;
    our $afterschool_child3_copay = 0;
    our $afterschool_child4_copay = 0;
    our $afterschool_child5_copay = 0;

    our $afterschool_expenses = 0; 	#  The total afterschool fees for the family

	our $afterschool_need = 0; # number of children who need afterschool

	# 1: Check for afterschool flag
	if ($in->{'ostp'} == 1) {

	# 2: Check for afterschool eligibility (and enrollment) by age. 
	# The below code is written to include eligibility criteria applied to all children enrolled in pk3-8 elementary and middle school. However, evidence such as that contained in the DC Alliance of Youth Advocates report at http://www.dc-aya.org/sites/default/files/DCAYA%20%23ExpandLearningDC_June%202016%20REVISED_0.pdf makes it pretty clear that (a) afterschool does not reach many low-income youth,  and (b) afterschool programs are much more prevalent at the elementary school level compared to the middle school level. (See, for example, footnote 15 of that report. POSSIBLE QUESTION FOR DC DHS: Should we include an on/off option for afterschool in the model that allows users to model the impact of afterschool for all children ages 3-13, or should we have two separate afterschool on/off options, one for preK/elementary school and another for middle school? This would allow analyses to measure the separate impacts of elementary vs. middle school afterschool programs.

		for(my $i=1; $i<=5; $i++) {
			if(($in->{'prek'} == 1 && ($in->{'child' . $i . '_age'} == 3 || $in->{'child' . $i . '_age'} ==4)) || ($in->{'child' . $i . '_age'} >= 5 && $in->{'child' . $i . '_age'} <=13)) {
				${'afterschool_child' . $i} = 1;
				${'afterschool_need'}++;
			
				# Determines whether child receives TANF and/or Medicaid; if so, copay = 0. 
				if($out->{'tanf_recd'} > 0 || $out->{'hlth_cov_child' . $i}  eq 'Medicaid' || $in->{'year'} == 2021) { #Afterschool copays are suspended for the 2021-2022 school year. While this means that for the 2021 MTRC afterschool expenses will simply be 0, we are keeping this logic in here for potential future use in case fees are restored.
					${'afterschool_child' . $i . '_copay'} = 0;
				} else {
					${'afterschool_child' . $i . '_copay'} = ${'$afterschool_copay_max_perchild'};
				}
			}
		}
		
	   $afterschool_expenses = &least($afterschool_child1_copay + $afterschool_child2_copay + $afterschool_child3_copay +  $afterschool_child4_copay + $afterschool_child5_copay, $afterschool_copay_max);

		# This may or may not be useful for the child care model, but we assign an average value of afterschool expenses to each child in afterschool. 
		if (${'afterschool_expenses'} > 0) {
			for(my $i=1; $i<=5; $i++) {
				if (${'afterschool_child' . $i} > 1) {
					${'afterschool_child' . $i . '_copay'} = ${'afterschool_expenses'}/${'afterschool_need'}
				}
			} 
		}

		# Note: At this point, we are defining the afterschool_expenses here, and will be including it as a potential part of the CDCTC deduction in fedtax. Conceivably it could also be added to the child care expenses in the child care module. However, it may or may not be cheaper to enroll children in afterschool, depending on the user inputs  – certainly it will be more expensive if a family is choosing not to enroll in Medicaid or TANF when eligible, but enrolling their children in afterschool even when not working. So for now, we're modeling afterschool expenses as a separate expense. 

	}

	#debugs
	#foreach my $debug (qw(afterschool_expenses)) {
	#	print $debug.": ".${$debug}."\n";
	#}
	

	# Outputs
    foreach my $name (qw(afterschool_expenses afterschool_child1 afterschool_child2 afterschool_child3 afterschool_child4 afterschool_child5 afterschool_child1_copay afterschool_child2_copay afterschool_child3_copay afterschool_child4_copay afterschool_child5_copay)) {
       $out->{$name} = ${$name};
    }
	
}

1;
