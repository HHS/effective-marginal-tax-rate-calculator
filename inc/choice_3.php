<?php # if($_SESSION['benefits'] > 0) { #this line seemed to be generating errors. Check to see if 'benefits' is generated anywhere.?>
When eligible, family receives:
<ul>
<!-- CCDF Child Care Subsidies -->
<?php
	$benefits_flag = 0;
	if($_SESSION['ccdf']) {
		$benefits_flag = 1;
		echo "<li>CCDF Child Care Subsidies";
		if($_SESSION['state'] == 'IL' && ($_SESSION['year'] == 2006 || $_SESSION['year'] == 2008) && $simulator->alternates()) {
			if($_SESSION['ccdf_alt_c']) { echo "<br/>(changed the income eligibility limit to {$_SESSION['ccdf_user_input_c']}% SMI"; }
			if($_SESSION['ccdf_alt_b']) { echo "<br/>(added a provider fee of \${$simulator->format($_SESSION['ccdf_user_input_b'])}/month per child, in addition to family copayment)"; }
			if($_SESSION['ccdf_alt'] == 1 && $_SESSION['ccdf_alt_value'] == 1) { echo "<br/>(disregarded all child support income received)"; }
			if($_SESSION['ccdf_alt'] == 1 && $_SESSION['ccdf_alt_value'] == 2) { echo "<br/>(disregarded up to \${$simulator->format($_SESSION['ccdf_user_input'])} of child support income received)"; }
			if($_SESSION['ccdf_alt_d'] == 1 && $_SESSION['ccdf_user_input_d'] == 'family_both') { echo "<br/>(deducting family's out-of-pocket medical costs when calculating copays and eligibility)"; }
			elseif($_SESSION['ccdf_alt_d'] == 1 && $_SESSION['ccdf_user_input_d'] == 'family_eligibility') { echo "<br />(deducting family's out-of-pocket medical costs when calculating eligibility)"; }
			elseif($_SESSION['ccdf_alt_d'] == 1 && $_SESSION['ccdf_user_input_d'] == 'child_both') { echo "<br />(deducting children's out-of-pocket medical costs when calculating copays and eligibility)"; }
			elseif($_SESSION['ccdf_alt_d'] == 1 && $_SESSION['ccdf_user_input_d'] == 'child_eligibility') { echo "<br />(deducting children's out-of-pocket medical costs when calculating eligibility)"; }
		}
		elseif($_SESSION['state'] == 'CT' && $_SESSION['year'] == 2005 && $_SESSION['ccdf_alt']) {
			echo "<br/>(changed income limit to {$_SESSION['ccdf_user_input']}% of state median income)";
		}
		elseif($_SESSION['state'] == 'TX' && $_SESSION['year'] == 2004 && $_SESSION['ccdf_alt']) {
			echo "<br/>(changed income limit to {$_SESSION['ccdf_user_input']}% of state median income)";
		}
		elseif($_SESSION['state'] == 'CO' && $_SESSION['ccdf_inc_limit_alt']) {
			echo "<br/>(changed eligibility limit to {$_SESSION['ccdf_inc_limit_user_input']}% of FPL)";
		}
		elseif($_SESSION['state'] == 'MI' && $_SESSION['year'] == 2006 && $_SESSION['ccdf_alt']) {
			echo "<br/>(used policy change option";
			if($_SESSION['ccdf_alt_b']) {
				echo ' with income limit of ' . $_SESSION['ccdf_alt_b_value'] . '% of FPL';
			}
			echo ')';
		}
		elseif($_SESSION['state'] == 'NM' && $_SESSION['year'] == 2008 && $_SESSION['ccdf_alt']) {
			echo "<br/>(changed poverty limit to {$_SESSION['ccdf_user_input']}% of FPL)";
		}
		if($_SESSION['state'] == 'TX' && $_SESSION['year'] == 2004 && $_SESSION['ccdf_alt_b']) {
			echo "<br/>(changed sliding fee scale for parents&rsquo; share of costs to {$_SESSION['ccdf_user_input_b']}% of household&rsquo;s total gross income)";
		}
		if($_SESSION['state'] == 'TX' && $_SESSION['year'] == 2004 && $_SESSION['ccdf_alt_c']) {
			echo "<br/>(using updated part-time care fee calculations for Dallas)";
		}
		if($_SESSION['state'] == 'VT' && $_SESSION['year'] == 2008 && $_SESSION['ccdf_alt']) {
			echo "<br/>(using state payment rates as cost of both subsidized and unsubsidized care)";
		}
		if($_SESSION['state'] == 'VT' && $_SESSION['year'] == 2008 && $_SESSION['ccdf_alt_b']) {
			echo "<br/>(using 2010 rules)";
		}
		if($_SESSION['state'] == 'IA' && $_SESSION['year'] == 2008 && $_SESSION['ccdf_alt']) {
			echo "<br/>(increased income eligibility limit)";
		}
		elseif($_SESSION['state'] == 'WA' && $_SESSION['year'] == 2008 && $_SESSION['ccdf_alt']) {
			echo "<br/>(changed income eligibility limit to {$_SESSION['ccdf_user_input']}% of FPL)";
		}
		echo "</li>";
	}
