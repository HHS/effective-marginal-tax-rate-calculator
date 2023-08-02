<?php include("../../inc/headers_sps.php"); ?>
<?php
session_start();
$simulator = Sps_TableFactory::create_table("NCCP_Simulator");
$help_table = Sps_TableFactory::create_table("FRS_Help");

$tools_table = Sps_TableFactory::create_table("NCCP_Tool");
$tool = $tools_table->fetch_item(14);
$page_header = $tool->get_field("header_photo")->get_relative_path();
$page_title = "Basic Needs Budget Calculator";
$page_section = "tools";
$page_layout = "content-left";

if ($_REQUEST['submitall'] || $_REQUEST['submitall_privatehealth']) {
    header("Content-type: application/octet-stream");
    header("Content-Disposition: attachment; filename=\"budgets.csv\"");
    $fo = fopen('php://output', 'w');
    foreach (array('child_support_paid_m', 'savings', 'vehicle1_value', 'vehicle1_owed', 'vehicle2_value', 'vehicle2_owed') as $var) {
        $_SESSION[$var] = 0;
    }
    $choices = 'Values represent budgets for a ';
    if ($_REQUEST['family_structure'] == 1) {
        $choices .= 'single-parent family ';
    } else {
        $choices .= 'two-parent family (second parent ';
        if ($_REQUEST['parent2_max_work'] == 'F') {
            $choices .= 'employed full-time) ';
        } elseif ($_REQUEST['parent2_max_work'] == 'H') {
            $choices .= 'employed part-time) ';
        } else {
            $choices .= 'not employed) ';
        }
    }
    $choices .= sprintf('with %d children, ', ($_REQUEST['child1_age'] == -1 ? 0 : 1) + ($_REQUEST['child2_age'] == -1 ? 0 : 1) + ($_REQUEST['child3_age'] == -1 ? 0 : 1));
    if ($_REQUEST['child2_age'] == -1) {
        $choices .= sprintf('age %d.', $_REQUEST['child1_age']);
    } elseif ($_REQUEST['child3_age'] == -1) {
        $choices .= sprintf('ages %d and %d.', $_REQUEST['child1_age'], $_REQUEST['child2_age']);
    } else {
        $choices .= sprintf('ages %d, %d, and %d.', $_REQUEST['child1_age'], $_REQUEST['child2_age'], $_REQUEST['child3_age']);
    }
    fputcsv($fo, array($choices));
    $labels = array('State', 'Year', 'Residence', 'Rent and Utilities', 'Food', 'Child Care', 'Health Insurance Premiums',
        'Out-of-pocket Medical', 'Transportation', 'Other Necessities', 'Debt', 'Payroll taxes', 'Income taxes (includes credits)',
        'Federal gross income tax liability', 'Federal EITC', 'Federal CADC', 'Federal CTC', 'State gross income tax liability',
        'State EITC Received', 'State CADC Received', 'Renter Credit Received', 'State CTC Received', 'Gross local tax liability',
        'Local EITC Received (CA)', 'Local EIC Received (VT)', 'Local CADC Received', 'State HPTC Received', 'Local Tax Credits',
        'TOTAL', 'Hourly wage');
    fputcsv($fo, $labels);
    foreach ($simulator->get_simulators(0, 1) as $s) {
        $_REQUEST['simulator'] = $s['code'] . $s['year'];
        foreach ($simulator->get_residences($s['code'], $s['year']) as $r) {
            $_REQUEST['residence'] = $r['id'];
            $simulator->input_page_1($_REQUEST);
            $simulator->calc_page_1($_REQUEST);
            $simulator->input_page_2($_REQUEST);
            $simulator->calc_page_2($_REQUEST);
            $_SESSION['hlth_costs_oop_m'] = round($simulator->oop_costs());
            if ($_REQUEST['submitall_privatehealth']) {
                $_SESSION['hlth_plan'] = 'private';
            }
            $results = $simulator->budget();
            $expenses = $results['rent_paid'] + $results['food_expenses'] + $results['child_care_expenses'] +
                    $results['trans_expenses'] + $results['health_expenses'] + $results['other_expenses'] + $results['debt_payment'];
            $total = $expenses + $results['tax_after_credits'] + $results['payroll_tax'];
            if ($_SESSION['family_structure'] == 1 || $_SESSION['parent2_max_work'] == 'N') {
                $hourly_wage = number_format($total / (52 * 40));
            } elseif ($_SESSION['parent2_max_work'] == 'F') {
                $hourly_wage = number_format($total / (52 * 80));
            } else {
                $hourly_wage = number_format($total / (52 * 60));
            }
            $row = array($s['name'],
                $s['year'],
                $r['name'],
                $results['rent_paid'],
                $results['food_expenses'],
                $results['child_care_expenses'],
                $results['health_expenses_before_oop'],
                $_SESSION['hlth_costs_oop'],
                $results['trans_expenses'],
                $results['other_expenses'],
                $results['debt_payment'],
                $results['payroll_tax'],
                $results['tax_after_credits'],
                $results['federal_tax_gross'],
                $results['eitc_recd'],
                $results['cadc_recd'],
                $results['ctc_total_recd'],
                $results['state_tax_gross'],
                $results['state_eic_recd'],
                $results['state_cadc_recd'],
                $results['renter_credit_recd'],
                $results['state_ctc_recd'],
                $results['local_tax'],
                $results['local_eitc_recd'],
                $results['local_eic_recd'],
                $results['local_cadc_recd'],
                $results['state_hptc_recd'],
                $results['local_tax_credits'],
                $total,
                $hourly_wage
            );
            fputcsv($fo, $row);
        }
    }
    fclose($fo);
    return 0;
}

