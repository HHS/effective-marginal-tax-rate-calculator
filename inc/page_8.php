<?php
#We first create a perl file that collects the $_SESSION inputs. This is necessary at least for testing purposes, because we are running Perl through the command line, and the text space needed to list all the inputs exceeds at least the maximum space for Windows command lines. The command line use of Perl can still work fine on Macs and Linux servers with more allowable space. But for these codes to work locally on PC's, this fix is neeeded.
 
$myfile = fopen("temp/".$_SESSION['id']."_inputs.pl", "w")  or  die (error_get_last());
$line = "#---Temporary file of inputs because depending on how many details users enter, the total number of characters may exceed the 8,191 total character limit of the Windows command line. If downloading this file as a text file from one of the testing pages, copy the text and save this file as ".$_SESSION['id']."_inputs.pl instead of a .txt file, in your relevant temp directory, in order to run this output from the command line. --- \n";
fwrite($myfile, $line);
$line = "sub long_inputs { \n";
fwrite($myfile, $line);
foreach ($_SESSION as $name => $value) {
	$line = '$in->{'."'$name'}=\"$value\"".';'."\n";
	fwrite($myfile, $line);
}
$line = '$in->{'."'test1'}='1'".';'."\n";
fwrite($myfile, $line);
$line = '$in->{'."'test2'}='2'".';'."\n";
fwrite($myfile, $line);
$line = "} \n";
fwrite($myfile, $line);
$line = "1; \n";
fwrite($myfile, $line);
fclose($myfile);
?>
<?php if ($_SESSION['test'] == 1) { 
	copy("temp/".$_SESSION['id']."_inputs.pl", "temp/".$_SESSION['id']."_inputs.txt")  or  die (error_get_last());
	#For testing purposes, this sets up a way to easily access the .pl file of inputs.
	#$path_info = pathinfo($_SERVER['PHP_SELF']); #For debugging purposes or other applications, we could use the full path, but I don't think that's necessary.
	#$script_path = $path_info['dirname']; #Same note as above -- this doesn't seem necessary but keeping it in hre if it comes in handy.?>
	<ul class="downloads noprint">
		<li class="xls"><a href="<?php #echo $script_path #same note as above -- the full path name doesn't appear necessary but perhaps this code snippet will come in handy.?>temp/<?php echo $_SESSION['id'] ?>_inputs.txt" target="_blank">Download .txt version of .pl input file</a></li>
	</ul>
<?php } ?>

<?php

#The run_frs line also prints the PHP arguments to the command line and, when testing is turned on, page_8.php.
$result = $simulator->run_frs();

$h = fopen("temp/".$_SESSION['id']."_private.csv", "r") or  die (error_get_last());
$row =0;
while (($data = fgetcsv($h, 2000, ",")) !== FALSE) {
	$num = count($data);
	#echo "<p> $num fields in line $row: <br /></p>\n";
	if ($row == 0) {
		for ($c=0; $c < $num; $c++) {
			$output_names[$c] = $data[$c];
		}
	} else {
		for ($c=0; $c < $num; $c++) {
			${$output_names[$c].'_'.$row} = $data[$c];
		}
	}
	$row++;
}

#We now delete the file if the testing variable is turned off, to preserve confidentiality. At this point, all the data from this .csv file has been grabbed.
if ($_SESSION['test'] == 0) {
	unlink ("temp/".$_SESSION['id']."_private.csv");
	unlink ("temp/".$_SESSION['id']."_public.csv");
	unlink ("temp/".$_SESSION['id'].".csv");
	unlink ("temp/".$_SESSION['id']."_inputs.pl");
}

# Will need to pull from csv files at C:\xampp\htdocs\msgtech-calculatorapp-d765e3cf739b\family-resource-sim-mtrc\tools\frs_stage\temp here.
foreach($result as $line) {
	if(preg_match('/^(.*)\|(.*)$/',$line,$matches)) {
		$_SESSION[$matches[1]] = $matches[2];
	}
}
echo "<!-- RESULTS: \n";
print_r($result);
echo "-->\n";
?>

