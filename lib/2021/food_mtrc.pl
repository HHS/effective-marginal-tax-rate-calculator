#  FOOD COSTS  – 2021 
#
#=============================================================================#
# 	INPUTS AND OUTPUTS REFERNCED IN THIS MODULE:
#
#   INPUTS FROM USER INTERFACE
#		child#_age
#		parent#_age
#		family_size
#		food_override
#		food_override_amt
#
#	INPUTS POTENTIALLY GENERATED IN THIS MODULE
#		family_foodcost_initial
#
#	OUTPUTS FROM FRS.PL
#		scenario
#
#	OUTPUTS FROM SNAP (FSP)
#		fsp_recd
#
# 	OUTPUTS FROM SCHOOL AND SUMMER MEALS:
#		child_foodcost_red_total
#
#	OUTPUTS FROM WIC
#		wic_recd
#=============================================================================#

sub food
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

  # outputs created
    our $food_expenses = 0; # total annual family food expenses
    our $family_foodcost = 0;       # annual
	our  $subsidized_food = 0; 	# The total amount of food subsidies that the family is receiving.

	# variables used in this script
	# Costs for low-cost food plan cited below, including food cost adjustments, are available on USDA's websites as pdfs, e.g. https://www.fns.usda.gov/cnpp/usda-food-plans-cost-food-reports-monthly-reports.
	our $parent1_foodcost_m =  235.20;	# monthly food cost for first parent (Mean of low-cost food costs between Female aged 19-50 years and Male aged 19-50 years. Source is the USDA Low-Cost food plan issued Jan 2021.)
	our $parent2_foodcost_m = 235.20;	# monthly food cost for second parent. (Mean of low-cost food costs between Female aged 19-50 years and Male aged 19-50 years. Source is the USDA Low-Cost food plan issued Jan 2021.)
	our $parent3_foodcost_m = 235.20;	# monthly food cost for third parent. (Mean of low-cost food costs between Female aged 19-50 years and Male aged 19-50 years. Source is the USDA Low-Cost food plan issued Jan 2021.)
	our $parent4_foodcost_m = 235.20;	# monthly food cost for fourth parent. (Mean of low-cost food costs between Female aged 19-50 years and Male aged 19-50 years. Source is the USDA Low-Cost food plan issued Jan 2021.)
	our $olderparent_foodcost_m =  225.10;    #Mean of low-cost food costs between Female aged 51-70 years and Male aged 51-70 years. Source is the USDA Low-Cost food plan issued Jan 2021.
	our $yo18parent_foodcost_m =  234.60;    #Mean of low-cost food costs between 18-year-old female and 18-year-old male. Source is the USDA Low-Cost food plan issued Jan 2021. That this is only 80 cents lower than the monthly parent1 and parent2 food cost indicated above makes this a pretty marginal adjustment for this year, but as we are pulling from a federal table that specifically includes ages, it is appropriate to do so at this time. If the table indicates larger differences between adults and 18-year-olds at a later date, this code will already account for that change.
	our $child1_foodcost_m  = 0;	 # Monthly food cost per child stratified by age
	our $child2_foodcost_m  = 0;	# Monthly food cost per child stratified by age
	our $child3_foodcost_m  = 0;	 # Monthly food cost per child stratified by age
	our $child4_foodcost_m  = 0;	# Monthly food cost per child stratified by age
	our $child5_foodcost_m  = 0;	# Monthly food cost per child stratified by age
	our $familysize_adjustment = qw(0 1.2 1.1 1.05 1 0.95 0.95 0.90 .90 .90)[$in->{'family_size'}];     # Food cost adjustment 

	# calculated in macro	
	our $base_foodcost_m = 0;              	# Total monthly (unadjusted) family food cost, based on a family of 4
	our $base_foodcost = 0;                	# NIP: Total annual (unadjusted) family food cost, based on a family of 4. Commenting out for now; delete this if there's no other program that uses this. but comment out if it's not mentioned anywhere else.
	our $family_foodcost_fmred  = 0;	# NIP: the family food costs after accounting for free meals 
	#programs for children


    #   1.  Calculate base food cost for each family
    #   Use Food Cost tables to look up Child#_foodcost_m 

	if($in->{'food_override'}) {
		if ($out->{'scenario'} eq 'current') {
			#To find the base food cost -- how much the family spends on food items -- we add the out-of-pocket amount the user has entered to the subsidies they receive from various food programs. We do this only for the "currrent" scenario to find the base amount, which will be the total food expenses families pay as they lose wic, school/summer lunch or breakfast, and SNAP. Including SNAP here is a departure from the FRS, which calculates SNAP separately, but it is not possible to continue to separate the two given how the MTRC is considering out-of-pocket costs.
			$in->{'family_foodcost_initial'} = 12 * $in->{'food_override_amt'} + $out->{'child_foodcost_red_total'} + $out->{'wic_recd'} + $out->{'fsp_recd'};
		}
		
		$family_foodcost = $in->{'family_foodcost_initial'} ;

	} else {

		# Get individual adult's food costs
		for (my $i = 1; $i <= 4; $i++) {
			if ($in->{'parent'.$i.'_age'} == -1) {
				${'parent'.$i.'_foodcost_m'} = 0;			
			} elsif ($in->{'parent'.$i.'_age'} > 50) {
				${'parent'.$i.'_foodcost_m'} = $olderparent_foodcost_m;
			} elsif ($in->{'parent'.$i.'_age'} == 18) {
				${'parent'.$i.'_foodcost_m'} = $yo18parent_foodcost_m;
			}
		}

		# Get individual children's food costs
		for (my $i = 1; $i <= 5; $i++) {
			if ($in->{'child'.$i.'_age'} == -1) {
				${"child".$i."_foodcost_m"} = 0;
			} else {
				${"child".$i."_foodcost_m"} = qw(133.30 133.30 139.80 139.80 143.20 143.20 202.00 202.00 202.00 216.10 216.10 216.10 232.40 232.40 234.60 234.60 234.60 234.60)[$in->{"child".$i."_age"}]; #Child costs for low-cost food plan as of January 2021. Ages 12-17 represent aveage between males and females.
			}
		}
		
		$base_foodcost_m = $parent1_foodcost_m + $parent2_foodcost_m + $parent3_foodcost_m + $parent4_foodcost_m + $child1_foodcost_m + $child2_foodcost_m + $child3_foodcost_m + $child4_foodcost_m + $child5_foodcost_m;
		
		$family_foodcost = $base_foodcost_m * 12 * $familysize_adjustment;
	}
	 
	$food_expenses = &round(&pos_sub($family_foodcost, $out->{'child_foodcost_red_total'} + $out->{'wic_recd'} + $out->{'fsp_recd'}));

	$subsidized_food = $family_foodcost - $food_expenses;

	#debugging:
	foreach my $debug (qw(food_expenses family_foodcost subsidized_food)) {
		print $debug.": ".${$debug}."\n";
	}

	# outputs
    foreach my $name (qw(food_expenses family_foodcost subsidized_food)) {
       $out->{$name} = ${$name};
	}
}

# Note about assumptions and justifications:
# The USDA separates out food costs according to gender of child for children older than 11, and separates food costs for parents according to gender for all ages. Previous versions calculated food costs for children older than 11 based on the average food cost between the listing for male and female children of that age range, and assumed food costs for a one-parent family based on listings for females age 19-50, and for two-parent families based on listings for one female age 19-50 and one male age 19-50.  Because we are now asking about age of parent, we need to also include lower food costs for older parents (ages 51-61). The differences in monthly food cost between adult males and adult females in the low-cost food plan is at most less thatn $600 per year, before any food subsidies are considered. This seems fairly nominal, and is based on estimated food costs anyway (with likely considerable margins of error compared to actual food costs) so I think it’s okay to use the assumption that each household adult consumes the average of male and female food costs. We are also removing gender assumptions by using the average of male and female food costs going forward.
# We are also assuming that if a user enters their own food costs, those food costs are out-of-pocket, and therefore inclusive of any savings the family may be getting from WIC or school and summer meals programs.

1;

