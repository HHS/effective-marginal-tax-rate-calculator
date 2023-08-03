<ul>
<!-- Health Expenses -->
<?php 
    // if no selection has been made, employer should be selected by default 
	// replace hlth_plan_private with these two echo statements after resolved in plan.in lines 35 and 36 with private
	
    if (!$_SESSION['privateplan_type']) {
        $_SESSION['privateplan_type'] = "employer";
    }

	echo "<li>";
	if($_SESSION['hlth_plan'] == 'uninsured') {
		echo "Family has no access to private health insurance; parents are uninsured when ineligible for public coverage";
	}
	elseif($_SESSION['hlth']) {
		echo "Cost of {$_SESSION['hlth_plan_text']} insurance premium: \${$_SESSION['hlthins_parent_cost_m']}/month";
		if ($_SESSION['child_number_mtrc'] > 0) {
			echo " for adults (when children are still eligible for public insurance); \${$_SESSION['hlthins_family_cost_m']}/month for family";
		}
	}
	else {
		echo "Cost of {$_SESSION['hlth_plan_text']} insurance premium: \${$_SESSION['hlthins_family_cost_m']}/month";
	}

	if($_SESSION['hlth_costs_oop_m'] > 0) {
		echo "</li>";
		echo "<li>Family&rsquo;s out-of-pocket health costs: \${$_SESSION['hlth_costs_oop_m']}/month</li>";
		if($_SESSION['state'] == 'IL' && ($_SESSION['year'] == 2006 || $_SESSION['year'] == 2008) && $simulator->alternates()) {
			echo "<li>";
			if($_SESSION['hlth']) {
				echo "Health insurance expense includes out-of-pocket costs: per child - ";
				echo "\${$simulator->format($_SESSION['hlth_oop_child_public'])}/month while in public coverage, ";
				echo "\${$simulator->format($_SESSION['hlth_oop_child_private'])}/month while in private; per parent - ";
				echo "\${$simulator->format($_SESSION['hlth_oop_parent_public'])}/month while in public coverage, ";
				echo "\${$simulator->format($_SESSION['hlth_oop_parent_private'])}/month in private";
			}
			else {
				echo "Health insurance expense includes out-of-pocket costs: per child - ";
				echo "\${$simulator->format($_SESSION['hlth_oop_child_private'])}/month; per parent - ";
				echo "\${$simulator->format($_SESSION['hlth_oop_parent_private'])}/month";
			}
			echo "</li>";
		}
	}
?>
</ul>

