<?php

#=========================================#
# Included in this file:                  #
#                                         #
# (1) line_taxes - UNUSED                 #
#                                         #
# (2) line_taxes_percent - UNUSED         #
#                                         #
# (3) line_all - PRIVATE                  #
#     resources before/after expenses     #
#                                         #
# (4) line_income_expenses                #
#     income/expenses line graph          #
#                                         #
# (5) line_resources                      #
#     resources after subtracting         #
#     expenses                            #
#                                         #
# (6) eligibility - PRIVATE               #
#     bar chart showing when benefits     #
#     are gained and lost                 #
#                                         #
# (7) income_only - UNUSED                #
#                                         #
# (8) income_only_no_health               #
#                                         #
# (9) expense_only                        #
#                                         #
# (10) master - UNUSED                    #
#                                         #
# (11) simplified_master - UNUSED         #
#                                         #
# (12) relative_expenses - UNUSED         #
#                                         #
# (13) relative_expenses_line -UNUSED     #
#                                         #
#=========================================#

#
# GENERAL PURPOSE FUNCTIONS
#
#######################################

function yLabelFormat($aLabel)
{
    if($aLabel < 1 && $aLabel > -1)
    {
        $aLabel = 0;
    }
    return '$' . $aLabel . 'K';
}

function yLabelFormatMnth($aLabel)
{
    if($aLabel < 1 && $aLabel > -1)
    {
        $aLabel = 0;
    }
    return '$' . $aLabel;
}

function yLabelFormatPercent($aLabel)
{
    if($aLabel < 1 && $aLabel > -1)
    {
        $aLabel = 0;
    }
    return $aLabel . '%';
}


#
# TAX LIABILITY LINE CHART
#
#######################################

function line_taxes (&$data, $size, &$graph, $time_span, $state, $year)
{
  // get calculated values (state income tax, federal income tax, local income tax)
    for($i = 0; $i < count($data{'earnings'}); $i++)
    {
        $data_payroll[$i] = $data{'payroll_tax'}[$i];
        $data_federal[$i] = $data{'federal_tax'}[$i] - $data{'eitc_recd'}[$i] - $data{'ctc_total_recd'}[$i];
        $data_state[$i] = $data{'state_tax'}[$i] - $data{'state_eic_recd'}[$i];
        $data_local[$i] = $data{'local_tax'}[$i] - $data{'local_eic_recd'}[$i];
        $data_all[$i] = $data_payroll[$i] + $data_federal[$i] + $data_state[$i] + $data_local[$i];
    }

  // Create linear plots
    $line_payroll = new LinePlot($data_payroll);
    $line_payroll->SetLegend("Payroll tax");
    $line_payroll->SetColor("#44A95E");
    $line_payroll->SetWeight(1);
    $graph->Add($line_payroll);

    $line_federal = new LinePlot($data_federal);
    $line_federal->SetLegend("Federal income tax");
    $line_federal->SetColor("#8D1BB2");
    $line_federal->SetWeight(1);
    $graph->Add($line_federal);

    $line_state = new LinePlot($data_state);
    $line_state->SetLegend("State income tax");
    $line_state->SetColor("#093A80");
    $line_state->SetWeight(1);
    $graph->Add($line_state);

    $line_local = new LinePlot($data_local);
    $line_local->SetLegend("Local income tax");
    $line_local->SetColor("#F26B09");
    $line_local->SetWeight(1);
    $graph->Add($line_local);

    $line_all = new LinePlot($data_all);
    $line_all->SetLegend("Total tax liability");
    $line_all->SetColor("black");
    $line_all->SetWeight(1);
    $line_all->SetStyle('dashed');
    $graph->Add($line_all);

  // Format the x axis labels
    $x_labels = $data{'earnings'};
    if($data{'earnings'}[1] - $data{'earnings'}[0] == 1)
    {
        array_walk($x_labels, create_function('&$v,$k', '$v = $v . "K";'));
    }
    $graph->xaxis->SetTickLabels($x_labels);

    $graph->title->Set("Family's Payroll and Income Tax Liability");
    $graph->yaxis->title->Set("Tax Liability");
    if(count($data{'earnings'}) > 12) {
        $graph->xaxis->SetTextTickInterval(round(count($data{'earnings'})/12));
    }

    $graph->AddLine(new PlotLine(HORIZONTAL,0,"red",1));

    if($time_span == "monthly")
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormatMnth');
    }
    else
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormat');
    }

    $graph->xaxis->SetPos("min");

}

#
# TAX LIABILITY LINE CHART - as percent of income
#
#######################################

function line_taxes_percent (&$data, $size, &$graph, $time_span, $state, $year)
{
  // get calculated values (state income tax, federal income tax, local income tax)
    for($i = 0; $i < count($data{'earnings'}); $i++)
    {
        if($data{'earnings'}[$i] == 0)
        {
            $data_payroll[$i] = 0;
            $data_federal[$i] = 0;
            $data_state[$i] = 0;
            $data_local[$i] = 0;
            $data_all[$i] = 0;
        }
        else
        {
            $data_payroll[$i] = $data{'payroll_tax'}[$i] / $data{'earnings'}[$i] * 100;
            $data_federal[$i] = ($data{'federal_tax'}[$i] - $data{'eitc_recd'}[$i] - $data{'ctc_total_recd'}[$i]) / $data{'earnings'}[$i] * 100;
            $data_state[$i] = ($data{'state_tax'}[$i] - $data{'state_eic_recd'}[$i]) / $data{'earnings'}[$i] * 100;
            $data_local[$i] = ($data{'local_tax'}[$i] - $data{'local_eic_recd'}[$i]) / $data{'earnings'}[$i] * 100;
            $data_all[$i] = $data_payroll[$i] + $data_federal[$i] + $data_state[$i] + $data_local[$i];
        }
    }

  // Create linear plots
    $line_payroll = new LinePlot($data_payroll);
    $line_payroll->SetLegend("Payroll tax");
    $line_payroll->SetColor("#44A95E");
    $line_payroll->SetWeight(1);
    $graph->Add($line_payroll);

    $line_federal = new LinePlot($data_federal);
    $line_federal->SetLegend("Federal income tax");
    $line_federal->SetColor("#8D1BB2");
    $line_federal->SetWeight(1);
    $graph->Add($line_federal);

    $line_state = new LinePlot($data_state);
    $line_state->SetLegend("State income tax");
    $line_state->SetColor("#093A80");
    $line_state->SetWeight(1);
    $graph->Add($line_state);

    $line_local = new LinePlot($data_local);
    $line_local->SetLegend("Local income tax");
    $line_local->SetColor("#F26B09");
    $line_local->SetWeight(1);
    $graph->Add($line_local);

    $line_all = new LinePlot($data_all);
    $line_all->SetLegend("Total tax liability");
    $line_all->SetColor("black");
    $line_all->SetWeight(1);
    $line_all->SetStyle("dotted");
    $graph->Add($line_all);

  // Format the x axis labels
    $x_labels = $data{'earnings'};
    if($data{'earnings'}[1] - $data{'earnings'}[0] == 1)
    {
        array_walk($x_labels, create_function('&$v,$k', '$v = $v . "K";'));
    }
    $graph->xaxis->SetTickLabels($x_labels);

    $graph->title->Set("Family's Payroll and Income Tax Liability (as % of Earnings)");
    $graph->yaxis->title->Set("Tax Liability");
    if(count($data{'earnings'}) > 12) {
        $graph->xaxis->SetTextTickInterval(round(count($data{'earnings'})/12));
    }

    $graph->yaxis->SetLabelFormatCallback('yLabelFormatPercent');

    $graph->AddLine(new PlotLine(HORIZONTAL,0,"red",1));

    $graph->xaxis->SetPos("min");

}


#
# RESOURCES BEFORE/AFTER EXPENSES LINE CHART
#
#######################################

function line_all (&$data, $size, &$graph, $time_span, $state, $year)
{

  # reduce the number of x-labels, if necessary
    if($size == "small") { $bars = 11; }
    else { $bars = 11; }

    $points = count($data{'earnings'});
    if($bars >= $points) { $interval = 1; }
    else {
        $interval = ceil( $points / $bars );
    }

    if($time_span == "monthly") { $interval *= 100; }

  // get the difference between income and expenses
    for ($i = 0; $i < count($data{'earnings'}); $i++) {
        if($data{'earnings'}[$i] % $interval == 0) {
            if($time_span == "monthly") {
                $tick_labels[$i] = $data{'earnings'}[$i];
            }
            else {
                $tick_labels[$i] = $data{'earnings'}[$i] . "K";
            }
        }
        else {
            $tick_labels[$i] = '';
        }
        $all[$i] = $data{'earnings_posttax'}[$i] + $data{'child_support_recd'}[$i] + $data{'eitc_recd'}[$i] + $data{'state_eic_recd'}[$i] + $data{'local_eic_recd'}[$i] + $data{'cc_credit_recd'}[$i] + $data{'state_cadc_recd'}[$i] + $data{'tanf_recd'}[$i] + $data{'fsp_recd'}[$i] + $data{'nutrition_recd'}[$i] + $data{'ssi_recd'}[$i] + $data{'ctc_total_recd'}[$i];
        $difference[$i] = $all[$i] - $data{'rent_paid'}[$i] - $data{'child_care_expenses'}[$i] - $data{'food_expenses'}[$i] - $data{'trans_expenses'}[$i] - $data{'other_expenses'}[$i] - $data{'health_expenses'}[$i] - $data{'debt_payment'}[$i] - $data{'salestax'}[$i] - $data{'disability_expenses'}[$i];
    }

  // Create the linear plots
    $line_all = new LinePlot($all);
    $line_all->SetLegend("Resources before\nsubtracting\nexpenses");
    $line_all->SetColor("#093A80");
    $line_all->SetWeight(1);
    $graph->Add($line_all);

    $line_difference = new LinePlot($difference);
    $line_difference->SetLegend("Resources after\nsubtracting\nexpenses");
    $line_difference->SetColor("#2D8343");
    $line_difference->SetWeight(1);
    $graph->Add($line_difference);

    $graph->xaxis->SetTickLabels($data{'earnings'});

    $graph->title->Set("Resources Before and After Subtracting Basic Expenses");
    $graph->yaxis->title->Set("Resources");
    if(count($data{'earnings'}) > 12) {
        $graph->xaxis->SetTextTickInterval(round(count($data{'earnings'})/12));
    }

  // back to basics -- do it as a line graph
    $breakeven_flag = 0;
    $y2 = $difference[0];
    foreach ($difference as $x1 => $y1)
    {
        if($y2 < 0 && $y1 >= 0)
        {
          // see whether this point or the last one was closer to the x-axis
            if( (0 - $y2) < ($y1 - 0) )
            {
                $breakeven_y[$x1 - 1] = 0;
                $breakeven_y[$x1] = 'x';
                $breakeven_flag = 1;
            }
            else
            {
                $breakeven_y[$x1] = 0;
                $breakeven_flag = 1;
            }
        }
        else
        {
            $breakeven_y[] = 'x';
        }
        $y2 = $y1;
    }

    if($breakeven_flag)
    {
        $breakeven = new LinePlot($breakeven_y);
        $breakeven->mark->SetType(MARK_STAR);
        if($size == "large")
        {
            $breakeven->mark->SetSize(5);
        }
        $breakeven->SetLegend("Breaking even");
        $graph->Add($breakeven);
    }

    if($time_span == "monthly")
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormatMnth');
    }
    else
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormat');
    }

    $graph->AddLine(new PlotLine(HORIZONTAL,0,"red",1));

    $graph->xaxis->SetPos("min");
    $graph->xaxis->HideTicks();
    $graph->xaxis->SetTextTickInterval(1);
    $graph->xaxis->SetTickLabels($tick_labels);

}

