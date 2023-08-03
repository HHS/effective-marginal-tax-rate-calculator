<script type="text/javascript">

<?php if($_SESSION['year'] == 2017): ?>
addLoadEvent(function() { 

  if($F('housing_override_0')) {
	Form.Element.disable($('energy_cost_override'))

  } else {
	Form.Element.enable($('energy_cost_override'))

  }
  
  $('housing_override_0').onclick = function()  {
    if($F('housing_override_0')) {
	  Form.Element.disable($('energy_cost_override'))

    }
  }
  
  $('housing_override_1').onclick = function()  {
    if($F('housing_override_1')) {
	  Form.Element.enable($('energy_cost_override'))

  }

  }
	})
<?php endif; ?>

Validation.add('validate-nonnegative','Value cannot be blank or less than 0', function(v,e) {
	if(Number(v) < 0 || v == "") {
		return false
	}
	return true;
});

Validation.add('validate-heating','Please enter an amount lower the total of all your utility bills above', function(v,e) {
	if(Number(v) >  Number($F('energy_cost_override_amt')))  {
		return false
	}
	return true;
});

</script>
<?php       
#$simulator->rent()
?>

<br/>
<br/>
<br/>

<p>On this page, you can fill in your costs or use the calculator's estimate.<br><br>
If you fill in your costs, include out-of-pocket costs only. For example: 
<br/>
  •	If heating is included in your rent, do not include any cost for heat under “utilities.” 
<br/>
  •	If you receive SNAP benefits or other food assistance, do not include the amount on your EBT card(s). Enter only what you pay out of pocket for food. 
<?php //echo $notes_table->add_note('page7_intro'); //echo $help_table->add_help('page7_intro'); ?></p>
<h4>Rent or Mortgage Payments:<?php //echo $notes_table->add_note('page7_housing'); //echo $help_table->add_help('page7_housing'); ?></h4>

<p class="checkset">
<?php if(($_SESSION['state'] == 'DC' || $_SESSION['state'] == 'KY') && $_SESSION['year'] >= 2017) { ?> 
	<label for="home_type">I live in a(n)<?php //echo $notes_table->add_note('page7_home_type') ?></label>
		  <select name="home_type" id="home_type">
			<option value= "apartment" <?php if($_SESSION['home_type'] == 'apartment') echo 'selected' ?>>Apartment</option> 
			<option value= "house" <?php if($_SESSION['home_type'] == 'house') echo 'selected' ?>>House</option> 
		  </select>
<br/>  
<br/>  
<?php } ?> 
    <input type="radio" id="housing_override_1" name="housing_override" value="1" <?php if($_SESSION['housing_override'] == 1) echo 'checked' ?> />
    <label>I want to enter my household's rent/mortgage payment. My household pays $
	<input class="validate-number validate-nonnegative" type="text" enabled_when_checked="housing_override_1" id="housing_override_amt" name="housing_override_amt" size="3" maxlength="4" value="<?php if (is_null ($_SESSION['housing_override_amt'])) {echo 0;} else {echo $_SESSION['housing_override_amt'];} ?>"> per month, out of pocket for rent/mortgage. </label>
<br>
<!--<i>Choose the Benefit Cliffs Calculator estimates or enter your own estimates. Please enter only the amounts you pay out of pocket. (For example, if you receive rent subsidies, just enter the monthly amount you pay in rent, not the market rate for where you live. And if you receive SNAP/Food Stamps, just enter the rough amount you pay for food every month out of pocket, without adding in the value of the food you buy through that program) </i>This was repeated twice, not sure why.--> 	
<br/>
    <input type="radio" id="housing_override_0" name="housing_override" value="0" <?php if($_SESSION['housing_override'] == 0) echo 'checked' ?> />

	<label for="housing_override_0">I want the calculator to estimate my housing cost based on location.<?php #Something is wrong with the simulator->rent function, possibly because we're reworking the child_number variable to make it child_number_mtrc. But we don't need that function to work yet in the UI, since we are removing the mention of the estimtes from this page: echo $simulator->rent() ?> </label>
