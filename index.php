<?php include("../../inc/headers_sps.php"); ?>

<?php
	session_start();
	$simulator    = Sps_TableFactory::create_table("NCCP_Simulator");
	$notes_table  = Sps_TableFactory::create_table("FRS_Note");
	$help_table   = Sps_TableFactory::create_table("FRS_Help");

	$tools_table  = Sps_TableFactory::create_table("NCCP_Tool");
	$tool         = $tools_table->fetch_item(6);
	$page_header  = $tool->get_field("header_photo")->get_relative_path();
	$page_title   = "Family Resource Simulator";
	$page_section = "tools";

	$scripts = array("prototype.js", "scriptaculous.js", "validation.js");
	if($_SESSION['mode'] == 'budget') { # if we're coming from the budget, we want to reset everything
		$simulator->reset();
	}
	elseif($_SERVER['REQUEST_METHOD'] == 'POST') {
		# If there's data to be stored, the proper input function is called
		# and it returns the # of the page that gets displayed
		$page = $simulator->{'input_page_'.($_POST['input'])}($_POST);
		$simulator->{'calc_page_'.($_POST['input'])}();
		$simulator->{'log_page_'.($_POST['input'])}();
	}
	elseif($_GET['mode'] == 'test') {
		$page = $simulator->run_test();
	}
	elseif($_GET['mode'] == 'quick') {
		$page = $simulator->input_page_1($_GET);
		$simulator->log_page_1();
	}

	# Alternately, a specific page could be requested (if we're going backwards through the steps, for instance)
	elseif($_GET['p']) { $page = $_GET['p']; }
	
	if($_GET['reset']) { $simulator->reset(); }
	
	$page_layout  = "content-left";	
	
	# Finally, if no specific page was requested than we go to step one
	if(!$page) $page = 1;

	# put information about this session into the log
	if($page == 1) $simulator->log_start();

	$titles = array('','City &amp; State','Family','Income &amp; Assets','Work Supports','Child Care','Health Insurance','Other Expenses','Results');
	$titles_long = array('', 
						 'Select state and city (or county)',
						 'Select family characteristics',
						 'Enter income sources, assets, and debt',
						 'Select work supports',
						 'Make choices about child care',
						 'Make choices about health insurance',
						 'Make choices about other expenses',
						 'View results'
						);
	
	# we don't need the "email this page" link on this page
	if($page != 1) { $page_noemail = 1; }
	
	if (!isset($_SESSION['mode']) || $_SESSION['mode'] == 'budget') { $_SESSION['mode'] = 'step'; }
?>

<?php include("inc/headers_html.php"); ?>
<link rel="stylesheet" href="frs.css" type="text/css" media="screen" />

<script type="text/javascript">

function next()
{
    var valid = new Validation('main-id', {onSubmit:false})
    var result = valid.validate()
    if(result) { document.main.submit(); return true; }
    else { void(0) }
}

// Make sure that the form gets validated before it's submitted
addLoadEvent(function() { registerDependencies('main-id') })
addLoadEvent(function() { 
	new Validation('main-id');
})
<?php if($page != 8) { ?>
// SAM IS COMMENTING THIS OUT HERE
//addLoadEvent(function() { $('button_continue').onclick = function() { next(); }})
<?php } ?>
<?php if($page == 1) { ?>
addLoadEvent(function() { $('simulator').onchange = function() { changeCities(); }})
addLoadEvent(function() { changeCities() })
var cities = new Array();
//var default_cities = new Array();
	<?php foreach($simulator->get_simulators() as $s) {
		$residences = array();
		foreach($simulator->get_residences($s['code'],$s['year']) as $i => $r) {
			array_push($residences, sprintf('"%s","%s"', $r['id'], html_entity_decode($r['name'], ENT_QUOTES, 'UTF-8')));
			/*
			if($r['is_default']) {
				echo "default_cities['${s['code']}${s['year']}'] = $i;\n";
			}
			*/
		}
		$residence_string = join(',',$residences);
	?>
		cities['<?php echo $s['code'].$s['year'] ?>'] = new Array("", "---Select a Location---", <?php echo $residence_string ?>)
			
	<?php } ?>
<?php } ?>