$scripts = array("prototype.js", "scriptaculous.js", "validation.js");

# conditions in which we want to return to page 1:
# -- this is the first request
# -- no simulator has been specified
# -- "reset" was explicitly requested
# -- the user was on the FRS and came back to the budget
if (!$_REQUEST || !$_SESSION['simulator'] || $_REQUEST['reset']) {
    $simulator->load_profile('CA', 2007, 'Default');
    $_SESSION['state'] = '';
    $_SESSION['year'] = '';
    $step = 1;
}

if ($_REQUEST['page'] == 2) {
    $step = 2;
} elseif ($_REQUEST['submit1']) {
    $simulator->input_page_1($_REQUEST);
    $simulator->calc_page_1($_REQUEST);
    $simulator->input_page_2($_REQUEST);
    $simulator->calc_page_2($_REQUEST);
    $simulator->calc_page_6($_REQUEST);
    $_SESSION['hlth_costs_oop_m'] = round($simulator->oop_costs());

    # save the default child care/health settings to session so that we can compare
    # them to user selections later
    $_SESSION['hlth_plan_default'] = $_SESSION['hlth_plan_text'];
    $_SESSION['child_care_default'] = implode('|', array($_SESSION['child1_nobenefit_setting'], $_SESSION['child2_nobenefit_setting'], $_SESSION['child3_nobenefit_setting']));

    $step = 2;
} elseif ($_REQUEST['submit2'] && $_SESSION['mode'] == 'budget') { # if we were just using another tool, don't go to step 2, reset everything
    if ($_REQUEST['hlth_plan_choice'] == 'amount') {
        $_REQUEST['hlth_plan'] = 'amount';
    }
    foreach (array('housing_override', 'food_override', 'trans_override', 'debt_override') as $var) {
        unset($_SESSION[$var]);
    }
    $simulator->input_page_5($_REQUEST);
    $simulator->calc_page_5($_REQUEST);
    $simulator->input_page_6($_REQUEST);
    $simulator->calc_page_6($_REQUEST);
    $simulator->input_page_7($_REQUEST);
    $simulator->calc_page_7($_REQUEST);
    $step = 3;
} else {
    $step = 1;
}

if ($step > 1) {
    # we need to make sure that settings that aren't included in the BBC aren't used
    # (they might still be in the session from using the FRS)
    foreach (array('child_support_paid_m', 'savings', 'vehicle1_value', 'vehicle1_owed', 'vehicle2_value', 'vehicle2_owed') as $var) {
        $_SESSION[$var] = 0;
    }

    # we want to see if the child care/health care selections have been changed by the user

    $results = $simulator->budget();
    $expenses = $results['rent_paid'] + $results['food_expenses'] + $results['child_care_expenses'] +
            $results['trans_expenses'] + $results['health_expenses'] + $results['other_expenses'] + $results['debt_payment'];
    $total = $expenses + $results['tax_after_credits'] + $results['payroll_tax'];
    if ($_SESSION['family_structure'] == 1 || $_SESSION['parent2_max_work'] == 'N') {
        $hourly_wage = number_format($total / (52 * 40));
    } elseif ($_SESSION['parent2_max_work'] == 'F') {
        $hourly_wage = number_format($total / (52 * 80));
    } else {
        $hourly_wage = number_format($total / (52 * 60));
    }
    $minimum_wage = 7.25;
}
?>

<?php include("inc/headers_html.php"); ?>
<link rel="stylesheet" href="frs.css" type="text/css" media="screen" />
<link rel="stylesheet" href="budget.css" type="text/css" media="screen" />

<script type="text/javascript">
    addLoadEvent(function () {
        registerDependencies('main-id')
    })
    addLoadEvent(function () {
        new Validation('main-id')
    })