<br/>
	<?php if($_SESSION['year'] >= 2020 && $_SESSION['sec8'] == 1) { ?> 
<br/>
            <label for="flatrent">If you live in Public Housing, is the amount you entered above a flat rent, meaning that it will not rise if your household's income increases?</label>
			  <select enabled_when_checked="housing_override_1" name="flatrent" id="flatrent">
				<option value="0" <?php if($_SESSION['flatrent'] == 0) echo 'selected' ?>>No (rent CHANGES with income)</option> 
				<option value="1" <?php if($_SESSION['flatrent'] == 1) echo 'selected' ?>>Yes, flat rent (will NOT change with income)</option> 
			  </select>
<br/>
	<?php } else { 
		$_SESSION['flatrent'] = 0;
	}  ?>


</p>
<?php if($_SESSION['year'] >= 2017 ) { ?>
	<h4>Utilities:</h4> <!--5/8: moved this down to below the DC 2017 condition-->

	<p class="checkset">
		<input type="radio" id="energy_cost_override_1" name="energy_cost_override" value="1" 
		enabled_when_checked="housing_override_1" <?php if($_SESSION['energy_cost_override'] == 1) echo 'checked' ?> />
		<label>I want to enter how much my household pays out of pocket for utilities like heating, gas, electric, and water. My household pays $<input class="validate-number validate-energy" type="text" enabled_when_checked="energy_cost_override_1" name="energy_cost_override_amt" id="energy_cost_override_1"  size="3" maxlength="4" value="<?php if (is_null ($_SESSION['energy_cost_override_amt'])) {echo 0;} else {echo $_SESSION['energy_cost_override_amt'];} ?>"> per month for utilities.</label>
		<?php if($_SESSION['state'] == 'ME' && $_SESSION['liheap']) { ?>	
			<label>The above number includes about $<input class="validate-number validate-energy" type="text" enabled_when_checked="energy_cost_override_1" name="heating_cost_override_amt" id="energy_cost_override_1"  size="3" maxlength="4" value="<?php if (is_null ($_SESSION['heating_cost_override_amt'])) {echo 0;} else {echo $_SESSION['heating_cost_override_amt'];} ?>"> per month for heating costs, out of pocket. (If heating costs are included in your electric bill, just enter your entire electric bill.)</label>
		<?php } ?> 
	<br/>
	<br/>
		<input type="radio" id="energy_cost_override_0" name="energy_cost_override" value="0" <?php if($_SESSION['energy_cost_override'] == 0) echo 'checked' ?> />
		<label for="energy_cost_override_0">I want the calculator to estimate my utility costs based on size and location.</label>
	<br/>
	<br/>
	Note: The calculator's rent estimate includes utilities. You can enter your own utility costs only if you entered your own rent/mortgage cost above.	
	<br/>
	<br/>
	<label for="fuel_source">Heating Source: <?php //echo $notes_table->add_note('page7_fuel_source') ?></label>
	<?php if($_SESSION['state'] == 'DC') { ?>	
		  <select name="fuel_source" id="fuel_source">
			<option value= "gas" <?php if($_SESSION['fuel_source'] == 'gas') echo 'selected' ?>>Gas</option> 
			<option value= "electric" <?php if($_SESSION['fuel_source'] == 'electric') echo 'selected' ?>>Electric</option> 
			<option value= "oil" <?php if($_SESSION['fuel_source'] == 'oil') echo 'selected' ?>>Oil</option> 
		  </select>
	<?php } ?> 
	<?php if($_SESSION['state'] == 'KY') { ?> 
		  <select name="fuel_source" id="fuel_source"> 
			<option value="natural_gas" <?php if($_SESSION['fuel_source'] == 'natural_gas') echo 'selected' ?>>Natural Gas</option> 
			<option value= "electric" <?php if($_SESSION['fuel_source'] == 'electric') echo 'selected' ?>>Electric</option>
			<option value= "bottle_gas" <?php if($_SESSION['fuel_source'] == 'bottle_gas') echo 'selected' ?>>Bottled Gas</option>
			<option value= "coal" <?php if($_SESSION['fuel_source'] == 'coal') echo 'selected' ?>>Coal</option> 
			<option value= "wood" <?php if($_SESSION['fuel_source'] == 'wood') echo 'selected' ?>>Wood</option> 
			<option value= "fuel_oil" <?php if($_SESSION['fuel_source'] == 'fuel_oil') echo 'selected' ?>>Oil</option> 
		  </select>		
	<?php } ?> 
	<?php if($_SESSION['state'] == 'NH') { ?> 
		  <select name="fuel_source" id="fuel_source"> 
			<option value="natural_gas" <?php if($_SESSION['fuel_source'] == 'natural_gas') echo 'selected' ?>>Natural Gas</option> 
			<option value= "electric" <?php if($_SESSION['fuel_source'] == 'electric') echo 'selected' ?>>Electric</option>
			<option value= "bottle_gas" <?php if($_SESSION['fuel_source'] == 'bottle_gas') echo 'selected' ?>>Bottled Gas</option>
			<option value= "fuel_oil" <?php if($_SESSION['fuel_source'] == 'oil') echo 'selected' ?>>Oil</option> 
		  </select>		
	<?php } ?> 
	<?php if($_SESSION['state'] == 'PA') { ?> 
		  <select name="fuel_source" id="fuel_source"> 
			<option value="natural_gas" <?php if($_SESSION['fuel_source'] == 'natural_gas') echo 'selected' ?>>Natural Gas</option> 
			<option value= "fuel_oil" <?php if($_SESSION['fuel_source'] == 'oil') echo 'selected' ?>>Oil</option> 
			<option value= "electric" <?php if($_SESSION['fuel_source'] == 'electric') echo 'selected' ?>>Electric</option>
			<option value= "coal" <?php if($_SESSION['fuel_source'] == 'coal') echo 'selected' ?>>Coal</option> 
			<option value= "bottle_gas" <?php if($_SESSION['fuel_source'] == 'bottle_gas') echo 'selected' ?>>Propane</option>
			<option value="kerosene" <?php if($_SESSION['fuel_source'] == 'kerosene') echo 'selected' ?>>Kerosene</option> 
			<option value= "blended_fuel" <?php if($_SESSION['fuel_source'] == 'blended_fuel') echo 'selected' ?>>Blended Fuel</option> 
			<option value= "wood" <?php if($_SESSION['fuel_source'] == 'wood') echo 'selected' ?>>Wood or Other</option> 

		  </select>		
	<?php } ?> 
	<?php if($_SESSION['state'] == 'ME') { ?> 
		  <select name="fuel_source" id="fuel_source"> 
			<option value= "electric" <?php if($_SESSION['fuel_source'] == 'electric') echo 'selected' ?>>Electric</option>
			<option value="natural_gas" <?php if($_SESSION['fuel_source'] == 'non_electric') echo 'selected' ?>>Natural Gas or Other</option> 
		  </select>		
	<?php } ?> 

	<?php if($_SESSION['year'] >= 2020) { ?> 
		<br/>
		<br/>
		<label for="heat_in_rent">Is heating included in your rent?</label>
			  <select name="heat_in_rent" id="heat_in_rent"> <!--enabled_when_checked="energy_cost_override_0" Once included this enabled_when_checked check, but disabling because some people might pay for utilities but not heat-->
				<option value="0" <?php if($_SESSION['heat_in_rent'] == 0) echo 'selected' ?>>No</option> 
				<option value="1" <?php if($_SESSION['heat_in_rent'] == 1) echo 'selected' ?>>Yes</option> 
			  </select>
	<?php } ?> 	
	</p>

<?php } ?> 
<h4>Food:

