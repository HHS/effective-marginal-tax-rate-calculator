<h2 class="noborder">
	<div class="squarebutton mini">
		5
	</div>
	Make choices about child care.<?php echo $notes_table->add_note('page5_continue_title'); echo $help_table->add_help('page5_continue_title'); ?>
</h2>	
<br/>

<h3>Select setting or enter cost for unsubsidized child care.<?php echo $notes_table->add_note('page5_continue_intro'); echo $help_table->add_help('page5_continue_intro'); ?></h3>
<p class="checkset">
	<input type="radio" name="child_care_continue_estimate_source" id="spr" value="spr" <?php if($_SESSION['child_care_continue_estimate_source'] == 'spr') echo 'checked' ?>>
	<label>Select child care setting:<?php echo $notes_table->add_note('page5_continue_setting'); echo $help_table->add_help('page5_continue_setting'); ?></label>
</p>
<table class="indented">
	<?php for($i=1; $i<=3; $i++) { ?>
		<?php if($_SESSION["child{$i}_age"] > 0) { ?>
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	<?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
		        </td>
			    <?php if($simulator->child_eligible($i)) { ?>
			    	<?php if($_SESSION["child{$i}_continue_flag"]) { ?>
                        <td class="copy">continues in same type of care</td>
					<?php } else { ?>
                        <td align="left" class="copy"> 
                          	<select id="continue_setting_<?php echo $i ?>" enabled_when_checked="spr" name="child<?php echo $i ?>_continue_setting">
            					<?php foreach($simulator->child_care_settings($i) as $s) { ?>
			                        <option value="<?php echo $s['text'] ?>" <?php if($_SESSION["child{$i}_continue_setting"] == $s['text']) echo 'selected' ?>><?php echo $s['text'] ?> ($<?php echo $simulator->format($s['spr'], 1) ?>/month)</option>
								<?php } ?>
							</select>
                        </td>
					<?php } ?>
				<?php } else { ?>
	           			<td class="copy">not eligible for care</td>
	           		<?php } ?>
        	</tr>
        <?php } ?>
    <?php } ?>
</table>
<br/>
<p class="checkset">
	<input type="radio" name="child_care_continue_estimate_source" id="amt" value="amt" <?php if($_SESSION['child_care_continue_estimate_source'] == 'amt') echo 'checked' ?>>
	<label>Enter cost per child:<?php echo $notes_table->add_note('page5_continue_cost'); echo $help_table->add_help('page5_continue_cost'); ?></label>
</p>
<table class="indented">
	<?php for($i=1; $i<=3; $i++) { ?>
		<?php if($_SESSION["child{$i}_age"] > 0) { ?>
		    <tr valign="top">
		        <td class="copy" align="right" >
		        	<?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
		        </td>
			    <?php if($simulator->child_eligible($i)) { ?>
			    	<?php if($_SESSION["child{$i}_continue_flag"]) { ?>
                        <td class="copy">continues in same type of care</td>
					<?php } else { ?>
                        <td valign="bottom" align="left" class="copy"> 
                        	$<input class="validate-number" id="amt_<?php echo $i ?>" enabled_when_checked="amt" type="text" name="child<?php echo $i ?>_continue_amt_m" value="<?php echo $_SESSION["child{$i}_continue_amt_m"] ?>" size="3" maxlength="4"> per month
                    	</td>
                    <?php } ?>
				<?php } else { ?>
                	<td valign="bottom" class="copy">not eligible for care</td>
                <?php } ?>
            </tr>
        <?php } ?>
    <?php } ?>
</table>