#
# RESOURCES AFTER EXPENSES LINE CHART
#
#######################################

function line_resources (&$data, $size, &$graph, $time_span, $state, $year)
{

  # reduce the number of x-labels, if necessary
    if($size == "small") { $bars = 11; }
    else { $bars = 11; }

    $points = count($data{'earnings'});
    if($bars >= $points) { $interval = 1; }
    else {
        $interval = ceil( $points / $bars );
    }

    if($time_span == "monthly") { $interval *= 100; }

  // get the difference between income and expenses
    for ($i = 0; $i < count($data{'earnings'}); $i++) {
        if($data{'earnings'}[$i] % $interval == 0) {
            if($time_span == "monthly") {
                $tick_labels[$i] = $data{'earnings'}[$i];
            }
            else {
                $tick_labels[$i] = $data{'earnings'}[$i] . "K";
            }
        }
        else {
            $tick_labels[$i] = '';
        }
        if($year < 2006) {
	        $all[$i] = $data{'earnings_posttax'}[$i] + $data{'child_support_recd'}[$i] + $data{'eitc_recd'}[$i] + $data{'state_eic_recd'}[$i] + $data{'local_eic_recd'}[$i] + $data{'cc_credit_recd'}[$i] + $data{'state_cadc_recd'}[$i] + $data{'local_cadc_recd'}[$i] + $data{'state_ctc_recd'}[$i] + $data{'tanf_recd'}[$i] + $data{'fsp_recd'}[$i] + $data{'nutrition_recd'}[$i] + $data{'ssi_recd'}[$i];
    	    $difference[$i] = $all[$i] - $data{'rent_paid'}[$i] - $data{'child_care_expenses'}[$i] - $data{'food_expenses'}[$i] - $data{'trans_expenses'}[$i] - $data{'other_expenses'}[$i] - $data{'health_expenses'}[$i] - $data{'debt_payment'}[$i]  - $data{'salestax'}[$i] - $data{'disability_expenses'}[$i];
        	$breakeven[$i] = 0;
        } else {
			$difference[$i] = $data{'net_resources'}[$i];
        	$breakeven[$i] = 0;
        }
    }

  // Create the linear plot
    $line_difference = new LinePlot($difference);
    $line_difference->SetLegend("Net resources\n(resources minus\nexpenses)");
    $line_difference->SetColor("#2D8343");
    $line_difference->SetWeight(1);
    $graph->Add($line_difference);

  // Create a dummy linear plot for the breakeven line on the legend
    $line_breakeven = new LinePlot($breakeven);
    $line_breakeven->SetLegend("Breakeven line\n   ");
    $line_breakeven->SetColor("red");
    $line_breakeven->SetWeight(1);
    $graph->Add($line_breakeven);

    $graph->xaxis->SetTickLabels($data{'earnings'});

    $graph->title->Set("Net Family Resources (resources minus expenses)");
    $graph->yaxis->title->Set("Net Resources");
    if(count($data{'earnings'}) > 12) {
        $graph->xaxis->SetTextTickInterval(round(count($data{'earnings'})/12));
    }

  // back to basics -- do it as a line graph
    $breakeven_flag = 0;
    $y2 = $difference[0];
    foreach ($difference as $x1 => $y1)
    {
        if($y2 < 0 && $y1 >= 0)
        {
          // see whether this point or the last one was closer to the x-axis
            if( (0 - $y2) < ($y1 - 0) )
            {
                $breakeven_y[$x1 - 1] = 0;
                $breakeven_y[$x1] = 'x';
                $breakeven_flag = 1;
            }
            else
            {
                $breakeven_y[$x1] = 0;
                $breakeven_flag = 1;
            }
        }
        else
        {
            $breakeven_y[] = 'x';
        }
        $y2 = $y1;
    }

    if($breakeven_flag)
    {
        $breakeven = new LinePlot($breakeven_y);
        $breakeven->mark->SetType(MARK_STAR);
        if($size == "large")
        {
            $breakeven->mark->SetSize(5);
        }
        $breakeven->SetLegend("Breakeven point\n(where resources\nequal expenses)");
        $graph->Add($breakeven);
    }

    if($time_span == "monthly")
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormatMnth');
    }
    else
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormat');
    }

    $graph->AddLine(new PlotLine(HORIZONTAL,0,"red",1));

    $graph->xaxis->SetPos("min");
    $graph->xaxis->HideTicks();
    $graph->xaxis->SetTextTickInterval(1);
    $graph->xaxis->SetTickLabels($tick_labels);

}

#
# INCOME/EXPENSES LINE CHART
#
#######################################

function line_income_expenses (&$data, $size, &$graph, $time_span, $state, $year)
{

  # reduce the number of x-labels, if necessary
    if($size == "small") { $bars = 11; }
    else { $bars = 11; }

    $points = count($data{'earnings'});
    if($bars >= $points) { $interval = 1; }
    else {
        $interval = ceil( $points / $bars );
    }

    if($time_span == "monthly") { $interval *= 100; }

  // create labels, and get the difference between income and expenses
    for ($i = 0; $i < count($data{'earnings'}); $i++) {
        if($data{'earnings'}[$i] % $interval == 0) {
            if($time_span == "monthly") {
                $tick_labels[$i] = $data{'earnings'}[$i];
            }
            else {
                $tick_labels[$i] = $data{'earnings'}[$i] . "K";
            }
        }
        else {
            $tick_labels[$i] = '';
        }
        $income[$i] = $data{'earnings_posttax'}[$i] + $data{'child_support_recd'}[$i] + $data{'eitc_recd'}[$i] + $data{'state_eic_recd'}[$i] + $data{'local_eic_recd'}[$i] + $data{'cc_credit_recd'}[$i] + $data{'state_cadc_recd'}[$i] + $data{'tanf_recd'}[$i] + $data{'fsp_recd'}[$i] + $data{'nutrition_recd'}[$i] + $data{'ctc_total_recd'}[$i] + $data{'ssi_recd'}[$i];
        $expenses[$i] = $data{'rent_paid'}[$i] + $data{'child_care_expenses'}[$i] + $data{'food_expenses'}[$i] + $data{'trans_expenses'}[$i] + $data{'other_expenses'}[$i] + $data{'health_expenses'}[$i] + $data{'debt_payment'}[$i] - $data{'salestax'}[$i] - $data{'disability_expenses'}[$i];
    }

  // Create the linear plots
    $line_income = new LinePlot($income);
    $line_income->SetLegend("Resources");
    $line_income->SetColor("#093A80");
    $line_income->SetWeight(1);
    $graph->Add($line_income);

    $line_expenses = new LinePlot($expenses);
    $line_expenses->SetLegend("Basic Expenses");
    $line_expenses->SetColor("#2D8343");
    $line_expenses->SetWeight(1);
    $graph->Add($line_expenses);

    $graph->xaxis->SetTickLabels($data{'earnings'});

    $graph->title->Set("Family Resources and Basic Expenses");
    $graph->yaxis->title->Set("Resources/Expenses");
    if(count($data{'earnings'}) > 12) {
        $graph->xaxis->SetTextTickInterval(round(count($data{'earnings'})/12));
    }

  // draw the "breaking even" point
    $breakeven_flag = 0;
    $y2 = $income[0] - $expenses[0];
    foreach ($expenses as $x1 => $expense)
    {
        $y1 = $income[$x1] - $expense;
        if($y2 < 0 && $y1 >= 0)
        {
          // see whether this point or the last one was closer to the x-axis
            if( (0 - $y2) < ($y1 - 0) )
            {
                $breakeven_y[$x1 - 1] = $expenses[$x1 - 1];
                $breakeven_y[$x1] = 'x';
                $breakeven_flag = 1;
            }
            else
            {
                $breakeven_y[$x1] = $expenses[$x1];
                $breakeven_flag = 1;
            }
        }
        else
        {
            $breakeven_y[] = 'x';
        }
        $y2 = $y1;
    }

    if($breakeven_flag)
    {
        $breakeven = new LinePlot($breakeven_y);
        $breakeven->mark->SetType(MARK_STAR);
        if($size == "large")
        {
            $breakeven->mark->SetSize(5);
        }
        $breakeven->SetLegend("Breaking even");
        $graph->Add($breakeven);
    }

    if($time_span == "monthly")
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormatMnth');
    }
    else
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormat');
    }

    $graph->xaxis->SetPos("min");
    $graph->xaxis->HideTicks();
    $graph->xaxis->SetTextTickInterval(1);
    $graph->xaxis->SetTickLabels($tick_labels);

}

#
# ELIGIBILITY BAR CHART
#
#######################################

