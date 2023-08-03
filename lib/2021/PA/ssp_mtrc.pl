#=============================================================================#
#  SSP (State Supplemental Program) Module – 2021 PA 
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
	# These are the amounts of PA's state supplement to the SSI program in 2021, for couples and individuals. The program is explained in Section 720.1 of the Pennsylvania state code, available as of 3.27.2019 at http://services.dpw.state.pa.us/oimpolicymanuals/supp/720_State_Supplementary_Payment/720_1_General_Policy.htm and http://services.dpw.state.pa.us/oimpolicymanuals/supp/720_State_Supplementary_Payment/720_Appendix_B.htm. This documentation is also available in the policy manuals at http://www.dhs.pa.gov/publications/policyhandbooksandmanuals/, under "Supplemental Handbook," which links to http://services.dpw.state.pa.us/oimpolicymanuals/supp/index.htm. As far as Seth understants the program, these amounts are simply combined with the federal payment standard. This is the "optional" state supplement, meaning it is a state option to provide this additional benefit. In most cases, the correct amount is simply added on to the amount of SSI a family or individual receives. Individuals or couples eligible for SSI except that their income just barely exceeds the federal standard are also eligible for payments under this program at declining amounts as income rises, until their monthly income exceeds the combined federal and state (PA) standards. Although small in amount, receiving the supplement also allows individuals with disabilities at slightly higher incomes to receive Medicaid. 
	# The SSP program is also availabe to people receiving OASDI prayments, through the state's "mandatory" program. The federal Social Security Administration manages that program, while PA's state govt handles the optional program that overlaps with SSI.
	# This code is also so simple and is purely a hard-coded assignment of state variables; it may be easier to eventually include this as a variable in the db.
	# These SSP amounts and variables are incorporated into the federal SSI Perl code.
	our $ssp_couple_thresh = 33.3; 
	our $ssp_individual_thresh = 22.1;
	our $ssp_couple_ben = 0;
	our $ssp_individual_ben = 0;
	

	 # outputs
	foreach my $name (qw(ssp_couple_thresh ssp_individual_thresh ssp_couple_ben ssp_individual_ben)) {
		$out->{$name} = ${$name};
	}
}

1;
