<h3>On this  page, you can enter your child care costs or use the calculator's estimate.</h3>
<p class="checkset">
<input type="radio" name="child_care_nobenefit_estimate_source" id="amt" value="amt" <?php if($_SESSION['child_care_nobenefit_estimate_source'] == 'amt') echo 'checked' ?>>
	<label>I want to enter my child care costs. I pay this much out of pocket for child care, including any after-school programs<?php if($_SESSION['state'] == 'ME') { ?><label for="step4_care_flag">. This care </label>
			<select name="step4_care_flag" id="step4_care_flag" enabled_when_checked="amt" >
				<option value="0" <?php if($_SESSION['step4_care_flag'] == 0) echo 'selected' ?>>does not include</option>
				<option value="1" <?php if($_SESSION['step4_care_flag'] == 1) echo 'selected' ?>>includes</option>
			</select>
			care provided by a Step 4 high-quality child care provider (important for tax purposes): 
		<?php } else { ?>: <?php }?><?php //echo $notes_table->add_note('page5_nobenefit_cost'); echo $help_table->add_help('page5_nobenefit_cost'); ?></label>
<table class="indented">
		<?php for($i=1; $i<=5; $i++) { ?>
		<?php if($_SESSION["child{$i}_age"] > -1) { ?>
           <tr>
                <td>
		        	<?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
                </td>
                <?php if($simulator->child_eligible($i)) { ?>
                    <td> 
                      $<input class="validate-number <?php echo 'validate-childcarehours-'.$i ?>" type="text" id="amt_<?php echo $i ?>" enabled_when_checked="amt" name="child<?php echo $i ?>_nobenefit_amt_m" value="<?php echo $_SESSION["child{$i}_nobenefit_amt_m"] ?>" size="3" maxlength="4"> per 
						<label for="<?php echo 'cc_nobenefit_payscale'.$i?>"></label>			   
						<select name="<?php echo 'cc_nobenefit_payscale'.$i?>" id="<?php echo 'cc_nobenefit_payscale'.$i?>" enabled_when_checked="amt"> <!--5/20: Changed all these to numeric values (1-24), and ordered them ascendingly.-->
						<?php if($_SESSION['user_prototype'] == 1 && $_SESSION['children_under13'] > 0 && ($_SESSION['ccdf'] || $_SESSION['future_scenario'] == 'hours' || $_SESSION['future_scenario'] == 'both')) { #While child care costs are needed for other situations than those meeting these conditions, we are not asking about hourly or daily rates because child care costs will not change if these conditions are not met. Users can still select between weekly, bi-weekly, monthly, or annual costs to accommodate the numbers they have available for theses rates.?>
							  <option value="hour" <?php if($_SESSION['cc_nobenefit_payscale'.$i] == 'hour') echo 'selected' ?>>hour</option> 
							  <option value="day" <?php if($_SESSION['cc_nobenefit_payscale'.$i] == 'day') echo 'selected' ?>>day</option> 
						<?php } ?>
							  <option value="week" <?php if($_SESSION['cc_nobenefit_payscale'.$i] == 'week') echo 'selected' ?>>week</option> 
							  <option value="biweekly" <?php if($_SESSION['cc_nobenefit_payscale'.$i] == 'biweekly') echo 'selected' ?>>every two weeks</option> 
							  <option value="month" <?php if($_SESSION['cc_nobenefit_payscale'.$i] == 'month') echo 'selected' ?>>month</option> 
							  <option value="year" <?php if($_SESSION['cc_nobenefit_payscale'.$i] == 'year') echo 'selected' ?>>year</option> 					 
						</select>
                    </td>
				<?php } else { ?>
                   <td>not eligible for care</td>
				<?php } ?>
            </tr>
		<?php } ?>
	<?php } ?>
</table>
    <input type="radio" name="child_care_nobenefit_estimate_source" id="spr" value="spr" <?php if($_SESSION['child_care_nobenefit_estimate_source'] == 'spr') echo 'checked' ?>>
    <label>I want the calculator to estimate my child care costs based on type of child care: <?php //echo $notes_table->add_note('page5_nobenefit_setting'); echo $help_table->add_help('page5_nobenefit_setting'); ?></label>
<table class="indented">
	<?php for($i=1; $i<=5; $i++) { ?>
		<?php if($_SESSION["child{$i}_age"] > -1) { ?>
            <tr>
                <td>
		        	<?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
                </td>
                <?php if($simulator->child_eligible($i)) { ?>
                    <td>
                        <select id="nobenefit_setting_<?php echo $i ?>" enabled_when_checked="spr" name="child<?php echo $i ?>_nobenefit_setting">
		                	<?php if ($_SESSION['user_prototype'] == 1 && $_SESSION['state'] == 'KY' ) { ?>
		                        <option value="Licensed Type 1 Provider" <?php if($_SESSION["child{$i}_nobenefit_setting"] == 'type_1') echo 'selected' ?>>Child Care Center</option>
		                        <option value="Certified Family Child Care Home" <?php if($_SESSION["child{$i}_nobenefit_setting"] == 'registered_home') echo 'selected' ?>>Child Care Home</option>
		                        <option value="Registered Provider (family, friend, or neighbor)" <?php if($_SESSION["child{$i}_nobenefit_setting"] == 'registered') echo 'selected' ?>>Family, friend, or neighbor</option>							
							<?php } else { ?>
								<?php foreach($simulator->child_care_settings($i) as $s) { ?>
									<option value="<?php echo $s['text'] ?>" <?php if($_SESSION["child{$i}_nobenefit_setting"] == $s['text']) echo 'selected' ?>><?php echo $s['text'] ?></option>
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
</p>
