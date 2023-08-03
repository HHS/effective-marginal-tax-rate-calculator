#!/usr/bin/env perl

open(STDERR, ">&STDOUT");
#use DBI; #this line refers to a package that is no longer needed now that PHP is doing all the database calls. But at least locally, running Perl on the Windows command line did not return an error here, while running on the bash shell did return an error here.
use POSIX;
use Getopt::Long;

# get all the parameters from the command line
my $result = GetOptions ( 
						"dir=s" => \$frs_dir,
						"budget" => \$budget,
						"single" => \$single,
						"def=s" => \%in 
					 );

#while(($key, $value) = each(%in)) {
#	print $key."=".$value."\n";
#}

require "$frs_dir/lib/frs.pm";
# create a new simulator
my $frs = Frs->new();
#Removing Perl DB commands:
# my $dbh = $frs->dbhConnect('DBI:mysql:database=FRS;host=localhost;port:8889','root','root');

$frs->{'in'} = \%in;
$in  = $frs->{'in'};
$out = $frs->{'out'};

#Too much on the command line fix: Then, grab the additional arguments from the .pl file created in page_8.php.
#Turn this on or off depending on if you want to run this strictly from the command line.
#turning off for debugging 3/31.
#if (1==0) {
	require "$frs_dir/temp/".$in->{'id'}."_inputs.pl";
	&long_inputs($frs);
#}

#TODO DELETE WHEN this shows the program can handle long inputs.
#Testing long inputs:
my $test_add = $in->{'test1'} + $in->{'test2'};
print "test addition: $test_add \n";

# load all available national-level subroutines
my $dirname = "$frs_dir/lib/" . $in->{"year"};
opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
while ( defined (my $file = readdir DIR) ) {
	if($file =~ /.*\.pl$/) { require "$dirname/$file"; }
}
closedir(DIR);

# load all available state-level subroutines
$dirname = "$dirname/" . $in->{'state'};
opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
while ( defined (my $file = readdir DIR) ) {
    if($file =~ /.*\.pl$/) { require "$dirname/$file"; }
}
closedir(DIR);

# load the default values for this state/year (this is defined in the state's default.pl file)
# this assigns order, chart, public_csv, private_csv, and csv_labels to the $frs object
&defaults($frs);

# calculate universal values based on inputs (family size, etc.)
$frs->setGeneral();