<!-- The PHP will pull data from the CSV file that the Perl will pass on outputs to, including up to four rows of data -- the estimate of the current situation, the future situation, the future situation impacted by CCDF enrollment, and the future situation impacted by Head Start enrollment.-->
<!-- While the final version of this will run separate scenarios to determine whether Head Start, Pre-K, and CCDF would reduce overall costs, for this initial prototype we are including those options when children are appropriate ages and when child care is expected to be needed.-->
<?php
$headstart_or_earlyheadstart_scenario = 0;
$prek_scenario = 0;
$ccdf_scenario = 0;
for($i=1; $i<=5; $i++) {
	for($j=1; $j<=7; $j++) {
		if($_SESSION['day'.$j.'_future_hours_child'.$i] > 0) {
			$ccdf_scenario = 1;
			if ($_SESSION['child'.$i.'_age'] < 5) {
					$headstart_or_earlyheadstart_scenario = 1;
			}
			if ($_SESSION['child'.$i.'_age'] == 3 || $_SESSION['child'.$i.'_age'] == 4) {
					$prek_scenario = 1;
			}
		}
	}
}
?>

<?php 

$current_benefits = 0;
if ($tanf_recd_1 > 0) {
	$current_benefits = 1;
}
if ($hlth_cov_parent_1 == 'Medicaid' || $hlth_cov_parent_1 == 'Medicaid and private' || $hlth_cov_parent_1 == 'Medicaid, CHIP, and private') {
	$current_benefits = 1;
}
if ($hlth_cov_child_all_1 == 'Medicaid' || $hlth_cov_child_all_1 == 'Medicaid and CHIP') {
	$current_benefits = 1;
}
if ($hlth_cov_child_all_1 == 'CHIP' || $hlth_cov_child_all_1 == 'Medicaid and CHIP') {
	$current_benefits = 1;
}
if ($housing_recd_1 > 0) {
	$current_benefits = 1;
}
if ($ssi_recd_1 > 0) {
	$current_benefits = 1;
}
if ($ui_recd_1 > 0) {
	$current_benefits = 1;
}

if ($fsp_recd_1 > 0) {
	$current_benefits = 1;
}
if ($child_foodcost_red_total_1 > 0) {
	$current_benefits = 1;
}
if ($child_care_recd_1 > 0) {
	$current_benefits = 1;
}

if ($liheap_recd_1 > 0) {
	$current_benefits = 1;
}

if ($wic_recd_1 > 0) {
	$current_benefits = 1;
}

if ($lifeline_recd_1 > 0 ) {
	$current_benefits = 1;
}

if ($federal_tax_credits_1 > 0 ) {
	$current_benefits = 1;
}

if ($premium_credit_recd_1 > 0 ) {
	$current_benefits = 1;
}


$future_benefits = 0;
if ($tanf_recd_2 > 0) {
	$future_benefits = 1;
}
if ($hlth_cov_parent_2 == 'Medicaid' || $hlth_cov_parent_2 == 'Medicaid and private' || $hlth_cov_parent_2 == 'Medicaid, CHIP, and private') {
	$future_benefits = 1;
}
if ($hlth_cov_child_all_2 == 'Medicaid' || $hlth_cov_child_all_2 == 'Medicaid and CHIP') {
	$future_benefits = 1;
}
if ($hlth_cov_child_all_2 == 'CHIP' || $hlth_cov_child_all_2 == 'Medicaid and CHIP') {
	$future_benefits = 1;
}
if ($housing_recd_2 > 0) {
	$future_benefits = 1;
}
if ($ssi_recd_2 > 0) {
	$future_benefits = 1;
}
if ($ui_recd_2 > 0) {
	$future_benefits = 1;
}

if ($fsp_recd_2 > 0) {
	$future_benefits = 1;
}
if ($child_foodcost_red_total_2 > 0) {
	$future_benefits = 1;
}
if ($child_care_recd_2 > 0) {
	$future_benefits = 1;
}

if ($liheap_recd_2 > 0) {
	$future_benefits = 1;
}

if ($wic_recd_2 > 0) {
	$future_benefits = 1;
}

if ($lifeline_recd_2 > 0 ) {
	$future_benefits = 1;
}
if ($federal_tax_credits_2 > 0 ) {
	$future_benefits = 1;
}

if ($premium_credit_recd_2 > 0 ) {
	$future_benefits = 1;
}


