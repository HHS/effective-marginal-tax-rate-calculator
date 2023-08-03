#=============================================================================#
#  Federal Income Taxes Module -- 2021 
#=============================================================================#
# Inputs referenced in this module:
#
#   INPUTS
#	family_structure
#	child_number
#	disability_parent#
#	disability_personal_expenses_m
#	cadc
#	ctc
#
#	FROM FRS.PM
#	children_under13
#	children_under17
#
#	FROM EARNINGS:
#	earnings
#	parent#_earnings
#	parent#_max_hours_w
#
#   FROM INTEREST:
#	interest
#
#   FROM CHILD CARE:
#	child_care_expenses
#
#=============================================================================#
#
# NOTE ABOUT HOMEOWNERS: THIS MODEL DOES NOT INCLUDE FEDERAL PROPERTY TAX DEDUCTIONS OR TAX CREDITS, NOR ANY STATE PROPERTY TAXES. THERE ARE SPECIFIC DEDUCTIONS AND CREDITS THAT HOMEOWNERS CAN TAKE, BUT FOR THE MTRC, WE ARE WORKING OFF AN ASSUMPTION THAT THESE REDUCTIONS IN EXPENSES ARE OFFSET BY PROPERTY TAXES. 

# NOTE ABOUT ADULT STUDENTS: THERE ARE TWO FEDERAL TAX CREDITS RELATED TO EDUCATIONAL EXPENSES, ONE REFUNDABLE AND ONE NON-REFUNDABLE. WE ARE MAKING A LIMITING ASSUMPTION THAT ALL STUDENTS ARE NOT INCURRING $0 IN EDUCATIONAL EXPENSES AND THEREFORE ARE NOT ELIGIBLE FOR THIS CREDIT. WHILE THIS LIMITS THE ACCURACY OF THE TAX MODULE FOR FAMILIES WITH STUDENTS, THE TAX CREDIT DECLINES GRADUALLY FROM A MAXIMUM AMOUNT AS INCOME RISES ABOVE A SPECIFIC GROSS INCOME LEVEL, SO THE TAX CREDIT DOES NOT CAUSE A CLIFF IN AND OF ITSELF. IT ALSO DOES NOT IMPACT THE OTHER FOUR BENEFIT CLIFFS THAT WE ARE ANALYZING IN THE NEW HEIGHTS ANALYSIS (SNAP, TANF, MEDICAID, AND CCDF), FOR WHICH STATES HAVE GREATER DISCRETION AROUND RULES, SO WHILE THE TAX CREDITS LIKLEY HELP THESE FAMILIES, THEY DO NOT IMPACT THE POLICY EFFECTS THAT WE ARE ANALYSIZYING.   

