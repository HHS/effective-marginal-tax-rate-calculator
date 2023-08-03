#=============================================================================#
#  Food Stamp Asset Module -- PA 2021 
#=============================================================================#
#
# Inputs referenced in this module:
#	
#   INPUTS FROM USER 
#		child_number
#		family_structure
#		heat_fuel_source
#		cooking_fuel_source
#		home_type
#		residence
#
#=============================================================================#

sub fsp_assets
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# This subroutine can be considered to include the full array of potential state variations to the federal SNAP program.

	# outputs created
	our $fs_vehicle1 = 0;
	our $fs_vehicle2 = 0;
	our $bbce_gross_income_pct = 1.6;    # % of poverty used for SNAP gross income eligibility test. Last checked 5/20/21.
	our $bbce_no_asset_limit = 1;            	# “1” for a state that has no asset limit as part of its BBCE program. 
	our $sua_heat = 594; #Policy as of 10/1/2020
	our $sua_nonheat = 308; #This is the SUA for "utilities only". To avoid too many user questions, we are assuming that if a user selects that they are paying heat in rent but and they also fill in a nonzero utilities amount or a nonzero phone bill amount (or choose the calcaultor estimate of the phone bill), they are entitled to the "Utiltiies Only" SUA. 
	#Other SUAs: (policy as of 10/1/2020)
	our $sua_limited = 59; #This is the SUA for one  utility that is not a telephone expense.
	our $sua_phone = 33; #This is the allowance / SUA for homes that just incur telephone expenses but no other utilities.
	our $bbce_disability_no_asset_limit = 0; # Some states that have broad-based categorical eligibility (BBCE) policies do not exempt households that include people who are elderly or people with disabilities from federal asset limit at incomes higher than 200% of the poverty level. These families face no gross income limit based on federal policy, but do face asset limits. BBCE allows states to exempt the assets of these families at gross incomes below 200% of the federal poverty level and also allows states the choice of whether to use the federal standard for families above this level. PA chooses to use the federal asset limit at higher incomes. Other states like DC exempt assets for all applicant families; for these states, this variable would equal 1.
	our $bbce_asset_limit = 0;                  # For states that have a BBCE asset limit, this is where that would be.
	our $heatandeat_nominal_payment = 0;  # This relates to the nominal payment (using local funds) that all SNAP recipients can get in order to claim the standard utility allowance, similar to if they received LIHEAP. Including it in this SNAP-related subroutine allows us to run the SNAP subroutine prior to LIHEAP, which is helpful because SNAP receipt confers categorical eligibility for LIHEAP. The SNAP code checks if this is greater than the heat-and-eat minimum, and if it is, confer the full SUA on SNAP recipients. 
	#"To enhance participation and benefits for households enrolled in the Supplemental Nutrition Assistance Program (SNAP), DHS will continue to issue a heating assistance benefit to SNAP households that are responsible for heating costs and have not already been approved for LIHEAP during the current program year. SNAP applicants or recipients who are homeless or living in institutions are not eligible to receive the heating assistance benefit.
	#Per federal SNAP regulation, receipt of a heating assistance benefit, regardless of the amount of the benefit, enables SNAP recipients to maximize the SNAP Standard Utility Allowance (SUA). Households receiving the heating assistance benefit that are recipients of SNAP will receive the highest SNAP SUA. Using the highest allowable SUA in the SNAP benefit calculation may significantly increase SNAP benefits for many households. The annual heating assistance benefit will qualify the household for the maximum SNAP SUA for the current federal fiscal year." - PA LIHEAP State Plan 2021
	#

	our $optional_sua_policy = 0; # Some states require the use of state-determined SUA's in calculating the utilities portion of SNAP's excess shelter deduction (they have "Mandatory SUAs"), while other states allow SNAP recipients to claim higher utilities costs if they can provide evidence that these costs exceed SUAs (these states have "optional SUAs"). This variable indicates whether the state has optional SUAs, allowing SNAP recipients to claim hgiher utilities expenses than state SUAs. Most states, like PA, follow a policy of mandatory SUAs. See https://fns-prod.azureedge.net/sites/default/files/snap/14-State-Options.pdf and also state policy handbooks.
	our $average_electric_cost = 115.47; #from eia.gov
	our $average_naturalgas_cost = 977/12; #from aga.org.

	#Calculated in macro:
	our $sua_phoneandinternet_only = 0; #defined/derived below.
	our $sua_utilities_only = 0;	#We rename this to align the name above for PA with a common name we're using across states.
	our $pha_ua = 0; # Estimating or incorporating energy costs is important for estimating SNAP becuase we the fair market rents we use incorporate utilities, but SNAP calculations separate rent from utilities. So we need to separate rent from utilities here as well. These estimations vary by state but this variable is used in the upcoming FSP code.
	#For at least the MTRC, starting with Allegheny County, we are moving away from relying on PHA UAs for estimating utility costs. Most people using this tool for their own situations will likely be entering their own costs anyway. But relying on PHA UAs has also become problematic because it require digging deep into not commonly available public information, especially for large states with many PHAs. Moving toward a more general approach of just incorporating average gas and electric costs makes sense. Perhaps we could also adjust these based on the difference between fair market rent and the median or average bedroom size of a state or at the national level.
	our $heating_cost_pha = 0;
	our $cooking_cost_pha = 0;

	our $wic_elig_nslp = 0; #This is a state policy variable indicating whether there is categorical eligibilty for WIC for young children who receive free school lunches. This is a policy in some areas (like DC and VA) but is not explicitly a federal policy. It does not seem like a policy in PA, in that there is no record of any state agency or nonprofit agency promoating eligibility to WIC through school lunch programs.

	# calculations / assignments:  
	$sua_utilities_only = $sua_nonheat; #Using this  variable as the general one (in the fsp_mtrc.pl code), and figuring out here which of the PA SUA's apply. Waiting on response from Allegheny County as to whether telephone+internet counts as two utilities or just a telephone expense. If just telephone, then can build into SNAP code (or here) some additional code that defers to telephone allowance.
	$sua_phoneandinternet_only = $sua_phone;
	$fs_vehicle1 = 0;                             # value of vehicle 1 to be counted in the food stamp asset test
	$fs_vehicle2 = 0;                             # value of vehicle 2 to be counted in the food stamp asset test

	$pha_ua = $average_electric_cost + $average_naturalgas_cost; # Let's try this for now. It saves us a lot of work, for a figure that isn't necessarily right.

	#debugging:
	#foreach my $debug (qw(pha_ua heating_cost_pha cooking_cost_pha electric_cost_pha sua_heat sua_utilities_only)) {
	#	print $debug.": ".${$debug}."\n";
	#}


	#Note for PA: Have eliminated the following outputs from below list. Need to check if this interferes with SNAP code or LIHEAP code (or any other code)
	#pha_zone 
	#bedrooms
	#heating_cost_pha
	#cooking_cost_pha
	#electric_cost_pha

  # outputs
    foreach my $name (qw(fs_vehicle1 fs_vehicle2 bbce_gross_income_pct bbce_no_asset_limit bbce_disability_no_asset_limit bbce_asset_limit heatandeat_nominal_payment optional_sua_policy pha_ua sua_heat sua_utilities_only average_naturalgas_cost average_electric_cost sua_phoneandinternet_only wic_elig_nslp)) {
       $out->{$name} = ${$name};
    }
}

1;