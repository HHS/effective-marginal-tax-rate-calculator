<?php
$JPGRAPH_DIR = '../../lib/jpgraph/';
$TEMP_DIR    = './temp/';

include ("$JPGRAPH_DIR/src/jpgraph.php");
include ("$JPGRAPH_DIR/src/jpgraph_bar.php");
include ("$JPGRAPH_DIR/src/jpgraph_line.php");
include ("$JPGRAPH_DIR/src/jpgraph_scatter.php");
include ("chart_functions.php");

setlocale (LC_ALL, 'et_EE.ISO-8859-1');

// Get the id being used as an argument
$id = $_GET['id'];
if($_GET['type']) { $type = $_GET['type']; }
else { $type = "cash"; }
if($_GET['size']) { $size = $_GET['size']; }
else { $size = "large"; }
if($_GET['time_span']) { $time_span = $_GET['time_span']; }
else { $time_span = "yearly"; }
if($_GET['state']) { $state = $_GET['state']; }
else { $state = "CT"; }
if($_GET['year']) { $year = $_GET['year']; }
else { $year = "2002"; }

$states = array(
	'AL' => 'Alabama',
	'CA' => 'California',
	'CO' => 'Colorado',
	'CT' => 'Connecticut',
	'DC' => 'District of Columbia',
	'DE' => 'Delaware',
	'FL' => 'Florida',
	'GA' => 'Georgia',
	'IL' => 'Illinois',
	'IN' => 'Indiana',
	'IA' => 'Iowa',
	'LA' => 'Louisiana',
	'MD' => 'Maryland',
	'MA' => 'Massachusetts',
	'MI' => 'Michigan',
	'MS' => 'Mississippi',
	'NY' => 'New York',
	'PA' => 'Pennsylvania',
	'TX' => 'Texas',
	'WA' => 'Washington',
	'VT' => 'Vermont',
	'NM' => 'New Mexico',
	'OH' => 'Ohio',
	'ND' => 'North Dakota',
	'MT' => 'Montana',
	'NJ' => 'New Jersey',
);

$state_name = $states[$state];

$labels = array(
    'earnings' 				=> 'Earnings',
    'earnings_plus_interest' 		=> 'Earnings',
    'earnings_posttax' 			=> 'Post-Tax Earnings',
    'taxes' 				=> "Income taxes\n(excluding credits)",
    'child_support_recd'		=> 'Child Support',
    'eitc_recd' 			=> 'Federal EITC',
    'state_eic_recd' 			=> 'State EITC',
    'local_eic_recd' 			=> 'Local EITC',
    'local_eitc_recd' 			=> 'Local EITC',
    'cadc_recd'				=> "Federal child care\ntax credit",
    'state_cadc_recd' 			=> "State child care\ntax credit",
    'local_cadc_recd'			=> "Local child care\ntax credit",
    'ctc_total_recd' 			=> "Federal Child\nTax Credit",
    'tanf_recd' 			=> 'TANF',
    'fsp_recd' 				=> 'SNAP/Food Stamps',
    'housing_recd' 			=> 'Housing',
    'hlth_recd' 			=> 'Health insurance',
    'child_care_recd' 			=> 'Child care',
    'rent_paid' 			=> 'Rent and utilities',
    'child_care_expenses' 		=> 'Child care',
    'food_expenses' 			=> 'Food',
    'trans_expenses' 			=> 'Transportation',
    'health_expenses' 			=> 'Health care',
    'other_expenses' 			=> 'Other necessities',
    'housing_recd' 			=> 'Rent and utilities',
    'child_care_recd' 			=> 'Child care',
    'hlth_cov_parent' 			=> 'Parent',
    'hlth_cov_child1' 			=> 'Child 1',
    'hlth_cov_child2' 			=> 'Child 2',
    'hlth_cov_child3' 			=> 'Child 3',
    'debt_payment' 			=> 'Debt Payment',
    'cc_credit_recd' 			=> 'State Child Care Credit',
    'nutrition_recd' 			=> 'Supp. Nutrition Allowance',
    'state_ctc_recd'			=> "State Child Tax\nCredit",
    'liheap_recd'			=> "LIHEAP",
    'renter_credit_recd'		=> "Renter credit",
    'schoolread_credit_recd'		=> "School readiness\ncredit",
    'federal_tax_credits'		=> "Federal tax credits",
    'state_tax_credits'			=> "State tax credits",
    'local_tax_credits'			=> "Local tax credits",
    'payroll_tax'			=> "Payroll taxes",
    'tax_after_credits'			=> "Income taxes\n(excluding credits)",
    'mwp_recd'				=> "Making Work Pay\nTax Credit",
    'mrvp_vouch_recd'			=> "Rental Vouchers",
    'heap_recd'                         => "HEAP",
    'lifeline_recd'                     => "Lifeline Subsidy",
    'premium_credit_recd'               => "Premium Tax Credit",
    'medically_needy'                   => "Medically Needy",
	'salestax'							=> "Sales Tax",
	'disability_expenses' 				=> "Disability Expenses",
	'afterschool_expenses'				=> "Afterschool Expenses",
	'ssi_recd'							=> "SSI"
);