?>
<!-- Food Stamps -->
<?php
	if($_SESSION['fsp']) {
		$benefits_flag = 1;
		echo "<li>SNAP/Food Stamps";
		if($_SESSION['state'] == 'IL' && ($_SESSION['year'] == 2006 || $_SESSION['year'] == 2008)) {
			if($_SESSION['fsp_alt']) { echo "<br />(added a \${$simulator->format($_SESSION['fsp_user_input'])}/month supplemental nutrition allowance)"; }
			if($_SESSION['fsp_alt_b']) { echo "<br />(waived gross income test)"; }
			if($_SESSION['fsp_alt_c']) { echo "<br />(waived asset test)"; }					
		}
		if($_SESSION['state'] == 'IA' && $_SESSION['year'] == 2008) {
			if($_SESSION['fsp_alt_b']) { echo "<br />(waived gross income test)"; }
		}
		if($_SESSION['state'] == 'NM' && $_SESSION['year'] == 2008) {
			if($_SESSION['fsp_alt']) { echo "<br />(waived gross income test for families under 200% FPL)"; }
		}
		if($_SESSION['state'] == 'IA' && $_SESSION['year'] == 2008) {
			if($_SESSION['fsp_alt']) { echo "<br />(increased the gross income limit to 160%FPL and waived the asset test)"; }
		}
		if($_SESSION['state'] == 'WA' && $_SESSION['year'] == 2008) {
			if($_SESSION['fsp_alt']) { echo "<br />(waived gross income and asset tests for families under 200% FPL)"; }
		}
		echo "</li>";
	}
?>

<?php 
if($_SESSION['liheap']) {
  $benefits_flag = 1;
  if($_SESSION['state'] == 'CO') { echo "<li>Low Income Energy Assistance Program (LIHEAP)</li>"; }
  elseif($_SESSION['state'] == 'MT') { echo "<li>Low Income Energy Assistance Program (LIEAP)</li>"; }
  else { echo "<li>LIHEAP</li>"; }
}
?>