sub fedtax
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# outputs created
    our $federal_tax_gross = 0;      # gross federal taxes, before subtracting CADC and CTC
    our $federal_tax_gross1 = 0;      #This variable is not used outside of this code, and we do have loops to account for all variables needed per each filing unit, so technically we do not need to break this variable down by filing unit. Still, doing so will be less confusing for any analysis and debugging, so we are tentatively adding this variable. Maybe make this just federal_tax_income, redefined every loop, if separatign this out causes too much slow-downs to occur.
	our $federal_tax_gross1 = 0;
	our $federal_tax_gross2 = 0;
	our $federal_tax_gross3 = 0;
	our $federal_tax_gross4 = 0;
	our $federal_tax_credits = 0;    # [Fed Tax Credits]  
    our $federal_tax = 0;        # annual federal tax liability, NOT including the CTC or the EITC
    our $cadc_recd = 0;          # [Fed CADC] annual value of child and dependent tax care credit
                                 # (cannot be less than pre-CADC tax liability; does not take into account CTC)
    our $cadc_base = 0;          # Qualified child care expenses for determining CADC credit
    our $ctc_nonref_recd = 0;    # annual child tax credit, non-refundable portion
                                 # (cannot be less than pre-CTC tax liability; does take into account CADC)
    our $cadc_real_recd = 0;     # "real" value of CADC, given eligibility for child tax credit
                                 # (i.e., this is what the value of the CADC would be if the Child Tax Credit were subtracted 
                                 # from gross tax liability first)
    #our $filing_status = 0;      # filing status
    our $federal_tax_income = 0;     # adjusted income for calculating taxes
	our $federal_tax_income1 = 0;	#This variable is not used outside of this code, and we do have loops to account for all variables needed per each filing unit, so technically we do not need to break this variable down by filing unit. Still, doing so will be less confusing for any analysis and debugging, so we are tentatively adding this variable. Maybe make this just federal_tax_income, redefined every loop, if separatign this out causes too much slow-downs to occur.
	our $federal_tax_income2 = 0;
	our $federal_tax_income3 = 0;
	our $federal_tax_income4 = 0;
	our $gross_income1 = 0;		
	our $gross_income2 = 0;		
	our $gross_income3 = 0;		
	our $gross_income4 = 0;		
	our $adult_children = 0;
    # Additional variables used within the macro
    our $cadc_max_claims = 3000; # maximum child care expenses that can be claimed (per child, up to 2)
    our $ctc_per_child   = 2000; #  max child tax credit (per child)
	our $nonchild_dependent_add = 500; 		#additional dependent add-on for non-child dependents.
	our $ctc_per_child_arpa = 3000; #Max ARPA CTC for children 6 or over is $3000.
	our $ctc_arpa_under6_add = 600; #Addition ARPA provides for children under 6.
    our $ded_per_exempt  = 4050; # deduction amount per exemption, as of 2016. Kept in case exemptions are reinstated.
    our $tax_rate1       = 0.10; # tax rate for income bracket 1
    our $tax_rate2       = 0.12; #  tax rate for income bracket 2
    our $tax_rate3       = 0.22; #  tax rate for income bracket 3
    our $tax_rate4       = 0.24; #  tax rate for income bracket 4
	our $tax_rate5       = 0.32; #  tax rate for income bracket 5
    our $tax_rate6       = 0.35; #  tax rate for income bracket 6
    our $tax_rate7       = 0.37; #  tax rate for income bracket 7


	# variables set
    our $home = 0;               # parent(s) meet the test of keeping up a home (1|0)
    our $support = 0;            # parent(s) meet the test of supporting a child (1|0)
	#    our $exempt_number = 0;      # number of exemptions family can claim. Excluded beginning in 2019 because 2017 tax reform (beginning in 2018 tax year) removed exemptions. But kept in here in case later reform adds in exemptions.
    our $standard_deduction1 = 0; # standard deduction
    our $standard_deduction2 = 0; # standard deduction
    our $standard_deduction3 = 0; # standard deduction
    our $standard_deduction4 = 0; # standard deduction
    our $max_taxrate1 = 0;       # max adjusted income for tax rate 1
    our $max_taxrate2 = 0;       # max adjusted income for tax rate 2
    our $max_taxrate3 = 0;       # max adjusted income for tax rate 3
    our $max_taxrate4 = 0;       # max adjusted income for tax rate 4
    our $max_taxrate5 = 0;       # max adjusted income for tax rate 5
    our $max_taxrate6 = 0;       # max adjusted income for tax rate 6


    our $federal_tax_cadc = 0;   # federal tax liability after subtracting cadc, but before ctc
    our $cadc_gross = 0;         # gross CADC amount (i.e., before comparing to tax liability)
    our $cadc_percentage = 0;
    our $ctc_max_income = 0;     # income limit for max child tax credit (varies by filing status)
	our $ctc_max_income_covid = 0; #additional income limit for max child tax credit as expanded by ARPA

    our $ctc_number = 0;     # number of children eligible for child tax credit
    our $ctc_potential = 0;      # max potential child tax credit family may be eligible for (ie, ctc_per_child * ctc_number)
    our $ctc_reduction = 0;      # reduction amount for filers w/income above ctc_max_income (line 7 in ctc worksheet)
    our $ctc_potential_recd = 0;  # max potential child tax credit, after subtracting ctc_reduction
	our $other_dependent_credit = 0; #portion of the CTC that is the credit for other (non-child) dependents.
	our $ctc_potential_recd_nonother = 0;

    our $cadc = $in->{'cadc'};
	our $cadc_dis = 0;	#the only values for cadc_dis would be 0 and 1 to indicate whether or not 2nd parent is disabled and care for the parents would qualify for cadc
	our $unit1_lowestearner = 0;
	our $unit1_lowestearnings = 0;
	our $earnings_unit1 = 0;
	our $earnings_unit2 = 0;
	our $earnings_unit3 = 0;
	our $earnings_unit4 = 0;

