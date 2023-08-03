#=============================================================================#
#  Lifeline (telephone subsidies) Module -- NH 2021
#=============================================================================#
#
# Inputs referenced in this module:
#
#   INPUTS FROM USER INTERFACE
#       lifeline
#
#	OUPUTS FROM FRS.PL 
#       earnings
#
#	OUTPUTS FROM FRS.PM
#       fpl
#
#   OUTPUTS FROM HEALTH
#       hlth_cov_parent
#       hlth_cov_child#
#
#   OUTPUTS FROM FOOD STAMPS
#       fsp_recd
#
# 	OUTPUTS FROM SSI
#   	ssi_recd
#
#   OUTPUTS FROM SECTION 8
#       housing_recd
#
#	OUTPUTS FROM FEDERAL TAXES
#		gross_income#
#
#
#=============================================================================#
#
# Lifeline program - general information
# The 2016 revisions to Lifeline rules, effective December 1, 2016, are described at https://www.fcc.gov/general/lifeline-program-low-income-consumers. These changes include excluding eligibility for TANF, LIHEAP and NSLP from categorical eligibility for Lifeline. The FCC pages at https://www.fcc.gov/consumers/guides/lifeline-support-affordable-communications are also helpful, but includes antiquated rules without the adjustments made in 2016.
# This site also seems helpful: https://nationalverifier.service-now.com/lifeline. 
# While the monetary amount of the Lifeline subsidy is relatively low, at $9.25/month, acceptance into the program allows low-income families to gain access to much cheaper telephone plans than are available on the open market. These options were expanded significantly under the Obama administration, so a popular alternative name for this program is simply "Obamaphone." Providers of these plans typically offer plans at no cost or at a very cheap cost (around $5/month), meaning that the providers get about $10-$15 per month from a combination of fees that consumers directly pay and subsidies that they receive from the government program. Low-incoem families therefore save the difference between what a similar plan would cost on the open market and the fee they pay.
# While in previous simulators, we have only modeled the subsidy as a reduction, for the MTRC and for the FRS beginning in 2021, we will be modeling the total savings families receive.
#
# Lifeline program - New Hampshire
# The Lifeline program had 12,000 low-income subscribers in New Hampshire in 2018, according to https://docs.fcc.gov/public/attachments/DOC-362272A1.pdf (Table 2.8). Only one discount is available per household. To estimate take-up, we could determine how many individuals would qualify based on income and/or categorical eligiblity, use that numberas the denominator to determine a take-up percentage, and randomly assign take up across New HEIGHTS based on that take-up rate.

sub lifeline
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};

    # outputs created
    our $lifeline_subsidy = 9.25;       #   The monthly subsidy for those participating in the Lifeline program. In previous versions of this code, this was the only reduction we modeled, and for a generic Lifeline plan.
	our $lifeline_cost = 0; #In New Hampshire, Assurance wireless is one of at least several companies that offer a free voice, text, and data wireless or landline plan. They also provide similar services in other states.
    our $lifeline_inc_limit = 1.35;     #   The income eligibility limit as a % of federal poverty guideline

    # outputs calculated in macro
    our $lifeline_recd = 0;             #   The federal subsidy applied to a family’s phone bill via participation in the Lifeline program. While this code will return this as the primary output, similar to previous codes, it will be used in a different way in the "other" code, in that it will use the receipt of ANY lifeline subsidy as meaning that a family will access savings such that they are paying the lifeline_cost for cellphone service instead of market-rate cellphone costs. 

    # 1: Check for Lifeline flag
    #
    if ($in->{'lifeline'} == 0) {
        $lifeline_recd = 0;
    } else {
        #
        # 2: Check for Determine subsidy if eligible
        #
        # Eligibility criteria based on requirements listed in Federal Register / Vol. 77, No. 42 / Friday, March 2, 2012, § 54.409, with adjustments based on changes as part of the Lifeline modernization plan enacted in 2016 (see https://www.fcc.gov/general/lifeline-program-low-income-consumers). 
		# This definition matches gross income as defined by federal taxes. This is the income to use accordign to Lifeline regulations.
		if (($out->{'gross_income1'} + $out->{'gross_income2'} + $out->{'gross_income3'} + $out->{'gross_income4'})/ $in->{'fpl'} <= $lifeline_inc_limit || $out->{'hlth_cov_parent'} eq 'Medicaid' || $out->{'hlth_cov_parent'} eq 'Medicaid and private' || $out->{'hlth_cov_child1'} eq 'Medicaid' || $out->{'hlth_cov_child2'} eq 'Medicaid' || $out->{'hlth_cov_child3'} eq 'Medicaid'   || $out->{'hlth_cov_child4'} eq 'Medicaid' || $out->{'hlth_cov_child5'} eq 'Medicaid' || $out->{'fsp_recd'} > 0 || $out->{'housing_recd'} > 0 || $out->{'ssi_recd'} > 0) {
			$lifeline_recd = $lifeline_subsidy * 12;
		} else {
			$lifeline_recd = 0;
		}

	}

	#debugging:
	#foreach my $debug (qw(lifeline_recd lifeline_cost)) {
	#	print $debug.": ".${$debug}."\n";
	#}
	
  # outputs
    foreach my $name (qw(lifeline_recd lifeline_cost)) {
       $out->{$name} = ${$name};
    }
	
}

1;