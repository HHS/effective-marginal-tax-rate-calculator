#=============================================================================#
#  SSP (State Supplemental Program) Module – 2021 DC  
#=============================================================================#
#
#
#=============================================================================#

sub ssp
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

	# outputs created in macro:
	# Some states supplement the federal SSI benefit with their own state benefit, which increases cash assistance for individuals eligible for SSI or ineligible due to incomes that slightly exceed SSI standards. To keep the SSI module applicable across different states, this module tracks state SSI supplements (called the "state supplementary program", or SSP) in states that have them. Although small in amount, receiving this supplement can also allow individuals with disabilities at slightly higher incomes to receive Medicaid. DC indeed provides an SSP, but it is limited to individuals  living in adult foster care homes or Medicaid facilities. We are not yet including this as an option for the FRS/MTRC, so the potential benefit from DC's SSP program will be $0 unless we reassess our living arrangement options. See https://www.ssa.gov/pubs/EN-05-11162.pdf and https://dhcf.dc.gov/service/optional-state-supplement-payment-program
	# This code is also so simple and is purely a hard-coded assignment of state variables; it may be easier to eventually include this as a variable in the db.
	# These SSP amounts and variables are incorporated into the federal SSI Perl code.
	our $ssp_couple_thresh = 0; # Amount the state's SSP program is structured increases the income standard above the federal threshold for couples, to provide supplemental funds to cover otherwise inelgible families.
	our $ssp_individual_thresh = 0; # Amount the state's SSP program is structured increases the income standard above the federal threshold for individuals, to provide supplemental funds to cover otherwise inelgible individuals 
	our $ssp_couple_ben = 0;  # Amount state's SSP program increase benefits for couples resceiving federal SSI supports.
	our $ssp_individual_ben = 0; # Amount state's SSP program increase benefits for individuals receiving federal SSI supports.

	#debugging:
	foreach my $debug (qw()) {
		print $debug.": ".${$debug}."\n";
	}
	
	# outputs
    foreach my $name (qw(ssp_couple_thresh ssi_individual_thresh ssp_couple_ben ssi_individual_ben)) { 
       $out->{$name} = ${$name};
    }
	
}

1;
