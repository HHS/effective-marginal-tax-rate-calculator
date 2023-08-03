#=============================================================================#
#  Additional (Refundable) Child Tax Credit -- 2021 
#=============================================================================#
#
# Inputs referenced in this module:
#
#   FROM USER
#	ctc
#
#	FROM FRS.PM
#	children_under17
#
#	FROM PARENT_EARNINGS
#	earnings
#
#   FROM FEDERAL TAXES:
#	ctc_potential_recd
#	ctc_nonref_recd
#	cadc_recd
#
#   FROM PAYROLL TAXES:
#	payroll_tax
#
#	FROM EITC
#	eitc_recd
#
#=============================================================================#

sub ctc
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

  # policy variables used
    our $ctc_add_threshold    = 2500;     # earnings threshold for the refundable child tax credit, as indicated on form 8812. (Earnings threshold above which the family's ACTC begins to increase by 15%)
	our $actc_per_child = 1400;			# The maximum additional (refundable) child tax credit per child. Confirmed as of 2021.

  # outputs created
    our $ctc_total_recd = 0;              # [Child Tax Credit] Total value of the Child Tax Credit, including refundable and non-refundable portions
    our $federal_tax_credits = 0;

  # intermediary variables (needed for calculations specific to this code)
    our $ctc_add_line3 = 0;                   # line 3 on form 8812: excess child tax credit (ctc_potential - ctc_nonref_recd)
	our $ctc_add_line4 = 0;						# line 4 on form 8812.
	our $ctc_add_line5 = 0;						# line 5 on form 8812.
    our $ctc_add_line8 = 0;                   # line 8 (formerly line 6, prior to 2018) on form 8812: 15% of earnings above ctc threshold (earnings - ctc_add_threshold)
    our $ctc_add_line14 = 0;                  # line 14 (formerly line 12, prior to 2018) on form 8812: greater of line 8 (15% of earnings above ctc threshold) OR line 13 (payroll_tax - EITC)
    our $ctc_additional_recd = 0;         # additional annual child tax credit (i.e., refundable portion)   

  #
  # 1. DETERMINE VALUE OF ADDITIONAL CTC
  #
  # Only tax filing unit 1 is eligible for the ACTC, since we are assigning all chidlren to that unit.
  
    if($in->{'ctc'} != 1) {
        $ctc_additional_recd = 0;
    } else {
      # variables used within this module
        if($out->{'ctc_potential_recd'} <= 0) { 
            $ctc_additional_recd = 0; 
        } else {
            if ($in->{'covid_ctc_expansion'} == 1) {
				$ctc_additional_recd = $out->{'ctc_potential_recd_nonother'}; #This is the potential refundable amount of the credit under ARPA. It's the part of the potential credit that's separate from the credit for other dependents.
			} else {	
				$ctc_add_line3 = &pos_sub($out->{'ctc_potential_recd'}, $out->{'ctc_nonref_recd'});
				$ctc_add_line4 = $actc_per_child * $in->{'children_under17'}; 
				$ctc_add_line5 = &least($ctc_add_line3, $ctc_add_line4);
				$ctc_add_line8 = 0.15 * &pos_sub($out->{'earnings_unit1'}, $ctc_add_threshold);

				if($ctc_add_line3 == 0) { 
					$ctc_additional_recd = 0; 
				} else {
					if($in->{'children_under17'} < 3) { 
						if($ctc_add_line8 == 0) {
							$ctc_additional_recd = 0;
						} elsif($ctc_add_line8 > 0)  {
							$ctc_additional_recd = &least($ctc_add_line5, $ctc_add_line8);
						}
					} else {
						if($ctc_add_line8 >= $ctc_add_line5) { 
							$ctc_additional_recd = $ctc_add_line5; 
						} else {
							$ctc_add_line14 = &greatest($ctc_add_line8, ($out->{'payroll_tax1'} - $out->{'eitc_recd1'}));
							$ctc_additional_recd = &least($ctc_add_line14, $ctc_add_line5);
						}
					}
				}
			}
        }
    }
	# CALCULATE THE TOTAL CHILD TAX CREDIT (REFUNDABLE AND NONREFUNDABLE) AND TOTAL FEDERAL TAX CREDITS. 

    $ctc_total_recd = $ctc_additional_recd + $out->{'ctc_nonref_recd'};

    $federal_tax_credits = $out->{'eitc_recd'} + $ctc_total_recd + $out->{'cadc_recd'};

	#This is the last federal tax code. Because state credits are calculated after federal tax credits, we define the tax_before_credits and tax_after_credits variables in the state tax codes modules. So even if a state has no taxes, they should have a state tax module indicating as much and defining these variables. 

	# debugs:
	foreach my $debug (qw(ctc_additional_recd ctc_total_recd federal_tax_credits)) {
		print $debug.": ".${$debug}."\n";
	}
  # outputs
    foreach my $name (qw(ctc_additional_recd ctc_total_recd federal_tax_credits)) {
       $out->{$name} = ${$name};
	}
}

1;
