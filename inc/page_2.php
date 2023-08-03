<script>
 < ?php if($_SESSION['family_structure'] == "1"){ ?> disabled="disabled"< ?php }? >
  function disable(family_structure)
  {
      if($_SESSION['family_structure'] == 1)
           document.getElementById("parent2_age").disabled=true;
      else
          document.getElementById("parent2_age").disabled=false;
  }
</script>
 


<script type="text/javascript">
Validation.add('Validate_parent2_age', 'You must select the age of the second parent if modeling a two-parent family, and cannot include the age of the second parent unless also choosing to model a two-parent family.', function(v,e)  {
	if(Number(v) == 2 && Number($F('parent2_age') == 17	)) {

	return false
	}
	else if (Number(v) == 1 && Number($F('parent2_age') > 17	)) {
		return false; 
	}
	return true;
});

Validation.add('validate-your-age','Please enter your age.', function(v,e) {
	if(Number(v) == -1) {
		return false
	}
	return true;
});

Validation.add('validate-age','Pleae select an age, or go back one step and change how many people are in your household.', function(v,e) {
	if(Number(v) == -1) {
		return false
	}
	return true;
});

Validation.add('validate-married', 'If two people in your household are married, please select one person in the first drop-down menu and their spouse in the second drop-down menu. If no one is married, choose the blank option in the second drop-down menu. Currently, the calculator cannot estimate benefits if  someone in your household is married to someone living outside your household, or if your household includes more than one married couple.', function(v,e)  {
	if((Number(v) == 0  && Number($F('married1')) > 0) || (Number(v) == Number($F('married1')) && Number(v) > 0) || (Number(v) > 0  && Number($F('married1')) == 0)) {
		return false
	}
	return true;
});

Validation.add('validate-employed-parent1', 'If not currently employed, please select either "Start a new job" or "Not make any employment changes." The other options are for making changes to wages or hours of current job(s).', function(v,e)  {
	if((v == 'hours' || v == 'both' || v == 'wages') && Number($F('parent1_jobs_initial')) == 0) {
		return false
	}
	return true;
});

Validation.add('validate-employed-parent2', 'If not currently employed, please select either "Start a new job" or "Not make any employment changes." The other options are for making changes to wages or hours of current job(s).', function(v,e)  {
	if((v == 'hours' || v == 'both' || v == 'wages') && Number($F('parent2_jobs_initial')) == 0) {
		return false
	}
	return true;
});

Validation.add('validate-employed-parent3', 'If not currently employed, please select either "Start a new job" or "Not make any employment changes." The other options are for making changes to wages or hours of current job(s).', function(v,e)  {
	if((v == 'hours' || v == 'both' || v == 'wages') && Number($F('parent3_jobs_initial')) == 0) {
		return false
	}
	return true;
});

Validation.add('validate-employed-parent4', 'If not currently employed, please select either "Start a new job" or "Not make any employment changes." The other options are for making changes to wages or hours of current job(s).', function(v,e)  {
	if((v == 'hours' || v == 'both' || v == 'wages') && Number($F('parent4_jobs_initial')) == 0) {
		return false
	}
	return true;
});

Validation.add('validate-students-1', 'You entered in Step 1 that at least one of the adults in your household was a student. Please select a part-time or full-time student status for one of the adults or go back one step and adjust your entries.', function(v,e)  {
	return true;
});

Validation.add('validate-students-2', 'You entered in Step 1 that at least one of the adults in your household was a student. Please select a part-time or full-time student status for one of the adults or go back one step and adjust your entries.', function(v,e)  {
	if($F('parent1_student_status') == 'nonstudent' && $F('parent2_student_status') == 'nonstudent') {
		return false
	}
	return true;
});																																			Validation.add('validate-students-3', 'You entered in Step 1 that at least one of the adults in your household was a student. Please select a part-time or full-time student status for one of the adults or go back one step and adjust your entries.', function(v,e)  {
	if($F('parent1_student_status') == 'nonstudent' && $F('parent2_student_status') == 'nonstudent' && $F('parent3_student_status') == 'nonstudent') {
		return false
	}
	return true;
});	

