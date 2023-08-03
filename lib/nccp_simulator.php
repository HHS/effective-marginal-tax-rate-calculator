<?php

class NCCP_Simulator extends DB {

    public function __construct() {
        $this->db_name = "frs";
        // TODO: set this to your local path
        $this->frs_directory = '/nccpsps/tools/frs/tools/frs_stage/';
        $this->all_benefits = array('ccdf', 'cc_credit', 'fsp', 'hlth', 'tanf', 'eitc', 'state_eitc', 'local_eitc', 'state_cadc', 'renter_credit', 'local_cadc', 'state_ctc', 'sec8', 'liheap', 'leap', 'mwp', 'mrvp', 'heap', 'lifeline', 'premium_tax_credit', 'ctc', 'cadc', 'wic', 'sanctioned', 'tanfwork', 'travelstipends', 'workbonuses', 'nsbp', 'fsmp', 'prek', 'ostp', 'frpl', 'exclude_covid_policies_ending_0921', 'exclude_covid_policies_ending_1221', 'ssp');
    }

    public function get_dbh() {
        $db = new db($dbhost, 'calcproju', 'G2nK5@x27y2c4f*7jJY$Y', 'calcproj');
        return $db;
    }
    
    # Takes an array of values and saves them to session
    
    public function save_to_session($args) {
        foreach ($args as $name => $value) {
            if ($value == 'on') {
                $_SESSION[$name] = 1;
            } else {
                $_SESSION[$name] = $value;
            }
        }
    }

    public function reset() {
        session_unset();
    }

    public function log_page($number) {
        if (!$this->stage_user()) {
            $dbh = $this->get_dbh();
            $sql = "UPDATE FRS_Log SET last_step = ?, time_end = NOW() WHERE code = ? ";
            $stmt = $dbh->query($sql, array($number + 1, $_SESSION['id']));
        }
    }

    # TODO: At some point need to integrate this with the simulator users table, so that
    # users can only see preview versions of particular states

    public function preview_user() {
        # Determine whether this user is entitled to view alternate policy options
        # (based on the server, the authenticated user, and the state chosen)
        return (preg_match('/\/frs_preview\//', $_SERVER['PHP_SELF']));
    }

    public function office_user() {
        return(preg_match('/^156\.111\.190\.\d+$/', $_SERVER['REMOTE_ADDR']));
    }

    public function stage_user() {
#		if(preg_match('/^207\.38\.169\.235$/', $_SERVER['REMOTE_ADDR'])) {
#			return false; # this is Litza's IP address at home -- for "simulating" the public site!
#		}
        return (preg_match('/(stage|dev|test)\.nccp\.org/', $_SERVER['HTTP_HOST']) ||
                preg_match('/test\.nccp\.org/', $_SERVER['HTTP_HOST']) ||
                preg_match('/development\.nccp\.org/', $_SERVER['HTTP_HOST']));
    }

    public function alternates() {
        return ($this->preview_user() || $this->stage_user());
    }

    # Gets all the default variables for a given state/year/profile
    # from the db and loads them into the session

    public function load_profile($state, $year, $profile) {
        $dbh = $this->get_dbh();
        $sql = "SELECT * FROM FRS_Defaults ";
        $sql .= "WHERE id = ? ";

        $stmt = $dbh->query($sql, array($state . $year . $profile))->fetchAll();
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
//print_r($stmt);
        if ( count( $stmt ) > 0) {
            $session_id = $_SESSION['id'];
            session_unset();
            $_SESSION['id'] = $session_id;
            foreach ($stmt as $hr ) {
                $_SESSION[$hr['name']] = $hr['value'];
            }
            return true;
        } else {
            return false;
        }
    }

    public function run_frs() {
        //$command = '/usr/bin/perl ' . $this->frs_directory . 'lib/frs.pl';
        //$command .= " --dir={$this->frs_directory}";
        
        // TODO: point to local frs.pl
        #1. Replace /Perl64/bin/perl with version of Perl that is operational on the server.
        #2. Replace "/xampp/htdocs/newdir/calculatorapp/family-resource-sim-mtrc/tools/frs_stage" in both the second and third part for where the operational version 
        #old, not working: $command = "/usr/share/perl5 /var/www/html/calculatorapp/family-resource-sim-mtrc/tools/frs_stage/lib/frs.pl --dir=/var/www/html/calculatorapp/family-resource-sim-mtrc/tools/frs_stage/";
        $command = "perl /var/www/html/prod_calc/family-resource-sim-mtrc/tools/frs_stage/lib/frs.pl --dir=/var/www/html/prod_calc/family-resource-sim-mtrc/tools/frs_stage/";		
		
        if ($_SESSION['mode'] == 'single') {
            $command .= " --single";
        }

		#Solution to too many variables on teh command line problem: pare down the SESSION variables sent to the command line to just some essentials. The .pl file stored in the /temp directory will extract the rest.
		#def id="qqfzd8" --def mode="step" --def demo="0" --def state="NH" --def year="2021" --def simulator="NH"
		#$command .= " --def id=\"$_SESSION['id']\"";
        
		foreach (array('id', 'step', 'demo', 'state', 'year', 'simulator') as $name) {
			$command .= " --def $name=\"$_SESSION[$name]\"";
        }
		# $command .= ' --def testshortenedline=1';
		
		#Trying commenting this out, so that we just get the reduced set of variables that are needed to proceed. The 'id' variable is essential because that's what the frs.pl program plugs in to extract the longer set of outputs.
		#foreach ($_SESSION as $name => $value) {
        #    $command .= " --def $name=\"$value\"";
        #}
		if ($_SESSION['test'] == 1) {
			echo $command; #comment out this command to prevent variables from being printed on page 8. For testing purposes, e.g. when running nhtest.php, this will output.
		}
        exec($command, $output, $return);
//         echo '<pre>';
//         var_dump($output);
//         echo '</pre>';
        return $output;
    }

    public function budget() {
        $_SESSION['wage_1'] = 6.55;
        $_SESSION['wage_2'] = 6.55;

        $command = '/usr/bin/perl ' . $this->frs_directory . '/lib/frs.pl';
        $command .= " --dir={$this->frs_directory}";
        $command .= " --budget";
        foreach ($_SESSION as $name => $value) {
            $command .= " --def $name='$value'";
        }
        exec($command, $output, $return);
        $result = array();
        foreach ($output as $line) {
            if (preg_match('/^(.*)\|(.*)$/', $line, $matches)) {
                $result[$matches[1]] = $matches[2];
            }
        }
        return $result;
    }

    /*     * ************************************************************************************ */
    /* GENERAL DATA ACCESS FUNCTIONS                                                       */
    /* The input_page functions fetch the necessary parameters and save them to session    */
    /* These functions should return the page that needs to be output next                 */
    /*     * ************************************************************************************ */

    public function run_test() {
        $_SESSION['mode'] = 'test';
        foreach (array(1, 2, 3, 4, 5, '5a', 6, 7, 8) as $step) {
            $this->{"calc_page_$step"}();
        }
        return 8;
    }

    public function log_start() {
        $_SESSION['id'] = base_convert(time(), 10, 36);
        if (!$this->stage_user()) {
            /*$dbh = $this->get_dbh();
            $sql = "INSERT INTO FRS_Log (time_start, time_end, ip, last_step, code) VALUES (NOW(), NOW(), ?, ?, ?)";
            $stmt = $dbh->query($sql, array($_SERVER['REMOTE_ADDR'], 1, $_SESSION['id']))->fetchArray();*/
        }
    }

	#The following "input_page_[x]" and "calc_page_[x]" functions pertain specifically to the inputs gathered on each of these "[x"] pages. Most of the important calculations occur within the "calc_page_[x]" functions, which include lookups in the MySQL database based on the inputs entered in step [x], which are collected through each of the page_[x].php files.
	
    public function input_page_1($args) {

        # Get the state/year from the input
        if (preg_match('/(\w{2})(\d{4})/', $args['simulator'], $matches)) {
            $state = $matches[1];
            $year = $matches[2];
        }
        # If the state/year wasn't set properly, then we go back to the start
        else {
            return 2;
        }

        # if user chose a new residence (or if there is no vehicle value yet), then reset the value of the vehicle
        # TODO: This doesn't have a value for vehicle_cost at the time that it runs!
        if ($args['residence'] != $_SESSION['residence'] || !isset($_SESSION['vehicle1_value'])) {
            $_SESSION['vehicle1_value'] = $results['vehicle_cost'];
        }

        # Find the mode that was chosen and set defaults accordingly -- 
        # if it was "quick" we go to step 7; if it was "step" we go to 2
        if ($args['mode'] == 'quick') {die;
            $this->load_profile($state, $year, 'Alll But Section 8');
            if ($_REQUEST['residence']) {
                $_SESSION['residence'] = $_REQUEST['residence'];
            }
            $_SESSION['mode'] = 'quick';
            foreach (array(1, 2, 3, 4, 5, '5a', 6, 7, 8) as $step) {
                $this->{"calc_page_$step"}();
            }
            return 8;
        } elseif ($args['mode'] == 'budget') {
            $this->load_profile($state, $year, 'Budget');
            $_SESSION['mode'] = 'budget';
            $_SESSION['residence'] = $args['residence'];
        } else {
            # If the chosen state/year doesn't match the session, or if the other variables aren't yet set, load the defaults into the session
            $this->load_profile($state, $year, 'Default');
            $_SESSION['residence'] = $args['residence'];
            $_SESSION['mode'] = 'step';
            return 2;
        }
    }

