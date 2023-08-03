<script type="text/javascript">
Validation.add('validate-max200', 'Value must not be greater than 200.', function(v,e) {
	if(Number(v) > 200) {
		return false
	}
	return true;
});
Validation.add('validate-max300', '&nbsp', function(v,e) {
	if(Number(v) > 300) {
            alert('The entrance eligibilty limit cannot exceed the exit eligibility limit, which is 300% of the federal poverty guideline.');
            e.value = 300;
            return false;
	}
	return true;
});

Validation.add('validate-max100', '&nbsp', function(v,e) {
	if(Number(v) > 100) {
            alert('This number cannot be greater than 100');
            e.value = 100;
            return false;
	}
	return true;
});

Validation.add('validate-min0', '&nbsp', function(v,e) {
	if(Number(v) < 0) {
            alert('This number cannot be less than 0');
            e.value = 0;
            return false;
	}
	return true;
});
addLoadEvent(function() { $('select_all').onclick = function()  {
	<?php if($_SESSION['state'] == 'DC' && $_SESSION['year'] == 2017) { ?>
		checks = new Array('ccdf','fsp','hlth','sec8','tanf','ctc','cadc','wic','ssi','prek','afterschool','nsbp','frpl','fsmp','eitc','state_eitc','state_cadc','premium_tax_credit','liheap','lifeline','heap','ccdf_alt','eitc_alt','eitc_refundable_alt','eitc_nolimit_alt','wic','ssi','prek','afterschool','nsbp','frpl','fsmp','tax', 'ostp')
	<?php } elseif($_SESSION['state'] == 'KY' && $_SESSION['year'] == 2020) { ?>
		checks = new Array('ccdf','fsp','hlth','sec8','tanf','ctc','cadc','wic','ssi','afterschool','nsbp','frpl','fsmp','eitc','state_eitc','state_cadc','premium_tax_credit','liheap','lifeline','familysize_credit')
	<?php } elseif($_SESSION['state'] == 'NH' && $_SESSION['year'] == 2021) { ?>
		checks = new Array('ccdf','fsp','hlth','sec8','tanf','lifeline','liheap','eap','wic','ssi','ui','afterschool','nsbp','frpl','fsmp','prek_mtrc','headstart','earlyheadstart', 'exclude_covid_policies_ending_0921', 'exclude_covid_policies_ending_1221')
	<?php } else { ?>
		checks = new Array('ccdf','fsp','hlth','sec8','tanf','ctc','cadc','eitc','state_eitc','local_eitc','state_cadc','mwp')
	<?php } ?>
	for(var i=0; i<checks.length; i++) {
		if(obj = $(checks[i])) {
			obj.checked = true
			updateDependents(obj)
		}
	}
	return false;
}})

addLoadEvent(function() { $('select_none').onclick = function()  {
	<?php if($_SESSION['state'] == 'DC' && $_SESSION['year'] == 2017) { ?>
		checks = new Array('ccdf','fsp','hlth','sec8','tanf','ctc','cadc','wic','ssi','prek','afterschool','nsbp','frpl','fsmp','eitc','state_eitc','state_cadc','premium_tax_credit','liheap','lifeline','heap','ccdf_alt','eitc_alt','eitc_refundable_alt','eitc_nolimit_alt','wic','ssi','prek','afterschool','nsbp','frpl','fsmp','tax','ostp')
	<?php } elseif($_SESSION['state'] == 'KY' && $_SESSION['year'] == 2020) { ?>
		checks = new Array('ccdf','fsp','hlth','sec8','tanf','ctc','cadc','wic','ssi','afterschool','nsbp','frpl','fsmp','eitc','state_eitc','state_cadc','premium_tax_credit','liheap','lifeline','familysize_credit')
	<?php } elseif($_SESSION['state'] == 'NH' && $_SESSION['year'] == 2021) { ?>
		checks = new Array('ccdf','fsp','hlth','sec8','tanf','lifeline','liheap','eap','wic','ssi','ui','afterschool','nsbp','frpl','fsmp','prek_mtrc','headstart','earlyheadstart', 'exclude_covid_policies_ending_0921', 'exclude_covid_policies_ending_1221')
	<?php } else { ?>
		checks = new Array('ccdf','fsp','hlth','sec8','tanf','ctc','cadc','eitc','state_eitc','local_eitc','state_cadc','mwp')
	<?php } ?>
	for(var i=0; i<checks.length; i++) {
		if(obj = $(checks[i])) {
			obj.checked = false
			updateDependents(obj)
		}
	}
	return false;
}})


