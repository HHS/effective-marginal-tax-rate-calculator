<script type="text/javascript">
Validation.add('validate-nonnegative','Value cannot be blank or less than 0', function(v,e) {
	if(Number(v) < 0 || v == "") {
		return false
	}
	return true;
});

Validation.add('validate-day','There are only 24 hours in a day. Please enter a number up to 24.', function(v,e) {
	if(Number(v) > 24) {
		return false
	}
	return true;
});

Validation.add('validate-nontrad-day','There are only 10 hours in this evening or morning time period. Please enter a number up to 10.', function(v,e) {
	if(Number(v) > 10) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-initial-1','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_hours_child1')) + Number($F('day2_hours_child1')) + Number($F('day3_hours_child1')) + Number($F('day4_hours_child1')) + Number($F('day5_hours_child1')) > 0) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-initial-2','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_hours_child2')) + Number($F('day2_hours_child2')) + Number($F('day3_hours_child2')) + Number($F('day4_hours_child2')) + Number($F('day5_hours_child2')) > 0) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-initial-3','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_hours_child3')) + Number($F('day2_hours_child3')) + Number($F('day3_hours_child3')) + Number($F('day3_hours_child1')) + Number($F('day3_hours_child1')) > 0) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-initial-4','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_hours_child4')) + Number($F('day2_hours_child4')) + Number($F('day3_hours_child4')) + Number($F('day4_hours_child4')) + Number($F('day5_hours_child4')) > 0) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-initial-5','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_hours_child5')) + Number($F('day2_hours_child5')) + Number($F('day3_hours_child5')) + Number($F('day4_hours_child5')) + Number($F('day5_hours_child5')) > 0) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-future-1','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_future_hours_child1')) + Number($F('day2_future_hours_child1')) + Number($F('day3_future_hours_child1')) + Number($F('day4_future_hours_child1')) + Number($F('day5_future_hours_child1')) > 0) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-future-2','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_future_hours_child2')) + Number($F('day2_future_hours_child2')) + Number($F('day3_future_hours_child2')) + Number($F('day4_future_hours_child2')) + Number($F('day5_future_hours_child2')) > 0) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-future-3','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_future_hours_child3')) + Number($F('day2_future_hours_child3')) + Number($F('day3_future_hours_child3')) + Number($F('day4_future_hours_child3')) + Number($F('day5_future_hours_child3')) > 0) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-future-4','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_future_hours_child4')) + Number($F('day2_future_hours_child4')) + Number($F('day3_future_hours_child4')) + Number($F('day4_future_hours_child4')) + Number($F('day5_future_hours_child4')) > 0) {
		return false
	}
	return true;
});

Validation.add('validate-schoolage-future-5','If you enter in hours from Monday to Friday for school-age children, you cannot select "none" for the type of care during school days.', function(v,e) {
	if(v == "none" && Number($F('day1_future_hours_child5')) + Number($F('day2_future_hours_child5')) + Number($F('day3_future_hours_child5')) + Number($F('day4_future_hours_child5')) + Number($F('day5_future_hours_child5')) > 0) {
		return false
	}
	return true;
});

