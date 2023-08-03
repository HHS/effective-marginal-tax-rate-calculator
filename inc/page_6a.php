<h2 class="noborder">
	<div class="squarebutton mini">
		6
	</div>
	Make choices about health insurance and other expenses.
</h2>	
<br/>

<h3>Select Family Resource Simulator estimate or enter your own estimate for other expenses.*</h3>
<h4>Housing expenses (cost of unsubsidized rent):</h4>
<p class="checkset">
    <input type="radio" id="housing_override_0" name="housing_override" value="0" <?php if($_SESSION['housing_override'] == 0) echo 'checked' ?> />
	<label for="housing_override_0">Fair Market Rent, as determined by the U.S. Department of Housing and Urban Development: $<?php echo $simulator->rent() ?> per month</label>
</p>
<p class="checkset">
    <input type="radio" id="housing_override_1" name="housing_override" value="1" <?php if($_SESSION['housing_override'] == 1) echo 'checked' ?> />
    <label>Other cost estimate: $<input class="validate-number" type="text" enabled_when_checked="housing_override_1" id="housing_override_amt" name="housing_override_amt" size="3" maxlength="4" value="<?php echo $_SESSION['housing_override_amt'] ?>"> per month</label>
</p>
<br/>
<h4>Food expenses:</h4>
<p class="checkset">
    <input type="radio" id="food_override_0" name="food_override" value="0" <?php if($_SESSION['food_override'] == 0) echo 'checked' ?> />
    <label for="food_override_0">Low-Cost Food Plan developed by the U.S. Department of Agriculture</label>
</p>
<p class="checkset">
    <input type="radio" id="food_override_1" name="food_override" value="1" <?php if($_SESSION['food_override'] == 1) echo 'checked' ?> />
    <label>Other cost estimate: $<input class="validate-number" type="text" enabled_when_checked="food_override_1" id="food_override_amt" name="food_override_amt" size="3" maxlength="4" value="<?php echo $_SESSION['food_override_amt'] ?>"> per month</label>
</p>
<br/>
<h4>Transportation expenses:</h4>
<p class="checkset">
    <input type="radio" id="trans_override_0" name="trans_override" value="0" <?php if($_SESSION['trans_override'] == 0) echo 'checked' ?> />
	<label for="trans_override_0">
	    <?php if($simulator->trans_private()) { ?>Private transportation cost estimate
		<?php } else { ?>Public transportation cost estimate<?php } ?>
	</label>
</p>
<p class="checkset">
    <input type="radio" id="trans_override_1" name="trans_override" value="1" <?php if($_SESSION['trans_override'] == 1) echo 'checked' ?> />
    <label for="trans_override_1">
    <?php if($_SESSION['family_structure'] == 2 && $_SESSION['parent2_max_work'] != 'N') { ?>
        Other cost estimate:
    </label>
	</p>
	<p style="margin-left: 24px;margin-bottom:0px;">
        Parent 1: $<input class="validate-number" type="text" enabled_when_checked="trans_override_1" id="trans_override_parent1_amt" name="trans_override_parent1_amt" size="3" maxlength="3" value="<?php echo $_SESSION['trans_override_parent1_amt'] ?>"> per month<br/>
        Parent 2: $<input class="validate-number" type="text" enabled_when_checked="trans_override_1" id="trans_override_parent2_amt" name="trans_override_parent2_amt" size="3" maxlength="3" value="<?php echo $_SESSION['trans_override_parent2_amt'] ?>"> per month
	</p>
	<?php } else { ?>
		Other cost estimate: $<input type="text" enabled_when_checked="trans_override_1" id="trans_override_parent1_amt" name="trans_override_parent1_amt" size="3" maxlength="3" value="<?php echo $_SESSION['trans_override_parent1_amt'] ?>"> per month
	</label>
	</p>
	<?php } ?>
<br/>
<h4>Cost of other necessities:</h4>
<p class="checkset">
    <input type="radio" id="other_override_0" name="other_override" value="0" <?php if($_SESSION['other_override'] == 0) echo 'checked' ?> />
    <label for="other_override_0">Family Resource Simulator estimate of other necessities</label>
</p>
<p class="checkset">
    <input type="radio" id="other_override_1" name="other_override" value="1" <?php if($_SESSION['other_override'] == 1) echo 'checked' ?> />
    <label>Other cost estimate: $<input class="validate-number" type="text" enabled_when_checked="other_override_1" name="other_override_amt" size="3" maxlength="3" value="<?php echo $_SESSION['other_override_amt'] ?>"> per month</label>
</p>
<br/>
<p class="small">* For more information about the Family Resource Simulator&rsquo;s expense estimates, see <a onclick="popup(this, 'scrollbars=1', 600, 700); return false;" target="blank" href="/popup.php?name=frs_guide#C2">Calculating Family Expenses</a>.</p>