<?php include("../../inc/headers_sps.php"); ?>

<?php
	session_start();
	$simulator    = Sps_TableFactory::create_table("NCCP_Simulator");
	$simulator_list = $simulator->get_simulators();
	$page_title   = "Simulator Reports";
	$page_section = "tools";

	$scripts = array("prototype.js", "scriptaculous.js", "validation.js", "multiselect.js");
	$page_layout  = "content-full";	
	
	$standard_dimensions = array('simulator' => 'Simulator',
								 'mode' => 'Mode (Sample/Step-by-step)',
								 'residence' => 'Residence',
								 'benefits' => 'Benefits Chosen',
								 'last_step' => 'Last Step'
								);
	$extra_dimensions = array('year' => 'Years',
							  'month' => 'Months',
							  'day' => 'Days'
							 );
	if($_REQUEST['submit']) {
		$results = $simulator->get_report($_REQUEST);
		$results_csv_name = base_convert(time(),10,36) . '.csv';
		$csv = fopen($simulator->frs_directory . '/temp/' . $results_csv_name, 'w');
		$date_start = date('Y-m-d', strtotime($_REQUEST['date_start']));
		$date_end   = date('Y-m-d', strtotime($_REQUEST['date_end']));
		$all_simulators = $_REQUEST['all_simulators'];
	}
	else {
		$date_start = $simulator->get_report_date_start();
		$date_end = $simulator->get_report_date_end();
		$all_simulators = 1;
	}
?>