for (let d = 1; d < 5; d++) {

	Validation.add('validate-childcarehours-'.concat([d]),'You must enter in at least some child care hours below in order for the calculator to include these child care costs in its calculations. If you are using the calculator to estimate child care costs, please enter 0 here.', function(v,e) {
		<?php if(($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') && ($_SESSION['nontraditionalwork'] == 1 || (($_SESSION['state'] == 'NH' || $_SESSION['state'] == 'PA' || $_SESSION['state'] == 'ME') && $_SESSION['demo'] == 0)) && ($_SESSION['schoolage_children_under13'] > 0)) { #This is the beginning of a fairly complicated JavaScript in which we need to adjust the validation lookups depending on the variables generated on this same page. There are 8 (2 cubed) permutations here, because the child care hour quetsions depend on (1) whether we need to ask about future care due to changes in hours worked, (2) whether we need to ask about nontraditional hours, and (3) whether we need to ask about school hours. Notable is that because some states require checks for nontraditional work and others don't, we need to invoke state names here, tenratively. It would likely be easier if we created an intermediary varibale such as "nontraditional_cc_state" that we could use here instead, but just using the state names for the time being. These eight permutations are below. To help keep track of them, the sequence of Y's or N's included as comments indicate which, if any, of these three possibilities are true. To start, we begin with the most expansive permutation, indicated as YYY ?>
			if(v > 0 && Number($F('day1_hours_child'.concat([d]))) + Number($F('day2_hours_child'.concat([d]))) + Number($F('day3_hours_child'.concat([d]))) + Number($F('day4_hours_child'.concat([d]))) + Number($F('day5_hours_child'.concat([d]))) + Number($F('day6_hours_child'.concat([d]))) + Number($F('day7_hours_child'.concat([d]))) + Number($F('summerday1_hours_child'.concat([d]))) + Number($F('summerday2_hours_child'.concat([d]))) + Number($F('summerday3_hours_child'.concat([d]))) + Number($F('summerday4_hours_child'.concat([d]))) + Number($F('summerday5_hours_child'.concat([d]))) + Number($F('summerday6_hours_child'.concat([d]))) + Number($F('summerday7_hours_child'.concat([d]))) + Number($F('day1_future_hours_child'.concat([d]))) + Number($F('day2_future_hours_child'.concat([d]))) + Number($F('day3_future_hours_child'.concat([d]))) + Number($F('day4_future_hours_child'.concat([d]))) + Number($F('day5_future_hours_child'.concat([d]))) + Number($F('day6_future_hours_child'.concat([d]))) + Number($F('day7_future_hours_child'.concat([d]))) + Number($F('summerday1_future_hours_child'.concat([d]))) + Number($F('summerday2_future_hours_child'.concat([d]))) + Number($F('summerday3_future_hours_child'.concat([d]))) + Number($F('summerday4_future_hours_child'.concat([d]))) + Number($F('summerday5_future_hours_child'.concat([d]))) + Number($F('summerday6_future_hours_child'.concat([d]))) + Number($F('summerday7_future_hours_child'.concat([d])))== 0) {
				return false
			}
			return true;
		<?php } else if (($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') && ($_SESSION['nontraditionalwork'] == 1 || (($_SESSION['state'] == 'NH' || $_SESSION['state'] == 'PA' || $_SESSION['state'] == 'ME') && $_SESSION['demo'] == 0))) { #Permutation YYN ?>
			if(v > 0 && Number($F('day1_hours_child'.concat([d]))) + Number($F('day2_hours_child'.concat([d]))) + Number($F('day3_hours_child'.concat([d]))) + Number($F('day4_hours_child'.concat([d]))) + Number($F('day5_hours_child'.concat([d]))) + Number($F('day6_hours_child'.concat([d]))) + Number($F('day7_hours_child'.concat([d]))) + Number($F('day1_future_hours_child'.concat([d]))) + Number($F('day2_future_hours_child'.concat([d]))) + Number($F('day3_future_hours_child'.concat([d]))) + Number($F('day4_future_hours_child'.concat([d]))) + Number($F('day5_future_hours_child'.concat([d]))) + Number($F('day6_future_hours_child'.concat([d]))) + Number($F('day7_future_hours_child'.concat([d]))) == 0) {
				return false
			}
			return true;
		<?php } else if(($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') && ($_SESSION['schoolage_children_under13'] > 0)) { #Permutation YNY?>
			if(v > 0 && Number($F('day1_hours_child'.concat([d]))) + Number($F('day2_hours_child'.concat([d]))) + Number($F('day3_hours_child'.concat([d]))) + Number($F('day4_hours_child'.concat([d]))) + Number($F('day5_hours_child'.concat([d]))) + Number($F('summerday1_hours_child'.concat([d]))) + Number($F('summerday2_hours_child'.concat([d]))) + Number($F('summerday3_hours_child'.concat([d]))) + Number($F('summerday4_hours_child'.concat([d]))) + Number($F('summerday5_hours_child'.concat([d]))) + Number($F('day1_future_hours_child'.concat([d]))) + Number($F('day2_future_hours_child'.concat([d]))) + Number($F('day3_future_hours_child'.concat([d]))) + Number($F('day4_future_hours_child'.concat([d]))) + Number($F('day5_future_hours_child'.concat([d]))) + Number($F('summerday1_future_hours_child'.concat([d]))) + Number($F('summerday2_future_hours_child'.concat([d]))) + Number($F('summerday3_future_hours_child'.concat([d]))) + Number($F('summerday4_future_hours_child'.concat([d]))) + Number($F('summerday5_future_hours_child'.concat([d]))) == 0) {
				return false
			}
			return true;
		<?php } else if(($_SESSION['nontraditionalwork'] == 1 || (($_SESSION['state'] == 'NH' || $_SESSION['state'] == 'PA' || $_SESSION['state'] == 'ME') && $_SESSION['demo'] == 0)) && ($_SESSION['schoolage_children_under13'] > 0)) { #Permutation NYY?>
			if(v > 0 && Number($F('day1_hours_child'.concat([d]))) + Number($F('day2_hours_child'.concat([d]))) + Number($F('day3_hours_child'.concat([d]))) + Number($F('day4_hours_child'.concat([d]))) + Number($F('day5_hours_child'.concat([d]))) + Number($F('day6_hours_child'.concat([d]))) + Number($F('day7_hours_child'.concat([d]))) + Number($F('summerday1_hours_child'.concat([d]))) + Number($F('summerday2_hours_child'.concat([d]))) + Number($F('summerday3_hours_child'.concat([d]))) + Number($F('summerday4_hours_child'.concat([d]))) + Number($F('summerday5_hours_child'.concat([d]))) + Number($F('summerday6_hours_child'.concat([d]))) + Number($F('summerday7_hours_child'.concat([d]))) == 0) {
				return false
			}
			return true;
		<?php } else if(($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both')) { #Permutation YNN?>
			if(v > 0 && Number($F('day1_hours_child'.concat([d]))) + Number($F('day2_hours_child'.concat([d]))) + Number($F('day3_hours_child'.concat([d]))) + Number($F('day4_hours_child'.concat([d]))) + Number($F('day5_hours_child'.concat([d]))) + Number($F('day1_future_hours_child'.concat([d]))) + Number($F('day2_future_hours_child'.concat([d]))) + Number($F('day3_future_hours_child'.concat([d]))) + Number($F('day4_future_hours_child'.concat([d]))) + Number($F('day5_future_hours_child'.concat([d])))  == 0) {
				return false
			}
			return true;
		<?php } else if(($_SESSION['nontraditionalwork'] == 1 || (($_SESSION['state'] == 'NH' || $_SESSION['state'] == 'PA' || $_SESSION['state'] == 'ME') && $_SESSION['demo'] == 0))) { #Permutation NYN?>
			if(v > 0 && Number($F('day1_hours_child'.concat([d]))) + Number($F('day2_hours_child'.concat([d]))) + Number($F('day3_hours_child'.concat([d]))) + Number($F('day4_hours_child'.concat([d]))) + Number($F('day5_hours_child'.concat([d]))) + Number($F('day6_hours_child'.concat([d]))) + Number($F('day7_hours_child'.concat([d]))) == 0) {
				return false
			}
			return true;
		<?php } else if(($_SESSION['schoolage_children_under13'] > 0)) { #Permutation NNY ?>
			if(v > 0 && Number($F('day1_hours_child'.concat([d]))) + Number($F('day2_hours_child'.concat([d]))) + Number($F('day3_hours_child'.concat([d]))) + Number($F('day4_hours_child'.concat([d]))) + Number($F('day5_hours_child'.concat([d]))) + Number($F('summerday1_hours_child'.concat([d]))) + Number($F('summerday2_hours_child'.concat([d]))) + Number($F('summerday3_hours_child'.concat([d]))) + Number($F('summerday4_hours_child'.concat([d]))) + Number($F('summerday5_hours_child'.concat([d]))) == 0) {
				return false
			}
			return true;
		<?php } else { #Permutation NNN ?>
			if(v > 0 && Number($F('day1_hours_child'.concat([d]))) + Number($F('day2_hours_child'.concat([d]))) + Number($F('day3_hours_child'.concat([d]))) + Number($F('day4_hours_child'.concat([d]))) + Number($F('day5_hours_child'.concat([d]))) == 0) {
				return false
			}
			return true;
		<?php }  ?>

	});
}

for (let c = 1; c < 5; c++) {
	Validation.add('validate-nontrad-hours-'.concat([c]),'The number of nontraditional hours cannot exceed the total number of child care needed in a day.', function(v,e) {
		if(v > 0 && (Number($F('day1_hours_child'.concat([c]))) < Number($F('day1_nontrad_hours_child'.concat([c]))) || Number($F('day2_hours_child'.concat([c]))) < Number($F('day2_nontrad_hours_child'.concat([c]))) || Number($F('day3_hours_child'.concat([c]))) < Number($F('day3_nontrad_hours_child'.concat([c]))) || Number($F('day4_hours_child'.concat([c]))) < Number($F('day4_nontrad_hours_child'.concat([c]))) || Number($F('day5_hours_child'.concat([c]))) < Number($F('day5_nontrad_hours_child'.concat([c]))))) {
			return false
		}
		return true;
	});

	Validation.add('validate-nontrad-future-hours-'.concat([c]),'The number of nontraditional hours cannot exceed the total number of child care needed in a day.', function(v,e) {
		if(v > 0 && (Number($F('day1_future_hours_child'.concat([c]))) < Number($F('day1_nontrad_future_hours_child'.concat([c]))) || Number($F('day2_future_hours_child'.concat([c]))) < Number($F('day2_nontrad_future_hours_child'.concat([c]))) || Number($F('day3_future_hours_child'.concat([c]))) < Number($F('day3_nontrad_future_hours_child'.concat([c]))) || Number($F('day4_future_hours_child'.concat([c]))) < Number($F('day4_nontrad_future_hours_child'.concat([c]))) || Number($F('day5_future_hours_child'.concat([c]))) < Number($F('day5_nontrad_future_hours_child'.concat([c]))))) {
			return false
		}
		return true;
	});

	Validation.add('validate-nontrad-summer-hours-'.concat([c]),'The number of nontraditional hours cannot exceed the total number of child care needed in a day.', function(v,e) {
		if(v > 0 && (Number($F('summerday1_hours_child'.concat([c]))) < Number($F('summerday1_nontrad_hours_child'.concat([c]))) || Number($F('summerday2_hours_child'.concat([c]))) < Number($F('summerday2_nontrad_hours_child'.concat([c]))) || Number($F('summerday3_hours_child'.concat([c]))) < Number($F('summerday3_nontrad_hours_child'.concat([c]))) || Number($F('summerday4_hours_child'.concat([c]))) < Number($F('summerday4_nontrad_hours_child'.concat([c]))) || Number($F('summerday5_hours_child'.concat([c]))) < Number($F('summerday5_nontrad_hours_child'.concat([c]))))) {
			return false
		}
		return true;
	});

	Validation.add('validate-nontrad-summer-future-hours-'.concat([c]),'The number of nontraditional hours cannot exceed the total number of child care needed in a day.', function(v,e) {
		if(v > 0 && (Number($F('summerday1_future_hours_child'.concat([c]))) < Number($F('summerday1_nontrad_future_hours_child'.concat([c]))) || Number($F('summerday2_future_hours_child'.concat([c]))) < Number($F('summerday2_nontrad_future_hours_child'.concat([c]))) || Number($F('summerday3_future_hours_child'.concat([c]))) < Number($F('summerday3_nontrad_future_hours_child'.concat([c]))) || Number($F('summerday4_future_hours_child'.concat([c]))) < Number($F('summerday4_nontrad_future_hours_child'.concat([c]))) || Number($F('summerday5_future_hours_child'.concat([c]))) < Number($F('summerday5_nontrad_future_hours_child'.concat([c]))))) {
			return false
		}
		return true;
	});

}



</script>

<!--
-->

<?php 
$_SESSION['children_under13'] = 0;
$_SESSION['schoolage_children_under13'] = 0;
for($i=1; $i<=$_SESSION['child_number_mtrc']; $i++) {
	if($_SESSION['child'.$i.'_age'] <  13) {
		$_SESSION['children_under13']++;
		if($_SESSION['child'.$i.'_age'] > 4) {
			$_SESSION['schoolage_children_under13']++;
		}
	}
} 
// if no selection has been made, defer to the calculator estimates instead of user-entered amounts.

if (!$_SESSION['child_care_continue_estimate_source']) {
	$_SESSION['child_care_continue_estimate_source'] = 'spr';
}

if (!$_SESSION['child_care_nobenefit_estimate_source']) {
	$_SESSION['child_care_nobenefit_estimate_source'] = 'spr';
}

if (!$_SESSION['ccdfpay_estimate_source']) {
	$_SESSION['ccdfpay_estimate_source'] = 'fullcost_ccdf';
}
?>

<?php #For now, we're using the user_prototype varible in order to use generic names for types of care provided. As we identify which child care settings to model based on jurisdiction, we will populate the database with local terms. But for now, for user testing, we are going to use generic names, and this variable will allow us to do that. ?>
<br/>
<?php if($_SESSION['child_number_mtrc'] == 0) { ?> 
<h3>There are no children in your household. Please click the "Save & Next" button.</h3>
<?php } else if ($_SESSION['children_under13'] == 0) { ?> 
<h3>There are no children in your household under 13. Please click the "Save & Next" button.</h3>
<?php } else if($_SESSION['ccdf']) { ?>	
	
	<h3><!--You said that you currently receive child care subsidies. Please provide some additional details about that:-->  <?php //echo $notes_table->add_note('page5_withbenefit_setting'); echo $help_table->add_help('page5_withbenefit_setting'); ?></h3>
	<label>What type of child care is each child in?</label>
	<table>
	<?php for($i=1; $i<=$_SESSION['child_number']; $i++) { ?>
		<?php if($_SESSION["child{$i}_age"] > -1) { ?>
		    <tr>
		        <td >
		        	<?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
		        </td>
		        <?php if($simulator->child_eligible($i)) { ?>
		            <td>
		                <select name="child<?php echo $i ?>_withbenefit_setting">
							<?php if ($_SESSION['user_prototype'] == 1 && $_SESSION['state'] == 'KY' ) { ?> <!--this following block of code is never active for MTRC's since KY was just the basis for which we built some of this code, but keeping in here in case the hard-coding of child care settings is useful down the line.-->
		                        <option value="Licensed Type 1 Provider" <?php if($_SESSION["child{$i}_withbenefit_setting"] == 'type_1') echo 'selected' ?>>Child Care Center</option>
		                        <option value="Certified Family Child Care Home" <?php if($_SESSION["child{$i}_withbenefit_setting"] == 'certified_home') echo 'selected' ?>>Child Care Home</option>
		                        <option value="Registered Provider (family, friend, or neighbor)" <?php if($_SESSION["child{$i}_withbenefit_setting"] == 'registered') echo 'selected' ?>>Family, friend, or neighbor</option>							
							<?php } else { ?> 
		                	<?php foreach($simulator->child_care_settings($i) as $s) { ?>
		                        <option value="<?php echo $s['text'] ?>" <?php if($_SESSION["child{$i}_withbenefit_setting"] == $s['text']) echo 'selected' ?>><?php echo $s['text'] ?></option>
								<?php } ?>
							<?php } ?>
		                </select>
		            </td>
		        <?php } else { ?>
		            <td>not eligible for care</td>
		        <?php } ?>
		    </tr>
		<?php } ?>
	<?php } ?>
	</table>
	<br/>
	<?php if ($_SESSION['state'] != 'DC' && $_SESSION['state'] != 'ME') { #DC and Maine do not allow subsidized providers to charge payments beyond co-payments.?>
		<p class="checkset">
			<input type="radio" name="ccdfpay_estimate_source" id="amt_ccdf" value="amt_ccdf" <?php if($_SESSION['ccdfpay_estimate_source'] == 'amt_ccdf') echo 'checked' ?>>
			<label>I want to enter my child care costs. I pay this much out of pocket for child care, including any afterschool programs:</label>
		<table class="indented">
			<?php for($i=1; $i<=$_SESSION['child_number']; $i++) { ?>
				<?php if($_SESSION["child{$i}_age"] > -1) { ?>
					<tr valign="top">
						<td class="copy" align="right" >
							<?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
						</td>
						<?php if($simulator->child_eligible($i)) { ?>
							<td valign="bottom" align="left" class="copy"> 
								$<input class="validate-number <?php echo 'validate-childcarehours-'.$i ?>" id="<?php echo 'child'.$i.'_ccdfpay_amt_m' ?>" enabled_when_checked="amt_ccdf" type="text" name="<?php echo 'child'.$i.'_ccdfpay_amt_m' ?>" value="<?php if (is_null ($_SESSION['child'.$i.'_ccdfpay_amt_m'])) {echo 0;} else {echo $_SESSION['child'.$i.'_ccdfpay_amt_m'];}  ?>" size="3" maxlength="4"> per 
								<label for="<?php echo 'ccdf_payscale'.$i?>"></label>	   
								<select name="<?php echo 'ccdf_payscale'.$i?>" id="<?php echo 'ccdf_payscale'.$i?>" enabled_when_checked="amt_ccdf"> <!--5/20: Changed all these to numeric values (1-24), and ordered them ascendingly.-->
									  <!-- I don't believe families on CCDF can be charged by the hour or by the day. Commenting these options out for now.
									  <option value="hour" <?php ## if($_SESSION['ccdf_payscale'.$i] == 'hour') echo 'selected' ?>>hour</option> 
									  <option value="day" <?php ## if($_SESSION['ccdf_payscale'.$i] == 'day') echo 'selected' ?>>day</option>
									  -->
									  <option value="week" <?php if($_SESSION['ccdf_payscale'.$i] == 'week') echo 'selected' ?>>week</option> 
									  <option value="biweekly" <?php if($_SESSION['ccdf_payscale'.$i] == 'biweekly') echo 'selected' ?>>every two weeks</option> 
									  <option value="month" <?php if($_SESSION['ccdf_payscale'.$i] == 'month') echo 'selected' ?>>month</option> 
									  <option value="year" <?php if($_SESSION['ccdf_payscale'.$i] == 'year') echo 'selected' ?>>year</option> 					 
								</select>
							</td>
						<?php } else { ?>
							<td valign="bottom" class="copy">not eligible for care</td>
						<?php } ?>
					</tr>
				<?php } ?>
			<?php } ?>
		</table>
			<input type="radio" name="ccdfpay_estimate_source" id="fullcost_ccdf" value="fullcost_ccdf" <?php if($_SESSION['ccdfpay_estimate_source'] == 'fullcost_ccdf') echo 'checked' ?>>
			<label>I want the calculator to estimate my child care costs based on type of child care.<?php //echo $notes_table->add_note('page5_continue_setting'); echo $help_table->add_help('page5_continue_setting'); ?></label>
		</p>
	<?php } ?>
	<input type="hidden" name="child1_continue_flag" value="0" />
	<input type="hidden" name="child2_continue_flag" value="0" />
	<input type="hidden" name="child3_continue_flag" value="0" />
	<input type="hidden" name="child4_continue_flag" value="0" />
	<input type="hidden" name="child5_continue_flag" value="0" />

	<br/>
	<!--<h3>Select setting<?php //echo $notes_table->add_note('page5_continue_intro_setting'); ?> or enter cost for unsubsidized child care.<?php //echo $notes_table->add_note('page5_continue_intro'); echo $help_table->add_help('page5_continue_intro'); ?></h3>-->
	<h3>You said you receive child care subsidies. If you lost the child care subsidies, how much would you have to pay for child care? You can enter the cost here or use the calculator's estimate.</h3>
	<p class="checkset">
		<input type="radio" name="child_care_continue_estimate_source" id="amt" value="amt" <?php if($_SESSION['child_care_continue_estimate_source'] == 'amt') echo 'checked' ?>>
		<label>I want to enter the child care costs I would pay. I would pay this much  out of pocket for child care, including any afterschool programs<?php //echo $notes_table->add_note('page5_continue_cost'); echo $help_table->add_help('page5_continue_cost'); ?></label><?php if($_SESSION['state'] == 'ME') { ?><label for="step4_care_flag">. This care </label>
			<select name="step4_care_flag" id="step4_care_flag" enabled_when_checked="amt" >
				<option value="0" <?php if($_SESSION['step4_care_flag'] == 0) echo 'selected' ?>>does not include</option>
				<option value="1" <?php if($_SESSION['step4_care_flag'] == 1) echo 'selected' ?>>includes</option>
			</select>
			care provided by a Step 4 high-quality child care provider (important for tax purposes): 
		<?php } else { ?>: <?php }?>

	<table class="indented">
		<?php for($i=1; $i<=$_SESSION['child_number']; $i++) { ?>
			<?php if($_SESSION["child{$i}_age"] > -1) { ?>
				<tr valign="top">
					<td class="copy" align="right" >
						<?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
					</td>
					<?php if($simulator->child_eligible($i)) { ?>
						<td valign="bottom" align="left" class="copy"> 
							$<input class="validate-number <?php echo 'validate-childcarehours-'.$i ?>" id="child<?php echo $i ?>_continue_amt_m" enabled_when_checked="amt" type="text" name="child<?php echo $i ?>_continue_amt_m" value="<?php echo $_SESSION["child{$i}_continue_amt_m"] ?>" size="3" maxlength="4"> per <!--id used to equal amt_[i], here and for the ccdf overage option, not sure why. I don't think changing this will affect these variables, but leaving this note in here in case that comes up later.-->

						<label for="<?php echo 'cc_continue_payscale'.$i?>"></label> 			   
						<select name="<?php echo 'cc_continue_payscale'.$i?>" id="<?php echo 'cc_continue_payscale'.$i?>" enabled_when_checked="amt"> <!--5/20: Changed all these to numeric values (1-24), and ordered them ascendingly.-->
							  <option value="hour" <?php if($_SESSION['cc_continue_payscale'.$i] == 'hour') echo 'selected' ?>>hour</option> 
							  <option value="day" <?php if($_SESSION['cc_continue_payscale'.$i] == 'day') echo 'selected' ?>>day</option> 
							  <option value="week" <?php if($_SESSION['cc_continue_payscale'.$i] == 'week') echo 'selected' ?>>week</option> 
							  <option value="biweekly" <?php if($_SESSION['cc_continue_payscale'.$i] == 'biweekly') echo 'selected' ?>>every two weeks</option> 
							  <option value="month" <?php if($_SESSION['cc_continue_payscale'.$i] == 'month') echo 'selected' ?>>month</option> 
							  <option value="year" <?php if($_SESSION['cc_continue_payscale'.$i] == 'year') echo 'selected' ?>>year</option> 					 
						</select>

						</td>
					<?php } else { ?>
						<td valign="bottom" class="copy">not eligible for care</td>
					<?php } ?>
				</tr>
			<?php } ?>
		<?php } ?>
		
	</table>
		<input type="radio" name="child_care_continue_estimate_source" id="spr" value="spr" <?php if($_SESSION['child_care_continue_estimate_source'] == 'spr') echo 'checked' ?>>
		<label>I want the calculator to estimate the child care costs I would pay based on type of child care:<?php //echo $notes_table->add_note('page5_continue_setting'); echo $help_table->add_help('page5_continue_setting'); ?></label>
	<table class="indented">
		<?php for($i=1; $i<=$_SESSION['child_number']; $i++) { ?>
			<?php if($_SESSION["child{$i}_age"] > -1) { ?>
				<tr valign="top">
					<td class="copy" align="right" >
						<?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
					</td>
					<?php if($simulator->child_eligible($i)) { ?>
						<td align="left" class="copy"> 
							<select id="continue_setting_<?php echo $i ?>" enabled_when_checked="spr" name="child<?php echo $i ?>_continue_setting">
								<?php if ($_SESSION['user_prototype'] == 1 && $_SESSION['state'] == 'KY' ) { ?> <!--as above, the KY code is not part of any MTRC, but keeping it here to help in case hard-coding is important down the line.-->
									<option value="Licensed Type 1 Provider" <?php if($_SESSION["child{$i}_continue_setting"] == 'type_1') echo 'selected' ?>>Child Care Center</option>
									<option value="Certified Family Child Care Home" <?php if($_SESSION["child{$i}_continue_setting"] == 'certified_home') echo 'selected' ?>>Child Care Home</option>
									<option value="Registered Provider (family, friend, or neighbor)" <?php if($_SESSION["child{$i}_continue_setting"] == 'registered') echo 'selected' ?>>Family, friend, or neighbor</option>							
								<?php } else { ?>
									<?php foreach($simulator->child_care_settings($i) as $s) { ?>
										<option value="<?php echo $s['text'] ?>" <?php if($_SESSION["child{$i}_continue_setting"] == $s['text']) echo 'selected' ?>><?php echo $s['text'] ?></option>
									<?php } ?>
								<?php } ?>
							</select>
						</td>
					<?php } else { ?>
							<td class="copy">not eligible for care</td>
						<?php } ?>
				</tr>
			<?php } ?>
		<?php } ?>
	</table>
	<br/>

<?php } else { ?>
<h3><!--Select setting or enter cost for child care.--></h3>
<?php include("form_5_unsubsidized.php"); ?> <!-- 6/13/18: added semicolon.-->

<?php } ?>

<?php if($_SESSION['user_prototype'] == 1 && $_SESSION['children_under13'] > 0) { #Had formerly included condition of " && ($_SESSION['ccdf'] || $_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both')" here, but corrected later to remove that, since without the child care table, users who do not select CCDf, are not increasing their wages, and wish to use calculator estimates for child care will not be able to select how much child care they need per week, which is essential for the calculator estimates.?>

	<?php if($_SESSION['ccdf'] && ($_SESSION['future_scenario'] == 'wages' || $_SESSION['future_scenario'] == 'none' )) { ?>
		<h3>You said you are currently receiving CCDF subsidies. To help the calculator estimate what changes in child care costs you might experience if you lose CCDF subsidies, please enter how many hours of care each child needs.
	<?php } else if ($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?>
		<h3>Please enter how many hours of care each child needs now and how many hours are needed if a household member works more. 
	<?php } else { #This last possible chunk of explanatory text will show up when future_scenario is either 'wages' or 'none', and ccdf = 0.  ?>
		<h3>If you select above that you want to use the calculator to estimate child care costs, please enter how many hours of care each child needs per week. 
	<?php } ?>
	<?php if ($_SESSION['headstart'] || $_SESSION['earlyheadstart'] || $_SESSION['prek_mtrc']) { ?>If a child is in<?php if ($_SESSION['prek_mtrc']) { ?> Pre-K,<?php } ?> Head Start or Early Head Start, do not count that time here.<?php } ?> If your work hours change from week to week, enter the number of hours for a typical week.</h3>
	<table class="indented">
		<tr valign="top">
			<td class="copy" align="right" >
				
			</td>
			<td valign="bottom" align="right" class="copy"> 
					Hours <?php if ($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?> now <?php } ?> 				 
			</td>
			<?php if($_SESSION['nontraditionalwork'] == 1) { ?>
				<td valign="bottom" align="right" class="copy"> 
						Hours <?php if ($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?> now <?php } ?> <br/>before 5am <br/> or after 7pm
			<?php } ?>
			<?php if($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?>
				<td valign="bottom" align="right" class="copy"> 
						Hours with <br/>new schedule 					 
				</td>
				<?php if($_SESSION['nontraditionalwork'] == 1) { ?>
					<td valign="bottom" align="right" class="copy"> 
							Hours with <br/>new schedule <br/>before 5am <br/>or after 7pm
				<?php } ?>
			<?php } ?>

		</tr>
	
	<?php #If there is a child in the home who is school age and is also of child care age, we capture school-year and non-school year scenarios.
	if ($_SESSION['schoolage_children_under13'] > 0) { ?>
		<tr valign="top">
			<td class="copy" align="right" >
			<b>During the school year:</b>
			</td>
		</tr>
	<?php 
	} ?>	
	<?php for($i=1; $i<=$_SESSION['child_number']; $i++) {
		if($_SESSION['child'.$i.'_age'] > -1 && $_SESSION['child'.$i.'_age'] < 13) { ?>
			<tr valign="top">
				<td class="copy" align="right" >
				<u> Child <?php echo $i ?>, age <?php echo $_SESSION['child'.$i.'_age']?> </u>
			</tr>
			<?php if($_SESSION['child'.$i.'_age'] > 4 && ($_SESSION['state'] == 'NH' ||  $_SESSION['state'] == 'DC')) { ?> <!-- In NH, market rates for school-age children are not dependent on the number of hours of care provided.-->
				<tr valign="top">
				<td class="copy" align="right" >					
				On school days:
				</td>
				<td class="copy" align="right" >
				<label for="<?php echo 'schoolage_care_initial_child'.$i?>"></label>
				<select name="<?php echo 'schoolage_care_initial_child'.$i?>" id="<?php echo 'schoolage_care_initial_child'.$i?>"  class="<?php if (($_SESSION['state'] == 'NH' &&  $_SESSION['child'.$i.'_age'] > 5) || ($_SESSION['state'] == 'DC' &&  $_SESSION['child'.$i.'_age'] > 4)) { echo 'validate-schoolage-initial-'.$i; }?>"> 
					<option value="none" <?php if($_SESSION['schoolage_care_initial_child'.$i] == 'none') echo 'selected' ?>><?php if ($_SESSION['state'] == 'NH' && $_SESSION['child'.$i.'_age'] == 5) { echo 'None, or not yet in Kindergarten';} else { echo 'None';} ?></option> 
					<option value="afterschool" <?php if($_SESSION['schoolage_care_initial_child'.$i] == 'afterschool') echo 'selected' ?>>After school</option> 
					<option value="beforeschool" <?php if($_SESSION['schoolage_care_initial_child'.$i] == 'beforeschool') echo 'selected' ?>>Before school</option> 
					<option value="bandaschool" <?php if($_SESSION['schoolage_care_initial_child'.$i] == 'bandaschool') echo 'selected' ?>>Before and after school</option> 
					<?php if($_SESSION['nontraditionalwork'] == 1 || ($_SESSION['state'] == 'NH' && $_SESSION['demo'] == 0)) { ?>
						<option value="nontraditional" <?php if($_SESSION['schoolage_care_initial_child'.$i] == 'nontraditional') echo 'selected' ?>>Before 5am or after 7pm</option> 
					<?php } ?>
					</select>
				</td>
				<?php if($_SESSION['nontraditionalwork'] == 1) { #Skipping a column in this intance, for alignment purposes ?> 
					<td>
					</td>
				<?php } ?>					
				<?php if($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?>
					<td class="copy" align="right" >
					<label for="<?php echo 'schoolage_care_future_child'.$i?>"></label>
					<select name="<?php echo 'schoolage_care_future_child'.$i?>" id="<?php echo 'schoolage_care_future_child'.$i?>" class="<?php if (($_SESSION['state'] == 'NH' &&  $_SESSION['child'.$i.'_age'] > 5) || ($_SESSION['state'] == 'DC' &&  $_SESSION['child'.$i.'_age'] > 4)) { echo 'validate-schoolage-future-'.$i; }?>"> 
						<option value="none" <?php if($_SESSION['schoolage_care_future_child'.$i] == 'none') echo 'selected' ?>><?php if ($_SESSION['state'] == 'NH' && $_SESSION['child'.$i.'_age'] == 5) { echo 'None, or not yet in Kindergarten';} else { echo 'None';} ?></option> 
						<option value="afterschool" <?php if($_SESSION['schoolage_care_future_child'.$i] == 'afterschool') echo 'selected' ?>>After school</option> 
						<option value="beforeschool" <?php if($_SESSION['schoolage_care_future_child'.$i] == 'beforeschool') echo 'selected' ?>>Before school</option> 
						<option value="bandaschool" <?php if($_SESSION['schoolage_care_future_child'.$i] == 'bandaschool') echo 'selected' ?>>Before and after school</option> 
						<?php if($_SESSION['nontraditionalwork'] == 1 || ($_SESSION['state'] == 'NH' && $_SESSION['demo'] == 0)) { ?>
							<option value="nontraditional" <?php if($_SESSION['schoolage_care_future_child'.$i] == 'nontraditional') echo 'selected' ?>>Before 5am or after 7pm</option> 
						<?php } ?>
						</select>
					</td>
				<?php } ?>
				</tr>
			<?php } ?>
			<?php for($j=1; $j<=5; $j++) { ?>
				<tr valign="top">
					<td class="copy" align="right" >
					<?php if ($j==1) { ?>
						Monday: 
					<?php } else if ($j==2) { ?>
						Tuesday: 
					<?php } else if ($j==3) { ?>
						Wednesday: 
					<?php } else if ($j==4) { ?>
						Thursday: 
					<?php } else if ($j==5) { ?>
						Friday: 
					<?php } ?>
					</td>
					<td valign="bottom" align="right" class="copy"> 
					<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'day'.$j.'_hours_child'.$i?>" name="<?php echo 'day'.$j.'_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['day'.$j.'_hours_child'.$i])) {echo 0;} else {echo $_SESSION['day'.$j.'_hours_child'.$i];} ?>">
					<?php if($_SESSION['nontraditionalwork'] == 1) { #Had  && $_SESSION['child'.$i.'_age'] <=4) here, not sure why.?>
						<td valign="bottom" align="right" class="copy"> 
						<input class="validate-number validate-nonnegative validate-nontrad-day <?php echo 'validate-nontrad-hours-'.$i?>" type="text" id="<?php echo 'day'.$j.'_nontrad_hours_child'.$i?>" name="<?php echo 'day'.$j.'_nontrad_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['day'.$j.'_nontrad_hours_child'.$i])) {echo 0;} else {echo $_SESSION['day'.$j.'_nontrad_hours_child'.$i];} ?>">
						</td>
					<?php } ?>
					<?php if($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { #*?>
						<td valign="bottom" align="right" class="copy"> 
						<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'day'.$j.'_future_hours_child'.$i?>" name="<?php echo 'day'.$j.'_future_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['day'.$j.'_future_hours_child'.$i])) {echo 0;} else {echo $_SESSION['day'.$j.'_future_hours_child'.$i];} ?>">
						</td>
						<?php if($_SESSION['nontraditionalwork'] == 1) { ?>
							<td valign="bottom" align="right" class="copy"> 
							<input class="validate-number validate-nonnegative validate-nontrad-day <?php echo 'validate-nontrad-future-hours-'.$i?>" type="text" id="<?php echo 'day'.$j.'_nontrad_future_hours_child'.$i?>" name="<?php echo 'day'.$j.'_nontrad_future_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['day'.$j.'_nontrad_future_hours_child'.$i])) {echo 0;} else {echo $_SESSION['day'.$j.'_nontrad_future_hours_child'.$i];} ?>">
							</td>
						<?php } ?>
					<?php } ?>
				</tr>
			<?php } ?>	

			<?php if($_SESSION['nontraditionalwork'] == 1 || (($_SESSION['state'] == 'NH' || $_SESSION['state'] == 'PA' || $_SESSION['state'] == 'ME') && $_SESSION['demo'] == 0)) { #Because we are not asking the nontraditional work question for NH, PA, or ME, we need to add in the weekend days as the default scenario, in case someone wants to enter weekend care. #*?>
				<tr valign="top">
					<td class="copy" align="right" >
					Saturday: 
					</td>
					<td valign="bottom" align="right" class="copy"> 
					<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'day6_hours_child'.$i?>" name="<?php echo 'day6_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['day6_hours_child'.$i])) {echo 0;} else {echo $_SESSION['day6_hours_child'.$i];} ?>">
					</td>
					<?php if($_SESSION['nontraditionalwork'] == 1) { #Skipping a column in this intance, for alignment purposes ?> 
					<td>
					</td>
					<?php } ?>					
					<?php if($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?>
						<td valign="bottom" align="right" class="copy"> 
						<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'day6_future_hours_child'.$i?>" name="<?php echo 'day6_future_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['day6_future_hours_child'.$i])) {echo 0;} else {echo $_SESSION['day6_future_hours_child'.$i];} ?>">
						</td>
					<?php } ?>
				</tr>
				<tr valign="top">
					<td class="copy" align="right" >
					Sunday:
					</td>					
					<td valign="bottom" align="right" class="copy"> 
					<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'day7_hours_child'.$i?>" name="<?php echo 'day7_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['day7_hours_child'.$i])) {echo 0;} else {echo $_SESSION['day7_hours_child'.$i];}  ?>">
					</td>
					<?php if($_SESSION['nontraditionalwork'] == 1) { #Skipping a column in this intance, for alignment purposes ?> 
					<td>
					</td>
					<?php } ?>										
					<?php if($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?>
						<td valign="bottom" align="right" class="copy"> 
						<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'day7_future_hours_child'.$i?>" name="<?php echo 'day7_future_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['day7_future_hours_child'.$i])) {echo 0;} else {echo $_SESSION['day7_future_hours_child'.$i];} ?>">
						</td>
					<?php } ?>
				<tr/>
			<?php } else {
				$_SESSION['day6_hours_child'.$i] = 0;
				$_SESSION['day7_hours_child'.$i] = 0;
				$_SESSION['day6_future_hours_child'.$i] = 0;
				$_SESSION['day7_future_hours_child'.$i] = 0;
				}?>
		<?php } ?>
	<?php } ?>

	<?php if ($_SESSION['schoolage_children_under13'] > 0) { #We check for whether there is a child age above 4 to see if the child is school-age. If there is no child who is school-age, we don't ask these questions, since we already capture child care above. ?>
		<tr valign="top">
			<td class="copy" align="right" >
			<b>During the summer:</b>
			</td>
		</tr>
		<?php for($i=1; $i<=$_SESSION['child_number']; $i++) { ?>
			<?php if($_SESSION['child'.$i.'_age'] > -1 && $_SESSION['child'.$i.'_age'] < 13) { ?>
				<tr valign="top">
					<td class="copy" align="right" >
				<u> Child <?php echo $i ?>, age <?php echo $_SESSION['child'.$i.'_age']?> </u>
				</tr>
				<?php for($j=1; $j<=5; $j++) { ?>
					<tr valign="top">
						<td class="copy" align="right" >
						<?php if ($j==1) { ?>
							Monday: 
						<?php } else if ($j==2) { ?>
							Tuesday: 
						<?php } else if ($j==3) { ?>
							Wednesday: 
						<?php } else if ($j==4) { ?>
							Thursday: 
						<?php } else if ($j==5) { ?>
							Friday: 
						<?php } ?>
						</td>
						<td valign="bottom" align="right" class="copy"> 
						<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'summerday'.$j.'_hours_child'.$i?>" name="<?php echo 'summerday'.$j.'_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['summerday'.$j.'_hours_child'.$i])) {echo 0;} else {echo $_SESSION['summerday'.$j.'_hours_child'.$i];} ?>">
						<?php if($_SESSION['nontraditionalwork'] == 1) { ?>
							<td valign="bottom" align="right" class="copy"> 
							<input class="validate-number validate-nonnegative validate-nontrad-day <?php echo 'validate-nontrad-summer-hours-'.$i?>" type="text" id="<?php echo 'summerday'.$j.'_nontrad_hours_child'.$i?>" name="<?php echo 'summerday'.$j.'_nontrad_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['summerday'.$j.'_nontrad_hours_child'.$i])) {echo 0;} else {echo $_SESSION['summerday'.$j.'_nontrad_hours_child'.$i];} ?>"> 
						<?php } ?>
						<?php if($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?>
							<td valign="bottom" align="right" class="copy"> 
							<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'summerday'.$j.'_future_hours_child'.$i?>" name="<?php echo 'summerday'.$j.'_future_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['summerday'.$j.'_future_hours_child'.$i])) {echo 0;} else {echo $_SESSION['summerday'.$j.'_future_hours_child'.$i];} ?>">
							<?php if($_SESSION['nontraditionalwork'] == 1) { ?>
								<td valign="bottom" align="right" class="copy"> 
								<input class="validate-number validate-nonnegative validate-nontrad-day <?php echo 'validate-nontrad-summer-future-hours-'.$i?>" type="text" id="<?php echo 'summerday'.$j.'_nontrad_future_hours_child'.$i?>" name="<?php echo 'summerday'.$j.'_nontrad_future_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['summerday'.$j.'_nontrad_future_hours_child'.$i])) {echo 0;} else {echo $_SESSION['summerday'.$j.'_nontrad_future_hours_child'.$i];} ?>">
								</td>
							<?php } ?>
						<?php } ?>
					<tr/>
				<?php } ?>
					
				<?php if($_SESSION['nontraditionalwork'] == 1 || (($_SESSION['state'] == 'NH' || $_SESSION['state'] == 'PA' || $_SESSION['state'] == 'ME') && $_SESSION['demo'] == 0)) { ?>
					<tr valign="top">
						<td class="copy" align="right" >
						Saturday: 
						</td>
						<td valign="bottom" align="right" class="copy"> 
						<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'summerday6_hours_child'.$i?>" name="<?php echo 'summerday6_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['summerday6_hours_child'.$i])) {echo 0;} else {echo $_SESSION['summerday6_hours_child'.$i];} ?>">
						</td>
						<?php if($_SESSION['nontraditionalwork'] == 1) { #Skipping a column in this intance, for alignment purposes ?> 
						<td>
						</td>
						<?php } ?>					
						<?php if($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?>
							<td valign="bottom" align="right" class="copy"> 
							<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'summerday6_future_hours_child'.$i?>" name="<?php echo 'summerday6_future_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['summerday6_future_hours_child'.$i])) {echo 0;} else {echo $_SESSION['summerday6_future_hours_child'.$i];} ?>">
							</td>						
						<?php } ?>
					</tr>
					<tr valign="top">
						<td class="copy" align="right" >
						Sunday: 
						</td>					
						<td valign="bottom" align="right" class="copy"> 
						<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'summerday7_hours_child'.$i?>" name="<?php echo 'summerday7_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['summerday7_hours_child'.$i])) {echo 0;} else {echo $_SESSION['summerday7_hours_child'.$i];} ?>">
						<?php if($_SESSION['nontraditionalwork'] == 1) { #Skipping a column in this intance, for alignment purposes ?> 
						<td>
						</td>
						<?php } ?>

						<?php if($_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both') { ?>
							<td valign="bottom" align="right" class="copy"> 
							<input class="validate-number validate-nonnegative validate-day" type="text" id="<?php echo 'summerday7_future_hours_child'.$i?>" name="<?php echo 'summerday7_future_hours_child'.$i?>" size="2" maxlength="2" value="<?php if (is_null ($_SESSION['summerday7_future_hours_child'.$i])) {echo 0;} else {echo $_SESSION['summerday7_future_hours_child'.$i];} ?>">
							</td>
						<?php } ?>
					<tr/>
				<?php } else {
					$_SESSION['summerday6_hours_child'.$i] = 0;
					$_SESSION['summerday7_hours_child'.$i] = 0;
					$_SESSION['summerday6_future_hours_child'.$i] = 0;
					$_SESSION['summerday7_future_hours_child'.$i] = 0;
				}?>
			<?php } ?>
		<?php } ?>	
	<?php } else {  #No summer hours.
		for($i=1; $i<=$_SESSION['child_number']; $i++) {
			if($_SESSION['child'.$i.'_age'] > -1 && $_SESSION['child'.$i.'_age'] < 13) {
				for($j=1; $j<=7; $j++) {
					$_SESSION['summerday'.$j.'_hours_child'.$i] = 0;
				}
			}
		}
	}
	
	#In case a user has entered data for a child in the home and then removed that child, we need to set all child care hours variables to 0. This seems to be mainly necessary for the JavaScript data validation. 
	for($i=1; $i<=5; $i++) {
		if($_SESSION['child'.$i.'_age'] == -1) {
			for($j=1; $j<=7; $j++) {
				$_SESSION['day'.$j.'_hours_child'.$i] = 0;
				$_SESSION['day'.$j.'_future_hours_child'.$i] = 0;
				$_SESSION['summerday'.$j.'_hours_child'.$i] = 0;
				$_SESSION['summerday'.$j.'_future_hours_child'.$i] = 0;
			}
		}
	}
	
	
	?>	
	</table>
<?php } ?>

<br/>
