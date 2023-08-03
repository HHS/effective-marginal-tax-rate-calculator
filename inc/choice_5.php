<ul>
<?php if($_SESSION['child_number'] == 0) { ?>
No children
</ul>
<?php } else { ?>
	<?php
		if($_SESSION['year'] >= 2017) {
			for($c=1;$c<=5;$c++) {

				if($_SESSION["child{$c}_age"] != -1) { 
					printf('<li>Child %d (age %d): ', $c, $_SESSION["child{$c}_age"]);
					if($_SESSION["child{$c}_age"] < 13) {
						if($_SESSION['ccdf']) {
							printf('%s while care is subsidized, and %s when care is not subsidized, with daily costs varying if care is non-traditional',
									$_SESSION["child{$c}_withbenefit_setting"],
									($_SESSION['child_care_continue_estimate_source'] == 'amt' ? 
										'care costing $' . $simulator->format($_SESSION["child{$c}_continue_amt_m"], 1) . '/day' :
										($_SESSION["child{$c}_withbenefit_setting"] == $_SESSION["child{$c}_continue_setting"] ? 
											'the same type of care at $' . $simulator->format($_SESSION["child{$c}_withbenefit_cost_m"], 1) . '/day' : 
											$_SESSION["child{$c}_continue_setting"].' ($'.$simulator->format($_SESSION["child{$c}_continue_cost_m"], 1).'/day)'
										)
									)
								);
						} else {
							if($_SESSION['child_care_nobenefit_estimate_source'] == 'spr') {
								printf('%s ($%s/day)', $_SESSION["child{$c}_nobenefit_setting"], $simulator->format($_SESSION["child{$c}_nobenefit_cost_m"], 1));
							}
							else {
								printf('care costing $%s/day, with daily costs varying if care is non-traditional', $simulator->format($_SESSION["child{$c}_nobenefit_amt_m"], 1));
							}
						}
					}
					else {
						echo "not eligible for child care";
					}
					echo "</li>";
				}
			}
		echo "</ul>";

		} else {
			for($c=1;$c<=3;$c++) {
				if($_SESSION["child{$c}_age"] != -1) { 
					printf('<li>Child %d (age %d): ', $c, $_SESSION["child{$c}_age"]);
					if($_SESSION["child{$c}_age"] < 13) {
						if($_SESSION['ccdf']) {
							if($_SESSION['state'] == 'DE' && $_SESSION['year'] == 2009) {
								printf('%s while care is subsidized, and %s when care is not subsidized',
										($_SESSION['child_care_delaware_choice'] == 'rate' ? 'care costing $' . $simulator->format($_SESSION["child{$c}_provider_rate"], 1) . '/month' : $_SESSION["child{$c}_withbenefit_setting"]),
										($_SESSION['child_care_continue_estimate_source'] == 'amt' ? 
											'care costing $' . $simulator->format($_SESSION["child{$c}_continue_amt_m"], 1) . '/month' :
											(($_SESSION['child_care_delaware_choice'] == 'setting' && $_SESSION["child{$c}_withbenefit_setting"] == $_SESSION["child{$c}_continue_setting"]) ? 
												'the same type of care at $' . $simulator->format($_SESSION["child{$c}_withbenefit_cost_m"], 1) . '/month' : 
												$_SESSION["child{$c}_continue_setting"].' ($'.$simulator->format($_SESSION["child{$c}_continue_cost_m"], 1).'/month)'
											)
										));
							} elseif($_SESSION['state'] == 'CA' && $_SESSION['year'] == 2011 && $_SESSION["child{$c}_age"] < 13 && $_SESSION["child{$c}_age"] > 10) {
								printf('%s (not eligible for subsidized care)',
										($_SESSION['child_care_continue_estimate_source'] == 'amt' ? 
											'care costing $' . $simulator->format($_SESSION["child{$c}_continue_amt_m"], 1) . '/month' :
											$_SESSION["child{$c}_continue_setting"].' ($'.$simulator->format($_SESSION["child{$c}_continue_cost_m"], 1).'/month)'
										));
							} else {
								printf('%s while care is subsidized, and %s when care is not subsidized',
										$_SESSION["child{$c}_withbenefit_setting"],
										($_SESSION['child_care_continue_estimate_source'] == 'amt' ? 
											'care costing $' . $simulator->format($_SESSION["child{$c}_continue_amt_m"], 1) . '/month' :
											($_SESSION["child{$c}_withbenefit_setting"] == $_SESSION["child{$c}_continue_setting"] ? 
												'the same type of care at $' . $simulator->format($_SESSION["child{$c}_withbenefit_cost_m"], 1) . '/month' : 
												$_SESSION["child{$c}_continue_setting"].' ($'.$simulator->format($_SESSION["child{$c}_continue_cost_m"], 1).'/month)'
											)
										));
							}
						}
						else {
							if($_SESSION['child_care_nobenefit'] == 'none') { echo 'no paid child care.'; }
							elseif($_SESSION['child_care_nobenefit_estimate_source'] == 'spr') {
								printf('%s ($%s/month)', $_SESSION["child{$c}_nobenefit_setting"], $simulator->format($_SESSION["child{$c}_nobenefit_cost_m"], 1));
							}
							else {
								printf('care costing $%s/month', $simulator->format($_SESSION["child{$c}_nobenefit_amt_m"], 1));
							}
						}
					}
					else {
						echo "not eligible for child care";
					}
					echo "</li>";
				}
			}
			echo "</ul>";
			if($_SESSION['refused_subsidy_level'] > 0 && $_SESSION['state'] != 'VT') {
				printf("<p>Family stopped participating in the child care subsidy program at $%s per year in earnings (although they continued to be eligible) because the family co-payment exceeded the cost of care.</p>", $simulator->format($_SESSION['refused_subsidy_level']));
			}
			if($_SESSION['always_refused_subsidy'] == 1 && $_SESSION['state'] != 'VT') {
				echo "<p>Family does not receive a child care subsidy because when both parents are employed, the subsidy copayment (which rises with  income) exceeds the full cost of care.</p>";
			}
		}
	?>
<?php } ?>
