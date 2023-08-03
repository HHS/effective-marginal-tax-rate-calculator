# Defaults PA 2021

sub defaults {

    my $self = shift;

	# The below "order" defines the sequencing of the various individual Perl codes. This order must be reexamined for each jurisdiction (e.g. a state) where an MTRC or any related tool is developed. There are some repetitions based on how families can optimally use various programs. For example, in many states TANF includes a child care deduction, but also can lead to work requirements that increase child care need, so in those states it may be optimal for a family to first assess their child care need before enrolling in TANF, see their child care need increase due to work requirements, and then allow them to claim a larger TANF child care deduction that will increase their TANF cash assistance. 
	
    @{$self->{'order'}} = qw(interest parent_earnings filing_status unemployment transportation ssp ssi fed_hlth_insurance hlth child_support child_care ccdf tanf child_care ccdf tanf sec8 fsp_assets liheap fsp schoolsummermeals wic fedtax eitc payroll ctc statetax food lifeline salestax other);
	
	#Loops:
	#child_care needs to know TANF for Head Start availability.
	#CCDF has tanf_recd as income input
	#tanf has child_care_recd as input for determining work hours.
	#So we run child_care first, after initially setting tanf_recd to 0. Then run CCDF, also with TANF at 0, to see if a family can receive subsidized care based on income before TANF is considered. Then Run TANF, using eligibiltiy for CCDF to help determine eligibility and satisfaction of work requirements. Then run child care again, to see if the change in TANF affects Head Start eligibility. Then CCDF again, to determine if the amount of TANF received lowers  them over income limits or results in higher child care costs. Then tanf, because if they lose child care subsidies, parents may no longer be on sanctions, and could gain more tanf. But we do not run child care again to check Head Start eligibility, as we can assume at this point in this sequence the child will be enrolled in Head Start and there is no exit eligibility limit in the program.
	
	#Below is an explanation of the "order" above, specific to New Hampshire. It is illustrative of the methodology of the MTRC, but may differ for other states when one program's rules require inputs from another program's rules, that are also at least partially dependent -- directly or indirectly -- on outputs from the initial program. Please note that there are some repeated codes/functions, also explained below. 
	#1. filing_status: breaks down the members of the family unit into different taxable units. This is important both for taxes and for Medicaid determinations. 
	#2.	interest: this is a code that is used to account for the unearned income the household receives. It is called "interest" because in predecessors to this tool, interest was the only source of unearned income included. It has since been expanded to tabulate alimony and the catch-all "other income" inputs. 
	#3. parent_earnings: this code tabulates total weekly, monthly, and annual earnings on the part of each adult in the household and of the entire household 
	#4. unemployment: calculates the unemployment insurance income received by each member of the household. 
	#5. transportation: calculates transportation costs.
	#6. ssp: accounts for state variation in state supplement programs, that supplement federal SSI cash assistance.
	#7. ssi: calculates the SSI payments a household is eligible to receive (partially contingent on UI payments)
	#8. fed_health_insurance: calculates MAGI income and the caps on healthcare insurance that the family might pay.
	#9. hlth: calculates Medicaid eligibility, ACA subsidies, and health insurance costs. Necessarily after SSI because SSI confers categorical eligibility to SSI recipients.
	#10. child_support: translates the input of child support owed to an output. This is also a placeholder in case someone wants to add in a more robust model of child support inclusive of child support court order formulas. Predecessors of this tool have done so, but for various reasons, it was decided to keep child support owed a constant.
	#11. child_care: calculates unsubsidized child care costs and, for the potential Head Start scenario, potential Head Start eligibility and savings.   
	#12. tanf: calculates TANF/FANF cash assistance, which counts UI and adult SSI toward eligibility, as well as child support paid to the household. This needs to run after child care because households can increase TANF cash assistance through the child care deduction.
	#13. child_care (2): recalculates child care costs, informed by whether TANF cash assistance received by the houshold qualifies them for Head Start. 	#5. Child Care Scholarship (CCDF / child care assistance), which counts TANF, SSP, SSI, and UI toward eligibility,  
	#14. tanf (2): recalculates TANF/FANF cash assistance, since reduced child care costs may affect TANF eligibiltiy and the amount of cash assistance received. 
	#15. ccdf: calculates eligibiltiy and savings from Child Care Scholarship (CCDF / child care assistance),  which counts TANF, SSP, SSI, and UI toward eligibility,  
	#16. tanf (3): recalculates TANF/FANF again, for a third time, since CCDF eligibility may reduce the amount of the TANF child care deduction families can claim, 
	#17. ccdf (2): Child Care Scholarship (CCDF / child care assistance) for a second time, since reduced TANF may impact which CCDF “step” a family is on, 
	#18. sec8: calculates eligibility for Section 8 / HCVP/ LIHTC / Public Housing. Calculations of family contributions to rent incorporate TANF, SSI, and UI, and since some medical deductions can be contingent on Medicaid eligibility,
	#19. fsp_assets: generates variables for state-specific SNAP policy rules and calculates estimates for energy costs.
	#20. liheap: calcultes eligibilty and benefit receipt for LIHEAP and EAP ( fuel and electric assistance). Calculations of family income for these program incorporate TANF, SSP, SSI, and UI.
	#21. fsp: calculates SNAP / Food Stamp eligibilty and receipt. Calculaations for eligibility and income require previous calculations for TANF, SSP, and SSI, and UI. Benefits are also partially contingent on child care costs and shelter costs, informed by the codes run above, earlier in this sequence.  
	#22. schoolsummermeals: calculations of savings from nutrition (school meal) programs, including free and reduced price school lunch and breakfast. These are partially contingent on SNAP and TANF receipt, both of which confer categorical eligibility for free meals. TANF, SSI, and UI are counted as income in eligibility considerations as well.
	#23. wic: calculates eligibiltiy for WIC and estimates WIC beneits. WIC policy  confers categorical eligibility to SNAP, TANF, and Medicaid recipients.
	#24. fedtax: calculate federal tax liabiltiy and federal tax credits.
	#25. eitc: calculates each tax filer's EITC.
	#26. payroll: calculates payroll taxes on earnings for all adults.
	#27. ctc: calculates any remaining portion of the child tax credit not calculated in fedtax. For years prior to the passage of ARPA, this included the refundable portion of the credit, while fedtax calculated only the nonrefundable portion.  
	#28. statetax: calculates state tax liability and state tax credits.
	#29. food: calculates food costs, inclusive of any reductions in those food costs through SNAP, meal programs, and WIC.
	#30. lifeline: incldues state-specific policy and market data related to Lifeline telephone subsidies. Lifeline confers categorical eligibility to households receiving Medicaid, SNAP, SSI, and housing assistance recipients.
	#31. salestax: includes state policy information on sales tax rates.
	#32. other: calculates an estimate for "other necessities" such as clothing, household supplies, and telephone costs. The basic caluction is based on a proportion of housing and food costs, and sales tax is added after that basic calculation. Lifeline subsidies reduce telephone costs calculated here.
	
	
  # define variables to be used for creating charts
  # The MTRC does not use charts, but keeping this array in here in case it's helpful for future updates or adaptations by collaborators.
      @{$self->{'chart'}} = qw(disability_parent1 disability_parent2 disability_expenses family_size unit_size ccdf fsp hlth sec8 tanf eitc state_eitc ctc state_cadc state earnings earnings_posttax earnings_plus_interest taxes  
    federal_tax state_tax local_tax payroll_tax fpl child_support_recd eitc_recd ctc_total_recd tanf_recd fsp_recd rent_paid child_care_expenses 
    food_expenses housing_recd child_care_recd hlth_cov_parent hlth_cov_child1 hlth_cov_child2 hlth_cov_child3 hlth_cov_child4 hlth_cov_child5 hlth_cov_child_all fpl ccdf_eligible_flag lifeline lifeline_recd other_expenses 
    trans_expenses premium_tax_credit premium_credit_recd public_hlth_prem health_expenses health_expenses_before_oop child1_age child2_age child3_age child4_age child5_age state_eic_recd state_cadc_recd debt_payment 
    federal_tax_gross cadc cadc_recd tax_after_credits state_tax_gross local_tax_gross federal_tax_credits state_tax_credits local_tax_credits net_resources wic_recd child_foodcost_red_total ssi_recd liheap_recd afterschool_expenses salestax upd_recd); 

  # define variables to be included in private CSV output file
  # The private_csv output file is crucial for the MTRC. The frs.pl file creates this csv file and fills it with output from each of the scenarios the user enters information about -- scenarios include current, future, and the "future plus" scenarios that are used to indicate whether there may be savings from CCDF or Head Start or, in some jurisdictions, Pre-K or afterschool programs. Once the private csv file is created, the Perl program ends. Then, the code in page_8.php grabs the data from each line, and displays it in the table and various other places in the Step 8 results pages. For the public-facing tool, e.g. the one accessible through ".../nh.php", the private csv file is deleted after the results page is generated. This helps ensure that no client data is stored on any server using this tool. For the testing pages, e.g. the one accessible through ".../nhtest.php", the private csv file is presserved, to aid debugging.
    @{$self->{'private_csv'}} = qw(fuel_source tanf_earned_ded_recd tanf_earnings ostp parent1_premium_ratio a27yo_premium_ratio family_costfrs parent_costfrs permealcost nsbp frpl fsmp child1_foodcost_red  child2_foodcost_red child3_foodcost_red child4_foodcost_red child5_foodcost_red family_structure parent_number child_number salestax phone_expenses family_size unit_size ssi_recd ssi_recd_mnth ccdf fsp hlth sec8 tanf eitc ssi wic nsbp prek sanctioned state_eitc ctc state_cadc earnings earnings_posttax child_support_recd eitc_recd tanf_recd fsp_recd rent_paid 
    housing_recd last_received_sec8 hlth_recd child_care_recd federal_tax state_tax county_tax federal_tax_gross payroll_tax cadc_real_recd state_eic_recd home support ui_recd
    child_care_expenses food_expenses family_foodcost hlth_cov_parent hlth_cov_child1 hlth_cov_child2 hlth_cov_child3 hlth_cov_child4 hlth_cov_child5  hlth_cov_child_all ctc_additional_recd ctc_total_recd
    lifeline lifeline_recd other_expenses other_regular_payments trans_expenses premium_tax_credit premium_credit_recd public_hlth_prem health_expenses ctc_nonref_recd cadc cadc_recd ccdf_eligible_flag interest debt_payment exempt_number filing_status
    parent1_earnings parent2_earnings parent_workhours_w state_nrcadc_recd state_nrcadc_base state_cadc_recd wic_recd afterschool_expenses disability_work_expenses disability_medical_expenses_mnth disability_personal_expenses disability_expenses salestax child_foodcost_red_total liheap_recd udp_recd federal_tax_income tax_before_credits federal_tax_credits state_tax_credits cs_flag child1_support child2_support child3_support child4_support child5_support gift_income other_income income expenses net_resources); 

  # define variables to be recorded in public CSV output file
  # The public csv is also not used in the MTRC. In predecessors to the MTRC, it was generated as a way for public users to download the data they see in the charts, with headings in plain English (the "captions" defined below) as opposed to variable names. Again, keeping this array in here in case it's helpful for future updates or adaptations by collaborators.
    @{$self->{'public_csv'}} = qw(eitc state_eitc state_cadc earnings net_resources child_support_recd tanf_recd fsp_recd federal_tax_credits state_tax_credits local_tax_credits
    public_hlth_prem premium_credit_recd health_expenses child_care_expenses trans_expenses rent_paid food_expenses family_foodcost lifeline_recd other_expenses debt_payment payroll_tax 
    tax_before_credits tax_after_credits federal_tax_gross eitc_recd ctc_total_recd cadc cadc_recd state_tax_gross state_eic_recd
    state_cadc_recd hlth_cov_parent hlth_cov_child1 hlth_cov_child2 hlth_cov_child3 hlth_cov_child4 hlth_cov_child5 interest wic_recd afterschool_expenses disability_expenses salestax child_foodcost_red_total ssi_recd liheap_recd udp_recd); 

  # define the captions to be used in the public CSV output file
    %{$self->{'csv_labels'}} =
    (
        'earnings'         =>       'Earnings',
        'taxes'            =>       'Taxes',
        'earnings_posttax' =>       'Post-tax Earnings',
        'net_resources'	   =>       'Net Resources',
        'child_support_recd' =>     'Child Support',
        'eitc_recd'        =>       'Federal EITC',
        'cadc_recd'		   =>		'Fed CADC',
        'state_eic_recd'   =>       'State EITC',
        'state_cadc_recd'  =>       'State Child Care Tax Credit',
        'ctc_total_recd'   =>       'Child Tax Credit',
        'tanf_recd'        =>       'TANF',
        'fsp_recd'         =>       'SNAP/Food Stamps',
        'public_hlth_prem'   =>     'Public Health Insurance Premiums',
        'health_expenses'  =>       'Health Insurance',
        'child_care_expenses' =>    'Child Care',
        'trans_expenses'   =>       'Transportation',
        'rent_paid'        =>       'Housing',
        'heap_recd'        =>       'Heap Benefits',
        'food_expenses'    =>       'Food',
        'family_foodcost'  =>       'Family Foodcost',
        'lifeline_recd'    =>       'Lifeline Subsidy',
        'other_expenses'   =>       'Other Necessities',
        'federal_tax'      =>       'Federal Tax',
        'state_tax'        =>       'State Tax',
        'payroll_tax'      =>       'Payroll Tax',
        'debt_payment'     =>       'Debt Payment',
        'local_tax'        =>       'Local Tax',
        'federal_tax_credits' =>	'Fed Tax Credits',
        'state_tax_credits'	=>		'State Tax Credits',
        'local_tax_credits'	=>		'Local Tax Credits',
        'federal_tax_gross' =>		'Fed Gross Tax',
        'state_tax_gross'	=>		'State Gross Tax',
        'hlth_cov_parent'	=>		'Parent\'s Health Coverage',
        'hlth_cov_child1'	=>		'1st Child\'s Health Coverage',
        'hlth_cov_child2'	=>		'2nd Child\'s Health Coverage',
        'hlth_cov_child3'	=>		'3rd Child\'s Health Coverage',
		'hlth_cov_child4'	=>		'4th Child\'s Health Coverage', 
		'hlth_cov_child5'	=>		'5th Child\'s Health Coverage', 
        'tax_before_credits' =>		'Tax Excluding Credits',
        'tax_after_credits' =>		'Tax Including Credits',
      #  'private_max'       =>      'Federal Health Insurance',
        'eitc'              =>      'Federal Earned Income Tax Credit',
        'state_eitc'        =>      'State Earned Income Tax Credit',
        'cadc'              =>      'Federal Child and Dependent Care Tax Credit',
        'state_cadc'        =>      'State Child and Dependent Care Tax Credit (nonrefundable)',
        'interest'        =>      'Interest from Savings',
        'premium_credit_recd'        =>      'Premium Tax Credit',
    #    'heap'              =>      'Home Energy Assistance Program',
		'ssi_recd'			=>		'Supplemental Security Insurance', 
		'disability_expenses' =>	'Disability personal and work expenses', 
		'salestax'			=>		'Sales Tax', 
		'wic_recd'			=>		'WIC', 
		'child_foodcost_red_total' => 'Savings from free or reduced-price meals for children', 
		'ssi_recd'			=> 		'SSI', 
		'liheap_recd'		=>		'Savings from LIHEAP', 
		'afterschool_expenses'	=>	'Afterschool costs',
		'udp_recd'			=>		'Savings from DC\'s Utility Discount Program', 

		
    );

}

1;

