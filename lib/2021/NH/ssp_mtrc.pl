#=============================================================================#
#  SSP (State additions to Supplemental Security Income) Module – 2021, NH 
#=============================================================================#
#
# No Inputs or outputs needed -- this is basically a Perl file used to define variables. 
#	
#=============================================================================#

sub ssp
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};


	# outputs created in macro:
	# Some states supplement the federal SSI benefit with their own state benefit, which increases cash assistance for individuals eligible for SSI or ineligible due to incomes that slightly exceed SSI standards. To keep the SSI module applicable across different states, we have used a separate module beginning in the 2020 FRS and 2021 MTRC that tracks state SSI supplements (called the "state supplementary program", or SSP) in states that have them. Although usually small in amount, receiving this supplement can also allow individuals with disabilities at slightly higher incomes to receive Medicaid.  

	# These SSP amounts and variables are incorporated into the federal SSI Perl code.

	# While the documentation on New Hampshire's SSP programs are very robust, and can seemingly appear complicated, the SSP rules at least for APTD and ANB seem fairly simple to model and in practice are similar to the small additions most states also offer. The "standard of need" for individuals and couples in New Hampshire for APTD and ANB in 2020 are $797 and $1176, respectively, or $14 and $1 higher than the federal benefit rates (FBRs) for SSI nationally. Aside from a smaller asset limit (which we are not including in the MTRC, since we are not assessing initial eligibility and assuming assets stay constant), this behaves as simply raising the income limits for SSI by these amounts. This is becuase SSI income counts as non-excluded income in NH's SSP program, meaning that essentially it adds the difference in eligibility limits to SSI limits. A more important part of NH's SSP program is conferring Medicaid eligibility for former APTD recipients up to 450% of the federal poverty level. This means that people on SSI or SSP in NH can receive Medicaid up to these amounts.

	# This code only addresses  to the needy blind (ANB) and aid to the permanently and totally disabled (APTD). These are elements of NH's SSP program. We are excluding households with elderly individuals from this analysis, therefore are not concerned with Old Age Assistance (OAA) cases, another part of NH's SSP program. 

	# Note the terminology can be confusing because APTD, ANB, and OAA are also the former names of programs specific to these populations that became part of the federal SSI program. 

	our $ssp_asset_limit = 1500; # Amount the state's SSP program is structured increases the income standard above the federal 
	our $ssp_couple_thresh = 1; # Amount the state's SSP program is structured increases the income standard above the federal threshold for couples, to provide supplemental funds to cover otherwise inelgible families.
	our $ssp_individual_thresh = 14; # Amount the state's SSP program is structured increases the income standard above the federal threshold for individuals, to provide supplemental funds to cover otherwise inelgible individuals 
	our $ssp_couple_ben = 0;  # Amount state's SSP program increase benefits for couples resceiving federal SSI supports.
	our $ssp_individual_ben = 0; # Amount state's SSP program increase benefits for individuals receiving federal SSI supports.

	 # outputs
	foreach my $name (qw(ssp_couple_thresh ssp_individual_thresh ssp_couple_ben ssp_individual_ben ssp_asset_limit)) {
        $out->{$name} = ${$name};
	}
}

1;

# Limitations: 
# 1. We are assuming no individual in the house qualifies as an "essential person." The shorthand definition of an Essential Person is "someone who was identified as essential to your welfare under a State program that preceded the SSI program." The more formal definiition is someone who: "(A) has continuously lived in the individual's home since December 1973; and (B) was not eligible for State assistance in December 1973; and (C) has never been eligible for SSI benefits as an eligible individual or as an eligible spouse; and (D) State records show that, under a State plan in effect for June 1973, the State took that person's needs into account in determining the qualified individual's need for State assistance for December 1973."