<!-- Public Health Insurance -->
<?php
	if($_SESSION['hlth']) {
		$benefits_flag = 1;
		echo "<li>Public Health Insurance";
		if($_SESSION['state'] == 'CT' && $_SESSION['year'] == 2005) {
			if($_SESSION['hlth_alt']) { echo "<br />(added premiums of \${$simulator->format($_SESSION['hlth_user_input'])}/month per parent when family income is above 100% FPL)"; }
		}
		elseif($_SESSION['state'] == 'IL' && ($_SESSION['year'] == 2006 || $_SESSION['year'] == 2008) && $simulator->alternates()) {
			if($_SESSION['hlth_alt']) { echo "<br />(changed maximum monthly child care expense deduction to \${$simulator->format($_SESSION['hlth_user_input'])} per child)"; }
			if($_SESSION['hlth_alt_b'] == 1) { echo "<br />(disregarded all child support income received)"; }
			elseif($_SESSION['hlth_alt_b'] == 0 && $_SESSION['hlth_user_input_b'] > 0) { echo "<br />(added a child support income disregard of \${$simulator->format($_SESSION['hlth_user_input_b'])}/month)"; }
		}
		elseif($_SESSION['state'] == 'WA' && $_SESSION['hlth_alt']) {
			echo "<br />(selected Washington Basic Health)";
			if($_SESSION['hlth_alt_b']) {
				echo "<br />(Decreased income eligibility limit to " . $_SESSION['hlth_user_input_b'] . "% FPL)";
			}
		}
		elseif($_SESSION['state'] == 'VT' && $_SESSION['hlth_alt']) {
			echo "<br />(selected Catamount Health Assistance Program)";
		}
		elseif($_SESSION['state'] == 'IA' && $_SESSION['hlth_alt']) {
			echo "<br />(selected IowaCare)";
		}
		elseif($_SESSION['state'] == 'NM') {
			if($_SESSION['hlth_sci']) {
				echo "<br />(selected State Coverage Insurance)";
			}
			if($_SESSION['hlth_pak']) {
				echo "<br />(selected Premium Assistance for Kids)";
			}
		}
		elseif($_SESSION['state'] == 'DE' && $_SESSION['hlth_alt']) {
			echo "<br />(increased SCHIP income limit to 300% FPL)";
		}
		elseif($_SESSION['state'] == 'ND' && $_SESSION['hlth_alt']) {
      echo "<br />(changed SCHIP to " . $_SESSION['hlth_user_input'] . "% FPL)";
		}
		elseif($_SESSION['state'] == 'NJ' && $_SESSION['year'] == 2010 && $_SESSION['hlth_alt']) {
      echo "<br />(changed parents' income eligibility threshold to " . $_SESSION['hlth_user_input'] . "% FPL)";
		}
		elseif($_SESSION['state'] == 'MS') {
		  if($_SESSION['hlth_alt']) {
        echo "<br />(changed gross and net income for Medicaid to " . $_SESSION['hlth_user_input'] . "% of current limits)";
		  }
		  if($_SESSION['hlth_alt_b']) {
        echo "<br />(changed monthly employment disregard to $" . $_SESSION['hlth_user_input_b'] . ")";
		  }
		  if($_SESSION['hlth_alt_c']) {
        echo "<br />(changed maximum monthly child care expense deduction to $" . $_SESSION['hlth_user_input_c'] . " per child)";
		  }
		  if($_SESSION['hlth_alt_d']) {
        echo "<br />(changed income eligibility limit to " . $_SESSION['hlth_user_input_d'] . "% of income limit)";
		  }
		}
		echo "</li>";
	}
?>
<!-- Section 8 Housing Vouchers -->
<?php
	if($_SESSION['sec8']) {
		$benefits_flag = 1;
		echo "<li>Section 8 Housing Vouchers</li>";
	}
?>

<!-- MRVP (Massachusetts) -->
<?php if($_SESSION['mrvp']) {	
  echo "<li>Massachusetts Rental Voucher Program (MRVP)"; 
	if($_SESSION['mrvp_alt']) { echo "<br />(offered a $500 per dependent deduction)"; }
	if($_SESSION['mrvp_alt_b']) { echo "<br />(offered an earned income deduction of 10 percent of first $9,000 in earned income up to $900)"; }
	if($_SESSION['mrvp_alt_c']) { echo "<br />(changed eligibility to \${$simulator->format($_SESSION['mrvp_alt_value_c'])} percent of the area median income)"; }
	if($_SESSION['mrvp_alt_d']) { echo "<br />(used federal Section 8 fair market rent standards in place of existing MRVP rent standards for the maximum rent)"; }
	echo "</li>";
} ?>


