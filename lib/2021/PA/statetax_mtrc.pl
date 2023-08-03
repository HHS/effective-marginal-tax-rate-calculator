#=============================================================================#
#  State Taxes -- 2021 -- PA
#=============================================================================#
#
# Inputs referenced in this module:
#
#   FROM BASE
#     Inputs:
#       child_number
#       family_structure
#     Outputs:
#       earnings
#
#   FROM INTEREST
#       interest
#
#   FROM FEDERAL TAX
#       support
#
#=============================================================================#

sub statetax
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};
    
  # outputs created
    our $state_tax = 0;
    our $local_tax = 0;
   
  # additional variables used within this macro
    our $state_tax_gross1 = 0;       # PA tax liability
    our $state_tax_gross2 = 0;       # PA tax liability
    our $state_tax_gross3 = 0;       # PA tax liability
    our $state_tax_gross4 = 0;       # PA tax liability
    our $state_tax_credits = 0; # amount of tax back/tax forgiveness
	our $eligibility_income1 = 0;
	our $eligibility_income2 = 0;
	our $eligibility_income3 = 0;
	our $eligibility_income4 = 0;
	
    #our $state_taxable1 = 0;         # PA taxable income (earnings + interest)
    #our $state_taxable2 = 0;         # PA taxable income (earnings + interest)
    #our $state_taxable3 = 0;         # PA taxable income (earnings + interest)
    #our $state_taxable4 = 0;         # PA taxable income (earnings + interest)
    
    our $state_tax_rate = 0.0307; 
    our $state_filing_status1 = 0;   # filing status for PA (single or married)
    our $state_filing_status2 = 0;   # filing status for PA (single or married)
    our $state_filing_status3 = 0;   # filing status for PA (single or married)
    our $state_filing_status4 = 0;   # filing status for PA (single or married)
    our $dependent_number = 0;      # number of dependents
    our $state_tax_credit_percent = 0;  # % reimbursed by tax back

    our @state_tax_base_array = ();
    our $state_tax_base = 0;
    our $pa_local_tax_rate = 0;         # local tax rate


	for(my $i=1; $i<=$out->{'filers_count'}; $i++) { 
		# determine state filing status and dependent number
		if($out->{'filing_status'.$i} eq 'Head of Household' || $out->{'filing_status'.$i} eq 'Single' ) {
			${'state_filing_status'.$i} = "single";
		} else {
			${'state_filing_status'.$i} = "married";
		}
	  
		if($i == 1) {
			#There can be up to 8 dependents in the MTRC. 5 children plus 3 adult students or incpapacitated adults. Only filing unit 1 will have dependents, based on how we've defined filing units in the federal code.
			$dependent_number = $in->{'child_number'} + $out->{'adult_children'};
		} else {
			$dependent_number  = 0; #Necessary to redefine here because we're using the same variable over multiple loops.
		}

		# determine PA tax liability
		#${'state_taxable'.$i} = $out->{'earnings'} + $out->{'interest'}; #Seems unnecessary unless 
		${'state_tax_gross'.$i} = $state_tax_rate * $out->{'gross_income'.$i} ;
		
		if(${'state_tax_gross'.$i} > 0) {
			
		  # determine amount of TAX FORGIVENESS credit
			if(${'state_filing_status'.$i} eq "single") {
				# No dependents = "You" on the PA tax table schedule for this credit, so we start at 0 dependents = 6500.
				@state_tax_base_array = (6500, 16000, 25500, 35000, 44500,54000,63500, 73000, 82500);
			}
			else {
				@state_tax_base_array = (13000,22500,32000,41500,51000,60500, 70000, 79500, 89000);
			}
			$state_tax_base = $state_tax_base_array[$dependent_number];
			print "state tax base $i: $state_tax_base \n";
			#Income calculated for determining the tax forgiveness credit includes more income items than the calculation for state taxes, including gifts and income. Here we assume that all tax filers split the gift income but that only tax filer 1 (the one with dependents) receives alimony. We are not asking which members of the household receives alimony, to reduce question burden.
			${'eligibility_income'.$i} = $out->{'gross_income'.$i} + $out->{'gift_income'}/$out->{'filers_count'};
			if ($i == 1) {
				${'eligibility_income'.$i} += $in->{'alimony_paid_m'};
			}
			
			for (${'eligibility_income'.$i}) {
				$state_tax_credit_percent = ($_ <= $state_tax_base)        ?   1     :
											($_ <= $state_tax_base + 250)  ?   0.9   :
											($_ <= $state_tax_base + 500)  ?   0.8   :
											($_ <= $state_tax_base + 750)  ?   0.7   :
											($_ <= $state_tax_base + 1000) ?   0.6   :
											($_ <= $state_tax_base + 1250) ?   0.5   :
											($_ <= $state_tax_base + 1500) ?   0.4   :
											($_ <= $state_tax_base + 1750) ?   0.3   :
											($_ <= $state_tax_base + 2000) ?   0.2   :
											($_ <= $state_tax_base + 2250) ?   0.1   :
																			   0;
			}
			
			$state_tax_credits += $state_tax_credit_percent * ${'state_tax_gross'.$i};
		  
		}
		
	}
	
	# determine actual state tax amount (after TAX BACK)
	$state_tax = $state_tax_gross1 + $state_tax_gross2 + $state_tax_gross3 + $state_tax_gross4 - $state_tax_credits; #Should never be negative, otherwise something is wrong in the above calculations.

	# determine local tax rate

	for ($in->{'residence'}) { #We are using residence here to capture Pittsburgh's tax rate, which does not apply to Allegheny County outside of Pittsburgh. We've chosen the 15122 identifier for Pittsburgh. 
		$pa_local_tax_rate = ($ == 15122) ? .03  :
							 # Commenting these out for now but they can be reinstated if we expand beyond Allegheny County
							 # ($_ == 1)  ?   0.01     : 
							 # ($_ == 2)  ?   0.0115   :
							 # ($_ == 3)  ?   0.045    :
							 # ($_ == 4)  ?   0.03     :
							 # ($_ == 5)  ?   0.01     :
												0;
	}
	# calculate PA local tax
	$local_tax = $pa_local_tax_rate * $out->{'earnings'};

	#We now combine the state tax variables with the federal ones, to get the aggregate tax variables.
	$tax_before_credits = &round($out->{'federal_tax_gross'} + $state_tax + $local_tax);
	$tax_after_credits = &round($tax_before_credits - $out->{'federal_tax_credits'} - $state_tax_credits);
	
	#debugging
	foreach my $debug (qw(state_tax local_tax state_tax_credits state_tax_gross1 state_tax_gross2 state_tax_gross3 state_tax_gross4 eligibility_income1 eligibility_income2 eligibility_income3 eligibility_income4 dependent_number state_tax_credit_percent pa_local_tax_rate)) {
		print $debug.": ".${$debug}."\n";
	}

        
  # outputs
    foreach my $name (qw(state_tax local_tax tax_before_credits state_tax_credits tax_after_credits)) {
        $out->{$name} = ${$name} || '';
    }

}

1;