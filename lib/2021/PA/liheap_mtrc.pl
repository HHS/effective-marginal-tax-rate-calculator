#=============================================================================#
#  LIHEAP Module – PA 2021 
#=============================================================================#
# From:
# http://services.dpw.state.pa.us/oimpolicymanuals/liheap/LIHEAP_Handbook.htm
# and
# https://www.humanservices.state.pa.us/LIHEAP_BENEFIT_TABLE/
# and
# https://www.dhs.pa.gov/Services/Assistance/Documents/Heating%20Assistance_LIHEAP/State%20Plan%2020-21.pdf
#
#	LIHEAP in Pennsvlvania is offered via either a single "cash grant" to help pay the costs of home heating, a Crisis grant to help with emergencies, and Weatherization grants. This code will only cover the Cash grant portion.

# INPUTS AND OUTPUTS NEEDED FOR THIS SCRIPT TO RUN:

# INPUTS FROM USER INTERFACE:
#	liheap
#	parent#_age
#  	heat_fuel_source
#	cooking_fuel_source	
#	family_size 
#
# INPUTS FROM FRS.PM
#	parent#_selfemployed_netprofit
#	unearn_gross_mon_inc_amt_ag
#	fpl
#
# OUTPUTS FROM PARENT_EARNINGS:
# 	earnings_mnth
#
# OUTPUTS FROM INTEREST:
#   interest
#
# OUTPUTS FROM SEC 8:
# 	housing_subsidized
#  	rent_paid
#	rent_paid_m 
#
# OUTPUTS FROM SSI:
#  	ssi_recd_m
#
# OUTPUTS FROM TANF
#  	tanf_recd_m	
#	child_support_recd_m
#
# OUTPUTS FROM FSP_ASSETS
#	heating_cost_pha
#	electric_cost_pha
#	cooking_cost_pha
# OUTPUTS FROM UNEMPLOYMENT
#	ui_recd_m
#	ui_recd
#=============================================================================#
sub liheap
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# outputs created
	our $liheap_recd = 0;				# annual value of LIHEAP received

	# other variables used
	our $liheap_income_limit= qw(0 19140 25860 32580 39300 46020 52740 59460 66180 72900 79620) [$in->{'family_size'}]; #2020-21 LIHEAP income limits, the latest available.
	our $interest_disregard = 25; #The dollar amount of interest or dividend income disregarded from income.
	our $income_deduction = .2; # 20% of wage income can be deducted from income to determine benefits if the family is eligible for LIHEAP. (650.5)
	our $alimony_exclusion = 50;
	our $child_support_exlusion_perchild = 100;
	our $child_support_exclusion_max = 200;

	#Defined in macro:
	our $self_employment_inome_total_m = 0;
	our $liheap_income_m = 0;		# monthly countable income for LIHEAP eligibility and benefit level calculations. FAP income counts the following as income to determine eligibility and benefit levels for fap: alimony, annuity payments, chil support, dividends over $50, pensions, interest over $50/yr, insurance payments, rental income, salaries and money wages before deductions, social security, SSI (except for minor disabled children), state welfare payments, and unemployment, among others.
	our $liheap_income = 0;	    #annual countable income for determining LIHEAP benefit
	our $liheap_total_income = 0;	    #annual countable income for liheap eligibility
	our $liheap_total_income_m = 0;	    #monthly countable income for liheap eligibility
	our $electric_bill_m = 0;
	our	$countable_interest_m = 0;		# annual interest counted as income - only interest over $25/yr
	our $rent_paid = $out->{'rent_paid'};	#We'll be adjusting this output here.
	our $rent_paid_m = $out->{'rent_paid_m'};	#We'll be adjusting this output here.
	# LIHEAP benefits are modeled as reduction in rent costs because the Fair Market Rents include utilities and liheap benefits are paid directly to utility companies. LIHEAP is a federal block grant to states. (It is not an entitlement program). The amount of benefit depends of household size, income, type of unit (multi-family or single family), and fuel source. 
	our $liheap_static_unearned_income = 0;
	our	$heat_bill_m = 0;
	our	$heatandelectric_cost_m = 0;
    our $liheap_unearned_income_m = 0;	#monthly unearned income that is counted for fap eligibility and benefit calculation: social security, tanf, child support, interest over $50/yr, ssi, among others, listed on page 13 of FAP procedures manual
	our $support_exclusion = 0;
	our $liheap_minimum_benefit = 200; #For families who are eligible for LIHEAP based on income, they receive at least the minimum LIHEAP benefit. This is not clear from the benefit tables, but has been clarified by Allegheny DHS.

		  

	#Beginning in 2021 -- with the MTRC -- we are separating heating and energy as utilities separate from rent.
	#

	if($in->{'liheap'} == 1 && $out->{'housing_recd'} == 0) { # && $in->{'heat_in_rent'} == 0: commenting this out because it appears that if you pay for heat indirectrly through your rent bill, you are still eligible for LIHEAP. See 605.12 of the LIHEAP manual. But changed to exclude anyone who lives in subsized housing, as per Section 610.2 of the LIHEAP handbook.
		#In PA, all household members's income is counted.

		#
		# 
		#
		# 

		# 2. Calculating gross income according to LIHEAP rules.
		#
		# Since both programs are operated by the same agency and the EAP program does not appear to publish a clear indication of what counts as "gross income," we can assume they count different types of income the same way. Also the FY 2020 LIHEAP state plan indicates "The CAAs will also take an Electric Assistance Program (EAP) application in coordination with FAP and WAP as EAP uses mostly the same eligibility requirements, although it is a separate application." LIHEAP has a very specific accounting of what counts as income.
		#
		# Organizing non-disregarded income:
		$liheap_static_unearned_income = $in->{'unearn_gross_mon_inc_amt_ag'}; #This is set to 0 in the frs.pm module.
		#For a very advanced tool, we could go through these one by one and see if there are any differences between what's counted as underaned income for LIHEAP compared to unearned income for other programs, but any differences seem nominal or rare based on our reading.

		#Adjusting for interest:
		# The first $25 of interest and dividends, and other returns on investments is disregarded.
		
		$countable_interest_m = (pos_sub($out->{'interest'}, $interest_disregard))/12; 
		
		
		#Combining other types of unearned income:
		$liheap_unearned_income_m = $liheap_static_unearned_income + $countable_interest_m + $out->{'gift_income_m'} + $out->{'ssi_recd_mnth'} + $out->{'tanf_recd_m'} + $out->{'ui_recd_m'}; 
		
		#Child support (from "Income Exclusions"):
		#(15) For actual child support received, whether court-ordered support or voluntary support from a legally responsible relative, up to the first $100 will be excluded in determining household income if there is one child under age 18 in the household. If there are two or more children in the household, up to $200 will be excluded. Also, up to the first $50 of actual spousal support received in a given month will be excluded. If a household receives both child support and spousal support, only the amount which is the greatest will be excluded for that month; the household will not receive both a child support and spousal support deduction in the same month. All support refunded by DHS during the month is excluded.


		if ($out->{'child_support_recd_m'} + $in->{'alimony_paid_m'} > 0) {
			$support_exclusion = &greatest(&least($in->{'alimony_paid_m'},$alimony_exclusion), &least($out->{'child_support_recd_m'}, $child_support_exlusion_perchild * $in->{'child_number'}, $child_support_exclusion_max));
			$liheap_unearned_income_m +=  pos_sub($out->{'child_support_recd_m'} + $in->{'alimony_paid_m'}, $support_exclusion);
		}
		#NOTES: NEED TO REMOVE CHILD SSI RECEIVED AFTER INCORPORATING THAT CODE IN, BASED ON THOSE VARIABLES.		
		
		#Self-employment income needs to be tallied:
		$self_employment_inome_total_m = 0;
		for(my $i=1; $i<=4; $i++) {
			if($in->{'parent' . $i . '_age'} > 0) {
				$self_employment_inome_total_m += ($in->{'parent'.$i.'_selfemployed_netprofit'})/12;
			}
		}

		#NOTE: Income from renters is included in Countable Earned Income. 
		$liheap_total_income_m = $out->{'earnings_mnth'} + $self_employment_inome_total_m + $liheap_unearned_income_m; 
		$liheap_total_income = $liheap_total_income_m*12;
		#$liheap_poverty_level = 12 * $liheap_income_m / $in->{'fpl'};
				

		# 5. DETERMINE LIHEAP ELIGIBILITY AND BENEFITS:
		#
		# LIHEAP applies to all energy types. 
		#
		if ($liheap_total_income  <= $liheap_income_limit) {
			$liheap_income = pos_sub($liheap_total_income, $income_deduction * $out->{'earnings_mnth'});
		

			# We use the LIHEAP benefit matrix to determine discount. We will apply the reduction to this discount for natural gas and electric clients afteward.			
			
			if ($in->{'heat_fuel_source'} eq 'electric') {		
				if ($liheap_income <= 999) {	
					$liheap_recd = qw(0  853 863 874 884 895 905 916 926 937 947 958) [$in->{'family_size'}];
				} elsif ($liheap_income <= 1999) {	
					$liheap_recd = qw(0  772 781 791 800 810 819 829 838 848 857 867) [$in->{'family_size'}];
				} elsif ($liheap_income <= 2999) {	
					$liheap_recd = qw(0  711 720 728 737 746 755 763 772 781 790 798) [$in->{'family_size'}];
				} elsif ($liheap_income <= 3999) {	
					$liheap_recd = qw(0  569 576 583 590 597 604 611 618 625 632 639) [$in->{'family_size'}];
				} elsif ($liheap_income <= 4999) {	
					$liheap_recd = qw(0  508 514 520 526 533 539 545 551 558 564 570) [$in->{'family_size'}];
				} elsif ($liheap_income <= 5999) {	
					$liheap_recd = qw(0  406 411 416 421 426 431 436 441 446 451 456) [$in->{'family_size'}];
				} elsif ($liheap_income <= 6999) {	
					$liheap_recd = qw(0  354 359 363 368 372 376 381 385 389 394 398) [$in->{'family_size'}];
				} elsif ($liheap_income <= 7999) {	
					$liheap_recd = qw(0  309 313 317 321 325 328 332 336 340 344 347) [$in->{'family_size'}];
				} elsif ($liheap_income <= 8999) {	
					$liheap_recd = qw(0  270 273 277 280 283 287 290 293 297 300 303) [$in->{'family_size'}];
				} elsif ($liheap_income <= 9999) {	
					$liheap_recd = qw(0  236 238 241 244 247 250 253 256 259 262 265) [$in->{'family_size'}];
				} elsif ($liheap_income <= 10999) {	
					$liheap_recd = qw(0  206 208 211 213 216 218 221 223 226 228 231) [$in->{'family_size'}];
				} elsif ($liheap_income <= 11999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 201) [$in->{'family_size'}];
				} elsif ($liheap_income <= 12999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 13999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 14999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 15999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 16999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 17999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 18999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 19999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 20999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 21999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 22999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} else {
					$liheap_recd = $liheap_minimum_benefit;
				}
			} elsif ($in->{'heat_fuel_source'} eq 'fuel_oil') {		
				if ($liheap_income <= 999) {	
					$liheap_recd = qw(0  1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000) [$in->{'family_size'}];
				} elsif ($liheap_income <= 1999) {	
					$liheap_recd = qw(0  1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000) [$in->{'family_size'}];
				} elsif ($liheap_income <= 2999) {	
					$liheap_recd = qw(0  1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000) [$in->{'family_size'}];
				} elsif ($liheap_income <= 3999) {	
					$liheap_recd = qw(0  832 839 846 853 860 867 874 881 888 895 902) [$in->{'family_size'}];
				} elsif ($liheap_income <= 4999) {	
					$liheap_recd = qw(0  743 749 755 761 768 774 780 786 793 799 805) [$in->{'family_size'}];
				} elsif ($liheap_income <= 5999) {	
					$liheap_recd = qw(0  594 599 604 609 614 619 624 629 634 639 644) [$in->{'family_size'}];
				} elsif ($liheap_income <= 6999) {	
					$liheap_recd = qw(0  518 523 527 532 536 540 545 549 553 558 562) [$in->{'family_size'}];
				} elsif ($liheap_income <= 7999) {	
					$liheap_recd = qw(0  452 456 460 464 468 472 475 479 483 487 491) [$in->{'family_size'}];
				} elsif ($liheap_income <= 8999) {	
					$liheap_recd = qw(0  395 398 401 405 408 411 415 418 421 425 428) [$in->{'family_size'}];
				} elsif ($liheap_income <= 9999) {	
					$liheap_recd = qw(0  345 347 350 353 356 359 362 365 368 371 374) [$in->{'family_size'}];
				} elsif ($liheap_income <= 10999) {	
					$liheap_recd = qw(0  301 303 306 308 311 313 316 318 321 323 326) [$in->{'family_size'}];
				} elsif ($liheap_income <= 11999) {	
					$liheap_recd = qw(0  262 265 267 269 271 273 276 278 280 282 284) [$in->{'family_size'}];
				} elsif ($liheap_income <= 12999) {	
					$liheap_recd = qw(0  229 231 233 235 237 239 241 243 244 246 248) [$in->{'family_size'}];
				} elsif ($liheap_income <= 13999) {	
					$liheap_recd = qw(0  200 202 203 205 207 208 210 212 213 215 217) [$in->{'family_size'}];
				} elsif ($liheap_income <= 14999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 15999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 16999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 17999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 18999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 19999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 20999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 21999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 22999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} else {
					$liheap_recd = $liheap_minimum_benefit;
				}	
			} elsif ($in->{'heat_fuel_source'} eq 'coal') {		
				if ($liheap_income <= 999) {	
					$liheap_recd = qw(0  518 529 539 550 560 571 581 592 602 613 623) [$in->{'family_size'}];
				} elsif ($liheap_income <= 1999) {	
					$liheap_recd = qw(0  469 478 488 497 507 516 526 535 545 554 564) [$in->{'family_size'}];
				} elsif ($liheap_income <= 2999) {	
					$liheap_recd = qw(0  432 440 449 458 467 475 484 493 502 510 519) [$in->{'family_size'}];
				} elsif ($liheap_income <= 3999) {	
					$liheap_recd = qw(0  345 352 359 366 373 380 387 394 401 408 415) [$in->{'family_size'}];
				} elsif ($liheap_income <= 4999) {	
					$liheap_recd = qw(0  308 315 321 327 333 340 346 352 358 365 371) [$in->{'family_size'}];
				} elsif ($liheap_income <= 5999) {	
					$liheap_recd = qw(0  247 252 257 262 267 272 277 282 287 292 297) [$in->{'family_size'}];
				} elsif ($liheap_income <= 6999) {	
					$liheap_recd = qw(0  215 220 224 228 233 237 241 246 250 255 259) [$in->{'family_size'}];
				} elsif ($liheap_income <= 7999) {	
					$liheap_recd = qw(0  200 200 200 200 203 207 211 215 218 222 226) [$in->{'family_size'}];
				} elsif ($liheap_income <= 8999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 9999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 10999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 11999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 12999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 13999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 14999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 15999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 16999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 17999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 18999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 19999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 20999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 21999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 22999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} else {
					$liheap_recd = $liheap_minimum_benefit;
				}	
			} elsif ($in->{'heat_fuel_source'} eq 'natural_gas') {		
				if ($liheap_income <= 999) {	
					$liheap_recd = qw(0  782 793 803 814 824 835 845 856 866 877 887) [$in->{'family_size'}];
				} elsif ($liheap_income <= 1999) {	
					$liheap_recd = qw(0  708 717 727 736 746 755 765 774 784 793 803) [$in->{'family_size'}];
				} elsif ($liheap_income <= 2999) {	
					$liheap_recd = qw(0  652 661 669 678 687 696 704 713 722 731 739) [$in->{'family_size'}];
				} elsif ($liheap_income <= 3999) {	
					$liheap_recd = qw(0  522 529 536 543 550 557 564 571 578 585 592) [$in->{'family_size'}];
				} elsif ($liheap_income <= 4999) {	
					$liheap_recd = qw(0  466 472 478 484 491 497 503 509 516 522 528) [$in->{'family_size'}];
				} elsif ($liheap_income <= 5999) {	
					$liheap_recd = qw(0  373 378 383 388 393 398 403 408 413 418 423) [$in->{'family_size'}];
				} elsif ($liheap_income <= 6999) {	
					$liheap_recd = qw(0  325 329 334 338 343 347 351 356 360 364 369) [$in->{'family_size'}];
				} elsif ($liheap_income <= 7999) {	
					$liheap_recd = qw(0  284 288 291 295 299 303 307 310 314 318 322) [$in->{'family_size'}];
				} elsif ($liheap_income <= 8999) {	
					$liheap_recd = qw(0  248 251 254 258 261 264 268 271 274 278 281) [$in->{'family_size'}];
				} elsif ($liheap_income <= 9999) {	
					$liheap_recd = qw(0  216 219 222 225 228 231 233 236 239 242 245) [$in->{'family_size'}];
				} elsif ($liheap_income <= 10999) {	
					$liheap_recd = qw(0  200 200 200 200 200 201 204 206 209 211 214) [$in->{'family_size'}];
				} elsif ($liheap_income <= 11999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 12999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 13999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 14999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 15999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 16999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 17999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 18999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 19999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 20999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 21999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 22999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} else {
					$liheap_recd = $liheap_minimum_benefit;
				}	
			} elsif ($in->{'heat_fuel_source'} eq 'kerosene') {		
				if ($liheap_income <= 999) {	
					$liheap_recd = qw(0  1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000) [$in->{'family_size'}];
				} elsif ($liheap_income <= 1999) {	
					$liheap_recd = qw(0  1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000) [$in->{'family_size'}];
				} elsif ($liheap_income <= 2999) {	
					$liheap_recd = qw(0  1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000) [$in->{'family_size'}];
				} elsif ($liheap_income <= 3999) {	
					$liheap_recd = qw(0  850 857 864 871 878 885 892 899 906 913 920) [$in->{'family_size'}];
				} elsif ($liheap_income <= 4999) {	
					$liheap_recd = qw(0  759 766 772 778 784 791 797 803 809 816 822) [$in->{'family_size'}];
				} elsif ($liheap_income <= 5999) {	
					$liheap_recd = qw(0  607 612 617 622 627 632 637 642 647 652 657) [$in->{'family_size'}];
				} elsif ($liheap_income <= 6999) {	
					$liheap_recd = qw(0  530 534 539 543 548 552 556 561 565 569 574) [$in->{'family_size'}];
				} elsif ($liheap_income <= 7999) {	
					$liheap_recd = qw(0  463 466 470 474 478 482 485 489 493 497 501) [$in->{'family_size'}];
				} elsif ($liheap_income <= 8999) {	
					$liheap_recd = qw(0  404 407 410 414 417 420 424 427 430 434 437) [$in->{'family_size'}];
				} elsif ($liheap_income <= 9999) {	
					$liheap_recd = qw(0  352 355 358 361 364 367 370 373 376 378 381) [$in->{'family_size'}];
				} elsif ($liheap_income <= 10999) {	
					$liheap_recd = qw(0  307 310 312 315 318 320 323 325 328 330 333) [$in->{'family_size'}];
				} elsif ($liheap_income <= 11999) {	
					$liheap_recd = qw(0  268 271 273 275 277 279 282 284 286 288 290) [$in->{'family_size'}];
				} elsif ($liheap_income <= 12999) {	
					$liheap_recd = qw(0  234 236 238 240 242 244 246 248 250 252 253) [$in->{'family_size'}];
				} elsif ($liheap_income <= 13999) {	
					$liheap_recd = qw(0  204 206 208 209 211 213 214 216 218 219 221) [$in->{'family_size'}];
				} elsif ($liheap_income <= 14999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 15999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 16999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 17999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 18999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 19999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 20999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 21999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 22999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} else {
					$liheap_recd = $liheap_minimum_benefit;
				}	
			} elsif ($in->{'heat_fuel_source'} eq 'bottle_gas') { #This is propane 		
				if ($liheap_income <= 999) {	
					$liheap_recd = qw(0  853 863 874 884 895 905 916 926 937 947 958) [$in->{'family_size'}];
				} elsif ($liheap_income <= 1999) {	
					$liheap_recd = qw(0  772 781 791 800 810 819 829 838 848 857 867) [$in->{'family_size'}];
				} elsif ($liheap_income <= 2999) {	
					$liheap_recd = qw(0  711 720 728 737 746 755 763 772 781 790 798) [$in->{'family_size'}];
				} elsif ($liheap_income <= 3999) {	
					$liheap_recd = qw(0  569 576 583 590 597 604 611 618 625 632 639) [$in->{'family_size'}];
				} elsif ($liheap_income <= 4999) {	
					$liheap_recd = qw(0  508 514 520 526 533 539 545 551 558 564 570) [$in->{'family_size'}];
				} elsif ($liheap_income <= 5999) {	
					$liheap_recd = qw(0  406 411 416 421 426 431 436 441 446 451 456) [$in->{'family_size'}];
				} elsif ($liheap_income <= 6999) {	
					$liheap_recd = qw(0  354 359 363 368 372 376 381 385 389 394 398) [$in->{'family_size'}];
				} elsif ($liheap_income <= 7999) {	
					$liheap_recd = qw(0  309 313 317 321 325 328 332 336 340 344 347) [$in->{'family_size'}];
				} elsif ($liheap_income <= 8999) {	
					$liheap_recd = qw(0  270 273 277 280 283 287 290 293 297 300 303) [$in->{'family_size'}];
				} elsif ($liheap_income <= 9999) {	
					$liheap_recd = qw(0  236 238 241 244 247 250 253 256 259 262 265) [$in->{'family_size'}];
				} elsif ($liheap_income <= 10999) {	
					$liheap_recd = qw(0  206 208 211 213 216 218 221 223 226 228 231) [$in->{'family_size'}];
				} elsif ($liheap_income <= 11999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 201) [$in->{'family_size'}];
				} elsif ($liheap_income <= 12999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 13999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 14999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 15999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 16999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 17999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 18999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 19999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 20999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 21999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 22999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} else {
					$liheap_recd = $liheap_minimum_benefit;
				}	
			} elsif ($in->{'heat_fuel_source'} eq 'wood') {		
				if ($liheap_income <= 999) {	
					$liheap_recd = qw(0  865 876 886 897 907 918 928 939 949 960 970) [$in->{'family_size'}];
				} elsif ($liheap_income <= 1999) {	
					$liheap_recd = qw(0  783 792 802 811 821 830 840 849 859 868 878) [$in->{'family_size'}];
				} elsif ($liheap_income <= 2999) {	
					$liheap_recd = qw(0  721 730 739 747 756 765 774 782 791 800 809) [$in->{'family_size'}];
				} elsif ($liheap_income <= 3999) {	
					$liheap_recd = qw(0  577 584 591 598 605 612 619 626 633 640 647) [$in->{'family_size'}];
				} elsif ($liheap_income <= 4999) {	
					$liheap_recd = qw(0  515 521 528 534 540 546 553 559 565 571 578) [$in->{'family_size'}];
				} elsif ($liheap_income <= 5999) {	
					$liheap_recd = qw(0  412 417 422 427 432 437 442 447 452 457 462) [$in->{'family_size'}];
				} elsif ($liheap_income <= 6999) {	
					$liheap_recd = qw(0  360 364 368 373 377 381 386 390 394 399 403) [$in->{'family_size'}];
				} elsif ($liheap_income <= 7999) {	
					$liheap_recd = qw(0  314 318 321 325 329 333 337 340 344 348 352) [$in->{'family_size'}];
				} elsif ($liheap_income <= 8999) {	
					$liheap_recd = qw(0  274 277 280 284 287 290 294 297 300 304 307) [$in->{'family_size'}];
				} elsif ($liheap_income <= 9999) {	
					$liheap_recd = qw(0  239 242 245 248 251 253 256 259 262 265 268) [$in->{'family_size'}];
				} elsif ($liheap_income <= 10999) {	
					$liheap_recd = qw(0  209 211 214 216 219 221 224 226 229 231 234) [$in->{'family_size'}];
				} elsif ($liheap_income <= 11999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 202 204) [$in->{'family_size'}];
				} elsif ($liheap_income <= 12999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 13999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 14999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 15999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 16999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 17999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 18999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 19999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 20999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 21999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 22999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} else {
					$liheap_recd = $liheap_minimum_benefit;
				}	
			} elsif ($in->{'heat_fuel_source'} eq 'blended_fuel') {		
				if ($liheap_income <= 999) {	
					$liheap_recd = qw(0  1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000) [$in->{'family_size'}];
				} elsif ($liheap_income <= 1999) {	
					$liheap_recd = qw(0  1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000) [$in->{'family_size'}];
				} elsif ($liheap_income <= 2999) {	
					$liheap_recd = qw(0  1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 1000) [$in->{'family_size'}];
				} elsif ($liheap_income <= 3999) {	
					$liheap_recd = qw(0  841 848 855 862 869 876 883 890 897 904 911) [$in->{'family_size'}];
				} elsif ($liheap_income <= 4999) {	
					$liheap_recd = qw(0  751 757 764 770 776 782 789 795 801 807 814) [$in->{'family_size'}];
				} elsif ($liheap_income <= 5999) {	
					$liheap_recd = qw(0  601 606 611 616 621 626 631 636 641 646 651) [$in->{'family_size'}];
				} elsif ($liheap_income <= 6999) {	
					$liheap_recd = qw(0  524 529 533 537 542 546 551 555 559 564 568) [$in->{'family_size'}];
				} elsif ($liheap_income <= 7999) {	
					$liheap_recd = qw(0  458 461 465 469 473 477 480 484 488 492 496) [$in->{'family_size'}];
				} elsif ($liheap_income <= 8999) {	
					$liheap_recd = qw(0  399 403 406 409 413 416 419 423 426 429 433) [$in->{'family_size'}];
				} elsif ($liheap_income <= 9999) {	
					$liheap_recd = qw(0  348 351 354 357 360 363 366 369 372 375 377) [$in->{'family_size'}];
				} elsif ($liheap_income <= 10999) {	
					$liheap_recd = qw(0  304 307 309 312 314 317 319 322 324 327 329) [$in->{'family_size'}];
				} elsif ($liheap_income <= 11999) {	
					$liheap_recd = qw(0  265 268 270 272 274 276 279 281 283 285 287) [$in->{'family_size'}];
				} elsif ($liheap_income <= 12999) {	
					$liheap_recd = qw(0  232 234 235 237 239 241 243 245 247 249 251) [$in->{'family_size'}];
				} elsif ($liheap_income <= 13999) {	
					$liheap_recd = qw(0  202 204 205 207 209 211 212 214 216 217 219) [$in->{'family_size'}];
				} elsif ($liheap_income <= 14999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 15999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 16999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 17999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 18999) {	
					$liheap_recd = qw(0  200 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 19999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 20999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 21999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} elsif ($liheap_income <= 22999) {	
					$liheap_recd = qw(0  0 200 200 200 200 200 200 200 200 200 200) [$in->{'family_size'}];
				} else {
					$liheap_recd = $liheap_minimum_benefit;
				}	
			} else {
				$liheap_recd = 0;
			}
						
			# We now subtract the minimum between heating costs and the max liheap benefit.

			#We use the natural average gas cost as the baseline energy cost, absent an override.
			
			$liheap_recd = least($out->{'average_naturalgas_cost'} * 12, $liheap_recd);
		}
	}	

	if ($in->{'heat_in_rent'} == 1 && $in->{'energy_cost_override'} == 0) {
		$electric_bill_m = 0;
		$heat_bill_m = 0;
		$heatandelectric_cost_m = 0;
	} else {
		if ($in->{'energy_cost_override'} == 1) { # This also means that the user has overriden the rent cost.
			#In this case, we do the same operation we do elsewhere with subsidized expenses -- first add back the subsidized expense for the "current" scenario to find the baseline expenses, and then subtract any benefits from that for the ultimate cost.
			if ($out->{'scenario'} eq 'current') {
				$in->{'imputed_energycost_total'} = $in->{'energy_cost_override_amt'} + ($liheap_recd)/12;
			}
			$heatandelectric_cost_m = $in->{'imputed_energycost_total'};
		} else {
			$electric_bill_m = $out->{'average_electric_cost'};			
			if ($in->{'heat_fuel_source'} eq 'electric') {
				$electric_bill_m += $out->{'average_naturalgas_cost'};
			} else {
				$heat_bill_m = $out->{'average_naturalgas_cost'};
			}
			$heatandelectric_cost_m = $electric_bill_m + $heat_bill_m;
		}
	}

	$heatandelectric_paid = pos_sub($heatandelectric_cost_m * 12, $liheap_recd);
	$heatandelectric_paid_m = $heatandelectric_paid /12;	
	
	#Rather than break this out into a separate "Heat and electric" cost, we build it into rent. Separating the two out is problematic for users who do not override rent costs, because FMR's build utility costs like heating and energy into their estimates.
	if ($in->{'housing_override'} == 1) {
		#For a user who has entered in their own rent cost, we assume that they are entering rent independent of utilities. Therefore we add utility costs, inclusive of any reductions in those costs from LIHEAP or EAP.
		$rent_paid = $rent_paid + $heatandelectric_paid; 		
	} else {
		#For a user who has chosen to use the calculator's rent defaults, which are based on FMR's that include utility costs, we subctract any utility cost savings from rent.
		$rent_paid = pos_sub($rent_paid, 12 * pos_sub($heatandelectric_cost_m, $heatandelectric_paid_m)); 
	}
	$rent_paid_m = $rent_paid / 12;

	#debugging:
	foreach my $debug (qw(liheap_income liheap_recd rent_paid_m rent_paid liheap_unearned_income_m liheap_total_income liheap_income_limit self_employment_inome_total_m)) {
		print $debug.": ".${$debug}."\n";
	}

	# outputs
	foreach my $name (qw(liheap_recd rent_paid rent_paid_m heatandelectric_paid_m heatandelectric_paid)) {
       $out->{$name} = ${$name};
    }
	
}

1;