</script>
<?php
# Program names:
# For generic names:
if ($_SESSION['state'] == 'NH' && $_SESSION['demo'] == 1) {
	$_SESSION['ui_name'] = 'Unemployment Insurance (UI)';
	$_SESSION['ssi_name'] = 'Supplemental Security Income (SSI)';
	$_SESSION['ssp_name'] = 'State Supplement Program (SSP)';
	$_SESSION['medicaid_name'] = 'Medicaid/CHIP';
	$_SESSION['tanf_name'] = 'TANF Cash Assistance';
	$_SESSION['ccdf_name'] = 'Child Care and Development Fund (CCDF) Subsidies'; 
	$_SESSION['sec8_name'] = 'Subsidized Housing (Section 8, Housing Choice Vouchers, or Public Housing)';
	$_SESSION['liheap_name'] = 'Low Income Home Energy Assistance Program (LIHEAP)';
	$_SESSION['eap_name'] = 'Electric Assistance Program (EAP)';
	$_SESSION['fsp_name'] = 'SNAP/Food Stamps';
	$_SESSION['frpl_name'] = 'Free and reduced price school lunch';
	$_SESSION['sbp_name'] = 'Free and reduced price school breakfast'; 
	$_SESSION['sfsp_name'] = 'Free summer meals';   
	$_SESSION['wic_name'] = 'Women, Infants, and Children (WIC)';
	$_SESSION['lifeline_name'] = 'Lifeline'; 
	$_SESSION['state_tax_credits_name'] = 'State tax credits'; 

	#We also set up the "short" names here for sentence references in subsequent pages.
	$_SESSION['tanf_short_name'] = 'TANF';
	$_SESSION['medicaid_short_name'] = 'Medicaid';
	$_SESSION['ccdf_short_name'] = 'CCA'; 
	$_SESSION['prek_short_name'] = 'Pre-K'; #No Pre-K in NH but still assigning in case it's added later.

	#We also set up the "medium" names for the final table in Step 8. 
	$_SESSION['tanf_medium_name'] = 'TANF Cash Assistance';
	$_SESSION['medicaid_medium_name'] = 'Medicaid';
	$_SESSION['chip_medium_name'] = 'CHIP';
	$_SESSION['ui_medium_name'] = 'Unemployment Benefits';
	$_SESSION['ssi_medium_name'] = 'SSI/SSP'; #Just used for a table where we combine references to SSI and SSP
	$_SESSION['tanf_medium_name'] = 'FANF Cash Assistance';
	$_SESSION['ccdf_medium_name'] = 'Child Care Assistance'; 
	$_SESSION['sec8_medium_name'] = 'Housing assistance';
	$_SESSION['liheap_medium_name'] = 'LIHEAP';
	$_SESSION['fsp_medium_name'] = 'SNAP / Food Stamps';
	$_SESSION['wic_medium_name'] = 'WIC';
	$_SESSION['lifeline_medium_name'] = 'Lifeline'; 
}

# For New Hampshire to start:
if ($_SESSION['state'] == 'NH' && $_SESSION['demo'] == 0) {
	$_SESSION['ui_name'] = 'Unemployment benefits (also called unemployment assistance or unemployment insurance)';
	$_SESSION['ssi_name'] = 'SSI (also called Supplemental Security Income)';
	$_SESSION['ssp_name'] = 'State Supplemental cash assistance &ndash; SSP (also called APTD, OAA, or ANB)';
	$_SESSION['medicaid_name'] = 'Medicaid';
	$_SESSION['tanf_name'] = 'FANF cash assistance (also called TANF, NHEP, IDP, FAP, or FWOC)';
	$_SESSION['ccdf_name'] = 'Child care assistance (also called Child Care Scholarship, child care subsidies, or CCDF)'; 
	$_SESSION['sec8_name'] = 'Housing assistance (Housing Choice Vouchers or HCVP [formerly Section 8] or Public Housing)';
	$_SESSION['liheap_name'] = 'Fuel Assistance Program (also called LIHEAP)';
	$_SESSION['eap_name'] = 'Electric Assistance Program (EAP)';
	$_SESSION['fsp_name'] = 'SNAP / Food Stamps';
	$_SESSION['frpl_name'] = 'Free or Reduced Price School Lunch';
	$_SESSION['sbp_name'] = 'Free or Reduced Price School Breakfast'; 
	$_SESSION['sfsp_name'] = 'Free Summer Meals Program';   
	$_SESSION['wic_name'] = 'Women, Infants, and Children (also known as WIC or Special Supplemental Program for Women, Infants, and Children)';
	$_SESSION['lifeline_name'] = 'Lifeline Assistance Program (also known as Lifeline Service or telephone subsidies)';
	$_SESSION['state_tax_credits_name'] = 'State tax credits'; 

	#We also set up the "short" names here for sentence references in subsequent pages.
	$_SESSION['tanf_short_name'] = 'FANF';
	$_SESSION['medicaid_short_name'] = 'Medicaid';
	$_SESSION['ccdf_short_name'] = 'CCA'; 
	$_SESSION['prek_short_name'] = 'Pre-K'; #No Pre-K in NH but still assigning in case it's added later.

	#We also set up the "medium" names for the final table in Step 8. 
	$_SESSION['tanf_medium_name'] = 'FANF Cash Assistance';
	$_SESSION['medicaid_medium_name'] = 'Medicaid';
	$_SESSION['chip_medium_name'] = ''; #There is no CHIP program in New Hampshire; it will not show up anywhere.
	$_SESSION['ui_medium_name'] = 'Unemployment Benefits';
	$_SESSION['ssi_medium_name'] = 'SSI/SSP'; #Just used for a table where we combine references to SSI and SSP
	$_SESSION['ccdf_medium_name'] = 'Child Care Assistance'; 
	$_SESSION['sec8_medium_name'] = 'Housing assistance';
	$_SESSION['liheap_medium_name'] = 'LIHEAP';
	$_SESSION['fsp_medium_name'] = 'SNAP / Food Stamps';
	$_SESSION['wic_medium_name'] = 'WIC';
	$_SESSION['lifeline_medium_name'] = 'Lifeline'; 
}

