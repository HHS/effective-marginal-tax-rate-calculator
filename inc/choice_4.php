<ul>
<?php if($_SESSION['user_prototype'] == 1) { ?>
	<br/>
	<?php for($k=1; $k<=$_SESSION['family_structure']; $k++) { ?>
		<?php if ($k == 1) { ?>
		<li>You:</li>
		<?php } else { ?>
		<li>Adult <?php echo $k ?> (age <?php echo $_SESSION['parent'.$k.'_age']; ?>):</li>
		<?php } ?> 
		<?php if ($_SESSION['parent'.$k.'_jobs_initial'] == 0) { ?>
		No current jobs
		<?php } else { ?> 
			<?php for ($j=1; $j<=$_SESSION['parent'.$k.'_jobs_initial']; $j++) { ?>
			Current job #<?php echo $j?>: $<?php echo $_SESSION['parent'.$k.'_wage_'.$j] ?> per 
					<?php if ($_SESSION['parent'.$k.'_payscale'.$j] == 'hour') {echo 'hour,';}
						else if ($_SESSION['parent'.$k.'_payscale'.$j] == 'day') {echo 'day,';}
						else if ($_SESSION['parent'.$k.'_payscale'.$j] == 'week') {echo 'week,';}
						else if ($_SESSION['parent'.$k.'_payscale'.$j] == 'biweekly') {echo 'every two weeks,';}
						else if ($_SESSION['parent'.$k.'_payscale'.$j] == 'month') {echo 'month,';}
						else if ($_SESSION['parent'.$k.'_payscale'.$j] == 'year') {echo 'year,';} 
					?>
					<?php echo $_SESSION['parent'.$k.'_workweek'.$j]; ?> hours per week
					<br/>
			<?php } ?>
		<?php } ?>
		<br/>
	<?php } ?>
<?php } else { ?>
	
	<li>Starting wage rate: $<?php echo number_format($_SESSION['wage_1'], 2) ?>/hour</li>
	<?php if($_SESSION['family_structure'] == 2) {
		if($_SESSION['parent2_max_work'] == 'F') {
			echo "<li>Second parent reaches full-time employment</li>";
		}
		elseif($_SESSION['parent2_max_work'] == 'H') {
			echo "<li>Second parent reaches part-time employment</li>";
		}
		else {
			echo "<li>Second parent is not employed</li>";
		}
	} ?>
	<?php if($_SESSION['year'] >= 2017) { ?> 
		<?php if($_SESSION['child1support'] == 1 || $_SESSION['child2support'] == 1 || $_SESSION['child3support'] == 1|| $_SESSION['child4support'] == 1|| $_SESSION['child5support'] == 1) { ?>
		<li>

			The family is receiving child support for
			<?php if($_SESSION['child1support'] == 1) { ?>
			Child 1 <?php } ?>
			<?php if($_SESSION['child2support'] == 1) { ?>
			,Child 2 
			<?php } ?>
			<?php if($_SESSION['child3support'] == 1) { ?>
			,Child 3 
			<?php } ?>
			<?php if($_SESSION['child4support'] == 1) { ?>
			,Child 4 
			<?php } ?>
			<?php if($_SESSION['child5support'] == 1) { ?>
			,Child 5 <?php } ?>
		
			from a noncustodial parent
		</li>
		<?php } ?>
	<?php } else { ?> 
		<li>$<?php echo $simulator->format($_SESSION['child_support_paid_m']) ?>/month in child support paid to family by noncustodial parent</li>
	<?php } ?> 
	<?php if($_SESSION['state'] != 'CT' || $_SESSION['year'] != 2002) { ?>
		<li>$<?php echo $simulator->format($_SESSION['savings']) ?> in savings</li>
		<li>
			<?php
			if($_SESSION['vehicle1_value'] > 0) {
				echo "Family car worth \${$simulator->format($_SESSION['vehicle1_value'])}, of which \${$simulator->format($_SESSION['vehicle1_owed'])} is still owed";
			}
			else {
				echo "No family car";
			} ?>
		</li>
			<?php
			if($_SESSION['family_structure'] == 2) {
				echo "<li>";
				if($_SESSION['vehicle2_value'] > 0) {
					echo "Second car worth \${$simulator->format($_SESSION['vehicle2_value'])}, of which \${$simulator->format($_SESSION['vehicle2_owed'])} is still owed";
				}
				else {
					echo "No second car";
				}
				echo "</li>";
			}
		?>
	<?php } ?>
	<li>$<?php echo $simulator->format($_SESSION['debt_payment']) ?>/month in debt payment</li>
<?php } ?>
</ul>