<?php  if($_SESSION['year'] >= 2020 && $_SESSION['state'] == 'KY') {
	//echo $notes_table->add_note('page7_food_new'); //echo $help_table->add_help('page7_food_new');
} else {
	//echo $notes_table->add_note('page7_food'); //echo $help_table->add_help('page7_food');
}  ?>
</h4>

<p class="checkset">
    <input type="radio" id="food_override_1" name="food_override" value="1" <?php if($_SESSION['food_override'] == 1) echo 'checked' ?> />
    <label>I want to enter my out-of-pocket food costs. My household spends about $<input class="validate-number validate-nonnegative" type="text" enabled_when_checked="food_override_1" id="food_override_amt" name="food_override_amt" size="3" maxlength="4" value="<?php if (is_null ($_SESSION['food_override_amt'])) {echo 0;} else {echo $_SESSION['food_override_amt'];}?>"> per month out of pocket on food.</label>
	<br/>
	<br/>
    <input type="radio" id="food_override_0" name="food_override" value="0" <?php if($_SESSION['food_override'] == 0) echo 'checked' ?> />
    <label for="food_override_0">I want the calculator to estimate my out-of-pocket food costs based on the number and ages of people in my household.</label>
</p>
<?php if($_SESSION['year'] >= 2020) { ?> 
	<!-- use SQL call in earlier PHP code (maybe similar to how public vs. private transportation is defined in $simulator->trans_private) eventually, but for now we're hard-coding-->
	<?php #$cep_option_array = array(0,0,0,1,0,0,0,0,1,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0);
	#$cep_option = $cep_option_array[$_SESSION['residence']]; 
	?>
	<?php if($_SESSION['child_number'] > 0 && ($_SESSION['frpl'] == 1 || $_SESSION['nsbp'] == 1) && $_SESSION['state'] != 'DC' && ($_SESSION['state'] != 'PA' || $_SESSION['residence'] != 15122)) {  #Commenting out additional condition that $cep_option == 1 for cep to be checked. Conceivably we could add this to adjust based on geography, but it makes more sense to check with parents rather than rely on incomplete school data.?> 
		<p>
		<label for="cep">In step 3, you said your child/children gets free or reduced price meals at school. Does the school give these meals to all students without asking about income? (If you did not have to fill out a form for free or reduced price meals, please select YES.)</label>
			  <select name="cep" id="cep">
				<option value="0" <?php if($_SESSION['cep'] == 0) echo 'selected' ?>>No</option> 
				<option value="1" <?php if($_SESSION['cep'] == 1) echo 'selected' ?>>Yes</option> 
			  </select>
		</p>
	<?php } else if ($_SESSION['state'] == 'DC' || ($_SESSION['state'] == 'PA' && $_SESSION['residence'] == 15122)) { #All public schools in DC and Pittsburgh offer free breakfast and lunch to all students regardless of income. We include cep_partipation in the SQL tables. Initially that had been envisioned as whether any school in the area participated in CEP, but we may want to eventually use it as an indicator of whether all public schools are participating in CEP, and using CEP = 0 as a condition for asking teh above question instead of doing these locally-specific conditions.
		$_SESSION['cep'] = 1;
	}  else {
		$_SESSION['cep'] = 0;
	} ?> 
<?php } ?> 
<h4>Transportation:<?php //echo $notes_table->add_note('page7_trans'); //echo $help_table->add_help('page7_trans'); ?></h4>
<p class="checkset">
    <input type="radio" id="trans_override_1" name="trans_override" value="1" <?php if($_SESSION['trans_override'] == 1) echo 'checked' ?> />
    <label>
    <?php if($_SESSION['family_structure'] >= 2 && $_SESSION['parent2_max_work'] != 'N') { ?>
       I want to enter how much my household spends on transportation (gas, car repairs, bus fare, taxi/ride-sharing costs, etc.). We spend about this much on transportation:<?php //echo $help_table->add_help('page7_trans_user'); ?>
    </label>
	<br/>
	<style="margin-left: 24px;margin-bottom:0px;"> <!--I lose the style when I moe the p tag. But when I add the p tag, annoying lines appear that should not be there. The gray lines should only be there to indicate different groups, e.g. "Food", "Transportation," etc. -->
        Me:$<input class="validate-number validate-nonnegative" type="text" enabled_when_checked="trans_override_1" id="trans_override_parent1_amt" name="trans_override_parent1_amt" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['trans_override_parent1_amt'])) {echo 0;} else {echo $_SESSION['trans_override_parent1_amt'];} ?>"> per month<br/>
        Adult 2: $<input class="validate-number validate-nonnegative" type="text" enabled_when_checked="trans_override_1" id="trans_override_parent2_amt" name="trans_override_parent2_amt" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['trans_override_parent2_amt'])) {echo 0;} else {echo $_SESSION['trans_override_parent2_amt'];} ?>"> per month<br/>
		<?php if($_SESSION['family_structure'] >= 3) { ?>
        Adult 3: $<input class="validate-number validate-nonnegative" type="text" enabled_when_checked="trans_override_1" id="trans_override_parent3_amt" name="trans_override_parent3_amt" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['trans_override_parent3_amt'])) {echo 0;} else {echo $_SESSION['trans_override_parent3_amt'];} ?>"> per month<br/><?php } ?>
		<?php if($_SESSION['family_structure'] >= 4) { ?>
        Adult 4: $<input class="validate-number validate-nonnegative" type="text" enabled_when_checked="trans_override_1" id="trans_override_parent4_amt" name="trans_override_parent4_amt" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['trans_override_parent4_amt'])) {echo 0;} else {echo $_SESSION['trans_override_parent4_amt'];} ?>"> per month<br/><?php } ?>
	<?php } else { ?>
		 I want to enter how much my household spends on transportation (gas, car repairs, bus fare, taxi/ride-sharing costs, etc.). My household spends about $<input class="validate-number validate-nonnegative" type="text" enabled_when_checked="trans_override_1" id="trans_override_parent1_amt" name="trans_override_parent1_amt" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['trans_override_parent1_amt'])) {echo 0;} else {echo $_SESSION['trans_override_parent1_amt'];} ?>"> per month out of pocket on transportation.<?php //echo $help_table->add_help('page7_trans_user'); ?>
	</label>
	<?php } ?>