# For Pennsylvania:
if ($_SESSION['state'] == 'PA' && $_SESSION['demo'] == 0) {
	$_SESSION['ui_name'] = 'Unemployment Compensation';
	$_SESSION['ssi_name'] = 'Supplemental Security Income (SSI)';
	$_SESSION['ssp_name'] = 'State Supplement Program (SSP)';
	$_SESSION['medicaid_name'] = 'Medical Assistance/CHIP';
	$_SESSION['tanf_name'] = 'Cash Assistance';
	$_SESSION['ccdf_name'] = 'Child Care Works'; 
	$_SESSION['sec8_name'] = 'Housing assistance (Section 8, Housing Choice Vouchers, or Public Housing)';
	$_SESSION['liheap_name'] = 'Low Income Home Energy Assistance Program (LIHEAP)';
	$_SESSION['fsp_name'] = 'SNAP';
	$_SESSION['frpl_name'] = 'Free or reduced price school lunch';
	$_SESSION['sbp_name'] = 'Free or reduced price school breakfast'; 
	$_SESSION['sfsp_name'] = 'Summer Food Service Program (SFSP)';   
	$_SESSION['wic_name'] = 'Women, Infants, and Children (WIC)';
	$_SESSION['lifeline_name'] = 'Lifeline telephone subsidy'; 
	$_SESSION['prek_name'] = 'Pre-K Counts';
	$_SESSION['state_tax_credits_name'] = 'State tax credits (Tax Forgiveness Credit)'; 

	#We also set up the "short" names here for sentence references in subsequent pages.
	$_SESSION['tanf_short_name'] = 'Cash Assistance';
	$_SESSION['medicaid_short_name'] = 'Medical Assistance';
	$_SESSION['ccdf_short_name'] = 'CCW'; 
	$_SESSION['prek_short_name'] = 'Pre-K';
	
	#We also set up the "medium" names for the final table in Step 8. 
	$_SESSION['tanf_medium_name'] = 'Cash Assistance';
	$_SESSION['medicaid_medium_name'] = 'Medical Assistance';
	$_SESSION['chip_medium_name'] = 'CHIP';
	$_SESSION['ui_medium_name'] = 'Unemployment Compensation';
	$_SESSION['ssi_medium_name'] = 'SSI'; #Just used for a table where we combine references to SSI and SSP
	$_SESSION['ccdf_medium_name'] = 'Child Care Works'; 
	$_SESSION['sec8_medium_name'] = 'Housing assistance';
	$_SESSION['liheap_medium_name'] = 'LIHEAP';
	$_SESSION['fsp_medium_name'] = 'SNAP';
	$_SESSION['wic_medium_name'] = 'WIC';
	$_SESSION['lifeline_medium_name'] = 'Lifeline'; 
	$_SESSION['prek_medium_name'] = 'Pre-K Counts';
}

# For DC:
if ($_SESSION['state'] == 'DC' && $_SESSION['demo'] == 0) {
	$_SESSION['ui_name'] = 'Unemployment Compensation';
	$_SESSION['ssi_name'] = 'Supplemental Security Income (SSI)';
	$_SESSION['ssp_name'] = 'State Supplement Program (SSP)';
	$_SESSION['medicaid_name'] = 'Medicaid / Medical Assistance';
	$_SESSION['tanf_name'] = 'TANF Cash Assistance';
	$_SESSION['ccdf_name'] = 'Child Care Subsidy/Voucher Program'; 
	$_SESSION['sec8_name'] = 'Rental assistance (Section 8, Housing Choice Vouchers, or Public Housing)';
	$_SESSION['liheap_name'] = 'Low Income Home Energy Assistance Program (LIHEAP)';
	$_SESSION['fsp_name'] = 'Food Stamps / SNAP';
	$_SESSION['frpl_name'] = 'Free or reduced price school lunch';
	$_SESSION['sbp_name'] = 'Free or reduced price school breakfast'; 
	$_SESSION['sfsp_name'] = 'DC Free Summer Meals Program';   
	$_SESSION['wic_name'] = 'Women, Infants, and Children (WIC)';
	$_SESSION['lifeline_name'] = 'Lifeline telephone discount program'; 
	$_SESSION['prek_name'] = 'Pre-Kindergarten';
	$_SESSION['state_tax_credits_name'] = 'State tax credits'; 

	#We also set up the "short" names here for sentence references in subsequent pages.
	$_SESSION['tanf_short_name'] = 'TANF';
	$_SESSION['medicaid_short_name'] = 'Medicaid';
	$_SESSION['ccdf_short_name'] = 'Child Care Subsidy'; 
	$_SESSION['prek_short_name'] = 'Pre-K';
	
	#We also set up the "medium" names for the final table in Step 8. 
	$_SESSION['tanf_medium_name'] = 'TANF Cash Assistance';
	$_SESSION['medicaid_medium_name'] = 'Medicaid';
	$_SESSION['ui_medium_name'] = 'Unemployment Compensation';
	$_SESSION['ssi_medium_name'] = 'SSI'; 
	$_SESSION['ccdf_medium_name'] = 'Child Care Subsidy'; 
	$_SESSION['sec8_medium_name'] = 'Housing assistance';
	$_SESSION['liheap_medium_name'] = 'LIHEAP';
	$_SESSION['fsp_medium_name'] = 'Food Stamps / SNAP';
	$_SESSION['wic_medium_name'] = 'WIC';
	$_SESSION['lifeline_medium_name'] = 'Lifeline'; 
	$_SESSION['prek_medium_name'] = 'Pre-K';
}

