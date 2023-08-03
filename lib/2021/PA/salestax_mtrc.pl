#=============================================================================#
#  Sales Tax – 2021 – PA
#=============================================================================#
#
# No inputs or outputs referenced in this module. It is used simply to generate sales tax policy information (if sales tax exist in a state) to feed to other modules.
#
#=============================================================================#

sub salestax
{
    my $self = shift;
    my $in = $self->{'in'};
    my $out = $self->{'out'};
  
    # outputs created
    our $statesalestax_rate_other = .06;	# The PA sales tax on tangible personal property, according to https://www.revenue.pa.gov/GeneralTaxInformation/Tax%20Types%20and%20Information/SUT/Pages/default.aspx.
    our $localsalestax_rate_allegheny = .01;	# The local sales tax on tangible personal property for Allegheny County, according to https://www.revenue.pa.gov/GeneralTaxInformation/Tax%20Types%20and%20Information/SUT/Pages/default.aspx. If we are moving this to a database, this should be added to the General tab, based on location identifier. 
    our $localsalestax_rate_philadelphia = 0.02;     # The local sales tax on tangible personal property for Allegheny County, according to https://www.revenue.pa.gov/GeneralTaxInformation/Tax%20Types%20and%20Information/SUT/Pages/default.aspx. If we are moving this to a database, this should be added to the General tab, based on location identifier.
    our $salestax_rate_other = 0;		# The applicable sales tax on tangible personal property, calculated below. This includes local sales taxes where they are applicable. 
	
    # outputs calculated in macro
    our $otherplussalestax = 0;
    our $salestaxbase = 0;
    our $salestax = 0;

    # The only applicable sales tax rate for the purposes of the FRS/MTRC is a tax rate on tangible personal property, and these expenditures are captured completely in the “other” expenses calculation. 
	#
	# Combining state and local taxes:
	$salestax_rate_other = $statesalestax_rate_other + $localsalestax_rate_allegheny; #for now, we'll just use Allegheny. But we need to revise if we add other localities.

	#We use this sales tax rate in the "other" Perl model calculation.

	#debugging
	#foreach my $debug (qw(salestax_rate_other)) {
	#	print $debug.": ".${$debug}."\n";
	#}


    # outputs
    foreach my $name (qw(salestax_rate_other)) {
       $out->{$name} = ${$name};
    }
	
}

1;