function eligibility (&$data, $size, &$graph, $time_span, $state, $year)
{
  # figure out what ages of children there are, so we know which bars to display
    $under6_variable = 0;
    $under6_flag = 0;
    $over6_variable = 0;
    $over6_flag = 0;
    for($i=1;$i<=3;$i++) {
        if($data{'child' . $i . '_age'}[0] != -1) {
            if($data{'child' . $i . '_age'}[0] < 6) {
                $under6_variable = 'hlth_cov_child' . $i;
                $under6_flag = "hlth";
            }
            else {
                $over6_variable = 'hlth_cov_child' . $i;
                $over6_flag = "hlth";
            }
        }
    }

    if($data{'local_eic_recd'})
    {
        for ( $i = 0; $i < count($data{'earnings'}); $i++)
        {
            if($data{'local_eic_recd'}[$i])
            {
              # create a dummy flag in the data array for this benefit
                $data{'local_eitc'}[0] = 1;
            }
        }
    }


    if($data{'state_cadc'}[0])
    {
        for ( $i = 0; $i < count($data{'earnings'}); $i++)
        {
            if($data{'state_cadc_recd'}[$i])
            {
              # create a dummy flag in the data array for this benefit
                $data{'state_cadc'}[0] = 1;
            }
        }
    }
    
    if($data{'premium_tax_credit'}[0]) {
        for ($i = 0; $i < count($data{'earnings'}); $i++) {
            if($data{'premium_credit_recd'}[$i] > 0) {
              # create a dummy flag in the data array for this benefit
              $data{'premium_tax_credit'}[0] = 1;
            } else {
              $data{'premium_tax_credit'}[0] = 0;
            }
        }
    }
    
    if($data{'cadc'}[0]) {
        for ($i = 0; $i < count($data{'earnings'}); $i++) {
            if($data{'cadc_recd'}[$i] > 0) {
              # create a dummy flag in the data array for this benefit
              $data{'cadc'}[0] = 1;
            } else {
              $data{'cadc'}[0] = 0;
            }
        }
    }
	
    
    if($data{'ctc'}[0]) {
        for ($i = 0; $i < count($data{'earnings'}); $i++) {
            if($data{'ctc_total_recd'}[$i] > 0) {
              # create a dummy flag in the data array for this benefit
              $data{'ctc'}[0] = 1;
            } else {
              $data{'ctc'}[0] = 0;                
            }
        }
    }

    if($data{'tanf'}[0]) {
        for ($i = 0; $i < count($data{'earnings'}); $i++) {
            if($data{'tanf_recd'}[$i] > 0) {
              # create a dummy flag in the data array for this benefit
              $data{'tanf'}[$i] = 1;
            } else {
              $data{'tanf'}[$i] = 0;                
            }
        }
    }

    if($data{'liheap'}[0]) {
        for ($i = 0; $i < count($data{'earnings'}); $i++) {
            if($data{'liheap_recd'}[$i] > 0) {
              # create a dummy flag in the data array for this benefit
              $data{'liheap'}[$i] = 1;
            } else {
              $data{'liheap'}[$i] = 0;                
            }
        }
    }

    if($data{'heap'}[0]) {
        for ($i = 0; $i < count($data{'earnings'}); $i++) {
            if($data{'heap_recd'}[$i] > 0) {
              # create a dummy flag in the data array for this benefit
              $data{'heap'}[$i] = 1;
            } else {
              $data{'heap'}[$i] = 0;                
            }
        }
    }

    if($data{'hlth'}[0]) {
        for ($i = 0; $i < count($data{'earnings'}); $i++) {
            if($data{'medically_needy'}[$i] > 0) {
              # create a dummy flag in the data array for this benefit
              $data{'medically_needy_flag'}[0] = 1;
            }
        }
    }
	if($data{'wic_recd'})
    {
        for ( $i = 0; $i < count($data{'earnings'}); $i++)
        {
            if($data{'wic_recd'}[$i])
            {
              # create a dummy flag in the data array for this benefit
                $data{'wic'}[0] = 1;
            }
        }
    }
	
	if($data{'ssi_recd'})
    {
        for ( $i = 0; $i < count($data{'earnings'}); $i++)
        {
            if($data{'ssi_recd'}[$i])
            {
              # create a dummy flag in the data array for this benefit
                $data{'ssi'}[0] = 1;
            }
        }
    }
	
	if($data{'child_foodcost_red_total'})
    {
        for ( $i = 0; $i < count($data{'earnings'}); $i++)
        {
            if($data{'child_foodcost_red_total'}[$i])
            {
              # create a dummy flag in the data array for this benefit
                $data{'child_foodcost_red_total'}[0] = 1;
            }
        }
    }	
	
		if($data{'premium_credit_recd'})
    {
        for ( $i = 0; $i < count($data{'earnings'}); $i++)
        {
            if($data{'premium_credit_recd'}[$i])
            {
              # create a dummy flag in the data array for this benefit
                $data{'premium_credit_recd'}[0] = -1; #tried changing this to negative, thinking that 1 will reflect as receiving this benefit and negatives are set back to 0.
            }
        }
    }	
	
	
	
	
	
    $variables = array( 
        ($state == 'CO' && $year == 2015 ? "cc_subsidized_flag" : "ccdf_eligible_flag"),
        "fsp_recd",
        $over6_variable,
        $under6_variable,
        "hlth_cov_parent",
        ($state === 'FL' && $year == 2015 ? "medically_needy" : ""),
        "premium_credit_recd",
        (($state === 'DC') && $year == 2017 ? "child_foodcost_red_total" : ""),
        (($state === 'DC') && $year == 2017 ? "wic_recd" : ""),
        (($state === 'DC') && $year == 2017 ? "ssi_recd" : ""),
		"housing_recd",
        "tanf_recd",
        (($state === 'CO' || $state === 'OH' || $state === 'FL' || $state === 'DC') && ($year == 2015 || $year == 2017 ) ? "ctc_total_recd" : ""),
        "state_ctc_recd",
        "eitc_recd", 
        "state_eic_recd",
        "local_eic_recd",
        "state_cadc_recd",
        "local_cadc_recd",
        "cadc_recd",
        "cc_credit_recd",
        "nutrition_recd", 
        "liheap_recd",
        "heap_recd", 
        "lifeline_recd",
        "renter_credit_recd",
        "schoolread_credit_recd",
        "mwp_recd",
        "mrvp_vouch_recd"
    );
    $labels = array(
        "CCDF Subsidies",
        "SNAP/Food Stamps",
        "Pub Health Ins-Children",
        "Pub Hlth Ins-Chldrn <6",
        "Pub Health Ins-Parents",
        ($state === 'FL' && $year == 2015 ? "Medically Needy" : ""),
        "Premium Tax Credit",
		(($state === 'DC') && $year == 2017 ? "Subsidized Meals" : ""),
		(($state === 'DC') && $year == 2017 ? "WIC" : ""),
		(($state === 'DC') && $year == 2017 ? "SSI" : ""),
        "Sec 8 Housing Vouchers",
        "TANF Cash Assistance",
        ((($state === 'CO' || $state === 'OH' || $state === 'FL' || $state === 'DC') && ($year == 2015 || $year == 2017)) ? "Child Tax Credit, Federal" : ""),
        "Child Tax Credit, State",
        "EITC, Federal",
        "EITC, State",
        "EITC, Local",
        "State Child Care Credit",
        "Local Child Care Credit",
        "Federal Child Care Credit",
        "State Child Care Credit",
        "Supp. Nutrition Allowance",
        "LIHEAP",
        "HEAP",
        "Lifeline Subsidy",
        "State Renter Credit",
        "School Readiness Credit",
        "Making Work Pay Tax Credit",
        "Rental Vouchers"
    );
    
    $flags = array(
        "ccdf",
        "fsp",
        $over6_flag,
        $under6_flag,
        "hlth",
        ($state === 'FL' && $year == 2015 ? "medically_needy_flag" : ""),
        "premium_credit_recd",
		(($state === 'DC') && $year == 2017 ? "child_foodcost_red_total" : ""),
		(($state === 'DC') && $year == 2017 ? "wic" : ""),
		(($state === 'DC') && $year == 2017 ? "ssi" : ""),
        "sec8",
        "tanf",
        ((($state === 'CO' || $state === 'OH' || $state === 'FL' || $state === 'DC') && ($year == 2015 || $year == 2017 )) ? "ctc" : ""),
        "state_ctc",
        "eitc",
        "state_eitc",
        "local_eitc",
        "state_cadc",
        "local_cadc",
        "cadc",
        "cc_credit",
        "fsp_alt",
((($state === 'CO' || $state === 'OH' || $state === 'FL' || $state === 'DC' ) && ($year == 2015 || $year == 2017 )) ? "liheap_recd" : "liheap_recd"),
        "heap",
        "lifeline",
        "renter_credit",
        "schoolread_credit",
        "mwp",
        "mrvp"
    );

  # counter that keeps track of which variable we're examining (only includes the ones that get displayed on the chart)
    $k = 0;
    $asset_note = 0;

    foreach ($variables as $i => $variable) {
        if($data{$flags[$i]}[0]) {  # only include this benefit in the output if user turned this benefit on

          # counter keeps track of which state (0-5) we're examining
            $j = 0;

          # bar representing first "off" state; starts at the lowest value
            $data_y[0][$k] = $data{'earnings'}[0];

          # bar representing first "on" state; default to the whole range of earnings
            $data_y[1][$k] = $data{'earnings'}[0];

          # bar representing the second "off" state
            $data_y[2][$k] = $data{'earnings'}[0];

          # bar representing the second "on" state
            $data_y[3][$k] = $data{'earnings'}[0];

          # bar representing the third "off" state
            $data_y[4][$k] = $data{'earnings'}[0];

          # bar representing the third "on" state
            $data_y[5][$k] = $data{'earnings'}[0];

            if(ereg("hlth", $variable)) {
                $last_value = "No public coverage";
            }
            else {
                $last_value = 0;
            }

            $null_values = "0|-1|No public coverage|Employer|Private|Individual|User-entered|Nongroup|CHPB|HNY|Uninsured|Buy-In|BasicHealth|PAK|SCI|HealthyKids Full-Pay|MediKids Full-Pay"; #added -1 to this to see if that works for premium tax credit bug.

            $start = 0;
            foreach ($data{$variable} as $x => $y) {

              # if the value has changed from "on" to "off" (or vice versa), store another bar
                if( (stristr($null_values, (string) $last_value) && !stristr($null_values, (string) $y) ) || ( !stristr($null_values, (string) $last_value) && stristr($null_values, (string) $y)))
                {
                    $value = $x - $start;
                    if($value < 0) { $value = 0; }
                    $data_y[$j][$k] = $data{'earnings'}[$value];
                    $start = $x;
                    $j++;
                }
                $last_value = $y;
            }

          # if the first "on" section never went off, then we want to show receipt of benefit through entire span of earnings
            if($data_y[1][$k] == $data{'earnings'}[0] && !stristr($null_values, (string) $data{$variable}[count($data{$variable}) - 1]) ) {
                $data_y[1][$k] = $data{'earnings'}[count($data{'earnings'}) - 1] + 1;
            }

          # if the second "on" section never went off, then we want to show receipt of benefit through rest of span
            if($data_y[2][$k] > 0 && $data_y[3][$k] == $data{'earnings'}[0]) {
                $data_y[3][$k] = $data{'earnings'}[count($data{'earnings'}) - 1] + 1;
            }

          # if the third "on" section never went off, then we want to show receipt of benefit through rest of span
            if($data_y[4][$k] > 0 && $data_y[5][$k] == $data{'earnings'}[0]) {
                $data_y[5][$k] = $data{'earnings'}[count($data{'earnings'}) - 1] + 1;
            }

          # if this is the under 6 bar, and there was also an over 6 bar, and they're the same, then DON'T SHOW this bar
          # OR if this is one of the child bars, and this is IL 2006, DON'T SHOW THE BAR, since in IL 2006 children
          # are always eligible and this bar would be misleading (not to mention uninteresting)
            if (!( ($labels[$i] === "Pub Hlth Ins-Chldrn <6") && $over6_flag && ($data_y[0][$k - 1] == $data_y[0][$k]) && ($data_y[1][$k - 1] == $data_y[1][$k]) && ($data_y[2][$k - 1] == $data_y[2][$k]) && ($data_y[3][$k - 1] == $data_y[3][$k]) && ($data_y[4][$k - 1] == $data_y[4][$k]) && ($data_y[5][$k - 1] == $data_y[5][$k]))
                && !($state == "IL" && ($year == 2006 || $year == 2008) && ($labels[$i] === "Pub Hlth Ins-Chldrn <6" || $labels[$i] === "Pub Health Ins-Children"))
                ) {

              # store the title for this bar
                $output_labels[] = $labels[$i];

              # if this is the under 6 bar, and this is not PA, then change the name of the label
                if($labels[$i] === "Pub Hlth Ins-Chldrn <6" && $over6_flag && $data{'state'}[0] !== 'PA') {
                    $output_labels[$k - 1] = "Pub Health Ins-Children";
                }
                elseif($labels[$i] === "Pub Hlth Ins-Chldrn <6" && !$over6_flag) {
                    $output_labels[$k] = "Pub Health Ins-Children";
                }

              # add asset asterisk if necessary
                if($data{'state'}[0] === 'GA' && ($labels[$i] === "Public Health Insurance-Parents" ||
                                                  $labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'PA' && ($labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'MA' && ($labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'DE' && $labels[$i] === "TANF Cash Assistance") {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'IL' && ($labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'DC' && $year == 2004 &&  ($labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'AL' && ($labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'MD' && $labels[$i] === "TANF Cash Assistance") {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'TX' && ($labels[$i] === "Pub Health Ins-Parents" ||
                                                  $labels[$i] === "Pub Health Ins-Children" ||
                                                  $labels[$i] === "Pub Hlth Ins-Chldrn <6" ||
                                                  $labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'NY' && $year == 2004 && ($labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'NY' && $year == 2004 && ($labels[$i] === "Pub Health Ins-Parents")) {
                    $output_labels[$k] = "Pub Hlth Ins-Parents (no prem)";
                }
                if($data{'state'}[0] === 'NY' && $year == 2008 && ($labels[$i] === "Pub Health Ins-Parents" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($state === 'CT' && $year == 2005 && ($labels[$i] === "Food Stamps" ||
                                                        $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($state == 'IL' && $year == 2006 && $labels[$i] === "Pub Health Ins-Parents") {
                    $output_labels[$k] = "Public Health Ins-Parents & Children";
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'MI' && $year == 2006 && ($labels[$i] === "Pub Health Ins-Parents" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($state === 'CO' && $year == 2006 && ($labels[$i] === "Food Stamps" ||
                                                        $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'CA' && ($labels[$i] === "Pub Health Ins-Parents" ||
                                                  $labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'FL' && ($labels[$i] === "Pub Health Ins-Parents" ||
                                                  $labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    if ($year == 2015) {
                        $asset_note = 0;                        
                    } else {
                        $output_labels[$k] .= chr(94);
                        $asset_note = 1;                        
                    } 
                }
                if($data{'state'}[0] === 'WA' && ($labels[$i] === "Pub Health Ins-Parents" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($data{'state'}[0] === 'IA' && ($labels[$i] === "Pub Health Ins-Parents" ||
                                                  $labels[$i] === "Food Stamps" ||
                                                  $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }
                if($state === 'VT' && ($labels[$i] === "Food Stamps" ||
                                    $labels[$i] === "TANF Cash Assistance" )) {
                    $output_labels[$k] .= chr(94);
                    $asset_note = 1;
                }

              # increment variable
                $k++;
            }
        }
    }

    // this is to create a blank line where we're putting the FPL text
	//removed asset note for all states from line 1054. Kept the statement blank otherwise it throws as asset note counter variable. 
    if($asset_note) {
    	    $output_labels[] = "";
    }
    else {
        $output_labels[] = "";
    }
    $data_y[0][] = $data{'earnings'}[0];
    $data_y[1][] = 0;
    $data_y[2][] = 0;
    $data_y[3][] = 0;
    $data_y[4][] = 0;
    $data_y[5][] = 0;

    // Create the bar plots
    $b1 = new BarPlot($data_y[0]);
    $b1->SetColor("white");
    $b1->SetFillColor("white");
    $b1->SetWidth(1);
    $barplots[] = $b1;

    $b2 = new BarPlot($data_y[1]);
    $b2->SetColor("white");
    $b2->SetFillColor("#37939B");
    $b2->SetWidth(1);
    $barplots[] = $b2;

    $b3 = new BarPlot($data_y[2]);
    $b3->SetColor("white");
    $b3->SetFillColor("white");
    $b3->SetWidth(1);
    $barplots[] = $b3;

    $b4 = new BarPlot($data_y[3]);
    $b4->SetColor("white");
    $b4->SetFillColor("#37939B");
    $b4->SetWidth(1);
    $barplots[] = $b4;

    $b5 = new BarPlot($data_y[4]);
    $b5->SetColor("white");
    $b5->SetFillColor("white");
    $b5->SetWidth(1);
    $barplots[] = $b5;

    $b6 = new BarPlot($data_y[5]);
    $b6->SetColor("white");
    $b6->SetFillColor("#37939B");
    $b6->SetWidth(1);
    $barplots[] = $b6;

    // Create the accumulated bar plot
    $accplot = new AccBarPlot($barplots);
    $accplot->SetWidth(1);

    // And add it to the graph
    $graph->Add($accplot);

    // if values run off the end of the chart, don't show them
    $graph->SetClipping(true);

    // Title
    $graph->title->Set("Family's Receipt of Benefits by Earnings Level*");

    // Specify X-labels
    $graph->xaxis->HideTicks();
    $graph->xaxis->SetTickLabels($output_labels);
    $graph->xaxis->SetPos('max');
    $graph->xaxis->title->SetFont(FF_TAHOMA);
    $graph->xaxis->SetFont(FF_TAHOMA,FS_NORMAL,8);
    $graph->xaxis->SetLabelSide(SIDE_RIGHT);
    $graph->xaxis->SetLabelAlign('left','center');
    $graph->xaxis->HideLine();
    $graph->xaxis->SetLabelMargin(0);

    // Y-labels (which get turned into X-labels when we rotate the graph)

  # reduce the number of x-labels, if necessary
    if($size == "small") { $bars = 11; }
    else { $bars = 11; }

    $points = count($data{'earnings'});
    if($bars >= $points) { $interval = 1; }
    else {
        $interval = ceil( $points / $bars );
    }

    if($time_span == "monthly") { $interval *= 100; }

    for ( $i = 0; $i < count($data{'earnings'}); $i++) {
        if($data{'earnings'}[$i] % $interval == 0) {
            if($time_span == "yearly") {
                $tick_labels[$i] = $data{'earnings'}[$i] . "K";
            }
            else {
                $tick_labels[$i] = $data{'earnings'}[$i];
            }
        }
        else {
            $tick_labels[$i] = '';
        }
    }

    $graph->yaxis->SetTickLabels($tick_labels);
    $graph->yaxis->scale->ticks->Set($interval);
    $graph->yaxis->scale->ticks->SetSide(SIDE_LEFT);
    $graph->yaxis->SetLabelAngle(90);
    $graph->yaxis->title->SetFont(FF_TAHOMA);
    $graph->yaxis->SetFont(FF_TAHOMA,FS_NORMAL,8);
    $graph->yaxis->SetLabelMargin(0);
	$graph->yaxis->SetLabelSide(SIDE_DOWN); 
    
    // Setup legend
    $graph->legend->SetPos(.01,.05,'right','top');
    $graph->legend->SetFont(FF_TAHOMA,FS_NORMAL,16);
    $graph->legend->SetFillColor("white");
    $graph->legend->SetShadow(0);
    $graph->legend->SetFrameWeight(0);

    $graph->SetFrame(false,'white',0);

/*
    // Add lines to indicate 100% and 200% FPL
    if($size == "small") { 
    	$x_width = 114; 
    	$margin = 5;
    }
    else { 
    	$x_width = 410; 
		$margin = 10;
    }

    // round the fpl up to the next earnings interval, if necessary
    $interval = $data{'earnings'}[1] - $data{'earnings'}[0];
    $fpl_100 = ceil($data{'fpl'}[0]/$interval) * $interval;
    $fpl_200 = ceil($data{'fpl'}[0]/$interval * 2) * $interval;
    $y = 226;

    // Only add the lines if they fall within the range of the chart
    $x_100 = $margin + $fpl_100 * ($x_width / $data{'earnings'}[count($data{'earnings'}) - 1]);

    if($x_100 <= $margin + $x_width) {
        $line_100 = new PlotLine (HORIZONTAL, $fpl_100, "#990000",1);
        $graph->Add( $line_100);
        $txt_100 = new Text("100% FPL",$x_100 - 3,$y);
        $txt_100->SetFont(FF_TAHOMA,FS_NORMAL,8);
        $txt_100->Align('right','top');
        $graph->AddText($txt_100);
    }
    $x_200 = $margin + $fpl_200 * ($x_width / $data{'earnings'}[count($data{'earnings'}) - 1]);
    if($x_200 <= $margin + $x_width) {
        $line_200 = new PlotLine (HORIZONTAL, $fpl_200, "#990000",1);
        $graph->Add( $line_200);
        $txt_200 = new Text("200% FPL",$x_200 - 3,$y);
        $txt_200->SetFont(FF_TAHOMA,FS_NORMAL,8);
        $txt_200->Align('right','top');
        $graph->AddText($txt_200);
    }
*/

}

#
# INCOME-ONLY BAR CHART
#
#######################################

function income_only ($data, $size, &$graph, $time_span, $state, $year)
{
    global $labels;

    $income_headers = array("earnings_posttax", "child_support_recd", "eitc_recd", "state_eic_recd", "local_eic_recd", "cc_credit_recd", "state_cadc_recd", "ctc_total_recd", "tanf_recd", "fsp_recd", "nutrition_recd", "ssi_recd");
	$income_colors = array('#008576','#F3ED86','#7E2271','#A9A28D','#000000','#005596','#73C167','#B51019','#569BBD','#F9A350','#674F3F','#674F3F');
	
  # reduce the number of bars, if necessary
    if($size == "small") { $bars = 24; }
    else { $bars = 24; }

  # interval refers not to the income amount, but to the index of the income array
    if($bars >= count($data{'earnings'})) { $interval = 1; }
    else {
        $interval = ceil( count($data{'earnings'}) / $bars);
    }

    $max_state_eic = 0;
    $child_support_recd = 0;
    for ( $i = 0; $i < count($data{'earnings'}); $i = $i + $interval) {
        $bar_data{'earnings'}[] = $data{'earnings'}[$i];
        foreach ($income_headers as $name) {
            $bar_data{$name}[] = $data{$name}[$i];
        }
        $bar_data{'zeros'}[] = 0;

        if($data{'state_eic_recd'}[$i] > $max_state_eic)
        {
            $max_state_eic = $data{'state_eic_recd'}[$i];
        }

        if($data{'child_support_recd'}[$i])
        {
            $child_support_recd = 1;
        }

        if($data{'local_eic_recd'}[$i])
        {
            $local_eic_recd = 1;
        }

        if($data{'state_cadc_recd'}[$i])
        {
            $state_cadc_recd = 1;
        }

        if($data{'cc_credit_recd'}[$i])
        {
            $cc_credit_recd = 1;
        }
    }

  # this is an array with flags for the various benefits, now that we know which ones we need to display
  # has to be created after we've tested for child support receipt
    $benefits = array(1, $child_support_recd, $data{'eitc'}[0], $data{'state_eitc'}[0], $local_eic_recd, $cc_credit_recd, $state_cadc_recd, 1, $data{'tanf'}[0], $data{'fsp'}[0], $data{'fsp_alt'}[0], $ssi_recd);

  # test to see if there are children under 6
    $under6 = 0;
    $over6 = 0;
    for($i=1;$i<=3;$i++) {
        if($data{'child' . $i . '_age'}[0] != -1) {
            if($data{'child' . $i . '_age'}[0] < 6) {
                $under6 = $i;
            }
            else {
                $over6 = $i;
            }
        }
    }

    if($data{'hlth'}[0]) {

        if($under6 && $data{'state'}[0] === "PA") {
            $var = "ins_header_1";
            $$var = new BarPlot($bar_data{'zeros'});
            $$var->SetColor("white");
            $$var->SetFillColor("#cccccc");
            $$var->SetLegend("Only children\nunder 6 eligible");
            $barplots_b1[] = $$var;
        }

        if($over6 && $data{'state'}[0] === "PA") {
            $var = "ins_header_3";
            $$var = new BarPlot($bar_data{'zeros'});
            $$var->SetColor("white");
            $$var->SetFillColor("#999999");
            $$var->SetLegend("Children eligible");
            $barplots_b1[] = $$var;
        }

      # since children are always eligible in IL 2006, don't show that bar because it's uninteresting
        if($state == "IL" && $year == 2006) {
            $var = "ins_header_3";
            $$var = new BarPlot($bar_data{'zeros'});
            $$var->SetColor("white");
            $$var->SetFillColor("white");
            $$var->SetLegend("(children always\neligible, but\npremiums rise\nwith income)");
            $barplots_b1[] = $$var;
        }
        elseif($data{'state'}[0] !== "PA") {
            $var = "ins_header_3";
            $$var = new BarPlot($bar_data{'zeros'});
            $$var->SetColor("white");
            $$var->SetFillColor("#999999");
            if($data{'state'}[0] == 'NY') {
                $$var->SetLegend("Children eligible\n(per-child premium:\n$0-15/month)");
            }
            else {
                $$var->SetLegend("Children eligible");
            }
            $barplots_b1[] = $$var;
        }

        $var = "ins_header_2";
        $$var = new BarPlot($bar_data{'zeros'});
        $$var->SetColor("white");
        $$var->SetFillColor("#666666");
        if($data{'state'}[0] == 'NY') {
            $$var->SetLegend("Parents and\nchildren eligible\n(no premiums)");
        }
        else {
            $$var->SetLegend("Parents and\nchildren eligible");
        }
        $barplots_b1[] = $$var;

        $var = "ins_header_title";
        $$var = new BarPlot($bar_data{'zeros'});
        $$var->SetColor("white");
        $$var->SetFillColor("white");
        $$var->SetLegend("PUBLIC HEALTH\nINSURANCE");
        $barplots_b1[] = $$var;

        $var = "blank_header";
        $$var = new BarPlot($bar_data{'zeros'});
        $$var->SetColor("white");
        $$var->SetFillColor("white");
        $$var->SetLegend(" ");
        $barplots_b1[] = $$var;
    }

    // Create the bar plots for income
    foreach ($income_headers as $i => $name) {
        if($benefits[$i]) {
            $var = "b1." . $i . "plot";
            $$var = new BarPlot($bar_data{$name});
            $$var->SetColor("white");
            $$var->SetFillColor($income_colors[$i % count($income_colors)]);
            $$var->SetLegend($labels[$name]);

            $barplots_b1[] = $$var;
        }
    }

    $var = "legend_title";
    $$var = new BarPlot($bar_data{'zeros'});
    $$var->SetColor("white");
    $$var->SetFillColor("white");
    $$var->SetLegend("RESOURCES");
    $barplots_b1[] = $$var;

    // Create the accumulated bar plot for income
    $ab1plot = new AccBarPlot($barplots_b1);
    $ab1plot->SetYBase(10);
    $ab1plot->SetWidth(1);

    // And add it to the graph
    $graph->Add($ab1plot);

    $graph->title->Set("Family Resources, Cash and Near-cash");

    $x_labels = $bar_data{'earnings'};
    if($data{'earnings'}[1] - $data{'earnings'}[0] == 1) {
        array_walk($x_labels, create_function('&$v,$k', '$v = $v . "K";'));
    }
    $graph->xaxis->SetTickLabels($x_labels);

    $graph->xaxis->HideTicks();
    if(count($bar_data{'earnings'}) > 12) {
        $graph->xaxis->SetTextTickInterval(2);
    }

    $graph->yaxis->title->Set("Resources");

    $graph ->xaxis->SetPos("min");

  # add bands for health insurance if it was turned on
    if($data{'hlth'}[0]) {

      # needs to allow for THREE bands of parent eligibility -- well, not anymore, but it still will

        $max = $data{'earnings'}[count($data{'earnings'}) - 1] + 1;

        $parent_start_1 = 0;
        $parent_end_1 = $max;
        $parent_start_2 = 0;
        $parent_end_2 = $max;
        $parent_start_3 = 0;
        $parent_end_3 = $max;

        $null_values = "No public coverage|Employer|Individual|Private|User-entered|Nongroup|CHPB|HNY|Uninsured|PAK|SCI|HealthyKids Full-Pay|MediKids Full-Pay";
        $eligible = 1;
        $i = 1;
        foreach ($data{'hlth_cov_parent'} as $x => $y) {
            if($eligible == 1 && stristr($null_values, $y) ) {           // if parent is currently eligible & runs out on this value
                ${'parent_end_' . $i} = $data{'earnings'}[$x];  // set value to the earnings level of the last iteration
                $i++;
                $eligible = 0;
            }
            elseif ($eligible == 0 && !stristr($null_values, $y) ) {
                ${'parent_start_' . $i} = $data{'earnings'}[$x];
                $eligible = 1;
            }

        }

        if($parent_start_2 == 0 && $parent_end_2 == $max) { $parent_start_2 = $parent_end_2 = 0; }
        if($parent_start_3 == 0 && $parent_end_3 == $max) { $parent_start_3 = $parent_end_3 = 0; }

        $over6_cutoff = 0;
        $under6_cutoff = 0;

      # if there are children under 6, then create an "under 6" band (longer than the other child band)
        if($under6 && $data{'state'}[0] === 'PA') {
            $under6_cutoff = $data{'earnings'}[count($data{'earnings'}) - 1] + 1; // start at the upper limit
            foreach($data{'hlth_cov_child' . $under6} as $x => $y) {
                if(stristr($null_values, $y)) {  // if eligibility has run out
                    $under6_cutoff = $data{'earnings'}[$x];  // set value to the earnings level of the last iteration
                    break;
                }
            }
        }

      # if there are children over 6, then create an "over 6" band
        if($over6 && $data{'state'}[0] === 'PA') {
            $over6_cutoff = $data{'earnings'}[count($data{'earnings'}) - 1] + 1; // start at the upper limit
            foreach($data{'hlth_cov_child' . $over6} as $x => $y) {
                if(stristr($null_values, $y)) {  // if eligibility has run out
                    $over6_cutoff = $data{'earnings'}[$x];  // set value to the earnings level of the last iteration
                    break;
                }
            }
        }

        if($data{'state'}[0] !== 'PA') {
            $over6_cutoff = $data{'earnings'}[count($data{'earnings'}) - 1] + 1; // start at the upper limit
            foreach($data{'hlth_cov_child1'} as $x => $y) {
                if(stristr($null_values, $y)) {  // if eligibility has run out
                    $over6_cutoff = $data{'earnings'}[$x];  // set value to the earnings level of the last iteration
                    break;
                }
            }
        }

      # accomodate the interval that we're using on this graph

        if($time_span == "monthly") {
            $parent_start_1 = ceil(($parent_start_1 - $data{'earnings'}[0])/($interval * 100));
            $parent_end_1 = ceil(($parent_end_1 - $data{'earnings'}[0])/($interval * 100));
            $parent_start_2 = ceil(($parent_start_2 - $data{'earnings'}[0])/($interval * 100));
            $parent_end_2 = ceil(($parent_end_2 - $data{'earnings'}[0])/($interval * 100));
            $parent_start_3 = ceil(($parent_start_3 - $data{'earnings'}[0])/($interval * 100));
            $parent_end_3 = ceil(($parent_end_3 - $data{'earnings'}[0])/($interval * 100));
            $under6_cutoff = ceil(($under6_cutoff - $data{'earnings'}[0])/($interval * 100));
            $over6_cutoff = ceil(($over6_cutoff - $data{'earnings'}[0])/($interval * 100));
        }
        else {
            $parent_start_1 = ceil(($parent_start_1 - $data{'earnings'}[0])/$interval);
            $parent_end_1 = ceil(($parent_end_1 - $data{'earnings'}[0])/$interval);
            $parent_start_2 = ceil(($parent_start_2 - $data{'earnings'}[0])/$interval);
            $parent_end_2 = ceil(($parent_end_2 - $data{'earnings'}[0])/$interval);
            $parent_start_3 = ceil(($parent_start_3 - $data{'earnings'}[0])/$interval);
            $parent_end_3 = ceil(($parent_end_3 - $data{'earnings'}[0])/$interval);
            $under6_cutoff = ceil(($under6_cutoff - $data{'earnings'}[0])/$interval);
            $over6_cutoff = ceil(($over6_cutoff - $data{'earnings'}[0])/$interval);
        }

        if ($state == "IL" && $year == 2006)
        {

        }
        else
        {
            $band_under6_cutoff = new PlotBand(VERTICAL, BAND_SOLID, 0, $under6_cutoff, '#cccccc', 1, DEPTH_BACK);
            $band_under6_cutoff->ShowFrame(false);
            $graph->AddBand($band_under6_cutoff);

            $band_over6_cutoff = new PlotBand(VERTICAL, BAND_SOLID, 0, $over6_cutoff, '#999999', 1, DEPTH_BACK);
            $band_over6_cutoff->ShowFrame(false);
            $graph->AddBand($band_over6_cutoff);
        }

        $band_parent_1 = new PlotBand(VERTICAL, BAND_SOLID, $parent_start_1, $parent_end_1, '#666666', 1, DEPTH_BACK);
        $band_parent_1->ShowFrame(false);
        $graph->AddBand($band_parent_1);

        $band_parent_2 = new PlotBand(VERTICAL, BAND_SOLID, $parent_start_2, $parent_end_2, '#666666', 1, DEPTH_BACK);
        $band_parent_2->ShowFrame(false);
        $graph->AddBand($band_parent_2);

        $band_parent_3 = new PlotBand(VERTICAL, BAND_SOLID, $parent_start_3, $parent_end_3, '#666666', 1, DEPTH_BACK);
        $band_parent_3->ShowFrame(false);
        $graph->AddBand($band_parent_3);

    }
}

#
# INCOME-ONLY BAR CHART - NO HEALTH INSURANCE BARS
#
#######################################

function income_only_no_health ($data, $size, &$graph, $time_span, $state, $year)
{
    global $labels;

	# CTC is included in the tax figures for pre-2006 states
	if($year < 2006) {
		$income_headers = array("earnings_plus_interest", "child_support_recd", "state_ctc_recd", "eitc_recd", "state_eic_recd", "local_eic_recd", "cc_credit_recd", "local_cadc_recd", "state_cadc_recd", "tanf_recd", "fsp_recd", "nutrition_recd", "liheap_recd");
		$income_colors = array('#008576', '#F3ED86', '#B51019', '#7E2271', '#A9A28D', '#000000', '#005596', '#B51019', '#73C167', '#569BBD', '#F9A350', '#674F3F', '#B51019', '#B51019');
	} else {
		$income_headers = array("earnings_plus_interest", "child_support_recd", "eitc_recd", "ctc_total_recd", "cc_credit_recd", "cadc_recd","mwp_recd", "state_eic_recd", "state_ctc_recd", "state_cadc_recd", "local_eic_recd", "local_eitc_recd", "local_cadc_recd", "renter_credit_recd", "schoolread_credit_recd", "tanf_recd", "fsp_recd", "nutrition_recd", "liheap_recd", "heap_recd", "ssi_recd");
		$income_colors  = array('#008478', '#F3ED86', "#673bb8", "#7E2271", '#c78cda', '#e14c68', "#e3d700", '#0078c9', '#B51019', '#005195', '#e3d700', '#e3d700', '#a3d869', '#e3d700', "#e3d700", '#00aecb', '#a3d869', '#000000', '#00ae42', '#00ae42', '#00ae42');
	}
	
  # reduce the number of bars, if necessary
    if($size == "small") { $bars = 24; }
    else { $bars = 24; }

  # interval refers not to the income amount, but to the index of the income array
    if($bars >= count($data{'earnings'})) { $interval = 1; }
    else {
        $interval = ceil( count($data{'earnings'}) / $bars);
    }

    $max_state_eic = 0;
    $child_support_recd = 0;
    for ( $i = 0; $i < count($data{'earnings'}); $i = $i + $interval) {
        $bar_data{'earnings'}[] = $data{'earnings'}[$i];
        foreach ($income_headers as $name) {
            $bar_data{$name}[] = $data{$name}[$i];
        }
        $bar_data{'zeros'}[] = 0;

        if($data{'state_eic_recd'}[$i] > $max_state_eic)
        {
            $max_state_eic = $data{'state_eic_recd'}[$i];
        }

        if($data{'child_support_recd'}[$i])
        {
            $child_support_recd = 1;
        }

        if($data{'local_eic_recd'}[$i])
        {
            $local_eic_recd = 1;
        }

        if($data{'state_cadc_recd'}[$i])
        {
            $state_cadc_recd = 1;
        }
        
        if($data{'local_cadc_recd'}[$i])
        {
        	$local_cadc_recd = 1;
        }

        if($data{'ctc_total_recd'}[$i])
        {
        	$ctc_recd = 1;
        }

        if($data{'cadc_recd'}[$i])
        {
        	$cadc_recd = 1;
        } else {
        	$cadc_recd = 0;
        } 
        
        if($data{'state_ctc_recd'}[$i])
        {
        	$state_ctc_recd = 1;
        }
        
        if($data{'cc_credit_recd'}[$i])
        {
            $cc_credit_recd = 1;
        }
        
        if($data{'liheap_recd'}[$i])
        {
        	$liheap_recd = 1;
        }
        if($data{'heap_recd'}[$i])
        {
        	$heap_recd = 1;
        }
        if($data{'tanf_recd'}[$i])
        {
        	$tanf_recd = 1;
        }
        if($data{'lifeline_recd'}[$i])
        {
        	$lifeline_recd = 1;
        }
        if($data{'renter_credit_recd'}[$i])
        {
        	$renter_credit_recd = 1;
        }

        if($data{'schoolread_credit_recd'}[$i])
        {
        	$schoolread_credit_recd = 1;
        }

        if($data{'local_eitc_recd'}[$i])
        {
        	$local_eitc_recd = 1;
        }
        
        if($data{'mwp_recd'}[$i])
        {
        	$mwp_recd = 1;
        }
        
        if($data{'mrvp_vouch_recd'}[$i])
        {
        	$mrvp_vouch_recd = 1;
        }
		
		if($data{'ssi_recd'}[$i])
        {
        	$ssi_recd = 1;

        } 
    }

  # this is an array with flags for the various benefits, now that we know which ones we need to display
  # has to be created after we've tested for child support receipt
    if($year < 2006) {
        $benefits = array(1, $child_support_recd, $state_ctc_recd, $data{'eitc'}[0], $data{'state_eitc'}[0], $local_eic_recd, $cc_credit_recd, $local_cadc_recd, $state_cadc_recd, $data{'tanf'}[0], $data{'fsp'}[0], $data{'fsp_alt'}[0], $liheap_recd);
    } else {
        $benefits = array(1, $child_support_recd, $data{'eitc'}[0], $ctc_recd, $cc_credit_recd,	$cadc_recd, $mwp_recd, $data{'state_eitc'}[0], $state_ctc_recd, $state_cadc_recd, $local_eic_recd, $local_eitc_recd, $local_cadc_recd, $renter_credit_recd, $schoolread_credit_recd, $tanf_recd, $data{'fsp'}[0], $data{'fsp_alt'}[0], $liheap_recd, $heap_recd, $ssi_recd);
    }

    // Create the bar plots for income
    foreach ($income_headers as $i => $name) {
        if($benefits[$i]) {
            $var = "b1." . $i . "plot";
            $$var = new BarPlot($bar_data{$name});
            $$var->SetColor("white");
            $$var->SetFillColor($income_colors[$i % count($income_colors)]);
            $$var->SetLegend($labels[$name]);

            $barplots_b1[] = $$var;
        }
    }

	#print_r($barplots_b1);

    // Create the accumulated bar plot for income
    $ab1plot = new AccBarPlot($barplots_b1);
    $ab1plot->SetYBase(10);
    $ab1plot->SetWidth(1);

    // And add it to the graph
    $graph->Add($ab1plot);

    $graph->title->Set("Family Resources (cash and near-cash)");

    $x_labels = $bar_data{'earnings'};
    if($data{'earnings'}[1] - $data{'earnings'}[0] == 1) {
        array_walk($x_labels, create_function('&$v,$k', '$v = $v . "K";'));
    }
    $graph->xaxis->SetTickLabels($x_labels);

    $graph->xaxis->HideTicks();
    if(count($bar_data{'earnings'}) > 12) {
        $graph->xaxis->SetTextTickInterval(2);
    }

    $graph->yaxis->title->Set("Resources");

    $graph ->xaxis->SetPos("min");
}

#
# EXPENSE ONLY
# not here JSB
#######################################

function expense_only (&$data, $size, &$graph, $time_span, $state_year)
{
    global $labels;

    $expense_headers = array("debt_payment","other_expenses","food_expenses","rent_paid","trans_expenses","child_care_expenses","health_expenses");
    $expense_colors = array('#B51019','#630208','#F98885','#F70824','#820023','#D21041','#F26649');

  # reduce the number of bars, if necessary
    if($size == "small") { $bars = 24; }
    else { $bars = 24; }

  # interval refers not to the income amount, but to the index of the income array
    if($bars >= count($data{'earnings'})) { $interval = 1; }
    else {
        $interval = ceil( count($data{'earnings'}) / $bars);
    }

    $child_care_cost = 0;
    $housing_cost = 0;
    $trans_cost = 0;
    $food_cost = 0;
    $health_cost = 0;
    $other_cost = 0;
    for ( $i = 0; $i < count($data{'earnings'}); $i = $i + $interval) {
        $bar_data{'earnings'}[] = $data{'earnings'}[$i];
        foreach ($expense_headers as $name) {
            $bar_data{$name}[] = $data{$name}[$i];
        }
        $bar_data{'zeros'}[] = 0;

        if($data{'child_care_expenses'}[$i])
        {
            $child_care_cost = 1;
        }
        if($data{'rent_paid'}[$i])
        {
            $housing_cost = 1;
        }
        if($data{'trans_expenses'}[$i])
        {
            $trans_cost = 1;
        }
        if($data{'food_expenses'}[$i])
        {
            $food_cost = 1;
        }
        if($data{'health_expenses'}[$i])
        {
            $health_cost = 1;
        }
        if($data{'other_expenses'}[$i])
        {
            $other_cost = 1;
        }
    }

    $debt_payment = 0;
    if($data{'debt_payment'}[0] > 0)
    {
        $debt_payment = 1;
    }

    $expenses = array($debt_payment, $other_cost, $food_cost, $housing_cost, $trans_cost, $child_care_cost, $health_cost);
    $show_expenses = $debt_payment + $other_cost + $food_cost + $housing_cost + $trans_cost + $child_care_cost + $health_cost;

    if($show_expenses)
    {
      // Create the bar plots for expenses
        foreach ($expense_headers as $i => $name) {
            if($expenses[$i])
            {
                $var = "b1." . $i . "plot";
                $$var = new BarPlot($bar_data{$name});
                $$var->SetColor("white");
                $$var->SetFillColor($expense_colors[$i % count($expense_colors)]);
                $$var->SetLegend($labels[$name]);
                $barplots_b1[] = $$var;
            }
        }
    }
    else
    {
        $var = "blank_header";
        $$var = new BarPlot($bar_data{'zeros'});
        $$var->SetColor("white");
        $$var->SetFillColor("white");
        $$var->SetLegend(" ");
        $barplots_b1[] = $$var;
    }

    // Create the accumulated bar plot for expenses
    $ab1plot = new AccBarPlot($barplots_b1);
    $ab1plot->SetYBase(10);
    $ab1plot->SetWidth(1);

    // And add it to the graph
    $graph->Add($ab1plot);

    $graph->title->Set("Basic Family Expenses");
    $graph->yaxis->title->Set("Expenses");
    $graph->xaxis->HideTicks();
    if(count($bar_data{'earnings'}) > 12) {
        $graph->xaxis->SetTextTickInterval(2);
    }

    $x_labels = $bar_data{'earnings'};
    if($data{'earnings'}[1] - $data{'earnings'}[0] == 1) {
        array_walk($x_labels, create_function('&$v,$k', '$v = $v . "K";'));
    }
    $graph->xaxis->SetTickLabels($x_labels);

}

#
# INCOME AND EXPENSES BAR CHART 
#
#######################################

function master (&$data, $size, &$graph, $time_span, $state, $year)
{

    global $labels;

# now including taxes as an expense
	if($year < 2006) {
	    $income_headers = array("earnings_plus_interest", "child_support_recd", "state_ctc_recd", "eitc_recd", "state_eic_recd", "local_eic_recd", "cc_credit_recd", "local_cadc_recd", "state_cadc_recd", "tanf_recd", "fsp_recd", "nutrition_recd", "liheap_recd");
		$income_colors  = array('#008576',				  '#73C167',			'#006757',		  '#9FD5B5',   '#00B259',		 '#8FD2C5',		   '#006224',		 '#006224',			'#73C167',		   '#006757',	'#C1D82E',	'#C1D82E', 		  '#C1D82E');

	    $expense_headers = array("taxes","debt_payment","other_expenses","food_expenses","rent_paid","trans_expenses","child_care_expenses","health_expenses");
	    $expense_colors  = array('#B51019','#630208','#F98885','#F70824','#820023','#D21041','#F26649');
	} else {
	    $income_headers = array("earnings_plus_interest", "child_support_recd", "federal_tax_credits", "state_tax_credits", "local_tax_credits", "tanf_recd", "fsp_recd", "liheap_recd", "heap_recd" , "ssi_recd");
        $income_colors  = array('#008478', '#a3d869', '#5a8e22', '#70d551', '#005643', '#00ad68', '#73d1b7', '#C1D82E', '#C1D82E', '#653aba');

	    $expense_headers = array("taxes",	 "payroll_tax",  "debt_payment", "other_expenses", "food_expenses", "rent_paid", "trans_expenses","child_care_expenses","health_expenses","salestax","disability_expenses","afterschool_expenses");
	    $expense_colors  = array('#7a2426',	 "#ff8d7a", '#af292e', '#ff5113', '#a90050', '#d6083b', '#cb4f00', '#ffa200', '#ba3a4f','#4fba3a','#653aba');
	}

  # reduce the number of bars, if necessary
    if($size == "small") { $bars = 20; }
    else { $bars = 20; }

    $points = count($data{'earnings'});
    if($bars >= $points) { $interval = 1; }
    else {
        $interval = ceil( $points / $bars );
    }

    $child_support_recd = 0;
    $local_eic_recd = 0;
    $cc_credit_recd = 0;
    $state_cadc_recd = 0;
    $child_care_cost = 0;
    $housing_cost = 0;
    $trans_cost = 0;
    $food_cost = 0;
    $health_cost = 0;
    $other_cost = 0;
    for ( $i = 0; $i < count($data{'earnings'}); $i = $i + $interval) {
        $bar_data{'earnings'}[] = $data{'earnings'}[$i];
                
        if($data{'taxes'}[$i] < 0 && $data{'taxes'}[$i] > -1000) {
        	$data{'taxes'}[$i] = 0;
        }
        
        foreach ($income_headers as $name) {
            $bar_data{$name}[] = $data{$name}[$i];
        }
        foreach ($expense_headers as $name) {
            $bar_data{$name}[] = $data{$name}[$i];
        }
        $bar_data{'zeros'}[] = 0;

        if($data{'child_support_recd'}[$i])
        {
            $child_support_recd = 1;
        }
        if($data{'local_eic_recd'}[$i])
        {
            $local_eic_recd = 1;
        }
        if($data{'cc_credit_recd'}[$i])
        {
            $cc_credit_recd = 1;
        }
        if($data{'state_cadc_recd'}[$i])
        {
            $state_cadc_recd = 1;
        }
        if($data{'local_cadc_recd'}[$i])
        {
            $local_cadc_recd = 1;
        }
        if($data{'state_ctc_recd'}[$i])
        {
            $state_ctc_recd = 1;
        }
        if($data{'liheap_recd'}[$i])
        {
            $liheap_recd = 1;
        }
        if($data{'heap_recd'}[$i])
        {
            $heap_recd = 1;
        }
        if($data{'tanf_recd'}[$i])
        {
            $tanf_recd = 1;
        }
        if($data{'lifeline_recd'}[$i])
        {
            $lifeline_recd = 1;
        }
        if($data{'child_care_expenses'}[$i])
        {
            $child_care_cost = 1;
        }
        if($data{'rent_paid'}[$i])
        {
            $housing_cost = 1;
        }
        if($data{'trans_expenses'}[$i])
        {
            $trans_cost = 1;
        }
        if($data{'food_expenses'}[$i])
        {
            $food_cost = 1;
        }
        if($data{'health_expenses'}[$i])
        {
            $health_cost = 1;
        }
        if($data{'other_expenses'}[$i])
        {
            $other_cost = 1;
        }
        if($data{'federal_tax_credits'}[$i])
        {
            $federal_tax_credits = 1;
        }
        if($data{'state_tax_credits'}[$i])
        {
            $state_tax_credits = 1;
        }
        if($data{'local_tax_credits'}[$i])
        {
            $local_tax_credits = 1;
        }
		if($data{'ssi_recd'}[$i])
        {
            $ssi_recd = 1;
        }
    }

    $debt_payment = 0;
    if($data{'debt_payment'}[0] > 0)
    {
        $debt_payment = 1;
    }
	
    $salestax = 0;
    if($data{'salestax'}[0] > 0)
    {
        $salestax = 1;
    }	
	
	$disability_expenses = 0;
    if($data{'disability_expenses'}[0] > 0)
    {
        $disability_expenses = 1;
    }	
	
	$afterschool_expenses = 0;
    if($data{'afterschool_expenses'}[0] > 0)
    {
        $afterschool_expenses = 1;
    }	
	

	
	
	if($year < 2006) {
	    $benefits = array(1, $child_support_recd, $state_ctc_recd, $data{'eitc'}[0], $data{'state_eitc'}[0], $local_eic_recd, $cc_credit_recd, $local_cadc_recd, $state_cadc_recd, $data{'tanf'}[0], $data{'fsp'}[0], $data{'fsp_alt'}[0], $liheap_recd);
	    $expenses = array(1, $debt_payment, $other_cost, $food_cost, $housing_cost, $trans_cost, $child_care_cost, $health_cost);
	} else {
	    #				  "earnings_plus_interest", "child_support_recd", 	"federal_tax_credits", 	"state_tax_credits", 	"local_tax_credits", 	"tanf_recd", 			"fsp_recd", 			"liheap_recd");
	    $benefits = array(1, $child_support_recd, $federal_tax_credits, $state_tax_credits, $local_tax_credits, $tanf_recd, $data{'fsp'}[0], $liheap_recd, $heap_recd, $child_support_recd, $ssi_recd);
	    $expenses = array(1, 1, $debt_payment, $other_cost, $food_cost, $housing_cost, $trans_cost, $child_care_cost, $health_cost, $salestax, $disability_expenses, $afterschool_expenses);
	}

    $show_expenses = 1 + $debt_payment + $other_cost + $food_cost + $housing_cost + $trans_cost + $child_care_cost + $health_cost + $salestax + $disability_expenses + $afterschool_expenses;

    if($show_expenses)
    {
        $var = "expense_header";
        $$var = new BarPlot($bar_data{'zeros'});
        $$var->SetColor("white");
        $$var->SetFillColor("white");
        $$var->SetLegend("EXPENSES");
        $barplots_b1[] = $$var;
    }

    $var = "blank_header";
    $$var = new BarPlot($bar_data{'zeros'});
    $$var->SetColor("white");
    $$var->SetFillColor("white");
    $$var->SetLegend(" ");
    $barplots_b1[] = $$var;

    foreach ($income_headers as $i => $name) {
        if($benefits[$i]) {
            $var = "b1." . $i . "plot";
            $$var = new BarPlot($bar_data{$name});
            $$var->SetColor("white");
            $$var->SetFillColor($income_colors[$i % count($income_colors)]);
            $$var->SetLegend($labels[$name]);
            $barplots_b1[] = $$var;
        }
    }

  // Create the bar plots for income
    $var = "income_header";
    $$var = new BarPlot($bar_data{'zeros'});
    $$var->SetColor("white");
    $$var->SetFillColor("white");
    $$var->SetLegend("RESOURCES");
    $barplots_b1[] = $$var;

    if($show_expenses)
    {
      // Create the bar plots for expenses
        foreach ($expense_headers as $i => $name) {
            if($expenses[$i])
            {
                $var = "b2." . $i . "plot";
                $$var = new BarPlot($bar_data{$name});
                $$var->SetColor("white");
                $$var->SetFillColor($expense_colors[$i % count($expense_colors)]);
                $$var->SetLegend($labels[$name]);
                $barplots_b2[] = $$var;
            }
        }
    }
    else
    {
        $var = "blank_header";
        $$var = new BarPlot($bar_data{'zeros'});
        $$var->SetColor("white");
        $$var->SetFillColor("white");
        $$var->SetLegend(" ");
        $barplots_b2[] = $$var;
    }

    // Create the accumulated bar plot for income
    $ab1plot = new AccBarPlot($barplots_b1);
    $ab1plot->SetWidth(1);

    // Create the accumulated bar plot for expenses
    $ab2plot = new AccBarPlot($barplots_b2);
    $ab2plot->SetWidth(1);

    // Create the grouped bar plot
    $gbplot = new GroupBarPlot (array($ab1plot, $ab2plot));

    // Create the grouped bar plot
    $gbplot = new GroupBarPlot (array($ab1plot, $ab2plot));

    // And add it to the graph
    $graph->Add($gbplot);

    $graph->title->Set("Family Resources and Basic Expenses");
    $graph->yaxis->title->Set("Resources/Expenses");

	#$graph->xaxis->SetPos('min');
    $graph->xaxis->HideTicks();
    $graph->xaxis->SetTextTickInterval(1);
    
    $x_labels = $bar_data{'earnings'};
    if($data{'earnings'}[1] - $data{'earnings'}[0] == 1) {
        array_walk($x_labels, create_function('&$v,$k', '$v = $v . "K";'));
    }
    $graph->xaxis->SetTickLabels($x_labels);

}

#
# SIMPLIFIED INCOME/EXPENSES BAR
# NOT USED IGNORE JAY BALA
#######################################

function simplified_master (&$data, $size, &$graph, $time_span, $state_year)
{

//    $income_colors = array("#44A95E","#114695","#2062B4","#0099FF","#000000", "#666666", "#92AAC7","#0F00D8","#6F80FE");
//    $expense_colors = array("#FF3600","#530913","#AA0D0D","#C28080","#FF0000","#FF6363","#FCC1C1");

  # reduce the number of bars, if necessary
    if($size == "small") { $bars = 11; }
    else { $bars = 11; }

    $points = count($data{'earnings'});
    if($bars >= $points) { $interval = 1; }
    else {
        $interval = ceil( $points / $bars );
    }

    #print_r("$points|$bars|$interval");

    $c = 0;
    for ( $i = 0; $i < count($data{'earnings'}); $i = $i + $interval) {
        $earnings[] = $data{'earnings'}[$i];
        $resources[]  = $data{'earnings_posttax'}[$i] + $data{'child_support_recd'}[$i] + $data{'eitc_recd'}[$i] + $data{'state_eic_recd'}[$i] + $data{'local_eic_recd'}[$i] + $data{'state_cadc_recd'}[$i] + $data{'tanf_recd'}[$i] + $data{'fsp_recd'}[$i] + $data{'ctc_total_recd'}[$i];
        $expenses[]   = $data{'rent_paid'}[$i] + $data{'child_care_expenses'}[$i] + $data{'food_expenses'}[$i] + $data{'trans_expenses'}[$i] + $data{'other_expenses'}[$i] + $data{'health_expenses'}[$i] + $data{'debt_payment'}[$i];
        $difference[] = $resources[$c] - $expenses[$c];
        $c++;
    }

    $bar_1 = new BarPlot($resources);
    $bar_1->SetColor("white");
    $bar_1->SetFillColor("#0F00D8");
    $bar_1->SetLegend("Resources");

    $bar_2 = new BarPlot($expenses);
    $bar_2->SetColor("white");
    $bar_2->SetFillColor("#CD172F");
    $bar_2->SetLegend('Expenses');

    $bar_3 = new BarPlot($difference);
    $bar_3->SetColor("white");
    $bar_3->SetFillColor("#44A95E");
    $bar_3->SetLegend("Resources after\nsubtracting\nexpenses");

    // Create the grouped bar plot
    $gbplot = new GroupBarPlot (array($bar_1, $bar_2, $bar_3));
    $gbplot->SetWidth(0.8);

    // And add it to the graph
    $graph->Add($gbplot);

    $graph->title->Set("Resources and Expenses");
    $graph->yaxis->title->Set("Resources/Expenses");
    $graph->xaxis->HideTicks();
    $graph->xaxis->SetTextTickInterval(1);

    $x_labels = $earnings;
    if($data{'earnings'}[1] - $data{'earnings'}[0] == 1) {
        array_walk($x_labels, create_function('&$v,$k', '$v = $v . "K";'));
    }
    $graph->xaxis->SetTickLabels($x_labels);

    $graph->AddLine(new PlotLine(HORIZONTAL,0,"red",1));

    $graph->xaxis->SetPos("min");

}

#
# EXPENSES RELATIVE TO TOTAL BAR CHART
#
#######################################

function relative_expenses (&$data, $size, &$graph, $time_span, $state_year)
{
    global $labels;

    $graph->SetScale("textlin", 0, 100);

    $expense_headers = array("debt_payment","other_expenses","food_expenses","rent_paid","trans_expenses","child_care_expenses","health_expenses");
    $expense_colors = array('#B51019','#630208','#F98885','#F70824','#820023','#D21041','#F26649');

  # reduce the number of bars, if necessary
    if($size == "small") { $bars = 11; }
    else { $bars = 11; }

    $points = count($data{'earnings'});
    if($bars >= $points) { $interval = 1; }
    else {
        $interval = ceil( $points / $bars );
    }

    $child_care_cost = 0;
    $housing_cost = 0;
    $trans_cost = 0;
    $food_cost = 0;
    $health_cost = 0;
    $other_cost = 0;
    for ( $i = 0; $i < count($data{'earnings'}); $i = $i + $interval) {
        $bar_data{'earnings'}[] = $data{'earnings'}[$i];
        $expenses = $data{'rent_paid'}[$i] + $data{'child_care_expenses'}[$i] + $data{'food_expenses'}[$i] + $data{'trans_expenses'}[$i] + $data{'other_expenses'}[$i] + $data{'health_expenses'}[$i] + $data{'debt_payment'}[$i];

        foreach ($expense_headers as $name) {
            $bar_data{$name}[] = $data{$name}[$i]/$expenses * 100;
        }
        $bar_data{'zeros'}[] = 0;

        if($data{'child_care_expenses'}[$i])
        {
            $child_care_cost = 1;
        }
        if($data{'rent_paid'}[$i])
        {
            $housing_cost = 1;
        }
        if($data{'trans_expenses'}[$i])
        {
            $trans_cost = 1;
        }
        if($data{'food_expenses'}[$i])
        {
            $food_cost = 1;
        }
        if($data{'health_expenses'}[$i])
        {
            $health_cost = 1;
        }
        if($data{'other_expenses'}[$i])
        {
            $other_cost = 1;
        }
    }

    $debt_payment = 0;
    if($data{'debt_payment'}[0] > 0)
    {
        $debt_payment = 1;
    }

    $expenses = array($debt_payment, $other_cost, $food_cost, $housing_cost, $trans_cost, $child_care_cost, $health_cost);

  // Create the bar plots for expenses
    foreach ($expense_headers as $i => $name) {
        if($expenses[$i])
        {
            $var = "b2." . $i . "plot";
            $$var = new BarPlot($bar_data{$name});
            $$var->SetColor("white");
            $$var->SetFillColor($expense_colors[$i % count($expense_colors)]);
            $$var->SetLegend($labels[$name]);
            $barplots[] = $$var;
        }
    }

    // Create the accumulated bar plot for expenses
    $abplot = new AccBarPlot($barplots);
    $abplot->SetWidth(1);

    // And add it to the graph
    $graph->Add($abplot);

    $graph->title->Set("Expense Categories as % of Total Expenses");
    $graph->yaxis->title->Set("% of Total Expenses");
    $graph->xaxis->HideTicks();
    $graph->xaxis->SetTextTickInterval(1);

    $x_labels = $bar_data{'earnings'};
    if($data{'earnings'}[1] - $data{'earnings'}[0] == 1) {
        array_walk($x_labels, create_function('&$v,$k', '$v = $v . "K";'));
    }
    $graph->xaxis->SetTickLabels($x_labels);

    $graph->yaxis->SetLabelFormat('%d%');

}

#
# EXPENSES RELATIVE TO TOTAL LINE CHART
#
#######################################

function relative_expenses_line (&$data, $size, &$graph, $time_span, $state_year)
{
    global $labels;

    $graph->SetScale("textlin", 0, 100);

    $expense_headers = array("debt_payment","other_expenses","food_expenses","rent_paid","trans_expenses","child_care_expenses","health_expenses");
    $expense_colors = array('#B51019','#630208','#F98885','#F70824','#820023','#D21041','#F26649');

  # reduce the number of x-labels, if necessary
    if($size == "small") { $bars = 11; }
    else { $bars = 11; }

    $points = count($data{'earnings'});
    if($bars >= $points) { $interval = 1; }
    else {
        $interval = ceil( $points / $bars );
    }

    $child_care_cost = 0;
    $housing_cost = 0;
    $trans_cost = 0;
    $food_cost = 0;
    $health_cost = 0;
    $other_cost = 0;
    for ( $i = 0; $i < count($data{'earnings'}); $i++) {

        if($data{'earnings'}[$i] % $interval == 0) {
            $tick_labels[$i] = $data{'earnings'}[$i] . "K";
        }
        else {
            $tick_labels[$i] = '';
        }

        $expenses = $data{'rent_paid'}[$i] + $data{'child_care_expenses'}[$i] + $data{'food_expenses'}[$i] + $data{'trans_expenses'}[$i] + $data{'other_expenses'}[$i] + $data{'health_expenses'}[$i] + $data{'debt_payment'}[$i];

        foreach ($expense_headers as $name) {
            $bar_data{$name}[] = $data{$name}[$i]/$expenses * 100;
        }
        $bar_data{'zeros'}[] = 0;

        if($data{'child_care_expenses'}[$i])
        {
            $child_care_cost = 1;
        }
        if($data{'rent_paid'}[$i])
        {
            $housing_cost = 1;
        }
        if($data{'trans_expenses'}[$i])
        {
            $trans_cost = 1;
        }
        if($data{'food_expenses'}[$i])
        {
            $food_cost = 1;
        }
        if($data{'health_expenses'}[$i])
        {
            $health_cost = 1;
        }
        if($data{'other_expenses'}[$i])
        {
            $other_cost = 1;
        }
    }

    $debt_payment = 0;
    if($data{'debt_payment'}[0] > 0)
    {
        $debt_payment = 1;
    }

    $expenses = array($debt_payment, $other_cost, $food_cost, $housing_cost, $trans_cost, $child_care_cost, $health_cost);

  // Create the line plots for expenses
    foreach ($expense_headers as $i => $name) {
        if($expenses[$i])
        {
            $var = "b2." . $i . "plot";
            $$var = new LinePlot($bar_data{$name});
            $$var->SetColor("white");
            $$var->SetFillColor($expense_colors[$i % count($expense_colors)]);
            $$var->SetLegend($labels[$name]);
            $lineplots[] = $$var;
        }
    }

    // Create the accumulated bar plot for expenses
    $alplot = new AccLinePlot($lineplots);

    // And add it to the graph
    $graph->Add($alplot);

    $graph->title->Set("Expense Categories as % of Total Expenses");
    $graph->yaxis->title->Set("% of Total Expenses");
    $graph->xaxis->HideTicks();
    $graph->xaxis->SetTextTickInterval(1);

    $graph->xaxis->SetTickLabels($tick_labels);

}


#
# CHILD BENEFIT LINE CHART
#
#######################################

function line_child_benefit (&$data, $size, &$graph, $time_span, $state, $year)
{
  // get calculated values (state income tax, federal income tax, local income tax)
    for($i = 0; $i < count($data{'earnings'}); $i++)
    {
    	$data_eitc[$i] 		= $data{'eitc_recd'}[$i];
    	$data_exempt[$i]	= $data{'eitc_recd'}[$i] + $data{'net_child_benefit'}[$i];
    	$data_ctc[$i]		= $data{'eitc_recd'}[$i] + $data{'net_child_benefit'}[$i] + $data{'ctc_total_recd'}[$i];
    	$data_cadc[$i]		= $data{'eitc_recd'}[$i] + $data{'net_child_benefit'}[$i] + $data{'ctc_total_recd'}[$i] + $data{'cadc_recd'}[$i];
    }

  // Create linear plots
    $line_cadc = new LinePlot($data_cadc);
    $line_cadc->SetLegend("Child care credit");
    $line_cadc->SetColor("black");
    $line_cadc->SetFillColor("#F9A350");
    $line_cadc->SetWeight(1);
    $graph->Add($line_cadc);
 
    $line_ctc = new LinePlot($data_ctc);
    $line_ctc->SetLegend("Child tax credit");
    $line_ctc->SetColor("black");
    $line_ctc->SetFillColor("#569BBD");
    $line_ctc->SetWeight(1);
    $graph->Add($line_ctc);

    $line_exempt = new LinePlot($data_exempt);
    $line_exempt->SetLegend("Dependent\nexemptions");
    $line_exempt->SetColor("black");
    $line_exempt->SetFillColor("#7E2271");
    $line_exempt->SetWeight(1);
    $graph->Add($line_exempt);

    $line_eitc = new LinePlot($data_eitc);
    $line_eitc->SetLegend("EITC");
    $line_eitc->SetColor("black");
    $line_eitc->SetFillColor("#008576");
    $line_eitc->SetWeight(1);
    $graph->Add($line_eitc);
 
  // Format the x axis labels
    $x_labels = $data{'earnings'};
    if($data{'earnings'}[1] - $data{'earnings'}[0] == 1)
    {
        array_walk($x_labels, create_function('&$v,$k', '$v = $v . "K";'));
    }
    $graph->xaxis->SetTickLabels($x_labels);

    $graph->title->Set("Federal Tax Benefits Associated With Having Children");
    $graph->yaxis->title->Set("Tax Benefits");
    if(count($data{'earnings'}) > 12) {
        $graph->xaxis->SetTextTickInterval(round(count($data{'earnings'})/12));
    }

    if($time_span == "monthly")
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormatMnth');
    }
    else
    {
        $graph->yaxis->SetLabelFormatCallback('yLabelFormat');
    }

    $graph->xaxis->SetPos("min");
}

?>
