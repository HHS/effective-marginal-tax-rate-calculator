
<script type="text/javascript">

Validation.add('validate-owed', 'Vehicle cost must not be greater than vehicle value', function(v,e) {
	if(Number(v) > 0 && e.id == 'vehicle1_owed' && Number(v) >= Number($F('vehicle1_value'))) {
		return false
	}
	else if(Number(v) > 0 && e.id == 'vehicle2_owed' && Number(v) >= Number($F('vehicle2_value'))) {
		return false;
	}
	return true;
});


Validation.add('Validate_1', 'Please select which child(ren) receive child support payments or go back to Step 2 and answer "No" to the question about child support.', function(v,e)  {
if($F('child1support')) {

	return true;
	
	}
	return false;
});


Validation.add('Validate_12', 'Please select which child(ren) receive child support payments or go back to Step 2 and answer "No" to the question about child support.', function(v,e)  {
if($F('child1support') || $F('child2support')) {

	return true;
	
	}
	return false;
});

Validation.add('testfunction', 'testtext', function(x) {
  
if (x.checked){
//	alert("enough arguments")
	  return false;
  } 
  return true;
}); 

Validation.add('validate-hometime', 'Value must be less than 120', function(v,e) {
	if(Number(v) > 120  ) {
		return false
	}
	else if (Number(v) < 0 ) {
		return false;
	}
	return true;
});
Validation.add('validate-hometime2', 'Value must be less than 48', function(v,e) {
	if(Number(v) > 48 ) {
		return false
	}
	else if (Number(v) < 0 ) {
		return false;00
	}
	return true;
});


Validation.add('validate-wage','Please enter a wage greater than $0 or go back to Step 2 and remove this job from your selections.', function(v,e) {
	if(Number(v) <= 0) {
		return false
	}
	return true;
});

Validation.add('validate-workhours','Please list a work schedule greater than 0 hours per week or go back to Step 2 and remove this job from your selections.', function(v,e) {
	if(Number(v) <= 0) {
		return false
	}
	return true;
});

Validation.add('validate-nonnegative','Value cannot be blank or less than 0', function(v,e) {
	if(Number(v) < 0 || v == "") {
		return false
	}
	return true;
});

Validation.add('validate-week','There are only 168 hours in a week. Please enter an amount less than that.', function(v,e) {
	if(Number(v) > 168) {
		return false
	}
	return true;
});

Validation.add('validate-fpuc-1','If this amount includes the $300 weekly FPUC payment, it must be larger than $300. If this amount does not include the FPUC payment, please select "No" in response to the question about FPUC below.', function(v,e) {
	if(Number($F('parent1_ui_recd_initial')) >= 0 && Number($F('parent1_ui_recd_initial')) < 300 && Number($F('fpuc'))==1) {
		return false
	}
	return true;
});

Validation.add('validate-fpuc-2','You said in the previous step that someone in your household receives Unemployment Compensation. Please enter the amount that at least one person in your household receives from Unemployment Compensation or go back one step and uncheck that box. Since you have selected "Yes" in response to the question below about the $300 weekly FPUC payment, any amount you enter for Unemployment Compensation must be larger than $300. If you are not including the FPUC payment, please select "No" in response to the question about FPUC below.', function(v,e) {
	if(Number($F('fpuc'))==1 && Number($F('parent1_ui_recd_initial')) < 300 && Number($F('parent2_ui_recd_initial')) < 300) {
		return false
	}
	return true;
});

Validation.add('validate-fpuc-3','You said in the previous step that someone in your household receives Unemployment Compensation. Please enter the amount that at least one person in your household receives from Unemployment Compensation or go back one step and uncheck that box. Since you have selected "Yes" in response to the question below about the $300 weekly FPUC payment, any amount you enter for Unemployment Compensation must be larger than $300. If you are not including the FPUC payment, please select "No" in response to the question about FPUC below.', function(v,e) {
	if(Number($F('fpuc'))==1 && Number($F('parent1_ui_recd_initial')) < 300 && Number($F('parent2_ui_recd_initial')) < 300 && Number($F('parent3_ui_recd_initial')) < 300)  {
		return false
	}
	return true;
});

Validation.add('validate-fpuc-4','You said in the previous step that someone in your household receives Unemployment Compensation. Please enter the amount that at least one person in your household receives from Unemployment Compensation or go back one step and uncheck that box. Since you have selected "Yes" in response to the question below about the $300 weekly FPUC payment, any amount you enter for Unemployment Compensation must be larger than $300. If you are not including the FPUC payment, please select "No" in response to the question about FPUC below.', function(v,e) {
	if(Number($F('fpuc'))==1 && Number($F('parent1_ui_recd_initial')) < 300 && Number($F('parent2_ui_recd_initial')) < 300 && Number($F('parent3_ui_recd_initial')) < 300 && Number($F('parent4_ui_recd_initial')) < 300)  {
		return false
	}
	return true;
});

Validation.add('validate-ui-1','You said in the previous step that you receive Unemployment Compensation. Please enter the amount that you receive from Unemployment Compensation or go back one step and uncheck that box.', function(v,e) {
	if(Number($F('parent1_ui_recd_initial')) == 0 && Number($F('fpuc'))==-1) {
		return false
	}
	return true;
});


Validation.add('validate-ui-2', 'You said in the previous step that your household receives Unemployment Compensation. Please enter an amount that at least least one adult receives from Unemployment Compensation or go back one step and uncheck that box.', function(v,e)  {
	if(Number($F('parent1_ui_recd_initial')) + Number($F('parent2_ui_recd_initial')) == 0 && Number($F('fpuc'))==-1) {
		return false
	}
	return true;
});																																			