Validation.add('validate-students-4', 'You entered in Step 1 that at least one of the adults in your household was a student. Please select a part-time or full-time student status for one of the adults or go back one step and adjust your entries.', function(v,e)  {
	if($F('parent1_student_status') == 'nonstudent' && $F('parent2_student_status') == 'nonstudent' && $F('parent3_student_status') == 'nonstudent' && $F('parent4_student_status') == 'nonstudent') {
		return false
	}
	return true;
});	

</script>
<!--
-->

<?php
	
	#Since we are allowing users to select child ages of "0" to represent children less than 1 year old, and also use 0 in the perl and other PHP codes to represent this age, but have not yet assigned a value to child ages before this point in the PHP sequence, we need to account for the assignment of null values as equivalent to the numerical value 0 in PHP. This is not needed for variables like parent ages, since the range of options we give to users does not include 0.
	for($i=1; $i<=5; $i++) {
		if(is_null($_SESSION['child'.$i.'_age'])) {
			$_SESSION['child'.$i.'_age'] = -1;
		}
	}
	for($i=1; $i<=4; $i++) {
		if(is_null($_SESSION['parent'.$i.'_age'])) {
			$_SESSION['parent'.$i.'_age'] = -1;
		}
	}
?>	

<br/>
<br/>
<br/>
<br/>
<table border="0" cellspacing="0" cellpadding="4">
	  
	  <tr>
	  <?php if($_SESSION['child_number_mtrc'] >= 1) { ?>
		<td>
		<?php if($_SESSION['child_number_mtrc'] == 1) { ?>
		<label for="child1_age">Age of child <?php if($_SESSION['year'] >= 2017) echo ''?> </label><?php //echo $notes_table->add_note('page2_child_age'); echo $help_table->add_help('page2_child_age'); ?></td>
		<?php } else { ?>
		<label for="child1_age">Age of first child <?php if($_SESSION['year'] >= 2017) echo ''?> </label><?php //echo $notes_table->add_note('page2_child_age'); echo $help_table->add_help('page2_child_age'); ?></td>
		<?php } ?>
		<td> 
		  <select name="child1_age" id="child1_age" class="validate-age">
			<option value="-1">--Select age--</option> <!-- test 120120-->
				<?php if($_SESSION['year'] >= 2017) { 
					for($i=0; $i<18; $i++) {
						if ($i == 0) {
							printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child1_age'] == $i ? 'selected' : ''), "0 or expected");
						} else {
							printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child1_age'] == $i ? 'selected' : ''), $i);
						}
					} 
				} ?>
		  </select>
		</td>
	  </tr>
	  <?php } ?>

	  <?php if($_SESSION['child_number_mtrc'] >= 2) { ?>
	  <tr> 
		<td><label for="child2_age">Age of second child <?php if($_SESSION['year'] >= 2017) echo ''?> </label></td>
		<td> 
		  <select name="child2_age" id="child2_age" class="validate-age">
			<option value="-1">--Select age--</option>
				<?php if($_SESSION['year'] >= 2017) { 
					for($i=0; $i<18; $i++) {
						if ($i == 0) {
							printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child2_age'] == $i ? 'selected' : ''), "0 or expected");
						} else {
							printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child2_age'] == $i ? 'selected' : ''), $i);
						}
					} 
				}  ?>
		  </select>
		</td>
	  </tr>
	  <?php } ?>

	  <?php if($_SESSION['child_number_mtrc'] >= 3) { ?>
	  <tr> 
		<td><label for="child3_age">Age of third child <?php if($_SESSION['year'] >= 2017) echo '' ?> </label></td>
		<td> 
		  <select name="child3_age" id="child3_age">
			<option value="-1">--Select age--</option>
				<?php if($_SESSION['year'] >= 2017) { 
					for($i=0; $i<18; $i++) {
						if ($i == 0) {
							printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child3_age'] == $i ? 'selected' : ''), "0 or expected");
						} else {
							printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child3_age'] == $i ? 'selected' : ''), $i);
						}
					} 
				} ?>
			</select>
		</td>
	  </tr>
	  <?php } ?>

	<?php if($_SESSION['year'] >= 2017) { ?>
	  <?php if($_SESSION['child_number_mtrc'] >= 4) { ?>

		<tr> 
		<td><label for="child4_age">Age of fourth child<?php if($_SESSION['year'] >= 2017) echo '' ?> </label></td>
		<td> 
		  <select name="child4_age" id="child4_age" class="validate-age">
			<option value="-1">--Select age--</option>
				<?php for($i=0; $i<18; $i++) {
					if ($i == 0) {
						printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child4_age'] == $i ? 'selected' : ''), "0 or expected");
					} else {
						printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child4_age'] == $i ? 'selected' : ''), $i);
					}
				} ?>
		  </select>
		</td>
		</tr>
	  <?php } ?>

	<?php if($_SESSION['child_number_mtrc'] >= 5) { ?>
		<tr> 
		<td><label for="child5_age">Age of fifth child<?php if($_SESSION['year'] >= 2017) echo '' ?> </label></td>
		<td> 
		  <select name="child5_age" id="child5_age" class="validate-age">
			<option value="-1">--Select age--</option>
				<?php for($i=0; $i<18; $i++) {
					if ($i == 0) {
						printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child5_age'] == $i ? 'selected' : ''), "0 or expected");
					} else {
						printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child5_age'] == $i ? 'selected' : ''), $i);
					}
				} ?>
		  </select>
		</td>
		</tr>
	  <?php } ?>

		<tr> 
		<td><label for="parent1_age">How old are you?</label></td>
		<td> 
		  <select name="parent1_age" id="parent1_age" class="validate-your-age">
		  <option value="-1">--Select age--</option>
				<?php for($i=18; $i<62; $i++) {
					printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['parent1_age'] == $i ? 'selected' : ''), $i);
				} ?>
		  </select>
		</td>
		</tr>
		<tr> 
	<?php if($_SESSION['family_structure'] >= 2) { ?>
		<td><label for="parent2_age">Age of Adult 2</label></td>
		<td>  
		  <select <?php echo $parent2_age ?>  name="parent2_age" id="parent2_age" class="validate-age" >
		  <option value="-1">--Select age--</option>
				<?php for($i=18; $i<62; $i++) { #5/15: Changed lower bound from 17 to 18.
					printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['parent2_age'] == $i ? 'selected' : ''), $i);
				} ?>
				
		  </select>
		</td>
	  <?php } ?>

	<?php if($_SESSION['family_structure'] >= 3) { ?>
		<tr> 
		<td><label for="parent3_age">Age of Adult 3</label></td>
		<td>  
		  <select <?php echo $parent3_age ?>  name="parent3_age" id="parent3_age" class="validate-age" >
		  <option value="-1">--Select age--</option>
				<?php for($i=18; $i<62; $i++) { 
					printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['parent3_age'] == $i ? 'selected' : ''), $i);
				} ?>
				
		  </select>
		</td>
	  <?php } ?>

	<?php if($_SESSION['family_structure'] >= 4) { ?>
		<tr> 
		<td><label for="parent4_age">Age of Adult 4</label></td>
		<td>  
		  <select <?php echo $parent4_age ?>  name="parent4_age" id="parent4_age" class="validate-age" >
		  <option value="-1">--Select age--</option>
				<?php for($i=18; $i<62; $i++) { 
					printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['parent4_age'] == $i ? 'selected' : ''), $i);
				} ?>
				
		  </select>
		</td>
		</tr>
	  <?php } ?>

		<?php if($_SESSION['family_structure'] == 1) {
			$_SESSION['married1'] = 0; 
			$_SESSION['married2'] = 0;
		} ?>
		<tr> 
		<?php if($_SESSION['family_structure'] == 2) { ?>
		  <td><label for="married1">Are you married to the other adult in your household?</label></td> <!-- In this case, we will assign married2 to 2 in Perl if married1 equals 1.-->
			<td> 
			  <select name="married1" id="married1">
				<option value="1" <?php if($_SESSION['married1'] == 1) echo 'selected' ?>>Yes</option>
				<option value="0" <?php if($_SESSION['married1'] == 0) echo 'selected' ?>>No</option>
			  </select>
			</td>
		<?php } ?>

		<?php if($_SESSION['family_structure'] > 2) { ?>
		  <td><label for="married1">Is anyone in your household  married to someone else in the household?</label></td>
			<td valign="bottom" align="left" class="copy"> 
			<label for="married1"></label> 			   
			<select name="married1" id="married1"> 
			  <option value="0" <?php if($_SESSION['married1'] == 0) echo 'selected' ?>>No, no one is</option> 
			  <option value="1" <?php if($_SESSION['married1'] == 1) echo 'selected' ?>>Yes, I</option> 
			  <option value="2" <?php if($_SESSION['married1'] == 2) echo 'selected' ?>>Yes, Adult 2</option> 
			  <option value="3" <?php if($_SESSION['married1'] == 3) echo 'selected' ?>>Yes, Adult 3</option> 
			<?php if($_SESSION['family_structure'] > 3) { ?>
				  <option value="4" <?php if($_SESSION['married1'] == 4) echo 'selected' ?>>Yes, Adult 4</option> 
			<?php } ?>
			</select>
			married
			<label for="married2"></label> 			   
			<select name="married2" id="married2" class="validate-married"> 
			  <option value="0" <?php if($_SESSION['married2'] == 0) echo 'selected' ?>></option>.
			  <option value="2" <?php if($_SESSION['married2'] == 2) echo 'selected' ?>>Adult 2</option> 
			  <option value="3" <?php if($_SESSION['married2'] == 3) echo 'selected' ?>>Adult 3</option> 
			  <?php if($_SESSION['family_structure'] > 3) { ?>
				  <option value="4" <?php if($_SESSION['married2'] == 4) echo 'selected' ?>>Adult 4</option> 
			  <?php } ?>
			</select>.
			</td>
			<?php } ?>
		  </tr>

		<?php if ($_SESSION['year'] >= 2020) { ?>
		  <tr> 
			<?php if($_SESSION['family_structure'] >= 2) { ?>
				<td><label for="disability_parent1">Have you ever received permanent disability benefits, like Supplemental Security Income (SSI) or Social Security Disability Insurance (SSDI)?</label></td>
				<td> 
			<?php } else { ?>
			<td><label for="disability_parent1">Have you ever received permanent disability benefits, like SSI or SSDI?</label></td>
				<td> 
			<?php } ?>
			  <select name="disability_parent1" id="disability_parent1">
				<option value="0" <?php if($_SESSION['disability_parent1'] == 0) echo 'selected' ?>>No</option>
				<option value="1" <?php if($_SESSION['disability_parent1'] == 1) echo 'selected' ?>>Yes</option>
			  </select>
			</td>
		  </tr>
		  <tr> 
			<?php if($_SESSION['family_structure'] >= 2) { ?>
				<td><label for="disability_parent2">Has Adult 2 ever received permanent disability benefits, like SSI or SSDI?</label></td>
				<td> 
				  <select <?php echo $disability_parent2 ?> name="disability_parent2" id="disability_parent2">
					<option value="0" <?php if($_SESSION['disability_parent2'] == 0) echo 'selected' ?>>No</option>
					<option value="1" <?php if($_SESSION['disability_parent2'] == 1) echo 'selected' ?>>Yes</option>
				  </select>
				</td>
			  </tr>
			<?php } ?>
			<?php if($_SESSION['family_structure'] >= 3) { ?>
				<td><label for="disability_parent3">Has Adult 3 ever received permanent disability benefits, like SSI or SSDI?</label></td>
				<td> 
				  <select <?php echo $disability_parent3 ?> name="disability_parent3" id="disability_parent3">
					<option value="0" <?php if($_SESSION['disability_parent3'] == 0) echo 'selected' ?>>No</option>
					<option value="1" <?php if($_SESSION['disability_parent3'] == 1) echo 'selected' ?>>Yes</option>
				  </select>
				</td>
			  </tr>
			<?php } ?>
			<?php if($_SESSION['family_structure'] >= 4) { ?>
				<td><label for="disability_parent4">Has Adult 4 ever received permanent disability benefits, like SSI or SSDI?</label></td>
				<td> 
				  <select <?php echo $disability_parent4 ?> name="disability_parent4" id="disability_parent4">
					<option value="0" <?php if($_SESSION['disability_parent4'] == 0) echo 'selected' ?>>No</option>
					<option value="1" <?php if($_SESSION['disability_parent4'] == 1) echo 'selected' ?>>Yes</option>
				  </select>
				</td>
			  </tr>
			<?php } ?>
		<?php } ?>

		  <td><label for="parent1_jobs_initial">How many jobs do you have now?</label></td>
			<td> 
			  <select name="parent1_jobs_initial" id="parent1_jobs_initial">
				<option value="0" <?php if($_SESSION['parent1_jobs_initial'] == 0) echo 'selected' ?>>0 (not employed)</option>
				<option value="1" <?php if($_SESSION['parent1_jobs_initial'] == 1) echo 'selected' ?>>1</option>
				<option value="2" <?php if($_SESSION['parent1_jobs_initial'] == 2) echo 'selected' ?>>2</option>
				<option value="3" <?php if($_SESSION['parent1_jobs_initial'] == 3) echo 'selected' ?>>3</option>
			  </select>
			</td>
		  </tr>

		<?php if($_SESSION['family_structure'] >= 2) { ?>
		  <td><label for="parent2_jobs_initial">How many jobs does Adult 2 have now?</label></td>
			<td> 
			  <select name="parent2_jobs_initial" id="parent2_jobs_initial">
				<option value="0" <?php if($_SESSION['parent2_jobs_initial'] == 0) echo 'selected' ?>>0 (not employed)</option>
				<option value="1" <?php if($_SESSION['parent2_jobs_initial'] == 1) echo 'selected' ?>>1</option>
				<option value="2" <?php if($_SESSION['parent2_jobs_initial'] == 2) echo 'selected' ?>>2</option>
				<option value="3" <?php if($_SESSION['parent2_jobs_initial'] == 3) echo 'selected' ?>>3</option>
			  </select>
			</td>
		  </tr>
		<?php } ?>

		<?php if($_SESSION['family_structure'] >= 3) { ?>
		  <td><label for="parent3_jobs_initial">How many jobs does Adult 3 have now?</label></td>
			<td> 
			  <select name="parent3_jobs_initial" id="parent3_jobs_initial">
				<option value="0" <?php if($_SESSION['parent3_jobs_initial'] == 0) echo 'selected' ?>>0 (not employed)</option>
				<option value="1" <?php if($_SESSION['parent3_jobs_initial'] == 1) echo 'selected' ?>>1</option>
				<option value="2" <?php if($_SESSION['parent3_jobs_initial'] == 2) echo 'selected' ?>>2</option>
				<option value="3" <?php if($_SESSION['parent3_jobs_initial'] == 3) echo 'selected' ?>>3</option>
			  </select>
			</td>
		  </tr>
		<?php } ?>

		<?php if($_SESSION['family_structure'] == 4) { ?>
		  <td><label for="parent4_jobs_initial">How many jobs does Adult 4 currently have?</label></td>
			<td> 
			  <select name="parent4_jobs_initial" id="parent4_jobs_initial">
				<option value="0" <?php if($_SESSION['parent4_jobs_initial'] == 0) echo 'selected' ?>>0 (not employed)</option>
				<option value="1" <?php if($_SESSION['parent4_jobs_initial'] == 1) echo 'selected' ?>>1</option>
				<option value="2" <?php if($_SESSION['parent4_jobs_initial'] == 2) echo 'selected' ?>>2</option>
				<option value="3" <?php if($_SESSION['parent4_jobs_initial'] == 3) echo 'selected' ?>>3</option>
			  </select>
			</td>
		  </tr>
		<?php } ?>

		<?php if ($_SESSION['year'] >= 2020) { ?>
		  <tr>
		  </tr>
			<?php for($i=1; $i<=$_SESSION['family_structure']; $i++) { ?>
				<tr>
				<td><label for="<?php echo 'future_scenario_parent'.$i?>"> 
				<?php if ($i == 1) { ?>
				I want to find out how my household's financial situation might change if I do this: 
				<?php } else if ($i == 2){ ?>
				... and if Adult 2 does this:
				<?php } else if ($i == 3){ ?>
				... and if Adult 3 does this:
				<?php } else if ($i == 4){ ?>
				... and if Adult 4 does this:
				<?php } ?>
				</label></td>
				<td> 
				  <select name="<?php echo 'future_scenario_parent'.$i?>" id="<?php echo 'future_scenario_parent'.$i?>" class = "<?php echo 'validate-employed-parent'.$i?>">
					<option value="new" <?php if($_SESSION['future_scenario_parent'.$i] == 'new') echo 'selected' ?>>Start a new job (add a job to current number of jobs)</option>
					<option value="wages" <?php if($_SESSION['future_scenario_parent'.$i] == 'wages') echo 'selected' ?>>Earn higher wages (at same number of jobs)</option>
					<option value="hours" <?php if($_SESSION['future_scenario_parent'.$i] == 'hours') echo 'selected' ?>>Work more hours (at same number of jobs)</option>
					<option value="both" <?php if($_SESSION['future_scenario_parent'.$i] == 'both') echo 'selected' ?>>Earn higher wages and work more hours (at same number of jobs)</option>
					<option value="none" <?php if($_SESSION['future_scenario_parent'.$i] == 'none') echo 'selected' ?>>Make no employment changes</option>
				  </select>
				</td>
				</tr>
			<?php } ?>
		<?php } ?>

		<?php if ($_SESSION['adult_student_flag'] == 1) { ?>
			<?php for($i=1; $i<=$_SESSION['family_structure']; $i++) { ?>
				<tr>
				<td>
				<label for="<?php echo 'parent'.$i.'_student_status'?>">
				<?php if ($i == 1) { ?>
					I am ...
				<?php } else if ($i == 2) { ?>
					Adult 2 is ...
				<?php } else if ($i == 3) { ?>
					Adult 3 is ...
				<?php } else if ($i == 4) { ?>
					Adult 4 is ...
				<?php } ?> 
				</label></td>
				<td>
				<select name="<?php echo 'parent'.$i.'_student_status'?>" id="<?php echo 'parent'.$i.'_student_status'?>" class="<?php echo 'validate-students-'.$_SESSION['family_structure']?>"> 
					<?php if ($_SESSION['family_structure'] > 1) { ?>
						<option value="nonstudent" <?php if($_SESSION['parent'.$i.'_student_status'] == 'nonstudent') echo 'selected' ?>>not a student</option> 
					<?php } ?> 
					<option value="pt_student" <?php if($_SESSION['parent'.$i.'_student_status'] == 'pt_student') echo 'selected' ?>>a part-time student</option> 
					<option value="ft_student" <?php if($_SESSION['parent'.$i.'_student_status'] == 'ft_student') echo 'selected' ?>>a full-time student</option> 
				</select>
				
				</td>
				</tr>
			<?php } ?>
		<?php } else { 
			for($i=1; $i<=$_SESSION['family_structure']; $i++) { 
				$_SESSION['parent'.$i.'_student_status'] = 'nonstudent';
			}
		}
		?>
		
		  <tr>
		  <tr>
		  <label> <tr>
			<?php if($_SESSION['year'] >= 2017) echo '' ?>
		 </label></tr> 
		  </tr>
	<?php } ?>

</table>
