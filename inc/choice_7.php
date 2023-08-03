<ul>
<!-- Other Expenses -->
<?php
	if($_SESSION['housing_override']) {	echo "<li>Rent and utilities: \${$simulator->format($_SESSION['housing_override_amt'])}/month</li>"; }
	else { echo "<li>Rent and utilities: Calculator estimate</li>"; }

	if($_SESSION['food_override']) { echo "<li>Food: \${$simulator->format($_SESSION['food_override_amt'])}/month</li>"; }
	else { echo "<li>Food: Calculator estimate</li>"; }

	if($_SESSION['trans_override']) {
		if($_SESSION['family_structure'] == 2) {
			echo "<li>First parent&rsquo;s transportation ({$_SESSION['trans_type']}): \${$simulator->format($_SESSION['trans_override_parent1_amt'])}/month</li>";
			if($_SESSION['parent2_workhours'] != 'N') {
				echo "<li>Second parent&rsquo;s transportation ({$_SESSION['trans_type']}): \${$simulator->format($_SESSION['trans_override_parent2_amt'])}/month</li>";
			}
		}
		else { echo "<li>Transportation: \${$simulator->format($_SESSION['trans_override_parent1_amt'])}/month</li>"; }
	}
	else { echo "<li>Transportation ({$_SESSION['trans_type']}): Calculator estimate</li>"; }

	if($_SESSION['other_override']) { echo "<li>Other necessities: \${$simulator->format($_SESSION['other_override_amt'])}/month</li>"; }
	else { echo "<li>Other necessities: Calculator estimate</li>"; }

	# DC 2017 additions:
	if($_SESSION['state'] == 'DC' && $_SESSION['year'] == 2017) { 
		if($_SESSION['home_type'] == 1) {
			echo "<li> Home Type: Apartment </li>";
		} else {
			echo "<li> Home Type: House </li>";
		}
		if($_SESSION['energy_cost_override']) { 
			echo "<li>Energy cost: \${$simulator->format($_SESSION['energy_cost_override_amt'])}/month</li>";
		} else {
			if($_SESSION['fuel_source'] == 3) {
				echo "<li>  Fuel Source: Oil </li>";
			} elseif($_SESSION['fuel_source'] == 2) {
				echo "<li>  Fuel Source: Electric </li>";
			} else {  
				echo "<li>  Fuel Source: Gas </li>";
			}
		}
	}
	
	#Disability-related expenses
	if($_SESSION['year'] >= 2017) { 
		if(($_SESSION['disability_parent1'] || $_SESSION['disability_parent2']) == 1)  { 
			echo "<li> 	Disability-related personal expenses: \${$_SESSION['disability_personal_expenses_m']} /month </li>";
			echo "<li> 	Disability-related work expenses: \${$_SESSION['disability_work_expenses_m']} /month </li>";
		}
	}
?>
</ul>