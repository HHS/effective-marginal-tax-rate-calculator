#=============================================================================#
#  Payroll Module -- 2021 
#=============================================================================#
# Inputs referenced in this module: 
#
#   FROM PARENT EARNINGS:
#       parent#_earnings
#		filing_status_adult#
#
#=============================================================================#

sub payroll
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

  # policy variables used within this module
    my $social_sec_rate     = 0.062;    # social security tax rate
    my $medicare_rate       = 0.0145;   # medicare rate
    my $ssec_income_limit   = 142800;    # social security  wage base limit, the maximum wage subject to the tax for the year. Updated for 2021.
    my $add_medicare_tax   = 0.009; 	#additional Medicare tax to those earning more than $200,000. 
    my $add_medicare_inc = 200000;	#wage ceiling before additional Medicare tax kicks in.

  # outputs created
    our $payroll_tax = 0;
    our $parent1_payroll_tax = 0;
    our $parent2_payroll_tax = 0;
    our $parent3_payroll_tax = 0;
    our $parent4_payroll_tax = 0;
	our $payroll_tax1 = 0;	#The payroll tax for tax filing unit 1. This is important for determining the ACTC.

    # calculated in Macro
    our $social_sec_tax_parent1 = 0;    # social security tax amount (parent 1)
    our $social_sec_tax_parent2 = 0;    # social security tax amount (parent 2)
    our $social_sec_tax_parent3 = 0;    # social security tax amount (parent 2)
    our $social_sec_tax_parent4 = 0;    # social security tax amount (parent 2)
    our $medicare_tax_parent1 = 0;      # medicare tax amount (parent 1)
    our $medicare_tax_parent2 = 0;      # medicare tax amount (parent 2)
    our $medicare_tax_parent3 = 0;      # medicare tax amount (parent 2)
    our $medicare_tax_parent4 = 0;      # medicare tax amount (parent 2)
    our $add_medicare_tax_parent1 = 0;      	#additional medicare tax amount (parent 1)
    our $add_medicare_tax_parent2 = 0;      	#additional medicare tax amount (parent 2)
    our $add_medicare_tax_parent3 = 0;      	#additional medicare tax amount (parent 2)
    our $add_medicare_tax_parent4 = 0;      	#additional medicare tax amount (parent 2)


	#Note: people do not pay payoll taxes for unemployment insurance benefits.
	
	for(my $i=1; $i<=4; $i++) { 
		${'social_sec_tax_parent'.$i} = $social_sec_rate * &least($out->{'parent'.$i.'_earnings'}, $ssec_income_limit);
		${'medicare_tax_parent'.$i} = $medicare_rate * $out->{'parent'.$i.'_earnings'};	
		${'add_med_tax_parent'.$i}  = $add_medicare_tax  * pos_sub($out->{'parent'.$i.'_earnings'}, $add_medicare_inc);
	}
	
	#Note for future consideration: Techincally, self-employed individuals pay the employer portion of payroll taxes as well, meaning that, for the most part, they pay twice these taxes. Self-employed individuals also file taxes using a separate form, and can claim multiple additional deductions on self employment earnings (e.g. the self employment tax deduction, which allows this payroll tax to be partially deducted from gross earnings in calculating adjusted gross income. We are making the simplifying assumption that the payroll taxes on self employment, adjusted by these deductions, are not significantly different than payroll taxes for non-self-employed people. Further improvements to this model could include a more detailed account of self-employment.
    $parent1_payroll_tax = $social_sec_tax_parent1 + $medicare_tax_parent1 + $add_medicare_tax_parent1;
    $parent2_payroll_tax = $social_sec_tax_parent2 + $medicare_tax_parent2 + $add_medicare_tax_parent2;
    $parent3_payroll_tax = $social_sec_tax_parent3 + $medicare_tax_parent3 + $add_medicare_tax_parent3;
    $parent4_payroll_tax = $social_sec_tax_parent3 + $medicare_tax_parent3 + $add_medicare_tax_parent4;

    $payroll_tax = &round($parent1_payroll_tax + $parent2_payroll_tax + $parent3_payroll_tax + $parent4_payroll_tax);


	#We need to know payroll tax for tax filing unit 1 because that is the filing unit we are assigning all children to. Payroll tax can affect the amount of CTC a tax filer is eligible to receive.
	for(my $i=1; $i<=4; $i++) { 
		if ($in->{'parent'. $i.'_age'} > 0) { 
			if ($i == $out->{'filing_status1_adult1'} || $i == $out->{'filing_status1_adult2'}  || $i == $out->{'filing_status1_adult3'} || $i == $out->{'filing_status1_adult4'}) {
				$payroll_tax1 += ${'parent'.$i.'_payroll_tax'};
			}
		}
	}
	foreach my $debug (qw(payroll_tax parent1_payroll_tax parent2_payroll_tax parent3_payroll_tax parent4_payroll_tax)) {
		print $debug.": ".${$debug}."\n";
	}

  # outputs
    foreach my $name (qw(payroll_tax parent1_payroll_tax parent2_payroll_tax parent3_payroll_tax parent4_payroll_tax payroll_tax1)) {
       $out->{$name} = ${$name};
	}
}

1;
