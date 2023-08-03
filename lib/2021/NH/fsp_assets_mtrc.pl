#=============================================================================#
#  Food Stamp Asset Module -- NH 2021 
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
	our $fs_vehicle1 = 0;		#No assets are counted among expanded categorically eligible families for NH's SNAP rules, which so far all families will be. This will be different if we include ABAWDs, which are not eligible for BBCE.
	our $fs_vehicle2 = 0;
	our $bbce_gross_income_pct = 1.85;		# % of poverty used for SNAP gross income eligibility test
	our $bbce_no_asset_limit = 1;			# “1” for a state that has no asset limit as part of its BBCE program. 
	our $sua_heat = 701; #Policy as of 10/1/2021
	our $sua_utilities_only = 256; #This is the SUA for "utilities only" in NH (policy as of 10/1/2020). To avoid too many user questions, we are assuming that if a user selects that they are paying heat in rent but and they also fill in a nonzero utilities amount or a nonzero phone bill amount (or choose the calcaultor estimate of the phone bill), they are entitled to the "Utiltiies Only" SUA in NH. The qualifications for this non-heating SUA are very broad, and internet and telephone count as two utiltiies.
	#Other SUAs: (policy as of 10/1/2020)
	#Utilities Only: $256
	#Electric Only: $150
	#Telephone Only: $27
	#Internet Only: $50

	our $bbce_disability_no_asset_limit = 1; #  Some states that have broad-based categorical eligibility (BBCE) policies do not exempt households that include people who are elderly or people with disabilities from federal asset limit at incomes higher than 200% of the poverty level. These families face no gross income limit based on federal policy, but do face asset limits. BBCE allows states to exempt the assets of these families at gross incomes below 200% of the federal poverty level and also allows states the choice of whether to use the federal standard for families above this level. NH exempts assets for all applicant families, so this variable would equal 1.
	our $bbce_asset_limit = 0;				# For states that have a BBCE asset limit, this is where that would be.
	our $heatandeat_nominal_payment = 0;	#Heat-and-eat nominal payment amount. This is a small amount of LIHEAP benefits that states can give to SNAP recipients to qualify them for the 'standard utility allowance' deduction when calculating their SNAP net adjusted income, even in cases where the family does not pay for their own heat (which would typically disqualify them from getting the SUA deduction). This serves to increase the amount of SNAP benefits that the family gets. NH does not provide nominal LIHEAP payments to increase SNAP participation, according to their most recent LIHEAP plan. This variable also does not currently factor into SNAP determinations for states with a mandatory SUA policy, as NH has, as long as we are assuming that rent is separate from utiltiy costs.  SNAP policy may also change to allow for optional SUAs again, in which this would be important. 
	our $optional_sua_policy = 0;			# Whether the state allows families to have the option of claiming their actual costs instead of the SUA. NH does not do this. This is clear from the SNAP policy manual and from the most recent federally published SNAP Policy Options report.


	our $sua_phoneandinternet_only = 0;
	our $pha_zone = 0;
	our $pha_ua = 0; # Estimating or incorporating energy costs is important for estimating SNAP becuase we the fair market rents we use incorporate utilities, but SNAP calculations separate rent from utilities. So we need to separate rent from utilities here as well. These estimations vary by state but this variable is used in the upcoming FSP code.
	our $heating_cost_pha = 0;
	our $cooking_cost_pha = 0;
	# calculate assets    
	
	our $wic_elig_nslp = 0; #This is a state policy variable indicating whether there is categorical eligibilty for WIC for young children who receive free school lunches. This is a policy in some areas (like DC, NH, and VA) but is not explicitly a federal policy.
	
	our $bedrooms = qw(1 2 2 3 3 4)[$in->{'child_number'} + least(1,pos_sub($in->{'family_structure'},2))];  #These are based on HUD standards of two heartbeats per room as long as people sharing the same room are of the same generation and related. We'll need to know the number of bedrooms to estimate pha_ua below. This assumes maximum of two children per bedroom and two adults per bedroom, with no adult in the same bedroom as a child. 
	our $electric_cost_pha = qw(41 47 56 66 77 86)[$bedrooms];

	#In past FRS PROJECTS, we've includEd variations on cooking costs based on energy type, as PHA utility allowances include this variation. As we are including estimates and there is very little impact of changes in types of cooking fuel source on annual budets (about $10 variation per month), we are taking the average of these allowances to estimate cooking costs.
	our $cooking_cost_pha = qw(12 14 18 22 28 32)[$bedrooms];	

	#	PHA utility allowances are more realistic than SUAs for approximating energy costs because there is less incentive for states to inflate them; using them also allows us to see the impact of setting lower or higher SUAs relative to estimated actual utility costs. In New Hampshire, the PHA UAs are delineated by home type, with the home types listed as (1) 2-3 story walk-ups, (2) row and townhouses, (3) duplex and twin, (4) high-rise, (5) detached, (6) pre-1976 mobile homes, and (7) mobile homes made from 1976-1994. For mobile homes made after 1976, the guidance is to use the UAs listed in the "detached" category.
	#
	#	In terms of a default home_type setting, the three categoriSes that NH Office of Strategic Initiatives use in their most recent Housing Trends document are (1) Single Family, (2) Multi-Family, and (3) Manufactured Housing. Single Family dwellings constiute about 2/3 of the housing stock in NH as of 2018 - 405,702 units out of 642,433 total estimated units. As "Detached" homes are used synonomously with "Single Family" Homes, we can use this as the default home type. Choosing so has the added benefit of also encompassing the PHA UA for mobile homes made after 1994, as these use the same PHA UAs. Mobile homes -- or "manufactured housing" -- consitute an additionla 36,834 estimated housing units as of 2018. (THe remaining units are "multi-family homes."

	#Right now, we're hard-coding these reginal energy estimates by PHA region. this could also be made into a SQL table if it's easier to update SQL than it is to update Perl. This is a discussion we could have with IT folks.

	# We are also making a generalization that the variation between different housing types for heating costs across a PHA per number of bedrooms is nominal enough that we are taking the average of those costs, even though PHAs separate out allowances by household type. This information is not needed anywhere else in the tool. If we take the average pha allowance based on location, bedrooms, and heating type (without asking about housing type), the maximum annual difference in estimated energy costs compared to results based on housing type is $1,219 over the course of a year, but the median difference is $431. The average difference is $488. There are meaningful numbers, but as we are approximating costs here, and there are no benefit cliffs tied to these numbers (outside of potentially slightly smaller cliffs when these costs form an upper bound for LIHEAP costs).

	#Potentially, more detail aroudn housing type could be added on later.

	$fs_vehicle1 = 0;						# value of vehicle 1 to be counted in the food stamp asset test. This calculation is a bit more complicated in states that count assets.
	$fs_vehicle2 = 0;						# value of vehicle 2 to be counted in the food stamp asset test. This calculation is a bit more complicated in states that count assets.
	$sua_phoneandinternet_only = $sua_utilities_only; #As explained above, phone and internet are enough to qualify for the second-highest SUA in NH.

	if ($in->{'pha_region'} == 1) {
		if ($in->{'heat_fuel_source'} eq 'natural_gas') { 
		$heating_cost_pha = qw(56 72 88 103 127 134)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'bottle_gas') {
		$heating_cost_pha = qw(101 142 181 220 280 298)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'oil') {
		$heating_cost_pha = qw(68 95 124 152 192 202)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'electric') {
		$heating_cost_pha = qw(75 98 146 190 209 224)[$bedrooms];
		}
	} elsif ($in->{'pha_region'} == 2) {	
		if ($in->{'heat_fuel_source'} = 'natural_gas') { 
		$heating_cost_pha = qw(60 78 96 112 139 147)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'bottle_gas') {
		$heating_cost_pha = qw(112 157 201 244 311 330)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'oil') {
		$heating_cost_pha = qw(76 105 137 169 214 224)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'electric') {
		$heating_cost_pha = qw(83 109 162 211 232 248)[$bedrooms];
		}
	} elsif ($in->{'pha_region'} == 3) {	
		if ($in->{'heat_fuel_source'} eq 'natural_gas') { 
		$heating_cost_pha = qw(64 84 104 121 151 160)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'bottle_gas') {
		$heating_cost_pha = qw(123 173 221 269 342 363)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'oil') {
		$heating_cost_pha = qw(84 116 151 186 235 247)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'electric') {
		$heating_cost_pha = qw(91 120 179 231 255 273)[$bedrooms];
		}
	} elsif ($in->{'pha_region'} == 4) {	
		if ($in->{'heat_fuel_source'} eq 'natural_gas') { 
		$heating_cost_pha = qw(68 90 112 131 163 173)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'bottle_gas') {
		$heating_cost_pha = qw(134 189 242 293 373 397)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'oil') {
		$heating_cost_pha = qw(91 127 165 203 256 269)[$bedrooms];
		} elsif ($in->{'heat_fuel_source'} eq 'electric') {
		$heating_cost_pha = qw(99 131 195 253 278 298)[$bedrooms];
		}
	}
	
	$pha_ua = $heating_cost_pha + $cooking_cost_pha + $electric_cost_pha;  

	#debugging:
	foreach my $debug (qw(pha_ua heating_cost_pha cooking_cost_pha electric_cost_pha sua_heat sua_utilities_only sua_phoneandinternet_only)) {
		print $debug.": ".${$debug}."\n";
	}


  # outputs
    foreach my $name (qw(fs_vehicle1 fs_vehicle2 bbce_gross_income_pct bbce_no_asset_limit bbce_disability_no_asset_limit bbce_asset_limit heatandeat_nominal_payment optional_sua_policy pha_zone pha_ua bedrooms heating_cost_pha cooking_cost_pha electric_cost_pha sua_heat sua_utilities_only wic_elig_nslp)) {
       $out->{$name} = ${$name};
    }
	
}

1;