Validation.add('validate-ui-3', 'You said in the previous step that your household receives Unemployment Compensation. Please enter an amount that at least least one adult receives from Unemployment Compensation or go back one step and uncheck that box.', function(v,e)  {
	if(Number($F('parent1_ui_recd_initial')) + Number($F('parent2_ui_recd_initial')) + Number($F('parent3_ui_recd_initial'))== 0 && Number($F('fpuc'))==-1) {
		return false
	}
	return true;
});

Validation.add('validate-ui-4', 'You said in the previous step that your household receives Unemployment Compensation. Please enter an amount that at least least one adult receives from Unemployment Compensation or go back one step and uncheck that box.', function(v,e)  {
	if(Number($F('parent1_ui_recd_initial')) + Number($F('parent2_ui_recd_initial')) + Number($F('parent3_ui_recd_initial')) + Number($F('parent4_ui_recd_initial'))== 0 && Number($F('fpuc'))==-1) {
		return false
	}
	return true;
});

Validation.add('validate-wage-parent2-trad', 'If entering a work schedule for a second wage-earner, enter an hourly wage greater than $0', function(v,e) {
	if(Number(v) <= 0 && ($F('parent2_max_work') == 'H' || $F('parent2_max_work') == 'F')) {
		return false
	}
	return true;
});

Validation.add('validate-wage-parent2-nontrad', 'If entering a work schedule for a second wage-earner, enter an hourly wage greater than $0', function(v,e) {
	if(Number(v) <= 0 && Number($F('parent2_max_work_override_amt')) != 0) {
		return false;
	}
	return true;
});

// end AK edit //

</script>

<br/>
<br/>
<p class="stepfourhead">Note: If you are self-employed, enter your expected earnings. This calculator treats self-employment income like wage income.
<?php //echo $notes_table->add_note('page7_intro'); //echo $help_table->add_help('page7_intro'); ?></p>

<table <?php if($_SESSION['year'] >= 2017) echo 'width="100%"' ?>>
 
<colgroup>
	<col style="vertical-align:top;"/>
	<col style="vertical-align:top;"/>
</colgroup>

<?php if ($_SESSION['parent1_jobs_initial'] + $_SESSION['parent2_jobs_initial'] + $_SESSION['parent3_jobs_initial'] + $_SESSION['parent4_jobs_initial']>= 1) { ?>	 			
	<b>Currently, on average and before taxes ... </b>
<?php } ?>

<?php if ($_SESSION['parent1_jobs_initial'] >= 1) { ?>	 			
	<?php for($i=1; $i<=$_SESSION['parent1_jobs_initial']; $i++) { ?>
	<tr>
	<td>
		<label for="<?php echo 'parent1_wage_'.$i ?>">I make </label>
		$<input class="validate-number validate-wage" type="text" name="<?php echo 'parent1_wage_'.$i ?>" id="<?php echo 'parent1_wage_'.$i ?>" size="5" maxlength="5" value="<?php echo $_SESSION['parent1_wage_'.$i ]?>">
		  <label for="<?php echo 'parent1_payscale'.$i ?>"> per </label> 
			<select name="<?php echo 'parent1_payscale'.$i ?>" id="payscale1"> 
				  <option value="hour" <?php if($_SESSION['parent1_payscale'.$i] == 'hour') echo 'selected' ?>>hour</option> 
				  <!--<option value="week" <?php #if($_SESSION['parent1_payscale'.$i] == 'day') echo 'selected' ?>>day</option> Commenting this out for now. Seems rare for someone to get reliably paid a certain amount per day. If asking this, we'd also have to ask how many days per week they work, which we're trying not to do.-->
				  <option value="week" <?php if($_SESSION['parent1_payscale'.$i] == 'week') echo 'selected' ?>>week</option> 
				  <option value="biweekly" <?php if($_SESSION['parent1_payscale'.$i] == 'biweekly') echo 'selected' ?>>every two weeks</option> 
				  <option value="month" <?php if($_SESSION['parent1_payscale'.$i] == 'month') echo 'selected' ?>>month</option> 
				  <option value="year" <?php if($_SESSION['parent1_payscale'.$i] == 'year') echo 'selected' ?>>year</option> 
			</select>
		
		<label for="<?php echo 'parent1_workweek'.$i ?>">and work </label> 
		<input class="validate-number validate-workhours validate-week" type="text" name="<?php echo 'parent1_workweek'.$i ?>" id="<?php echo 'parent1_workweek'.$i ?>" size="5" maxlength="5" value="<?php echo $_SESSION['parent1_workweek'.$i] ?>">	hours per week<?php 
		if ($_SESSION['parent1_jobs_initial'] == 1) { ?>.<?php 
		} else { ?>
			at my 
			<?php if ($i == 1) { ?>
				first job.
			<?php } else if ($i == 2) { ?>
				second job.
			<?php } else if ($i == 3) { ?>
				third job.
			<?php } else if ($i == 4) { ?>
				fourth job.
			<?php } ?> 
		<?php } ?> 
	</td>
	</tr>
	<?php } ?>
<?php } ?>
			