# Are we just calculating the basic family budget?  (This is the level at which the family breaks even.)
if($budget) {
	$min = floor($in->{'min_income'});
	#$max = 2 * ceil($in->{'max_income'});
	$max = 1000000;
	$net_income = $positive_value = $negative_value = 0;
	$continue = 1;
	$count = 0;
	while($continue > 0 && $count <= 100) {
		$earnings = round(($max - $min) / 2) + $min;

	    $out->{'earnings'} = $earnings;
	    $out->{'earnings_mnth'} = $out->{'earnings'}/12;            # monthly earnings
	    $out->{'earnings_week'} = $out->{'earnings'}/52;            # weekly earnings

	  # run each of the modules that's been requested
	    foreach my $function (@{$frs->{'order'}}) {
	        if (defined &$function) { &$function($frs); }
	    }

		if($in->{'year'} < 2006) {
		  # other expenses calculation
		    if($in->{'other_override'}) {
		        $out->{'other_expenses'} = $in->{'other_override_amt'} * 12;
		    }
		    elsif($in->{'state'} eq 'VT') {
		        $out->{'other_expenses'} = &pos_sub(0.27 * ($out->{'food_expenses'} + ($in->{'fmr'} * 12)), $out->{'lifeline_recd'});
		    }
		    else {
		        $out->{'other_expenses'} = 0.27 * ($out->{'food_expenses'} + ($in->{'fmr'} * 12));
		    }
		}
	
	  # set debt_payment to a yearly value, instead of monthly
	    $out->{'debt_payment'} = 12 * $in->{'debt_payment'};
	    
	  # calculate net_income
	    # starting with 2006 simulators, we're handling taxes and credits differently, so these calculations are changing
		$income = $out->{'earnings'} + $out->{'child_support_recd'} + $out->{'interest'} +
						   $out->{'tanf_recd'} + $out->{'fsp_recd'} + $out->{'liheap_recd'} + $out->{'heap_recd'} + $out->{'federal_tax_credits'} +
						   $out->{'state_tax_credits'} + $out->{'local_tax_credits'};
		$expenses = $out->{'tax_before_credits'} + $out->{'payroll_tax'} + $out->{'rent_paid'} + $out->{'child_care_expenses'} + $out->{'food_expenses'} + 
							 $out->{'trans_expenses'} + $out->{'other_expenses'} + $out->{'health_expenses'} + $out->{'debt_payment'};
	    $net_income = $income - $expenses;

	    print "count$count|$count\n";
	    print "earnings$count|$earnings\n";
	    print "net_income$count|$net_income\n";
	    print "max$count|$max\n";
	    print "min$count|$min\n";
	    print "continue$count|$continue\n";
	    
	  # if we were doing this round to test the previous value...
	    if($continue == 2) {
	    	$negative_value = $net_income;
	    	$negative_value_out = $out;
	    	if(abs($negative_value) < abs($positive_value)) {
	    		$budget_values = $negative_value_out;
	    	}
	    	else {
	    		$budget_values = $positive_value_out;
	    		$earnings++; # I'm not sure what this does
	    	}
	    	$continue = 0;
	    }
	    elsif($continue == 3) {
	    	$positive_value = $net_income;
	    	$positive_value_out = $out;
	    	if(abs($negative_value) < abs($positive_value)) {
	    		$budget_values = $negative_value_out;
	    	}
	    	else {
	    		$budget_values = $positive_value_out;
	    		$earnings++; # I'm not sure what this does
	    	}
	    	$continue = 0;
	    }
	    elsif($net_income > 0 && ($earnings == $max || $earnings == $min)) {
	    	$max = $min = $earnings - 1;
	    	$continue = 2;
	    	$positive_value = $net_income;
	    	$positive_value_out = $out;
	    }
	    elsif($net_income < 0 && ($earnings == $max || $earnings == $min)) {
	    	$max = $min = $earnings + 1;
	    	$continue = 3;
	    	$negative_value = $net_income;
	    	$negative_value_out = $out;
	    }
	    else {
		  # determine next value
		    if($net_income < 0) {
		    	$min = $earnings;
		    }
		    else {
		    	$max = $earnings;
			}
		}
	    $count++;
	}
    foreach my $variable (@{$frs->{'chart'}}) { print $variable . '|' . ($out->{$variable} ? $out->{$variable} : 0) . "\n"; }
    print "count|$count\n";
    print "positive_value|$positive_value\n";
    print "negative_value|$negative_value\n";
    print "earnings|$earnings\n";
    print "max|$max\n";
    print "min|$min\n";
    print "continue|$continue\n";
    print "mode|" . $in->{'mode'} . "\n";
}

# Are we running a single income level for testing purposes?
elsif($single) {

	$frs->{'debug'} = ();
#	my @debug_array;

  # run all scripts for this earning level only	
    $out->{'earnings'} = $in->{'earnings'};
    $out->{'earnings_mnth'} = $out->{'earnings'}/12;            # monthly earnings
    $out->{'earnings_week'} = $out->{'earnings'}/52;            # weekly earnings
    
    @inputs = sort(keys(%{$frs->{'in'}}));
	foreach my $name (@inputs) {
		printf("%s|%s|%s|%s\n", 'input', 'input', $name, $frs->{'in'}->{$name});
	}

  # run each of the modules that's been requested
    foreach my $function (@{$frs->{'order'}}) {
        if (defined &$function) { &$function($frs); }
		foreach my $variable (@{$frs->{'debug'}->{$function}->{'output'}}) {
			printf("%s|%s|%s|%s\n", $function, 'output', $variable->{'name'}, $variable->{'value'});
		}
		foreach my $variable (@{$frs->{'debug'}->{$function}->{'detail'}}) {
			printf("%s|%s|%s|%s\n", $function, 'detail', $variable->{'name'}, $variable->{'value'});
		}
    }
}

