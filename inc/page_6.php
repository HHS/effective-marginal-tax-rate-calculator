<script type="text/javascript">
Validation.add('validate-oop', 'Disability-related out-of-pocket health expenses cannot exceed total out-of-pocket health expenses', function(v,e) {
	if(Number(v) > 0 && e.id == 'disability_medical_expenses_mnth' && Number(v) > Number($F('hlth_costs_oop_m'))) {
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

</script>
<?php 
    // if no selection has been made, employer should be selected by default 
	// replace hlth_plan_private witht these two echo statements after resolved in plan.in lines 35 and 36 with private
	
    if (!$_SESSION['privateplan_type']) {
		if ($_SESSION['hlth'] == 1) {
			$_SESSION['privateplan_type'] = "individual";
		} else {
			$_SESSION['privateplan_type'] = "employer";
		}
    }

    if (!$_SESSION['hlth_plan_estimate_source']) {
        $_SESSION['hlth_plan_estimate_source'] = "calc_estimate";
    }
	
    ?>

	<!-- this is specifically calculated for DC 2017 only for non-group plans this was calculated due to the additional of the new parent age 2 to the formula, I would advise building it into the sql table next time --> 	
	<?php if ($_SESSION['year'] == 2020 && $_SESSION['state'] == 'KY') {
		$premium_ratioarray = array(0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.833, 0.859, 0.885, 0.851, 0.941, 0.97, 1, 1, 1, 1, 1.004, 1.024, 1.048, 1.087, 1.119, 1.135, 1.159, 1.183, 1.198, 1.214, 1.222, 1.23, 1.238, 1.246, 1.262, 1.278, 1.302, 1.325, 1.357, 1.397, 1.444, 1.5, 1.563, 1.635, 1.706, 1.786, 1.865, 1.952, 2.04, 2.135, 2.23, 2.333, 2.437, 2.548, 2.603, 2.714, 2.81, 2.873, 2.952, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3);
		$parent1_premium_ratio = $premium_ratioarray[($_SESSION['parent1_age'])];
		$parent2_premium_ratio = $premium_ratioarray[($_SESSION['parent2_age'])];
		$parent1_premium = ($parent1_premium_ratio/1.048) * 386;
		if ($_SESSION['family_structure'] == '2') { 
			$parent2_premium = ($parent2_premium_ratio/1.048)*386;
		} else {
			$parent2_premium = 0;
		}
		$parent_cost = $parent1_premium + $parent2_premium; 
		$family_cost = $parent_cost;
		for($i=1; $i<=5; $i++) {
			if ($_SESSION['child' . $i . '_age'] > -1) {
				${'child'.$i.'_premium_ratio'} = $premium_ratioarray[($_SESSION['child' . $i . '_age'])];
				${'child'.$i.'_premium'} = (${'child'.$i.'_premium_ratio'}/1.048) * 386;
				$family_cost = $family_cost + ${'child'.$i.'_premium'};
			}
		}
	} elseif ($_SESSION['year'] == 2021) {
		$premium_ratioarray = array(0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.833, 0.859, 0.885, 0.851, 0.941, 0.97, 1, 1, 1, 1, 1.004, 1.024, 1.048, 1.087, 1.119, 1.135, 1.159, 1.183, 1.198, 1.214, 1.222, 1.23, 1.238, 1.246, 1.262, 1.278, 1.302, 1.325, 1.357, 1.397, 1.444, 1.5, 1.563, 1.635, 1.706, 1.786, 1.865, 1.952, 2.04, 2.135, 2.23, 2.333, 2.437, 2.548, 2.603, 2.714, 2.81, 2.873, 2.952, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3);
		#Lookup the baseline 27-year-old premium. Eventually do this using a SQL lookup. For now, hardcoding it:
		if ($_SESSION['state'] == 'NH') { 
			$baseline27yo_premium = 331.79;
		}
		if ($_SESSION['state'] == 'PA') { 
			$baseline27yo_premium = 274.17;
		}
		if ($_SESSION['state'] == 'DC') { 
			$baseline27yo_premium = 303.65;
		}

		#Locate the premiums by using the ratio of the parent age ratio compared to the baseline age ratio.
		for($i=1; $i<=4; $i++) {
			if ($_SESSION['parent'.$i.'_age'] > -1) {
				${'parent'.$i.'_premium_ratio'} = $premium_ratioarray[($_SESSION['parent'.$i.'_age'])];  
				${'parent'.$i.'_premium'} = (${'parent'.$i.'_premium_ratio'}/1.048) * $baseline27yo_premium;
				$parent_cost += ${'parent'.$i.'_premium'}; 
			}
		}
		$family_cost = $parent_cost;
		for($i=1; $i<=5; $i++) {
			if ($_SESSION['child' . $i . '_age'] > -1) {
				${'child'.$i.'_premium_ratio'} = $premium_ratioarray[($_SESSION['child' . $i . '_age'])];
				${'child'.$i.'_premium'} = (${'child'.$i.'_premium_ratio'}/1.048) * 386;
				$family_cost +=  ${'child'.$i.'_premium'};
			}
		}
	}
	
	$_SESSION['family_size'] = $_SESSION['family_structure'] + $_SESSION['child_number']; 

	?>

<br/>
<br/>
<br/>
	
 <?php if ($_SESSION['hlth']) { ?>
	<h3>On Step 3, you indicated that your family receives at least some health insurance through Medicaid <?php if ($_SESSION['medicaid_name'] != 'Medicaid') { ?> (<?php echo $_SESSION['medicaid_name']; ?>) <?php } ?>. If your household starts making too much money to qualify for <?php echo $_SESSION['medicaid_name'] ?> how will you get health insurance?  </h3>
	<table class="indented">
	<tr>
		<td>
			<input type="radio" name="privateplan_type" id="hlth_plan_employer" value="employer" <?php if ($_SESSION['privateplan_type'] == 'employer') echo 'checked' ?>>
		</td>
		<td>
			Through my job<?php if ($_SESSION['family_structure'] > 1) { ?> or the job of someone else in my household<?php } ?>.<?php 
			/*echo $notes_table->add_note('page6_withbenefit_employer');
			echo $help_table->add_help('page6_withbenefit_employer');*/
			?><br>
			<!--commenting out for now because we found during user testing that these figures were confusing.
			<?php if ($_SESSION['child_number'] > 0) { ?>
				$<?php echo $simulator->health_cost('employer', 'parent') ?> per month for parent(s) (when children are still eligible for public insurance)<br>
				$<?php echo $simulator->health_cost('employer', 'family') ?> per month for family
			<?php } else { ?>
				$<?php echo $simulator->health_cost('employer', 'parent') ?> per month for adult(s)<br>
			<?php } ?>						
			-->
		</td>
	</tr>
	<tr>
		<?php $plantype = 'individual'; ?>
		<td>
			<input type="radio" name="privateplan_type" id="hlth_plan_private" value="individual" <?php if ($_SESSION['privateplan_type'] === 'individual') echo 'checked' ?>>
		</td>							
		<td>
			Through <?php if ($_SESSION['state'] == 'DC') { ?> <a href="https://dchealthlink.com/" target="_blank">DC Health Link<a/> or <?php } ?><a href="https://www.healthcare.gov/see-plans/#/" target="_blank">Healthcare.gov</a> (also called a "marketplace" plan or "individual" or "nongroup" plan). If you know what your <?php if ($_SESSION['family_size'] > 1) { ?> family's <?php } ?>health insurance premium (the amount you pay per month for health insurance) would be, you can enter it below. If not, the calculator will estimate your premium.<?php
			/*echo $notes_table->add_note('page6_withbenefit_nongroup');
			echo $help_table->add_help('page6_withbenefit_nongroup');*/
			?><br>
			<!--commenting out for now because we found during user testing that these figures were confusing.
			<?php if ($_SESSION['child_number'] > 0) { ?>
				$<?php echo round($parent_cost) ?> per month for parent(s)<br> <?php $plantype = 'individual' ?>
				$<?php echo round($family_cost) ?> per month for family		<?php $plantype = 'individual' ?>
			<?php } else {?>						
				$<?php echo round($parent_cost) ?> per month for adult(s)<br> <?php $plantype = 'individual' ?>
			<?php } ?>						
			-->
			 
		</td>
	</tr>
	</table>

<!--
Old way:
privateplan_type: divided between (a) hlth_plan_employer / employer, (b) hlth_plan_private / individual, and (c) hlth_plan_amount / user-entered
userplantype: individual or nothing

New way:
privateplan_type: divided between (a) hlth_plan_employer / employer, (b) hlth_plan_private / individual, 
hlth_plan_estimate_source: divided betwen "calc_estimate" and "user-entered"

-->
	<table class="indented">
	<p>
	<tr>
		<td>
			<input type="radio" name="hlth_plan_estimate_source" id="hlth_plan_estimate" value="calc_estimate" <?php if ($_SESSION['hlth_plan_estimate_source'] == 'calc_estimate') echo 'checked' ?>>
		</td>							
		<td>
			I want the calculator to estimate what my <?php if ($_SESSION['family_size'] > 1) { ?> family's health insurance premiums would be. <?php } else { ?> health insurance premium would be.<?php } ?> (This option is recommended if you choose that you will buy health insurance through <?php if ($_SESSION['state'] == 'DC') { ?> DC Health Link or <?php } ?>HealthCare.gov above. The calculator will assume you get the second lowest cost Silver plan on HealthCare.gov. If you choose this option for an employer plan, estimates are based on average costs of employer plans in your state.)
		</td>
	</tr>
	<tr>
		<td>
			<input type="radio" name="hlth_plan_estimate_source" id="hlth_plan_amount" value="user-entered" <?php if ($_SESSION['hlth_plan_estimate_source'] == 'user-entered') echo 'checked' ?>>
		</td>
		<td>
		 I know what my <?php if ($_SESSION['family_size'] > 1) { ?> family's <?php } ?>premium would be. My<?php if ($_SESSION['family_size'] > 1) { ?> family's <?php } ?> health insurance premium would be <!-- <a href="https://www.healthcare.gov/see-plans/#/" target="_blank">Healthcare.gov</a>)-->:
		<br>
			<table border="0" cellspacing="0" cellpadding="1">
			<?php if ($_SESSION['child_number'] > 0) { ?>
			   <tr>
					<td>
						$<input class="validate-number" type="text" name="hlth_amt_parent_m" id="hlth_amt_parent_m" enabled_when_checked="hlth_plan_amount" size="3" maxlength="4" value="<?php if (is_null ($_SESSION['hlth_amt_parent_m'])) {echo 0;} else {echo $_SESSION['hlth_amt_parent_m'];}?>"> per month for adult(s) only (health insurance premiums for you<?php if ($_SESSION['family_structure'] > 1) { ?> and other adults in your household<?php } ?>; if you are currently paying healthcare premiums for yourself<?php if ($_SESSION['family_structure'] > 1) { ?> and/or any other adult in your household<?php } ?>, you can enter that here)
					</td>
				</tr>
				<tr>
					<td>
						$<input class="validate-number" type="text" name="hlth_amt_family_m" id="hlth_amt_family_m" enabled_when_checked="hlth_plan_amount" size="3" maxlength="4" value="<?php if (is_null ($_SESSION['hlth_amt_family_m'])) {echo 0;} else {echo $_SESSION['hlth_amt_family_m'];} ?>"> per month for adult(s) plus any children (premiums for your entire household)
					</td>
				</tr>
			<?php } else { ?>
				<tr>
					<td>
						$<input class="validate-number" type="text" name="hlth_amt_parent_m" id="hlth_amt_parent_m" enabled_when_checked="hlth_plan_amount" size="3" maxlength="4" value="<?php if (is_null ($_SESSION['hlth_amt_parent_m'])) {echo 0;} else {echo $_SESSION['hlth_amt_parent_m'];} ?>"> per month for adult(s)
					</td>
				</tr>
			<?php } ?>
				
			<?php if (1 == 0) { ?>
				<!--Legacy text below. Including here in case "userplantype" shows up anywhere else. This is what it used to be. Took it out based on improvements to questions.-->
				<tr>
					<td>
						<?php $userplantype = 'individual'; ?>
						<input type="checkbox" name="userplantype" id="userplantype" enabled_when_checked="hlth_plan_amount" value="individual" <?php if ($_SESSION['userplantype'] == 'individual') echo 'checked' ?>> &nbsp; If you are entering your own health insurance premium amounts above, click here if you expect to purchase that insurance from the healthcare marketplace. (If you do not click this box, the calculator will assume that it is an employer plan.)
					</td>
				</tr>
			<?php } ?>	
				
			</table>
		</td>
	</tr> 
	</table>
	</p>

<?php } else { ?>
    <h3>This section is about your health insurance premium (the amount you pay per month for health insurance).<?php
        /*echo $notes_table->add_note('page6_nobenefit_intro');
        echo $help_table->add_help('page6_nobenefit_intro');*/
        ?></h3>
    <h4></h4>
	<table class="indented">
	<tr>
		<td>
			<input type="radio" name="hlth_plan_estimate_source" id="amount_other" value="user-entered" <?php if ($_SESSION['hlth_plan_estimate_source'] === 'user-entered') echo 'checked' ?>>
		</td>
		<td>
			I want to enter <?php if ($_SESSION['family_size'] > 1) { ?> my family's health insurance premium. We pay <?php } else { ?> my health insurance premium. I pay <?php } ?> $<input type="text" class="validate-number validate-nonnegative" id="hlth_amt_family_m" validate="\d{0,4}" error="Family's health costs must be between 0 and 9999" enabled_when_checked="amount_other" name="hlth_amt_family_m" size="3" maxlength="4" value="<?php if (is_null ($_SESSION['hlth_amt_family_m'])) {echo 0;} else {echo $_SESSION['hlth_amt_family_m'];} ?>"> per month for health insurance. (If you do not have health insurance, enter "0" here and skip the questions below about what type of plan you have.)
		</td>
	</tr>
	<tr>
		<td>
            <input type="radio" name="hlth_plan_estimate_source" id="hlth_plan_estimate" value="calc_estimate" <?php if ($_SESSION['hlth_plan_estimate_source'] == 'calc_estimate') echo 'checked' ?>>
		</td>
		<td>
            <label for="amount_employer">I want the calculator to estimate my <?php if ($_SESSION['family_size'] > 1) { ?> family's <?php } ?>health insurance premium.<?php # commenting out for now echo $simulator->health_cost('employer', 'family') ?> <!-- commenting out because too confusing for users. per month for family coverage--></label>
		</td>
	</tr>
	</table>
	<table class="indented">	
	<p>
    <h3>Type of health insurance coverage:</h3>
	<tr>
		<td>
            <input type="radio" name="privateplan_type" id="amount_employer" value="employer" <?php if ($_SESSION['privateplan_type'] == 'employer') echo 'checked' ?>>
		</td>
		<td>
            <label for="amount_employer"><?php if ($_SESSION['family_size'] > 1) { ?>My family has <?php } else { ?>I have <?php } ?> through my job<?php if ($_SESSION['family_structure'] > 1) { ?> or the job of someone else in my household<?php } ?>.
			<?php # commenting out for now echo $simulator->health_cost('employer', 'family') ?> <!-- commenting out because too confusing for users. per month for family coverage--></label>
		</td>
	</tr>
	<tr>
        <td>
            <?php $plantype = 'individual';
            ?>
			<input type="radio" name="privateplan_type" id="amount_private" value="individual" <?php if ($_SESSION['privateplan_type'] === 'individual') echo 'checked' ?>>
		</td>
		<td>
			<label><?php if ($_SESSION['family_size'] > 1) { ?>My family has <?php } else { ?>I have <?php } ?>health insurance through a <?php if ($_SESSION['state'] == 'DC') { ?> <a href="https://dchealthlink.com/" target="_blank">DC Health Link<a/> or <?php } ?><a href="https://www.healthcare.gov/see-plans/#/" target="_blank">Healthcare.gov</a> (also called a "marketplace" plan or "individual" or "nongroup" plan). If you select this option, and select to use the calculator to estimate health costs, the calculator will assume you get the second lowest cost Silver plan on HealthCare.gov.  
			<!-- commeneting out for now because the costs were too confusing for users during user testing. <?php
			/*echo $notes_table->add_note('page6_withbenefit_nongroup');
			echo $help_table->add_help('page6_withbenefit_nongroup');*/
			?><br>
			$<?php echo round($parent_cost) ?> per month for parent(s)<br>
			$<?php echo round($family_cost) ?> per month for family
			-->
			</label>
        </td>
	</tr>
	</table>
	</p>
<?php } ?>
<h3>Additional medical expenses:</h3>
<p>Expected out-of-pocket medical expenses other than premium payments, such as copays and deductibles: $<input type="text" id="hlth_costs_oop_m" class="validate-number validate-nonnegative" error="Family's out-of-pocket health costs must be between 0 and 999" name="hlth_costs_oop_m" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['hlth_costs_oop_m'])) {echo 0;} else {echo $_SESSION['hlth_costs_oop_m'];} ?>"> per month<?php
    if ($_SESSION['hlth']) {
        //echo $help_table->add_help('page6_oop_costs_withbenefit');
    } else {
        //echo $help_table->add_help('page6_oop_costs_nobenefit');
    }
    ?>
<br/>

<?php if($_SESSION['year'] >= 2017 && ($_SESSION['disability_parent1'] == 1 || $_SESSION['disability_parent2'] == 1 || $_SESSION['disability_parent3'] == 1 || $_SESSION['disability_parent4'] == 1)) { ?>
	<br/>How much of the above out-of-pocket medical expenses are for the 
	<?php if ($simulator->disability_count() == 1) { ?>
	adult who has 
	<?php } else { ?>
	adults who have
	<?php } ?>
	received disability benefits? $<input type="text" id="disability_medical_expenses_mnth" class="validate-number validate-oop validate-nonnegative" error="Family's out-of-pocket health costs must be between 0 and 999" name="disability_medical_expenses_mnth" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['disability_medical_expenses_mnth'])) {echo 0;} else {echo $_SESSION['disability_medical_expenses_mnth'];}?>"> per month<?php
    ?>

<?php #if($_SESSION['disability_medical_expenses_mnth'] > $_SESSION['hlth_costs_oop_m']);
	#$_SESSION['hlth_costs_oop_m']=$_SESSION['disability_medical_expenses_mnth'];
	?>
<?php } ?>
</p> 
<?php if ($_SESSION['exclude_covid_policies_ending_1221'] == 0 && $_SESSION['hlth'] == 1) { ?>
	<p>On  step 3, you said that your household receives Medicaid <?php if ($_SESSION['medicaid_short_name'] != 'Medicaid') { ?> (<?php echo $_SESSION['medicaid_short_name']; ?>) <?php } ?> benefits, and that you want the calculator to include temporary changes to benefit programs made because of COVID-19. One of these changes requires states to continue coverage of anyone currrently on Medicaid unless they voluntarily decide to leave the program (if they enroll in another insurance plan, for example), even if your household begins making an income that would be regularly too high to remain enrolled. Please select "Yes" below for the members of your household who both are on <?php echo $_SESSION['medicaid_short_name']?> now and who would choose to remain on <?php echo $_SESSION['medicaid_short_name']; ?> if your family income goes up:
	<br/>
	<br/>
	<?php for($i=1; $i<=$_SESSION['family_structure']; $i++) { #Note: using "2" as a default for No right now, will convert to 0 in frs.pm. ?>
		<?php if ($i == 1) { ?>
			<label for="parent1_continuous_coverage">You: </label>
			<select name="parent1_continuous_coverage" id="parent1_continuous_coverage">
				<option value="1" <?php if($_SESSION['parent1_continuous_coverage'] == 1) echo 'selected' ?>>Yes</option>
				<option value="2" <?php if($_SESSION['parent1_continuous_coverage'] == 2) echo 'selected' ?>>No</option>
			</select>
			<br/>
		<?php } else  { ?>
			<label for="<?php echo 'parent'.$i.'_continuous_coverage'?>">Adult <?php echo $i ?> (age <?php echo $_SESSION['parent'.$i.'_age'] ?>): </label>
			<select name="<?php echo 'parent'.$i.'_continuous_coverage'?>" id="<?php echo 'parent'.$i.'_continuous_coverage'?>">
				<option value="1" <?php if($_SESSION['parent'.$i.'_continuous_coverage'] == 1) echo 'selected' ?>>Yes</option>
				<option value="2" <?php if($_SESSION['parent'.$i.'_continuous_coverage'] == 2) echo 'selected' ?>>No</option>
			</select>
			<br/>
		<?php } ?>
	<?php } ?>
	<?php if($_SESSION['child_number_mtrc'] > 0) { ?>
		<label for="<?php echo 'child_continuous_coverage'?>">Child(ren): </label>
		<select name="<?php echo 'child_continuous_coverage'?>" id="<?php echo 'child_continuous_coverage'?>">
			<option value="1" <?php if($_SESSION['child_continuous_coverage'] == 1) echo 'selected' ?>>Yes</option>
			<option value="2" <?php if($_SESSION['child_continuous_coverage'] == 2) echo 'selected' ?>>No</option>
		</select>
		<br/>
	<?php } ?>
</p>
<?php } else {
	for($i=1; $i<=$_SESSION['family_structure']; $i++) {
		$_SESSION['parent'.$i.'_continuous_coverage'] == 0;
	}
	for($i=1; $i<=$_SESSION['child_number']; $i++) {
		$_SESSION['child_continuous_coverage'] == 0;
	}
}
?>


<br class="clearing" />