<?php if ($_SESSION['family_structure'] >=2) { ?>
	<?php for($j=2; $j<=$_SESSION['family_structure']; $j++) { ?>
		<?php if ($_SESSION['parent'.$j.'_jobs_initial'] >= 1) { ?>	 			
			<?php for($i=1; $i<=$_SESSION['parent'.$j.'_jobs_initial']; $i++) { ?>
			<tr>
			<td>
				<label for="<?php echo 'parent'.$j.'_wage_'.$i ?>">
				<?php if ($j == 2) { ?>
					Adult 2
				<?php } else if ($j == 3) { ?>
					Adult 3
				<?php } else if ($j == 4) { ?>
					Adult 4
				<?php } ?> 

				(age <?php echo $_SESSION['parent'.$j.'_age'] ?>) makes </label>
				$<input class="validate-number validate-wage" type="text" name="<?php echo 'parent'.$j.'_wage_'.$i ?>" id="<?php echo 'parent'.$j.'_wage_'.$i ?>" size="5" maxlength="5" value="<?php echo $_SESSION['parent'.$j.'_wage_'.$i ]?>">
				  <label for="<?php echo 'parent'.$j.'_payscale'.$i ?>"> per </label> 
					<select name="<?php echo 'parent'.$j.'_payscale'.$i ?>" id="payscale1"> 
						  <option value="hour" <?php if($_SESSION['parent'.$j.'_payscale'.$i] == 'hour') echo 'selected' ?>>hour</option> 
						  <!--<option value="week" <?php #if($_SESSION['parent'.$j.'_payscale'.$i] == 'day') echo 'selected' ?>>day</option> See note above.-->
						  <option value="week" <?php if($_SESSION['parent'.$j.'_payscale'.$i] == 'week') echo 'selected' ?>>week</option> 
						  <option value="biweekly" <?php if($_SESSION['parent'.$j.'_payscale'.$i] == 'biweekly') echo 'selected' ?>>every two weeks</option> 
						  <option value="month" <?php if($_SESSION['parent'.$j.'_payscale'.$i] == 'month') echo 'selected' ?>>month</option> 
						  <option value="year" <?php if($_SESSION['parent'.$j.'_payscale'.$i] == 'year') echo 'selected' ?>>year</option> 
					</select>
				
				<label for="<?php echo 'parent'.$j.'_workweek'.$i ?>">and works </label> 
				<input class="validate-number validate-workhours validate-week" type="text" name="<?php echo 'parent'.$j.'_workweek'.$i ?>" id="<?php echo 'parent'.$j.'_workweek'.$i ?>" size="5" maxlength="5" value="<?php if (is_null ($_SESSION['parent'.$j.'_workweek'.$i])) {echo 0;} else {echo $_SESSION['parent'.$j.'_workweek'.$i];} ?>">	hours per week<?php 
					if ($_SESSION['parent'.$j.'_jobs_initial'] == 1) { ?>.<?php 
					} else { ?>
					at their 
					<?php if ($i == 1) { ?>
						first job.
					<?php } else if ($i == 2) { ?>
						second job.
					<?php } else if ($i == 3) { ?>
						third job.
					<?php } else if ($i == 4) { ?>
						fourth job.
					<?php } ?> 
				<?php } ?> 
			</td>
			</tr>
			<?php } ?>
		<?php } ?>
	<?php } ?>
<?php } ?>

<?php
#Simplifying the future_scenario_parent# variables into one aggregate variable, that can be used to guide some questions (like the below one) about future scenarios and child care. The idea here is partially to limit the questions that pertain to increased work schedules to just situations where users have entered they will be working more.
$_SESSION['future_scenario'] = 'none';
for($i=1; $i<=$_SESSION['family_structure']; $i++) { 
	if ($_SESSION['future_scenario_parent'.$i] == 'both' || $_SESSION['future_scenario_parent'.$i] == 'new') {
		$_SESSION['future_scenario'] = 'both';
	}
	if ($_SESSION['future_scenario_parent'.$i] == 'hours' && $_SESSION['future_scenario'] != 'both') {
		$_SESSION['future_scenario'] = 'hours';
	}
}

for($i=1; $i<=$_SESSION['family_structure']; $i++) { 
	if ($_SESSION['future_scenario_parent'.$i] == 'wages') {
		if ($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') {
			$_SESSION['future_scenario'] = 'both';
		} else {
			$_SESSION['future_scenario'] = 'wages';	
		}
	}
}

#Also calculating parent#_future_jobs based on previous entries, as well as calculating whether the household is completely unemployed, both in the current and future situation:

$_SESSION['total_futureandcurrent_jobs'] = 0;
for($j=1; $j<=$_SESSION['family_structure']; $j++) {
	$_SESSION['parent'.$j.'_future_jobs'] = $_SESSION['parent'.$j.'_jobs_initial'];
	if ($_SESSION['future_scenario_parent'.$j] == 'new') {
		$_SESSION['parent'.$j.'_future_jobs'] += 1;
	}
	$_SESSION['total_futureandcurrent_jobs'] += $_SESSION['parent'.$j.'_jobs_initial'] + $_SESSION['parent'.$j.'_future_jobs'];
	
} ?>
<tr>
<td>
<?php if ($_SESSION['future_scenario'] != 'none' && $_SESSION['total_futureandcurrent_jobs'] > 0) { ?>
<b>I want to find out how my household's financial situation might change if...  </b>
<?php } else if ($_SESSION['total_futureandcurrent_jobs'] == 0){ ?>
<b>You said in Step 2 that no one in your household is employed and you do not plan to change that. If that is not correct, please go back to Step 2 and enter the correct answers there.</b>
<?php } ?>
</td>
</tr>	
<?php if ($_SESSION['parent1_future_jobs'] >= 1) { # Used to have  "&& ($_SESSION['future_scenario_parent1'] == 'wages' || $_SESSION['future_scenario_parent1'] == 'hours' || $_SESSION['future_scenario_parent1'] == 'both')" added here, but I think with the change to add the "new job" scenario, that's not necessary.?>	 			
	<?php for($i=1; $i<=$_SESSION['parent1_future_jobs']; $i++) { ?>
		<?php if ($_SESSION['future_scenario_parent1'] == 'wages' || $_SESSION['future_scenario_parent1'] == 'both' || $_SESSION['future_scenario_parent1'] == 'hours' || ($_SESSION['future_scenario_parent1'] == 'new' && $i == $_SESSION['parent1_jobs_initial'] + 1)) { ?>		
			<tr>
			<td>
			I start to  
			<?php if ($_SESSION['future_scenario_parent1'] == 'wages' || $_SESSION['future_scenario_parent1'] == 'both'  || ($_SESSION['future_scenario_parent1'] == 'new' && $i == $_SESSION['parent1_jobs_initial'] + 1)) { ?>
				<label for="<?php echo 'parent1_future_wage_'.$i ?>">make </label>
				$<input class="validate-number validate-wage" type="text" name="<?php echo 'parent1_future_wage_'.$i ?>" id="<?php echo 'parent1_future_wage_'.$i ?>" size="5" maxlength="5" value="<?php echo $_SESSION['parent1_future_wage_'.$i ]?>">
				  <label for="<?php echo 'parent1_future_payscale'.$i ?>"> per </label> 
					<select name="<?php echo 'parent1_future_payscale'.$i ?>" id="payscale1"> 
						  <option value="hour" <?php if($_SESSION['parent1_future_payscale'.$i] == 'hour') echo 'selected' ?>>hour</option> 
						  <!--<option value="week" <?php #if($_SESSION['parent1_future_payscale'.$i] == 'day') echo 'selected' ?>>day</option> See note above-->
						  <option value="week" <?php if($_SESSION['parent1_future_payscale'.$i] == 'week') echo 'selected' ?>>week</option> 
						  <option value="biweekly" <?php if($_SESSION['parent1_future_payscale'.$i] == 'biweekly') echo 'selected' ?>>every two weeks</option> 
						  <option value="month" <?php if($_SESSION['parent1_future_payscale'.$i] == 'month') echo 'selected' ?>>month</option> 
						  <option value="year" <?php if($_SESSION['parent1_future_payscale'.$i] == 'year') echo 'selected' ?>>year</option> 
					</select>
			<?php } else {
				$_SESSION['parent1_future_wage_'.$i ] = $_SESSION['parent1_wage_'.$i];
				$_SESSION['parent1_future_payscale'.$i] = $_SESSION['parent1_payscale'.$i];
			} ?>
			<?php if ($_SESSION['future_scenario_parent1'] == 'both'  || ($_SESSION['future_scenario_parent1'] == 'new' && $i == $_SESSION['parent1_jobs_initial'] + 1)) { ?>
				and
			<?php } ?>	
			<?php if ($_SESSION['future_scenario_parent1'] == 'hours' || $_SESSION['future_scenario_parent1'] == 'both' || ($_SESSION['future_scenario_parent1'] == 'new' && $i == $_SESSION['parent1_jobs_initial'] + 1)) { ?>
				<label for="<?php echo 'parent1_future_workweek'.$i ?>">I work </label> 
				<input class="validate-number validate-workhours validate-week" type="text" name="<?php echo 'parent1_future_workweek'.$i ?>" id="<?php echo 'parent1_future_workweek'.$i ?>" size="5" maxlength="5" value="<?php if (is_null ($_SESSION['parent1_future_workweek'.$i])) {echo 0;} else {echo $_SESSION['parent1_future_workweek'.$i];} ?>">	hours per week<?php 
			} else {
				$_SESSION['parent1_future_workweek'.$i] = $_SESSION['parent1_workweek'.$i];
			} 
			?><?php if ($_SESSION['parent1_future_jobs'] == 1) { ?>.<?php 
			} else { ?>
				at my 
				<?php if ($i == 1) { ?>
					first job.
				<?php } else if ($i == 2) { ?>
					second job.
				<?php } else if ($i == 3) { ?>
					third job.
				<?php } else if ($i == 4) { ?>
					fourth job.
				<?php } ?> 
			<?php } ?> 
			</td>
			</tr>
		<?php } ?>
	<?php } ?>
<?php } ?>