# For Maine:
if ($_SESSION['state'] == 'ME' && $_SESSION['demo'] == 0) {
	$_SESSION['ui_name'] = 'Unemployment Insurance Benefit (UIB)';
	$_SESSION['ssi_name'] = 'Supplemental Security Income (SSI)';
	$_SESSION['ssp_name'] = 'State Supplement Program (SSP)';
	$_SESSION['medicaid_name'] = 'MaineCare / Cub Care';
	$_SESSION['tanf_name'] = 'TANF Cash Assistance';
	$_SESSION['ccdf_name'] = 'Child Care Subsidy/Voucher Program'; 
	$_SESSION['sec8_name'] = 'Rental assistance (Section 8, Housing Choice Vouchers, or Public Housing)';
	$_SESSION['liheap_name'] = 'Home Energy Assistance Program (HEAP)';
	$_SESSION['fsp_name'] = 'Food Supplement Program (FSP)';
	$_SESSION['frpl_name'] = 'Free or reduced price school lunch';
	$_SESSION['sbp_name'] = 'Free or reduced price school breakfast'; 
	$_SESSION['sfsp_name'] = 'Summer Food Service Program (SFSP)';   
	$_SESSION['wic_name'] = 'Women, Infants, and Children (WIC)';
	$_SESSION['lifeline_name'] = 'Lifeline telephone discount program'; 
	$_SESSION['prek_name'] = 'Public Pre-Kindergarten (Pre-K or 4YO program)';
	$_SESSION['state_tax_credits_name'] = 'State tax credits'; 

	#We also set up the "short" names here for sentence references in subsequent pages.
	$_SESSION['tanf_short_name'] = 'TANF';
	$_SESSION['medicaid_short_name'] = 'MaineCare';
	$_SESSION['ccdf_short_name'] = 'Child Care Subsidy'; 
	$_SESSION['prek_short_name'] = 'Pre-K';
	
	#We also set up the "medium" names for the final table in Step 8. 
	$_SESSION['tanf_medium_name'] = 'TANF Cash Assistance';
	$_SESSION['medicaid_medium_name'] = 'MaineCare';
	$_SESSION['chip_medium_name'] = 'Cub Care';
	$_SESSION['ui_medium_name'] = 'Unemployment Insurance Benefits';
	$_SESSION['ssi_medium_name'] = 'SSI'; 
	$_SESSION['ccdf_medium_name'] = 'Child Care Subsidy'; 
	$_SESSION['sec8_medium_name'] = 'Housing assistance';
	$_SESSION['liheap_medium_name'] = 'HEAP';
	$_SESSION['fsp_medium_name'] = 'FSP';
	$_SESSION['wic_medium_name'] = 'WIC';
	$_SESSION['lifeline_medium_name'] = 'Lifeline'; 
	$_SESSION['prek_medium_name'] = 'Pre-K';
}

# We set up some variables used for determining whether people's ages or disability status make them eligible for various benefits.
$_SESSION['children_under13'] = 0;
for($i=1; $i<=$_SESSION['child_number_mtrc']; $i++) {
	if($_SESSION['child'.$i.'_age'] <  13) {
		$_SESSION['children_under13']++;
	}
} 

$_SESSION['children_under5'] = 0;
for($i=1; $i<=$_SESSION['child_number_mtrc']; $i++) {
	if($_SESSION['child'.$i.'_age'] <  5) {
		$_SESSION['children_under5']++;
	}
}

$children_under4 = 0;
for($i=1; $i<=$_SESSION['child_number_mtrc']; $i++) {
	if($_SESSION['child'.$i.'_age'] <  4) {
		$children_under4++;
	}
}

$children_whoare3or4 = 0;
for($i=1; $i<=$_SESSION['child_number_mtrc']; $i++) {
	if($_SESSION['child'.$i.'_age'] == 3 || $_SESSION['child'.$i.'_age'] == 4) {
		$children_whoare3or4++;
	}
}

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

$disability_count = 0;
for($i=1; $i<=$_SESSION['family_structure']; $i++) {
	if($_SESSION['disability_parent'.$i] == 1) {
		$disability_count++;
	}
}

$potential_adult_children = 0;
for($i=1; $i<=$_SESSION['family_structure']; $i++) {
	if($_SESSION['parent'.$i.'_age'] == 18 && $_SESSION['parent'.$i.'_student_status'] == 'ft_student') {
		$potential_adult_children++; #Dependents who are 18 years old may be high school students and therefore may count as children for TANF cash assistance. There are other variables we could take into account here but this leaves it broad enough to allow people with 18-year-olds in their home to select TANF cash assistance rather than see it missing.
	}
}


?>

<br/>
<br/>
<br/>
<div style="margin:10px 0;"><b>Please select all the benefits currently received by you or anyone in your household.</b><br><br>
<b>Note:&nbsp; &nbsp;If someone in your household receives a benefit not listed here, the results (in Step 8) will be less accurate. Please ask your case manager for more information.</b></div>
<br>
<!--<i> Select which benefits you or other people in you household <u/>currently</u> receive: </i>
<br/>
</br>-->

<!-- CCDF -->

<?php if ($_SESSION['children_under13'] > 0) { ?>

<input type="checkbox" id="ccdf" name="ccdf" <?php if($_SESSION['ccdf']) echo 'checked' ?>>&nbsp;<label for="ccdf"><?php echo $_SESSION['ccdf_name'] ?></label><?php ////echo $notes_table->add_note('page4_ccdf'); echo $help_table->add_help('page4_ccdf'); ?><br />    

<?php } ?>

<!-- FOOD STAMPS -->

<input type="checkbox" id="fsp" name="fsp" <?php if($_SESSION['fsp']) echo 'checked' ?>>&nbsp;<label for="fsp" ><?php echo $_SESSION['fsp_name'] ?></label><?php //echo $notes_table->add_note('page4_fsp'); echo $help_table->add_help('page4_fsp'); ?><br />
<?php if($_SESSION['year'] >= 2020 && $_SESSION['child_number_mtrc'] == 0 && $_SESSION['state'] != 'PA') { ?>
    <div class="alternate">
        <div class="checkbox">
            <label for="exclude_abawd_provision"><input class="check" type="checkbox" id="exclude_abawd_provision" enabled_when_checked="fsp" name="exclude_abawd_provision" <?php if($_SESSION['exclude_abawd_provision']) echo 'checked' ?>>&nbsp;Click here to include SNAP benefits only if you work the required number of hours. (Note that for the remainder of 2021, there is NO work requirement for SNAP. If you do not know whether you will need to meet work requirements to receive SNAP benefits, check with your case manager.)</label> 
        </div>
    </div>

	<?php if ($_SESSION['user_prototype'] == 0) { #Suppressing this option for now. It may be something of interest later on if reverting this back to a Family Resource Simulator type tool, in the MTRC, the calculator asks about training hours on the following page. This question could be asked if those traning questions are removed, for example if this tool is adapted to once again assume that people facing work requirements either get or don't get the training they need to meet work requirements, rather than asking them and comparing those answer to work requirements.?>
		<div class="alternate">
			<div class="checkbox">
				<label for="snap_training"><input class="check" type="checkbox" id="snap_training" enabled_when_checked="fsp" name="snap_training" <?php if($_SESSION['snap_training']) echo 'checked' ?>>&nbsp;Are you or other people in your household attending training or other opportunities to satisfy SNAP work requirements?</label> 
			</div>
		</div>
	<?php } ?>
<?php } ?>

