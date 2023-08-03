#=============================================================================#
#  Sales Tax – 2021 – DC
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
    our $salestax_rate_other = .06;		# The applicable sales tax on tangible personal property and selected services. There are also other sales taxes for different types of activities (e.g. 10% on restaurant meals, 10.25% on liquor), but we are considering those luxury items in the FRS/MTRC model and therefore using this lower rate. See https://cfo.dc.gov/page/tax-rates-and-revenues-sales-and-use-taxes-alcoholic-beverage-taxes-and-tobacco-taxes.

    # In most places, the only applicable sales tax rate for the purposes of the FRS is a tax rate on tangible personal property, and these expenditures are captured completely in the “other” expenses calculation. It is important to consider what expenses are additionally included in state or local sales tax systems beyond the expenses captured in sales taxes, but in the case of NH, where there are no sales taxes whatsoever, this is irrelevant. Because later outcome mesaures include the salestax variable, though, we need to assign 0 values to these variables. 

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