    public function calc_page_1() {
        $dbh = $this->get_dbh();

        if ($this->preview_user()) {
            $_SESSION['alternates'] = 1;
        } else {
            unset($_SESSION['alternates']);
        }

        # Find the month of this Simulator
        $sql = "SELECT DISTINCT month FROM FRS_General ";
        $sql .= "WHERE state = ? AND year = ? ";
        $stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year']))->fetchArray();
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        
        $months = array('', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
        $_SESSION['month_name'] = $months[$stmt['month']];

        # Get the full name of the state chosen
        $sql = "SELECT DISTINCT name FROM NCCP_State WHERE code = ?";
        $stmt = $dbh->query($sql, array($_SESSION['state']))->fetchArray();
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        
        $_SESSION['state_name'] = $stmt['name'];

        # get the residence name & other information
        $sql = "SELECT name, vehicle_cost, trans_type FROM FRS_Locations ";
        $sql .= "WHERE state = ? && year = ? && id = ?";
        $results = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $_SESSION['residence']))->fetchArray();
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        $_SESSION['residence_name'] = $results['name'];
        if (strtolower($results['trans_type']) == 'car' || strtolower($results['trans_type']) == 'private') {
            $_SESSION['trans_type'] = 'private';
        } else {
            $_SESSION['trans_type'] = 'public';
        }