<?php include("inc/headers_html.php"); ?>
<?php include("inc/headers_page.php"); ?>
<?php include("inc/menu.php"); ?>

	<div class="breadcrumbs">
	    <a href="/">Home</a> &gt; <a href="/tools">Data Tools</a> &gt; <a href="/tools/frs">Family Resource Simulator</a>
	</div>
	
    <form id="main-id" name="main" action="<?php echo $_SERVER['PHP_SELF'] ?>" method="post">

    <div id="content" class="content frs">
        <div class="container">
			
			<h1>Family Resource Simulator Reports</h1>
			
			<div style="float:left;padding: 0 10px;border-right:1px solid #666;">
				<h2 class="noborder">Dates (optional)</h2>
				<p>
					<label for="date_start">From</label><br/>
					<input type="text" name="date_start" id="date_start" value="<?php echo $date_start ?>" />
				</p>
				<p>
					<label for="date_end">To</label><br/>
					<input type="text" name="date_end" id="date_end" value="<?php echo $date_end ?>" />
				</p>
			</div>
			
			<div style="float:left;padding: 0 10px;border-right:1px solid #666;">
				<h2 class="noborder">Dimensions</h2>
				<p>
					<label for="dimension_y">Rows</label><br/>
					<select name="dimension_y" id="dimension_y" style="width:150px;">
						<?php foreach($standard_dimensions as $key => $value) { ?>
							<option value="<?php echo $key ?>" <?php if($_REQUEST['dimension_y'] == $key) { echo 'selected="selected"'; } ?>><?php echo $value ?></option>
						<?php } ?>
					</select>
				</p>
				<p>
					<label for="dimension_x">Columns</label><br/>
					<select name="dimension_x" id="dimension_x" style="width:150px;">
						<option value="">Totals</option>
						<?php foreach($extra_dimensions as $key => $value) { ?>
							<option value="<?php echo $key ?>" <?php if($_REQUEST['dimension_x'] == $key) { echo 'selected="selected"'; } ?>><?php echo $value ?></option>
						<?php } ?>
						<?php foreach($standard_dimensions as $key => $value) { ?>
							<option value="<?php echo $key ?>" <?php if($_REQUEST['dimension_x'] == $key) { echo 'selected="selected"'; } ?>><?php echo $value ?></option>
						<?php } ?>
					</select>
				</p>
			</div>
			
			<div style="float:left;padding: 0px 10px;">
				<h2 class="noborder">Simulators</h2>
				<input type="hidden" name="hidden_simulators" id="hidden_simulators" value="<?php echo $_REQUEST['hidden_simulators'] ?>" />
				<div style="float:left;">
					<select name="from_simulators" id="from_simulators" size="6" style="width:150px" multiple>
						<?php foreach($simulator_list as $s) {
							if(!preg_match('/'.$s['code'].$s['year'].'/', $_REQUEST['hidden_simulators'])) { ?>
								<option value="<?php echo $s['code'] . $s['year'] ?>"><?php echo $s['code'] . $s['year'] ?></option>
						<?php } } ?>
					</select>
				</div>
				<div style="float:left;padding:10px;margin-top:20px;">
					<button onclick="return sps_select_multiple_add('simulators');">&gt;&gt;</button><br/>
					<button onclick="return sps_select_multiple_remove('simulators');">&lt;&lt;</button>
				</div>
				<div style="float:left;">
					<select name="to_simulators" id="to_simulators" size="6" style="width:150px" multiple>
						<?php foreach($simulator_list as $s) { 
							if(preg_match('/'.$s['code'].$s['year'].'/', $_REQUEST['hidden_simulators'])) { ?>
								<option value="<?php echo $s['code'] . $s['year'] ?>"><?php echo $s['code'] . $s['year'] ?></option>
							
						<?php } } ?>
					</select>
				</div>
				<br class="clearing" />
				<input type="checkbox" name="all_simulators" id="all_simulators" <?php if($all_simulators) { echo "checked"; } ?>/><label for="all_simulators">&nbsp;Include All Simulators</label><br/><br/>
			</div>
			<p class="clearing" style="text-align:right;"><input type="submit" name="submit" value="Generate Table" class="submit" /></p>
			<br/><br/>
			<?php if($results) { 
				$columns = $results[0]['columns'];
				$labels = array();
			?>
			<h2>Use of the Simulator</h2>
			<h3>Date Range: <?php echo $date_start ?> to <?php echo $date_end; ?></h3>
			<table class="data">
				<?php 
					fputcsv($csv, array("Use of the Simulator: $date_start to $date_end"));
					fputcsv($csv, array(''));
					if ($_REQUEST['dimension_x']) { 
						if($standard_dimensions[$_REQUEST['dimension_x']]) {
							$top_label = $standard_dimensions[$_REQUEST['dimension_x']];
						} else {
							$top_label = $extra_dimensions[$_REQUEST['dimension_x']];
						}
						fputcsv($csv, array('','',$top_label));
				?>
					<tr>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
						<td class="header top" colspan="<?php echo sizeof($columns) ?>"><?php echo $top_label ?></td>
					</tr>
				<?php } ?>
				<tr>
					<td class="header top"><?php echo $standard_dimensions[$_REQUEST['dimension_y']] ?></td>
					<td class="header top">Total Uses</td>
					<td class="header top">Unique Users</td>
					<td class="header top">Avg. Time Spent</td>
					
					<?php 
						$csv_row = array('','Total Uses','Unique Users','Time Spent');
						foreach($columns as $c) {
							array_push($labels, $c['label']);
							array_push($csv_row, $c['label']);
							printf('<td class="header top">%s</td>', $c['label']);
						} 
						fputcsv($csv, $csv_row);
					?>
					
				</tr>
				<?php foreach($results as $count => $row) {
					if($count % 2 == 1) { $alternate = 'alternate'; }
					else { $alternate = ''; }
					$csv_row = array($row['label'], $row['count'], $row['unique'], $row['time']);
				?>
					<tr>
						<td class="header left <?php echo $alternate ?>"><?php echo $row['label'] ?></td>
						<td class="<?php echo $alternate ?>"><?php echo $row['count'] . ' (' . round($row['percent']) . '%)' ?></td>
						<td class="<?php echo $alternate ?>">
							<?php 
							echo $row['unique'] . ' (' . round($row['percent_unique']) . '%)';
							if($row['uses']) { echo '<br/>(' . round($row['uses'], 1) . ' uses per user)'; }
							?>
						</td>
						<td class="<?php echo $alternate ?>"><?php echo $row['time'] ?></td>
						<?php 
							$i = 0;
							foreach($labels as $label) {
								$data = $row['columns'][$i];
								if($label == $data['label']) {
									printf('<td class="%s">%s (%s%%)</td>', $alternate, $data['count'], round($data['percent']));
									array_push($csv_row, $data['count']);
									$i++;
								}
								else { 
									printf('<td class="%s">0</td>', $alternate);
									array_push($csv_row, 0);
								}
							}
							fputcsv($csv, $csv_row);
						?>
					</tr>
				<?php } ?>
			</table>
			<p class="small"><em>Note: Traffic from within the NCCP offices is excluded from these figures</em></p>
			<p><a href="temp/<?php echo $results_csv_name ?>">Download CSV version of this data</a></p>
			<?php fclose($csv); ?>
			<?php } ?>
        </div>
    </div>
	<br class="clearing" />
	<!--
	<pre>
	<?php print_r($results) ?>
	</pre>
	-->
	
    </form>
    
<?php include("inc/footers.php"); ?>
