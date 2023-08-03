#=============================================================================#
#  EITC – 2021 
#=============================================================================#
# Calculates EITC benefits
#
#   FROM USER 
#	eitc
#	child_number
#	family_structure
#
#	FROM PARENT_EARNINGS
#	earnings
#
#=============================================================================#

sub eitc
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

  # outputs created
    our $eitc_recd = 0;           # [Federal EITC] annual value of federal EITC

  # variables used in this module
	our $childless_age_minimum	= 25;		#The minimum age needed for childless housheholds to claim EITC.
    our $eitc_phasein_rate      = 0;                            # eitc phase-in rate 
    our $eitc_plateau_start     = 0;		#earned income amount
    our $eitc_plateau_end       = 0;		#threshold phaseout amount
    our $eitc_max_value         = 0;			
    our $eitc_phaseout_rate     = 0;		
    our $eitc_income_limit      = 0;		#completed phaseout amount
	our $eitc_recd1 			= 0;		#EITC for the first counted filing unit.
	our $eitc_recd2 			= 0;
	our $eitc_recd3 			= 0;
	our $eitc_recd4 			= 0;
	our $meetsagemin_unit1 		= 0;
	our $meetsagemin_unit2 		= 0;
	our $meetsagemin_unit3 		= 0;
	our $meetsagemin_unit4 		= 0;

    if($in->{'eitc'} == 0) {
        $eitc_recd = 0; 
    } else {
		#First determine if there are any necessary EITC exclusions because of age.
		
		if ($in->{'covid_eitc_expansion'} == 1) { 
			$childless_age_minimum = 19; #ARPA lowered (for the 2021 tax year) the minimum age for childlress adults to claim the EITC
		}
		
		for(my $i=1; $i<=$out->{'filers_count'}; $i++) { #We calculate EITC for all the tax filing units in the household.
			# Use EITC table to determine (based on family_structure and child_number):

			for (my $j=1; $j<=4; $j++) {
				if ($in->{'parent'.$j.'_age'} > -1) {
					if ($in->{'parent'.$j.'_age'} >= $childless_age_minimum && ($j == ${'filing_status'.$i.'_adult1'} || ($i==1 && $j == ${'filing_status1_adult2'}))) {
						${'meetsagemin_unit'.$i} = 1;
					}
				}
			}
			if ($out->{'earnings_unit'.$i} == 0 || ($i == 1 && $in->{'child_number'} + $out->{'adult_children'} == 0 && $meetsagemin_unit1 == 0) || ($i > 1 && ${'meetsagemin_unit'.$i} == 0)){
				#The EITC uses the largest amount between earned income and gross income to determine the value of the EITC. So we can largely ignore earned income in our calculations below, since we do not (yet) account for any income reductions that could bring gross income below earned income. But, in order to claim the EITC, the filing unit must be able to claim at least $1 in earned income, so we include that check here. Also, in the case of childless households, at least one hh member must be 25 years old or older to qualify for the EITC. 
				${'eitc_recd'.$i} = 0;	
			} else {
				if ($i > 1 || $in->{'child_number'} + $out->{'adult_children'} == 0) { #Only tax filing unit 1 will include children. So we can use the childless EITC amounts for the rest of the units and for tax filing unit 1 if they have no children. 
					if ($in->{'covid_eitc_expansion'} == 1) { #Here's the expansion:
						#These figures were derived from ARPA, the EITC law, a helpful CRS report on the matter, and interpretations from previous IRS updates to the EITC law to reflect inflation. Under "normal years," the IRS releases statements with all these figures and updates, but the additional calculations are detailed below because the IRS has not released a similar guidance as they have for previous annual updates to EITC and other tax figures. Hence, the lengthy explanations for the numbers derived below.
						#ARPA indicates the phase-in and phase-out for the EITC is 15.3%, a change from the 7.65% of the original EITC law. 
						$eitc_phasein_rate = 0.153;
						$eitc_phaseout_rate = 0.153;
						#ARPA indicates the plateau start -- where the full EITC is claimed -- is $9,820, a seemingly inflation-adjusted amount from the original $4,220 plus the ARPA expansion.
						$eitc_plateau_start =  9820;
						#The maximum credit amount is the phase-in rate (.153) multiplied by the lowest earnings which qualifiies filers for the maximum credit amont ($9,820), rounded down.
						$eitc_max_value = 1502;
						#ARPA indicates the plateau end -- the highest income at which the full EITC can be claimed -- is $11,610, a seemingly inflation-adjusted amount from the original $5,280 plus the ARPA expansion. "In the case of a joint return filed by an eligible individual and such individual's spouse, the phaseout amount determined under subparagraph (A) shall be increased by $5,000." The previous IRS adjustment for 2021 indicated that the $5,000 indicated in the original law, adjusted for inflation, is $5,940 (the difference between $14,820 and $8,880. So that's $17,550, a number confirmed by CRS and other reports. CRS indicates this plateau's end is $11,610 for single filers, $17,550 for married ones.
						$eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 11610 : 17550);
						#The income limits or "income thresholds" for the EITC are mathematically derived from the numbers above, according to the EITC law, in federal statute "26 USC 32: Earned income," as follows: "The amount of the credit allowable to a taxpayer under paragraph (1) for any taxable year shall not exceed the excess (if any) of (A) the credit percentage of the earned income amount, over (B) the phaseout percentage of so much of the adjusted gross income (or, if greater, the earned income) of the taxpayer for the taxable year as exceeds the phaseout amount."  Using the variable designations (and $eitc_recd for the amount of EITC received, and $eitc_income_limit for these thresholds, this translates to 
						# $eitc_recd = ($eitc_phasein_rate) * ($eitc_plateau_start) - ($eitc_phaseout_rate)*($eitc_income_limit - $eitc_plateau_end).
						# When setting $eitc_recd to 0, the two numbers emerging from this equality for $eitc_income_limit are $21,427 and $27,367. These are not widely discussed figures but are reflected in charts in the CRS document and other documents related to the ARPA changes.
						$eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 21427 : 27367);
						
					} else {
						#Below are the regular, non-COVID EITC policy data for childless tax filers:
						$eitc_phasein_rate = 0.0765;
						$eitc_plateau_start = 7100;
						$eitc_max_value = 543;
						$eitc_phaseout_rate = 0.0765;
						$eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 8880 : 14820);
						$eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 15980 : 21920);
					}
				} elsif ($in->{'child_number'} + $out->{'adult_children'} == 1) {
				  $eitc_phasein_rate = 0.34;
				  $eitc_plateau_start = 10640;
				  $eitc_max_value = 3618;
				  $eitc_phaseout_rate = 0.1598;
				  $eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 19520 : 25470);
				  $eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 42158 : 48108);
				} elsif ($in->{'child_number'} + $out->{'adult_children'} == 2) {
				  $eitc_phasein_rate = 0.4;
				  $eitc_plateau_start = 14950;
				  $eitc_max_value = 5980;
				  $eitc_phaseout_rate = 0.2106;
				  $eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 19520 : 25470);
				  $eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 47915 : 53865);
				} elsif ($in->{'child_number'} + $out->{'adult_children'} >= 3) {
				  $eitc_phasein_rate = 0.45;
				  $eitc_plateau_start = 14950;
				  $eitc_max_value = 6728;
				  $eitc_phaseout_rate = 0.2106;
				  $eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 19520 : 25470);
				  $eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 51464 : 57414);
				}
			
				#First, we calculated EITC based on earned income alone.
				if ($out->{'gross_income'.$i} >= $eitc_income_limit || $out->{'earnings_unit'.$i}  >= $eitc_income_limit) { 
					${'eitc_recd'.$i} = 0;
				} elsif($out->{'earnings_unit'.$i} < $eitc_plateau_start) { 
					${'eitc_recd'.$i} = $eitc_phasein_rate * $out->{'earnings_unit'.$i}; 
				} elsif($out->{'earnings_unit'.$i} >= $eitc_plateau_start && $out->{'earnings_unit'.$i} < $eitc_plateau_end) { 
					${'eitc_recd'.$i} = $eitc_max_value; 
				} elsif($out->{'earnings_unit'.$i} >= $eitc_plateau_end && $out->{'earnings_unit'.$i} < $eitc_income_limit) { 
					${'eitc_recd'.$i} = $eitc_phaseout_rate * ($eitc_income_limit - $out->{'earnings_unit'.$i}); 
				}
					
				#Then, we check if the conditions are met for the EITC to be determined by gross income, which occurs when gross income is higher than earned income and gross income exceeds the beginning of the EITC's phase-out period. The EITC is the smaller of these two calculations. 
				
				if ($out->{'gross_income'.$i} > $out->{'earnings_unit'.$i} && $out->{'gross_income'.$i} >= $eitc_plateau_end && $out->{'gross_income'.$i} < $eitc_income_limit) {
					${'eitc_recd'.$i} = &least(${'eitc_recd'.$i},$eitc_phaseout_rate * ($eitc_income_limit - $out->{'gross_income'.$i}));
				}

				# round eitc_recd to the nearest integer
				${'eitc_recd'.$i} = sprintf "%.0f", ${'eitc_recd'.$i};
			}
		}
	$eitc_recd = $eitc_recd1 + $eitc_recd2 + $eitc_recd3 + $eitc_recd4; 
    }

	foreach my $debug (qw(eitc_recd)) {
		print $debug.": ".${$debug}."\n";
	}

  # outputs
    foreach my $name (qw(eitc_recd eitc_recd1 eitc_recd2 eitc_recd3 eitc_recd4 meetsagemin_unit1 meetsagemin_unit2 meetsagemin_unit3 meetsagemin_unit4)) {
       $out->{$name} = ${$name};
    }
	
}

1;