<?php if ($_SESSION['family_structure'] >=2) { ?>
	<?php for($j=2; $j<=$_SESSION['family_structure']; $j++) { ?>
		<?php if ($_SESSION['parent'.$j.'_future_jobs'] >= 1 && $_SESSION['future_scenario_parent'.$j] != 'none') { # Also used to have "&& ($_SESSION['future_scenario_parent'.$j] == 'wages' || $_SESSION['future_scenario_parent'.$j] == 'hours' || $_SESSION['future_scenario_parent'.$j] == 'both'))" as additional conditions here. ?>	 						
			<?php for($i=1; $i<=$_SESSION['parent'.$j.'_future_jobs']; $i++) { ?>
			<tr>
			<td>
				<?php if ($j == 2) { ?>
					Adult 2
				<?php } else if ($j == 3) { ?>
					Adult 3
				<?php } else if ($j == 4) { ?>
					Adult 4
				<?php } ?> 

				(age <?php echo $_SESSION['parent'.$j.'_age'] ?>) will  
				<?php if ($_SESSION['future_scenario_parent'.$j] == 'wages' || $_SESSION['future_scenario_parent'.$j] == 'both' || ($_SESSION['future_scenario_parent'.$j] == 'new' && $i <= $_SESSION['parent'.$j.'_jobs_initial'] + 1)) { ?>
						<label for="<?php echo 'parent'.$j.'_future_wage_'.$i ?>">
						make </label>
						$<input class="validate-number validate-wage" type="text" name="<?php echo 'parent'.$j.'_future_wage_'.$i ?>" id="<?php echo 'parent'.$j.'_future_wage_'.$i ?>" size="5" maxlength="5" value="<?php echo $_SESSION['parent'.$j.'_future_wage_'.$i ]?>">
						  <label for="<?php echo 'parent'.$j.'_future_payscale'.$i ?>"> per </label> 
							<select name="<?php echo 'parent'.$j.'_future_payscale'.$i ?>" id="payscale1"> 
								  <option value="hour" <?php if($_SESSION['parent'.$j.'_future_payscale'.$i] == 'hour') echo 'selected' ?>>hour</option> 
								  <!--<option value="week" <?php #if($_SESSION['parent'.$j.'_future_payscale'.$i] == 'day') echo 'selected' ?>>day</option> See note above-->
								  <option value="week" <?php if($_SESSION['parent'.$j.'_future_payscale'.$i] == 'week') echo 'selected' ?>>week</option> 
								  <option value="biweekly" <?php if($_SESSION['parent'.$j.'_future_payscale'.$i] == 'biweekly') echo 'selected' ?>>every two weeks</option> 
								  <option value="month" <?php if($_SESSION['parent'.$j.'_future_payscale'.$i] == 'month') echo 'selected' ?>>month</option> 
								  <option value="year" <?php if($_SESSION['parent'.$j.'_future_payscale'.$i] == 'year') echo 'selected' ?>>year</option> 
							</select>
				<?php } else {
					$_SESSION['parent1_future_wage_'.$i ] = $_SESSION['parent1_wage_'.$i];
					$_SESSION['parent1_future_payscale'.$i] = $_SESSION['parent1_payscale'.$i];
				} ?>
				<?php if ($_SESSION['future_scenario_parent'.$j] == 'both' || ($_SESSION['future_scenario_parent'.$j] == 'new' && $i == $_SESSION['parent'.$j.'_jobs_initial'] + 1)) { ?>
					and
				<?php } ?>	
				<?php if ($_SESSION['future_scenario_parent'.$j] == 'hours' || $_SESSION['future_scenario_parent'.$j] == 'both' || ($_SESSION['future_scenario_parent'.$j] == 'new' && $i == $_SESSION['parent'.$j.'_jobs_initial'] + 1)) { ?>
					<label for="<?php echo 'parent'.$j.'_future_workweek'.$i ?>"> work </label> 
					<input class="validate-number validate-workhours validate-week" type="text" name="<?php echo 'parent'.$j.'_future_workweek'.$i ?>" id="<?php echo 'parent'.$j.'_future_workweek'.$i ?>" size="5" maxlength="5" value="<?php if (is_null ($_SESSION['parent'.$j.'_future_workweek'.$i])) {echo 0;} else {echo $_SESSION['parent'.$j.'_future_workweek'.$i];}  ?>"> hours per week<?php } else {$_SESSION['parent'.$j.'_future_workweek'.$i] = $_SESSION['parent'.$j.'_workweek'.$i];
				} if ($_SESSION['parent'.$j.'_future_jobs'] == 1) { ?>.<?php 
				} else { ?>
					at their 
					<?php if ($i == 1) { ?>
						first job.
					<?php } else if ($i == 2) { ?>
						second job.
					<?php } else if ($i == 3) { ?>
						third job.
					<?php } else if ($i == 4) { ?>
						fourth job.
					<?php } ?> 
				<?php } ?> 
			<?php } ?>
			</td>
			</tr>
		<?php } ?>
	<?php } ?>
<?php } ?>

<tr>
<td>
</td>		 
</tr>
<?php #Seeing if any questions about work schedules are even necessary:
$workschedulequestions = 0;
if ($_SESSION['tanf'] == 1 || ($_SESSION['fsp'] == 1 && $_SESSION['child_number_mtrc'] == 0)) {
	$workschedulequestions = 1;
}
for($i=1; $i<=$_SESSION['family_structure']; $i++) {
	if ($_SESSION['parent'.$i.'_jobs_initial'] >= 1 || $_SESSION['parent'.$i.'_future_jobs'] >= 1 ||$_SESSION['parent'.$i.'_student_status'] != 'nonstudent') {
		$workschedulequestions = 1;
	}
}		
?>
<?php if ($workschedulequestions == 1) { ?>
	<tr><td><b>Work schedules:</b></td></tr>
<?php } ?>