if($state == 'CO' || $state == 'LA') { $labels['state_cadc_recd'] = "State Child Care\nTax Credit"; }
if($state == 'DC') { $labels['wic_recd'] = "wic DC"; }
if($state == 'MT') { $labels['liheap_recd'] = "LIEAP"; }

// Read in the data from the .csv file
$csv = fopen ($TEMP_DIR.$id.".csv","r");

if($csv)
{
    $headers = fgetcsv ($csv, 1000, ",");
    while ($line = fgetcsv ($csv, 1000, ",")) {
        foreach ($headers as $i => $name) {
            if (preg_match("/child\d_age/", $name)) {
                $data{$name}[] = $line[$i];
            }
            if (preg_match ("/^(-?[0-9]*.?[0-9]+)$/", $line[$i])) {
                 if($time_span == "monthly") {
                    $data{$name}[] = $line[$i]/12;
                 }
                 else {
                    $data{$name}[] = $line[$i]/1000;
                 }
            } else {
                 $data{$name}[] = $line[$i];
            }
        }
    }
    fclose ($csv);
}
else
{
   die( "fopen failed for $csv" ) ;
}

if($type != 'eligibility') {

    // Create the graph. These two calls are always required
    if($size == "small") { 
    	$graph = new Graph(124,80,"auto"); 
	    $graph->img->SetMargin(2,2,2,2);
	    $font_size = 7;
    }
    else { 
    	$graph = new Graph(540, 340, "auto"); 
	    $graph->img->SetMargin(50,124,30,100);
	    $font_size = 8;
    }

    $graph->SetMarginColor("white");
    $graph->SetScale("textlin");

    $type($data, $size, $graph, $time_span, $state, $year);   // call the appropriate function

    // Setup legend
    if($size == "small") { 
    	#$graph->legend->SetPos(.65,.07,'left','top'); 
    	$graph->legend->Hide();
    }
    else { 
    	$graph->legend->SetPos(.78,.07,'left','top'); 
	    $graph->legend->SetColumns(1);
	    $graph->legend->SetFont(FF_TAHOMA,FS_NORMAL,$font_size);
	    $graph->legend->SetFillColor("white");
	    $graph->legend->SetShadow(0);
	    $graph->legend->SetFrameWeight(0);
	    if(preg_match('/line/', $type)) {
	        $graph->legend->SetLineWeight(1);
	    }
	    else {
	        $graph->legend->SetLineWeight(0);
	    }
    }

	if($size == 'small') {
		$graph->xaxis->Hide();
		$graph->xaxis->HideTicks();
		$graph->xaxis->HideLabels();
		$graph->yaxis->Hide();
		$graph->yaxis->HideTicks();
		$graph->yaxis->HideLabels();
	}
	else {
	    // X-labels
	    $graph->xaxis->SetFont(FF_TAHOMA,FS_NORMAL,$font_size);
	    $graph->xaxis->SetLabelAngle(90);
	    $graph->xaxis->SetLabelMargin(10);
	    $graph->xaxis->title->SetFont(FF_TAHOMA, FS_NORMAL,$font_size);
	
	    // Y-labels
	    $graph->yaxis->SetFont(FF_TAHOMA,FS_NORMAL,$font_size);
	    $graph->yaxis->scale->ticks->SetSide(SIDE_LEFT);
	    $graph->yaxis->title->SetFont(FF_TAHOMA, FS_NORMAL,$font_size);
	}

    // Title
    if($size == 'small') { 
    	$graph->title->Set(''); # Don't even show a title on the thumbnail version
    }
    else {
    	$graph->title->SetFont(FF_TAHOMA, FS_BOLD, 12); 
	    $graph->title->Align("left");
    	$graph->title->ParagraphAlign("left");
    }
    
    if($time_span == "monthly") {
        $graph->xaxis->title->Set("Monthly Earnings");
        $graph->xaxis->SetTitlemargin(18);
        $graph->yaxis->SetTitlemargin(40);
        $graph->yaxis->SetLabelFormat('$%d'); # want to format label as $100 (actual dollar amount)
    }
    else {
        $graph->xaxis->SetTitlemargin(14);
        $graph->yaxis->SetTitlemargin(40);
        $graph->xaxis->title->Set("Annual Earnings");
        if($type == "relative_expenses_line") {
            $graph->yaxis->SetLabelFormat('%d%%');
        }
        else {
            $graph->yaxis->SetLabelFormat('$%dK');
        }
    }

    $graph->SetFrame(false,'white',0);

    if($size == "small") { $y = 250; }
    else { $y = 280; }
    if($type == 'line_child_benefit') {
	    $caption = new Text("© National Center for Children in Poverty\nFamily Resource Simulator, Tax Year $year",50, $y);
    } else {
	    $caption = new Text("© National Center for Children in Poverty\nFamily Resource Simulator, $state_name $year (Results reflect user choices.)",50, $y);
    }
    $caption->Align('left','top');
    $caption->SetColor('darkgray');
    $caption->SetFont(FF_TAHOMA,FS_NORMAL,8);
    $graph->AddText($caption);

}
else {
    // Create the graph
    if($size == "small") { 
    	$graph = new Graph(124,80,"auto"); 
	    $graph->SetScale("textlin", 0, $data{'earnings'}[count($data{'earnings'}) - 1]);
	    $graph->Set90AndMargin(5,5,5,5);
    }
    else { 
    	$graph = new Graph(540, 340, "auto"); 
    	$graph->SetScale("textlin", 0, $data{'earnings'}[count($data{'earnings'}) - 1]);
	    $graph->Set90AndMargin(10,120,80,100);
    }
    $graph->SetMarginColor("white");
    $type($data, $size, $graph, $time_span, $state, $year);

    if($size == "small") { 
		$graph->xaxis->HideTicks();
		$graph->xaxis->HideLabels();
		$graph->yaxis->HideTicks();
		$graph->yaxis->HideLabels();
		$graph->title->Set('');
    }
    else { 
/*
	    $subtitle = new Text("(Results vary based on user choices for this simulation.*)", 3, 17);
	    $subtitle->SetFont(FF_TAHOMA, FS_NORMAL, 9);
	    $subtitle->Align('left','top');
	    $graph->AddText($subtitle);
*/

	    if($time_span == "monthly") { $x_label = new Text("Monthly Earnings", 325, 36); }
	    else 						{ $x_label = new Text("Annual Earnings", 325, 36);  }
	    $x_label->Align('center','top');
	    $x_label->SetFont(FF_TAHOMA,FS_NORMAL,8);
	    $graph->AddText($x_label);
	
	    // Title
    	$graph->title->SetFont(FF_TAHOMA, FS_BOLD, 12); 
	    $graph->title->Align("left");
	    $graph->title->ParagraphAlign("left");

    	$caption = new Text("© National Center for Children in Poverty\nFamily Resource Simulator, $state_name $year (Results reflect user choices.)",10, 250);
	    $caption->Align('left','top');
	    $caption->SetColor('darkgray');
	    $caption->SetFont(FF_TAHOMA,FS_NORMAL,7.5);
	    $graph->AddText($caption);
    	$caption2 = new Text("*Note that eligibility for benefits is often tied to adjusted income--i.e., income after certain allowed\ndeductions--so a family with gross income above a program's eligibility limit could still be eligible.", 10, 300);
	    $caption2->SetFont(FF_TAHOMA,FS_NORMAL,7.5);
	    $caption2->Align('left','top');
	    $graph->AddText($caption2);
	}
}

// Display the graph
$graph->Stroke();

?>