<?php if($_SESSION['year'] < 2020) { ?>
	<p class="checkset">
		<input type="radio" id="trans_override_0" name="trans_override" value="0" <?php if($_SESSION['trans_override'] == 0) echo 'checked' ?> />
		<label for="trans_override_0">
			<?php if($simulator->trans_private()) { ?>Click here to let the calculator estimate private transportation costs
			<?php } else { ?>Click here to let the calculator estimate public transportation costs based on your location and number of days you and your family members work.<?php } ?>
		</label>
	</p>

<?php } else { ?>
		<br/>
		<br/>
	<?php if($simulator->trans_private()) { ?>
		<input type="radio" id="trans_override_0" name="trans_override" value="0" <?php if($_SESSION['trans_override'] == 0) echo 'checked' ?> />
		<label for="trans_override_0"> I want the calculator to estimate my household’s transportation costs based on the number of days worked and local transportation costs.
		</label>
	<?php } else { ?>
			<input type="radio" id="trans_override_0" name="trans_override" value="0" <?php if($_SESSION['trans_override'] == 0) echo 'checked' ?> />
			<label for="trans_override_0"> I want the calculator to estimate my household’s transportation costs based on the number of days worked and local transportation costs.
			</label>
		<br/>
		<br/>
		<label for="user_trans_type">Does your family use public transportation if available?</label>
			<select name="user_trans_type" id="user_trans_type" enabled_when_checked="trans_override_0">
				<option value="public" <?php if($_SESSION['user_trans_type'] == 'public') echo 'selected' ?>>Yes</option> 
				<option value="car" <?php if($_SESSION['user_trans_type'] == 'car') echo 'selected' ?>>No</option>
				</select>
	<?php } ?>							
<?php } ?>							
</p>
	<?php if($_SESSION['year'] >= 2017 && ($_SESSION['disability_parent1'] == 1  || $_SESSION['disability_parent2'] == 1 || $_SESSION['disability_parent3'] == 1 || $_SESSION['disability_parent4'] == 1)) { ?>
		<h4>Disability-Related Expenses:<?php //echo $notes_table->add_note('page7_other'); //echo $help_table->add_help('page7_other'); ?></h4>
		<p>
		How much does your household spend on work-related disability expenses (e.g., wheelchairs needed to get to work)? <br>
		 $<input type="text" id="disability_work_expenses_m" class="validate-number validate-nonnegative" error="Disability-related expenses must be between 0 and 999" name="disability_work_expenses_m" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['disability_work_expenses_m'])) {echo 0;} else {echo $_SESSION['disability_work_expenses_m'];} ?>"> per month
		<br/>
		<br/>		
		How much does your household spend on non-work-related disability expenses (e.g., wheelchairs for people who do not work)? <br>
		 $<input type="text" id="disability_other_expenses_m" class="validate-number validate-nonnegative" error="Disability-related expenses must be between 0 and 999" name="disability_other_expenses_m" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['disability_other_expenses_m'])) {echo 0;} else {echo $_SESSION['disability_other_expenses_m'];} ?>"> per month
		<br/>
		<br/>		
		How much does your household spend on dependent care for people with disabilities (e.g., home aides)? <br>
		 $<input type="text" id="disability_personal_expenses_m" class="validate-number validate-nonnegative" error="Disability-related expenses must be between 0 and 999" name="disability_personal_expenses_m" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['disability_personal_expenses_m'])) {echo 0;} else {echo $_SESSION['disability_personal_expenses_m'];} ?>"> per month
		</p>
	<?php } else {
		$_SESSION['disability_work_expenses_m'] = 0;
		$_SESSION['disability_personal_expenses_m'] = 0;
	}?>