<?php for($i=1; $i<=$_SESSION['family_structure']; $i++) { ?>
	<tr>
	<td>
	<?php if ($_SESSION['parent'.$i.'_jobs_initial'] >= 1 || $_SESSION['parent'.$i.'_future_jobs'] >= 1 || $_SESSION['tanf'] == 1 || $_SESSION['parent'.$i.'_student_status'] != 'nonstudent' || $_SESSION['children_under13'] > 0 || ($_SESSION['fsp'] == 1 && $_SESSION['child_number_mtrc'] == 0)) { ?>
		<?php if ($i == 1) { ?>
			I currently travel 
		<?php } if ($i == 2) { ?>
			Adult 2 (age <?php echo $_SESSION['parent2_age'] ?>) currently travels 
		<?php } else if ($i == 3) { ?>
			Adult 3 (age <?php echo $_SESSION['parent3_age'] ?>) currently travels 
		<?php } else if ($i == 4) { ?>
			Adult 4 (age <?php echo $_SESSION['parent4_age'] ?>) currently travels
		<?php } ?>
		<label for="<?php echo 'parent'.$i.'_transdays_w' ?>"></label><input class="validate-number  validate-nonnegative" type="text" name="<?php echo 'parent'.$i.'_transdays_w'?>" id="<?php echo 'parent'.$i.'_transdays_w' ?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['parent'.$i.'_transdays_w'])) {echo 0;} else {echo $_SESSION['parent'.$i.'_transdays_w'];} ?>">
		time(s) per week to and from work<?php if ($_SESSION['children_under13'] > 0) { ?>, or child care<?php } ?><?php if ($_SESSION['parent'.$i.'_student_status'] != 'nonstudent') { ?>, or classes<?php } ?><?php if ($_SESSION['state'] != 'PA' && ($_SESSION['tanf'] == 1 || ($_SESSION['fsp'] == 1 && $_SESSION['exclude_covid_policies_ending_1221'] == 1))) { ?>, and spend <label for="<?php echo 'parent'.$i.'_traininghours' ?>"></label><input class="validate-number validate-nonnegative" type="text" name="<?php echo 'parent'.$i.'_traininghours'?>" id="<?php echo 'parent'.$i.'_traininghours' ?>" size="2" maxlength="2" value="<?php  if (is_null ($_SESSION['parent'.$i.'_traininghours'])) {echo 0;} else {echo $_SESSION['parent'.$i.'_traininghours'];}?>"> hours per week in training or other activities that qualify for <?php echo $_SESSION['tanf_short_name']?><?php if ($_SESSION['fsp'] == 1 && $_SESSION['exclude_covid_policies_ending_1221'] == 1) { ?> or SNAP<?php } ?> work requirements<?php } ?>. With the change <?php if ($i == 1) { ?>I am<?php } else { ?>we are<?php } ?>  considering, 
		<?php if ($i == 1) { ?>
			I will travel 
		<?php } if ($i >= 2) { ?>
			they will travel 
		<?php } ?>
		<label for="<?php echo 'parent'.$i.'_future_transdays_w' ?>"></label><input class="validate-number validate-nonnegative" type="text" name="<?php echo 'parent'.$i.'_future_transdays_w'?>" id="<?php echo 'parent'.$i.'_future_transdays_w' ?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['parent'.$i.'_future_transdays_w'])) {echo 0;} else {echo $_SESSION['parent'.$i.'_future_transdays_w'];}?>">
		time(s) per week to and from work<?php if ($_SESSION['children_under13'] > 0) { ?>, or child care<?php } ?><?php if ($_SESSION['parent'.$i.'_student_status'] != 'nonstudent') { ?>, or classes<?php } ?><?php if ($_SESSION['state'] != 'PA' && ($_SESSION['tanf'] == 1 || ($_SESSION['fsp'] == 1 && $_SESSION['exclude_covid_policies_ending_1221'] == 1))) { ?>, and will spend <label for="<?php echo 'parent'.$i.'_future_traininghours' ?>"></label><input class="validate-number  validate-nonnegative" type="text" name="<?php echo 'parent'.$i.'_future_traininghours'?>" id="<?php echo 'parent'.$i.'_future_traininghours' ?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['parent'.$i.'_future_traininghours'])) {echo 0;} else {echo $_SESSION['parent'.$i.'_future_traininghours'];} ?>"> hours per week on activities that qualify for <?php echo $_SESSION['tanf_short_name']?> <?php if ($_SESSION['fsp'] == 1 && $_SESSION['exclude_covid_policies_ending_1221'] == 1) { ?> or SNAP<?php } ?> work requirements<?php } ?>.
	<?php } else {
		$_SESSION['parent'.$i.'_transdays_w'] = 0;
		$_SESSION['parent'.$i.'_traininghours'] = 0;
		$_SESSION['parent'.$i.'_future_transdays_w'] = 0;
		$_SESSION['parent'.$i.'_future_traininghours'] = 0;
	}
	?>
	</td>		 
	</tr>
<?php } ?>

