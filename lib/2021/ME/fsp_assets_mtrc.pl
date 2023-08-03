#=============================================================================#
#  Food Stamp Asset Module -- ME 2021 
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
	our $bbce_gross_income_pct = 1.85;    # % of poverty used for SNAP gross income eligibility test. Last checked 5/20/21.
	our $bbce_no_asset_limit = 1;            	# “1” for a state that has no asset limit as part of its BBCE program. 
	our $bbce_asset_limit = 0;                  # For states that have a BBCE asset limit, this is where that would be.
	our $bbce_disability_no_asset_limit = 1; # Some states that have broad-based categorical eligibility (BBCE) policies do not exempt households that include people who are elderly or people with disabilities from federal asset limit at incomes higher than 200% of the poverty level. These families face no gross income limit based on federal policy, but do face asset limits. BBCE allows states to exempt the assets of these families at gross incomes below 200% of the federal poverty level and also allows states the choice of whether to use the federal standard for families above this level. PA chooses to use the federal asset limit at higher incomes. Other states like DC and Maine exempt assets for all applicant families; for these states, this variable would equal 1.

	our $heatandeat_nominal_payment = 0;
	#Maine's Heat-and-Eat policy seems to differ from other states in that they only provide the nominal payment to residents of subsidized housing.
	if ($in->{'sec8'} == 1) {
		$heatandeat_nominal_payment = 21;  # This relates to the nominal payment (using local funds) that all SNAP recipients can get in order to claim the standard utility allowance, similar to if they received LIHEAP. Including it in this SNAP-related subroutine allows us to run the SNAP subroutine prior to LIHEAP, which is helpful because SNAP receipt confers categorical eligibility for LIHEAP. The SNAP code checks if this is greater than the heat-and-eat minimum, and if it is, confer the full SUA on SNAP recipients. 
	} else {
		$heatandeat_nominal_payment = 0;
	}

	our $average_electric_cost = 100.53; #from eia.gov
	our $average_naturalgas_cost = 1376/12; #from aga.org.

	our $optional_sua_policy = 0; # Some states require the use of state-determined SUA's in calculating the utilities portion of SNAP's excess shelter deduction (they have "Mandatory SUAs"), while other states allow SNAP recipients to claim higher utilities costs if they can provide evidence that these costs exceed SUAs (these states have "optional SUAs"). This variable indicates whether the state has optional SUAs, allowing SNAP recipients to claim hgiher utilities expenses than state SUAs. Most states, like PA, follow a policy of mandatory SUAs. See https://fns-prod.azureedge.net/sites/default/files/snap/14-State-Options.pdf and also state policy handbooks. In Maine, "households that incur expenses for heating or air-conditioning bills that are separate and apart from rent/mortgage bills must be givent the Full Standard Utiltiy Allowance (FSUA)." There are households that are not eligible, e.g. when someone outside the household is paying for all heating costs, but we are assuming that these exceptions are not the case in the MTRC.

	our $sua_heat = 782; # This is the FSUA in Maine. See Chart 8 of the SNAP manual.
	our $sua_utilities_only = 264; #This is the NHUA in Maine. This is the SUA for "utilities only" or "non-heating" in some states. While technically in Maine, if someone is incurring just one of utilities eligible for the NHUA, the allowance must be the actual cost of that utility, but since we are not breaking down utilities in the MTRC, we assume that there is more than one cost that can be charged here. See Chart 8 of the SNAP manual.
	our $sua_phoneandinternet_only = 45; #This is PHUA in Maine. This is the allowance / SUA for homes that just incur telephone and internet expenses but no other utilities. It cannot be added to eitehr of the other two. See Chart 8 of the SNAP manual.

	our $wic_elig_nslp = 0; #This is a state policy variable indicating whether there is categorical eligibilty for WIC for young children who receive free school lunches. This is a policy in some areas (like DC and VA) but is not explicitly a federal policy. It is not a policy in Maine. From the Maine WIC manual: "Adjunct or automatic income eligibility- Families with TANF, SNAP participants and MaineCare Recipients- Individuals who participate in SNAP, who are members of families receiving assistance under the TANF Program, who receive MaineCare, or who are members of families that include a pregnant woman or infant receiving  MaineCare (or presumptively eligible for MaineCare) are considered adjunctively income eligible for the Maine CDC WIC Nutrition Program. Adjunctive eligibility must be verified and entered for each family member in the WIC SPIRIT application."
	
	#Calculated below:
	our $pha_ua = 0; # Estimating or incorporating energy costs is important for estimating SNAP becuase we the fair market rents we use incorporate utilities, but SNAP calculations separate rent from utilities. So we need to separate rent from utilities here as well. These estimations vary by state but this variable is used in the upcoming FSP code.
	#For at least the MTRC, starting with Allegheny County, we are moving away from relying on PHA UAs for estimating utility costs. Most people using this tool for their own situations will likely be entering their own costs anyway. But relying on PHA UAs has also become problematic because it require digging deep into not commonly available public information, especially for large states with many PHAs. Moving toward a more general approach of just incorporating average gas and electric costs makes sense. Perhaps we could also adjust these based on the difference between fair market rent and the median or average bedroom size of a state or at the national level.
	# our $heating_cost_pha = 0;
	# our $cooking_cost_pha = 0;

	$fs_vehicle1 = 0;                             # value of vehicle 1 to be counted in the food stamp asset test
	$fs_vehicle2 = 0;                             # value of vehicle 2 to be counted in the food stamp asset test

	$pha_ua = $average_electric_cost + $average_naturalgas_cost; # Let's try this for now. It saves us a lot of work, for a figure that isn't necessarily right. May change this variable name soon, since it's no longer tied to public housing authorities, but keeping it in for now to help make sure all the codes work correctly.

	#Note for DC and ME: Have eliminated the following outputs from below list. Ongoing checks to see if this interferes with SNAP code or LIHEAP code (or any other code)
	#pha_zone 
	#bedrooms
	#heating_cost_pha
	#cooking_cost_pha
	#electric_cost_pha

	#debugging:
	#foreach my $debug (qw(pha_ua heating_cost_pha cooking_cost_pha electric_cost_pha sua_heat sua_utilities_only)) {
	#	print $debug.": ".${$debug}."\n";
	#}

  # outputs
    foreach my $name (qw(fs_vehicle1 fs_vehicle2 bbce_gross_income_pct bbce_no_asset_limit bbce_disability_no_asset_limit bbce_asset_limit heatandeat_nominal_payment optional_sua_policy pha_ua sua_heat sua_utilities_only average_naturalgas_cost average_electric_cost sua_phoneandinternet_only wic_elig_nslp)) {
       $out->{$name} = ${$name};
    }
}

1;