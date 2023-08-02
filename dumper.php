<?php include("../../inc/headers_sps.php"); ?>

<?php
	session_start();
	$simulator    = Sps_TableFactory::create_table("NCCP_Simulator");
	$page_title   = "Basic Budget Dumper";
	$page_section = "tools";
	$page_layout  = "content-full";	
	if (!$log = fopen('log', 'a')) {
         echo "Cannot open file (log)";
         exit;
    }
	if (!$output = fopen('output.csv', 'w')) {
         echo "Cannot open file (output.csv)";
         exit;
    }
?>

<?php include("inc/headers_html.php"); ?>
<?php include("inc/headers_page.php"); ?>
<?php include("inc/menu.php"); ?>

	<div class="breadcrumbs">
	    <a href="/">Home</a> &gt; <a href="/tools">Data Tools</a> &gt;
	</div>
	
    <div id="content" class="content frs">
        <div class="container">
			
			<h1>Basic Budget Dumper</h1>
			
			<?php 
			$args = array();
		    fwrite($log, "\n\nBEGINNING DUMPER: " . date('l dS \of F Y h:i:s A') . "\n\n");
		    fwrite($output, "State,Year,Residence,Rent and Utilities,Food,Child Care,Health Insurance,Transportation,Other Necessities,Payroll and Income Taxes,TOTAL,Hourly wage needed\n");
			foreach($simulator->get_simulators() as $s) {
				foreach($simulator->get_residences($s['code'],$s['year']) as $i => $r) {
					$args['simulator'] = $s['code'] . $s['year'];
					$args['residence'] = $r['id'];
					$simulator_name = sprintf('%s %s: %s', $s['name'], $s['year'], $r['name']);
				    fwrite($log, "Running budget for $simulator_name\n");
					$results = $simulator->budget($args);
					$taxes = $results['payroll_tax'] + $results['federal_tax'] + $results['state_tax'] + $results['local_tax'] - $results['ctc_total_recd'];
					$expenses = $results['rent_paid'] + $results['food_expenses'] + $results['child_care_expenses'] + 
								$results['trans_expenses'] + $results['health_expenses'] + $results['other_expenses'];
					fwrite($output, sprintf("%s,%s,%s,%f,%f,%f,%f,%f,%f,%f,%f,%f\n",
											$s['name'], $s['year'], $r['name'],
											$results['rent_paid'],
											$results['food_expenses'],
											$results['child_care_expenses'],
											$results['health_expenses'],
											$results['trans_expenses'],
											$results['other_expenses'],
											$taxes,
											$expenses + $taxes,
											$results['earnings'] / 2080
							));
					fwrite($log, "Finished output for $simulator_name\n");
				}
			}
			fclose($log);
			fclose($output);
			?>
			
			<p><a href="output.csv">Download CSV file of all basic budget results.</a></p>
        </div>
    </div>

<?php include("inc/footers.php"); ?>