<h4>Phone Bill:</h4>
<p class="checkset">
    <input type="radio" id="phone_override_1" name="phone_override" value="1" <?php if($_SESSION['phone_override'] == 1) echo 'checked' ?> />
    <label>I want to enter how much  my household spends on phone bills. My household spends about $<input class="validate-number validate-nonnegative" type="text" enabled_when_checked="phone_override_1" name="phone_override_amt" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['phone_override_amt'])) {echo 0;} else {echo $_SESSION['phone_override_amt'];} ?>"> per month out of pocket on phone costs (including home phone and cell/mobile/smart phones). </label>
	<br/>
	<br/>
    <input type="radio" id="phone_override_0" name="phone_override" value="0" <?php if($_SESSION['phone_override'] == 0) echo 'checked' ?> />
    <label for="phone_override_0">I want the calculator to estimate my household’s phone costs using typical telephone costs based on national averages.</label>
</p>

<?php if ($_SESSION['adult_student_flag'] == 1) { ?>
	<h4>Education Expenses:</h4>
	<p/>
	<br/>Please enter the yearly education expenses (tuition, fees, books, supplies, equipment) for adult student(s).
	<?php for($i=1; $i<=$_SESSION['family_structure']; $i++) { ?>
		<?php if($_SESSION['parent'.$i.'_student_status'] == 'pt_student' || $_SESSION['parent'.$i.'_student_status'] == 'ft_student') { ?> 
			<br/>
			<br/>
			Educational expenses for 
			<?php if ($i == 1) { ?>
				me: $<input type="text" id="parent1_educational_expenses" class="validate-number validate-nonnegative" name="parent1_educational_expenses" size="5" maxlength="5" value="<?php if (is_null ($_SESSION['parent1_educational_expenses'])) {echo 0;} else {echo $_SESSION['parent1_educational_expenses'];} ?>"> 
			<?php } else if ($i == 2) { ?>
				Adult 2 (age <?php echo $_SESSION['parent'.$i.'_age'] ?>): $<input type="text" id="parent2_educational_expenses" class="validate-number validate-nonnegative" name="parent2_educational_expenses" size="5" maxlength="5" value="<?php if (is_null ($_SESSION['parent2_educational_expenses'])) {echo 0;} else {echo $_SESSION['parent2_educational_expenses'];} ?>"> 
			<?php } else if ($i == 3) { ?>
				Adult 3 (age <?php echo $_SESSION['parent'.$i.'_age'] ?>): $<input type="text" id="parent3_educational_expenses" class="validate-number validate-nonnegative" name="parent3_educational_expenses" size="5" maxlength="5" value="<?php if (is_null ($_SESSION['parent3_educational_expenses'])) {echo 0;} else {echo $_SESSION['parent3_educational_expenses'];}?>"> 
			<?php } else if ($i == 4) { ?>
				Adult 4 (age <?php echo $_SESSION['parent'.$i.'_age'] ?>): $<input type="text" id="parent4_educational_expenses" class="validate-number validate-nonnegative" name="parent4_educational_expenses" size="5" maxlength="5" value="<?php if (is_null ($_SESSION['parent4_educational_expenses'])) {echo 0;} else {echo $_SESSION['parent4_educational_expenses'];} ?>"> 
			<?php } ?> 
			per year
		<?php } ?> 
	<?php } ?> 
	</p>
<?php } ?> 