# 1. Determine filing status, number of exemptions, and number of children for child tax credit
	# (note: to be claimed for the child tax credit, a child must be claimed as a dependent)

	# (We are only including cash and near-cash benefits in our calculation of public support
	# for the home and dependent support tests -- this is in keeping with common practice among tax preparers.)

	# Note: All children in the FRS beginning in 2019 and in the MTRC beginning in 2021 are considered "qualifying children" for tax purposes because they earn no income of their own. According to the 1040 instructions, this means that they are a qualifying child on someone's tax return. For single parents, they are a qualifying child either on the custodial parent's return or noncustodial parent's return, but regardless they are still a "qualifying child." This  means that all single-parent families being modeled in the FRS - at least up to 2019 - qualify as heads of household. In order to claim head of household, the child has to be young enough (under 19, all cases in the FRS), staying in the same home as the parent (all cases), and not paying more than half of the expenses that they themselves incur. This last condition is not the same as a condition that the single parent pays more than half of the child's expenses, it only means that THE CHILD HIMSELF OR HERSELF DOES NOT PAY more than half of their expenses. Previous versions of the FRS code (possibly of IRS code) compared earnigns and income against child support and TANF or other payments, but this is not correct. Whether or not a parent paid more than half of a child's expenses may be important in determining whether a child is dependent, though, which is explored later.

	# The following code uses Table “Federal Income Taxes tables”, worksheet I to determine:
	# - Filing_status
	# - Exempt_number
    # After the determination of filing status, the following if-block replicate the “Federal Income Taxes tables”, worksheet II to determine:
    # Use Table “Federal Income Taxes tables”, worksheet II to determine:
    # - Standard_deduction
    # - Max_taxrate1
    # - Max_taxrate2
    # - Max_taxrate3
    # - Max_taxrate4
	# - Max_taxrate5
	# - Max_taxrate6
    # - CTC_max_income


	#If there is a married couple in the house, we assign them to filing status 1, and also assign any other eligible adults to that filing unit.
	
	#We now run the tax codes for four possible tax filing units. 

	for(my $i=1; $i<=4; $i++) { 
		if($out->{'filing_status'.$i} ne 'none') { 
			if($out->{'filing_status'.$i} eq 'Head of Household') {
				${'standard_deduction'.$i} = 18800; 
				$max_taxrate1 = 14200;
				$max_taxrate2 = 54200;
				$max_taxrate3 = 86350;
				$max_taxrate4 = 164900;
				$max_taxrate5 = 209400;
				$max_taxrate6 = 523600;
				$ctc_max_income_covid = 112500; 
				$ctc_max_income = 200000; 
			} elsif($out->{'filing_status'.$i} eq 'Married') {
				${'standard_deduction'.$i} = 25100; 
				$max_taxrate1 = 19900;
				$max_taxrate2 = 81050;
				$max_taxrate3 = 172750;
				$max_taxrate4 = 329850;
				$max_taxrate5 = 418850;
				$max_taxrate6 = 628300;
				$ctc_max_income_covid = 150000; 
				$ctc_max_income = 400000; 
			} elsif($out->{'filing_status'.$i} eq 'Single') { # Might as well udpate these in here for now, in case the above interpretation of HH filers is incorrect.
				${'standard_deduction'.$i} = 12550;
				$max_taxrate1 = 9950;
				$max_taxrate2 = 40525;
				$max_taxrate3 = 86375;
				$max_taxrate4 = 164925;
				$max_taxrate5 = 209425;
				$max_taxrate6 = 523600;
				$ctc_max_income_covid = 75000; 
				$ctc_max_income = 200000; 
			}

			# 2 Determine gross federal tax (before CADC and Child Tax Credit)
			#$federal_tax_income = $out->{'earnings'} + $out->{'interest'} - $standard_deduction - ($exempt_number * $ded_per_exempt); #pre-2018 formula, kept in case exemptions are eventually reincluded.

			for(my $j=1; $j<=4; $j++) {
				if ($in->{'parent'.$j.'_age'} > -1) {
					if ($j == $out->{'filing_status'.$i.'_adult1'} || ($i==1 && ($j == $out->{'filing_status1_adult2'} || $j == $out->{'filing_status1_adult3'} || $j == $out->{'filing_status1_adult4'}))) {
						${'gross_income'.$i} += $out->{'parent'.$j.'_earnings'} + ($out->{'interest'} + $in->{'unearn_gross_mon_inc_amt_ag'})/$in->{'family_structure'} + $out->{'parent'.$j.'_ui_recd'} + $in->{'parent'.$j.'_selfemployed_netprofit'}; #Current formula, since 2017 tax reform removed exemptions.
						
						# Self-employment taxes are calculated differently than taxes from wage income. Since they do not impact benefit cliffs, we are at this time making a simplifying assumption that the taxes from wage income and self-employment are equivalent.
						
						#Note: ARPA excludes the first $10,200 in unemployment compensation from each individual receiving unemployment in tax year 2020. As this is not a permanent change affecting tax year 2021 and beyond (which we are modeling here), we are not including that exclusion. Techincally, this is only for tax filers with gross income exceeding $150,000, but we are simplifying this by assuming that anyone using the client-based tool has gross income less than $150k.

						#Note on gifts: Typically, people do not pay income tax on gifts they receive. People who make gifts must typically pay taxes on gifts exceeding $15,000, but the burden is on the donor rather than the donee (unless the donor doesn't pay).
						
						${'earnings_unit'.$i} += $out->{'parent'.$j.'_earnings'} + $in->{'parent'.$j.'_selfemployed_netprofit'}; #The combined earnings of members of tax unit 1 is needed for determining EITC and the additional CTC, in the ctc module.
					}
				}
			}
			${'federal_tax_income'.$i} = ${'gross_income'.$i} - ${'standard_deduction'.$i}; #Current formula, since 2017 tax reform removed exemptions. 

			if(${'federal_tax_income'.$i} <= 0) {
				${'federal_tax_income'.$i} = 0;
				${'federal_tax_gross'.$i} = 0;
			} else {
				if(${'federal_tax_income'.$i} <= $max_taxrate1) {
					${'federal_tax_gross'.$i} = $tax_rate1 * ${'federal_tax_income'.$i};
				} elsif(${'federal_tax_income'.$i} <= $max_taxrate2) {
					${'federal_tax_gross'.$i} = ($tax_rate2 * (${'federal_tax_income'.$i} - $max_taxrate1)) + ($tax_rate1 * $max_taxrate1);
				} elsif(${'federal_tax_income'.$i} <= $max_taxrate3) {
					${'federal_tax_gross'.$i} = ($tax_rate3 * (${'federal_tax_income'.$i} - $max_taxrate2))
									   + ($tax_rate2 * ($max_taxrate2 - $max_taxrate1))
									   + $tax_rate1 * $max_taxrate1;
				} elsif(${'federal_tax_income'.$i} <= $max_taxrate4) {
					${'federal_tax_gross'.$i} = ($tax_rate4 * (${'federal_tax_income'.$i} - $max_taxrate3))
									   + ($tax_rate3 * ($max_taxrate3 - $max_taxrate2))
									   + ($tax_rate2 * ($max_taxrate2 - $max_taxrate1))
									   + $tax_rate1 * $max_taxrate1;
				} elsif(${'federal_tax_income'.$i} <= $max_taxrate5) {
					${'federal_tax_gross'.$i} = ($tax_rate5 * (${'federal_tax_income'.$i} - $max_taxrate4))
									   + ($tax_rate4 * ($max_taxrate4 - $max_taxrate3))
										  + ($tax_rate3 * ($max_taxrate3 - $max_taxrate2))
									   + ($tax_rate2 * ($max_taxrate2 - $max_taxrate1))
									   + $tax_rate1 * $max_taxrate1;
				} elsif(${'federal_tax_income'.$i} <= $max_taxrate6) {
					${'federal_tax_gross'.$i} = ($tax_rate6 * (${'federal_tax_income'.$i} - $max_taxrate5))
									   + ($tax_rate5 * ($max_taxrate5 - $max_taxrate4))
									   + ($tax_rate4 * ($max_taxrate4 - $max_taxrate3))
										  + ($tax_rate3 * ($max_taxrate3 - $max_taxrate2))
									   + ($tax_rate2 * ($max_taxrate2 - $max_taxrate1))
									   + $tax_rate1 * $max_taxrate1;
				} elsif(${'federal_tax_income'.$i} > $max_taxrate6) {
					${'federal_tax_gross'.$i} = ($tax_rate7 * (${'federal_tax_income'.$i} - $max_taxrate6))
									   + ($tax_rate6 * ($max_taxrate6 - $max_taxrate5))  
										+ ($tax_rate5 * ($max_taxrate5 - $max_taxrate4))
									   + ($tax_rate4 * ($max_taxrate4 - $max_taxrate3))
										  + ($tax_rate3 * ($max_taxrate3 - $max_taxrate2))
									   + ($tax_rate2 * ($max_taxrate2 - $max_taxrate1))
									   + $tax_rate1 * $max_taxrate1;
				}
			}
		}
	}

	$federal_tax_gross = $federal_tax_gross1 + $federal_tax_gross2 + $federal_tax_gross3 + $federal_tax_gross4; 
	
	# 3.  Determine CADC and “final” federal tax liability (not including EITC or CTC)
	if ($in->{'cadc'} != 1) {
		$cadc_recd = 0;
	} else {
		#We only calculate the CADC/CDCTC and the CTC for filing status 1, since, above, that is the only filing status that contains children.
		
		#THE BELOW CODES MERGE THE CADC/CDCTC WITH THE DISABILITY EXPENSES CREDIT. 
		
		# Note: Separate from the question of whether a filer can file as head of household or single, children and other relatives int the home may be classified as dependents for the tax filer to claim certain tax credits. In the FRS/MTRC model, all children listed in the household for whom the parent(s) pay half the support for qualify as a dependent. In addition, a spouse who has a disability that is severe enough that they cannot work and possibly require expenses for proper care can also be classified as a dependent.

		#For the CADC/CDCTC, we need to find the adult in filing unit 1 that has the least earnings. Since we define this variable as 0 initially, we need to get a baseline number first before seeing which, if any, income is lower than that baseline. We need to run this if-block because it is possible that parent1 may not be in filing unit 1, which will be the case if parent1 is not married but others in the unit are.
		
		for(my $i=1; $i<=4; $i++) { 
			if ($in->{'parent'. $i.'_age'} > 0) { 
				if ($i == $out->{'filing_status1_adult1'} || $i == $out->{'filing_status1_adult2'}  || $i == $out->{'filing_status1_adult3'} || $i == $out->{'filing_status1_adult4'}) {
					$unit1_lowestearnings = $out->{'parent'.$i.'_earnings'};
					$unit1_lowestearner = $i;
				}
			}
		}

		#We then compare that individual's earnings to the others in filing unit 1, to find the lowest earner in that filing unit.
		for(my $i=1; $i<=4; $i++) { 
			if ($in->{'parent'. $i.'_age'} > 0) { 
				if ($out->{'parent'.$i.'_earnings'} < $unit1_lowestearnings && ($i == $out->{'filing_status1_adult1'} || $i == $out->{'filing_status1_adult2'}  || $i == $out->{'filing_status1_adult3'} || $i == $out->{'filing_status1_adult4'})) {
					$unit1_lowestearnings = $out->{'parent'.$i.'_earnings'};
					$unit1_lowestearner = $i;
				}
			}
		}
		
		#The CADC/CDCTC is available for a maxmium of twice the maximum amount allowable for care for one individual.

		#The below code allows for the CADC/CDCTC to be claimed by a family that includes a parent is incapacitated because of disability.
		
		#If an adult is disabled and not working, we assume that the other parents pay for someone to provide care for the  disabled spouse and their care expenses qualify for cadc. 
		
		if ($in->{'covid_cdctc_expansion'} == 1) {
			$cadc_max_claims = 6000; #ARPA raised the max amount of child or dependent care claimed from $3000 to $6000.
		}
		
		$cadc_base = &least($out->{'child_care_expenses'} +12* $in->{'disability_personal_expenses_m'}, ($in->{'children_under13'} + $in->{'parent_incapacitated_total'}) * $cadc_max_claims, 2 * $cadc_max_claims, $out->{'parent'.$unit1_lowestearner.'_earnings'});

		# determine cadc_percentage. (These are available at https://www.irs.gov/pub/irs-pdf/p503.pdf, at least as of 2021.) Checked for 2021.

		if ($in->{'covid_cdctc_expansion'} == 1) {
			#ARPA drastically expands the maximum CDCTC claimed.
			for ($gross_income1) {
				$cadc_percentage = ($_ <= 125000)  ?   0.50   :
									 ($_ <= 127000)  ?   0.49   :
									 ($_ <= 129000)  ?   0.48   :
									 ($_ <= 131000)  ?   0.47   :
									 ($_ <= 133000)  ?   0.46   :
									 ($_ <= 135000)  ?   0.45   :
									 ($_ <= 137000)  ?   0.44   :
									 ($_ <= 139000)  ?   0.43   :
									 ($_ <= 141000)  ?   0.42   :
									 ($_ <= 143000)  ?   0.41   :
									 ($_ <= 145000)  ?   0.40   :
									 ($_ <= 147000)  ?   0.39   :
									 ($_ <= 149000)  ?   0.38   :
									 ($_ <= 151000)  ?   0.37   :
									 ($_ <= 153000)  ?   0.36   :
									 ($_ <= 155000)  ?   0.35   :
									 ($_ <= 157000)  ?   0.34   :
									 ($_ <= 159000)  ?   0.33   :
									 ($_ <= 161000)  ?   0.32   :
									 ($_ <= 163000)  ?   0.31   :
									 ($_ <= 165000)  ?   0.30   :
									 ($_ <= 167000)  ?   0.29   :
									 ($_ <= 169000)  ?   0.28   :
									 ($_ <= 171000)  ?   0.27   :
									 ($_ <= 173000)  ?   0.26   :
									 ($_ <= 175000)  ?   0.25   :
									 ($_ <= 177000)  ?   0.24   :
									 ($_ <= 179000)  ?   0.23   :
									 ($_ <= 181000)  ?   0.22   :
									 ($_ <= 183000)  ?   0.21   :
									 ($_ <= 400000)  ?   0.20   :
									 ($_ <= 402000)  ?   0.19   :
									 ($_ <= 404000)  ?   0.18   :
									 ($_ <= 406000)  ?   0.17   :
									 ($_ <= 408000)  ?   0.16   :
									 ($_ <= 410000)  ?   0.15   :
									 ($_ <= 412000)  ?   0.14   :
									 ($_ <= 414000)  ?   0.13   :
									 ($_ <= 416000)  ?   0.12   :
									 ($_ <= 418000)  ?   0.11   :
									 ($_ <= 420000)  ?   0.10   :
									 ($_ <= 422000)  ?   0.09   :
									 ($_ <= 424000)  ?   0.08   :
									 ($_ <= 426000)  ?   0.07   :
									 ($_ <= 428000)  ?   0.06   :
									 ($_ <= 430000)  ?   0.05   :
									 ($_ <= 432000)  ?   0.04   :
									 ($_ <= 434000)  ?   0.03   :
									 ($_ <= 436000)  ?   0.02   :
									 ($_ <= 438000)  ?   0.01   :
														 0;
			}
		} else {
			for ($gross_income1) {
				$cadc_percentage = ($_ <= 15000)  ?   0.35   :
									 ($_ <= 17000)  ?   0.34   :
									 ($_ <= 19000)  ?   0.33   :
									 ($_ <= 21000)  ?   0.32   :
									 ($_ <= 23000)  ?   0.31   :
									 ($_ <= 25000)  ?   0.30   :
									 ($_ <= 27000)  ?   0.29   :
									 ($_ <= 29000)  ?   0.28   :
									 ($_ <= 31000)  ?   0.27   :
									 ($_ <= 33000)  ?   0.26   :
									 ($_ <= 35000)  ?   0.25   :
									 ($_ <= 37000)  ?   0.24   :
									 ($_ <= 39000)  ?   0.23   :
									 ($_ <= 41000)  ?   0.22   :
									 ($_ <= 43000)  ?   0.21   :
														0.20;
			}
		}
		$cadc_gross = $cadc_percentage * $cadc_base;
		if ($in->{'covid_cdctc_expansion'} == 1) {
			$cadc_recd = $cadc_gross; #ARPA made the CDCTC (also called CADC credit) fully refundable.
		} else {	
			$cadc_recd = &least($federal_tax_gross1, $cadc_gross);
		}
	}
	$federal_tax_cadc = $federal_tax_gross1 - $cadc_recd;

	$federal_tax = $federal_tax_cadc; #This just calcualtes federal tax for filing unit 1 for now; we'll add the other filing units later in this code. 

	# 4 Determine ctc_nonref_recd
	# Refer to CTC_max_income according to filing status from federal income taxes tables. Use child tax credit worksheet in instructions for form 1040.

	if($in->{'ctc'} == 1) {
		print "debug_ctc_1 \n";
		if ($in->{'covid_ctc_expansion'} == 1) {
			print "debug_ctc_2 \n";
			print "ctc_per_child_arpa: $ctc_per_child_arpa \n";
			print "child_number: $in->{'child_number'} \n";
			$ctc_potential = $ctc_per_child_arpa * $in->{'child_number'}; #Under ARPA, this is $3000..
			$ctc_potential += $ctc_arpa_under6_add * $in->{'children_under6'}; #ARPA adds $600 to the credit (to totla $3,600) for children under 6.
		} else {	
			$ctc_potential = $ctc_per_child * $in->{'children_under17'}; 
		}
		# Adding in the tax credit for other dependents (which is only nonrefundable)
		$ctc_potential += $nonchild_dependent_add * $out->{'adult_children'}; 
		$other_dependent_credit = $nonchild_dependent_add * $out->{'adult_children'}; #The same thing. Tracking this is important because it's still a nonrefundable credit under ARPA.
		
		
		
		if($gross_income1 <= $ctc_max_income && $in->{'covid_ctc_expansion'} == 0) { 
			$ctc_reduction = 0; 
		} else {
			use POSIX;  # to get the ceil function to round up to nearest multiple of 1000. So $425 would be #$1000
			
			if ($in->{'covid_ctc_expansion'} == 1) {
				$ctc_reduction = &least(0.05 * 1000 * ceil((pos_sub($gross_income1, $ctc_max_income_covid))/1000), &pos_sub($ctc_potential,$ctc_per_child * $in->{'child_number'} + $other_dependent_credit)); #Above the new ARPA threshold, the CTC is reduced until the amount of the CTC equals (old: the pre-COVID max of $2000) (new:) the amount of the credit without regard to the additional expansions in ARPA, but seemingly based on the ARPA definition of eligible children. So the first argument in this "least" collection is the ARPA-specific reduction from the ARPA-inflated maximum amount, but the second argument is the difference betweeen the maximum amount under ARPA and the maximum amount under pre-ARPA rules, inclusive of the inclusion of 17-year-olds as qualifying children.
			}
			
			$ctc_reduction += 0.05 * 1000 * ceil((pos_sub($gross_income1,$ctc_max_income))/1000); #Under ARPA and previous to ARPA, the decline above the previous threshold remains the same.
		}
	  
		$ctc_potential_recd = pos_sub($ctc_potential, $ctc_reduction);
		$ctc_potential_recd_nonother = pos_sub($ctc_potential_recd, $other_dependent_credit);
		if($ctc_potential_recd <= 0) { 
			$ctc_nonref_recd = 0; 
		} elsif ($in->{'covid_ctc_expansion'} == 1) {
			$ctc_nonref_recd = &least(greatest(0,$federal_tax_cadc), $ctc_potential_recd, $other_dependent_credit);
			#For ARPA policy scenarios, this  will make the nonrefundable CTC $0 unless there's a non-child dependent in the home, but still generates a nonrefundable credit if there are non-child dependents (including, for MTRC purposes, an adult student or incapacitated adult.) In the ctc.pl code, we use the refundable variable there to make the remaining credit refundable based upon the value of ctc_potential_recd less this potential nonrefundable amount. Similar to pre-ARPA rules, we still need to compare the value of the nonrefundable credit against federal tax liability, as nonrefundable credits cannot in total exceed tax liability.
			
		} else { 
			$ctc_nonref_recd = &least($federal_tax_cadc, $ctc_potential_recd); 
		}
	} else {
		$ctc_nonref_recd = 0;
	}

	# determine federal tax liability (including all nonrefundable credits), and real value of CADC
	
	
	if ($in->{'covid_cdctc_expansion'} == 1) {
		$cadc_real_recd = $cadc_gross;
	} else {
		$cadc_real_recd = &least($cadc_gross, &pos_sub($federal_tax_gross1, $ctc_potential_recd));
	}
	 
	#debugging:
	foreach my $debug (qw(federal_tax_gross federal_tax_gross1 gross_income1 federal_tax_income1 ctc_potential ctc_potential_recd ctc_nonref_recd cadc_real_recd other_dependent_credit federal_tax_cadc)) {
		print $debug.": ".${$debug}."\n";
	}

	foreach my $name (qw(
		gross_income1 
		gross_income2 
		gross_income3 
		gross_income4 
		ctc_nonref_recd
		ctc_potential
		ctc_potential_recd
		ctc_potential_recd_nonother
		federal_tax_gross 
		federal_tax_gross1
		federal_tax_credits 
		federal_tax_income 
		cadc_recd 
		cadc_real_recd 
		ctc_reduction
		other_dependent_credit
		federal_tax 
		federal_tax_cadc 
		cadc_gross 
		cadc_base
		support 
		home
		earnings_unit1
		earnings_unit2
		earnings_unit3
		earnings_unit4
		standard_deduction1
		standard_deduction2
		standard_deduction3
		standard_deduction4 
		)) { 
						#
       $out->{$name} = ${$name};
	}
}

1;
