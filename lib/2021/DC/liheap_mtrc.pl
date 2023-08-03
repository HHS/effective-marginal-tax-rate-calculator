#=============================================================================#
#  LIHEAP Module – DC 2020 
#=============================================================================#

# Overview:
# LIHEAP benefits are modeled as reduction in rent costs because the Fair Market Rents include utilities and liheap benefits are paid directly to utility companies. LIHEAP is a federal block grant to states. (It is not an entitlement program). 
# The amount of benefit depends on household size, income, type of unit (multi-family or single family), and fuel source. 
# This module references DOEE's LIHEAP Regular Benefits Table for FY 2020, found here: https://liheapch.acf.hhs.gov/sites/default/files//webfiles/docs/DC_BenefitsMatrix_2020.pdf.
# 
# Inputs referenced in this module:
#
# FROM BASE
#  liheap
#  family_size
#  earnings
#  home_type	# new user-selection with a drop down menu of two options: multi-family (apartments) or single family 
#  fuel_source	# new user-selection “energy source” with a drop down menu of four options: “gas”, “oil”, “electric”, or “HIR” (heat in rent). Default is “gas”
#  energy_cost_override
#
# FROM PARENT EARNINGS
# 	earnings
#
# FROM SEC 8
#  rent_paid 	# annual rent paid by family: tenant rent burden or full rent for families without subsidies
#
# FROM SSI
#  ssi_recd_mnth			# categorically eligible to receive LIHEAP, counted as income
#
# FROM TANF
#  tanf_recd_m			# categorically eligible to receive LIHEAP, counted as income
#  child_support_recd_m

 # =============================================================================#