<h4>Other Necessities:<?php //echo $notes_table->add_note('page7_other'); //echo $help_table->add_help('page7_other'); ?></h4>
<p class="checkset">
    <input type="radio" id="other_override_1" name="other_override" value="1" <?php if($_SESSION['other_override'] == 1) echo 'checked' ?> />
    <label>I want to enter how much my household  spends per month on other necessary things, like clothes, school supplies, and household supplies. My household spends about $<input class="validate-number validate-nonnegative" type="text" enabled_when_checked="other_override_1" name="other_override_amt" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['other_override_amt'])) {echo 0;} else {echo $_SESSION['other_override_amt'];} ?>"> per month  out of pocket on things like these.</label>
	<br/>
	<br/>
    <input type="radio" id="other_override_0" name="other_override" value="0" <?php if($_SESSION['other_override'] == 0) echo 'checked' ?> />
    <label for="other_override_0">I want the calculator to estimate  these costs based on national averages.</label>
</p>

<h4>Other Regular Payments:</h4>
<p class="checkset">
	<input type="radio" id="other_regular_override_0" name="other_regular_override" value="0" <?php if($_SESSION['other_regular_override'] == 0) echo 'checked' ?>>
	<label>My household has no other regular payments, or I want to skip entering any for now.</label>
<br/>
<br/>
	<input type="radio" id="other_regular_override_1" name="other_regular_override" value="1" <?php if($_SESSION['other_regular_override'] == 1) echo 'checked' ?>>
	<label>My household has other regular payments. They are:<?php //echo $notes_table->add_note('page5_continue_cost'); echo $help_table->add_help('page5_continue_cost'); ?></label>
