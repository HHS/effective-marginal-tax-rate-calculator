<head>
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Merriweather|Source Sans Pro">
<style>
body {
  font-family: "Merriweather", sans-serif;
    font-size: 16px;
    }
</style>
</head>

<?php 
include_once("lib/db.php");
include_once("lib/nccp_simulator.php");
include_once("lib/frs_note.php");
//include_once("../../sps_data/nccp_tool.php");
include("../../inc/headers_sps.php"); 
?>

<?php
	session_start();

$_SESSION['state2'] = $_GET['state'];
$_SESSION['demo'] = 0;
$_SESSION['test'] = 1;

if( isset($_POST['input']) ) { 
    foreach( $_POST as $k=>$v) {
        $_SESSION[$k] = $v;
    } 
}
	$simulator    = new NCCP_Simulator();
	/*$notes_table  = Sps_TableFactory::create_table("FRS_Note");
	$help_table   = Sps_TableFactory::create_table("FRS_Help");

	$tools_table  = Sps_TableFactory::create_table("NCCP_Tool");
	$tool         = $tools_table->fetch_item(6);
	$page_header  = $tool->get_field("header_photo")->get_relative_path();*/
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

	$titles = array('','Location &amp; Family Size','Household','Current Benefits','Work &amp; Income','Child Care','Health Care','Other Expenses','Results');
	$titles_long = array('', 
						 'Please provide information about your location and family size:',
						 'Please describe your household:',
						 'Please select which benefits you or other people in your household currently receive:',
						 'Please answer questions about employment and other income your household receives:',
						 'Please enter information about child care:',
						 'Please enter health care information:',
						 'Please enter information about other out-of-pocket expenses:',
						 'View results'
						);
	
	if (!isset($_SESSION['mode']) || $_SESSION['mode'] == 'budget') { $_SESSION['mode'] = 'step'; }
?>

<?php include("../../inc/headers_html.php"); ?>
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
<?php if($page != 8) { 
// SAM IS COMMENTING THIS OUT HERE
//addLoadEvent(function() { $('button_continue').onclick = function() { next(); }})
} ?>

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

<?php include("../../inc/headers_page.php"); ?>

	
    <form id="main-id" name="main" action="<?php echo $_SERVER['PHP_SELF'] ?>" method="post" class="grid_12">

    <div id="content" class="content frs grid_8 alpha">
	<h1>Benefit Cliffs Calculator</h1>

    <?php if ($page == 1): ?>
	<p>This tool will show you how your benefits change when your income changes. There are 7 steps with questions for you to answer. Step 8 will show your results and suggest next steps.</p>

    <!--Old text:<p>The Benefit Cliffs Calculator shows what happens to your benefits when your income changes. After you answer the questions on the next few screens, you will see a graph showing how your resources and expenses change as your income changes. Along with the graph, the calculator will list some next steps that you can take.</p>-->
    <?php 
	$_SESSION['state'] = 'NH';
	$_SESSION['year'] = 2021;
	$_SESSION['simulator'] = 'NH';
	$s['code'] = 'NH';
	$s['year'] = 2021;

	
    endif;
    include("../../inc/frs_steps.php"); 
    ?>
	

<!-- SAM IS INLINING FRS_BUTTONS.PHP HERE -->

		<h2 class="steptitle noborder noprint">
			<div class="squarebutton mini">
				<?php echo $page ?>
			</div>
			<?php echo $titles_long[$page] ?>
		</h2>
		<div class="buttons">
			<?php if($page == 1) { ?>

					<a title="Reset" alt="Reset" class="roundbutton reset" href="<?php echo $_SERVER['PHP_SELF'] ?>?p=1&amp;reset=1">
						<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
					</a>
			<?php } ?>

			<?php if($page > 1) { ?>
					<a title="Back" alt="Back" class="roundbutton back" href="<?php echo $_SERVER['PHP_SELF'] ?>?p=<?php echo $page - 1 ?>">
						<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
					</a>
			<?php } else { ?>
					<a class="roundbutton back inactive" href="javascript:void(0);">
						<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
					</a>
			<?php } ?>
			<?php if($page < 8) { ?>
					<a title="Next" alt="Next" class="roundbutton next" href="javascript:next();" id="button_continue">
						<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
					</a>
			<?php } else { ?>
					<a class="roundbutton next inactive" href="javascript:void(0);">
						<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
					</a>
			<?php } ?>
		</div>
		<br class="clearing" />

<!-- END SAM HACK HERE -->


        <div class="container">
			<input type="hidden" name="input" value="<?php echo $page ?>" />			
			<?php include("inc/page_$page.php") ?>
			<div class="frs-note">
				<?php /*echo $notes_table->endnotes->get_list_with_stars()*/ ?>
			</div>
        </div>
    </div>

    

	<?php if($page < 8) { ?>
	<div class="sidebar grid_4 omega">
		<?php if($page == 1) {
			//echo $assets_table->fetch('simulator_sidebar_text');
		} ?>
		<div id="help-box" class="help">
			<img src="images/frs_help_big.gif" />
		</div>
	</div>
	<?php } else { ?>
    <div class="sidebar forceprint grid_4 omega" style="background-color:white;">
    	<div class="container" >
	    	
	    	<?php for($i=1;$i<8;$i++) { ?>
	    		<h2><?php printf('Step <a href="%s?p=%d">%d. %s</a>', $_SERVER['PHP_SELF'], $i, $i, $titles[$i]) ?></h2>
	        	<?php include("inc/choice_$i.php") ?>
	        	<br/>
			<?php } ?>
		</div>
    </div>
	<?php } ?>

	<?php if($page > 1) { ?>
    <div id="content" class="content frs grid_8 alpha">	
		<div class="buttons">
				<a title="Reset" alt="Reset" class="roundbutton reset" href="<?php echo $_SERVER['PHP_SELF'] ?>?p=1&amp;reset=1">
					<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
				</a>
		<?php if($page > 1) { ?>
				<a title="Back" alt="Back" class="roundbutton back" href="<?php echo $_SERVER['PHP_SELF'] ?>?p=<?php echo $page - 1 ?>">
					<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
				</a>
		<?php } else { ?>
				<a class="roundbutton back inactive" href="javascript:void(0);">
					<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
				</a>
		<?php } ?>
		<?php if($page < 8) { ?>
				<a title="Next" alt="Next" class="roundbutton next" href="javascript:next();" id="button_continue">
					<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
				</a>
		<?php } else { ?>
				<a class="roundbutton next inactive" href="javascript:void(0);">
					<img src="images/button-round-blank.gif" height="35" width="35" alt="" />
				</a>
		<?php } ?>
		</div>
	</div>
	<?php } ?>

</form>	
<pre>
<?php print_r($_SESSION) ?> 	
</pre>
<!--
<?php include("../../inc/footers.php"); ?>
<!---->