<?php if ($_SESSION['year'] >= 2020 && $_SESSION['user_prototype'] == 1 && (($_SESSION['state'] != 'NH' && $_SESSION['state'] != 'PA' && $_SESSION['state'] != 'ME')|| $_SESSION['demo'] == 1) && (($_SESSION['child1_age'] > -1 && $_SESSION['child1_age'] < 13) || ($_SESSION['child2_age'] > -1 && $_SESSION['child2_age'] < 13) || ($_SESSION['child3_age'] > -1 && $_SESSION['child3_age'] < 13) || ($_SESSION['child4_age'] > -1 && $_SESSION['child4_age'] < 13) || ($_SESSION['child5_age'] > -1 && $_SESSION['child5_age'] < 13)) && ($_SESSION['ccdf'] || $_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both')) { ?>
	<tr>
	<td><label for="nontraditionalwork">Do you or will you need child care during weekends, early mornings (before 7am) or nights (after 6pm)? </label></td>
	<!-- Note: We will adjust these times based on the definition of nontraditional hours for providing child care in each jurisdiction.-->
	<td> 
	  <select name="nontraditionalwork" id="nontraditionalwork">
		<option value="0" <?php if($_SESSION['nontraditionalwork'] == 0) echo 'selected' ?>>No</option>
		<option value="1" <?php if($_SESSION['nontraditionalwork'] == 1) echo 'selected' ?>>Yes</option>
	  </select>
	</td>
	</tr>
<?php } else {
	$_SESSION['nontraditionalwork'] = 0;	
} ?>

		
<!--		<tr><td><b>Assets and debt:</b></td></tr>  <!-- 6/15: added-->
	

<?php if($_SESSION['hlth'] && ($_SESSION['disability_parent1'] == 1 || $_SESSION['disability_parent2'] == 1 ||$_SESSION['disability_parent3'] == 1 ||$_SESSION['disability_parent4'] == 1))  { ?> <!-- Asset tests may still be necessary if a family is on Medicaid and eligible for additional Medicaid coverage through Medically Needy programs or Medicaid-like programs supporting people with disabilities. We will address what asset questions need to be adressed as we identify whether programs in the selected jurisdictions require them.-->
	<tr><td><b>Savings:</b></td></tr>
	<tr>
	  <td><label for="savings">Amount of family savings (in checking or savings account)</label><?php //echo $notes_table->add_note('page3_savings'); echo $help_table->add_help('page3_savings'); ?></td>
	  <td>
		$<input class="validate-number  validate-nonnegative" <?php echo $ct_disabled ?> type="text" name="savings" id="savings" size="4" maxlength="4" value="<?php if (is_null ($_SESSION['savings'])) {echo 0;} else {echo $_SESSION['savings'];} ?>">
	  </td>
	</tr>
<?php } else { 
	$_SESSION['savings'] = 0;
} ?>

<tr>
<td>
</td>		 
</tr>
<tr><td><b>Other sources of income:</b></td></tr>  <!-- 6/15: added-->
<?php if ($_SESSION['year'] >= 2020  && $_SESSION['user_prototype'] == 1 && $_SESSION['ui'] == 1) { ?> 
	<tr> 
	<td><!--On step 3, you said that your household receives unemployment payments. Please  enter the weekly benefit amount for unemployment each adult in the household receives, if any.-->
	</td>
	</tr>    
	  <?php for($i=1; $i<=$_SESSION['family_structure']; $i++) { ?>
			<tr><td>
			<label for="<?php echo 'parent'.$i.'_ui_recd_initial' ?>">
			<?php if ($i == 1) { ?>
				I currently receive 
			<?php } else if ($i == 2) { ?>
				Adult 2 (age <?php echo $_SESSION['parent2_age'] ?>) currently receives
			<?php } else if ($i == 3) { ?>
				Adult 3 (age <?php echo $_SESSION['parent3_age'] ?>) currently receives
			<?php } else if ($i == 4) { ?>
				Adult 4 (age <?php echo $_SESSION['parent4_age'] ?>) currently receives
			<?php } ?>
			</label>
			$<input class="validate-number validate-nonnegative <?php echo 'validate-fpuc-'.$_SESSION['family_structure']?> <?php echo 'validate-ui-'.$_SESSION['family_structure']?>" type="text" name="<?php echo 'parent'.$i.'_ui_recd_initial'?>" id="<?php echo 'parent'.$i.'_ui_recd_initial'?>" size="4" maxlength="4" value="<?php if (is_null ($_SESSION['parent'.$i.'_ui_recd_initial'])) {echo 0;} else {echo $_SESSION['parent'.$i.'_ui_recd_initial'];} ?>"> per week in <?php echo $_SESSION['ui_medium_name']?>. 

			<label for="<?php echo 'parent'.$i.'_unemployed_weeks' ?>">
			<?php if ($i == 1) { ?>
				I
			<?php } else { ?>
				They
			<?php } ?>
			</label>
			have received <?php echo$_SESSION['ui_medium_name']?> for <input class="validate-number  validate-nonnegative" type="text" name="<?php echo 'parent'.$i.'_unemployed_weeks'?>" id="<?php echo 'parent'.$i.'_unemployed_weeks'?>" size="4" maxlength="4" value="<?php if (is_null ($_SESSION['parent'.$i.'_unemployed_weeks'])) {echo 0;} else {echo $_SESSION['parent'.$i.'_unemployed_weeks'];} ?>"> weeks.
			</td>
			</tr>
	<?php } ?>
	<tr> 
	<td><label for="fpuc"><?php if ($_SESSION['family_structure'] == 1) {echo 'Does this amount ';} else {echo 'Do these amounts ';}?> include an additional $300 per week in Federal Pandemic Unemployment Compensation (FPUC)? </label></td>
	<td><select name="fpuc" id="fpuc">
		<option value="1" <?php if($_SESSION['fpuc'] == 1) echo 'selected' ?>>Yes</option>
		<option value="-1" <?php if($_SESSION['fpuc'] == -1) echo 'selected' ?>>No</option>
		</select>
	</td>
	</tr>    
<?php } ?>

<!-- Taking out this attempt to calibrate TANF cash assistance.
<?php #if ($_SESSION['year'] >= 2020  && $_SESSION['user_prototype'] == 1 && $_SESSION['tanf'] == 1) { ?>
	<tr> 
	  <td><label for="tanf_initial_amt">You marked on the previous page that your household currently receives TANF cash assistance. To help the calculator better estimate your current and future financial situations, can you mark how much TANF cash assistance your household currently receives?</label></td>
	  <td><nobr>$<input class="validate-number" type="text" name="tanf_initial_amt" id="tanf_initial_amt" size="4" maxlength="4" value="<?php #echo $_SESSION['tanf_initial_amt'] ?>"> per month
		</td>
	</tr>    
<?php #} ?>
-->

<?php if ($_SESSION['year'] >= 2020  && $_SESSION['user_prototype'] == 1 && $_SESSION['tanf'] == 1 && $_SESSION['state'] != 'PA' && $_SESSION['state'] != 'ME') { #PA and Maine have requested to remove the consideration of work requirements as grounds for issuing sanctions among TANF recipients or making individuals ineligible for TANF recipt.?>
	<tr> 
	<td><label for="tanfwork">On step 3, you said that your household receives <?php echo $_SESSION['tanf_short_name']?>. Is your household required to meet work requirements to keep on receiving <?php echo $_SESSION['tanf_short_name']?>?  </label></td>
	<td><select name="tanfwork" id="tanfwork">
		<option value="0" <?php if($_SESSION['tanfwork'] == 0) echo 'selected' ?>>No</option>
		<option value="1" <?php if($_SESSION['tanfwork'] == 1) echo 'selected' ?>>Yes</option>
		</select>
	</td>
	</tr>
<?php } else { 
	$_SESSION['tanfwork'] = 0;
} ?>
<?php if ($_SESSION['year'] >= 2020  && $_SESSION['user_prototype'] == 1 && $_SESSION['tanf'] == 1 && $_SESSION['state'] != 'PA' && $_SESSION['state'] != 'DC') { ?>
	<tr> 
	  <td><label for="tanf_months_received">Also, could you mark how many months your household has received <?php echo $_SESSION['tanf_short_name']?>, so that the calculator can determine if you may be close to the 60-month lifetime limit for the number of months you can receive <?php echo $_SESSION['tanf_short_name']?><?php if ($_SESSION['state'] == 'ME') { ?>, and so that the calculator can determine additional benefits if you recently started receiving <?php echo $_SESSION['tanf_short_name']?> <?php } ?>?</label></td>
	  <td><nobr><input class="validate-number validate-nonnegative" type="text" name="tanf_months_received" id="tanf_months_received" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['tanf_months_received'])) {echo 0;} else {echo $_SESSION['tanf_months_received'];} ?>"> month(s)
		</td>
	</tr>    