sub liheap
{
	my $self = shift;
	my $in = $self->{'in'};
	my $out = $self->{'out'};

	# outputs created
	our $liheap_recd = 0;			# annual value of LIHEAP received
	our $liheap_rent = 0;			# the amount of rent paid after accounting for liheap benefits 
	# (annual) # [AK edit - moved comments about UDP here, which is where it is first called. if this isn't the best place, we can move it back below.]
	# If a DC resident qualifies for LIHEAP, they also qualify for DC's Utility Discount Program (UDP), which can come in the form of a residential aid discount (RAD) or residential essential services (RES). 
	# RAD provides assistance with electric bills. It is paid to Pepco. This is estimated to be a 30% reduction of a typical bill. 
	# RES provides assistance with gas bills as part of the Utility Discount Program (UDP). It is paid to Washington Gas. This is estimated to be a 25% reduction of the total bill.  A document saved in the Resources folder indicates that a vast majority of UDP applicants are enrolled in LIHEAP. Further communication with DC's LIHEAP agency confirmed that it made sense to treat UDP as part of the LIHEAP module than having it as a separate flag. 
	our $udp_recd = 0;

	# other variables used
	our $liheap_smi = qw(0 0 42911 53007 63104 73201 83297 85190 87084)[$in->{'family_size'}]; # SMI by family size. This is separate from the smi variable in the general tab of the DC base tables. Updated August 2020.
	our $sfa = 0; #See below for explanation.
	
	# In the fsp (SNAP) code, we define liheap_benefit for the purpose of allowing eligible DC residents to access the Heat and Eat program. Since DC's heat and eat program is a local, and not federal, program, that benefit amount should not factor into the final determination of LIHEAP benefits; they come from different funding sources. So, we're resetting the LIHEAP benefits to 0 here.
	our $max_liheap_benefit = 0; # max liheap benefit based on fuel source and family size
	our $liheap_benefit = 0;
	our $udp_value =  0;	
	our $rad_recd = 0;			# annual value of residential aid discount 
	our $res_recd = 0;			# annual value of residential essential services discount  
	our $liheap_inc_m = 0;		# monthly countable income for LIHEAP eligibility and benefit level calculations
	our $liheap_inc = 0;	    # annual countable income for liheap eligibility
	our $utility_base_m = 0;
	our $utility_base = 0;
   
	# 1. CHECK FOR LIHEAP ELIGIBILITY
	
	if($in->{'liheap'} == 1) {
		
		# 2. LEAP NET INCOME TEST 
		
		$liheap_inc_m = $out->{'earnings'}/12 + $out->{'child_support_recd_m'} + $out->{'ssi_recd_mnth'} + $out->{'tanf_recd_m'}; 
		$liheap_inc = $liheap_inc_m*12;
		print "fsp_recd: $fsp_recd \n";
		if($liheap_inc <= $liheap_smi || $out->{'ssi_recd'} >0 ||  $out->{'tanf_recd'} >0 || $out->{'fsp_recd'}  > 0) {

			# 3. CALCULATE LIHEAP FUEL BENEFIT AND UTILTY DISCOUNT PROGRAM BENEFITS
			# Calculate the maximum LIHEAP benefit for the family.
			# The below calculation uses the HCVP utility allowance excel sheet to determine pha_ua and electricoiladdon by number of children. The value for pha_ua is the same as the same calculation for it in the SNAP (fsp) code.

			# Used this Utility Allowance calculator: https://www.dchousing.org/vue/customer/utility.aspx. Voucher size is determined by Housing Authority based on family composition and subsidy standards including number of beds (one bedroom for head of houshold and partner, and one additional bedroom for every two additional household members, regardless of age or sex). The allowance is based on whichever one - number of beds or voucher size - is smaller. For these estimates, we used all same number of beds to voucher number.
			
			# Use liheap_benefit table to determine max_liheap_benefit based on family_size, home_type, liheap_inc_m, and fuel_source. Output from this table is replicated below.
			#IMPORTANT NOTE: The below codes include a check for a sfa (Solar for All) flag. We could add this to the interface, but at this moment are not doing so since the benefits fromt that program on the short term are basically reversed by LIHEAP reductions. The main drawback to the current approach is not properly accounting for people who participate in Solar for All but not LIHEAP. As most people in apartments are unable to individually opt into Solar for All, this seems reasonable.

			# Updated August 2020.
			print "home_type: $in->{'home_type'} \n"; 
			print "family_size: $in->{'family_size'} \n"; 
			print "fuel_source: $in->{'fuel_source'} \n"; 

			if ($in->{'home_type'} eq 'apartment') {
				if ($in->{'family_size'} == 2) { 
					if ($in->{'fuel_source'} eq 'electric') {  
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)  ?   357   :
								($_ <=  2000)  ?   357   :
								($_ <=  4000)  ?   316   :
								($_ <=  6000)  ?   268   :
								($_ <=  8000)  ?   250   :
								($_ <=  10000)  ?   250   :
								($_ <=  12000)  ?   250   :
								($_ <=  14000)  ?   250   :
								($_ <=  16000)  ?   250   :
								($_ <=  18000)  ?   250   :
									250;
							}
						}
						else { #sfa == 0
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)  ?   857   :
								($_ <=  2000)  ?   857   :
								($_ <=  4000)  ?   816   :
								($_ <=  6000)  ?   768   :
								($_ <=  8000)  ?   744   :
								($_ <=  10000)  ?   552   :
								($_ <=  12000)  ?   528   :
								($_ <=  14000)  ?   432   :
								($_ <=  16000)  ?   408   :
								($_ <=  18000)  ?   360   :
									250;
							}
						}
					} elsif ($in->{'fuel_source'} eq 'gas') { 
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    729  :
								($_ <= 4000)    ?    670   :
								($_ <= 6000)    ?    580   :
								($_ <= 8000)    ?    490   :
								($_ <= 10000)    ?    413   :
								($_ <= 12000)    ?    392   :
								($_ <= 14000)    ?    371   :
								($_ <= 16000)    ?    351   :
								($_ <= 18000)    ?    310   :
									248;
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1229  :
								($_ <= 4000)    ?    1170   :
								($_ <= 6000)    ?    1080   :
								($_ <= 8000)    ?    990   :
								($_ <= 10000)    ?    900   :
								($_ <= 12000)    ?    855   :
								($_ <= 14000)    ?    810   :
								($_ <= 16000)    ?    765   :
								($_ <= 18000)    ?    675   :
									540;
							}
						}
					}
				} elsif ($in->{'family_size'} == 3) {	
					if ($in->{'fuel_source'} eq 'electric') {
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								 ($_ <= 2000)    ?    443    :
								($_ <= 4000)    ?    398    :
								($_ <= 6000)    ?    345    :
								($_ <= 8000)    ?    318    :
								($_ <= 10000)    ?    250    :
								($_ <= 12000)    ?    250    :
								($_ <= 14000)    ?    250    :
								($_ <= 16000)    ?    250    :
								($_ <= 18000)    ?    250    :
								250;
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								 ($_ <= 2000)    ?    943    :
								($_ <= 4000)    ?    898    :
								($_ <= 6000)    ?    845    :
								($_ <= 8000)    ?    818    :
								($_ <= 10000)    ?    607    :
								($_ <= 12000)    ?    581    :
								($_ <= 14000)    ?    475    :
								($_ <= 16000)    ?    449    :
								($_ <= 18000)    ?    396    :
								250;
							}
						}
					} elsif ($in->{'fuel_source'} eq 'gas') {
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    790    :
								($_ <= 4000)    ?    729    :
								($_ <= 6000)    ?    634    :
								($_ <= 8000)    ?    540    :
								($_ <= 10000)    ?    445    :
								($_ <= 12000)    ?    412    :
								($_ <= 14000)    ?    390    :
								($_ <= 16000)    ?    368    :
								($_ <= 18000)    ?    325    :
								260;
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1290    :
								($_ <= 4000)    ?    1229    :
								($_ <= 6000)    ?    1134    :
								($_ <= 8000)    ?    1040    :
								($_ <= 10000)    ?    945    :
								($_ <= 12000)    ?    898    :
								($_ <= 14000)    ?    851    :
								($_ <= 16000)    ?    803    :
								($_ <= 18000)    ?    709    :
								567;	
							}
						}
					}
				} elsif ($in->{'family_size'} >= 4) {
					if ($in->{'fuel_source'} eq 'electric') {
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    571    :
								($_ <= 4000)    ?    520    :
								($_ <= 6000)    ?    460    :
								($_ <= 8000)    ?    430    :
								($_ <= 10000)    ?    250    :
								($_ <= 12000)    ?    250    :
								($_ <= 14000)    ?    250    :
								($_ <= 16000)    ?    250    :
								($_ <= 18000)    ?    250    :
								250;	
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1071    :
								($_ <= 4000)    ?    1020    :
								($_ <= 6000)    ?    960    :
								($_ <= 8000)    ?    930    :
								($_ <= 10000)    ?    690    :
								($_ <= 12000)    ?    660    :
								($_ <= 14000)    ?    540    :
								($_ <= 16000)    ?    510    :
								($_ <= 18000)    ?    450    :
								250;	
							}
						}
					} elsif ($in->{'fuel_source'} eq 'gas') {
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1036    :
								($_ <= 4000)    ?    963    :
								($_ <= 6000)    ?    850    :
								($_ <= 8000)    ?    738    :
								($_ <= 10000)    ?    625    :
								($_ <= 12000)    ?    569    :
								($_ <= 14000)    ?    513    :
								($_ <= 16000)    ?    456    :
								($_ <= 18000)    ?    387    :
								310;
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1536    :
								($_ <= 4000)    ?    1463    :
								($_ <= 6000)    ?    1350    :
								($_ <= 8000)    ?    1238    :
								($_ <= 10000)    ?    1125    :
								($_ <= 12000)    ?    1069    :
								($_ <= 14000)    ?    1013    :
								($_ <= 16000)    ?    956    :
								($_ <= 18000)    ?    844    :
								675;	
							}
						}
					}
				}
			} elsif ($in->{'home_type'} eq 'house') {  
				if ($in->{'family_size'} == 2) {
					if ($in->{'fuel_source'} eq 'electric') {
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    616    :
								($_ <= 4000)    ?    563    :
								($_ <= 6000)    ?    500    :
								($_ <= 8000)    ?    469    :
								($_ <= 10000)    ?    250    :
								($_ <= 12000)    ?    250    :
								($_ <= 14000)    ?    250    :
								($_ <= 16000)    ?    250    :
								($_ <= 18000)    ?    250    :
								250;
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1116    :
								($_ <= 4000)    ?    1063    :
								($_ <= 6000)    ?    1000    :
								($_ <= 8000)    ?    969    :
								($_ <= 10000)    ?    719    :
								($_ <= 12000)    ?    688    :
								($_ <= 14000)    ?    563    :
								($_ <= 16000)    ?    531    :
								($_ <= 18000)    ?    469    :
								250;
							}
						}
					} elsif ($in->{'fuel_source'} eq 'gas') { 
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1002    :
								($_ <= 4000)    ?    930    :
								($_ <= 6000)    ?    820    :
								($_ <= 8000)    ?    710    :
								($_ <= 10000)    ?    600    :
								($_ <= 12000)    ?    545    :
								($_ <= 14000)    ?    490    :
								($_ <= 16000)    ?    435    :
								($_ <= 18000)    ?    378    :
								303;
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1502    :
								($_ <= 4000)    ?    1430    :
								($_ <= 6000)    ?    1320    :
								($_ <= 8000)    ?    1210    :
								($_ <= 10000)    ?    1100    :
								($_ <= 12000)    ?    1045    :
								($_ <= 14000)    ?    990    :
								($_ <= 16000)    ?    935    :
								($_ <= 18000)    ?    825    :
								660;
							}	
						}
					}
				} elsif ($in->{'family_size'} == 3) {
					if ($in->{'fuel_source'} eq 'electric') {
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    727    :
								($_ <= 4000)    ?    669    :
								($_ <= 6000)    ?    600    :
								($_ <= 8000)    ?    566    :
								($_ <= 10000)    ?    291    :
								($_ <= 12000)    ?    256    :
								($_ <= 14000)    ?    250    :
								($_ <= 16000)    ?    250    :
								($_ <= 18000)    ?    250    :
								250
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1227    :
								($_ <= 4000)    ?    1169    :
								($_ <= 6000)    ?    1100    :
								($_ <= 8000)    ?    1066    :
								($_ <= 10000)    ?    791    :
								($_ <= 12000)    ?    756    :
								($_ <= 14000)    ?    619    :
								($_ <= 16000)    ?    584    :
								($_ <= 18000)    ?    516    :
								250
							}
						}
					} elsif ($in->{'fuel_source'} eq 'gas') { 
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1077    :
								($_ <= 4000)    ?    1002    :
								($_ <= 6000)    ?    886    :
								($_ <= 8000)    ?    771    :
								($_ <= 10000)    ?    655    :
								($_ <= 12000)    ?    597    :
								($_ <= 14000)    ?    540    :
								($_ <= 16000)    ?    482    :
								($_ <= 18000)    ?    397    :
								318;
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1577    :
								($_ <= 4000)    ?    1502    :
								($_ <= 6000)    ?    1386    :
								($_ <= 8000)    ?    1271    :
								($_ <= 10000)    ?    1155    :
								($_ <= 12000)    ?    1097    :
								($_ <= 14000)    ?    1040    :
								($_ <= 16000)    ?    982    :
								($_ <= 18000)    ?    866    :
								693;
							}
						}
					}
				} elsif ($in->{'family_size'} >= 4) {
					if ($in->{'fuel_source'} eq 'electric') {
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								 ($_ <= 2000)    ?    894    :
								($_ <= 4000)    ?    828    :
								($_ <= 6000)    ?    750    :
								($_ <= 8000)    ?    711    :
								($_ <= 10000)    ?    398    :
								($_ <= 12000)    ?    359    :
								($_ <= 14000)    ?    250    :
								($_ <= 16000)    ?    250    :
								($_ <= 18000)    ?    250    :
								250;
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								 ($_ <= 2000)    ?    1394    :
								($_ <= 4000)    ?    1328    :
								($_ <= 6000)    ?    1250    :
								($_ <= 8000)    ?    1211    :
								($_ <= 10000)    ?    898    :
								($_ <= 12000)    ?    859    :
								($_ <= 14000)    ?    703    :
								($_ <= 16000)    ?    664    :
								($_ <= 18000)    ?    586    :
								273;
							}
						}
					} elsif ($in->{'fuel_source'} eq 'gas') { 
						if ($sfa == 1) {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1300    :
								($_ <= 4000)    ?    1288    :
								($_ <= 6000)    ?    1150    :
								($_ <= 8000)    ?    1013    :
								($_ <= 10000)    ?    875    :
								($_ <= 12000)    ?    806    :
								($_ <= 14000)    ?    738    :
								($_ <= 16000)    ?    669    :
								($_ <= 18000)    ?    531    :
								378;
							}
						} else {
							for ($liheap_inc) {
								$max_liheap_benefit = 
								($_ <= 2000)    ?    1800    :
								($_ <= 4000)    ?    1788    :
								($_ <= 6000)    ?    1650    :
								($_ <= 8000)    ?    1513    :
								($_ <= 10000)    ?    1375    :
								($_ <= 12000)    ?    1306    :
								($_ <= 14000)    ?    1238    :
								($_ <= 16000)    ?    1169    :
								($_ <= 18000)    ?    1031    :
								825;
							}
						}
					}
				}
			}
			# For home-in-rent and oil, the max benefit is the same regardless of family size and income:
			if ($in->{'heat_in_rent'} == 1 && $in->{'energy_cost_override'} == 0) { #This is for HIR fuel_source. 
				$max_liheap_benefit = 250;
			} elsif ($in->{'fuel_source'} eq 'oil') { #This is for oil fuel_source. 
				$max_liheap_benefit = 1500; # [AK edit - this is where we have that issue with "Benefit, but pay vendor Gas". Stll need to determine how we address this. THis is for people who pay oil heat but gas or electric as well.]
			}

			# CALCULATING THE PRE-LIHEAP, PRE-DISCOUNT UTILTIY COSTS:

			if ($in->{'energy_cost_override'} == 1) {
				$utility_base_m = $in->{'energy_cost_override_amt'};
			} else {
				#We use the natural average gas cost as the baseline energy cost, absent an override.
				$utility_base_m =  $out->{'average_naturalgas_cost'};
			}
			
			#5. CALCULATE ANNUAL UTILTY DISCOUNTS (MAYBE)
			# In the 2017 FRS, we included savings generated through DC's Utility Discount Programs (UDP), including the Residential Aid Program (RAD) and the Residential Essential Service (RES) program. While these generate some savings on electric bills, the savings are fairly nominal -- according to https://doee.dc.gov/sites/default/files/dc/sites/ddoe/publication/attachments/UPD-brochure.pdf, the maximum RES savings is $189 and the approximate RAD savings is $102. The RAD savings are income-determined. While $291 over the course of a year can be important, it does not seem to add significant functionality to the calculator and would require additional questions (participation flags). So tentatively, these are being left out. Some sample codign for how these could be incorporated is left in, however.
			# The link https://dcpsc.org/Consumers-Corner/Programs/Low-Income-Discount-Program.aspx is very helpful in terms of documents for the RES program. 
			# Also add these flags at the beginning -- need either big udp flag, or separate rad and res lags. For ASPE calculator, maybe all 4, or just udp in step 4 and q's about all 4 depending on heat type at the end. These are programs we shoud make people aware of. 
			#if ($in->{'fuel_source'} eq 'electric')  {
			#	#the average reduction of RAD is 25% reduction of electric bill
			#	$utility_base = 12 * ((1 - .25) * $utility_base_m);
			#} elsif ($in->{'fuel_source'} eq 'gas')  {
			#	#the average reduction of RES is 25% reduction of gas bill, but only from November through April.
			#	$utility_base = 6 * $utility_base_m + 6 * (1 - .25) *$utility_base_m;
			#} else {
			$utility_base = 12 * $utility_base_m;
			#}

			#$udp_recd = 12 * $utility_base_m - $utility_base;
			
			$out->{'rent_paid'} = &pos_sub($out->{'rent_paid'}, $udp_recd); 
			
			#6: Calculate LIHEAP benefits:

			$liheap_recd = &least($max_liheap_benefit, $utility_base);
			$liheap_rent = &pos_sub($out->{'rent_paid'}, $liheap_recd);
			our $rent_paid = $liheap_rent; #We're redefining the rent_paid output variable here to include LIHEAP reductions. 
		}
	}	

	# Note about the CRIAC fee (which can be a water-related expense of about $20/month) as well as CAP, which is a reduction on that expense:
	# See 2019 UDP flyer for DC here: https://www.opc-dc.gov/images/pdf/UDPflyer2019.pdf, and CAP program here: https://www.dcwater.com/customer-assistance. The CAP program both provides a discount for water charges and reduces the CRIAC fee for low or middle income households, depending on household size and income. People do not seem to pay the CRIAC fee if they don't pay for water, and CRIAC is a fee added to water bills: https://ourcommunitynow.com/news/dc-water-bill-breaks-may-be-in-sight-heres-how-to-see-if-youre-eligible. See also https://www.dcwater.com/impervious-area-charge. More info and analysis at https://static1.squarespace.com/static/5bbd09f3d74562c7f0e4bb10/t/5c94076da4222f0bb1fd468e/1553205103383/Keeping+CRIAC+Affordable+and+Equitable..pdf. While we are simplifying the energy calculations in this to only include heat and electric, we are allowing users to override this estimation with their own costs, which could include water bills.  https://www.dcwater.com/rates-and-metering

	#Solar for All note:
	# Could include SFA reductions for participating families. This seems like it could be a huge reduction for families that use electric heat, and a small benefit largely canceled out by reductions in LIHEAP amount among families that use other forms of heat. Since electric alone is not a utiltiy that has a separate allowance (the electricoroil add on is for electric or oil heat, we'll have to chunk out part of the heat estimates to chalk it to electricity. Seems like the SFA literature and the LIHEAP code provide an estimate that electric costs $500 a year on its own, separate from other forms of heat. Need to also take a closer look at how these different calculations should be used for estimating RAD and RES benefits. 
	# For SFA, could include sec8-like clause that checks if they are already getting SFA, and to provide them that into perpetuity, assuming that once you get it, you have it for 15 years even if you no longer qualify based on income.
	# See more information here: https://www.dcseu.com/solar-for-all#get-started%20to%20apply
	# Please confirm this how you receive the benefit - through reduced electricity bill for homeowners, for participants in the community solar program it is based on solar facility output x subscription percentage x Pepco Residential CNM credit rate (see page 3 of this document for credit calculations: https://doee.dc.gov/sites/default/files/dc/sites/ddoe/service_content/attachments/Solar%20for%20all%20applicationFeb19.pdf)
	# Can you confirm that solar panels (and associated reduction in electricity bills) remain even if income exceeds income limit in subsequent years.
	# If you're no longer income eligible, but have panels, do you no longer receive maintenance?
	# So judging from the benefit matrix reductions in LIHEAP from SFA participation, with those reductions approximately equal to the expected reductions in electric bills that SFA provides, the program provides a tangible benefit to people who live in single-family houses who are income eligible for it only if they spend a lot more on electricity than the estimates indicates?
	# Multi-family households who are renters can participate in Community solar. Credit you receive is based on prescription percentage. So there's a reduction in their electric bill, based on their subscription percentage, of approximately 50%.
	#

	
	#debugging
	foreach my $debug (qw(liheap_inc liheap_smi liheap_inc_m liheap_recd utility_base_m utility_base liheap_rent max_liheap_benefit rent_paid)) { 
		print $debug.": ".${$debug}."\n";
	}

	# outputs
	foreach my $name (qw(liheap_recd rent_paid rent_paid_m)) {
		$out->{$name} = ${$name};
	}

}
	
1;