# Otherwise, run through from min to max
else {
	# open up files for output
	my $dir = "$frs_dir/temp";
	my $csv_id = $in->{'id'};
	open(PRIVATE, ">$dir/$csv_id" . "_private.csv");
	open(PUBLIC, ">$dir/$csv_id" . "_public.csv");
	open(CHART, ">$dir/$csv_id.csv");
	
	# output values from $in to CSV file
	$now_string = localtime;
	print PUBLIC <<EOF;
NCCP's Family Resource Simulator: $in->{'state'} $in->{'year'} (nccp.org/tools/frs).
Output Generated $now_string.  Results reflect user choices.

EOF
	foreach my $variable (@{$frs->{'public_csv'}}) { print PUBLIC $frs->{'csv_labels'}{$variable} . ","; }
	print PUBLIC "\n";
	
	# get column headers for variables to be output
	print PRIVATE join(',', @{$frs->{'private_csv'}});
	print PRIVATE "\n";
	print CHART join(',',@{$frs->{'chart'}});
	print CHART "\n";
	
	my $last_cc_subsidized_flag = 0;
		
	# reset flags
	$in->{"last_received_sec8"}      = 0;
	$in->{"hlth_parents_ineligible"} = 0;
	$in->{"refused_subsidy_level"}   = 0;
	$in->{"last_cc_subsidized_flag"} = 0;

	# loop from minimum income to maximum income with proper interval
	# first, fix the minimum level
	# my $min = $in->{'interval'} * floor($in->{'min_income'} / $in->{'interval'});
	#for (my $earnings=$min; $earnings<=$in->{'max_income'}; $earnings+=$in->{'interval'}) { #This is the for-loop for the FRS. For the MTRC, we are only comparing simulations for current earnings, future earnings, and some alternate scenarios.
	$out->{'scenario'} = 'start';
	
	for (my $iteration=1; $iteration<=6; $iteration+=1) { 	
	  #$out->{'earnings'} = $earnings;								# yearly earnings for the FRS 9(not the MTRC)
	  #$out->{'earnings_mnth'} = $out->{'earnings'}/12;            # monthly earnings for the FRS 9(not the MTRC)
	  #$out->{'earnings_week'} = $out->{'earnings'}/52;            # weekly earnings for the FRS 9(not the MTRC)
		
		#Now we set up iterations for alternate versions of the projected wage scenario. These are flags, reset to 0 for each iteration, that we adjust to see what happens if the household uses child care options that may lower their child care costs.
		$out->{'ccdf_alt'} = 0;
		$out->{'prek_alt'} = 0;
		$out->{'headstart_alt'} = 0;
		$out->{'earlyheadstart_alt'} = 0;

		if ($iteration == 1) {
			#This is the current earnings scenario.
			$out->{'scenario'} = 'current';
		} elsif ($iteration == 2) {
			$out->{'scenario'} = 'future';
		} elsif ($iteration == 3) {
			$out->{'scenario'} = 'future';
			$out->{'ccdf_alt'} = 1;
		} elsif ($iteration == 4) {
			$out->{'scenario'} = 'future';
			$out->{'prek_alt'} = 1;
		} elsif ($iteration == 5) {
			$out->{'scenario'} = 'future';
			$out->{'headstart_alt'} = 1;
		} elsif ($iteration == 6) {
			$out->{'scenario'} = 'future';
			$out->{'earlyheadstart_alt'} = 1;
		}

	
	  # run each of the modules that's been requested
	    foreach my $function (@{$frs->{'order'}}) {
	        if (defined &$function) { &$function($frs); }
	    }
	
	  # determine whether family has stopped enrolling in CCDF although still eligible to
	    if($out->{'ccdf_eligible_flag'} == 1 && $out->{'cc_subsidized_flag'} == 0 && $in->{"last_cc_subsidized_flag"} == 1) {
	        $in->{"refused_subsidy_level"} = $earnings;
	    }
	    elsif($out->{'ccdf_eligible_flag'} == 1 && $out->{'cc_subsidized_flag'} == 0 && $in->{'refused_subsidy_level'} == 0) {
	    	$in->{'always_refused_subsidy'} = 1;
	    }
	    unless($out->{'cc_subsidized_flag'}) { $out->{'cc_subsidized_flag'} = 0; }
	    $in->{"last_cc_subsidized_flag"} = $out->{'cc_subsidized_flag'};
	
	  # set debt_payment to a yearly value, instead of monthly
	    $out->{'debt_payment'} = 12 * $in->{'debt_payment'};

		if($in->{'year'} < 2006) {
		  # other expenses calculation
		    if($in->{'other_override'}) {
		        $out->{'other_expenses'} = $in->{'other_override_amt'} * 12;
		    }
		    elsif($in->{'state'} eq 'VT') {
		        $out->{'other_expenses'} = &pos_sub(0.27 * ($out->{'food_expenses'} + ($in->{'fmr'} * 12)), $out->{'lifeline_recd'});
		    }
		    else {
		        $out->{'other_expenses'} = 0.27 * ($out->{'food_expenses'} + ($in->{'fmr'} * 12));
		    }
		}
		
	  # calculate any additional outputs
	    $out->{'taxes'} = $out->{'payroll_tax'} + $out->{'federal_tax'} + $out->{'state_tax'} + $out->{'local_tax'} - $out->{'ctc_total_recd'};
	    $out->{'earnings_plus_interest'} = $out->{'earnings'} + $out->{'interest'};
	    $out->{'earnings_posttax'} = $out->{'earnings_plus_interest'} - $out->{'taxes'};
	    
	    # starting with 2006 simulators, we're handling taxes and credits differently, so these calculations are changing
	    if($in->{'year'} < 2006) {
			$out->{'income'} = $out->{'earnings_posttax'} + $out->{'child_support_recd'} + $out->{'eitc_recd'} + 
							   $out->{'state_eic_recd'} + $out->{'local_eic_recd'} + $out->{'cc_credit_recd'} + $out->{'state_cadc_recd'} + 
							   $out->{'tanf_recd'} + $out->{'fsp_recd'} + $out->{'nutrition_recd'};
			$out->{'expenses'} = $out->{'rent_paid'} + $out->{'child_care_expenses'} + $out->{'food_expenses'} + 
								 $out->{'trans_expenses'} + $out->{'other_expenses'} + $out->{'health_expenses'} + 
								 $out->{'debt_payment'};
		} elsif ($in->{'user_prototype'} == 1) {
			#We calculate net resources a little differently in the MTRC than in the FRS. Differences include:
			#1. including sales tax in the "other expenses.
			#2. including phone expenses separately.
			
			$out->{'income'} = $out->{'earnings'} + $out->{'child_support_recd'} + $out->{'interest'} +
							   $out->{'tanf_recd'} + $out->{'ssi_recd'} + $out->{'liheap_recd'} + 
							   $out->{'federal_tax_credits'} + $out->{'state_tax_credits'} + $out->{'local_tax_credits'} + $out->{'ui_recd'} + $out->{'gift_income'}; #Note that fsp_recd has been removed, see note in food.pl about that.
			$out->{'expenses'} = $out->{'tax_before_credits'} + $out->{'payroll_tax'}  + $out->{'rent_paid'} + 
								 $out->{'child_care_expenses'} + $out->{'food_expenses'} + $out->{'trans_expenses'} + 
								 $out->{'other_expenses'} + $out->{'phone_expenses'} + $out->{'health_expenses'} +  
								 $out->{'disability_expenses'} + $out->{'afterschool_expenses'} + $out->{'other_regular_payments'};
		
		# For states that use LIHEAP funds to reduce energy payments rather than providing cash assistance directly to households, we reduce income by the LIHEAP amount to avoid double-counting LIHEAP benefits:
			if($in->{'state'} eq 'DC' || $in->{'state'} eq 'NH' || $in->{'state'} eq 'KY' || $in->{'state'} eq 'PA') {
					$out->{'income'} = $out->{'income'} - $out->{'liheap_recd'} ;
			}			
		} else {
			#This is code for NCCP's FRS tool and not the MTRC.
			$out->{'income'} = $out->{'earnings'} + $out->{'child_support_recd'} + $out->{'interest'} +
							   $out->{'tanf_recd'} + $out->{'ssi_recd'} + $out->{'fsp_recd'} + $out->{'liheap_recd'} + $out->{'heap_recd'} + $out->{'federal_tax_credits'} +
							   $out->{'state_tax_credits'} + $out->{'local_tax_credits'};
			$out->{'expenses'} = $out->{'tax_before_credits'} + $out->{'payroll_tax'} + $out->{'salestax'} + $out->{'rent_paid'} + $out->{'child_care_expenses'} + $out->{'food_expenses'} + 
								 $out->{'trans_expenses'} + $out->{'other_expenses'} + $out->{'health_expenses'} + $out->{'disability_expenses'} + $out->{'afterschool_expenses'} + $out->{'debt_payment'};
		
		# For DC 2017, we are using liheap_recd to reduce rent_paid, so it cannot be considered a resource on top of the reduction in rent it has already provided. Same is true for KY in 2020:
			if($in->{'year'}>= 2017 && ($in->{'state'} eq 'DC' || $in->{'state'} eq 'KY')) {
					$out->{'income'} = $out->{'income'} - $out->{'liheap_recd'} ;
			}
		}
	    $out->{'net_resources'} = $out->{'income'} - $out->{'expenses'};

	  # for the eligibility chart
	  	@variable = qw(child_number family_structure parent_number ccdf fsp hlth sec8 wic nsbp ostp prek ssi sanctioned tanf eitc state_eitc ctc fpl cc_credit fsp_alt state child1_age child2_age child3_age state_cadc local_cadc state_ctc fsmp frpl fuel_source family_size disability_medical_expenses_mnth);
	    foreach $variable (@variable) {
	        $out->{$variable} = $in->{$variable};
	    }
	
	  # output this row to the CSV files
	    foreach my $variable (@{$frs->{'public_csv'}}) { print PUBLIC ($out->{$variable} ? $out->{$variable} : 0) . ","; }
	    print PUBLIC "\n";
	    foreach my $variable (@{$frs->{'private_csv'}}) { print PRIVATE ($out->{$variable} ? $out->{$variable} : 0) . ","; }
	    print PRIVATE "\n";
	    foreach my $variable (@{$frs->{'chart'}}) { print CHART ($out->{$variable} ? $out->{$variable} : 0) . ","; }
	    print CHART "\n";
	}
	close CHART;
	close PUBLIC;
	close PRIVATE;

	print "refused_subsidy_level|" . $in->{'refused_subsidy_level'} . "\n";
	print "always_refused_subsidy|" . $in->{'always_refused_subsidy'} . "\n";

}

#####################################################################
# UTILITY FUNCTIONS
#####################################################################

# returns the smallest value of a list of values
sub least
{
    my @numbers = @_;
    my $min = $numbers[0];
    foreach my $i (@numbers) {
        if($i < $min) { $min = $i; }
    }
    return $min;
}

#returns the greatest value of a list of numbers
sub greatest
{
    my @numbers = @_;    
    my $max = $numbers[0];
    foreach my $i (@numbers)
    {
        if($i > $max) { $max = $i; }
    }
    return $max;
}

# subtracts $var2 from $var1 and returns the result, 
# returning 0 if the result is negative
sub pos_sub
{
    my ($var1, $var2) = @_;    
    my $result = $var1 - $var2;
    if($result < 0) { return 0; }
    else { return $result; }
}

sub round {
    my($number) = shift;
    return int($number + .5 * ($number <=> 0));
}

# rounds input to the nearest 50
sub round_to_nearest_50 {
    my($number) = shift;
    $number = $number/50.0;
    return 50 * (($number == int($number)) ? $number : int($number + 1));
}