<table class="indented">
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	Child support (that you pay) <?php if ($_SESSION['state'] == 'DC') { ?> for <input class="validate-number validate-nonnegative" type="text" id="outgoing_child_support_children" name="outgoing_child_support_children" size="3" maxlength="3" value="<?php if (is_null ($_SESSION['outgoing_child_support_children'])) {echo 0;} else {echo $_SESSION['outgoing_child_support_children'];} ?>"> children<?php } ?>
		        </td>
				<td valign="bottom" align="left" class="copy"> 
					$<input class="validate-number validate-nonnegative" id="amt_<?php echo $i ?>" enabled_when_checked="other_regular_override_1"  type="text" name="outgoing_child_support" value="<?php if (is_null ($_SESSION['outgoing_child_support'])) {echo 0;} else {echo $_SESSION['outgoing_child_support'];} ?>" size="3" maxlength="4"> per month
				</td>
            </tr>
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	Alimony (that you pay)
		        </td>
                    <td valign="bottom" align="left" class="copy"> 
                    	$<input class="validate-number validate-nonnegative" id="amt_<?php echo $i ?>" enabled_when_checked="other_regular_override_1"type="text" name="outgoing_alimony" value="<?php if (is_null ($_SESSION['outgoing_alimony'])) {echo 0;} else {echo $_SESSION['outgoing_alimony'];} ?>" size="3" maxlength="4"> per month
                	</td>
            </tr>
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	Car insurance
		        </td>
                    <td valign="bottom" align="left" class="copy"> 
                    	$<input class="validate-number validate-nonnegative" id="amt_<?php echo $i ?>" enabled_when_checked="other_regular_override_1"type="text" name="car_insurance_m" value="<?php if (is_null ($_SESSION['car_insurance_m'])) {echo 0;} else {echo $_SESSION['car_insurance_m'];} ?>" size="3" maxlength="4"> per month
                	</td>
            </tr>
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	Car payments (car loans)
		        </td>
                    <td valign="bottom" align="left" class="copy"> 
                    	$<input class="validate-number validate-nonnegative" id="amt_<?php echo $i ?>" enabled_when_checked="other_regular_override_1" type="text" name="car_payment_m" value="<?php if (is_null ($_SESSION['car_payment_m'])) {echo 0;} else {echo $_SESSION['car_payment_m'];} ?>" size="3" maxlength="4"> per month
                	</td>
            </tr>
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	Renters' or homeowners' insurance
		        </td>
                    <td valign="bottom" align="left" class="copy"> 
                    	$<input class="validate-number validate-nonnegative" id="amt_<?php echo $i ?>" enabled_when_checked="other_regular_override_1" type="text" name="renters_insurance_m" value="<?php if (is_null ($_SESSION['renters_insurance_m'])) {echo 0;} else {echo $_SESSION['renters_insurance_m'];} ?>" size="3" maxlength="4"> per month
                	</td>
            </tr>
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	Student loan debt
		        </td>
                    <td valign="bottom" align="left" class="copy"> 
                    	$<input class="validate-number validate-nonnegative" id="amt_<?php echo $i ?>" enabled_when_checked="other_regular_override_1" type="text" name="student_debt" value="<?php if (is_null ($_SESSION['student_debt'])) {echo 0;} else {echo $_SESSION['student_debt'];} ?>" size="3" maxlength="4"> per month
                	</td>
            </tr>
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	Any other debt
		        </td>
                    <td valign="bottom" align="left" class="copy"> 
                    	$<input class="validate-number validate-nonnegative" id="amt_<?php echo $i ?>" enabled_when_checked="other_regular_override_1" type="text" name="debt_payment" value="<?php if (is_null ($_SESSION['debt_payment'])) {echo 0;} else {echo $_SESSION['debt_payment'];} ?>" size="3" maxlength="4"> per month
                	</td>
            </tr>
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	Any other regular payments
		        </td>
                    <td valign="bottom" align="left" class="copy"> 
                    	$<input class="validate-number validate-nonnegative" id="amt_<?php echo $i ?>" enabled_when_checked="other_regular_override_1" type="text" name="other_payments" value="<?php if (is_null ($_SESSION['other_payments'])) {echo 0;} else {echo $_SESSION['other_payments'];} ?>" size="3" maxlength="4"> per month
                	</td>
            </tr>
</table>
</p>
<br/>