<!-- PUBLIC HEALTH INSURANCE -->

<input type="checkbox" id="hlth" name="hlth" <?php if($_SESSION['hlth']) echo 'checked' ?>>&nbsp;<label for="hlth"><?php echo $_SESSION['medicaid_name'] ?></label><?php //echo $notes_table->add_note('page4_hlth'); echo $help_table->add_help('page4_hlth'); ?><br />

<!-- SECTION 8 -->

<input type="checkbox" id="sec8" name="sec8" <?php if($_SESSION['sec8']) echo 'checked' ?>>&nbsp;<label for="sec8"><?php echo $_SESSION['sec8_name'] ?></label><?php //echo $notes_table->add_note('page4_sec8'); echo $help_table->add_help('page4_sec8'); ?><br />

<!-- TANF -->

<?php if(($_SESSION['child_number_mtrc'] >= 1 && $_SESSION['state'] == 'NH') || ($_SESSION['child_number_mtrc'] + $potential_adult_children >= 1 && $_SESSION['state'] == 'PA') || ($_SESSION['state'] != 'NH' && $_SESSION['state'] != 'PA')) { #NH does not provide TANF benefits to childless adults. PA does not either, but does allow for 18-year-olds to be considered children.?>

	<input type="checkbox" id="tanf" name="tanf" <?php if($_SESSION['tanf']) echo 'checked' ?>>&nbsp;<label for="tanf"><?php echo $_SESSION['tanf_name']?></label><?php //echo $notes_table->add_note('page4_tanf'); echo $help_table->add_help('page4_tanf'); ?><br />
	<?php if($_SESSION['state'] == 'DC' && $_SESSION['year'] == 2017) { ?>
		</div>
			<i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Additional questions about the family's TANF involvement:</i>
			<div class="alternate">
				<div class="checkbox">
					<label for="tanfentryreq"><input class="check" type="checkbox" id="tanfentryreq" enabled_when_checked="tanf" name="tanfentryreq" <?php if($_SESSION['tanfentryreq']) echo 'checked' ?>>Calculate TANF eligibility based on requirements for program entry, rather than program exit?</label>
				</div>
			</div>

		<div class="alternate">
				<div class="checkbox">
					<label for="sanctioned"><input class="check" type="checkbox" id="sanctioned" enabled_when_checked="tanf" name="sanctioned" <?php if($_SESSION['sanctioned']) echo 'checked' ?>>Is the family facing TANF sanctions due to noncompliance with TANF rules?</label>
				</div>
			</div>
			<div class="alternate">
				<div class="checkbox">
					<label for="tanfwork"><input class="check" type="checkbox" id="tanfwork" enabled_when_checked="tanf" name="tanfwork" <?php if($_SESSION['tanfwork']) echo 'checked' ?>>Do parents in the family satisfy TANF work requirements?</label>
				</div>
			</div>
			<div class="alternate">
				<div class="checkbox">
					<label for="travelstipends"><input class="check" type="checkbox" id="travelstipends" enabled_when_checked="tanf" name="travelstipends" <?php if($_SESSION['travelstipends']) echo 'checked' ?>>While on TANF, is the family eligible for transit stipends?</label>
				</div>
			</div>
			<div class="alternate">
				<div class="checkbox">
					<label for="workbonuses"><input class="check" type="checkbox" id="workbonuses" enabled_when_checked="tanf" name="workbonuses" <?php if($_SESSION['workbonuses']) echo 'checked' ?>>While on TANF and working, is the family eligible for work bonuses? </label>
				</div>
			</div> 

	<?php } ?>
<?php } ?>