<?php if ($step == 1) { ?>
        addLoadEvent(function () {
            $('simulator').onchange = function () {
                changeCities();
            }
        })
        addLoadEvent(function () {
            changeCities(<?php echo $_POST['residence'] ?>)
        })
        var cities = new Array();
    //var default_cities = new Array();
    <?php
    foreach ($simulator->get_simulators(0, 1) as $s) {
        $residences = array();
        foreach ($simulator->get_residences($s['code'], $s['year']) as $i => $r) {
            array_push($residences, sprintf('"%s","%s"', $r['id'], html_entity_decode($r['name'], ENT_QUOTES, 'UTF-8')));
            /*
              if($r['is_default']) {
              echo "default_cities['${s['code']}${s['year']}'] = $i;\n";
              }
             */
        }
        $residence_string = join(',', $residences);
        ?>
            cities['<?php echo $s['code'] . $s['year'] ?>'] = new Array("", "Select a Location", <?php echo $residence_string ?>)

    <?php } ?>
<?php } ?>

    function changeCities(currentSelection)
    {
        simulator_box = document.forms['main'].simulator
        residence_box = document.forms['main'].residence
        code = simulator_box.options[simulator_box.selectedIndex].value
        if (!code) {
            residence_box.disabled = true
            return
        }
        list = cities[code]
        residence_box.options.length = 0
        for (i = 0; i < list.length; i += 2)
        {
            residence_box.options[i / 2] = new Option(list[i + 1], list[i])
            if (currentSelection == list[i]) {
                residence_box.selectedIndex = i / 2
            }
        }
        residence_box.disabled = false
        /*
         if(!currentSelection) {
         residence_box.selectedIndex = default_cities[code];
         }
         */
    }

    function toggleTaxes()
    {
        $('taxtable').toggle();
        if ($('tax-toggle').innerHTML == '[show detail]')
            $('tax-toggle').innerHTML = '[hide detail]';
        else
            $('tax-toggle').innerHTML = '[show detail]';
    }
</script>

<?php include("inc/headers_page.php"); ?>
<?php include("inc/menu.php"); ?>

