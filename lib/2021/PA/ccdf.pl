# =============================================================================#
#  CCDF Module -- 2021 – PA
#=============================================================================#
# Inputs referenced in this module:
#
#	INPUTS FROM USER INTERFACE
#		family_size
#		ccdf
#
#	OUTPUTS FROM PARENT EARNINGS:
#       earnings
#
#	OUTPUTS FROM INTEREST
#       interest
#       
#	OUTPUTS FROM TANF
#       child_support_recd
#       tanf_recd
#
#	OUTPUTS FROM SSI
#       ssi_recd
#
#	OUTPUTS FROM CHILD CARE
# 		unsub_all_children
# 		spr_all_children

#============================

#
#

sub ccdf
{
    my $self = shift; 
    my $in = $self->{'in'};
    my $out = $self->{'out'};
    
	#Stil need check in online TANF handbook to see regulations specific to child care for TANF families. See CCDF regulations 3041.16.
  # outputs created
	our $summerweeks = 9; #For now, we're using this universally. It's a typical amount and exact school calendars won't be newly generated until after COVID subsides.
	our $ccdf_entrance_threshold = 2;
	our $ccdf_threshold = 2.35;           # ccdf income eligibility limit as a percent of poverty. Last checked 5/21/21.   
    #our @ccdf_fpl_array = $in->{'fpl'}; #Poverty level from annual levels. PA child care statutes (last checked 5/21/21).
    #our @ccdf_85smi_array = ; apparently SMI and 85% SMI is not considered in PA CCDF.
	our $lump_sum_exemption = 100;		#First $100 of various forms of lump sum income, including gifts, is exempted from income calculations.
    our $cc_subsidized_flag = 0;          # flag indicating whether or not child care is  subsidized
    our $ccdf_eligible_flag = 0;          # flag indicating whether eligible
    our $child_care_recd = 0;             # annual value of child care subsidies (cost  of care minus family expense)
 	our $ccdf_chargeabovespr = 1; #Some states, like NH and PA, allow providers to charge parents an overage amount of the difference between the SPR and the equivalent rate they would have charged without subsidies. This mitigates and potentially minimizes the CCDF cliff (if co-pays can increase to 100% of SPRs), but also potentially increases child care costs for low-income workers. PA CCDF regulations 3041.15
	our $parent_copay_wk = 0;	#The weekly copay.
	our $parent_copay_year = 0;	#The annual copay, before any considerations like paying up to the SPR or additional income decisions are regarded.
	our $parent_copay = 0; #The parent copay, based on income, for subsidized child care.
	our $overage_amount_paid  = 0; #This variable will be the difference between SPRs and unsubsidized child care, which child care providers can charge parents as long as ccdf_chargeabovespr =1.
	our $ccdf_training_hours = 0;	#The amount of training hours that can count toward CCDF work hours in PA.

  # determined in module
    our $ccdf_income = 0;                 # income used to determine ccdf eligibility and copay 
    our $ccdf_poverty_percent = 0;        # family income as percent of poverty

 	our $child_care_expenses = 0; # total annual child care expenses
 	our $child_care_expenses_m = 0;
	our $parent_copay_max = 0; #maximum amount family pays as a percentage of their income for copays.

	our $ccdfpay_total_initial = 0;

	# STEP 1: Test if there is any child care need.
	#First, see if the caregiving parent's training hours count toward CCDF work requirements. Training hours are only counted if they exceed 10 hours per week, but after that requirement is met, then all of the hours are counted.
	if ($in->{'parent'.$out->{'caregiver'}.'_traininghours'} >= 10) {
		$ccdf_training_hours = $in->{'parent'.$out->{'caregiver'}.'_traininghours'};
	}
    if (($out->{'unsub_all_children'} > 0 && ($in->{'ccdf'} == 1  || $out->{'ccdf_alt'} == 1)) 
		&& ($out->{'tanf_recd'} > 0 
		|| $out->{'parent_workhours_w'} + $ccdf_training_hours >= 20 
		|| ($in->{'parent'.$out->{'caregiver'}.'_age'} < 22 && $in->{'parent'.$out->{'caregiver'}.'_ft_student'} == 1 && $in->{'parent'.$out->{'caregiver'}.'_educational_expenses'} == 0)  
		|| ($in->{'family_structure'} > 1 && $in->{'disability_count'} > 0)	
		)) {	
		#Families on TANF receive a child care allowance equivalent to the amount they would receive through CCDF, just covered by different funding. But they do not need to satisfy minimum work hour requirements. Presumably this was originally conceived as a policy because CCDF minimum work hours coincided with TANF work hours.
		#There are also exemptions for adults with disabilities. One is time-sensitive and is only works for half the year (a parent receivng CCDF and becoming disabled enough that they cannot work, after initial determination, is eligible for CCDF for up to 183 days), and the other is that in a two-parent/caretaker family, eligibility can be achieved is one parent has a disabiltiy such that they cannot care for the child. There are also special requirements for Head Start, but since we are primarily determining eligibitliy for parents who are already in CCDF (and maybe Head Start as well), we'll leave this out for now.
		#work hour requirements are waived for high school students younger than 22.
		#Families formerly receiving TANF benefits can also receive CCDF for up to 183 days.
		#  STEP 2: DETERMINE FINANCIAL ELIGIBILITY FOR CCDF SUBSIDIES		#
		# Note: although Social Security income is included in income tabulations, child SSI is explicitly exempted, but adult SSI is not. We are only including adult SSI in the 2020 FRS and 2021 MTRC. 
		
		# While in NH, had decided upon looking at manual that all adults in family should have income counted and can take care of the child. Actually based on relation of adults to children in hh, but we are refraining from asking specific relationship questions. 
		$ccdf_income = $out->{'earnings'}  + $in->{'selfemployed_netprofit_total'} + $out->{'child_support_recd'} + $out->{'ssi_recd'} + $out->{'tanf_recd'} + $out->{'ui_recd'} + $out->{'interest'} + $out->{'gift_income'}; #see FAM 511 - Benefits and Self-Employment sections. #See p6 of PA CCDF regulations, also Appendix A Part 1.
		$ccdf_poverty_percent = $ccdf_income / $in->{'fpl'};
		# Page 43  of the child care subsidy manual clarifies exit eligibility income requirements. 

		#gift income note: We are only including recurring gift income in this MTRC tool (for now), and upon further clarification from Allegheny County, the exemption on gifts only applies to lump sum gifts. This would be the perl code snippet if including that exemption: pos_sub($out->{'gift_income'}, $lump_sum_exemption) 
		# One possible policy option for either reducing co-pays or qualifying for child care subsidies might be to use policy triggers to incentivize businesses to offer dependent care flexible spending accounts to their employees, which allow employees to deposit pre-tax earnings into an account dedicated to paying for costs such as child care. Having access to an account like this would seem to allow employee earnings to fall below income eligibility thresholds for a number of programs (e.g. CCDF, SNAP, and TANF), which would be helpful  if cash or near-cash benefits from those programs increase net resources by more than the amount that families might lose by no longer qualifying for the child and dependent care tax credit, which I think would no longer be available if enrolled in a dependent care FSA. For all these benefit programs, we'd also have to check whether funds in a dependent care FSA count as assets (or if assets that spent in the same month they are received are not actually assets).

		if($ccdf_poverty_percent > $ccdf_threshold) { 
			#PA NOTE: Former TANF recipients are eligible for CCDF, but still must abide by the same eligibility requirements as other potentially eligible families, incuding around hours and income. The language in both the CCDF rules and the PA Cash Assistance Manual regarding this is more about accessing limited CCDF spots than more lenient entry criteria. 
			$cc_subsidized_flag = 0;
			$ccdf_eligible_flag = 0;
			$child_care_recd = 0;
		} else {
			$ccdf_eligible_flag = 1;
			#
			#  STEP 3: DETERMINE VALUE OF  PARENT COST SHARE
			#
			if ($ccdf_eligible_flag == 1) {
			# We determine the parent's :co-pay 
			# Note: TANF rules specify the same co-payment schedules, and the law specific to this points to the same appendix the department uses to update CCDF copayment schedules. The reference in the latest cash assistance manual links to a table last updated in 2019, but the relevant appendix has last been updated as of 2021. So it's clear that the manual is out of date, and that the 2021 numbers should be used. 
			#From 2021 tables (updated 6/14/21 to reflect changes made in May 2021 due to poverty level changes):
				if ($in->{'family_size'} == 2) {			
					for ($ccdf_income) {		
						$parent_copay = 	
							($_ <= 6141)  ? 5 : 
							($_ <= 7164)  ? 6 : 
							($_ <= 8187)  ? 7 : 
							($_ <= 9211)  ? 8 : 
							($_ <= 10234)  ? 10 : 
							($_ <= 11258)  ? 11 : 
							($_ <= 12281)  ? 13 : 
							($_ <= 13305)  ? 15 : 
							($_ <= 14328)  ? 17 : 
							($_ <= 15351)  ? 19 : 
							($_ <= 16375)  ? 21 : 
							($_ <= 17398)  ? 23 : 
							($_ <= 18422)  ? 26 : 
							($_ <= 19445)  ? 28 : 
							($_ <= 20469)  ? 30 : 
							($_ <= 21492)  ? 32 : 
							($_ <= 22515)  ? 34 : 
							($_ <= 23539)  ? 36 : 
							($_ <= 24562)  ? 39 : 
							($_ <= 25586)  ? 41 : 
							($_ <= 26609)  ? 43 : 
							($_ <= 27632)  ? 46 : 
							($_ <= 28656)  ? 48 : 
							($_ <= 29679)  ? 51 : 
							($_ <= 30703)  ? 53 : 
							($_ <= 31726)  ? 56 : 
							($_ <= 32750)  ? 59 : 
							($_ <= 33773)  ? 61 : 
							($_ <= 34796)  ? 64 : 
							($_ <= 35820)  ? 67 : 
							($_ <= 36843)  ? 70 : 
							($_ <= 37867)  ? 73 : 
							($_ <= 38890)  ? 76 : 
							($_ <= 39914)  ? 79 : 
							($_ <= 40937)  ? 82 : 
							82;
					}		
				} elsif ($in->{'family_size'} == 3) {			
					for ($ccdf_income) {		
						$parent_copay = 	
							($_ <= 7741)  ? 5 : 
							($_ <= 9031)  ? 7 : 
							($_ <= 10321)  ? 9 : 
							($_ <= 11611)  ? 10 : 
							($_ <= 12902)  ? 12 : 
							($_ <= 14192)  ? 14 : 
							($_ <= 15482)  ? 16 : 
							($_ <= 16772)  ? 19 : 
							($_ <= 18062)  ? 21 : 
							($_ <= 19352)  ? 24 : 
							($_ <= 20642)  ? 27 : 
							($_ <= 21933)  ? 29 : 
							($_ <= 23223)  ? 32 : 
							($_ <= 24513)  ? 35 : 
							($_ <= 25803)  ? 38 : 
							($_ <= 27093)  ? 40 : 
							($_ <= 28383)  ? 43 : 
							($_ <= 29673)  ? 46 : 
							($_ <= 30964)  ? 49 : 
							($_ <= 32254)  ? 52 : 
							($_ <= 33544)  ? 55 : 
							($_ <= 34834)  ? 58 : 
							($_ <= 36124)  ? 61 : 
							($_ <= 37414)  ? 64 : 
							($_ <= 38705)  ? 67 : 
							($_ <= 39995)  ? 71 : 
							($_ <= 41285)  ? 74 : 
							($_ <= 42575)  ? 77 : 
							($_ <= 43865)  ? 81 : 
							($_ <= 45155)  ? 85 : 
							($_ <= 46445)  ? 88 : 
							($_ <= 47736)  ? 92 : 
							($_ <= 49026)  ? 96 : 
							($_ <= 50316)  ? 100 : 
							($_ <= 51606)  ? 104 : 
							104;
					}		
				} elsif ($in->{'family_size'} == 4) {			
					for ($ccdf_income) {		
						$parent_copay = 	
							($_ <= 7784)  ? 5 : 
							($_ <= 9341)  ? 7 : 
							($_ <= 10898)  ? 8 : 
							($_ <= 12455)  ? 10 : 
							($_ <= 14012)  ? 12 : 
							($_ <= 15569)  ? 15 : 
							($_ <= 17126)  ? 17 : 
							($_ <= 18683)  ? 20 : 
							($_ <= 20239)  ? 23 : 
							($_ <= 21796)  ? 26 : 
							($_ <= 23353)  ? 29 : 
							($_ <= 24910)  ? 32 : 
							($_ <= 26467)  ? 36 : 
							($_ <= 28024)  ? 39 : 
							($_ <= 29581)  ? 42 : 
							($_ <= 31138)  ? 45 : 
							($_ <= 32694)  ? 49 : 
							($_ <= 34251)  ? 52 : 
							($_ <= 35808)  ? 55 : 
							($_ <= 37365)  ? 59 : 
							($_ <= 38922)  ? 62 : 
							($_ <= 40479)  ? 66 : 
							($_ <= 42036)  ? 69 : 
							($_ <= 43593)  ? 73 : 
							($_ <= 45149)  ? 77 : 
							($_ <= 46706)  ? 81 : 
							($_ <= 48263)  ? 85 : 
							($_ <= 49820)  ? 89 : 
							($_ <= 51377)  ? 93 : 
							($_ <= 52934)  ? 98 : 
							($_ <= 54491)  ? 102 : 
							($_ <= 56048)  ? 106 : 
							($_ <= 57604)  ? 111 : 
							($_ <= 59161)  ? 116 : 
							($_ <= 60718)  ? 120 : 
							($_ <= 62275)  ? 125 : 
							125;
					}		
				} elsif ($in->{'family_size'} == 5) {			
					for ($ccdf_income) {		
						$parent_copay = 	
							($_ <= 7294)  ? 5 : 
							($_ <= 9118)  ? 6 : 
							($_ <= 10942)  ? 8 : 
							($_ <= 12765)  ? 10 : 
							($_ <= 14589)  ? 12 : 
							($_ <= 16412)  ? 15 : 
							($_ <= 18236)  ? 17 : 
							($_ <= 20060)  ? 20 : 
							($_ <= 21883)  ? 23 : 
							($_ <= 23707)  ? 27 : 
							($_ <= 25530)  ? 30 : 
							($_ <= 27354)  ? 34 : 
							($_ <= 29178)  ? 38 : 
							($_ <= 31001)  ? 42 : 
							($_ <= 32825)  ? 46 : 
							($_ <= 34648)  ? 49 : 
							($_ <= 36472)  ? 53 : 
							($_ <= 38296)  ? 57 : 
							($_ <= 40119)  ? 61 : 
							($_ <= 41943)  ? 65 : 
							($_ <= 43766)  ? 69 : 
							($_ <= 45590)  ? 73 : 
							($_ <= 47414)  ? 77 : 
							($_ <= 49237)  ? 81 : 
							($_ <= 51061)  ? 86 : 
							($_ <= 52884)  ? 90 : 
							($_ <= 54708)  ? 95 : 
							($_ <= 56532)  ? 100 : 
							($_ <= 58355)  ? 104 : 
							($_ <= 60179)  ? 109 : 
							($_ <= 62002)  ? 114 : 
							($_ <= 63826)  ? 119 : 
							($_ <= 65650)  ? 125 : 
							($_ <= 67473)  ? 130 : 
							($_ <= 69297)  ? 135 : 
							($_ <= 71120)  ? 141 : 
							($_ <= 72944)  ? 146 : 
							146;
					}		
				} elsif ($in->{'family_size'} == 6) {			
					for ($ccdf_income) {		
						$parent_copay = 	
							($_ <= 8361)  ? 5 : 
							($_ <= 10452)  ? 7 : 
							($_ <= 12542)  ? 9 : 
							($_ <= 14632)  ? 11 : 
							($_ <= 16723)  ? 14 : 
							($_ <= 18813)  ? 17 : 
							($_ <= 20903)  ? 20 : 
							($_ <= 22994)  ? 23 : 
							($_ <= 25084)  ? 27 : 
							($_ <= 27174)  ? 30 : 
							($_ <= 29265)  ? 34 : 
							($_ <= 31355)  ? 39 : 
							($_ <= 33445)  ? 43 : 
							($_ <= 35536)  ? 48 : 
							($_ <= 37626)  ? 53 : 
							($_ <= 39716)  ? 57 : 
							($_ <= 41807)  ? 61 : 
							($_ <= 43897)  ? 65 : 
							($_ <= 45987)  ? 70 : 
							($_ <= 48077)  ? 74 : 
							($_ <= 50168)  ? 79 : 
							($_ <= 52258)  ? 83 : 
							($_ <= 54348)  ? 88 : 
							($_ <= 56439)  ? 93 : 
							($_ <= 58529)  ? 98 : 
							($_ <= 60619)  ? 104 : 
							($_ <= 62710)  ? 109 : 
							($_ <= 64800)  ? 114 : 
							($_ <= 66890)  ? 120 : 
							($_ <= 68981)  ? 125 : 
							($_ <= 71071)  ? 131 : 
							($_ <= 73161)  ? 137 : 
							($_ <= 75252)  ? 143 : 
							($_ <= 77342)  ? 149 : 
							($_ <= 79432)  ? 155 : 
							($_ <= 81523)  ? 161 : 
							($_ <= 83613)  ? 168 : 
							168;
					}		
				} elsif ($in->{'family_size'} == 7) {			
					for ($ccdf_income) {		
						$parent_copay = 	
							($_ <= 9428)  ? 5 : 
							($_ <= 11785)  ? 7 : 
							($_ <= 14142)  ? 10 : 
							($_ <= 16499)  ? 13 : 
							($_ <= 18856)  ? 16 : 
							($_ <= 21213)  ? 19 : 
							($_ <= 23571)  ? 22 : 
							($_ <= 25928)  ? 26 : 
							($_ <= 28285)  ? 30 : 
							($_ <= 30642)  ? 34 : 
							($_ <= 32999)  ? 39 : 
							($_ <= 35356)  ? 44 : 
							($_ <= 37713)  ? 49 : 
							($_ <= 40070)  ? 54 : 
							($_ <= 42427)  ? 59 : 
							($_ <= 44784)  ? 64 : 
							($_ <= 47141)  ? 69 : 
							($_ <= 49498)  ? 74 : 
							($_ <= 51855)  ? 78 : 
							($_ <= 54212)  ? 84 : 
							($_ <= 56569)  ? 89 : 
							($_ <= 58926)  ? 94 : 
							($_ <= 61283)  ? 100 : 
							($_ <= 63640)  ? 105 : 
							($_ <= 65997)  ? 111 : 
							($_ <= 68354)  ? 117 : 
							($_ <= 70712)  ? 123 : 
							($_ <= 73069)  ? 129 : 
							($_ <= 75426)  ? 135 : 
							($_ <= 77783)  ? 141 : 
							($_ <= 80140)  ? 148 : 
							($_ <= 82497)  ? 154 : 
							($_ <= 84854)  ? 161 : 
							($_ <= 87211)  ? 168 : 
							($_ <= 89568)  ? 175 : 
							($_ <= 91925)  ? 182 : 
							($_ <= 94282)  ? 189 : 
							189;
					}		
				} elsif ($in->{'family_size'} == 8) {			
					for ($ccdf_income) {		
						$parent_copay = 	
							($_ <= 7871)  ? 5 : 
							($_ <= 10495)  ? 6 : 
							($_ <= 13119)  ? 8 : 
							($_ <= 15743)  ? 11 : 
							($_ <= 18366)  ? 14 : 
							($_ <= 20990)  ? 17 : 
							($_ <= 23614)  ? 21 : 
							($_ <= 26238)  ? 25 : 
							($_ <= 28862)  ? 29 : 
							($_ <= 31485)  ? 34 : 
							($_ <= 34109)  ? 38 : 
							($_ <= 36733)  ? 43 : 
							($_ <= 39357)  ? 49 : 
							($_ <= 41980)  ? 54 : 
							($_ <= 44604)  ? 60 : 
							($_ <= 47228)  ? 66 : 
							($_ <= 49852)  ? 71 : 
							($_ <= 52476)  ? 76 : 
							($_ <= 55099)  ? 82 : 
							($_ <= 57723)  ? 87 : 
							($_ <= 60347)  ? 93 : 
							($_ <= 62971)  ? 99 : 
							($_ <= 65594)  ? 105 : 
							($_ <= 68218)  ? 111 : 
							($_ <= 70842)  ? 117 : 
							($_ <= 73466)  ? 123 : 
							($_ <= 76089)  ? 130 : 
							($_ <= 78713)  ? 137 : 
							($_ <= 81337)  ? 143 : 
							($_ <= 83961)  ? 150 : 
							($_ <= 86585)  ? 157 : 
							($_ <= 89208)  ? 165 : 
							($_ <= 91832)  ? 172 : 
							($_ <= 94456)  ? 179 : 
							($_ <= 97080)  ? 187 : 
							($_ <= 99703)  ? 195 : 
							($_ <= 102327)  ? 203 : 
							203;
					}		
				} elsif ($in->{'family_size'} == 9) {			
					for ($ccdf_income) {		
						$parent_copay = 	
							($_ <= 8672)  ? 5 : 
							($_ <= 11562)  ? 6 : 
							($_ <= 14453)  ? 9 : 
							($_ <= 17343)  ? 12 : 
							($_ <= 20234)  ? 16 : 
							($_ <= 23124)  ? 19 : 
							($_ <= 26015)  ? 23 : 
							($_ <= 28905)  ? 27 : 
							($_ <= 31796)  ? 32 : 
							($_ <= 34686)  ? 37 : 
							($_ <= 37577)  ? 42 : 
							($_ <= 40467)  ? 48 : 
							($_ <= 43358)  ? 53 : 
							($_ <= 46248)  ? 60 : 
							($_ <= 49139)  ? 66 : 
							($_ <= 52029)  ? 73 : 
							($_ <= 54920)  ? 78 : 
							($_ <= 57810)  ? 84 : 
							($_ <= 60701)  ? 90 : 
							($_ <= 63591)  ? 96 : 
							($_ <= 66482)  ? 103 : 
							($_ <= 69372)  ? 109 : 
							($_ <= 72263)  ? 115 : 
							($_ <= 75153)  ? 122 : 
							($_ <= 78044)  ? 129 : 
							($_ <= 80934)  ? 136 : 
							($_ <= 83825)  ? 143 : 
							($_ <= 86715)  ? 151 : 
							($_ <= 89606)  ? 158 : 
							($_ <= 92496)  ? 166 : 
							($_ <= 95387)  ? 173 : 
							($_ <= 98277)  ? 181 : 
							($_ <= 101168)  ? 189 : 
							($_ <= 104058)  ? 198 : 
							($_ <= 106949)  ? 206 : 
							($_ <= 109839)  ? 214 : 
							($_ <= 112730)  ? 223 : 
							223;
					}		
				}			
				
				if ($out->{'unsub_nonsummer'} > 0) {
					$parent_copay_year += (52-$summerweeks) * $parent_copay;
				}
				
				if ($out->{'unsub_summer'} > 0) {
					$parent_copay_year += $summerweeks * $parent_copay;
				}
				
				if ($ccdf_poverty_percent <= 1) {
					$parent_copay_max = .08 * $ccdf_income;
				} else {
					$parent_copay_max = .11 * $ccdf_income;
				}
				$parent_copay = &least($out->{'spr_all_children'},$parent_copay, $parent_copay_max);
				#
				# STEP 4. COMPARE THE UNSUBSIDIZED COST OF CARE TO COPAY)
				#
				if($parent_copay > $out->{'unsub_all_children'}) {
					# In this case, the unsubsidized cost of child care is cheaper, so the family will opt for that.
					$cc_subsidized_flag = 0;
				} else {
					$cc_subsidized_flag = 1;

					#We can use the ccdf_chargeabovespr as a dummy variable (1 or 0, with it being 1 in NH's case) in calculate the overage payment (co-pay in NH) as the difference between unsubsidized care and the state payment rate in states that operate this policy. We call this variable "overage payment" in other states. NH has this policy (938 FAM).
					
					#We are asking users to indicate their out-of-pocket costs for child care, which will include both the overage payment (overage_amount_paid) and the parent cost share (parent_copay), which is the sliding scale payment amount. We have to disentangle these.
					
					#We need to figure out any overage payments the family will be paying. This is called "co-pay" in New Hampshire. If a user has entered how much they currently pay for CCDF-subsidized child care, we incorporate this amount into the below calculations. If not, we derive it from the market rates.
					
					#For users who have not entered current payment amounts or for the hypothetical scenario in which the tool models CCDF where it hadn't before. 
					if ($in->{'ccdfpay_estimate_source'} eq 'fullcost_ccdf' || ($in->{'ccdf'} == 0  && $out->{'ccdf_alt'} == 1)) {
						$overage_amount_paid = $ccdf_chargeabovespr * &pos_sub($out->{'fullcost_all_children'},$out->{'spr_all_children'}); 
					} else {
						#User has entered their own child care costs for CCDF participation. We use these first to identify an initial overage amount that we will apply for future iterations.
						for(my $i=1; $i<=5; $i++) {
							if ($in->{'child'.$i.'_age'} >-1 || $in->{'child'.$i.'_age'} < 13) {
								if ($in->{'ccdf_payscale'.$i} eq 'year') {
									$ccdfpay_total_initial += $in->{'child'.$i.'_ccdfpay_amt_m'};
								} elsif ($in->{'ccdf_payscale'.$i} eq 'month') {
									$ccdfpay_total_initial += $in->{'child'.$i.'_ccdfpay_amt_m'} * 12;
								} elsif ($in->{'ccdf_payscale'.$i} eq 'biweekly') {
									$ccdfpay_total_initial += $in->{'child'.$i.'_ccdfpay_amt_m'} * 26;
								} elsif ($in->{'ccdf_payscale'.$i} eq 'week') {
									$ccdfpay_total_initial += $in->{'child'.$i.'_ccdfpay_amt_m'} * 52;
								}
							}
						}
						if ($out->{'scenario'} eq 'current') {
							#We define an input variable, overage_amount. Since the current scenario is always run first, this will set up the overage amount for the future scenarios once they are invoked.
							$in->{'overage_amount'} = &pos_sub($ccdfpay_total_initial, $parent_copay);
							#Also, if they are paying under the amount of their parent cost share but participating in CCDF, that means that their child care provider is not only charging under the market rate, but under the SPR amount for the care they provide. We therefore lower the care they receive by this amount as well. Like overage_amount above, we assume below that the discount amount is a constant, and not proportional to the amount of care received or how much the provider could charge for that are at their market rates.
														
							$in->{'discount_amount'} = &pos_sub($parent_copay, $ccdfpay_total_initial);
														
							#In frs.pm, run once before any of the scenarios or iterations, we define both overage_amount and discount_amount as 0, so the invocations of these variables outside of this if-block will still work.
						}
						#We identify the child care copay, using the overage_amount variable that was just defined or that was defined in the "current" scenario. This assumes that any markup child care providers charge above the SPR is constant. Alternatively, we could include a proportional markup  against the full cost of care (fullcost_all_children), with any increases in child care schedules that might demand higher rates, but the market rate study includes rates that already have a large enough jump betweeen part-time and full-time care (that this tool dampens to something more realistic by including a half-time rate), that making the markup proportional to the market rate of care would exacerbate marginal tax rates unrealistically -- for the amounts it would raise child care rates by, users would most likely simply switch providers. This could be changed easily in the code if desired.
						
						$overage_amount_paid =  $in->{'overage_amount'}; #No need to multiply this by $ccdf_chargeabovespr since if they are paying an overage amount and on CCDF (like can happen in NH), then obviously, that happens. The question ascertaining overage costs in the first place should not be asked in locations where this policy is not active.
					}
					$child_care_expenses = &pos_sub($parent_copay + $overage_amount_paid, $in->{'discount_amount'});
					$child_care_recd = &pos_sub($out->{'spr_all_children'}, $parent_copay) + $in->{'discount_amount'};

				}
			}
		}
	} else {
	    $cc_subsidized_flag = 0;
        $ccdf_eligible_flag = 0;
        $child_care_recd = 0;

	} 	        
    #
    # STEP 6. DETERMINE UNSUBSIDIZED COST OF CARE
    #
    if($cc_subsidized_flag == 0) {

		$child_care_expenses = pos_sub($out->{'unsub_all_children'}, $in->{'discount_amount'}); #We include a the discount_amount here, which is set to 0 unless a family both qualifies and has entered in an override amount that is less than the parent share (sliding scale payment) of child care. Adding that to families that lose CCDF subsidies models the access to below-market rates that the family has. 
		$child_care_recd = 0;
	}

 	$child_care_expenses_m = $child_care_expenses / 12;       

	#debugging
	 foreach my $debug (qw(child_care_recd child_care_expenses ccdf_eligible_flag ccdf_poverty_percent ccdf_step parent_copay_percent parent_copay cc_subsidized_flag overage_amount_paid child_care_recd ccdf_income)) {
		print $debug.": ".${$debug}."\n";
	}

  # outputs
    foreach my $name (qw(child_care_expenses child_care_expenses_m  cc_subsidized_flag ccdf_eligible_flag child_care_recd ccdf_step parent_copay_percent)) {
        $out->{$name} = ${$name};
    }
	
}

1;