if ($earnings_2 == $earnings_1) {
	$marginal_tax_rate = 0;
} else {
	$marginal_tax_rate = 1-(($net_resources_2 - $net_resources_1)/($earnings_2 - $earnings_1));
}

$child_care_alt_option_3 = $_SESSION['ccdf_short_name'];
$child_care_alt_option_4 = $_SESSION['prek_short_name'];
$child_care_alt_option_5 = 'Head Start';
$child_care_alt_option_6 = 'Early Head Start';

for($i=3; $i<=6; $i++) {
	${'child_care_alternate_'.$i} = 0;
	if (${'net_resources_'.$i} - $net_resources_2 > 0) {
		${'child_care_alternate_'.$i} = 1;
	}
}

?>	
<br/>
<br/>
<p>
The below estimates are based on the information you entered in Steps 1 to 7. The first section shows your estimated benefits. The "Current Situation" column shows your current benefit amounts. The "New Situation" column shows the new benefit amounts you will get if you make the changes you described in Step 2. <br><br>
The second section shows your estimated finances. The "Current Situation" column shows your current yearly income, cash assistance, and tax credits (money coming in). It also shows your current yearly expenses (money going out). The column "New Situation" column shows your new income and expenses after the changes you described in Step 2.
<br/>	
<br/>
<!--You can change the information you had entered that the calculator used to make these estimates by using the arrows above or clicking one of the steps above. Once you are finished looking at these results or printing them out, please close your browser windows so that the information you entered is removed. 
<br/>	
<br/>	-->
<input type="button" value="Click here to print this page." onClick="window.print()"><br><br>
If you want to enter different information, use the Back button or click on the numbered steps above.<br><br>
When you are done looking at these results or printing them out, please close the browser window.
</p>
<?php if ($current_benefits + $future_benefits == 0) {?>
	<b>Benefits: none</b><br/>
	<br/>
<?php } else {?>

	<tr><td><b>Benefits:</b></td></tr>
	<br/>
	<table class="indented">
		<tr valign="top">
			<td valign="bottom" align="right" class="copy"> 
					<b>Yearly Benefit Amounts</b>
			</td>
			<td valign="bottom" align="right" class="copy"> 
					<b>Current Situation</b>					 
			</td>
			<td valign="bottom" align="right" class="copy"> 
					<b>New Situation <br/> </b> 					 
			</td>
		</tr>
		<?php if ($fsp_recd_1 + $fsp_recd_2 > 0 || $_SESSION['fsp'] == 1) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['fsp_medium_name'] ?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($fsp_recd_1) ?> 					 
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($fsp_recd_2) ?> 					 
				</td>
			</tr>
		<?php } ?>
		<?php if ($tanf_recd_1 + $tanf_recd_2 > 0 || $_SESSION['tanf'] == 1) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['tanf_medium_name']?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($tanf_recd_1) ?> 					 
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($tanf_recd_2) ?> 					 
				</td>
			</tr>
		<?php } ?>
		<?php if ($hlth_cov_parent_1 == 'Medicaid' || $hlth_cov_parent_1 == 'Medicaid and private' || $hlth_cov_parent_2 == 'Medicaid' || $hlth_cov_parent_2 == 'Medicaid and private' || $_SESSION['hlth'] == 1) {?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['medicaid_medium_name'] ?> (adult(s)):
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($hlth_cov_parent_1 == 'Medicaid' || $hlth_cov_parent_1 == 'Medicaid and private') {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($hlth_cov_parent_2 == 'Medicaid' || $hlth_cov_parent_2 == 'Medicaid and private') {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
			</tr>
		<?php if ($hlth_cov_parent_1 == 'CHIP' || $hlth_cov_parent_1 == 'Medicaid and CHIP' || $hlth_cov_parent_1 == 'Medicaid, CHIP, and private' || $hlth_cov_parent_2 == 'CHIP' || $hlth_cov_parent_2 == 'Medicaid and CHIP' || $hlth_cov_parent_2 == 'Medicaid, CHIP, and private') {?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['chip_medium_name'] ?> (adult(s)):
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($hlth_cov_parent_1 == 'CHIP' || $hlth_cov_parent_1 == 'Medicaid and CHIP' || $hlth_cov_parent_1 == 'Medicaid, CHIP, and private' ) {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($hlth_cov_parent_2 == 'CHIP' || $hlth_cov_parent_2 == 'Medicaid and CHIP' || $hlth_cov_parent_2 == 'Medicaid, CHIP, and private') {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
			</tr>
		<?php } ?>
		<?php } ?>
		<?php if ($hlth_cov_child_all_1 == 'Medicaid' || $hlth_cov_child_all_2 == 'Medicaid' || $hlth_cov_child_all_1 == 'Medicaid and CHIP' || $hlth_cov_child_all_2 == 'Medicaid and CHIP' || ($_SESSION['hlth'] == 1 && $_SESSION['child_number_mtrc'] > 0)) {?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['medicaid_medium_name'] ?> (child):
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($hlth_cov_child_all_1 == 'Medicaid' || $hlth_cov_child_all_1 == 'Medicaid and CHIP') {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($hlth_cov_child_all_2 == 'Medicaid' || $hlth_cov_child_all_2 == 'Medicaid and CHIP') {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
			</tr>
		<?php } ?>
		<?php if ($hlth_cov_child_all_1 == 'CHIP' || $hlth_cov_child_all_2 == 'CHIP' || $hlth_cov_child_all_1 == 'Medicaid and CHIP' || $hlth_cov_child_all_2 == 'Medicaid and CHIP') {?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['chip_medium_name'] ?> (child):
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($hlth_cov_child_all_1 == 'CHIP' || $hlth_cov_child_all_1 == 'Medicaid and CHIP') {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($hlth_cov_child_all_2 == 'CHIP' || $hlth_cov_child_all_2 == 'Medicaid and CHIP') {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
			</tr>
		<?php } ?>
		<?php if ($premium_credit_recd_1 + $premium_credit_recd_2 > 0) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					Financial Help for Health Insurance (Premium Tax Credits):
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($premium_credit_recd_1 > 0) {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($premium_credit_recd_2 > 0) {echo 'receiving';} else {echo 'ineligible';} ?> 					 
				</td>
			</tr>
		<?php } ?>
		<?php if ($housing_recd_1 + $housing_recd_2 > 0 || $_SESSION['sec8'] == 1) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['sec8_medium_name'] ?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($housing_recd_1) ?> 					 
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($housing_recd_2) ?> 					 
				</td>
			</tr>
		<?php } ?>
		<?php if ($ssi_recd_1 + $ssi_recd_2 > 0 || $_SESSION['ssi'] == 1) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['ssi_medium_name'] ?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($ssi_recd_1) ?> 					 
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($ssi_recd_2) ?> 					 
				</td>
			</tr>
		<?php } ?>
		<?php if ($ui_recd_1  + $ui_recd_2 > 0 || $_SESSION['ui'] == 1) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['ui_medium_name'] ?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($ui_recd_1) ?> 					 
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($ui_recd_2) ?> 					 
				</td>
			</tr>
		<?php } ?>
		<?php if ($child_foodcost_red_total_1 + $child_foodcost_red_total_2 > 0 || $_SESSION['nsbp'] + $_SESSION['frpl'] + $_SESSION['fsmp'] > 0) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					Free or Reduced Price Meals:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($child_foodcost_red_total_1 > 0) {echo 'receiving';} else {echo 'ineligible';} ?> 					 
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php  if ($child_foodcost_red_total_2 > 0) {echo 'receiving';} else {echo 'ineligible';}  ?> 					 
				</td>
			</tr>
		<?php } ?>
		<?php if ($child_care_recd_1 + $child_care_recd_2 > 0 || $_SESSION['ccdf'] == 1) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['ccdf_medium_name'] ?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($child_care_recd_1 > 0) {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($child_care_recd_2 > 0) {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
			</tr>
		<?php } ?>
		<?php if ($liheap_recd_1 + $liheap_recd_2 > 0 || $_SESSION['liheap'] == 1) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['liheap_medium_name'] ?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($liheap_recd_1) ?> 					 
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($liheap_recd_2) ?> 					 
				</td>
			</tr>
		<?php } ?>
		<?php if ($wic_recd_1 + $wic_recd_2 > 0 || $_SESSION['wic'] == 1) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['wic_medium_name'] ?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($wic_recd_1 > 0) {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($wic_recd_2 > 0) {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
			</tr>
		<?php } ?>
		<?php if ($lifeline_recd_1+ $lifeline_recd_2 > 0 || $_SESSION['lifeline'] == 1) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['lifeline_medium_name'] ?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($lifeline_recd_1 > 0) {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
				<td valign="bottom" align="right" class="copy"> 
						<?php if ($lifeline_recd_2 > 0) {echo 'receiving';} else {echo 'ineligible';} ?>
				</td>
			</tr>
		<?php } ?>
		<?php if ($federal_tax_credits_1+ $federal_tax_credits_2 > 0) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					Federal Tax Credits (EITC, CTC, and CDCTC):
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($federal_tax_credits_1) ?> 					 
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($federal_tax_credits_2) ?> 					 
				</td>
			</tr>
		<?php } ?>
		<?php if ($state_tax_credits_1 + $state_tax_credits_2 > 0) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
					<?php echo $_SESSION['state_tax_credits_name'] ?>:
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($state_tax_credits_1) ?> 					 
				</td>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format($state_tax_credits_2) ?> 					 
				</td>
			</tr>
		<?php } ?>
	</table>
	<?php } ?>
Note: In some situations, the table may not include all benefits you currently get. This is because the calculator does not include all rules for every type of situation. If you are concerned that a change in income will change your benefits, please discuss this with your case manager.
</p>
<tr><td><b>Current and New Finances:</b></td></tr>
<br/>
<table class="indented">
	<tr valign="top">
		<td class="copy" align="right" >				
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<b>Current Situation</b>					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<b>New Situation <br/> </b> 					 
		</td>
	<?php for ($i=3; $i <= 6; $i++) {
		if (${'child_care_alternate_'.$i} == 1) { ?>
			<td valign="bottom" align="right" class="copy"> 
				<b>New Situation,<br> with <?php echo ${'child_care_alt_option_'.$i} ?>*</b>			</td>
		<?php } ?>
	<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<b>Yearly Income, Cash Assistance, <br>
			and Tax Credits (money coming in)</b>
		</td>
		<td valign="bottom" align="right" class="copy"> 
								 
		</td>
		<td valign="bottom" align="right" class="copy"> 
									 
		</td>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<b>Earnings/Wage Income:</b>
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<b>$<?php echo number_format($earnings_1) ?></b> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<b>$<?php echo number_format($earnings_2) ?></b> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						<b>$<?php echo number_format(${'earnings_'.$i}) ?> </b> 				 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<?php if ($_SESSION['state'] == 'PA') { ?>
		<tr valign="top">
			<td class="copy" align="right" >
				Gift Income:
			</td>
			<td valign="bottom" align="right" class="copy"> 
					$<?php echo number_format($gift_income_1) ?> 					 
			</td>
			<td valign="bottom" align="right" class="copy"> 
					$<?php echo number_format($gift_income_2) ?> 					 
			</td>
			<?php for ($i=3; $i <= 6; $i++) {
				if (${'child_care_alternate_'.$i} == 1) { ?>
					<td valign="bottom" align="right" class="copy"> 
							$<?php echo number_format(${'gift_income_'.$i}) ?> 					 
					</td>
				<?php } ?>
			<?php } ?>
		</tr>
	<?php } ?>
	<tr valign="top">
		<td class="copy" align="right" >
			Other Income: <!-- For expedency's sake, we are using the "interest" variable to capture other income. We will work on adjusting this naming convention as we finalize the code. When we adjust these, we'll search "interest" elswhere on this page to make similar replacements.-->
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($other_income_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo  number_format($other_income_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'other_income_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<?php echo $_SESSION['tanf_medium_name']?>:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($tanf_recd_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo  number_format($tanf_recd_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'tanf_recd_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<?php echo $_SESSION['ssi_medium_name']?>:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo  number_format($ssi_recd_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($ssi_recd_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'ssi_recd_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<?php echo $_SESSION['ui_medium_name']?>:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo  number_format($ui_recd_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($ui_recd_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'ui_recd_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Child Support Received:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($child_support_recd_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($child_support_recd_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'child_support_recd_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>

	<!--Removing SNAP/Food Stamps to make them part of food expenses:
	<tr valign="top">
		<td class="copy" align="right" >
			SNAP (Food Stamps):
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php # echo number_format($fsp_recd_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php # echo number_format($fsp_recd_2) ?> 					 
		</td>
		<?php # for ($i=3; $i <= 3; $i++) {
			#if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php # echo number_format(${'fsp_recd_'.$i}) ?> 					 
				</td>
			<?php # } ?>
		<?php # } ?>
	</tr>
	-->
	<tr valign="top">
		<td class="copy" align="right" >
			Federal Tax Credits (EITC, CTC, and CDCTC):
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($federal_tax_credits_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($federal_tax_credits_2)?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'federal_tax_credits_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<?php echo $_SESSION['state_tax_credits_name'] ?>:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($state_tax_credits_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($state_tax_credits_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'state_tax_credits_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<i>Total Income:</i>
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<i>$<?php echo number_format($income_1) ?></i> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<i>$<?php echo number_format($income_2) ?></i> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						<i>$<?php echo number_format(${'income_'.$i}) ?></i>  					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr>
		<td>
		</td>
	</tr>
	<tr>
		<td>
		</td>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<b>Yearly Expenses (money going out)</b>
		</td>
		<td valign="bottom" align="right" class="copy"> 
		</td>
		<td valign="bottom" align="right" class="copy"> 
		</td>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Health Expenses:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($health_expenses_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($health_expenses_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'health_expenses_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Child Care Expenses:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($child_care_expenses_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($child_care_expenses_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'child_care_expenses_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Rent, Mortgage, and/or Utilities:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($rent_paid_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($rent_paid_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'rent_paid_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Transportation Expenses:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($trans_expenses_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($trans_expenses_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'trans_expenses_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Food Expenses:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($food_expenses_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($food_expenses_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'food_expenses_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Phone Expenses:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($phone_expenses_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($phone_expenses_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'phone_expenses_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Other Necessities:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($other_expenses_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($other_expenses_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'other_expenses_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Other Regular Payments:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($other_regular_payments_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($other_regular_payments_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'other_regular_payments_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Payroll Taxes:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($payroll_tax_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($payroll_tax_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'payroll_tax_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			Income Tax Before Credits:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($tax_before_credits_1) ?> 					 
		<td valign="bottom" align="right" class="copy"> 
				$<?php echo number_format($tax_before_credits_2) ?> 					 
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						$<?php echo number_format(${'tax_before_credits_'.$i}) ?> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<!--Moving debt payments into "other regular payments" calculations. 
	<tr valign="top">
		<td class="copy" align="right" >
			Debt Payments:
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php #echo number_format($debt_payment_1) ?> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				$<?php #echo number_format($debt_payment_2)?> 					 
		</td>
	-->
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<i> Total Expenses: </i>
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<i>$<?php echo number_format($expenses_1) ?></i> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<i>$<?php echo number_format($expenses_2) ?></i>
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						<i>$<?php echo number_format(${'expenses_'.$i}) ?></i> 					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
	<tr>
		<td>
		</td>
	</tr>
	<tr>
		<td>
		</td>
	</tr>
	<tr valign="top">
		<td class="copy" align="right" >
			<b> What's Left (money coming  <br/>
			 in minus money going out): </b>
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<b>$<?php echo number_format($net_resources_1) ?></b> 					 
		</td>
		<td valign="bottom" align="right" class="copy"> 
				<b>$<?php echo number_format($net_resources_2) ?></b>
		</td>
		<?php for ($i=3; $i <= 6; $i++) {
			if (${'child_care_alternate_'.$i} == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						<b>$<?php echo number_format(${'net_resources_'.$i}) ?></b>					 
				</td>
			<?php } ?>
		<?php } ?>
	</tr>
</table>
<br>
In your current situation, the calculator estimates that after one year, you will have about $<?php echo number_format($net_resources_1)?> left over. This is the difference between your money coming in (income, tax credits, and cash assistance) and your money going out (expenses). <?php if ($net_resources_1 < 0) {?>Please see the below explanation for what it means that this number has a minus sign (-) before it. <?php } ?><br><br>If you make the changes you entered in steps 2 and 4, <?php if ($net_resources_1 == $net_resources_2) { ?>your new situation would be about the same as before. <?php } else { ?>the calculator estimates that after one year, you will have about $<?php echo number_format($net_resources_2) ?> left over. <?php if ($net_resources_2 < 0) {?>Please see the below explanation for what it means that this number has a minus sign (-) before it. <?php }} ?>
<br/>
<br/>
<?php if ($earnings_1 != $earnings_2 || $other_income_1 != $other_income_2 || $gift_income_1 != $gift_income_2) { ?>
<h2>What This Means:</h2>

	This means that, for every additional $100 you earn (up to the amount you entered for your new earnings), the difference between your money coming in and money going out will  
	<?php if ($marginal_tax_rate <=1) { ?>
		increase by about $<?php echo number_format ((1-$marginal_tax_rate) * 100,2)?>.
	<?php } else if ($marginal_tax_rate > 1) {  ?>
		decrease by about $<?php echo number_format (($marginal_tax_rate-1) * 100,2)?>.
	<?php } ?>
<?php } ?>
<?php if ($net_resources_1 < 0 || $net_resources_2 < 0) { ?>
	<p>
	</p>
	<br/>
	<b/>
	In your current situation, the difference between your household's money coming in and money going out 
	<?php if ($net_resources_1 < 0) { ?>
		is less than zero.
	<?php } ?>

	<?php if ($net_resources_2 < 0) { ?>
	In the scenario you are considering, the difference between your household's money coming in and money going out is 
	<?php if ($net_resources_2 < 0 && $net_resources_1 < 0) { ?>
		also 
	<?php } ?>
		less than zero.
	<?php } ?>
	</b>
	<br/>
	<br/>
	This means you may have to go into debt, use your savings, or find ways to spend less money. Learn about some ways to keep your benefits, deal with benefit loss, increase your income, or lower your expenses <a href="helpwithbenefitcliffs.php" target="_blank">here</a>.
	<br/>
	<p>
	</p>
<?php } else if ($marginal_tax_rate > 1) { ?>
	<br/>
	<br/>
	This estimate shows that you may be facing a decline in the difference between money coming in and money going out, possibly due to losing eligibity for at least one public benefit you may be receiving. To read about some ways to avoid benefit cliffs or increase your money coming in compared to your money going out, click <a href="helpwithbenefitcliffs.php" target="_blank">here</a>.		
	<br/>
	<p>
	</p>
<?php } else {?>
	<br/>
	<br/>
	According to the calculator's estimates, the change you are considering will not have a negative impact on your finances. The calculator also estimates that you are able to afford your estimated expenses, both in your current situation and in your potentially new situation. (The money you are bringing in is greater than the money going out in both situations.) If you would like to learn more about some ways to avoid benefit cliffs or increase your money coming in compared to your money going out, though, click <a href="helpwithbenefitcliffs.php" target="_blank">here</a>.		
	<br/>
	<p>
	</p>
<?php } ?>	
<?php if (1 == 0) { #Below is the text that appears in the helpwithbenefitcliffs.php page. If you prefer to keep the text in a separate page, you can delete this mathematically impossible condition. But if you prefer to have that advice or links to other pages for your state, you can make this contition always true (e..g 1==1) or remove this PHP logic and edit this in HTML.?>
	<b>While one way to increase your net resources is attaining higher earnings, here are some other ways that you might be able to use for avoiding benefit cliffs or increasing the money have coming in compared to the money your household is spending ("money going out"): </b><br/><br/>
	(1)	Ask your case manager about redetermination periods. If the next time you need to report your income is a long time from now, then these changes  may take a while to kick in.<br/>
	(2)	Talk to your case manager about any benefits that are reduced or no longer show in the  Possible Future Earnings with Change column. Your case manager might be able to tell you how some of these benefits phase out slowly over time.  <br/>
	(3)	If you are receiving housing assistance, ask your landlord or case manager about “flat rents”.<br/>
	(4)	If the calculator’ estimates for child care costs increase in the Possible Future Earnings with Change column, ask your case manager about child care subsidies, Head Start, Early Head Start, or affordable Pre-K or afterschool programs.<br/>
	(5)	If part of why you will lose a benefit is because of higher child care costs, and you receive or pay child support, you may be able to adjust your child support order to help cover those costs. <br/>
	(6)	Ask your employer(s) about flexible spending accounts or “FSAs” (like child care FSAs or medical FSAs). These can help reduce taxes and may help you or your children stay on Medicaid, or lower your healthcare payments if your insurance is from the healthcare marketplaces.<br/>
	(7)	Ask your employer(s) about “tax-advantaged retirement accounts.” Aside from saving money for when you’re older, these can also lower your taxes and may help reduce your health insurance costs. <br/>
	(8)	Some employers offer onsite child care or employee shuttles, which can help increase your net resources by reducing child care or transportation costs.<br/>
	<br/>
	<br/>
<?php } ?>
<?php if($_SESSION['ccdf'] == 0 && $ccdf_scenario == 1 && $child_care_alternate_3 == 1) { ?>
	<tr><td><i>*Also, have you considered applying for <?php echo $_SESSION['ccdf_medium_name']?> (<?php echo $_SESSION['ccdf_short_name']?>)? It looks like you might be eligible for this program. If you are, the column labeled "Earnings Scenario You Are Considering, with <?php echo $_SESSION['ccdf_short_name']?>" shows how the calculator estimates your finances will changes with the assistance you could receive to reduce child care expenses.</i></td></tr>
	<!--
	<br/>
	Total Expenses with CCDF: $<?php #echo number_format($expenses_3) ?>
	<br/>
	Total Resources (Income plus cash assistance plus SNAP benefits): $<?php echo  number_format($resources_3) ?>
	<br/>
	Net Resources with CCDF (Total Resources minus Total Expenses): $<?php echo  number_format($net_resources_3) ?>
	<br/>
	<br/>
	-->
	<p>
	</p>
<?php } ?>
<?php if($_SESSION['prek'] == 0 && $prek_scenario == 1 && $child_care_alternate_4 == 1) { ?>
	<tr><td><i>*Also, have you considered enrolling your children in a nearby <?php echo $_SESSION['prek_medium_name']?> program? It looks like you might be eligible for that program. If you are, the column labeled "Earnings Scenario You Are Considering, with <?php echo $_SESSION['prek_short_name']?>" shows how the calculator estimates your finances will changes with the assistance you could receive to reduce child care expenses from participating. </i></td></tr>
	<p>
	</p>
<?php } ?>
<?php if($_SESSION['headstart'] == 0 && $_SESSION['earlyheadstart'] == 0 && $headstart_or_earlyheadstart_scenario == 1 && ($child_care_alternate_5 == 1 || $child_care_alternate_6 == 1)) { ?>
	<tr><td><i>*Last, have you considered enrolling your children in a nearby Head Start or Early Head Start (EHS) program? It looks like you might be eligible for one or both of these programs. If you are, <?php if ($_SESSION['state'] == 'ME') { ?>and if you live in an area where a Head Start or Early Head Start provider is nearby,<?php } ?> the column labeled "Earnings Scenario You Are Considering, with Head Start" or "Earnings Scenario You Are Considering, with EHS" shows how the calculator estimates your finances will changes with the assistance you could receive to reduce child care expenses from participating. </i></td></tr>
	<!-- If you enroll your children in Head Start or Early Head Start, this is what the calculator estimates your  financial situation would be will be after the change you indicated instead:
	<br/>
	Total Expenses with Head Start / Early Head Start: $<?php #echo  number_format($expenses_4) ?>
	<br/>
	Total Resources (Income plus cash assistance plus SNAP benefits): $<?php #echo  number_format($resources_4) ?>
	<br/>
	Net Resources with Head Start / Early Head Start (Total Resources minus Total Expenses): $<?php #echo  number_format($net_resources_4) ?>
	<br/>
	<br/>
	-->
	<p>
	</p>
<?php } ?>
<h2>Want to Change Your Information?</h2>
<b>Below is the information you entered into the calculator. If you want to change any of this information, click on the step below -– for example, “1. Location & Family Size.” Make the change on that page. Then use the “next” arrows on each screen to move forward to the Results page (Step 8).</b>