<?php if($_SESSION['state'] == 'DC' && $_SESSION['year'] == 2017 && $simulator->alternates()) { ?> <!-- seeing if this works to show during stage, hide during live.-->

    <div class="alternate">
        <div class="checkbox"><label for="workexpense_ded_alt"><input class="check" type="checkbox" id="workexpense_ded_alt" enabled_when_checked="tanf" name="workexpense_ded_alt" <?php if($_SESSION['workexpense_ded_alt']) echo 'checked' ?>>&nbsp;</label>
            <label for="workexpense_ded_user_input"><b>Policy Change: </b>Alter value of the TANF work expense deduction from $160 to $</label>
            <input class="validate-number validate-min0" name="workexpense_ded_user_input" id="workexpense_ded_user_input" enabled_when_checked="tanf" size="3" maxlength="3" value="<?php echo $_SESSION['workexpense_ded_user_input'] ?>" type="text">
        </div>
    </div>
	
    <div class="alternate">
        <div class="checkbox">  <label for="earnedincome_dis_alt"><input class="check" type="checkbox" id="earnedincome_dis_alt" enabled_when_checked="tanf" name="earnedincome_dis_alt" <?php if($_SESSION['earnedincome_dis_alt']) echo 'checked' ?>></label>
            <label for="earnedincome_dis_user_input"><b>Policy Change: </b>Alter value of the TANF earned income disregard from 2/3 of income to  &nbsp; &nbsp; </label> &nbsp; &nbsp;
            <input class="validate-number validate-min0 validate-max100" name="earnedincome_dis_user_input" id="earnedincome_dis_user_input" enabled_when_checked="tanf" size="2" maxlength="3" value="<?php echo $_SESSION['earnedincome_dis_user_input'] ?>" type="text"> %
        </div>
    </div>
	
    <div class="alternate">
        <div class="checkbox"><label for="tanf_perchild_cc_ded_alt"><input class="check" type="checkbox" id="tanf_perchild_cc_ded_alt" enabled_when_checked="tanf" name="tanf_perchild_cc_ded_alt" <?php if($_SESSION['tanf_perchild_cc_ded_alt']) echo 'checked' ?>></label>
            <label for="tanf_perchild_cc_ded_user_input"><b>Policy Change: </b>Alter value of the TANF dependent care deduction for incapacitated adults or children two or older from $175 to &nbsp; &nbsp; $</label>
            <input class="validate-number validate-min0" name="tanf_perchild_cc_ded_user_input" id="tanf_perchild_cc_ded_user_input" enabled_when_checked="tanf" size="3" maxlength="3" value="<?php echo $_SESSION['tanf_perchild_cc_ded_user_input'] ?>" type="text">
        </div>
    </div>
	
    <div class="alternate">
        <div class="checkbox"><label for="tanf_perchild0or1_cc_ded_alt"><input class="check" type="checkbox" id="tanf_perchild0or1_cc_ded_alt" enabled_when_checked="tanf" name="tanf_perchild0or1_cc_ded_alt" <?php if($_SESSION['tanf_perchild0or1_cc_ded_alt']) echo 'checked' ?>></label>
            <label for="tanf_perchild0or1_user_input"><b>Policy Change: </b>Alter value of the TANF dependent care deduction for children younger than two from $200 to $</label>
            <input class="validate-number validate-min0" name="tanf_perchild0or1_user_input" id="tanf_perchild0or1_user_input" enabled_when_checked="tanf" size="3" maxlength="3" value="<?php echo $_SESSION['tanf_perchild0or1_user_input'] ?>" type="text">
        </div>
    </div>

<?php } ?>

<?php if($_SESSION['year'] >= 2015) { ?>

    <!-- Lifeline -->
    <input type="checkbox" id="lifeline" name="lifeline" <?php if($_SESSION['lifeline']) echo 'checked' ?>>&nbsp;<label for="lifeline" ><?php echo $_SESSION['lifeline_name'] ?></label><?php //echo $notes_table->add_note('page4_lifeline'); echo $help_table->add_help('page4_lifeline'); ?><br />

<?php } ?>

<!-- LIHEAP (post-2017 tools, including DC, KY, NH, others) -->
<?php if ($_SESSION['year'] >= 2017) { ?>
	<input type="checkbox" id="liheap" name="liheap" <?php if($_SESSION['liheap']) echo 'checked' ?>>&nbsp;<label for="liheap" ><?php echo $_SESSION['liheap_name']?></label><?php //echo $notes_table->add_note('page4_liheap'); echo $help_table->add_help('page4_liheap'); ?><br />
<?php } ?>
			

<!-- EAP (NH) -->
<?php if ($_SESSION['state'] == 'NH') { ?>
	<input type="checkbox" id="eap" name="eap" <?php if($_SESSION['eap']) echo 'checked' ?>>&nbsp;<label for="eap" ><?php echo $_SESSION['eap_name'] ?></label><?php //echo $notes_table->add_note('page4_liheap'); echo $help_table->add_help('page4_liheap'); ?><br />
<?php } ?>

<!--WIC-->

<?php if($_SESSION['year'] >= 2017 && $_SESSION['children_under5'] > 0) { ?>
	<input type="checkbox" id="wic" name="wic" <?php if($_SESSION['wic']) echo 'checked' ?>>&nbsp;<label for="wic" ><?php echo $_SESSION['wic_name'] ?></label><?php //echo $notes_table->add_note('page4_wic'); echo $help_table->add_help('page4_wic'); ?><br />
	
	<?php if ($_SESSION['child1_age']==0 || $_SESSION['child2_age']==0  || $_SESSION['child3_age']==0  || $_SESSION['child4_age']==0  || $_SESSION['child5_age']==0) { ?>
		<div class="alternate">
		<div class="checkbox">
		<label for="breastfeeding"><input class="check" type="checkbox" id="breastfeeding" enabled_when_checked="wic" name="breastfeeding" <?php if($_SESSION['breastfeeding']) echo 'checked' ?>>&nbsp;To help better estimate WIC benefits, please check here if you or someone else in your household is breastfeeding infant children.</label> 
			</div>
		</div>
	<?php } ?>

<?php } ?>

<!--SSI-->
<?php if($_SESSION['year'] >= 2017 && $disability_count > 0) { ?>
	<input type="checkbox" id="ssi" name="ssi" <?php if($_SESSION['ssi']) echo 'checked' ?>>&nbsp;<label for="ssi" ><?php echo $_SESSION['ssi_name'] ?> </label><?php //echo $notes_table->add_note('page4_ssi'); echo $help_table->add_help('page4_ssi'); ?><br />
	
	<?php if($_SESSION['state'] != 'PA' && $_SESSION['state'] != 'DC' && $_SESSION['state'] != 'ME') { ?>
	
		<input type="checkbox" id="ssp" name="ssp" <?php if($_SESSION['ssp']) echo 'checked' ?>>&nbsp;<label for="ssp" ><?php echo $_SESSION['ssp_name']?> </label><?php //echo $notes_table->add_note('page4_ssi'); echo $help_table->add_help('page4_ssi'); ?><br />
	<?php } else {
		$_SESSION['ssp'] = 0; #Allegheny County DHS has requested we do not include an option for SSP as it's confusing. But the way the Perl codes work, entering "SSI" will include the boost for SSP coverage in PA, which is how Allegheny County (PA), DC, and ME has requested it.
	}
	?>
<?php } ?>

