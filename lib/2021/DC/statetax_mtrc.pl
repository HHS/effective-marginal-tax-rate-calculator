#=============================================================================#
#  State Taxes -- 2021 – DC 
#=============================================================================#

#Used instructions for form D-40, 2020, the latest available at the time of this update.
#
# Inputs referenced in this module:
#
#   FROM BASE
#     Inputs:
#       family_size
#       child_number
#       state_eitc				#flag for whether or not state_eitc is selected. Should only be able to select it if federal eitc is selected. 
#       state_cadc				#flag for whether or not state_cadc is selected. Should only be able to select it if federal cadc is selected.
#     Outputs:
#       earnings
#
#    FROM INTEREST
#         interest 
#  
# FROM WORK
#       parent1_earnings
#       parent2_earnings
#
#   FROM FEDERAL TAX
#       filing_status
#       exempt_number
#       cadc_gross
#       standard_deduction 
#       ded_per_exempt	
#
#   FROM EITC
#       eitc_recd
#
#=============================================================================#


sub statetax
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};
    my $dbh = $self->{'dbh'};

  # additional variables used within this macro
    our $state_tax_rate1 = 0.04;       		# state tax rate, bracket 1
    our $state_tax_rate2 = 0.06;      		# state tax rate, bracket 2
    our $state_tax_rate3 = 0.065;        		# state tax rate, bracket 3
    our $state_tax_rate4 = 0.085;        		# state tax rate, bracket 4
    our $state_tax_rate5 = 0.0875;        		# state tax rate, bracket 5
    our $state_tax_rate6 = 0.0895;       	 	# state tax rate, bracket 6

    our $max_state_taxrate1 = 10000;   	 	# max adjusted income for tax rate 1
    our $max_state_taxrate2 = 40000;  	   	# max adjusted income for tax rate 2
    our $max_state_taxrate3 = 60000;    	 	# max adjusted income for tax rate 3
    our $max_state_taxrate4 = 350000;     	# max adjusted income for tax rate 4
    our $max_state_taxrate5 =1000000;     	# max adjusted income for tax rate 5
	our $state_cadc_pct = .32;
	our $elc_max_income = 151900;	#the max income for DC's early learning credit, or Keep Child Care Affordable Credit, for single, head of household, and married filing jointly tax filers.
	our $elc_max_perchild = 1010;

  # outputs created
    #our $state_tax_exempt = 1775;      	 # personal exemption amount
    our $state_tax_gross1 = 0;       # DC tax liability
    our $state_tax_gross2 = 0;       # DC tax liability
    our $state_tax_gross3 = 0;       # DC tax liability
    our $state_tax_gross4 = 0;       # DC tax liability
    our $state_tax1 = 0;       # DC tax liability after nonrefundabe credits.
    our $state_tax2 = 0;       # DC tax liability
    our $state_tax3 = 0;       # DC tax liability
    our $state_tax4 = 0;       # DC tax liability
    our $state_tax_credits = 0;		# Includes State CADC
    our $state_cadc_recd = 0;		# OH Child and Dependent Care nonrefundable credit received
    our $state_tax	= 0;		# State tax liability
    our $state_eic_recd	= 0;		# Amount received for Earned Income State Tax Credit
    our $dc_stand_ded	=	0;	#standard deduction depending on filing status. If single, then 5200, if head of household, then 6500, if married, then 8350 
    our $state_tax_income = 0;        	  # annual taxable income  
    our $dc_childcare_credit = 0;  	 # nonrefundable state child and dependent care credit
    our $low_income_credit = 0;         	# DC low income credit amount
    our $dc_eitc = 0;                   		# DC EITC amount (before comparing to low_income_credit)
    our $tax_before_credits             = 0;            # Total federal and state tax liability
    our $tax_after_credits              = 0;            # Total federal and state tax liability after federal and stat     
	our $dc_eitc_line2 = 0;
	our $dc_eitc_line4 = 0;
	our $dc_eitc_line6 = 0;
	our $dc_eitc_line7 = 0;
	our $meets_dc_noncustodial_eitc_age = 0;
	our $dc_noncustodial_eitc_phasein_rate = 0;
	our $dc_noncustodial_eitc_plateau_start = 0;
	our $dc_noncustodial_eitc_max_value = 0;
	our $dc_noncustodial_eitc_phaseout_rate = 0;
	our $dc_noncustodial_eitc_plateau_end  = 0;
	our $dc_noncustodial_eitc_income_limit = 0;

    #
    # 1. DETERMINE TAXABLE AND ADJUSTED GROSS INCOME
    #  #see instructions beginning on page 23 for form D-40. total number of exemptions is calculated slightly differently in DC if filing status is head of household. Just add 1 to exempt number (source: Calculation G on DC tax form Schedule S). Assumptions include that all are not blind and under age 65. See pages 3 and 27 of instructions for personal exemption amount. 

	# NOTE TODO, maybe: – in dc taxes, may be able to take out SSI income, look into this more. 

	#
	#
	#
	#
	#
	#
	#
	
	#Check for any adult member 30 or below, for noncustodial parent EITC. This is a simplification, but as indicated below, we are not asking which household member(s) are noncustodial parents, just whether they pay child support and for how many children.
	for(my $i=1; $i<=$in->{'family_structure'}; $i++) {
		if ($in->{'parent'.$i.'_age'} <=30) {
			$meets_dc_noncustodial_eitc_age = 1;
		}
	}


	for(my $i=1; $i<=$out->{'filers_count'}; $i++) { 

		if($out->{'filing_status'.$i} eq 'Head of Household') {
			$dc_stand_ded	= 18650;
		} elsif($out->{'filing_status'.$i} eq 'Single')  {
			$dc_stand_ded	= 12400;
		} elsif($out->{'filing_status'.$i} eq 'Married') {
			$dc_stand_ded = 24800;
		}           

		$state_tax_income = $out->{'gross_income'.$i} - $dc_stand_ded;

		# 2. DETERMINE GROSS TAX AMOUNT (BEFORE PERSONAL TAX CREDITS)
		if ($state_tax_income < 0) { 
			$state_tax_income = 0;
		} elsif ($state_tax_income <= $max_state_taxrate1) {
			${'state_tax_gross'.$i} = $state_tax_rate1 * $state_tax_income;
		} elsif ($state_tax_income <= $max_state_taxrate2) {
			${'state_tax_gross'.$i} = $state_tax_rate2 * ($state_tax_income - $max_state_taxrate1)+ ($state_tax_rate1 * $max_state_taxrate1);
		} elsif ($state_tax_income <=$max_state_taxrate3) {
			${'state_tax_gross'.$i} = $state_tax_rate3 * ($state_tax_income - $max_state_taxrate2)
									+ ($state_tax_rate2 * ($max_state_taxrate2 - $max_state_taxrate1))
									+ ($state_tax_rate1 * $max_state_taxrate1);
		} elsif ($state_tax_income <=$max_state_taxrate4) {
			${'state_tax_gross'.$i} = $state_tax_rate4 * ($state_tax_income - $max_state_taxrate3)
									+ ($state_tax_rate3 * ($max_state_taxrate3 - $max_state_taxrate2))
									+ ($state_tax_rate2 * ($max_state_taxrate2 - $max_state_taxrate1))
									+ ($state_tax_rate1 * $max_state_taxrate1);
		} elsif ($state_tax_income <=$max_state_taxrate5) {
			${'state_tax_gross'.$i} = $state_tax_rate5 * ($state_tax_income - $max_state_taxrate4)
									+ ($state_tax_rate4 * ($max_state_taxrate4 - $max_state_taxrate3))
									+ ($state_tax_rate3 * ($max_state_taxrate3 - $max_state_taxrate2))
									+ ($state_tax_rate2 * ($max_state_taxrate2 - $max_state_taxrate1))
									+ ($state_tax_rate1 * $max_state_taxrate1);
		} elsif ($state_tax_income > $max_state_taxrate5)	 {		 
			${'state_tax_gross'.$i} = $state_tax_rate6 * ($state_tax_income - $max_state_taxrate5)
									+ ($state_tax_rate5 * ($max_state_taxrate5 - $max_state_taxrate4))
									+ ($state_tax_rate4 * ($max_state_taxrate4 - $max_state_taxrate3))
									+ ($state_tax_rate3 * ($max_state_taxrate3 - $max_state_taxrate2))
									+ ($state_tax_rate2 * ($max_state_taxrate2 - $max_state_taxrate1))
									+ ($state_tax_rate1 * $max_state_taxrate1);
		}
	  # 3. COMPUTE CHILD AND DEPENDENT CARE TAX CREDIT (non-refundable)

		  #this uses an amount from the federal taxes subroutine
		if($in->{'state_cadc'} == 1 && $i == 1) { #As with federal taxes, we are assigning all children to tax filing unit 1.
			$dc_childcare_credit = $state_cadc_pct * $out->{'cadc_gross'};
			${'state_tax'.$i} = &pos_sub(${'state_tax_gross'.$i}, $dc_childcare_credit);
			$state_cadc_recd += ${'state_tax_gross'.$i} - ${'state_tax'.$i};
		}

		# 
		# 4. COMPUTE (POTENTIALLY) REFUNDABLE TAX CREDIT  (see page 27 of instructions)

		# 4(a) Calculate low_income_credit/eitc
		# Cannot take both low income credit and EITC, must calculate both and take the greater of the two. #the low income credit is not available to those whose agi is greater than minimum federal income tax filing requirements, but taxable income must be greater than zero, and agi must be greater than the sum of DC personal exemptions and DC standard deduction and agi must be less than or equal to the sum of federal personal exemptions and federal standard deductions. The below calculations make use of the low-income credit table.

		#This is the old formula for the low-income credit, which has been discontinued.
		#if($in->{'state_eitc'} == 1 && $state_tax_income > 0)  {

		#	if ($out->{'filing_status'.$i} eq 'Head of Household' && ($out->{'gross_income'.$i} <= 13350)) { 
		#		for ($out->{'exempt_number'}) {
		#			$low_income_credit = 
		#			($_ == 2)  ?   223   :
		#			($_ == 3)  ?   315   :
		#			($_ ==  4)  ?   408   :
		#			($_ ==  5)  ?   546   :
		#			($_ ==  6)  ?   681   :
		#				0;
		#		}
		#	} elsif  ($out->{'filing_status'.$i} eq 'Married' && ($out->{'gross_income'.$i} <=20700)) { 
		#		for ($out->{'exempt_number'}) {
		#			$low_income_credit = 
		#			($_ == 3)  ?   465   :
		#			($_ == 4)  ?   603   :
		#			($_ ==  5)  ?   738   :
		#			($_ ==  6)  ?   876   :
		#			($_ ==  7)  ?   1011   :
		#				0;
		#		}
		#	} elsif  ($out->{'filing_status'.$i} eq 'Single' && ($out->{'gross_income'.$i}  <= 10350)) { 
		#		for ($out->{'exempt_number'}) {
		#			$low_income_credit = 
		#			($_ == 2)  ?   227   :
		#			($_ == 3)  ?   317   :
		#			($_ ==  4)  ?   414   :
		#			($_ ==  5)  ?   549   :
		#			($_ ==  6)  ?   687   :
		#				0;
		#		}
		#	}

		#	$low_income_credit = &least($low_income_credit, $state_tax);
		#}
			  
		# 4(b) Calculate DC EITC
		if($in->{'state_eitc'} && $in->{'child_number'} + $out->{'adult_children'} > 0 && $i == 1) {
			$dc_eitc += 0.4 * $out->{'eitc_recd'};
			#DC has a separate calculation for both (a) workers without qualifying children, and (b) non-custodial parents.
			#Workers without qualifying children:
		} elsif ($in->{'state_eitc'} && $out->{'interest'} <= 3650 && $out->{'earnings_unit'.$i} < 25833 && $out->{'meetsagemin_unit'.$i}) {
			#Although there's a bunch of line numbers here, this operates in the same way as the rise-plateau-decline pattern in the federal EITC, and also incorporates gross income in a similar manner, just with different amounts and slopes. It could be simplified mathematically, but for now, just going with the process in the instructions.
			if ($out->{'earnings_unit'.$i} < 7033) {
				$dc_eitc_line2 = 0.0765 * $out->{'earnings_unit'.$i};
			} else {
				$dc_eitc_line2 = 538;
			}
			$dc_eitc_line4 = &greatest($out->{'earnings_unit'.$i}, $out->{'gross_income'.$i});
			if ($dc_eitc_line4 < 19489) {
				$dc_eitc += $dc_eitc_line2;
			} else {
				$dc_eitc_line6 = $dc_eitc_line4 - 19489;
				$dc_eitc_line7 = .0848 * $dc_eitc_line6;
				$dc_eitc += pos_sub($dc_eitc_line2, $dc_eitc_line7);
			}
		}
		
		#DC's Non-cusotodial parent EITC (sched N)
		#It appears you can get both the non-custodian DC EITC and the regular EITC.

		#Adding in DC's non-custodial parent EITC. This is almost identical to its EITC for custodial parents but assuming that non-custodial parents would get the same in federal EITC, while they don't get any. So we need to calculate the entire federal EITC as if this person got that as well. The below is therefore largely a reproduction of the federal EITC code.
		
		#We use tax filing unit 1's gross income to determine the EITC for non-custodial parents. This is a simplification -- for instance, it does not allow for the possibility that the child of someone in the home is a noncustodial parent and is part of a separate tax filing unit -- but it is largely in keeping with our approach of limiting the tool to two generations. Since we are not asking who exactly in the household is a noncustodial parent, we just check all adults in the house to see if any are under 30 (the age max for this credit), and assign child support to that person.

		if ($i == 1 && $in->{'outgoing_child_support'} > 0 && $in->{'outgoing_child_support_children'} > 0 && $meets_dc_noncustodial_eitc_age == 1) { 
			if ( $in->{'outgoing_child_support_children'}  == 1) {
			  $dc_noncustodial_eitc_phasein_rate = 0.34;
			  $dc_noncustodial_eitc_plateau_start = 10640;
			  $dc_noncustodial_eitc_max_value = 3618;
			  $dc_noncustodial_eitc_phaseout_rate = 0.1598;
			  $dc_noncustodial_eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 19520 : 25470);
			  $dc_noncustodial_eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 42158 : 48108);
			} elsif ( $in->{'outgoing_child_support_children'}  == 2) {
			  $dc_noncustodial_eitc_phasein_rate = 0.4;
			  $dc_noncustodial_eitc_plateau_start = 14950;
			  $dc_noncustodial_eitc_max_value = 5980;
			  $dc_noncustodial_eitc_phaseout_rate = 0.2106;
			  $dc_noncustodial_eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 19520 : 25470);
			  $dc_noncustodial_eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 47915 : 53865);
			} elsif ( $in->{'outgoing_child_support_children'}  >= 3) {
			  $dc_noncustodial_eitc_phasein_rate = 0.45;
			  $dc_noncustodial_eitc_plateau_start = 14950;
			  $dc_noncustodial_eitc_max_value = 6728;
			  $dc_noncustodial_eitc_phaseout_rate = 0.2106;
			  $dc_noncustodial_eitc_plateau_end  = ($out->{'filing_status'.$i} ne 'Married' ? 19520 : 25470);
			  $dc_noncustodial_eitc_income_limit = ($out->{'filing_status'.$i} ne 'Married' ? 51464 : 57414);
			}
		
			#We calculate noncustodial EITC based on tax filing unit 1's gross income alone, and not their earnings, and then multiply that by 40%.
			if ($out->{'gross_income'.$i} >= $dc_noncustodial_eitc_income_limit) { 
				$dc_eitc += 0;
			} elsif($out->{'gross_income'.$i} < $dc_noncustodial_eitc_plateau_start) { 
				$dc_eitc += 0.4 * $dc_noncustodial_eitc_phasein_rate * $out->{'gross_income'.$i}; 
			} elsif($out->{'gross_income'.$i} >= $dc_noncustodial_eitc_plateau_start && $out->{'gross_income'.$i} < $dc_noncustodial_eitc_plateau_end) { 
				$dc_eitc += 0.4 * $dc_noncustodial_eitc_max_value; 
			} elsif($out->{'gross_income'.$i} >= $dc_noncustodial_eitc_plateau_end && $out->{'gross_income'.$i} < $dc_noncustodial_eitc_income_limit) { 
				$dc_eitc += 0.4 * $dc_noncustodial_eitc_phaseout_rate * ($dc_noncustodial_eitc_income_limit - $out->{'gross_income'.$i}); 
			}
				
		}
		
		#DC's Keep Child Care Affordable Tax Credit (schedule ELC)
		if ($i == 1 && $our->{'child_care_expenses'} > 0 && $out->{'gross_income'.$i} <= $elc_max_income) {
			for(my $i=1; $i<=$in->{'child_number'}; $i++) {
				if ($out->{'child_care_recd_flag_child'.$i} == 0 && $out->{'unsub_child'.$i} > 0 && $in->{'child'.$i.'_age'} < 4) {
					$elc_recd += &least($out->{'unsub_child'.$i}, $elc_max_perchild);
					#Payment is also partially contingent on when the child turned 3 years old, with payments limited to covering Jan-Sep child care turned 3 in September (afer which they presumably could begin pre-K). As we are already accounting for Pre-K elsewhere, we are not incorporating this consideration.
				}
			}
		}
	}

	$state_tax_gross = $state_tax_gross1 + $state_tax_gross2 + $state_tax_gross3 + $state_tax_gross4;
	$state_eic_recd = $dc_eitc; #This is accumulated through the calculations from different tax filing units.
	$state_tax_credits = $state_eic_recd + $state_cadc_recd + $elc_recd; #state_cadc_recd and elc_recd is also accumulated through the calculations from different tax filing units.

	# We need to add this last variable to make the frs.pl code calculate the net resources correctly.
	$tax_before_credits = &round($out->{'federal_tax_gross'} + $state_tax_gross); 
	$tax_after_credits = &round($tax_before_credits - $out->{'federal_tax_credits'} - $state_tax_credits);	  

	#debugging
	foreach my $debug (qw(state_tax state_tax_credits state_eic_recd state_taxable meets_dc_noncustodial_eitc_age dc_noncustodial_eitc_max_value)) {
		print $debug.": ".${$debug}."\n";
	}

        
  # outputs
    foreach my $name (qw(state_tax state_tax_gross tax_before_credits state_tax_credits tax_after_credits)) {
        $out->{$name} = ${$name} || '';
    }

}

1;