<form id="main-id" name="main" action="<?php echo $_SERVER['PHP_SELF'] ?>" method="post">
    <input type="hidden" name="mode" value="budget" />

    <div class="grid_12">
        <div id="content" class="content grid_8 alpha">

            <h1>
                            <?php if ($step > 1) { ?>
                    <input class="submit" type="submit" name="reset" style="float:right" value="Reset" />
                            <?php } ?>
                            <?php echo $page_title ?>
            </h1>
                            <?php if ($step == 1) { ?>
                                <?php echo $assets_table->fetch('budget_intro_text') ?>			        	
                <h2>
                    Select Location and Family Characteristics
                </h2>
                <table border="0" cellspacing="0" cellpadding="4">
                    <tr>
                        <td>State</td>
                        <td>
                            <select name="simulator" id="simulator" class="required">
                                <option value="">Select a State</option>
    <?php
    $sim_states = $simulator->get_simulators(0, 1);
    foreach ($sim_states as $s) {
        /****
        display name + year to all
        if ($simulator->preview_user() || $simulator->stage_user()) {
            $display = $s['name'] . ' ' . $s['year'];
        } else {
            $display = $s['name'];
        } */
        
        $display = $s['name'] . ' ' . $s['year'];
	
        printf('<option value="%s" %s>%s</option>', $s['code'] . $s['year'], ($s['code'] . $s['year'] == $_SESSION['state'] . $_SESSION['year'] ? 'selected' : ''), $display);
    
	
	}
    ?>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>City/County</td>
                        <td>
                            <select name="residence" id="residence" class="required" disabled="disabled">
                                <option value="">Select a Location</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>Family Structure</td>
                        <td>
                            <label for="family_structure_1"><input id="family_structure_1" type="radio" name="family_structure" value="1" <?php if (!$_SESSION['family_structure'] || $_SESSION['family_structure'] == 1) echo 'checked="checked"' ?> />&nbsp;Single-parent</label>
                            &nbsp;&nbsp;
                            <label for="family_structure_2"><input id="family_structure_2" type="radio" name="family_structure" value="2" <?php if ($_SESSION['family_structure'] == 2) echo 'checked="checked"' ?> />&nbsp;Two-parent</label>
                        </td>

                    <tr> 
                        <td><label for="parent2_max_work">Employment of second parent</label></td>
                        <td> 
                            <select name="parent2_max_work" id="parent2_max_work" enabled_when_checked="family_structure_2" >
                                <option value="F" <?php if ($_SESSION['parent2_max_work'] == 'F') echo 'selected' ?>>Full time</option>
                                <option value="H" <?php if ($_SESSION['parent2_max_work'] == 'H') echo 'selected' ?>>Part time</option>
                                <option value="N" <?php if ($_SESSION['parent2_max_work'] == 'N') echo 'selected' ?>>Not employed</option>
                            </select>
                        </td>
                    </tr>
                    <tr> 
                        <td><label for="child1_age">Age of first child</label></td>
                        <td> 
                            <select name="child1_age" id="child1_age">
    <?php
    for ($i = 1; $i < 18; $i++) {
        printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child1_age'] == $i ? 'selected' : ''), $i);
    }
    ?>
                            </select>
                        </td>
                    </tr>
                    <tr> 
                        <td><label for="child2_age">Age of second child</label></td>
                        <td> 
                            <select name="child2_age" id="child2_age">
                                <option value="-1">No second child</option>
                <?php
                for ($i = 1; $i < 18; $i++) {
                    printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child2_age'] == $i ? 'selected' : ''), $i);
                }
                ?>
                            </select>
                        </td>
                    </tr>
                    <tr> 
                        <td><label for="child3_age">Age of third child</label></td>
                        <td> 
                            <select name="child3_age" id="child3_age">
                                <option value="-1">No third child</option>
    <?php
    for ($i = 1; $i < 18; $i++) {
        printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child3_age'] == $i ? 'selected' : ''), $i);
    }
    ?>
                            </select>
                        </td>
                    </tr>
                </table>
                <input class="submit" style="float:right;" type="submit" name="submit1" value="Calculate Budget" />
                                <?php if ($simulator->stage_user()) { ?>
                    <input class="submit" style="float:right;margin-right:10px" type="submit" name="submitall" value="All States" />
                    <input class="submit" style="float:right;margin-right:10px" type="submit" name="submitall_privatehealth" value="All States (private health insurance)" />
                                <?php } ?>
                <br class="clearing" />
                            <?php } ?>

                            <?php if ($step > 1) { ?>
                                <?php if ($results['continue'] != 0) { ?>
                    <p><strong>CALCULATOR ENCOUNTERED PROBLEMS AND HAD TO STOP BEFORE SOLUTION WAS FOUND - THESE RESULTS ARE NOT RELIABLE</strong></p>
                                <?php } ?>

                <table class="budget-top" width="513">
                    <col style="width:313px" />
                    <col style="width:100px" />
                    <col style="width:100px" />
                    <tr class="title">
                        <td colspan="3" style="text-align: left">
                            <strong>Basic Needs Budget:
    <?php
    echo $_SESSION['residence_name'] . ', ' . $_SESSION['state'] . ' (' . $_SESSION['year'] . ')</strong><br/>';
    echo ($_SESSION['family_structure'] == 1 ? 'Single-parent' : 'Two-parent') . ' family with ';
    echo $_SESSION['child_number'];
    echo ($_SESSION['child_number'] == 1 ? ' child, age ' : ' children, ages ');
    echo $_SESSION['child1_age'];
    if ($_SESSION['child2_age'] != -1 && $_SESSION['child3_age'] != -1) {
        echo ', ' . $_SESSION['child2_age'] . ' and ' . $_SESSION['child3_age'];
    } elseif ($_SESSION['child2_age'] != -1) {
        echo ' and ' . $_SESSION['child2_age'];
    } elseif ($_SESSION['child3_age'] != -1) {
        echo ' and ' . $_SESSION['child3_age'];
    }

    if ($_SESSION['family_structure'] == 2) {
        if ($_SESSION['parent2_max_work'] == 'N') {
            echo "<br/>(one parent works full-time, one parent not employed)";
        } elseif ($_SESSION['parent2_max_work'] == 'F') {
            echo "<br/>(both parents work full-time)";
        } else {
            echo "<br/>(one parent works full-time, one parent works part-time)";
        }
    }
    ?>
                        </td>
                    </tr>
                    <tr class="header">
                        <th>&nbsp;</th>
                        <th style="text-align: right;">Annual</th>
                        <th style="text-align: right;">Monthly</th>
                    </tr>
                    <tr class="alt">
                        <th>Rent and utilities</th>
                        <td>$<?php echo number_format($results['rent_paid']) ?></td>
                        <td>$<?php echo number_format($results['rent_paid'] / 12) ?></td>
                    </tr>
                    <tr>
                        <th>Food</th>
                        <td>$<?php echo number_format($results['food_expenses']) ?></td>
                        <td>$<?php echo number_format($results['food_expenses'] / 12) ?></td>
                    </tr>
                    <tr class="alt">
                        <th>
                            Child care
    <?php
    if ($_SESSION['child_care_default'] == implode('|', array($_SESSION['child1_nobenefit_setting'], $_SESSION['child2_nobenefit_setting'], $_SESSION['child3_nobenefit_setting']))) {
        echo '<br/><span style="font-weight: 400;">(center-based)</a>';
    } else {
        echo '<br/><span style="font-weight: 400;">(user selection)</a>';
    }
    ?>
                        </th>
                        <td>$<?php echo number_format($results['child_care_expenses']) ?></td>
                        <td>$<?php echo number_format($results['child_care_expenses'] / 12) ?></td>
                    </tr>
                    <tr>
                        <th>
                            Health insurance premiums
                            <br/><span style="font-weight:400">(<?php echo ($_SESSION['hlth_plan_text'] == '(non-public)' ? 'user-entered' : $_SESSION['hlth_plan_text']) ?>)</span>
                        </th>
                        <td>$<?php echo number_format($results['health_expenses_before_oop']) ?></td>
                        <td>$<?php echo number_format($results['health_expenses_before_oop'] / 12) ?></td>
                    </tr>
                    <tr class="alt">
                        <th>Out-of-pocket medical</th>
                        <td>$<?php echo number_format($_SESSION['hlth_costs_oop_m'] * 12) ?></td>
                        <td>$<?php echo number_format($_SESSION['hlth_costs_oop_m']) ?></td>
                    </tr>
                    <tr>
                        <th>Transportation</th>
                        <td>$<?php echo number_format($results['trans_expenses']) ?></td>
                        <td>$<?php echo number_format($results['trans_expenses'] / 12) ?></td>
                    </tr>
                    <tr class="alt">
                        <th>Other necessities</th>
                        <td>$<?php echo number_format($results['other_expenses']) ?></td>
                        <td>$<?php echo number_format($results['other_expenses'] / 12) ?></td>
                    </tr>
                    <tr>
                        <th>Debt</th>
                        <td>$<?php echo number_format($results['debt_payment']) ?></td>
                        <td>$<?php echo number_format($results['debt_payment'] / 12) ?></td>
                    </tr>
                    <tr class="alt">
                        <th>Payroll taxes</th>
                        <td>$<?php echo number_format($results['payroll_tax']) ?></td>
                        <td>$<?php echo number_format($results['payroll_tax'] / 12) ?></td>
                    </tr>
                    <tr>
                        <th>
                            Income taxes (includes credits)<?php echo $help_table->add_help('budget_taxes') ?><br/>
                            <a id="tax-toggle" href="javascript:void(0)" onclick="toggleTaxes();" >[show detail]</a>
                        </th>
                        <td>$<?php echo number_format($results['tax_after_credits']) ?></td>
                        <td>$<?php echo number_format($results['tax_after_credits'] / 12) ?></td>
                    </tr>
                </table>
                <table id="taxtable" class="budget-taxes" style="display:none" width="513">
                    <col style="width:313px" />
                    <col style="width:100px" />
                    <col style="width:100px" />
                    <tr>
                        <td>Federal gross income tax liability</td>
                        <td>$<?php echo number_format($results['federal_tax_gross']) ?></td>
                        <td>$<?php echo number_format($results['federal_tax_gross'] / 12) ?></td>
                    </tr>
                    <tr>
                        <td>Federal Earned Income Tax Credit</td>
                        <td>-$<?php echo number_format($results['eitc_recd']) ?></td>
                        <td>-$<?php echo number_format($results['eitc_recd'] / 12) ?></td>
                    </tr>
                    <tr>
                        <td>Federal Child Tax Credit</td>
                        <td>-$<?php echo number_format($results['ctc_total_recd']) ?></td>
                        <td>-$<?php echo number_format($results['ctc_total_recd'] / 12) ?></td>
                    </tr>
                    <tr>
                        <td>Federal Child and Dependent Care Tax Credit</td>
                        <td>-$<?php echo number_format($results['cadc_recd']) ?></td>
                        <td>-$<?php echo number_format($results['cadc_recd'] / 12) ?></td>
                    </tr>
                    <?php if ($results['mwp']) { ?>
                        <tr>
                            <td>Making Work Pay Tax Credit</td>
                            <td>-$<?php echo number_format($results['mwp_recd']) ?></td>
                            <td>-$<?php echo number_format($results['mwp_recd'] / 12) ?></td>
                        </tr>
                    <?php } ?>
                    <!--
                                                            <tr>
                                                                    <td>State Child and Dependent Care Tax Credit</td>
                                                                    <td>-$<?php echo number_format($results['state_cadc_recd']) ?></td>
                                                                    <td>-$<?php echo number_format($results['state_cadc_recd'] / 12) ?></td>
                                                            </tr>
                    -->
                    <tr>
                        <td>State gross income tax liability</td>
                        <td>$<?php echo number_format($results['state_tax_gross']) ?></td>
                        <td>$<?php echo number_format($results['state_tax_gross'] / 12) ?></td>
                    </tr>
                    <?php if ($simulator->state_eitc_available()) { ?>
                        <tr>
                            <td>State Earned Income Tax Credit</td>
                            <td>-$<?php echo number_format($results['state_eic_recd']) ?></td>
                            <td>-$<?php echo number_format($results['state_eic_recd'] / 12) ?></td>
                        </tr>
    <?php } ?>
    <?php if ($_SESSION['state'] == 'NY' && $_SESSION['residence'] == 1) { # NEW YORK, NY  ?>
                        <tr>
                            <td>State Child Tax Credit</td>
                            <td>-$<?php echo number_format($results['state_ctc_recd']) ?></td>
                            <td>-$<?php echo number_format($results['state_ctc_recd'] / 12) ?></td>
                        </tr>
    <?php } ?>
    <?php if ($simulator->state_cadc_available()) { ?>
                        <tr>
                            <td>State child care tax credit</td>
                            <td>-$<?php echo number_format($results['state_cadc_recd']) ?></td>
                            <td>-$<?php echo number_format($results['state_cadc_recd'] / 12) ?></td>
                        </tr>
    <?php } ?>
    <?php if ($_SESSION['state'] == 'VT') { ?>
                        <tr>
                            <td>State Renter Rebate</td>
                            <td>-$<?php echo number_format($results['renter_credit_recd']) ?></td>
                            <td>-$<?php echo number_format($results['renter_credit_recd'] / 12) ?></td>
                        </tr>
    <?php } ?>
    <?php if ($_SESSION['state'] == 'NY' && $_SESSION['residence'] == 1) { # NEW YORK, NY  ?>
                        <tr>
                            <td>Local gross income tax liability</td>
                            <td>$<?php echo number_format($results['local_tax']) ?></td>
                            <td>$<?php echo number_format($results['local_tax'] / 12) ?></td>
                        </tr>
                        <tr>
                            <td>Local Earned Income Tax Credit</td>
                            <td>-$<?php echo number_format($results['local_eic_recd']) ?></td>
                            <td>-$<?php echo number_format($results['local_eic_recd'] / 12) ?></td>
                        </tr>
                        <tr>
                            <td>Local child care tax credit</td>
                            <td>-$<?php echo number_format($results['local_cadc_recd']) ?></td>
                            <td>-$<?php echo number_format($results['local_cadc_recd'] / 12) ?></td>
                        </tr>
    <?php } ?>
    <?php if ($_SESSION['state'] == 'CA' && $_SESSION['residence'] == 2) { # SAN FRANCISCO, CA  ?>
                        <tr>
                            <td>Local gross income tax liability</td>
                            <td>$<?php echo number_format($results['local_tax']) ?></td>
                            <td>$<?php echo number_format($results['local_tax'] / 12) ?></td>
                        </tr>
                        <tr>
                            <td>Local Earned Income Tax Credit</td>
                            <td>$<?php echo number_format($results['local_eitc_recd']) ?></td>
                            <td>$<?php echo number_format($results['local_eitc_recd'] / 12) ?></td>
                        </tr>
                            <?php } ?>
                            <?php if ($_SESSION['state'] == 'MI' && $_SESSION['year'] == '2006') { ?>
                        <tr>
                            <td>Local gross income tax liability</td>
                            <td>$<?php echo number_format($results['local_tax']) ?></td>
                            <td>$<?php echo number_format($results['local_tax'] / 12) ?></td>
                        </tr>
    <?php } ?>
                </table>
    <?php if ($hourly_wage < $minimum_wage) { ?>
                    <table class="budget-bottom" width="513">
                        <col style="width:313px" />
                        <col style="width:100px" />
                        <col style="width:100px" />
                        <tr class="total">
                            <th>TOTAL</th>
                            <td><strong>$<?php echo number_format($expenses + $results['tax_after_credits'] + $results['payroll_tax']) ?>*</strong></td>
                            <td><strong>$<?php echo number_format(($expenses + $results['tax_after_credits'] + $results['payroll_tax']) / 12) ?>*</strong></td>
                        </tr>
                        <tr><td colspan="3" class="small">
                                    <?php if ($_SESSION['family_structure'] == 1 || $_SESSION['parent2_max_work'] == 'N') { ?>	
                                    *Meeting this budget requires less than a full-time job<br/>(assuming wages at the federal minimum).
                                    <?php } else { ?>
            <?php if ($_SESSION['parent2_max_work'] == 'F') { ?>
                                        *Meeting this budget requires less than two full-time jobs<br/>(assuming wages at the federal minimum).
            <?php } else { ?>
                                        *Meeting this budget requires less than one full-time job and one part-time job<br/>(assuming wages at the federal minimum).
            <?php } ?>
                    <?php } ?>
                            </td></tr>
                    </table>
                    <br/>
    <?php } else { ?>
                    <table class="budget-bottom" width="513">
                        <col style="width:313px" />
                        <col style="width:100px" />
                        <col style="width:100px" />
                        <tr class="total">
                            <th>TOTAL</th>
                            <td><strong>$<?php echo number_format($expenses + $results['tax_after_credits'] + $results['payroll_tax']) ?></strong></td>
                            <td><strong>$<?php echo number_format(($expenses + $results['tax_after_credits'] + $results['payroll_tax']) / 12) ?></strong></td>
                        </tr>
                        <tr><td colspan="3" class="wage">
                                <div>
        <?php
        if ($_SESSION['family_structure'] == 1 || $_SESSION['parent2_max_work'] == 'N') {
            echo "Hourly wage needed:";
        } else {
            echo "Hourly wage needed (per parent):";
        }
        ?>
                                    <strong>$<?php echo $hourly_wage ?></strong>
                                </div>
                                <div style="margin-top:6px">Percent of the federal poverty level: <strong><?php echo round(($expenses + $results['tax_after_credits'] + $results['payroll_tax']) / $_SESSION['fpl'] * 100) ?>%</strong></div>
                            </td></tr>
                    </table>
                    <br/>
                            <?php } ?>
                <p><a onclick="popup(this, 'scrollbars=1,toolbar=1', 600, 700);
                        return false;" target="blank" href="/popup.php?name=budget_methodology" class="button popup">Budget Methodology</a></p>
                <h2>
                    <input class="submit" style="float:right;margin-bottom:10px;" type="submit" name="submit2" value="Recalculate" />
                    Change Family Expenses
                </h2>
                <table class="change-settings">
                    <tr>
                        <td><a name="rent"></a>Rent and utilities</td>
                        <td>
                            <input type="checkbox" class="check-inline" id="housing_override" name="housing_override" value="1" <?php if ($_SESSION['housing_override'] == 1) echo 'checked' ?> />
                            <label for="housing_override">Use my own amount:</label>
                            $<input class="validate-number" type="text" enabled_when_checked="housing_override" id="housing_override_amt" name="housing_override_amt" size="3" maxlength="4" value="<?php echo $_SESSION['housing_override_amt'] ?>"> per month
                        </td>
                    </tr>
                    <tr>
                        <td><a name="food"></a>Food</td>
                        <td>
                            <input type="checkbox" class="check-inline" id="food_override" name="food_override" value="1" <?php if ($_SESSION['food_override'] == 1) echo 'checked' ?> />
                            <label for="food_override_0">Use my own amount:</label>
                            $<input class="validate-number" type="text" enabled_when_checked="food_override" id="food_override_amt" name="food_override_amt" size="3" maxlength="4" value="<?php echo $_SESSION['food_override_amt'] ?>"> per month
                        </td>
                    </tr>
                    <tr>
                        <td><a name="childcare"></a>Child care</td>
                        <td>
    <?php if ($_SESSION['family_structure'] == 2 && $_SESSION['parent2_max_work'] == 'N') { ?>
                                <p>Children do not need child care when second parent is not employed.</p>
                                <?php } else { ?>
                                <p class="checkset">
                                    <input type="radio" name="child_care_nobenefit_estimate_source" id="spr" value="spr" <?php if ($_SESSION['child_care_nobenefit_estimate_source'] == 'spr') echo 'checked' ?>>
                                    <label>Select calculator estimate by child care setting</label>
                                </p>
                                <table class="indented">
                                        <?php for ($i = 1; $i <= 3; $i++) { ?>
                                            <?php if ($_SESSION["child{$i}_age"] > 0) { ?>
                                            <tr>
                                                <td>
                                                <?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
                                                <?php if ($simulator->child_eligible($i)) { ?>
                                                        <br/>
                                                        <select style="margin-top:4px" id="nobenefit_setting_<?php echo $i ?>" enabled_when_checked="spr" name="child<?php echo $i ?>_nobenefit_setting">
															<?php if ($_SESSION['year'] >= 2017) { ?>	
																<?php foreach ($simulator->child_care_settings($i) as $s) { ?>
																	<option value="<?php echo $s['text'] ?>" <?php if ($_SESSION["child{$i}_nobenefit_setting"] == $s['text']) echo 'selected' ?>><?php echo $s['text'] ?> ($<?php echo $simulator->format($s['spr'], 1) ?>/day)</option>
																<?php } ?>
															<?php } else { ?>
																<?php foreach ($simulator->child_care_settings($i) as $s) { ?>
																	<option value="<?php echo $s['text'] ?>" <?php if ($_SESSION["child{$i}_nobenefit_setting"] == $s['text']) echo 'selected' ?>><?php echo $s['text'] ?> ($<?php echo $simulator->format($s['spr'], 1) ?>/month)</option>
																<?php } ?>
															<?php } ?>
                                                        </select>
												<?php } else { ?>
                                                        not eligible for care
                <?php } ?>
                                            </tr>
            <?php } ?>
        <?php } ?>
                                </table>
                                <p class="checkset">
                                    <input type="radio" name="child_care_nobenefit_estimate_source" id="amt" value="amt" <?php if ($_SESSION['child_care_nobenefit_estimate_source'] == 'amt') echo 'checked' ?>>
                                    <label>Enter cost</label>
                                </p>
                                <table class="indented">
                                    <?php for ($i = 1; $i <= 3; $i++) { ?>
                                        <?php if ($_SESSION["child{$i}_age"] > 0) { ?>
                                            <tr>
                                                <td>
                <?php printf('Child&nbsp;%d&nbsp;(age&nbsp;%d)', $i, $_SESSION["child{$i}_age"]) ?>
                                                </td>
                <?php if ($simulator->child_eligible($i)) { ?>
                                                    <td>
														<?php if ($_SESSION['year'] >= 2017) { ?>	
															$<input class="validate-number" type="text" id="amt_<?php echo $i ?>" enabled_when_checked="amt" name="child<?php echo $i ?>_nobenefit_amt_m" value="<?php echo $_SESSION["child{$i}_nobenefit_amt_m"] ?>" size="3" maxlength="4"> per day
														<?php } else { ?>
 															$<input class="validate-number" type="text" id="amt_<?php echo $i ?>" enabled_when_checked="amt" name="child<?php echo $i ?>_nobenefit_amt_m" value="<?php echo $_SESSION["child{$i}_nobenefit_amt_m"] ?>" size="3" maxlength="4"> per month
														<?php } ?>
                                                   </td>
                <?php } else { ?>
                                                    <td>not eligible for care</td>
                <?php } ?>
                                            </tr>
                                    <?php } ?>
                                <?php } ?>
                                </table>
    <?php } ?>
                        </td>
                    </tr>
                    <tr>
                        <td><a name="healthcare"></a>Health care</td>
                        <td>
                            <input type="radio" name="hlth_plan_choice" id="hlth_plan_default" value="default" <?php if ($_SESSION['hlth_plan'] != 'amount') echo 'checked' ?>>
                            <label for="hlth_plan_default">Select Calculator estimate for premium by insurance type</label>
                            <br/>
                            <select name="hlth_plan" enabled_when_checked="hlth_plan_default" style="margin: 4px 0 10px 24px">
                                <option value="employer">Employer-based plan</option>
    <?php if ($_SESSION['state'] != 'IN'): ?>
                                    <option value="private">Nongroup plan</option>
    <?php endif; ?>
                            </select>
                            <br/>
                            <input type="radio" name="hlth_plan_choice" id="hlth_plan_amount" value="amount" <?php if ($_SESSION['hlth_plan'] == 'amount') echo 'checked' ?>>
                            <label>$<input type="text" id="hlth_amt_family_m" validate="\d{0,4}" error="Family's health costs must be between 0 and 9999" enabled_when_checked="hlth_plan_amount" name="hlth_amt_family_m" size="3" maxlength="4" value="<?php echo $_SESSION['hlth_amt_family_m'] ?>"> per month</label>
                            <br/><br/>
                            Additional out-of-pocket health costs: $<input type="text" id="hlth_costs_oop_m" validate="\d{0,3}" error="Family's out-of-pocket health costs must be between 0 and 999" name="hlth_costs_oop_m" size="3" maxlength="3" value="<?php echo $_SESSION['hlth_costs_oop_m'] ?>"> per month
                        </td>
                    </tr>
                    <tr>
                        <td><a name="transportation"></a>Transportation</td>
                        <td>
                            <input type="checkbox" class="check-inline" id="trans_override" name="trans_override" value="1" <?php if ($_SESSION['trans_override'] == 1) echo 'checked' ?> />
                            <label for="trans_override_0">Use my own amount:</label>
                <?php if ($_SESSION['family_structure'] == 2 && $_SESSION['parent2_max_work'] != 'N') { ?>
                                <p style="margin-left: 24px;margin-bottom:0px;">
                                    Parent 1: $<input class="validate-number" type="text" enabled_when_checked="trans_override" id="trans_override_parent1_amt" name="trans_override_parent1_amt" size="3" maxlength="3" value="<?php echo $_SESSION['trans_override_parent1_amt'] ?>"> per month<br/>
                                    Parent 2: $<input style="margin-top: 4px;" class="validate-number" type="text" enabled_when_checked="trans_override" id="trans_override_parent2_amt" name="trans_override_parent2_amt" size="3" maxlength="3" value="<?php echo $_SESSION['trans_override_parent2_amt'] ?>"> per month (assuming full-time work)
                                </p>
    <?php } else { ?>
                                $<input type="text" enabled_when_checked="trans_override" id="trans_override_parent1_amt" name="trans_override_parent1_amt" size="3" maxlength="3" value="<?php echo $_SESSION['trans_override_parent1_amt'] ?>"> per month
    <?php } ?>
                        </td>
                    </tr>
                    <tr>
                        <td><a name="other"></a>Other necessities</td>
                        <td>
                            <input type="checkbox" class="check-inline" id="other_override" name="other_override" value="1" <?php if ($_SESSION['other_override'] == 1) echo 'checked' ?> />
                            <label for="other_override">Use my own amount:</label>
                            $<input class="validate-number" type="text" enabled_when_checked="other_override" name="other_override_amt" size="3" maxlength="3" value="<?php echo $_SESSION['other_override_amt'] ?>"> per month
                        </td>
                    </tr>
                    <tr>
                        <td><a name="debt"></a>Debt payment</td>
                        <td>
                            <input type="checkbox" class="check-inline" id="debt_override" name="debt_override" value="1" <?php if ($_SESSION['debt_override'] == 1) echo 'checked' ?> />
                            <label for="debt_override">Use my own amount:</label>
                            $<input class="validate-number" type="text" enabled_when_checked="debt_override" name="debt_payment" id="debt_payment" size="3" maxlength="4" value="<?php echo $_SESSION['debt_payment'] ?>"> per month
                        </td>
                    </tr>
                    <tr><td colspan="2" style="text-align:right"><input class="submit" type="submit" name="submit2" value="Recalculate" /></td></tr>
                </table>

<?php } ?>
        </div>
        <div class="sidebar grid_4 omega">
<?php echo $assets_table->fetch('budget_sidebar_text') ?>
            <div id="help-box" class="help">
            </div>
        </div>
    </div>

</form>



<?php include("inc/footers.php"); ?>