<!--prek-->

<?php if($_SESSION['state'] == 'DC' && $_SESSION['year'] == 2017) { ?> <!--I can't remember why I put prek_mtrc below insead of just using this input. Keeping it here for now, may reorgnize later.--> 
	<input type="checkbox" id="prek" name="prek" <?php if($_SESSION['prek']) echo 'checked' ?>>&nbsp;<label for="prek" >Pre-Kindergarten (PreK)</label><?php //echo $notes_table->add_note('page4_prek'); echo $help_table->add_help('page4_prek'); ?><br />
<?php } ?>

<!--User prototype fields. When finalizing what state-level programs should be listed here, remove _mtrc suffix and replace condition with year and state designation-->

<input type="checkbox" id="ui" name="ui" <?php if($_SESSION['ui']) echo 'checked' ?>>&nbsp;<label for="ui" ><?php echo $_SESSION['ui_name'] ?></label><?php //echo $notes_table->add_note('page4_prek'); echo $help_table->add_help('page4_prek');t ?><br/>

<?php if ($children_whoare3or4 > 0) { ?>
	<?php if ($_SESSION['state'] == 'DC' || $_SESSION['state'] == 'PA' || ($_SESSION['state'] == 'ME' && $_SESSION['children_under5'] - $children_under4)) { #Whether to include this program varies depending on whether a state offers a fairly prevalent, free pre-K program, and age must also be considered. There are not really any pre-k options in NH outside of child care, but DC and PA have programs for 3-4 year olds, and Maine has a program for 4-year-olds.?>
		<input type="checkbox" id="prek_mtrc" name="prek_mtrc" <?php if($_SESSION['prek_mtrc']) echo 'checked' ?>>&nbsp;<label for="prek" ><?php echo $_SESSION['prek_name']?> </label><?php //echo $notes_table->add_note('page4_prek'); echo $help_table->add_help('page4_prek');t ?><br />
	<?php } ?>

	<input type="checkbox" id="headstart" name="headstart" <?php if($_SESSION['headstart']) echo 'checked' ?>>&nbsp;<label for="headstart">Head Start</label><?php //echo $notes_table->add_note('page4_prek'); echo $help_table->add_help('page4_prek');t ?><br />
<?php } ?>

<?php if ($children_under4 > 0) { ?>
	<input type="checkbox" id="earlyheadstart" name="earlyheadstart" <?php if($_SESSION['earlyheadstart']) echo 'checked' ?>>&nbsp;<label for="earlyheadstart" >Early Head Start</label><?php //echo $notes_table->add_note('page4_prek'); echo $help_table->add_help('page4_prek');t ?><br />

<?php } ?>
	

<!--afterschool-->

<?php if ($_SESSION['child_number_mtrc'] > 0) { ?>

	<?php if($_SESSION['state'] == 'DC' && $_SESSION['year'] >= 2017 && $_SESSION['schoolage_children_under13'] > 0) { ?>
		<input type="checkbox" id="ostp" name="ostp" <?php if($_SESSION['ostp']) echo 'checked' ?>>&nbsp;<label for="ostp" >Afterschool (Out of School Time Program)</label><?php //echo $help_table->add_help('page4_prek'); ?> <br/>
	<?php } ?>


	<!--NSBP-->

	<?php if($_SESSION['year'] >= 2017) { ?>
		<input type="checkbox" id="nsbp" name="nsbp" <?php if($_SESSION['nsbp']) echo 'checked' ?>>&nbsp;<label for="nsbp" ><?php echo $_SESSION['sbp_name']?></label><?php //echo $notes_table->add_note('page4_nsbp'); echo $help_table->add_help('page4_nsbp'); ?><br/>
	<?php } ?>

	<!--FRPL-->

	<?php if($_SESSION['year'] >= 2017) { ?>
		<input type="checkbox" id="frpl" name="frpl" <?php if($_SESSION['frpl']) echo 'checked' ?>>&nbsp;<label for="frpl" ><?php echo $_SESSION['frpl_name']?></label><?php //echo $notes_table->add_note('page4_frpl'); echo $help_table->add_help('page4_frpl'); ?><br/>
	<?php } ?>

	<!--FSMP-->

	<?php if($_SESSION['year'] >= 2017) { ?>
		<input type="checkbox" id="fsmp" name="fsmp" <?php if($_SESSION['fsmp']) echo 'checked' ?>>&nbsp;<label for="fsmp" ><?php echo $_SESSION['sfsp_name']?></label><?php //echo $notes_table->add_note('page4_fsmp'); echo $help_table->add_help('page4_fsmp'); ?><br/>
	<?php } ?>

<?php } ?>

<!-- Federal Tax Credits -->