<?php } else { 
	$_SESSION['tanf_months_received'] = 0;
} ?>


<?php if ($_SESSION['year'] >= 2020  && $_SESSION['user_prototype'] == 1 && $_SESSION['ssi'] == 1 && 1==0) { #adding in nonsensical 1=0 condition because we're moving away from having the calculator calibrate SSI based on user inputs. If the calculator is spitting out a different amount than the person receives, that person can check with their case manager to see why there's a difference; this will also help states identify where there are inaccuracies in our calculations.?>
	<tr> 
	  <td><label for="ssi_initial_amt">You marked on the previous page that your household currently receives SSI cash assistance. To help the calculator better estimate your current and future financial situations, can you mark how much SSI cash assistance your household currently receives?</label></td>
	  <td><nobr>$<input class="validate-number" type="text" name="ssi_initial_amt" id="ssi_initial_amt" size="4" maxlength="4" value="<?php echo $_SESSION['ssi_initial_amt'] ?>"> per month
		</td>
	</tr>    
<?php } ?>
		   
<?php if($_SESSION['child_number_mtrc'] > 0) { ?>
	<tr> 
	  <td><label for="child_support_paid_m"><?php if ($_SESSION['tanf'] == 1) { ?>Do you expect your household would regularly receive formal, court-ordered child support if you stopped receiving <?php echo $_SESSION['tanf_short_name']?>? <?php } else { ?>Does your household regularly receive formal, court-ordered child support?<?php } ?> If so, enter that amount here.</label><?php //echo $notes_table->add_note('page3_child_support'); echo $help_table->add_help('page3_child_support'); ?></td>
	  <td><nobr>$<input class="validate-number validate-nonnegative" type="text" name="child_support_paid_m" id="child_support_paid_m" size="6" maxlength="6" value="<?php if (is_null ($_SESSION['child_support_paid_m'])) {echo 0;} else {echo $_SESSION['child_support_paid_m'];} ?>"> per month
		
		</td>
	</tr>    
<?php } ?>

<tr> 
  <td><label for="alimony_paid_m">Does your household regularly receive formal, court-ordered alimony? If so enter that amount here.</label><?php //echo $notes_table->add_note('page3_child_support'); echo $help_table->add_help('page3_child_support'); ?></td>
  <td><nobr>$<input class="validate-number validate-nonnegative" type="text" name="alimony_paid_m" id="alimony_paid_m" size="6" maxlength="6" value="<?php if (is_null ($_SESSION['alimony_paid_m'])) {echo 0;} else {echo $_SESSION['alimony_paid_m'];} ?>"> per month
	</td>
</tr>    

<tr> 
<?php if($_SESSION['state'] == 'PA') { ?>
  <td><label for="current_gift_income_m">How much gift income does your household receive monthly, if any?</label><?php //echo $notes_table->add_note('page3_child_support'); echo $help_table->add_help('page3_child_support'); ?></td>
  <td><nobr>$<input class="validate-number validate-nonnegative" type="text" name="current_gift_income_m" id="current_gift_income_m" size="6" maxlength="6" value="<?php if (is_null ($_SESSION['current_gift_income_m'])) {echo 0;} else {echo $_SESSION['current_gift_income_m'];} ?>"> per month
	</td>
</tr>    
<tr> 
  <td><label for="future_gift_income_m">How much gift income will your household receive monthly, if any, in the situation you are using this calculator to anticipate?</label><?php //echo $notes_table->add_note('page3_child_support'); echo $help_table->add_help('page3_child_support'); ?></td>
  <td><nobr>$<input class="validate-number validate-nonnegative" type="text" name="future_gift_income_m" id="future_gift_income_m" size="6" maxlength="6" value="<?php if (is_null ($_SESSION['future_gift_income_m'])) {echo 0;} else {echo $_SESSION['future_gift_income_m'];} ?>"> per month
	</td>
<?php } else {
	$_SESSION['current_gift_income_m'] = 0;
	$_SESSION['future_gift_income_m'] = 0;
} ?>

</tr>    

<tr> 
  <td><label for="other_income_m">Does your household regularly receive any other income not already listed on this page? If so, enter that amount here.</label><?php //echo $notes_table->add_note('page3_child_support'); echo $help_table->add_help('page3_child_support'); ?></td>
  <td><nobr>$<input class="validate-number validate-nonnegative" type="text" name="other_income_m" id="other_income_m" size="6" maxlength="6" value="<?php if (is_null ($_SESSION['other_income_m'])) {echo 0;} else {echo $_SESSION['other_income_m'];} ?>"> per month
	</td>
</tr>    

</table>
<br/>