<!-- TANF -->
<?php
	if($_SESSION['tanf']) {
		$benefits_flag = 1;
		echo "<li>TANF Cash Assistance";
		if($_SESSION['state'] == 'IL' && ($_SESSION['year'] == 2006 || $_SESSION['year'] == 2008)) {
			if($_SESSION['tanf_alt']) { echo "<br />(increased maximum TANF payment by {$_SESSION['tanf_user_input']}%)"; }
			if($_SESSION['tanf_alt_b']) { echo "<br />(changed TANF earnings disregard to {$_SESSION['tanf_user_input_b']}% of earnings)"; }
			if($_SESSION['tanf_alt_c']) { echo "<br />(changed parents' wage rate to \${$simulator->format($_SESSION['tanf_user_input_c'])}/hour)"; }
		}
		if($_SESSION['state'] == 'MA' && ($_SESSION['year'] == 2009)) {
			if($_SESSION['tanf_alt']) { echo "<br />(Eliminated gross income test)"; }
			if($_SESSION['tanf_alt_b']) { echo "<br />(Increased child support disregard/pass-through to $100 for one child and $200 for two or more)"; }
		}
		echo "</li>";
	}
?>
<?php if($_SESSION['tanf'] && $_SESSION['state'] == 'DC' && $_SESSION['year'] == 2017) { ?> <!-- added block 6/13-->
	<ul>
		<?php if(empty($_SESSION['sanctioned']) and empty($_SESSION['tanfwork']) and empty($_SESSION['travelstipends']) and empty($_SESSION['workbonuses'])) { ; }
		else {?>
		<li>
		Family  <?php ; } ?>
		<?php if(empty($_SESSION['sanctioned'])) { ; } #removed echo sanctioned language. Not sure why that was there.
				else {?>
		faces sanctions,   <?php ; } ?>
		<?php if(empty($_SESSION['tanfwork'])) { ; }
				else {?>
		satisfies work requirements, <?php ; } ?>
		
		<?php if(empty($_SESSION['travelstipends'])) { ;} 
				else {?>
		is eligible for travel stipends, <?php ; } ?>
		<?php if(empty($_SESSION['workbonuses']) || empty($_SESSION['tanfwork']) || ($_SESSION['sanctioned'])) {;}
				else {?>
		is eligible for work bonuses. <?php ;} ?>

		</li>
		 
		<?php if( empty($_SESSION['tanfentryreq']) ){ ; }
		else {?>
		<li>
		TANF benefit calculated using program entry rules. <?php ;} ?>
		</li>
		<?php if( empty($_SESSION['workexpense_ded_alt']) ){ ; }
		else {?>
		<li>
		The work expense deduction is modeled at $<?php echo $_SESSION['workexpense_ded_user_input'] ?>. <?php ; } ?>
		</li> 
		
		<?php if( empty($_SESSION['earnedincome_dis_alt']) ){ ; }
		else {?>
		<li>
		The earned income disregard is modeled at <?php echo $_SESSION['earnedincome_dis_user_input'] ?>%. <?php ; } ?>
		</li>
		
		<?php if( empty($_SESSION['tanf_perchild_cc_ded_alt']) ){ ; }
		else {?>
		<li>
		The dependent care deduction for incapacitated adults or children age 2 or older is modeled at $<?php echo $_SESSION['tanf_perchild_cc_ded_user_input'] ?>. <?php ;} ?>
		</li>
		<?php if(empty($_SESSION['tanf_perchild0or1_cc_ded_alt']) ){ ; }
		else {?>
		<li>
		The dependent care deduction for children age 2 or younger is modeled at $<?php echo $_SESSION['tanf_perchild0or1_user_input'] ?>. <?php ;} ?>
		
		</li>	
	</ul>
<?php } ?>
<!-- EITC -->
<?php
	if($_SESSION['eitc']) {
		echo "<li>Federal Earned Income Tax Credit (EITC)";
		if($_SESSION['state'] == 'CT' && $_SESSION['year'] == 2005 && $_SESSION['eitc_alt']) {
			echo "<br/>(added State EITC at {$_SESSION['eitc_user_input']}% of federal)";
		}
		if($_SESSION['state'] == 'WA' && $_SESSION['year'] == 2008 && $_SESSION['eitc_alt']) {
			echo "<br/>(added State EITC at {$_SESSION['eitc_user_input']}% of federal)";
		}
		if($_SESSION['state'] == 'CO' && $_SESSION['eitc_alt']) {
			echo "<br/>(added State EITC at {$_SESSION['eitc_user_input']}% of federal)";
		}
		if($_SESSION['state'] == 'LA' && $_SESSION['year'] == 2007 && $_SESSION['eitc_alt']) {
			echo "<br/>(added State EITC at {$_SESSION['eitc_user_input']}% of federal)";
		}
		echo "</li>";
	}