<?php if ($_SESSION['user_prototype'] == 1) { ?>
	<br/>
	<div style="margin:3px 0;">In addition to the above programs, the calculator will determine the amount of any federal and state income tax credits that you are eligible to receive.</div> <!-- not returning the outputs page, so am coding these into frs.pm for now, and returning to this later. May be similar issue with inability to set defaults.-->
	<?php
	$_SESSION['eitc'] = 1;
	$_SESSION['ctc'] = 1;
	$_SESSION['cadc'] = 1;
	$_SESSION['premium_tax_credit'] = 1;
	$_SESSION['state_cadc']	= 1;
	$_SESSION['familysize_credit'] = 1;	
	?>
	<br/>
	***
	<div style="margin:3px 0;"><b>Some programs gave extra benefits during the COVID-19 pandemic. Some of these extra benefits will end around September 2021, and some will end around December 2021.</b></div> 

	<br/>
	<input type="checkbox" id="exclude_covid_policies_ending_0921" name="exclude_covid_policies_ending_0921" <?php if($_SESSION['exclude_covid_policies_ending_0921']) echo 'checked' ?>>&nbsp;<label for="exclude_covid_policies_ending_0921" ><b>Check here if you want to see what your benefits will be after September 2021.</b></label><br/>
		<script type="text/javascript">
		addLoadEvent(function() { 
			$('exclude_covid_policies_ending_1221').onchange = function()  {
				if($('exclude_covid_policies_ending_1221').checked == true && $('exclude_covid_policies_ending_0921').checked == false) {
					$('exclude_covid_policies_ending_0921').checked = true;
				}
				return false;
			}
		})
		</script>

	<input type="checkbox" id="exclude_covid_policies_ending_1221" enabled_when_checked="exclude_covid_policies_ending_0921" name="exclude_covid_policies_ending_1221" <?php if($_SESSION['exclude_covid_policies_ending_1221']) echo 'checked' ?>>&nbsp;<label for="exclude_covid_policies_ending_1221" ><b>Check here if you want to see what your benefits will be after December 2021. (You can only check this box if you also check the box above.)</b></label><br/>
	
<?php } else { ?>

	<div style="margin:3px 0;">Federal Tax Credits</div>
	<div style="margin-left:16px">

		<!-- EITC -->

		<input type="checkbox" id="eitc" name="eitc" <?php if($_SESSION['eitc']) echo 'checked' ?>>&nbsp;<label for="eitc">Earned Income Tax Credit (EITC)</label><?php //echo $notes_table->add_note('page4_eitc'); echo $help_table->add_help('page4_eitc'); ?><br />

		<!-- CTC -->
		
		<?php if($_SESSION['year'] >= 2006) { ?>
			<input type="checkbox" id="ctc" name="ctc" <?php if($_SESSION['ctc']) echo 'checked' ?>>&nbsp;<label for="ctc" >Child Tax Credit</label><br />
		<?php } ?>

		<!-- CADC -->
		
		<?php if($_SESSION['year'] >= 2006) { ?>
			<input type="checkbox" id="cadc" name="cadc" <?php if($_SESSION['cadc']) echo 'checked' ?>>&nbsp;<label for="cadc" >Child and Dependent Care Tax Credit</label><br />
		<?php } ?>

		<!-- Premium Tax Credit -->
		
		<?php if($_SESSION['year'] >= 2015) { ?>
			<input type="checkbox" id="premium_tax_credit" name="premium_tax_credit" <?php if($_SESSION['premium_tax_credit']) echo 'checked' ?>>&nbsp;<label for="premium_tax_credit" >Premium Tax Credit</label><?php //echo $notes_table->add_note('page4_premium_tax_credit'); echo $help_table->add_help('page4_premium_tax_credit'); ?><br />
		<?php } ?>
			
	</div>

	<?php if(($_SESSION['state'] == 'DE' && $_SESSION['year'] == 2009) || ($_SESSION['state'] != 'MI' && $_SESSION['state'] != 'AL' && $_SESSION['state'] != 'CT' && $_SESSION['state'] != 'FL' && $_SESSION['state'] != 'GA' && $_SESSION['state'] != 'PA' && $_SESSION['state'] != 'TX' && $_SESSION['state'] != 'WA' && $_SESSION['state'] != 'DC' && $_SESSION['state'] != 'MS' && $_SESSION['state'] != 'ND' && $_SESSION['state'] != 'MT')) { ?>
		<div style="margin:3px 0;">State Tax Credits</div>
		<div style="margin-left:16px">
	<?php } ?>		   

		
	<?php if($_SESSION['state'] == 'KY' && $_SESSION['year'] == 2020) { ?>
		<input type="checkbox" id="state_cadc" name="state_cadc" <?php if($_SESSION['state_cadc']) echo 'checked' ?>>&nbsp;<label for="state_cadc">Child and Dependent Care Credit</label><?php //echo $notes_table->add_note('page4_cadc'); echo $help_table->add_help('page4_cadc'); ?><br />
		<script type="text/javascript">
		addLoadEvent(function() { 
			$('state_cadc').onchange = function()  {
				if($('state_cadc').checked == true && $('cadc').checked == false) {
					$('cadc').checked = true;
					alert('Federal CADC must be selected if state CADC is selected.');
				}
				return false;
			}
			$('cadc').onchange = function() {
				if($('cadc').checked == false) {
					if($('state_cadc').checked == true) {
						$('cadc').checked = true;
						alert('Federal CADC must be selected if state CADC is selected.');
					}
				}
				return false;
			}
		})
		</script>
	<?php } ?>

	<?php  if($_SESSION['state'] == 'KY' && $_SESSION['year'] == 2020) { ?>
		<input type="checkbox" id="familysize_credit" name="familysize_credit" <?php if($_SESSION['familysize_credit']) echo 'checked' ?>>&nbsp;<label for="familysize_credit">Family Size Tax Credit</label><br />
	<?php } ?>
	</div>
<?php } ?><br>
<!--<div style="margin:10px 0;"><b><u/>Important note</u>: We know that the above list may not include some benefits that you or members of your household receive, like Medicare or SSDI (Social Security). While hopefully future versions of the tool will include those programs, this version of the tool does not. As a result, the calculations this tool makes will not be as accurate if you or one of your family members are enrolled in these programs.</b></div>-->

<br/>
<!--<p>[<a href="#" id="select_all">Select&nbsp;all</a>]&nbsp;[<a href="#" id="select_none">Select&nbsp;none</a>]</p>-->

	

<!-- END OPTIONS -->
