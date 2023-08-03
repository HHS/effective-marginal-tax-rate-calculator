# "FILING_STATUS" CODE, Federal 2021  
# We need to know the tax filing status of the family and family members for the purposes of assessing Medicaid units, and later for taxes. 
#=============================================================================#
#	INPUTS AND OUTPUTS NEEDED FROM OTHER CODES
#
#	INPUTS FROM USER:
#		family_structure
#		married1
#		married2
#		parent#_age
#		parent#_ft_student
#		parent#_pt_student
#		child_number
#
#=============================================================================#

sub filing_status {

    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	#Filing Status, which we need for hlth but also later for taxes. For now, just copying from taxes, but will delete that eventually or if loading takes too much time.
	our $filing_status1 = 'none'; #Filing status for first tax filing unit. There are up to four tax filing units if we consider households with up to 4 adults.
	our $filing_status2 = 'none';
	our $filing_status3 = 'none';
	our $filing_status4 = 'none';
	our $adults_lefttocount = 0;
	our $filers_count = 0;
	our $filing_status1_adult1 = 0;
	our $filing_status1_adult2 = 0;
	our $filing_status1_adult3 = 0;
	our $filing_status1_adult4 = 0;
	our $filing_status2_adult1 = 0;
	our $filing_status3_adult1 = 0;
	our $filing_status4_adult1 = 0;

	our $parent1_incapacitated = 0;
	our $parent2_incapacitated = 0;
	our $parent3_incapacitated = 0;
	our $parent4_incapacitated = 0;
	our $parent_incapacitated_total = 0;
	our $adult_children = 0;
	our $adult_student_dependents = 0;

	
	# How many households need to be counted?
	$adults_lefttocount = $in->{'family_structure'}; #As a check, this should always be reduced to 0 by the below codes by the end.

	#One thing we do here is identify which adults can be classified as "incapacitated" according to federal and state rules:
	for(my $i=1; $i<=4; $i++) {
		if ($in->{'parent'.$i.'_age'} > 0) {
			if ($in->{'disability_parent'.$i} == 1 && $out->{'parent'.$i.'_earnings'} == 0) {
				${'parent'.$i.'_incapacitated'} = 1;
			} else { 
				${'parent'.$i.'_incapacitated'} = 0;
			}
		}
	}	
	
	for(my $i=2; $i<=4; $i++) {
		if ($in->{'parent'.$i.'_age'} < 24 && ($in->{'parent'.$i.'_pt_student'} == 1 || $in->{'parent'.$i.'_ft_student'} == 1)) {
			$adult_student_dependents += 1;
		}
	}
	
	#If there is a married couple in the house, we assign them to filing status 1, and also assign any other eligible adults to that filing unit.
	for(my $i=1; $i<=4; $i++) {
		#Filing status 1:
		if ($in->{'parent'.$i.'_age'} > -1) {
			if (($in->{'married1'} == $i || $in->{'married2'} == $i) && $filing_status1 ne "Married") {
				$filing_status1 = "Married";
				$filing_status1_adult1 = $in->{'married1'};
				$filing_status1_adult2 = $in->{'married2'};
				print "debug1:".$filing_status1_adult2."\n";
				$filers_count += 1;
				$adults_lefttocount -=2;
				#Finding other adults in the household that can be counted as dependents or qualifying children:
				#To meet the qualifying child test, your child must be younger than you and either younger than 19 years old or be a "student" younger than 24 years old as of the end of the calendar year.
				#There's no age limit if your child is "permanently and totally disabled" or meets the qualifying relative test.
				if ($adults_lefttocount > 0) {
					for(my $j=1; $j<=4; $j++) {
						if ($in->{'parent'.$j.'_age'} > -1) {
							if ($j != $filing_status1_adult1 && $j != $filing_status1_adult2 && $filing_status1_adult3 == 0 && (${'parent'.$j.'_incapacitated'} == 1 || $in->{'parent'.$j.'_age'} < 19 || ($in->{'parent'.$j.'_age'} < 24 && ($in->{'parent'.$j.'_ft_student'} == 1 || $in->{'parent'.$j.'_pt_student'} == 1)))) {
								$filing_status1_adult3 = $j;
								$adults_lefttocount -=1;
								$adult_children +=1;
							}
						}
					}
					for(my $j=1; $j<=4; $j++) {
						if ($in->{'parent'.$j.'_age'} > -1) {
							if ($adults_lefttocount > 0 && $j != $filing_status1_adult1 && $j != $filing_status1_adult2 && $j != $filing_status1_adult3 && (${'parent'.$j.'_incapacitated'} == 1 || $in->{'parent'.$j.'_age'} < 19 || ($in->{'parent'.$j.'_age'} < 24 && ($in->{'parent'.$j.'_ft_student'} == 1 || $in->{'parent'.$j.'_pt_student'} == 1)))) {
								$filing_status1_adult4 = $j;
								$adults_lefttocount -=1;
								$adult_children +=1;
							}
						}
					}
				}			
			}
		}
	}
	if ($filing_status1 ne "Married") {
		if($in->{'child_number'} + ${'parent2_incapacitated'} + ${'parent3_incapacitated'} + ${'parent4_incapacitated'} + $adult_student_dependents >= 1) {
			$filing_status1 = "Head of Household";
			$filers_count += 1;
			$filing_status1_adult1 =  1; #We are defaulting here to parent1 being the head of household. This may not be optimal for tax purposes, if there are other filing units, but since we don't know which parent the children in the household are necessarily related to, this seems appropriate for now.
			$adults_lefttocount -=1;
			for(my $j=2; $j<=4; $j++) {
				if ($in->{'parent'.$j.'_age'} > -1) {
					if ($adults_lefttocount > 0 && $j != $filing_status1_adult1 && $filing_status1_adult2 == 0 && (${'parent'.$j.'_incapacitated'} == 1 || $in->{'parent'.$j.'_age'} < 19 || ($in->{'parent'.$j.'_age'} < 24 && ($in->{'parent'.$j.'_pt_student'} == 1 || $in->{'parent'.$j.'_ft_student'} == 1)))) {
						$filing_status1_adult2 = $j;
						$adults_lefttocount -=1;
						$adult_children +=1;
					}
				}
			}
			for(my $j=2; $j<=4; $j++) {
				if ($in->{'parent'.$j.'_age'} > -1) {			
					if ($adults_lefttocount > 0 && $j != $filing_status1_adult1 && $j != $filing_status1_adult2 && $filing_status1_adult3 == 0 && ($in->{'parent'.$j.'_age'} < 19 || (${'parent'.$j.'_incapacitated'} == 1 || $in->{'parent'.$j.'_age'} < 24 && ($in->{'parent'.$j.'_pt_student'} == 1 || $in->{'parent'.$j.'_ft_student'} == 1)))) {
						$filing_status1_adult3 = $j;
						$adults_lefttocount -=1;
						$adult_children +=1;
					}
				}
			}
			for(my $j=2; $j<=4; $j++) {
				if ($in->{'parent'.$j.'_age'} > -1) {			
					if ($adults_lefttocount > 0 && $j != $filing_status1_adult1 && $j != $filing_status1_adult2 && $j != $filing_status1_adult3 && (${'parent'.$j.'_incapacitated'} == 1 || $in->{'parent'.$j.'_age'} < 19 || ($in->{'parent'.$j.'_age'} < 24 && ($in->{'parent'.$j.'_pt_student'} == 1 || $in->{'parent'.$j.'_ft_student'} == 1)))) {
						$filing_status1_adult4 = $j;
						$adults_lefttocount -=1;
						$adult_children +=1;
					}
				}
			}
		}
	}
	
	if ($filing_status1 ne "Married" && $filing_status1 ne "Head of Household") {
		#All adults are counted as single for tax purposes. We start by assigning this to filing status 1 before filling it out for the other adutsl.
		$filing_status1 = "Single";
		$filing_status1_adult1 = 1;
		$adults_lefttocount -=1;
		$filers_count += 1;
	}
	if ($adults_lefttocount > 0) { #We now count all the other adults in the household -- who at this point in the code will be identified as neither married nor the head of a household -- as single filers.
		for(my $i=2; $i<=4; $i++) { #We start with i=2 because at this point, filing status 1 is already identified.
			if ($in->{'parent'.$i.'_age'} > -1 && $adults_lefttocount > 0 
			&& $i != $filing_status1_adult1  
			&& $i != $filing_status1_adult2
			&& $i != $filing_status1_adult3
			&& $i != $filing_status1_adult4
			&& $i != $filing_status2_adult1
			&& $i != $filing_status3_adult1 ) {
				$filers_count += 1;
				${'filing_status'.$filers_count} = 'Single';
				${'filing_status'.$filers_count.'_adult1'} = $i;
				$adults_lefttocount -= 1;
			}
		}
	}

	#counting incapacitated adults:
	for(my $i=1; $i<=$in->{'family_structure'}; $i++) { #For all possible adults in the househld:
		for(my $j=2; $j<=4; $j++) { #For the first tax filing unit, the number of potential dependent adults:
			if ($i == ${'filing_status1_adult'.$j} && ${'parent'.$i.'_incapacitated'} == 1) {
				$parent_incapacitated_total +=1; #This is the total number of adults who are incapacitated who can be claimed as a dependent for tax purposes. This method ensures that the head of a tax filing units who is incapacitated cannot receive tax credits for caring for their own needs as a dependent.
			}
		}
	}

	#debugs:
	foreach my $debug (qw(filing_status1_adult1 filing_status1_adult2 filing_status1_adult3 filing_status1_adult4 filing_status2_adult1 filing_status3_adult1 filing_status4_adult1 adult_student_dependents parent_incapacitated_total)) { 
		print $debug.": ".${$debug}."\n";
	}

	
	# outputs

    foreach my $name (qw(
	parent1_incapacitated 
	parent2_incapacitated 
	parent3_incapacitated 
	parent4_incapacitated 
	parent_incapacitated_total 
	filers_count
	filing_status1_adult1 
	filing_status1_adult2 
	filing_status1_adult3 
	filing_status1_adult4 
	filing_status2_adult1 
	filing_status3_adult1 
	filing_status4_adult1 
	filing_status1
	filing_status2
	filing_status3
	filing_status4
	adults_lefttocount
	adult_children
	)) { 
        $out->{$name} = ${$name};
	}
}

1;