?>
<!-- Federal Child Tax Credit -->
<?php
	if($_SESSION['ctc']) {
		echo "<li>Federal Child Tax Credit Refund</li>";
	}
?>
<!-- CADC -->
<?php
	if($_SESSION['cadc']) {
		echo "<li>Federal Child and Dependent Care Tax Credit</li>";
	}
?>
<!-- MWP -->
<?php
	if($_SESSION['mwp']) {
		echo "<li>Making Work Pay Tax Credit</li>";
	}
?>
<!-- State EITC -->
<?php
	if($_SESSION['state_eitc'] || ($_SESSION['state'] == 'MT' && $_SESSION['eitc_alt'])) { 
		echo "<li>State Earned Income Tax Credit (EITC)";
		if($_SESSION['state'] == 'IA' && $_SESSION['year'] == 2008 && $_SESSION['eitc_alt']) {
			echo "<br/>(changed state EITC to {$_SESSION['eitc_user_input']}% of federal EITC)";
		} elseif($_SESSION['state'] == 'NM' && $_SESSION['year'] == 2008 && $_SESSION['eitc_alt']) {
			echo "<br/>(changed state EITC to {$_SESSION['eitc_user_input']}% of federal EITC)";
		} elseif($_SESSION['state'] == 'DE' && $_SESSION['year'] == 2009 && $_SESSION['eitc_alt']) {
			echo "<br/>(changed to refundable credit at {$_SESSION['eitc_user_input']}% of federal)";
		}
		echo "</li>";
	}
?>
<!-- State CTC -->
<?php
	if($_SESSION['state_ctc']) {
		echo "<li>State Child Tax Credit</li>";
	}
?>
<!-- State CADC -->
<?php
	if($_SESSION['state_cadc']) {
		echo "<li>State Child and Dependent Care Tax Credit";
		if($_SESSION['state'] == 'VT' && $_SESSION['cadc_alt']) {
			echo "<br/>(Care qualifies for refundable credit)";
		}
		if($_SESSION['state'] == 'DE' && $_SESSION['cadc_alt']) {
			echo "<br/>(changed to refundable credit)";
		}
		if($_SESSION['state'] == 'CO' && $_SESSION['cadc_alt']) {
			echo "<br/>(used potential federal credit to calculate state child care credit)";
		}
		echo "</li>";
	}
?>
<!-- Lifeline -->
<?php
	if($_SESSION['lifeline']) {
		$benefits_flag = 1;
		echo "<li>Lifeline</li>";
	}
?>
<!-- Premium Tax Credit -->
<?php
	if($_SESSION['premium_tax_credit']) {
		echo "<li>Premium Tax Credit</li>";
	}
?>
<!-- Home Energy Assistance Program (HEAP) -->
<?php
	if($_SESSION['heap']) {
		echo "<li>Home Energy Assistance Program (HEAP)</li>";
	}
?>
<!-- State child care credit -->
<?php
	if($_SESSION['cc_credit']) {
		echo "<li>Refundable state child care tax credit";
		if($_SESSION['income_minimum'] == 'none') { echo "<br/>(no minimum income requirement)"; }
		elseif($_SESSION['income_minimum'] == 'ccap_limit') { echo "<br />(minimum income requirement equal to CCAP income limit)"; }
		echo "<br />(\${$simulator->format($_SESSION['cc_credit_maximum_under3'])}/year maximum credit for each child under 3; \${$simulator->format($_SESSION['cc_credit_maximum_3andup'])}/year maximum credit for each child 3 and up)";
		echo "</li>";
	}
?>
<!-- Renter Rebate (VT) -->
<?php
	if($_SESSION['renter_credit']) {
		echo '<li>State Renter Rebate</li>';
	}