		$sql = "SELECT pha_region, schooldays, summerdays, summerweeks, residence_size, publictrans_cost_d, publictrans_cost_max, publictrans_cost_d_dis, publictrans_cost_max_dis, ccdf_region, headstart_cc_program, headstart_length, headstart_age_min, headstart_age_max, headstart_summer, earlyheadstart_cc_program, earlyheadstart_length, earlyheadstart_age_min, earlyheadstart_age_max, earlyheadstart_summer FROM FRS_Locations WHERE state = ? && year = ? && id = ?";
        $stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $_SESSION['residence']))->fetchArray();
		if (!$stmt) {
			//PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
			return array();
		}
		$_SESSION['pha_region'] = $stmt['pha_region'];
		$_SESSION['schooldays'] = $stmt['schooldays'];
		$_SESSION['summerdays'] = $stmt['summerdays'];
		$_SESSION['summerweeks'] = $stmt['summerweeks'];
		$_SESSION['residence_size'] = $stmt['residence_size'];
		$_SESSION['publictrans_cost_d'] = $stmt['publictrans_cost_d'];
		$_SESSION['publictrans_cost_max'] = $stmt['publictrans_cost_max'];
		$_SESSION['publictrans_cost_d_dis'] = $stmt['publictrans_cost_d_dis'];
		$_SESSION['publictrans_cost_max_dis'] = $stmt['publictrans_cost_max_dis'];
		$_SESSION['ccdf_region'] = $stmt['ccdf_region'];
		$_SESSION['headstart_cc_program'] = $stmt['headstart_cc_program'];
		$_SESSION['headstart_length'] = $stmt['headstart_length'];
		$_SESSION['headstart_age_min'] = $stmt['headstart_age_min'];
		$_SESSION['headstart_age_max'] = $stmt['headstart_age_max'];
		$_SESSION['headstart_summer'] = $stmt['headstart_summer'];
		$_SESSION['earlyheadstart_cc_program'] = $stmt['earlyheadstart_cc_program'];
		$_SESSION['earlyheadstart_length'] = $stmt['earlyheadstart_length'];
		$_SESSION['earlyheadstart_age_min'] = $stmt['earlyheadstart_age_min'];
		$_SESSION['earlyheadstart_age_max'] = $stmt['earlyheadstart_age_max'];
		$_SESSION['earlyheadstart_summer'] = $stmt['earlyheadstart_summer'];

		
		$sql = "SELECT percent_nonsocial, percent_work, nonsocialnonwork_portion_public, FRS_Transportation_v2.avg_miles_driven, publictrans_cost_d, publictrans_cost_max, publictrans_cost_d_dis, publictrans_cost_max_dis FROM FRS_Locations LEFT JOIN FRS_Transportation_v2 USING (residence_size, year) WHERE state = ? && year = ? && id = ?";
        $stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $_SESSION['residence']))->fetchArray();
		if (!$stmt) {
			//PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
			return array();
		}
		$_SESSION['percent_nonsocial'] = $stmt['percent_nonsocial'];
		$_SESSION['percent_work'] = $stmt['percent_work'];
		$_SESSION['avg_miles_driven'] = $stmt['avg_miles_driven'];
		$_SESSION['nonsocialnonwork_portion_public'] = $stmt['nonsocialnonwork_portion_public'];		
    }

    public function log_page_1() {
        if (!$this->stage_user()) {
            $dbh = $this->get_dbh();
            $benefits = array();
            if ($_SESSION['mode'] == 'quick') {
                foreach ($this->all_benefits as $flag) {
                    if ($_SESSION[$flag]) {
                        array_push($benefits, $flag);
                    }
                }
                $number = 8;
            } else {
                $number = 2;
            }
            $sql = "UPDATE FRS_Log SET last_step = ?, time_end = NOW(), state = ?, year = ?, residence = ?, mode = ?, benefits = ? WHERE code = ? ";
            $stmt = $dbh->query($sql, array($number, $_SESSION['state'], $_SESSION['year'], $_SESSION['residence'], $_SESSION['mode'], join(',', $benefits), $_SESSION['id']));
        }
    }

    public function input_page_2($args) {
        # if user chose a new family size, set values for vehicle2_value and vehicle2_owed
        if ($_SESSION['family_structure'] == 1 && $args['family_structure'] == 2) {
            $_SESSION['vehicle2_value'] = $_SESSION['vehicle2_owed'] = 0;
        }

        # load the new figures into session
        $this->save_to_session($args);

        return 3;
    }

    public function calc_page_2() {
        $dbh = $this->get_dbh();

        # get the value of smi & fpl based on the family size
        if ($_SESSION['user_prototype'] == 1) {
			$_SESSION['child_number'] = $_SESSION['child_number_mtrc'];
			for ($i = 1; $i <= 5; $i++) {
				if ($i > $_SESSION['child_number']) {
					$_SESSION['child'.$i.'_age'] = -1;
				}
			}			
		} else {
			$_SESSION['child_number'] = 0;
			if ($_SESSION['child1_age'] != -1) {
				$_SESSION['child_number'] ++;
			}
			if ($_SESSION['child2_age'] != -1) {
				$_SESSION['child_number'] ++;
			}
			if ($_SESSION['child3_age'] != -1) {
				$_SESSION['child_number'] ++;
			}
			if ($_SESSION['child4_age'] != -1 && $_SESSION['year'] >= 2017) { #6/11: I believe as written, with square brackets, it may have not been pulling from the array correctly. making this into a year variable and pulling from session year.
				$_SESSION['child_number'] ++;
			}
			if ($_SESSION['child5_age'] != -1 && $_SESSION['year'] >= 2017) { #6/11: same edit as above.
				$_SESSION['child_number'] ++;
			}									  
		}	
        $family_size = $_SESSION['family_structure'] + $_SESSION['child_number'];

        # we're going to get SMI and Max Income from the FRS_General table,
        # but now the FPL values are going to come from the income converter table
        $sql = "SELECT smi, ROUND(smi * smi_percent) as max_income, fpl, passbook_rate FROM FRS_General ";
        $sql .= "WHERE state = ? AND year = ? AND size = ?";
        $stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $family_size))->fetchArray();
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        
        $_SESSION['smi'] = $stmt['smi'];
        if ($_SESSION['mode'] != 'test') {
            $_SESSION['max_income'] = $stmt['max_income'];
        }

        $_SESSION['fpl'] = $stmt['fpl'];
        $_SESSION['passbook_rate'] = $stmt['passbook_rate'];
    //    echo "fpl=".$_SESSION['fpl']."<br/>";
        
        # now that we know the family size, get the rent cost
        $sql = "SELECT rent FROM FRS_Locations ";
        $sql .= "WHERE state = ? && year = ? && id = ? && number_children = ? ";
        $stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $_SESSION['residence'], $_SESSION['child_number']))->fetchArray();
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }

		/*
		#The next batch of code estimates rent based on HUD Fair Market Rents (FMRs). HUD issues FMRs based on the number of bedrooms in a home. These rents are entered into the MySQL database, which outputs rent based on the number of children in a home. The translation of bedrooms to children, initially, is the following, and is based on teh assumption that two adults share a bedroom:
		0 children: 1 br
		1 child:	2 br
		2 children: 2 br
		3 children:	3 br
		4 children: 3 br
		5 children: 4 br
		
		This is based on the common setup of having no more than 2 children in a home. Because we allow up to 4 adults to live in a home in the MTRC, however, we will add a bedroomm in case of 3 adults, and a further bedroom for 4 adults. This follows the assumption we are making that there is only one married couple in the home. While this is a generalization and it may not be appropriate for 2 nonmarried adults or two older children to share a room, it can be adjusted by using further adjustments if partners so wish. To add a bedroom, we follow the following adjustments to FMRs, from  https://www.federalregister.gov/documents/2020/08/14/2020-17717/fair-market-rents-for-the-housing-choice-voucher-program-moderate-rehabilitation-single-room. "HUD derives FMRs for units with more than four bedrooms by adding 15 percent to the four-bedroom FMR for each extra bedroom. For example, the FMR for a five-bedroom unit is 1.15 times the four-bedroom FMR, and the FMR for a six-bedroom unit is 1.30 times the four-bedroom FMR."
		*/
		if ($_SESSION['family_structure'] <= 2) {
			$_SESSION['rent_cost_m'] = $stmt['rent'];
		} else if ($_SESSION['family_structure'] == 3) {
			$_SESSION['rent_cost_m'] = 1.15 * $stmt['rent'];
        } else { #family_structure = 4.
			$_SESSION['rent_cost_m'] = 1.3 * $stmt['rent'];
		}

        $sql = "SELECT fpl FROM FRS_General ";
        $sql .= "WHERE state = ? AND year = ? AND size = ? ";
        $year = $_SESSION['year'];
        
        # if for some reason this year's values haven't been entered, go back to the previous year
        while (!$hr['fpl'] && $year > $_SESSION['year'] - 5) {
            $stmt = $dbh->query($sql, array($_SESSION['state_name'], $year, $family_size))->fetchArray();
            if (!$stmt) {
              //  echo "fpl not available<br/>";
                //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
                return array();
            }
            $year = $year - 1;
            $hr = $stmt->FetchRow();
        }

    }

    public function log_page_2() {
        $this->log_page(2);
    }

    public function input_page_4($args) {
        $this->save_to_session($args);
        return 5;
    }

    public function calc_page_4() {
		if ($_SESSION['mode'] !== 'test') {

			$_SESSION['wage_2'] = $_SESSION['wage_1'];
			if($_POST['child1support'] !== 'on') {
				unset($_SESSION['child1support']);
			}
			if($_POST['child2support'] !== 'on') {
				unset($_SESSION['child2support']);
			}
			if($_POST['child3support'] !== 'on') {
				unset($_SESSION['child3support']);
			}
			if($_POST['child4support'] !== 'on') {
				unset($_SESSION['child4support']);
			}
			if($_POST['child5support'] !== 'on') {
				unset($_SESSION['child5support']);
			}
		}
    }

    public function log_page_4() {
        $this->log_page(4);
    }

    public function input_page_3($args) {
        # turn "off" all policies by default
        foreach (array('ccdf', 'ccdf_alt', 'ccdf_alt_value', 'ccdf_alt_b', 'ccdf_alt_b_value', 'ccdf_alt_c', 'ccdf_alt_d', 'cc_credit', 'fsp', 'fsp_alt', 'fsp_alt_b', 'fsp_alt_c',
    'hlth', 'hlth_alt', 'hlth_alt_b', 'hlth_alt_c', 'tanf', 'tanf_alt', 'tanf_alt_b', 'tanf_alt_c', 'ctc', 'state_ctc',
    'eitc', 'eitc_alt', 'state_eitc', 'state_eitc_alt', 'local_eitc', 'cadc', 'state_cadc', 'local_cadc', 'sec8', 'ccdf_inc_limit_alt',
    'ccdf_inc_limit_user_input', 'ccdf_entrance_povlimit_alt', 'cadc_alt', 'cadc_alt_b', 'state_ctc_alt', 'ctc_alt', 'ctc_alt_value_a',
    'ctc_alt_value_b', 'ctc_alt_value_c', 'ctc_alt_value_d', 'fedtax_alt', 'renter_credit', 'premium_tax_credit','lifeline', 'heap', 'liheap', 'hlth_sci', 'hlth_pak', 'leap', 'mwp', 'mrvp', 'mrvp_alt', 'mrvp_alt_b', 'mrvp_alt_c', 'mrvp_alt_d', 'passthrough_alt', 'noassetlimit_alt', 'novehiclemax_alt', 'medicaid_expansion_alt', 'chp_employer_alt','state_eitc_alt','state_ctc_alt','eitc_user_input','eitc_refundable_alt','eitc_nolimit_alt') as $flag) {
            unset($_SESSION[$flag]);
        }

        $this->save_to_session($args);
        if ($_SESSION['year'] < 2006) {
            $_SESSION['ctc'] = 1;
        }
        return 4;
    }

    public function calc_page_3() {
        $_SESSION['benefits'] = 0;
        foreach ($this->all_benefits as $flag) {
            if ($_SESSION[$flag]) {
                $_SESSION['benefits'] ++;
            }
        }

        if (!$_SESSION['ccdf']) {
            unset($_SESSION['child1_continue_flag']);
            unset($_SESSION['child2_continue_flag']);
            unset($_SESSION['child3_continue_flag']);
        }
        
		if ($_SESSION['mode'] !== 'test' && $_SESSION['mode'] !== 'quick') { #10/11: added additional condition about quick mode.
			$benefits = array( 'tanfentryreq',
								'sanctioned',
								'tanfwork',
								'travelstipends',
								'workbonuses',
								'workexpense_ded_alt',
								'earnedincome_dis_alt',
								'tanf_perchild_cc_ded_alt',
								'tanf_perchild0or1_cc_ded_alt',
								'wic',
								'ssi',
								'prek',
								'ostp',
								'nsbp',
								'frpl',
								'fsmp',
								'ui',
								'prek_mtrc',
								'headstart',
								'earlyheadstart',
								'eap',
								'exclude_abawd_provision',
								'snap_training',
								'exclude_covid_policies_ending_0921',
								'exclude_covid_policies_ending_1221',
								'ssp',
								);
			foreach ($benefits as $benefit) {
				if($_POST[$benefit] !== 'on') {
					unset($_SESSION[$benefit]);
				}
			}
        }
    }

    public function log_page_3() {
        $dbh = $this->get_dbh();
        $benefits = array();
        foreach ($this->all_benefits as $flag) {
            if ($_SESSION[$flag]) {
                array_push($benefits, $flag);
            }
        }
        $sql = "UPDATE FRS_Log SET last_step = ?, benefits = ?, time_end = NOW() WHERE code = ? ";
        $stmt = $dbh->query($sql, array(4, join(',', $benefits), $_SESSION['id']));
    }

    public function input_page_5($args) {
        # turn "off" all _alt policies by default
        foreach (array('halfday_upk_alt', 'fullday_upk_alt', 'fullday_k_alt') as $flag) {
            unset($_SESSION[$flag]);
        }
        $this->save_to_session($args);
        return 6;
        /*
          $needs_5a = 0;
          // We need to display the second page if there are any children that don't continue in the same care
          if($_SESSION['ccdf']) {
          for($i=1; $i<=3; $i++) {
          if($_SESSION["child{$i}_age"] != -1 && $_SESSION["child{$i}_age"] < 13) {
          if($_SESSION["child{$i}_continue_flag"] == 0) {
          $needs_5a++;
          }
          else {
          $_SESSION["child{$i}_continue_setting"] = $_SESSION["child{$i}_withbenefit_setting"];
          }
          }
          }
          if($needs_5a > 0) {
          return '5a';
          }
          else {
          $this->calc_page_5a();
          return 6;
          }
          }
          else { return 6; }
         */
    }

    public function calc_page_5() {
        // Get the cost of care with benefits/without benefits
        for ($i = 1; $i <= 3; $i++) {
            if ($_SESSION["child{$i}_age"] != -1 && $_SESSION["child{$i}_age"] < 13) {
                $_SESSION["child{$i}_withbenefit_cost_m"] = $this->get_spr('Unsubsidized', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
                $_SESSION["child{$i}_nobenefit_cost_m"] = $this->get_spr('Unsubsidized', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
                $_SESSION["child{$i}_continue_cost_m"] = $this->get_spr('Unsubsidized', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);
            }
        }
        if ($_SESSION['year'] >= 2017) { 
			if (!$_SESSION['ccdf']) { #If the user has not selected CCDF, they are not given the options to enter the child care settings that are needed to inform the nobenefit_cost and continue_cost variables requierd for an altenative scenario in which they receive CCDF subsidies. These variables are not needed in scenarios when CCDF remains uninvoked.
				for ($i = 1; $i <= 5; $i++) {
					$_SESSION["child{$i}_withbenefit_setting"] = $_SESSION["child{$i}_nobenefit_setting"];
					$_SESSION["child{$i}_continue_setting"] = $_SESSION["child{$i}_nobenefit_setting"];
				}	
			}
            for ($i = 1; $i <= 5; $i++) {
				#TODO: Once we finish incorporating these variables into the simulators, we need to remove the "_m" suffixes, which initially stood for "per month," but get confusing when different states have market rate studies or SPRs that are tracked per week or day, and not month.
                if ($_SESSION["child{$i}_age"] != -1 && $_SESSION["child{$i}_age"] < 13) {
					#Unsubsidized, full-time:
                    $_SESSION["child{$i}_withbenefit_cost_m"] = $this->get_spr('Unsubsidized', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
                    $_SESSION["child{$i}_nobenefit_cost_m"] = $this->get_spr('Unsubsidized', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
                    $_SESSION["child{$i}_continue_cost_m"] = $this->get_spr('Unsubsidized', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);

					#Unsubsidized, part-time:
                    $_SESSION["child{$i}_withbenefit_cost_m_pt"] = $this->get_spr('parttime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
                    $_SESSION["child{$i}_nobenefit_cost_m_pt"] = $this->get_spr('parttime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
                    $_SESSION["child{$i}_continue_cost_m_pt"] = $this->get_spr('parttime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);

					#Subsidized, full-time:
                    $_SESSION["child{$i}_withbenefit_cost_m_sub"] = $this->get_spr('fulltime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
                    $_SESSION["child{$i}_nobenefit_cost_m_sub"] = $this->get_spr('fulltime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
                    $_SESSION["child{$i}_continue_cost_m_sub"] = $this->get_spr('fulltime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);

					#Subsidized, parttime-time:
                    $_SESSION["child{$i}_withbenefit_cost_m_sub_pt"] = $this->get_spr('parttime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
                    $_SESSION["child{$i}_nobenefit_cost_m_sub_pt"] = $this->get_spr('parttime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
                    $_SESSION["child{$i}_continue_cost_m_sub_pt"] = $this->get_spr('parttime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);
					
					#Possibly specific to New Hampshire: halftime care:
					if ($_SESSION['state'] == 'NH') {						
						$_SESSION["child{$i}_withbenefit_cost_m_sub_ht"] = $this->get_spr('halftime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_nobenefit_cost_m_sub_ht"] = $this->get_spr('halftime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
						$_SESSION["child{$i}_continue_cost_m_sub_ht"] = $this->get_spr('halftime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);

						#School variables. For NH, these are the same starting at age 7, so for now just hard-coding that age. We may need this variable value for younger children. Possibly adjust the database so that it's assigning this value for children older than 7 as well.
						$_SESSION["child{$i}_withbenefit_baschool_cost"] = $this->get_spr('baschool_unsub', 7, $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_nobenefit_baschool_unsub"] = $this->get_spr('baschool_unsub', 7,  $_SESSION["child{$i}_nobenefit_setting"]);
						$_SESSION["child{$i}_continue_baschool_unsub"] = $this->get_spr('baschool_unsub', 7, $_SESSION["child{$i}_continue_setting"]);
						
						$_SESSION["child{$i}_withbenefit_bschoolonly_cost"] = $this->get_spr('bschoolonly_unsub', 7, $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_nobenefit_bschoolonly_unsub"] = $this->get_spr('bschoolonly_unsub', 7,  $_SESSION["child{$i}_nobenefit_setting"]);
						$_SESSION["child{$i}_continue_bschoolonly_unsub"] = $this->get_spr('bschoolonly_unsub', 7, $_SESSION["child{$i}_continue_setting"]);

						$_SESSION["child{$i}_withbenefit_aschoolonly_cost"] = $this->get_spr('aschoolonly_unsub', 7, $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_nobenefit_aschoolonly_unsub"] = $this->get_spr('aschoolonly_unsub', 7,  $_SESSION["child{$i}_nobenefit_setting"]);
						$_SESSION["child{$i}_continue_aschoolonly_unsub"] = $this->get_spr('aschoolonly_unsub', 7, $_SESSION["child{$i}_continue_setting"]);
					}

					if ($_SESSION['state'] == 'DC') {						
						$_SESSION["child{$i}_withbenefit_extendeddayfulltime_sub"] = $this->get_spr('extendeddayfulltime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_withbenefit_extendeddayfulltime_cost"] = $this->get_spr('extendeddayfulltime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_nobenefit_extendeddayfulltime_unsub"] = $this->get_spr('extendeddayfulltime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
						$_SESSION["child{$i}_continue_extendeddayfulltime_unsub"] = $this->get_spr('extendeddayfulltime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);
					
						$_SESSION["child{$i}_withbenefit_extendeddayparttime_sub"] = $this->get_spr('extendeddayparttime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_withbenefit_extendeddayparttime_cost"] = $this->get_spr('extendeddayparttime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_nobenefit_extendeddayparttime_unsub"] = $this->get_spr('extendeddayparttime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
						$_SESSION["child{$i}_continue_extendeddayparttime_unsub"] = $this->get_spr('extendeddayparttime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);

						$_SESSION["child{$i}_withbenefit_nontraditionalfulltime_sub"] = $this->get_spr('nontraditionalfulltime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_withbenefit_nontraditionalfulltime_cost"] = $this->get_spr('nontraditionalfulltime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_nobenefit_nontraditionalfulltime_unsub"] = $this->get_spr('nontraditionalfulltime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
						$_SESSION["child{$i}_continue_nontraditionalfulltime_unsub"] = $this->get_spr('nontraditionalfulltime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);

						$_SESSION["child{$i}_withbenefit_nontraditionalparttime_sub"] = $this->get_spr('nontraditionalparttime', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_withbenefit_nontraditionalparttime_cost"] = $this->get_spr('nontraditionalparttime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_nobenefit_nontraditionalparttime_unsub"] = $this->get_spr('nontraditionalparttime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_nobenefit_setting"]);
						$_SESSION["child{$i}_continue_nontraditionalparttime_unsub"] = $this->get_spr('nontraditionalparttime_unsub', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);

						#School variables. For DC, these are the same starting at age 5, up to 12, so for now just hard-coding at age 7 (same as NH above). We may need this variable value for younger children. Possibly adjust the database so that it's assigning this value for children older than 7 as well.
						$_SESSION["child{$i}_withbenefit_parttimetraditionalbora_sub"] = $this->get_spr('parttimetraditionalbora', 7, $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_withbenefit_parttimetraditionalbora_cost"] = $this->get_spr('parttimetraditionalbora_unsub', 7, $_SESSION["child{$i}_withbenefit_setting"]);
						$_SESSION["child{$i}_nobenefit_parttimetraditionalbora_unsub"] = $this->get_spr('parttimetraditionalbora_unsub', 7, $_SESSION["child{$i}_nobenefit_setting"]);
						$_SESSION["child{$i}_continue_parttimetraditionalbora_unsub"] = $this->get_spr('parttimetraditionalbora_unsub', 7, $_SESSION["child{$i}_continue_setting"]);
					}

                } 
            } 
        } 
    }

    public function log_page_5() {
        $this->log_page(5);
    }

    public function input_page_5a($args) {
        $this->save_to_session($args);
        return 6;
    }

    public function calc_page_5a() {
        for ($i = 1; $i <= 3; $i++) {
            if ($_SESSION["child{$i}_age"] != -1 && $_SESSION["child{$i}_age"] < 13) {
                $_SESSION["child{$i}_continue_cost_m"] = $this->get_spr('Unsubsidized', $_SESSION["child{$i}_age"], $_SESSION["child{$i}_continue_setting"]);
            }
        }
    }

    public function input_page_6($args) {
        
        // unset the userplantype value; it will be reset with save_to_session if it is still checked
        unset($_SESSION['userplantype']);

        $this->save_to_session($args);
        
        if ($_SESSION['year'] >= 2015) { # 6/15: changed this from including state conditions (OH, CO, FL) to include just the year, anticipating that future hlth codes will be similar to the ones we did in 2015 for OH, CO, and FL, and in 2017 for DC 
            // the default value for 'userplantype' is 'employer' if none was given
            if (!$_SESSION['userplantype']) {
                $_SESSION['userplantype'] = 'employer';
            }
        }
        return 7;
    }

    public function calc_page_6() {
        // for CO, OH and FL 2015, privateplan_type is used instead of hlth_plan
        if ($_SESSION['hlth_plan'] == 'amount' || $_SESSION['privateplan_type'] == 'user-entered') {
            $_SESSION['hlthins_family_cost_m'] = $_SESSION['hlth_amt_family_m'];
            $_SESSION['hlthins_parent_cost_m'] = $_SESSION['hlth_amt_parent_m'];
        } else {            
			if ($_SESSION['year'] >= 2015) { # 6/15: changed this from including state conditions (OH, CO, FL) to include just the year, anticipating that future hlth codes will be similar to the ones we did in 2015 for OH, CO, and FL, and in 2017 for DC 
                $_SESSION['hlthins_family_cost_m'] = $this->health_cost($_SESSION['privateplan_type'], 'family');
                $_SESSION['hlthins_parent_cost_m'] = $this->health_cost($_SESSION['privateplan_type'], 'parent');
                $_SESSION['hlthins_parent_cost_m_1adult'] = $this->health_cost_employer($_SESSION['privateplan_type'], 'parent',1);
                $_SESSION['hlthins_parent_cost_m_2adult'] = $this->health_cost_employer($_SESSION['privateplan_type'], 'parent',2);
                $_SESSION['hlthins_parent_cost_m_3adult'] = $this->health_cost_employer($_SESSION['privateplan_type'], 'parent',3);
                $_SESSION['hlthins_parent_cost_m_4adult'] = $this->health_cost_employer($_SESSION['privateplan_type'], 'parent',4);
                $_SESSION['hlthins_family_cost_m_1adult'] = $this->health_cost_employer($_SESSION['privateplan_type'], 'family',1);
                $_SESSION['hlthins_family_cost_m_2adult'] = $this->health_cost_employer($_SESSION['privateplan_type'], 'family',2);
                $_SESSION['hlthins_family_cost_m_3adult'] = $this->health_cost_employer($_SESSION['privateplan_type'], 'family',3);
                $_SESSION['hlthins_family_cost_m_4adult'] = $this->health_cost_employer($_SESSION['privateplan_type'], 'family',4);
                $_SESSION['self_only_coverage'] = $this->self_only_coverage();
            } else {     
                $_SESSION['hlthins_family_cost_m'] = $this->health_cost($_SESSION['hlth_plan'], 'family');
                $_SESSION['hlthins_parent_cost_m'] = $this->health_cost($_SESSION['hlth_plan'], 'parent');
            }
        }

        switch ($_SESSION['privateplan_type']) {
            case 'user-entered':
                $_SESSION['hlth_plan_text'] = '(non-public)';
                break;
            case 'employer':
                $_SESSION['hlth_plan_text'] = 'employer-based';
                break;
            case 'individual':
                $_SESSION['hlth_plan_text'] = 'unsubsidized marketplace';
                break;
            case 'nongroup':
                $_SESSION['hlth_plan_text'] = 'nongroup';
                break;
        }
        
        switch ($_SESSION['hlth_plan']) {
            case 'amount':
                $_SESSION['hlth_plan_text'] = '(non-public)';
                break;
            case 'employer':
                $_SESSION['hlth_plan_text'] = 'employer-based';
                break;
            case 'private':
                $_SESSION['hlth_plan_text'] = 'nongroup';
                break;
        }
    }

    public function log_page_6() {
        $this->log_page(6);
    }

    public function input_page_7($args) {
        $this->save_to_session($args);
        return 8;
    }

    public function calc_page_7() {
        $dbh = $this->get_dbh();
		$sql = "SELECT cost FROM FRS_Food ";
        $sql .= "WHERE year = ? && age_min <= ? && age_max >= ?";
		#$stmt = $dbh->query($sql, array($_SESSION['year'], $_SESSION['child1_age'], $_SESSION['child1_age']))->fetchArray();
		#if (!$stmt) {
		#	//PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
		#	return array();
		#}
		#$_SESSION['child1_foodcost_m'] = $stmt['cost'];

 		for ($i = 1; $i <= 5; $i++) {
			if ($SESSION['child'.$i.'_age'] != -1) { 
				$stmt = $dbh->query($sql, array($_SESSION['year'], $_SESSION['child'.$i.'_age'], $_SESSION['child'.$i.'_age']))->fetchArray();
				if (!$stmt) {
					//PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
					return array();
				}
				$_SESSION['child'.$i.'_foodcost_m'] = $stmt['cost'];
			} else {
				$_SESSION['child'.$i.'_foodcost_m'] = 0;
			}
		}
    }
	
    public function log_page_7() {
        $this->log_page(7);
    }

    public function input_page_8($args) {
        $this->save_to_session($args);
        if (!$args['interval'] || $args['interval'] == 1200 || $args['interval'] == 1000) {
            if ($_SESSION['time_span'] == 'monthly') {
                $_SESSION['interval'] = 1200;
            } else {
                $_SESSION['interval'] = 1000;
            }
        }
        return 8;
    }

    public function calc_page_8() {
        
    }

    public function log_page_8() {
        
    }

    public function get_simulators($public_only = 0, $budget_only = 0) {
        $preview = $this->preview_user();
        //$users_table = Sps_TableFactory::create_table("FRS_User");
        $result = array();
        # get a list of years from the simulator directory
        $dbh = $this->get_dbh();
        $sql = "SELECT name FROM NCCP_State WHERE code = ?";
        foreach (scandir($this->frs_directory . 'lib/') as $dir_year) {
            # for each year, get a list of states and add each to the array
            if (preg_match('/^(\d{4})$/', $dir_year, $matches)) {
                $year = $matches[1];
                if ($budget_only == 0 || $year >= 2006) {
                    foreach (scandir($this->frs_directory . 'lib/' . $year) as $dir_state) {
                        if (preg_match('/^(\w{2})$/', $dir_state, $matches)) {
                            $public = 1; # FRS is public until deemed non-public (bc it's got a .private file in the dir or because it's older than 2006)
                            foreach (scandir($this->frs_directory . 'lib/' . $year . '/' . $dir_state) as $file) {
                                if (preg_match('/^\.private$/', $file) || ($_SESSION['mode'] == 'budget' && $year < 2006)) {
                                    $public = 0;
                                }
                            }
                            $state = $matches[1];
                            if ($budget_only && $year == 2006 && ($state == 'CO' || $state == 'IL')) {
                                # skip earlier years where we have a duplicate
							} elseif($year == 2007 && $state == 'CO') {
								# skipping
                            } elseif($year == 2007 && $state == 'FL') {
								# skipping
                            } elseif($year == 2009 && $state == 'CO') {
								# skipping
                            } elseif($year == 2009 && $state == 'OH') {
								# skipping
                            } else {

                                # Show the Simulator if:
                                # -- we're on the staged site
                                # -- we're a preview user & authorized to see it
                                # -- the simulator is public
                                if (($this->stage_user() && !$public_only) ||
                                        ((!$preview || $public_only) && $public) ||
                                        (!$public_only && $preview && $users_table->user_authorized_for_simulator($_SERVER['PHP_AUTH_USER'], "$state$year"))
                                ) {
                                    $stmt = $dbh->query($sql, array($state))->fetchAll();
                                    if (!$stmt) {
                                        //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
                                        return array();
                                    }
                                    //$hr = $stmt->FetchRow();
                                    $frs['year'] = $year;
                                    $frs['name'] = $stmt['name'];
                                    $frs['code'] = $state;
                                    array_push($result, $frs);
                                }
                            }
                        }
                    }
                }
            }
        }
        # sort the list of simulators first by state, then by year (DESCENDING)
        usort($result, array($this, "cmp_simulators"));
        return $result;
    }

    public function get_residences($state = '', $year = '') {
        if ($state == '') {
            $state = $_SESSION['state'];
        }
        if ($year == '') {
            $year = $_SESSION['year'];
        }
        $dbh = $this->get_dbh();
        $sql = "SELECT DISTINCT id, name, is_default FROM FRS_Locations ";
        $sql .= "WHERE state = ? && year = ? ";
        $sql .= "ORDER BY name ";

        $stmt = $dbh->Execute($sql, array($state, $year));
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }

        $result = array();
        while ($hr = $stmt->FetchRow()) {
            array_push($result, $hr);
        }
        return $result;
    }

    public function get_residence_name($state = '', $year = '', $residence = '') {
        if ($state == '') {
            $state = $_SESSION['state'];
        }
        if ($year == '') {
            $year = $_SESSION['year'];
        }
        if ($residence == '') {
            $residence = $_SESSION['residence'];
        }
        $dbh = $this->get_dbh();
        $sql = "SELECT name FROM FRS_Locations ";
        $sql .= "WHERE state = ? && year = ? && id = ?";

        $stmt = $dbh->Execute($sql, array($state, $year, $residence));
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        $hr = $stmt->FetchRow();
        return $hr['name'];
    }

    public function get_profiles($state = '', $year = '') {
        if ($state == '') {
            $state = $_SESSION['state'];
        }
        if ($year == '') {
            $year = $_SESSION['year'];
        }
        $dbh = $this->get_dbh();
        $sql = "SELECT DISTINCT id FROM FRS_Defaults ";
        $sql .= "WHERE id LIKE ? ";
        $sql .= "ORDER BY id ";

        $stmt = $dbh->Execute($sql, array("$state$year%"));
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }

        $result = array();
        while ($hr = $stmt->FetchRow()) {
            if (preg_match('/(\w{2})(\d{4})(.+)/', $hr['id'], $matches)) {
                $hr['name'] = $matches[3];
                array_push($result, $hr);
            }
        }
        return $result;
    }

    public function save_profile($name) {
        $this->reset();
        if (preg_match('/(\w{2})(\d{4})/', $_POST['simulator'], $matches)) {
            $state = $matches[1];
            $year = $matches[2];
        }
        $id = $state . $year . $_POST['new_profile_name'];
        $dbh = $this->get_dbh();
        $sql = "DELETE FROM FRS_Defaults WHERE id = ? ";
        $stmt = $dbh->Execute($sql, array($id));
        $sql = "INSERT INTO FRS_Defaults (id, name, value) VALUES (?, ?, ?) ";
        foreach ($_POST as $name => $value) {
            if ($name != 'simulator' && $name != 'profile' && $name != 'new_profile_name') {
                $stmt = $dbh->Execute($sql, array($id, $name, $value));
                if (!$stmt) {
                    //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
                    return array();
                }
            }
        }
        $stmt = $dbh->Execute($sql, array($id, 'state', $state));
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        $stmt = $dbh->Execute($sql, array($id, 'year', $year));
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        $this->load_profile($state, $year, $_POST['new_profile_name']);
    }

    public function delete_profile($name) {
        $this->reset();
        if (preg_match('/(\w{2})(\d{4})/', $_POST['simulator'], $matches)) {
            $state = $matches[1];
            $year = $matches[2];
        }
        $id = $state . $year . $_POST['new_profile_name'];
        $dbh = $this->get_dbh();
        $sql = "DELETE FROM FRS_Defaults WHERE id = ? ";
        $stmt = $dbh->Execute($sql, array($id));
    }

    public function state_eitc_available() {
        $dbh = $this->get_dbh();
        $sql = "SELECT state_eitc FROM FRS_General WHERE state = ? && year = ? LIMIT 1 ";

        $stmt = $dbh->Execute($sql, array($_SESSION['state'], $_SESSION['year']));
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }

        $hr = $stmt->FetchRow();
        return $hr['state_eitc'];
    }

    public function state_cadc_available() {
        $dbh = $this->get_dbh();
        $sql = "SELECT state_cadc FROM FRS_General WHERE state = ? && year = ? LIMIT 1 ";

        $stmt = $dbh->Execute($sql, array($_SESSION['state'], $_SESSION['year']));
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }

        $hr = $stmt->FetchRow();
        return $hr['state_cadc'];
    }

    public function child_eligible($child) {
        return ($_SESSION["child{$child}_age"] != -1 && $_SESSION["child{$child}_age"] < 13);
    }

    public function child_care_settings($child = '') {

        $arg_array = array($_SESSION['state'], $_SESSION['year'], $_SESSION['residence'], $_SESSION['residence']);
        
        $dbh = $this->get_dbh();
        if ($child) {
            $sql = "SELECT DISTINCT FRS_CareOptions.text, FRS_SPR.spr, FRS_CareOptions.sequence ";
        } else {
            $sql = "SELECT DISTINCT FRS_CareOptions.text, FRS_CareOptions.sequence ";
        }
        $sql .= "FROM FRS_CareOptions LEFT JOIN FRS_SPR USING (state, year, ccdf_type) ";
        $sql .= "LEFT JOIN FRS_Locations USING (state, year, ccdf_region) ";
        $sql .= "WHERE FRS_SPR.state = ? && FRS_SPR.year = ? && FRS_Locations.id = ? ";
        $sql .= "AND (FRS_CareOptions.residence = ? || FRS_CareOptions.residence IS NULL || FRS_CareOptions.residence = 0) ";
        $sql .= "AND FRS_SPR.ccdf_time = 'Unsubsidized' ";

        if ($child) {
            $sql .= "AND FRS_SPR.age_min <= ? && FRS_SPR.age_max >= ? ";
            $arg_array[] = $_SESSION["child{$child}_age"];
            $arg_array[] = $_SESSION["child{$child}_age"];
        }

        $sql .= "ORDER BY FRS_CareOptions.sequence ";
        
        $stmt = $dbh->query($sql, $arg_array)->fetchAll();

        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        /*$result = array();
        while ($hr = $stmt->FetchRow()) {
            array_push($result, $hr);
        }*/
        
        return $stmt;
    }

    public function health_cost($plan, $type) {
		
		if ($_SESSION['year'] == 2017 && $_SESSION['state'] == 'DC' && $_SESSION['privateplan_type'] == 'individual' ) {
			# 6/15: this is specifically calculated for DC 2017. Jay Bala advises building it into the sql table next time, although without formulas that would be very onerous, since costs vary by age of parent and age of children. Aside from the premium array being specific to 2017, other constants for 2017, specifically the 27-yo monthly premium ($222/month) and the premium ratio (.727) are hardcoded below.	
			$parent1_premium_ratioarray = array(0.654,0.727,0.727,0.727,0.727,0.727,0.727,0.727,0.744,0.76,0.779,0.799,0.817,0.836,0.856,0.876,0.896,0.916,0.927,0.938,0.975,1.013,1.053,1.094,1.137,1.181,1.227,1.275,1.325,1.377,1.431,1.487,1.545,1.605,1.668,1.733,1.801,1.871,1.944,2.02,2.099,2.181);
			$parent1_premium_ratio = $parent1_premium_ratioarray[($_SESSION['parent1_age'] - 20)];
			$parent2_premium_ratio = $parent1_premium_ratioarray[($_SESSION['parent2_age'] - 20)];
			$parent1_premium = (($parent1_premium_ratio/0.727)*222);
			if ($_SESSION['family_structure'] == '2') { 
				$parent2_premium = (($parent2_premium_ratio/0.727)*222);
			} else {
				$parent2_premium = 0;
			}
			$parent_cost = ($parent1_premium + $parent2_premium); 
			$family_cost = $parent_cost;
			$family_cost = ($family_cost + $_SESSION['child_number']*(0.654/0.727)*222);
			if ($type == 'parent') {
				return $this->format($parent_cost, 1);
			} else {
				return $this->format($family_cost, 1);
			}
		}

		if ($_SESSION['year'] == 2020 && $_SESSION['state'] == 'KY' && $_SESSION['privateplan_type'] == 'individual' ) {
			$parent1_premium_ratioarray = array(0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.833, 0.859, 0.885, 0.851, 0.941, 0.97, 1, 1, 1, 1, 1.004, 1.024, 1.048, 1.087, 1.119, 1.135, 1.159, 1.183, 1.198, 1.214, 1.222, 1.23, 1.238, 1.246, 1.262, 1.278, 1.302, 1.325, 1.357, 1.397, 1.444, 1.5, 1.563, 1.635, 1.706, 1.786, 1.865, 1.952, 2.04, 2.135, 2.23, 2.333, 2.437, 2.548, 2.603, 2.714, 2.81, 2.873, 2.952, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3);
			$parent1_premium_ratio = $parent1_premium_ratioarray[($_SESSION['parent1_age'])];
			$parent2_premium_ratio = $parent1_premium_ratioarray[($_SESSION['parent2_age'])];
			$parent1_premium = ($parent1_premium_ratio/1.048) * 386;
			if ($_SESSION['family_structure'] == '2') { 
				$parent2_premium = ($parent2_premium_ratio/1.048)*386;
			} else {
				$parent2_premium = 0;
			}
			$parent_cost = $parent1_premium + $parent2_premium; 
			$family_cost = $parent_cost;
			for($i=1; $i<=5; $i++) {
				if ($_SESSION['child' . $i . '_age'] > -1) {
					${'child'.$i.'_premium_ratio'} = $premium_ratioarray[($_SESSION['child' . $i . '_age'])];
					${'child'.$i.'_premium'} = (${'child'.$i.'_premium_ratio'}/1.048) * 386;
					$family_cost = $family_cost + ${'child'.$i.'_premium'};
				}
			}
			if ($type == 'parent') {
				return $this->format($parent_cost, 1);
			} else {
				return $this->format($family_cost, 1);
			}
		}

		if ($_SESSION['year'] == 2021 && $_SESSION['privateplan_type'] == 'individual' ) {
			$premium_ratioarray = array(0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.765, 0.833, 0.859, 0.885, 0.851, 0.941, 0.97, 1, 1, 1, 1, 1.004, 1.024, 1.048, 1.087, 1.119, 1.135, 1.159, 1.183, 1.198, 1.214, 1.222, 1.23, 1.238, 1.246, 1.262, 1.278, 1.302, 1.325, 1.357, 1.397, 1.444, 1.5, 1.563, 1.635, 1.706, 1.786, 1.865, 1.952, 2.04, 2.135, 2.23, 2.333, 2.437, 2.548, 2.603, 2.714, 2.81, 2.873, 2.952, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3);
			#Lookup the baseline 27-year-old premium. Eventually do this using a SQL lookup. For now, hardcoding it:
			if ($_SESSION['state'] == 'NH') { 
				$baseline27yo_premium = 331.79;
			}
			if ($_SESSION['state'] == 'PA') { 
				$baseline27yo_premium = 274.17;
			}
			if ($_SESSION['state'] == 'DC') { 
				$baseline27yo_premium = 303.65;
			}

			#Locate the premiums by using the ratio of the parent age ratio compared to the baseline age ratio.
			for($i=1; $i<=4; $i++) {
				if ($_SESSION['parent'.$i.'_age'] > -1) {
					${'parent'.$i.'_premium_ratio'} = $premium_ratioarray[($_SESSION['parent'.$i.'_age'])];  
					${'parent'.$i.'_premium'} = (${'parent'.$i.'_premium_ratio'}/1.048) * $baseline27yo_premium;
					$parent_cost += ${'parent'.$i.'_premium'}; 
				}
			}
			$family_cost = $parent_cost;
			for($i=1; $i<=5; $i++) {
				if ($_SESSION['child' . $i . '_age'] > -1) {
					${'child'.$i.'_premium_ratio'} = $premium_ratioarray[($_SESSION['child' . $i . '_age'])];
					${'child'.$i.'_premium'} = (${'child'.$i.'_premium_ratio'}/1.048) * 386;
					$family_cost +=  ${'child'.$i.'_premium'};
				}
			}
			if ($type == 'parent') {
				return $this->format($parent_cost, 1);
			} else {
				return $this->format($family_cost, 1);
			}
		}

		if ($_SESSION['privateplan_type'] == 'employer') {
			$dbh = $this->get_dbh();
			$sql = "SELECT parent_cost, family_cost FROM FRS_Health ";
			$sql .= "WHERE state = ? && year = ? && family_structure = ? && child_number = ? && plan_type = ? && residence = ?";
			if ($_SESSION['year'] < 2021) { #In earlier simulators, we delineated all health costs by residence. But in the MTRC and in later simulators, this is completely unnecessary, as costs both for employer plans and marketplace plans are estimated the same way regardless of residence.
				$stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $_SESSION['family_structure'], $this->child_number(), $plan, $_SESSION['residence']))->fetchArray();
			} else {
				$stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $_SESSION['family_structure'], $this->child_number(), $plan, 1))->fetchArray();
			}
			if (!$stmt) {
				//PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
				return array();
			}
			if ($type == 'parent') {
				return $this->format($stmt['parent_cost'] / 12, 1);
			} else {
				return $this->format($stmt['family_cost'] / 12, 1);
			}
		}
    }
    public function health_cost_employer ($plan, $type, $adults) {
				
        $dbh = $this->get_dbh();
        $sql = "SELECT parent_cost, family_cost FROM FRS_Health ";
        $sql .= "WHERE state = ? && year = ? && family_structure = ? && child_number = ? && plan_type = ? && residence = ?";
		
		if ($_SESSION['year'] < 2021) {
			$stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $adults, $this->child_number(), $plan, $_SESSION['residence']))->fetchArray();
		} else { #As of 2021, we are simplifying the FRS_Health table so that residence is no longer resident for estimating employer health care (since defaults come from MEPS, drilled down only to the state level. So while we are keeping residence as a placeholder identifier in the relevant table (for backward compatibility), we are hard-coding residence to 1 going forward in this query.
			$stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $adults, $this->child_number(), $plan, 1))->fetchArray();
		}
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        //$result = $stmt->FetchRow();

        if ($type == 'parent') {
            return $this->format($stmt['parent_cost'] / 12, 1);
        } else {
            return $this->format($stmt['family_cost'] / 12, 1);
        }
    }

    public function self_only_coverage () {
				
        $dbh = $this->get_dbh();
        $sql = "SELECT self_only_coverage, family_cost FROM FRS_Health ";
        $sql .= "WHERE state = ? && year = ? && family_structure = ? && child_number = ? && plan_type = ? && residence = ?";
		
		$stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], 1, 0, 'employer', 1))->fetchArray();

        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        //$result = $stmt->FetchRow();

        return $stmt['self_only_coverage'];
 
    }

    public function oop_costs() {
		if ($_SESSION['year'] >= 2020) {
			if ($_SESSION['child_number'] >= 1) {
				if ($_SESSION['family_structure'] == 2) {
					$hlth_costs_oop = 721;
				} else {
					$hlth_costs_oop = 116;
				}
			} else {
				if ($_SESSION['family_structure'] == 2) {
					$hlth_costs_oop = 869;
				} else {
					$hlth_costs_oop = 242;
				}
			}			
		} else {
			if ($_SESSION['year'] > 2012) {
				$parent_oop_cost = 414.99;      # Annual OOP cost per parent (Ages 25-40)
				$child_under4_oop_cost = 108.13;    # Annual OOP cost per child (Ages 0-4)   
				$child_over4_oop_cost = 180.33;  # Annual OOP cost per child (Ages 5-17)
			} elseif ($_SESSION['year'] == 2011 || $_SESSION['year'] == 2012) {
				$parent_oop_cost = 401.94;  # annual OOP cost per parent
				$child_under9_oop_cost = 82.29;  # annual OOP cost per child (ages 1-8)
				$child_over9_oop_cost = 215.80; # annual OOP cost per child (ages 9-17)
			} elseif ($_SESSION['year'] == 2010) {
				$parent_oop_cost = 297;  # annual OOP cost per parent
				$child_under9_oop_cost = 108;  # annual OOP cost per child (ages 1-8)
				$child_over9_oop_cost = 168; # annual OOP cost per child (ages 9-17)
			} elseif ($_SESSION['year'] == 2009) {
				$parent_oop_cost = 352;  # annual OOP cost per parent
				$child_under9_oop_cost = 91;  # annual OOP cost per child (ages 1-8)
				$child_over9_oop_cost = 186; # annual OOP cost per child (ages 9-17)
			} else {
				$parent_oop_cost = 276;  # annual OOP cost per parent
				$child_under9_oop_cost = 89;  # annual OOP cost per child (ages 1-8)
				$child_over9_oop_cost = 204; # annual OOP cost per child (ages 9-17)
			}

			for ($i = 1; $i <= 3; $i++) {
				if ($_SESSION['child' . $i . '_age'] != -1) {
					if ($_SESSION['year'] > 2012) {
						if ($_SESSION['child' . $i . '_age'] <= 4) {
							${'child' . $i . '_oop_cost'} = $child_under4_oop_cost;
						} else {
							${'child' . $i . '_oop_cost'} = $child_over4_oop_cost;
						}
					} else {
						if ($_SESSION['child' . $i . '_age'] <= 8) {
							${'child' . $i . '_oop_cost'} = $child_under9_oop_cost;
						} else {
							${'child' . $i . '_oop_cost'} = $child_over9_oop_cost;
						}
					}
				}
			}
			$hlth_costs_oop = ($parent_oop_cost * $_SESSION['family_structure']) +
                $child1_oop_cost + $child2_oop_cost + $child3_oop_cost;
			$_SESSION['hlth_costs_oop'] = $hlth_costs_oop;
		}
        return $hlth_costs_oop / 12;
    }

    public function rent() {
        $dbh = $this->get_dbh();
        $sql = "SELECT rent FROM FRS_Locations ";
        $sql .= "WHERE state = ? AND year = ? AND id = ? AND number_children = ?";
        $stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $_SESSION['residence'], $_SESSION['child_number_mtrc']))->fetchArray(); // replacing $this->child_number() with child_number_mtrc for now
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        //$result = $stmt->FetchRow();
        return $this->format_currency($stmt['rent']);
    }

    # Do I want to be setting the session variables on this, too, esp for the 'trans_private' flag?  What is that for?

    public function trans_private() {
        $dbh = $this->get_dbh();
        $sql = "SELECT trans_type FROM FRS_Locations ";
        $sql .= "WHERE state = ? AND year = ? AND id = ? AND number_children = ?";
        $stmt = $dbh->query($sql, array($_SESSION['state'], $_SESSION['year'], $_SESSION['residence'], $this->child_number()))->fetchArray();
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        //$result = $stmt->FetchRow();
        return (strtolower($stmt['trans_type']) == 'car' || strtolower($stmt['trans_type']) == 'private');
    }

    public function child_number() {
        $child_number = 0;
        for ($i = 1; $i <= 3; $i++) { # changed the i from 5 to 3 because pre-2017 simulators only go up to 3.
            if ($_SESSION["child{$i}_age"] != -1) {
                $child_number++;
            }
        }
        if ($_SESSION['year'] >= 2017) { # 5/8/18: added line for conditionality to exclude cals for child4 and child5 for pre-2017 simulators. 6/13: changed curly brackets to square.
            for ($i = 4; $i <= 5; $i++) { # 5/8/18: added line
                if ($_SESSION["child{$i}_age"] != -1) { # 5/8/18: added line
                    $child_number++; # 5/8/18: added line
                } # 5/8/18: added line
            } # 5/8/18: added line
        } # 5/8/18: added line
        return $child_number;
    }

    public function disability_count() {
		#This function counts the number of adults with qualifying disabilities in the household.
        $disability_count = 0;
        for ($i = 1; $i <= $_SESSION['family_structure']; $i++) { 
            if ($_SESSION['disability_parent'.$i] == 1) {
                $disability_count++;
            }
        }
        return $disability_count;
    }


    # Function for sorting a list of simulators first by state, then by date in descending order

    public function cmp_simulators($a, $b) {
        if ($a['name'] == $b['name']) {
            return $a['year'] < $b['year'];
        } else {
            return strcmp($a['name'], $b['name']);
        }
    }

    public function format_currency($num) {
        $num = preg_replace('/\$|\,/', '', $num);
        if (!is_numeric($num)) {
            $num = "n/a";
            return $num;
        }
        #$sign = ($num == ($num = abs($num));
        $sign = 1;
        $num = floor($num * 100 + 0.50000000001);
        $cents = $num % 100;
        $num = floor($num / 100);
        if ($cents < 10)
            $cents = "0" + $cents;
        for ($i = 0; $i < floor((strlen($num) - (1 + $i)) / 3); $i++) {
            $num = substr($num, 0, strlen($num) - (4 * $i + 3)) . ',' . substr($num, strlen($num) - (4 * i + 3));
        }
        return ((($sign) ? '' : '-') . $num);
    }

    public function format($number, $round = 0) {
        if (preg_match('/\./', $number) && !$round) {
            return number_format($number, 2);
        } else {
            return number_format($number);
        }
    }

    public function get_spr($time, $age, $setting) {

        
        $year = $_SESSION['year'];
        
        $dbh = $this->get_dbh();
        $sql = "SELECT DISTINCT spr.spr FROM FRS_CareOptions care ";
        $sql .= "LEFT JOIN FRS_SPR spr USING (state, year, ccdf_type) ";
        $sql .= "LEFT JOIN FRS_Locations loc USING (state, year, ccdf_region) ";
        $sql .= "WHERE spr.state = ? AND spr.year = ? AND spr.ccdf_time = ? ";
        $sql .= "AND spr.age_min <= ? AND spr.age_max >= ? AND loc.id = ? AND care.text = ?";
        $stmt = $dbh->query($sql, array($_SESSION['state'], $year, $time, $age, $age, $_SESSION['residence'], $setting))->fetchArray();
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        //$result = $stmt->FetchRow();
        
        return $stmt['spr'];
    }

    public function state_has_simulator($state) {
        $simulators = $this->get_simulators(1);
        foreach ($simulators as $s) {
            if ($s['code'] == $state) {
                return 1;
            }
        }
        return 0;
    }

    public function get_report($options) {
        $dbh = $this->get_dbh();
        $arg_array = array();

        # don't count visits from inside NCCP
        $where = 'ip NOT LIKE "156.111.190%" AND time_start IS NOT NULL AND ';

        # narrow the date range
        if ($options['date_start']) {
            $where .= 'time_end >= ? AND ';
            array_push($arg_array, date('Y-m-d', strtotime($options['date_start'])));
        }
        if ($options['date_end']) {
            $where .= 'time_end <= ? AND ';
            array_push($arg_array, date('Y-m-d', strtotime($options['date_end'])));
        }

        # search only among simulators specified
        if (!$options['all_simulators'] && $options['hidden_simulators']) {
            $where .= '(';
            $simulator_array = array();
            foreach (explode('|', $options['hidden_simulators']) as $code) {
                $state = substr($code, 0, 2);
                $year = substr($code, 2, 4);
                array_push($simulator_array, "(state = ? && year = ?)");
                array_push($arg_array, $state);
                array_push($arg_array, $year);
            }
            $where .= join(' || ', $simulator_array) . ') AND ';
        }

        # set up the y dimension specified
        $y_select = 'COUNT(*) AS count, SEC_TO_TIME(AVG(TIME_TO_SEC(TIMEDIFF(time_end, time_start)))) AS time,  COUNT(DISTINCT ip) AS \'unique\', ';
        $y_group = '';
        switch ($options['dimension_y']) {
            case 'simulator':
                $y_group .= 'state, year';
                $y_select .= 'state, year, CONCAT(state,year) AS label';
                $x_where = 'state = ? AND year = ? AND ';
                $x_arg_array_fields = array('state', 'year');
                break;
            case 'residence':
                $y_group .= 'state, year, residence';
                $y_select .= 'state, year, residence';
                $x_where = 'state = ? AND year = ? AND residence = ? AND ';
                $x_arg_array_fields = array('state', 'year', 'residence');
                break;
            default:
                $y_group .= $options['dimension_y'];
                $y_select .= $options['dimension_y'] . ', ' . $options['dimension_y'] . ' AS label';
                $x_where = $options['dimension_y'] . ' = ? AND ';
                $x_arg_array_fields = array($options['dimension_y']);
        }

        # first, get totals for the first row
        # total number and time spent
        $sql = "SELECT COUNT(*) AS count, COUNT(DISTINCT ip) AS 'unique', SEC_TO_TIME(AVG(TIME_TO_SEC(TIMEDIFF(time_end, time_start)))) AS time FROM FRS_Log WHERE $where 1";
        $stmt = $dbh->Execute($sql, $arg_array);
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        $total = $stmt->FetchRow();
        # uses / user
        $sql = "SELECT COUNT(id) AS uses FROM FRS_Log WHERE $where 1 GROUP BY ip";
        $stmt = $dbh->Execute($sql, $arg_array);
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        $uses_count = 0;
        $uses_total = 0;
        while ($result = $stmt->FetchRow()) {
            $uses_total += $result['uses'];
            $uses_count++;
        }
        $total['uses'] = $uses_total / $uses_count;
        $total['label'] = 'TOTAL';
        $total['percent'] = 100;
        $total['percent_unique'] = 100;

        # set up the x dimension, if specified
        $columns = array();
        if ($options['dimension_x']) {
            $x_select = 'COUNT(*) AS count, ';
            $x_group = '';
            switch ($options['dimension_x']) {
                case 'simulator':
                    $x_group .= 'state, year';
                    $x_select .= 'state, year, CONCAT(state,year) AS label';
                    $x_order = 'state, year DESC';
                    break;
                case 'residence':
                    $x_group .= 'state, year, residence';
                    $x_select .= 'state, year, residence';
                    $x_order = 'state, year DESC, residence';
                    break;
                case 'year':
                    $x_group .= 'YEAR(time_start)';
                    $x_select .= 'YEAR(time_start) AS label';
                    $x_order .= 'YEAR(time_start) DESC';
                    break;
                case 'month':
                    $x_group .= 'MONTH(time_start), YEAR(time_start)';
                    $x_select .= 'DATE_FORMAT(time_start, "%b %Y") AS label';
                    $x_order .= 'YEAR(time_start) DESC, MONTH(time_start) DESC';
                    break;
                case 'day':
                    $x_group .= 'DAY(time_start), MONTH(time_start), YEAR(time_start)';
                    $x_select .= 'DATE_FORMAT(time_start, "%m/%e/%y") AS label';
                    $x_order .= 'YEAR(time_start) ASC, MONTH(time_start) ASC, DAY(time_start) ASC';
                    break;
                default:
                    $x_group .= $options['dimension_x'];
                    $x_select .= $options['dimension_x'] . ' AS label';
                    $x_order = $options['dimension_x'] . ' ASC';
            }

            # get the labels + the aggregate values / column labels for the x-dimension
            $sql = "SELECT $x_select FROM FRS_Log WHERE $where 1 GROUP BY $x_group ORDER BY $x_order";
            $stmt = $dbh->Execute($sql, $arg_array);
            if (!$stmt) {
                //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
                return array();
            }

            $none_text = "left on step 1";
            while ($hr = $stmt->FetchRow()) {
                if ($hr['label'] == '') {
                    $hr['label'] = $none_text;
                    $none_text = 'no benefits selected';
                }
                if ($options['dimension_x'] == 'residence') {
                    if (!$hr['state']) {
                        $hr['label'] = 'No state selected';
                    } elseif (!$hr['residence']) {
                        $hr['label'] = sprintf('%s%s: No residence selected', $hr['state'], $hr['year']);
                    } else {
                        $hr['label'] = sprintf('%s%s: %s', $hr['state'], $hr['year'], $this->get_residence_name($hr['state'], $hr['year'], $hr['residence']));
                    }
                }
                $hr['percent'] = $hr['count'] / $total['count'] * 100;
                array_push($columns, $hr);
            }

            # create the SQL to get the grouped columns (the x dimension)
            $x_sql = "SELECT $x_select FROM FRS_Log WHERE $where $x_where 1 GROUP BY $x_group ORDER BY $x_order";
        }
        $total['columns'] = $columns;

        # create the SQL to get the grouped rows (the y dimension)
        $y_sql = "SELECT $y_select FROM FRS_Log WHERE $where 1 GROUP BY $y_group ORDER BY count DESC";

        print_r($y_sql);

        $stmt = $dbh->Execute($y_sql, $arg_array);
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        $result = array($total);
        $none_text = "left on step 1";
        while ($hr = $stmt->FetchRow()) {
            $hr['percent'] = $hr['count'] / $total['count'] * 100;
            $hr['percent_unique'] = $hr['unique'] / $total['unique'] * 100;
            if ($hr['label'] == '') {
                $hr['label'] = $none_text;
                $none_text = 'no benefits selected';
            }
            if ($options['dimension_y'] == 'residence') {
                if (!$hr['state']) {
                    $hr['label'] = 'No state selected';
                } elseif (!$hr['residence']) {
                    $hr['label'] = sprintf('%s%s: No residence selected', $hr['state'], $hr['year']);
                } else {
                    $hr['label'] = sprintf('%s%s: %s', $hr['state'], $hr['year'], $this->get_residence_name($hr['state'], $hr['year'], $hr['residence']));
                }
            }

            # if there was a second dimension specified, get the data for the whole row
            if ($options['dimension_x']) {
                $x_arg_array = $arg_array;
                $x_sql_final = $x_sql;
                foreach ($x_arg_array_fields as $field) {
                    if ($hr[$field]) {
                        array_push($x_arg_array, $hr[$field]);
                    } else {
                        $x_sql_final = str_replace("$field = ?", "$field IS NULL", $x_sql_final);
                    }
                }
                /*
                  echo "<!--<p>$x_sql_final</p><ul>";
                  foreach($x_arg_array as $arg) {
                  echo "<li>$arg</li>";
                  }
                  echo "</ul>-->";
                 */
                $x_stmt = $dbh->Execute($x_sql_final, $x_arg_array);
                if (!$x_stmt) {
                    //PEAR::raiseError("Unable to execute $x_sql_final: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
                    return array();
                }
                $columns = array();
                $none_text = "left on step 1";
                while ($x_hr = $x_stmt->FetchRow()) {
                    if ($x_hr['label'] == '') {
                        $x_hr['label'] = $none_text;
                        $none_text = 'no benefits selected';
                    }
                    if ($options['dimension_x'] == 'residence') {
                        if (!$x_hr['state']) {
                            $x_hr['label'] = 'No state selected';
                        } elseif (!$x_hr['residence']) {
                            $x_hr['label'] = sprintf('%s%s: No residence selected', $x_hr['state'], $x_hr['year']);
                        } else {
                            $x_hr['label'] = sprintf('%s%s: %s', $x_hr['state'], $x_hr['year'], $this->get_residence_name($x_hr['state'], $x_hr['year'], $x_hr['residence']));
                        }
                    }
                    $x_hr['percent'] = $x_hr['count'] / $hr['count'] * 100;
                    array_push($columns, $x_hr);
                }
            }
            $hr['columns'] = $columns;
            array_push($result, $hr);
        }
        return $result;
    }

    public function get_report_date_start() {
        $dbh = $this->get_dbh();
        $sql = "SELECT DATE_FORMAT(MIN(time_start), '%Y-%m-%d') AS date FROM FRS_Log WHERE time_start IS NOT NULL ";
        $stmt = $dbh->Execute($sql, array());
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        $result = $stmt->FetchRow();
        return $result['date'];
    }

    public function get_report_date_end() {
        $dbh = $this->get_dbh();
        $sql = "SELECT DATE_FORMAT(MAX(time_start), '%Y-%m-%d') AS date FROM FRS_Log WHERE time_start IS NOT NULL ";
        $stmt = $dbh->Execute($sql, array());
        if (!$stmt) {
            //PEAR::raiseError("Unable to execute $sql: " . $dbh->ErrorMsg(), PEAR_LOG_ERR);
            return array();
        }
        $result = $stmt->FetchRow();
        return $result['date'];
    }

}

?>