function changeCities(currentSelection)
{
	simulator_box = document.forms['main'].simulator
	residence_box = document.forms['main'].residence
	code = simulator_box.options[simulator_box.selectedIndex].value
	if(!code) {
		residence_box.disabled = true
		return
	}
	list = cities[code]
	residence_box.options.length = 0
	for(i=0;i<list.length;i+=2)
	{
		residence_box.options[i/2] = new Option(list[i+1],list[i])
		if(currentSelection == list[i]) {
			residence_box.selectedIndex = i/2
		}
	}
	residence_box.disabled = false
	/*
	if(!currentSelection) {
		residence_box.selectedIndex = default_cities[code];
	}
	*/
}

</script>

<?php include("inc/headers_page.php"); ?>
<?php include("inc/menu.php"); ?>

	
    <form id="main-id" name="main" action="<?php echo $_SERVER['PHP_SELF'] ?>" method="post" class="grid_12">

    <div id="content" class="content frs grid_8 alpha">
	<h1>Family Resource Simulator <?php if($page > 1 && $_SESSION['state'] == 'DC' ) { echo ': Washington, '.$_SESSION['state'].' ('.$_SESSION['year'].')'; } ?> <?php if($page > 1 && $_SESSION['state'] !== 'DC') { echo ': '.$_SESSION['residence_name'].', '.$_SESSION['state'].' ('.$_SESSION['year'].')'; } ?></h1>

    <?php if ($page == 1) echo $assets_table->fetch('frs_introduction_new'); ?>
    
    <?php include("inc/frs_steps.php"); ?>
	

<!-- SAM IS INLINING FRS_BUTTONS.PHP HERE -->

		<h2 class="steptitle noborder noprint">
			<div class="squarebutton mini">
				<?php echo $page ?>
			</div>
			<?php echo $titles_long[$page] ?>.<?php echo $notes_table->add_note('page'. $page . '_title'); echo $help_table->add_help('page'. $page . '_title'); ?>
		</h2>
		<div class="buttons">
			<?php if($page > 1) { ?>
					<a title="Back" alt="Back" class="roundbutton back" href="<?php echo $_SERVER['PHP_SELF'] ?>?p=<?php echo $page - 1 ?>">
						<img src="/images/button-round-blank.gif" height="35" width="35" alt="Back" />
					</a>
			<?php } else { ?>
					<a class="roundbutton back inactive" href="javascript:void(0);">
						<img src="/images/button-round-blank.gif" height="35" width="35" alt="" />
					</a>
			<?php } ?>
					<a title="Reset" alt="Reset" class="roundbutton reset" href="<?php echo $_SERVER['PHP_SELF'] ?>?p=1&amp;reset=1">
						<img src="/images/button-round-blank.gif" height="35" width="35" alt="Reset" />
					</a>
			<?php if($page < 8) { ?>
					<a title="Next" alt="Next" class="roundbutton next" href="javascript:next();" id="button_continue">
						<img src="/images/button-round-blank.gif" height="35" width="35" alt="Next" />
					</a>
			<?php } else { ?>
					<a class="roundbutton next inactive" href="javascript:void(0);">
						<img src="/images/button-round-blank.gif" height="35" width="35" alt="" />
					</a>
			<?php } ?>
		</div>
		<br class="clearing" />

<!-- END SAM HACK HERE -->


        <div class="container">
			<input type="hidden" name="input" value="<?php echo $page ?>" />			
			<?php include("inc/page_$page.php") ?>
			<div class="frs-note">
				<?php echo $notes_table->endnotes->get_list_with_stars() ?>
			</div>
        </div>
    </div>

    

	<?php if($page < 8) { ?>
	<div class="sidebar grid_4 omega">
		<?php if($page == 1) {
			echo $assets_table->fetch('simulator_sidebar_text');
		} ?>
		<div id="help-box" class="help">
			<img src="images/frs_help_big.gif" />
		</div>
	</div>
	<?php } else { ?>
    <div class="sidebar forceprint grid_4 omega" style="background-color:white;">
    	<div class="container" >
	    	<?php if($_GET['mode'] == 'test') { ?>
	    		<p><a href="test.php">Go back to the testing interface</a></p>
	    	<?php } ?>
	    	<?php for($i=1;$i<8;$i++) { ?>
	    		<h2><?php printf('<a href="%s?p=%d">%d. %s</a>', $_SERVER['PHP_SELF'], $i, $i, $titles[$i]) ?></h2>
	        	<?php include("inc/choice_$i.php") ?>
	        	<br/>
			<?php } ?>
		</div>
    </div>
	<?php } ?>
</form>	
<!-- 
<?php print_r($_SESSION) ?> 	
-->
	
<?php include("inc/footers.php"); ?>