?>
<!-- School Readiness Credit (LA) -->
<?php
	if($_SESSION['school_readiness']) {
		echo '<li>School Readiness Credit: children enrolled in a Quality Start center with ' . $_SESSION['star_rating'] . ' stars</li>';
	}
?>
<!-- Local EITC -->
<?php
	if($_SESSION['local_eitc']) { echo "<li>Local Earned Income Tax Credit (EITC)</li>"; }
?>
<!-- Local CADC -->
<?php
	if($_SESSION['local_cadc']) {
		echo "<li>Local Child Care Tax Credit</li>";
	}
?>
<!-- Afterschool  -->
<?php
	if($_SESSION['ostp']) {
		$benefits_flag = 1;
		echo "<li>Afterschool (Out of School Time Program) </li>";
	}
?>	

<!-- Women, Infants, and Children (WIC)  -->
<?php
	if($_SESSION['wic']) {
		$benefits_flag = 1;
		if ($_SESSION['breastfeeding'] == 1 && ( $_SESSION['child1_age'] == 0 ||  $_SESSION['child2_age'] == 0 ||  $_SESSION['child3_age'] == 0 || $_SESSION['child4_age'] == 0 || $_SESSION['child5_age'] == 0)) {
			echo "<li>Special Supplemental Nutrition Program for Women, Infants, and Children (WIC), incorporating that the mother breasfeeds her infant</li>";
		} else {
			echo "<li>Special Supplemental Nutrition Program for Women, Infants, and Children (WIC)</li>";

		}
	}
?>	


<!-- National School Breakfast Program (NSBP)  -->
<?php
		if($_SESSION['nsbp']) {
		$benefits_flag = 1;
		echo "<li> National School Breakfast Program (NSBP) </li>";
	}
?>	

<!-- National School Lunch Program (NSLP)   -->
<?php
		if($_SESSION['frpl']) {
		$benefits_flag = 1;
		echo "<li> National School Lunch Program (NSLP)  </li>";
	}
?>	

<!-- Free Summer Meals Program (FSMP)  -->
<?php
		if($_SESSION['fsmp']) {
		$benefits_flag = 1;
		echo "<li> Free Summer Meals Program (FSMP) </li>";
	}
?>	

<!-- Supplemental Security Income -->
<?php
	if($_SESSION['ssi']) {
		$benefits_flag = 1;
		echo "<li>Supplemental Security Income (SSI)</li>";
	}
?>

<!-- Pre-Kindergarten (PreK) -->
<?php
	if($_SESSION['prek']) {
		$benefits_flag = 1;
		echo "<li>Pre-Kindergarten (PreK)</li>";
	}
?>


<!-- Extras -->
<?php
	if($_SESSION['state'] == 'CT' && $_SESSION['year'] == 2005 && $_SESSION['tanf']) {
        echo "<strong>Note:</strong> Simulator applies TANF eligibility rules that apply before families hit Connecticut&rsquo;s 21-month time limit; families who reapply after 21 months face stricter eligibility criteria.";
	}
	if($_SESSION['state'] == 'MI' && $_SESSION['year'] == 2006 && $simulator->alternates()) {
		if($_SESSION['cadc_alt']) {
			if($_SESSION['cadc_alt_b']) {
				echo '<li>Expanded CDCTC</li>';
			}
			else {
				echo '<li>Set CDCTC to zero</li>';
			}
		}
		if($_SESSION['ctc_alt']) {
			echo '<li>Applied policy changes to CTC: <br/>';
			echo $_SESSION['ctc_alt_value_a'] . ' for child 1 and 2 if child care is subsidized,<br/>';
			echo $_SESSION['ctc_alt_value_b'] . ' for child 3 if child care is subsidized,<br/>';
			echo $_SESSION['ctc_alt_value_c'] . ' for child 1 and 2 if child care is not subsidized,<br/>';
			echo $_SESSION['ctc_alt_value_d'] . ' for child 3 if child care is not subsidized<br/>';
		}
	}


?>
</ul>
<?php if ($benefits_flag == 0) { ?>
No benefits, except for tax credits<br/>
<?php } ?>
