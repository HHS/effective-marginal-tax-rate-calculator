#=============================================================================#
#  Food Stamp Asset Module -- DC 2021 
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
	our $bbce_gross_income_pct = 2;    # % of poverty used for SNAP gross income eligibility test. Last checked 5/20/21.
	our $bbce_no_asset_limit = 1;            	# “1” for a state that has no asset limit as part of its BBCE program. 
	our $bbce_asset_limit = 0;                  # For states that have a BBCE asset limit, this is where that would be.
	our $bbce_disability_no_asset_limit = 1; # Some states that have broad-based categorical eligibility (BBCE) policies do not exempt households that include people who are elderly or people with disabilities from federal asset limit at incomes higher than 200% of the poverty level. These families face no gross income limit based on federal policy, but do face asset limits. BBCE allows states to exempt the assets of these families at gross incomes below 200% of the federal poverty level and also allows states the choice of whether to use the federal standard for families above this level. PA chooses to use the federal asset limit at higher incomes. Other states like DC exempt assets for all applicant families; for these states, this variable would equal 1.

	our $heatandeat_nominal_payment = 20.01;  # This relates to the nominal payment (using local funds) that all SNAP recipients can get in order to claim the standard utility allowance, similar to if they received LIHEAP. Including it in this SNAP-related subroutine allows us to run the SNAP subroutine prior to LIHEAP, which is helpful because SNAP receipt confers categorical eligibility for LIHEAP. The SNAP code checks if this is greater than the heat-and-eat minimum, and if it is, confer the full SUA on SNAP recipients. 

	our $average_electric_cost = 97.62; #from eia.gov
	our $average_naturalgas_cost = 837/12; #from aga.org.

	our $optional_sua_policy = 0; # Some states require the use of state-determined SUA's in calculating the utilities portion of SNAP's excess shelter deduction (they have "Mandatory SUAs"), while other states allow SNAP recipients to claim higher utilities costs if they can provide evidence that these costs exceed SUAs (these states have "optional SUAs"). This variable indicates whether the state has optional SUAs, allowing SNAP recipients to claim hgiher utilities expenses than state SUAs. Most states, like PA, follow a policy of mandatory SUAs. See https://fns-prod.azureedge.net/sites/default/files/snap/14-State-Options.pdf and also state policy handbooks.
	our $sua_heat = 310; #as of 7/1/21; see https://dhs.dc.gov/service/snap-eligibility-general-requirements.
	our $sua_utilities_only = 310; #This is the SUA for "utilities only" or "non-heating" in some states, but everyone DC receives the same standard utility allowance, including, through the Heat and Eat option, people who pay no utilities out of pocket.
	our $sua_phoneandinternet_only = 310; #This is the allowance / SUA for homes that just incur telephone and internet expenses but no other utilities. As above, this is the same for everyone in DC.

	our $wic_elig_nslp = 1; #This is a state policy variable indicating whether there is categorical eligibilty for WIC for young children who receive free school lunches. This is a policy in some areas (like DC and VA) but is not explicitly a federal policy. 
	
	#Calculated below:
	our $pha_ua = 0; # Estimating or incorporating energy costs is important for estimating SNAP becuase we the fair market rents we use incorporate utilities, but SNAP calculations separate rent from utilities. So we need to separate rent from utilities here as well. These estimations vary by state but this variable is used in the upcoming FSP code.
	#For at least the MTRC, starting with Allegheny County, we are moving away from relying on PHA UAs for estimating utility costs. Most people using this tool for their own situations will likely be entering their own costs anyway. But relying on PHA UAs has also become problematic because it require digging deep into not commonly available public information, especially for large states with many PHAs. Moving toward a more general approach of just incorporating average gas and electric costs makes sense. Perhaps we could also adjust these based on the difference between fair market rent and the median or average bedroom size of a state or at the national level.
	# our $heating_cost_pha = 0;
	# our $cooking_cost_pha = 0;

	$fs_vehicle1 = 0;                             # value of vehicle 1 to be counted in the food stamp asset test
	$fs_vehicle2 = 0;                             # value of vehicle 2 to be counted in the food stamp asset test

	$pha_ua = $average_electric_cost + $average_naturalgas_cost; # Let's try this for now. It saves us a lot of work, for a figure that isn't necessarily right. May change this variable name soon, since it's no longer tied to public housing authorities, but keeping it in for now to help make sure all the codes work correctly.

	#debugging:
	#foreach my $debug (qw(pha_ua heating_cost_pha cooking_cost_pha electric_cost_pha sua_heat sua_utilities_only)) {
	#	print $debug.": ".${$debug}."\n";
	#}


	#Note for DC: Have eliminated the following outputs from below list. Ongoing checks to see if this interferes with SNAP code or LIHEAP code (or any other code)
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