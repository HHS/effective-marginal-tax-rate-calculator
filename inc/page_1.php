<script type="text/javascript">
function loadQuick() {
	sim = $F('simulator')
	res = $F('residence')
	if(sim == '') { sim = 'CO2015' }
	self.location = '<?php echo $_SERVER['PHP_SELF'] ?>?mode=quick&simulator='+sim+'&residence='+res
}

Validation.add('validate-location','You must select a location.', function(v,e) {
	if(Number(v) == 0) {
		return false
	}
	return true;
});
</script>
<br/>
<?php echo $_SESSION['test1']; ?>
<!--<div style="float:left;margin-right:20px;margin-top:12px;">
	<select name="simulator" id="simulator" class="required">
		<option value="">Select a State</option>
		<?php 
		
		//states array
		#$states = array(
		#'DC'=>'District of Columbia',
		#'ME'=>'Maine',
		#'NH'=>'New Hampshire',
		#'PA'=>'Pennsylvania',
		#'KY'=>'Kentucky',
		#);
		
		#foreach ($states as $abbr=>$name):
		?>
		<option value="<?php #echo $abbr; ?>"><?php #echo $name; ?></option>
		<!--<option value="<?php #echo $abbr; ?>"<?php #if($_SESSION['state'] == $abbr) echo 'selected' ?>><?php #echo $name; ?></option>-->
		
		<?php
		#endforeach;
		?>
		
		
	</select>
</div>
<!--
<div style="float:left;margin-top:12px;">
	<select name="residence2" id="residence2" class="required">
		<option value="">Select a Location</option>
		<?php 
		#for($i = 1; $i<10; $i++):
		?>
		<option value="<?php #echo $abbr; ?>">Location <?php #echo $i; ?></option>
		<?php
		#endfor;
		?>
	</select>
</div>
-->
<br/>
<table border="0" cellspacing="0" cellpadding="4">

	<?php if ($_SESSION['state'] != 'DC') { ?>
	
	  <tr>
		<td><label for="residence">What city or county do you live in?</label></td>
		<td >
		<select name="residence" id="residence" class="validate-location">
		<?php if ($_SESSION['state'] == 'NH' && $_SESSION['demo'] == 0) { ?>
			<option value="0"<?php if($_SESSION['residence'] ==0) echo 'selected' ?>>--Select Location--</option>
			<option value="1"<?php if($_SESSION['residence'] ==1) echo 'selected' ?>>Acworth</option>
			<option value="2"<?php if($_SESSION['residence'] ==2) echo 'selected' ?>>Albany</option>
			<option value="3"<?php if($_SESSION['residence'] ==3) echo 'selected' ?>>Alexandria</option>
			<option value="4"<?php if($_SESSION['residence'] ==4) echo 'selected' ?>>Allenstown</option>
			<option value="5"<?php if($_SESSION['residence'] ==5) echo 'selected' ?>>Alstead</option>
			<option value="6"<?php if($_SESSION['residence'] ==6) echo 'selected' ?>>Alton</option>
			<option value="7"<?php if($_SESSION['residence'] ==7) echo 'selected' ?>>Amherst</option>
			<option value="8"<?php if($_SESSION['residence'] ==8) echo 'selected' ?>>Andover</option>
			<option value="9"<?php if($_SESSION['residence'] ==9) echo 'selected' ?>>Antrim</option>
			<option value="10"<?php if($_SESSION['residence'] ==10) echo 'selected' ?>>Ashland</option>
			<option value="11"<?php if($_SESSION['residence'] ==11) echo 'selected' ?>>Atkinson and Gilmanton Academy Grant</option>
			<option value="12"<?php if($_SESSION['residence'] ==12) echo 'selected' ?>>Atkinson</option>
			<option value="13"<?php if($_SESSION['residence'] ==13) echo 'selected' ?>>Auburn</option>
			<option value="14"<?php if($_SESSION['residence'] ==14) echo 'selected' ?>>Barnstead</option>
			<option value="15"<?php if($_SESSION['residence'] ==15) echo 'selected' ?>>Barrington</option>
			<option value="16"<?php if($_SESSION['residence'] ==16) echo 'selected' ?>>Bartlett</option>
			<option value="17"<?php if($_SESSION['residence'] ==17) echo 'selected' ?>>Bath</option>
			<option value="18"<?php if($_SESSION['residence'] ==18) echo 'selected' ?>>Beans Grant</option>
			<option value="19"<?php if($_SESSION['residence'] ==19) echo 'selected' ?>>Beans Purchase</option>
			<option value="20"<?php if($_SESSION['residence'] ==20) echo 'selected' ?>>Bedford</option>
			<option value="21"<?php if($_SESSION['residence'] ==21) echo 'selected' ?>>Belmont</option>
			<option value="22"<?php if($_SESSION['residence'] ==22) echo 'selected' ?>>Bennington</option>
			<option value="23"<?php if($_SESSION['residence'] ==23) echo 'selected' ?>>Benton</option>
			<option value="24"<?php if($_SESSION['residence'] ==24) echo 'selected' ?>>Berlin</option>
			<option value="25"<?php if($_SESSION['residence'] ==25) echo 'selected' ?>>Bethlehem</option>
			<option value="26"<?php if($_SESSION['residence'] ==26) echo 'selected' ?>>Boscawen</option>
			<option value="27"<?php if($_SESSION['residence'] ==27) echo 'selected' ?>>Bow</option>
			<option value="28"<?php if($_SESSION['residence'] ==28) echo 'selected' ?>>Bradford</option>
			<option value="29"<?php if($_SESSION['residence'] ==29) echo 'selected' ?>>Brentwood</option>
			<option value="30"<?php if($_SESSION['residence'] ==30) echo 'selected' ?>>Bridgewater</option>
			<option value="31"<?php if($_SESSION['residence'] ==31) echo 'selected' ?>>Bristol</option>
			<option value="32"<?php if($_SESSION['residence'] ==32) echo 'selected' ?>>Brookfield</option>
			<option value="33"<?php if($_SESSION['residence'] ==33) echo 'selected' ?>>Brookline</option>
			<option value="34"<?php if($_SESSION['residence'] ==34) echo 'selected' ?>>Cambridge Township</option>
			<option value="35"<?php if($_SESSION['residence'] ==35) echo 'selected' ?>>Campton</option>
			<option value="36"<?php if($_SESSION['residence'] ==36) echo 'selected' ?>>Canaan</option>
			<option value="37"<?php if($_SESSION['residence'] ==37) echo 'selected' ?>>Candia</option>
			<option value="38"<?php if($_SESSION['residence'] ==38) echo 'selected' ?>>Canterbury</option>
			<option value="39"<?php if($_SESSION['residence'] ==39) echo 'selected' ?>>Carroll</option>
			<option value="40"<?php if($_SESSION['residence'] ==40) echo 'selected' ?>>Center-Harbor</option>
			<option value="41"<?php if($_SESSION['residence'] ==41) echo 'selected' ?>>Chandlers Purchase</option>
			<option value="42"<?php if($_SESSION['residence'] ==42) echo 'selected' ?>>Charlestown</option>
			<option value="43"<?php if($_SESSION['residence'] ==43) echo 'selected' ?>>Chatham</option>
			<option value="44"<?php if($_SESSION['residence'] ==44) echo 'selected' ?>>Chester</option>
			<option value="45"<?php if($_SESSION['residence'] ==45) echo 'selected' ?>>Chesterfield</option>
			<option value="46"<?php if($_SESSION['residence'] ==46) echo 'selected' ?>>Chichester</option>
			<option value="47"<?php if($_SESSION['residence'] ==47) echo 'selected' ?>>Claremont</option>
			<option value="48"<?php if($_SESSION['residence'] ==48) echo 'selected' ?>>Clarksville</option>
			<option value="49"<?php if($_SESSION['residence'] ==49) echo 'selected' ?>>Colebrook</option>
			<option value="50"<?php if($_SESSION['residence'] ==50) echo 'selected' ?>>Columbia</option>
			<option value="51"<?php if($_SESSION['residence'] ==51) echo 'selected' ?>>Concord</option>
			<option value="52"<?php if($_SESSION['residence'] ==52) echo 'selected' ?>>Conway</option>
			<option value="53"<?php if($_SESSION['residence'] ==53) echo 'selected' ?>>Cornish </option>
			<option value="54"<?php if($_SESSION['residence'] ==54) echo 'selected' ?>>Crawfords Purchase</option>
			<option value="55"<?php if($_SESSION['residence'] ==55) echo 'selected' ?>>Croydon</option>
			<option value="56"<?php if($_SESSION['residence'] ==56) echo 'selected' ?>>Cutts Grant</option>
			<option value="57"<?php if($_SESSION['residence'] ==57) echo 'selected' ?>>Dalton</option>
			<option value="58"<?php if($_SESSION['residence'] ==58) echo 'selected' ?>>Danbury</option>
			<option value="59"<?php if($_SESSION['residence'] ==59) echo 'selected' ?>>Danville</option>
			<option value="60"<?php if($_SESSION['residence'] ==60) echo 'selected' ?>>Deerfield</option>
			<option value="61"<?php if($_SESSION['residence'] ==61) echo 'selected' ?>>Deering</option>
			<option value="62"<?php if($_SESSION['residence'] ==62) echo 'selected' ?>>Derry</option>
			<option value="63"<?php if($_SESSION['residence'] ==63) echo 'selected' ?>>Dixs Grant</option>
			<option value="64"<?php if($_SESSION['residence'] ==64) echo 'selected' ?>>Dixville Township</option>
			<option value="65"<?php if($_SESSION['residence'] ==65) echo 'selected' ?>>Dorchester</option>
			<option value="66"<?php if($_SESSION['residence'] ==66) echo 'selected' ?>>Dover</option>
			<option value="67"<?php if($_SESSION['residence'] ==67) echo 'selected' ?>>Dublin</option>
			<option value="68"<?php if($_SESSION['residence'] ==68) echo 'selected' ?>>Dummer</option>
			<option value="69"<?php if($_SESSION['residence'] ==69) echo 'selected' ?>>Dunbarton</option>
			<option value="70"<?php if($_SESSION['residence'] ==70) echo 'selected' ?>>Durham</option>
			<option value="71"<?php if($_SESSION['residence'] ==71) echo 'selected' ?>>East Kingston</option>
			<option value="72"<?php if($_SESSION['residence'] ==72) echo 'selected' ?>>Easton</option>
			<option value="73"<?php if($_SESSION['residence'] ==73) echo 'selected' ?>>Eaton</option>
			<option value="74"<?php if($_SESSION['residence'] ==74) echo 'selected' ?>>Effingham</option>
			<option value="75"<?php if($_SESSION['residence'] ==75) echo 'selected' ?>>Ellsworth</option>
			<option value="76"<?php if($_SESSION['residence'] ==76) echo 'selected' ?>>Enfield</option>
			<option value="77"<?php if($_SESSION['residence'] ==77) echo 'selected' ?>>Epping</option>
			<option value="78"<?php if($_SESSION['residence'] ==78) echo 'selected' ?>>Epsom</option>
			<option value="79"<?php if($_SESSION['residence'] ==79) echo 'selected' ?>>Errol</option>
			<option value="80"<?php if($_SESSION['residence'] ==80) echo 'selected' ?>>Ervings Location</option>
			<option value="81"<?php if($_SESSION['residence'] ==81) echo 'selected' ?>>Exeter</option>
			<option value="82"<?php if($_SESSION['residence'] ==82) echo 'selected' ?>>Farmington</option>
			<option value="83"<?php if($_SESSION['residence'] ==83) echo 'selected' ?>>Fitzwilliam</option>
			<option value="84"<?php if($_SESSION['residence'] ==84) echo 'selected' ?>>Francestown</option>
			<option value="85"<?php if($_SESSION['residence'] ==85) echo 'selected' ?>>Franconia</option>
			<option value="86"<?php if($_SESSION['residence'] ==86) echo 'selected' ?>>Franklin</option>
			<option value="87"<?php if($_SESSION['residence'] ==87) echo 'selected' ?>>Freedom</option>
			<option value="88"<?php if($_SESSION['residence'] ==88) echo 'selected' ?>>Fremont</option>
			<option value="89"<?php if($_SESSION['residence'] ==89) echo 'selected' ?>>Gilford</option>
			<option value="90"<?php if($_SESSION['residence'] ==90) echo 'selected' ?>>Gilmanton</option>
			<option value="91"<?php if($_SESSION['residence'] ==91) echo 'selected' ?>>Gilsum</option>
			<option value="92"<?php if($_SESSION['residence'] ==92) echo 'selected' ?>>Goffstown</option>
			<option value="93"<?php if($_SESSION['residence'] ==93) echo 'selected' ?>>Gorham</option>
			<option value="94"<?php if($_SESSION['residence'] ==94) echo 'selected' ?>>Goshen</option>
			<option value="95"<?php if($_SESSION['residence'] ==95) echo 'selected' ?>>Grafton</option>
			<option value="96"<?php if($_SESSION['residence'] ==96) echo 'selected' ?>>Grantham</option>
			<option value="97"<?php if($_SESSION['residence'] ==97) echo 'selected' ?>>Greenfield</option>
			<option value="98"<?php if($_SESSION['residence'] ==98) echo 'selected' ?>>Greenland</option>
			<option value="99"<?php if($_SESSION['residence'] ==99) echo 'selected' ?>>Greens Grant</option>
			<option value="100"<?php if($_SESSION['residence'] ==100) echo 'selected' ?>>Greenville</option>
			<option value="101"<?php if($_SESSION['residence'] ==101) echo 'selected' ?>>Groton</option>
			<option value="102"<?php if($_SESSION['residence'] ==102) echo 'selected' ?>>Hadleys Purchase</option>
			<option value="103"<?php if($_SESSION['residence'] ==103) echo 'selected' ?>>Hale's Location</option>
			<option value="104"<?php if($_SESSION['residence'] ==104) echo 'selected' ?>>Hampstead</option>
			<option value="105"<?php if($_SESSION['residence'] ==105) echo 'selected' ?>>Hampton Falls</option>
			<option value="106"<?php if($_SESSION['residence'] ==106) echo 'selected' ?>>Hampton</option>
			<option value="107"<?php if($_SESSION['residence'] ==107) echo 'selected' ?>>Hancock</option>
			<option value="108"<?php if($_SESSION['residence'] ==108) echo 'selected' ?>>Hanover</option>
			<option value="109"<?php if($_SESSION['residence'] ==109) echo 'selected' ?>>Harrisville</option>
			<option value="110"<?php if($_SESSION['residence'] ==110) echo 'selected' ?>>Hart's Location</option>
			<option value="111"<?php if($_SESSION['residence'] ==111) echo 'selected' ?>>Haverhill</option>
			<option value="112"<?php if($_SESSION['residence'] ==112) echo 'selected' ?>>Hebron</option>
			<option value="113"<?php if($_SESSION['residence'] ==113) echo 'selected' ?>>Henniker</option>
			<option value="114"<?php if($_SESSION['residence'] ==114) echo 'selected' ?>>Hill</option>
			<option value="115"<?php if($_SESSION['residence'] ==115) echo 'selected' ?>>Hillsborough</option>
			<option value="116"<?php if($_SESSION['residence'] ==116) echo 'selected' ?>>Hinsdale</option>
			<option value="117"<?php if($_SESSION['residence'] ==117) echo 'selected' ?>>Holderness</option>
			<option value="118"<?php if($_SESSION['residence'] ==118) echo 'selected' ?>>Hollis</option>
			<option value="119"<?php if($_SESSION['residence'] ==119) echo 'selected' ?>>Hooksett</option>
			<option value="120"<?php if($_SESSION['residence'] ==120) echo 'selected' ?>>Hopkinton</option>
			<option value="121"<?php if($_SESSION['residence'] ==121) echo 'selected' ?>>Hudson</option>
			<option value="122"<?php if($_SESSION['residence'] ==122) echo 'selected' ?>>Jackson</option>
			<option value="123"<?php if($_SESSION['residence'] ==123) echo 'selected' ?>>Jaffrey</option>
			<option value="124"<?php if($_SESSION['residence'] ==124) echo 'selected' ?>>Jefferson</option>
			<option value="125"<?php if($_SESSION['residence'] ==125) echo 'selected' ?>>Keene</option>
			<option value="126"<?php if($_SESSION['residence'] ==126) echo 'selected' ?>>Kensington</option>
			<option value="127"<?php if($_SESSION['residence'] ==127) echo 'selected' ?>>Kilkenny Township</option>
			<option value="128"<?php if($_SESSION['residence'] ==128) echo 'selected' ?>>Kingston</option>
			<option value="129"<?php if($_SESSION['residence'] ==129) echo 'selected' ?>>Laconia</option>
			<option value="130"<?php if($_SESSION['residence'] ==130) echo 'selected' ?>>Lancaster</option>
			<option value="131"<?php if($_SESSION['residence'] ==131) echo 'selected' ?>>Landaff</option>
			<option value="132"<?php if($_SESSION['residence'] ==132) echo 'selected' ?>>Langdon</option>
			<option value="133"<?php if($_SESSION['residence'] ==133) echo 'selected' ?>>Lebanon</option>
			<option value="134"<?php if($_SESSION['residence'] ==134) echo 'selected' ?>>Lee</option>
			<option value="135"<?php if($_SESSION['residence'] ==135) echo 'selected' ?>>Lempster</option>
			<option value="136"<?php if($_SESSION['residence'] ==136) echo 'selected' ?>>Lincoln</option>
			<option value="137"<?php if($_SESSION['residence'] ==137) echo 'selected' ?>>Lisbon</option>
			<option value="138"<?php if($_SESSION['residence'] ==138) echo 'selected' ?>>Litchfield</option>
			<option value="139"<?php if($_SESSION['residence'] ==139) echo 'selected' ?>>Littleton</option>
			<option value="140"<?php if($_SESSION['residence'] ==140) echo 'selected' ?>>Livermore</option>
			<option value="141"<?php if($_SESSION['residence'] ==141) echo 'selected' ?>>Londonderry</option>
			<option value="142"<?php if($_SESSION['residence'] ==142) echo 'selected' ?>>Loudon</option>
			<option value="143"<?php if($_SESSION['residence'] ==143) echo 'selected' ?>>Low and Burbanks Grant</option>
			<option value="144"<?php if($_SESSION['residence'] ==144) echo 'selected' ?>>Lyman</option>
			<option value="145"<?php if($_SESSION['residence'] ==145) echo 'selected' ?>>Lyme</option>
			<option value="146"<?php if($_SESSION['residence'] ==146) echo 'selected' ?>>Lyndeborough</option>
			<option value="147"<?php if($_SESSION['residence'] ==147) echo 'selected' ?>>Madbury</option>
			<option value="148"<?php if($_SESSION['residence'] ==148) echo 'selected' ?>>Madison</option>
			<option value="149"<?php if($_SESSION['residence'] ==149) echo 'selected' ?>>Manchester</option>
			<option value="150"<?php if($_SESSION['residence'] ==150) echo 'selected' ?>>Marlborough</option>
			<option value="151"<?php if($_SESSION['residence'] ==151) echo 'selected' ?>>Marlow</option>
			<option value="152"<?php if($_SESSION['residence'] ==152) echo 'selected' ?>>Martins Location</option>
			<option value="153"<?php if($_SESSION['residence'] ==153) echo 'selected' ?>>Mason</option>
			<option value="154"<?php if($_SESSION['residence'] ==154) echo 'selected' ?>>Meredith</option>
			<option value="155"<?php if($_SESSION['residence'] ==155) echo 'selected' ?>>Merrimack</option>
			<option value="156"<?php if($_SESSION['residence'] ==156) echo 'selected' ?>>Middleton</option>
			<option value="157"<?php if($_SESSION['residence'] ==157) echo 'selected' ?>>Milan</option>
			<option value="158"<?php if($_SESSION['residence'] ==158) echo 'selected' ?>>Milford</option>
			<option value="159"<?php if($_SESSION['residence'] ==159) echo 'selected' ?>>Millsfield Township</option>
			<option value="160"<?php if($_SESSION['residence'] ==160) echo 'selected' ?>>Milton</option>
			<option value="161"<?php if($_SESSION['residence'] ==161) echo 'selected' ?>>Monroe</option>
			<option value="162"<?php if($_SESSION['residence'] ==162) echo 'selected' ?>>Mont Vernon</option>
			<option value="163"<?php if($_SESSION['residence'] ==163) echo 'selected' ?>>Moultonborough</option>
			<option value="164"<?php if($_SESSION['residence'] ==164) echo 'selected' ?>>Nashua</option>
			<option value="165"<?php if($_SESSION['residence'] ==165) echo 'selected' ?>>Nelson</option>
			<option value="166"<?php if($_SESSION['residence'] ==166) echo 'selected' ?>>New Boston</option>
			<option value="167"<?php if($_SESSION['residence'] ==167) echo 'selected' ?>>New Castle</option>
			<option value="168"<?php if($_SESSION['residence'] ==168) echo 'selected' ?>>New Durham</option>
			<option value="169"<?php if($_SESSION['residence'] ==169) echo 'selected' ?>>New Hampton</option>
			<option value="170"<?php if($_SESSION['residence'] ==170) echo 'selected' ?>>New Ipswich</option>
			<option value="171"<?php if($_SESSION['residence'] ==171) echo 'selected' ?>>New London</option>
			<option value="172"<?php if($_SESSION['residence'] ==172) echo 'selected' ?>>Newbury</option>
			<option value="173"<?php if($_SESSION['residence'] ==173) echo 'selected' ?>>Newfields</option>
			<option value="174"<?php if($_SESSION['residence'] ==174) echo 'selected' ?>>Newington</option>
			<option value="175"<?php if($_SESSION['residence'] ==175) echo 'selected' ?>>Newmarket</option>
			<option value="176"<?php if($_SESSION['residence'] ==176) echo 'selected' ?>>Newport</option>
			<option value="177"<?php if($_SESSION['residence'] ==177) echo 'selected' ?>>Newton</option>
			<option value="178"<?php if($_SESSION['residence'] ==178) echo 'selected' ?>>North Hampton</option>
			<option value="179"<?php if($_SESSION['residence'] ==179) echo 'selected' ?>>Northfield</option>
			<option value="180"<?php if($_SESSION['residence'] ==180) echo 'selected' ?>>Northumberland</option>
			<option value="181"<?php if($_SESSION['residence'] ==181) echo 'selected' ?>>Northwood</option>
			<option value="182"<?php if($_SESSION['residence'] ==182) echo 'selected' ?>>Nottingham</option>
			<option value="183"<?php if($_SESSION['residence'] ==183) echo 'selected' ?>>Odell Township</option>
			<option value="184"<?php if($_SESSION['residence'] ==184) echo 'selected' ?>>Orange</option>
			<option value="185"<?php if($_SESSION['residence'] ==185) echo 'selected' ?>>Orford</option>
			<option value="186"<?php if($_SESSION['residence'] ==186) echo 'selected' ?>>Ossipee</option>
			<option value="187"<?php if($_SESSION['residence'] ==187) echo 'selected' ?>>Pelham</option>
			<option value="188"<?php if($_SESSION['residence'] ==188) echo 'selected' ?>>Pembroke</option>
			<option value="189"<?php if($_SESSION['residence'] ==189) echo 'selected' ?>>Peterborough</option>
			<option value="190"<?php if($_SESSION['residence'] ==190) echo 'selected' ?>>Piermont</option>
			<option value="191"<?php if($_SESSION['residence'] ==191) echo 'selected' ?>>Pinkhams Grant</option>
			<option value="192"<?php if($_SESSION['residence'] ==192) echo 'selected' ?>>Pittsburg</option>
			<option value="193"<?php if($_SESSION['residence'] ==193) echo 'selected' ?>>Pittsfield</option>
			<option value="194"<?php if($_SESSION['residence'] ==194) echo 'selected' ?>>Plainfield</option>
			<option value="195"<?php if($_SESSION['residence'] ==195) echo 'selected' ?>>Plaistow</option>
			<option value="196"<?php if($_SESSION['residence'] ==196) echo 'selected' ?>>Plymouth</option>
			<option value="197"<?php if($_SESSION['residence'] ==197) echo 'selected' ?>>Portsmouth</option>
			<option value="198"<?php if($_SESSION['residence'] ==198) echo 'selected' ?>>Randolph</option>
			<option value="199"<?php if($_SESSION['residence'] ==199) echo 'selected' ?>>Raymond</option>
			<option value="200"<?php if($_SESSION['residence'] ==200) echo 'selected' ?>>Richmond</option>
			<option value="201"<?php if($_SESSION['residence'] ==201) echo 'selected' ?>>Rindge</option>
			<option value="202"<?php if($_SESSION['residence'] ==202) echo 'selected' ?>>Rochester</option>
			<option value="203"<?php if($_SESSION['residence'] ==203) echo 'selected' ?>>Rollinsford</option>
			<option value="204"<?php if($_SESSION['residence'] ==204) echo 'selected' ?>>Roxbury</option>
			<option value="205"<?php if($_SESSION['residence'] ==205) echo 'selected' ?>>Rumney</option>
			<option value="206"<?php if($_SESSION['residence'] ==206) echo 'selected' ?>>Rye</option>
			<option value="207"<?php if($_SESSION['residence'] ==207) echo 'selected' ?>>Salem</option>
			<option value="208"<?php if($_SESSION['residence'] ==208) echo 'selected' ?>>Salisbury</option>
			<option value="209"<?php if($_SESSION['residence'] ==209) echo 'selected' ?>>Sanbornton</option>
			<option value="210"<?php if($_SESSION['residence'] ==210) echo 'selected' ?>>Sandown</option>
			<option value="211"<?php if($_SESSION['residence'] ==211) echo 'selected' ?>>Sandwich</option>
			<option value="212"<?php if($_SESSION['residence'] ==212) echo 'selected' ?>>Sargents Purchase</option>
			<option value="213"<?php if($_SESSION['residence'] ==213) echo 'selected' ?>>Seabrook</option>
			<option value="214"<?php if($_SESSION['residence'] ==214) echo 'selected' ?>>Second College Grant</option>
			<option value="215"<?php if($_SESSION['residence'] ==215) echo 'selected' ?>>Sharon</option>
			<option value="216"<?php if($_SESSION['residence'] ==216) echo 'selected' ?>>Shelburne</option>
			<option value="217"<?php if($_SESSION['residence'] ==217) echo 'selected' ?>>Somerworth</option>
			<option value="218"<?php if($_SESSION['residence'] ==218) echo 'selected' ?>>South Hampton</option>
			<option value="219"<?php if($_SESSION['residence'] ==219) echo 'selected' ?>>Sprinfield</option>
			<option value="220"<?php if($_SESSION['residence'] ==220) echo 'selected' ?>>Stark</option>
			<option value="221"<?php if($_SESSION['residence'] ==221) echo 'selected' ?>>Stewartstown</option>
			<option value="222"<?php if($_SESSION['residence'] ==222) echo 'selected' ?>>Stoddard </option>
			<option value="223"<?php if($_SESSION['residence'] ==223) echo 'selected' ?>>Strafford</option>
			<option value="224"<?php if($_SESSION['residence'] ==224) echo 'selected' ?>>Stratford</option>
			<option value="225"<?php if($_SESSION['residence'] ==225) echo 'selected' ?>>Stratham</option>
			<option value="226"<?php if($_SESSION['residence'] ==226) echo 'selected' ?>>Success</option>
			<option value="227"<?php if($_SESSION['residence'] ==227) echo 'selected' ?>>Sugar Hill</option>
			<option value="228"<?php if($_SESSION['residence'] ==228) echo 'selected' ?>>Sullivan</option>
			<option value="229"<?php if($_SESSION['residence'] ==229) echo 'selected' ?>>Sunapee</option>
			<option value="230"<?php if($_SESSION['residence'] ==230) echo 'selected' ?>>Surry</option>
			<option value="231"<?php if($_SESSION['residence'] ==231) echo 'selected' ?>>Sutton</option>
			<option value="232"<?php if($_SESSION['residence'] ==232) echo 'selected' ?>>Swanzey</option>
			<option value="233"<?php if($_SESSION['residence'] ==233) echo 'selected' ?>>Tamworth</option>
			<option value="234"<?php if($_SESSION['residence'] ==234) echo 'selected' ?>>Temple</option>
			<option value="235"<?php if($_SESSION['residence'] ==235) echo 'selected' ?>>Thompson and Meserves Purchase</option>
			<option value="236"<?php if($_SESSION['residence'] ==236) echo 'selected' ?>>Thornton</option>
			<option value="237"<?php if($_SESSION['residence'] ==237) echo 'selected' ?>>Tilton</option>
			<option value="238"<?php if($_SESSION['residence'] ==238) echo 'selected' ?>>Troy</option>
			<option value="239"<?php if($_SESSION['residence'] ==239) echo 'selected' ?>>Tuftonboro</option>
			<option value="240"<?php if($_SESSION['residence'] ==240) echo 'selected' ?>>Unity</option>
			<option value="241"<?php if($_SESSION['residence'] ==241) echo 'selected' ?>>Wakefield</option>
			<option value="242"<?php if($_SESSION['residence'] ==242) echo 'selected' ?>>Walpole</option>
			<option value="243"<?php if($_SESSION['residence'] ==243) echo 'selected' ?>>Warner</option>
			<option value="244"<?php if($_SESSION['residence'] ==244) echo 'selected' ?>>Warren</option>
			<option value="245"<?php if($_SESSION['residence'] ==245) echo 'selected' ?>>Washington</option>
			<option value="246"<?php if($_SESSION['residence'] ==246) echo 'selected' ?>>Waterville Valley</option>
			<option value="247"<?php if($_SESSION['residence'] ==247) echo 'selected' ?>>Weare</option>
			<option value="248"<?php if($_SESSION['residence'] ==248) echo 'selected' ?>>Webster</option>
			<option value="249"<?php if($_SESSION['residence'] ==249) echo 'selected' ?>>Wentworth Location</option>
			<option value="250"<?php if($_SESSION['residence'] ==250) echo 'selected' ?>>Wentworth</option>
			<option value="251"<?php if($_SESSION['residence'] ==251) echo 'selected' ?>>Westmoreland</option>
			<option value="252"<?php if($_SESSION['residence'] ==252) echo 'selected' ?>>Whitefield</option>
			<option value="253"<?php if($_SESSION['residence'] ==253) echo 'selected' ?>>Wilmot</option>
			<option value="254"<?php if($_SESSION['residence'] ==254) echo 'selected' ?>>Wilton</option>
			<option value="255"<?php if($_SESSION['residence'] ==255) echo 'selected' ?>>Winchester</option>
			<option value="256"<?php if($_SESSION['residence'] ==256) echo 'selected' ?>>Windham</option>
			<option value="257"<?php if($_SESSION['residence'] ==257) echo 'selected' ?>>Windsor</option>
			<option value="258"<?php if($_SESSION['residence'] ==258) echo 'selected' ?>>Wolfeboro</option>
			<option value="259"<?php if($_SESSION['residence'] ==259) echo 'selected' ?>>Woodstock</option>

		<?php } else if ($_SESSION['state'] == 'ME' && $_SESSION['demo'] == 0) { ?>
			<option value="0"<?php if($_SESSION['residence'] ==0) echo 'selected' ?>>--Select Location--</option>
			<option value="1"<?php if($_SESSION['residence'] ==1) echo 'selected' ?>>Abbot</option>
			<option value="2"<?php if($_SESSION['residence'] ==2) echo 'selected' ?>>Acton</option>
			<option value="3"<?php if($_SESSION['residence'] ==3) echo 'selected' ?>>Addison</option>
			<option value="4"<?php if($_SESSION['residence'] ==4) echo 'selected' ?>>Albion</option>
			<option value="5"<?php if($_SESSION['residence'] ==5) echo 'selected' ?>>Alexander</option>
			<option value="6"<?php if($_SESSION['residence'] ==6) echo 'selected' ?>>Alfred</option>
			<option value="7"<?php if($_SESSION['residence'] ==7) echo 'selected' ?>>Allagash</option>
			<option value="8"<?php if($_SESSION['residence'] ==8) echo 'selected' ?>>Alna</option>
			<option value="9"<?php if($_SESSION['residence'] ==9) echo 'selected' ?>>Alton</option>
			<option value="10"<?php if($_SESSION['residence'] ==10) echo 'selected' ?>>Amherst</option>
			<option value="11"<?php if($_SESSION['residence'] ==11) echo 'selected' ?>>Amity</option>
			<option value="12"<?php if($_SESSION['residence'] ==12) echo 'selected' ?>>Andover</option>
			<option value="13"<?php if($_SESSION['residence'] ==13) echo 'selected' ?>>Anson</option>
			<option value="14"<?php if($_SESSION['residence'] ==14) echo 'selected' ?>>Appleton</option>
			<option value="15"<?php if($_SESSION['residence'] ==15) echo 'selected' ?>>Argyle UT</option>
			<option value="16"<?php if($_SESSION['residence'] ==16) echo 'selected' ?>>Arrowsic</option>
			<option value="17"<?php if($_SESSION['residence'] ==17) echo 'selected' ?>>Arundel</option>
			<option value="18"<?php if($_SESSION['residence'] ==18) echo 'selected' ?>>Ashland</option>
			<option value="19"<?php if($_SESSION['residence'] ==19) echo 'selected' ?>>Athens</option>
			<option value="20"<?php if($_SESSION['residence'] ==20) echo 'selected' ?>>Atkinson</option>
			<option value="21"<?php if($_SESSION['residence'] ==21) echo 'selected' ?>>Auburn</option>
			<option value="22"<?php if($_SESSION['residence'] ==22) echo 'selected' ?>>Augusta</option>
			<option value="23"<?php if($_SESSION['residence'] ==23) echo 'selected' ?>>Aurora</option>
			<option value="24"<?php if($_SESSION['residence'] ==24) echo 'selected' ?>>Avon</option>
			<option value="25"<?php if($_SESSION['residence'] ==25) echo 'selected' ?>>Baileyville</option>
			<option value="26"<?php if($_SESSION['residence'] ==26) echo 'selected' ?>>Baldwin</option>
			<option value="27"<?php if($_SESSION['residence'] ==27) echo 'selected' ?>>Bancroft</option>
			<option value="28"<?php if($_SESSION['residence'] ==28) echo 'selected' ?>>Bangor</option>
			<option value="29"<?php if($_SESSION['residence'] ==29) echo 'selected' ?>>Bar Harbor</option>
			<option value="30"<?php if($_SESSION['residence'] ==30) echo 'selected' ?>>Baring plantation</option>
			<option value="31"<?php if($_SESSION['residence'] ==31) echo 'selected' ?>>Bath</option>
			<option value="32"<?php if($_SESSION['residence'] ==32) echo 'selected' ?>>Beals</option>
			<option value="33"<?php if($_SESSION['residence'] ==33) echo 'selected' ?>>Beaver Cove</option>
			<option value="34"<?php if($_SESSION['residence'] ==34) echo 'selected' ?>>Beddington</option>
			<option value="35"<?php if($_SESSION['residence'] ==35) echo 'selected' ?>>Belfast</option>
			<option value="36"<?php if($_SESSION['residence'] ==36) echo 'selected' ?>>Belgrade</option>
			<option value="37"<?php if($_SESSION['residence'] ==37) echo 'selected' ?>>Belmont</option>
			<option value="38"<?php if($_SESSION['residence'] ==38) echo 'selected' ?>>Benton</option>
			<option value="39"<?php if($_SESSION['residence'] ==39) echo 'selected' ?>>Berwick</option>
			<option value="40"<?php if($_SESSION['residence'] ==40) echo 'selected' ?>>Bethel</option>
			<option value="41"<?php if($_SESSION['residence'] ==41) echo 'selected' ?>>Biddeford</option>
			<option value="42"<?php if($_SESSION['residence'] ==42) echo 'selected' ?>>Bingham</option>
			<option value="43"<?php if($_SESSION['residence'] ==43) echo 'selected' ?>>Blaine</option>
			<option value="44"<?php if($_SESSION['residence'] ==44) echo 'selected' ?>>Blanchard UT</option>
			<option value="45"<?php if($_SESSION['residence'] ==45) echo 'selected' ?>>Blue Hill</option>
			<option value="46"<?php if($_SESSION['residence'] ==46) echo 'selected' ?>>Boothbay Harbor</option>
			<option value="47"<?php if($_SESSION['residence'] ==47) echo 'selected' ?>>Boothbay</option>
			<option value="48"<?php if($_SESSION['residence'] ==48) echo 'selected' ?>>Bowdoin</option>
			<option value="49"<?php if($_SESSION['residence'] ==49) echo 'selected' ?>>Bowdoinham</option>
			<option value="50"<?php if($_SESSION['residence'] ==50) echo 'selected' ?>>Bowerbank</option>
			<option value="51"<?php if($_SESSION['residence'] ==51) echo 'selected' ?>>Bradford</option>
			<option value="52"<?php if($_SESSION['residence'] ==52) echo 'selected' ?>>Bradley</option>
			<option value="53"<?php if($_SESSION['residence'] ==53) echo 'selected' ?>>Bremen</option>
			<option value="54"<?php if($_SESSION['residence'] ==54) echo 'selected' ?>>Brewer</option>
			<option value="55"<?php if($_SESSION['residence'] ==55) echo 'selected' ?>>Bridgewater</option>
			<option value="56"<?php if($_SESSION['residence'] ==56) echo 'selected' ?>>Bridgton</option>
			<option value="57"<?php if($_SESSION['residence'] ==57) echo 'selected' ?>>Brighton plantation</option>
			<option value="58"<?php if($_SESSION['residence'] ==58) echo 'selected' ?>>Bristol</option>
			<option value="59"<?php if($_SESSION['residence'] ==59) echo 'selected' ?>>Brooklin</option>
			<option value="60"<?php if($_SESSION['residence'] ==60) echo 'selected' ?>>Brooks</option>
			<option value="61"<?php if($_SESSION['residence'] ==61) echo 'selected' ?>>Brooksville</option>
			<option value="62"<?php if($_SESSION['residence'] ==62) echo 'selected' ?>>Brownfield</option>
			<option value="63"<?php if($_SESSION['residence'] ==63) echo 'selected' ?>>Brownville</option>
			<option value="64"<?php if($_SESSION['residence'] ==64) echo 'selected' ?>>Brunswick</option>
			<option value="65"<?php if($_SESSION['residence'] ==65) echo 'selected' ?>>Buckfield</option>
			<option value="66"<?php if($_SESSION['residence'] ==66) echo 'selected' ?>>Bucksport</option>
			<option value="67"<?php if($_SESSION['residence'] ==67) echo 'selected' ?>>Burlington</option>
			<option value="68"<?php if($_SESSION['residence'] ==68) echo 'selected' ?>>Burnham</option>
			<option value="69"<?php if($_SESSION['residence'] ==69) echo 'selected' ?>>Buxton</option>
			<option value="70"<?php if($_SESSION['residence'] ==70) echo 'selected' ?>>Byron</option>
			<option value="71"<?php if($_SESSION['residence'] ==71) echo 'selected' ?>>Calais</option>
			<option value="72"<?php if($_SESSION['residence'] ==72) echo 'selected' ?>>Cambridge</option>
			<option value="73"<?php if($_SESSION['residence'] ==73) echo 'selected' ?>>Camden</option>
			<option value="74"<?php if($_SESSION['residence'] ==74) echo 'selected' ?>>Canaan</option>
			<option value="75"<?php if($_SESSION['residence'] ==75) echo 'selected' ?>>Canton</option>
			<option value="76"<?php if($_SESSION['residence'] ==76) echo 'selected' ?>>Cape Elizabeth</option>
			<option value="77"<?php if($_SESSION['residence'] ==77) echo 'selected' ?>>Caratunk</option>
			<option value="78"<?php if($_SESSION['residence'] ==78) echo 'selected' ?>>Caribou</option>
			<option value="79"<?php if($_SESSION['residence'] ==79) echo 'selected' ?>>Carmel</option>
			<option value="80"<?php if($_SESSION['residence'] ==80) echo 'selected' ?>>Carrabassett Valley</option>
			<option value="81"<?php if($_SESSION['residence'] ==81) echo 'selected' ?>>Carroll plantation</option>
			<option value="82"<?php if($_SESSION['residence'] ==82) echo 'selected' ?>>Carthage</option>
			<option value="83"<?php if($_SESSION['residence'] ==83) echo 'selected' ?>>Cary plantation</option>
			<option value="84"<?php if($_SESSION['residence'] ==84) echo 'selected' ?>>Casco</option>
			<option value="85"<?php if($_SESSION['residence'] ==85) echo 'selected' ?>>Castine</option>
			<option value="86"<?php if($_SESSION['residence'] ==86) echo 'selected' ?>>Castle Hill</option>
			<option value="87"<?php if($_SESSION['residence'] ==87) echo 'selected' ?>>Caswell</option>
			<option value="88"<?php if($_SESSION['residence'] ==88) echo 'selected' ?>>Central Aroostook UT</option>
			<option value="89"<?php if($_SESSION['residence'] ==89) echo 'selected' ?>>Central Hancock UT</option>
			<option value="90"<?php if($_SESSION['residence'] ==90) echo 'selected' ?>>Central Somerset UT</option>
			<option value="91"<?php if($_SESSION['residence'] ==91) echo 'selected' ?>>Chapman</option>
			<option value="92"<?php if($_SESSION['residence'] ==92) echo 'selected' ?>>Charleston</option>
			<option value="93"<?php if($_SESSION['residence'] ==93) echo 'selected' ?>>Charlotte</option>
			<option value="94"<?php if($_SESSION['residence'] ==94) echo 'selected' ?>>Chebeague Island</option>
			<option value="95"<?php if($_SESSION['residence'] ==95) echo 'selected' ?>>Chelsea</option>
			<option value="96"<?php if($_SESSION['residence'] ==96) echo 'selected' ?>>Cherryfield</option>
			<option value="97"<?php if($_SESSION['residence'] ==97) echo 'selected' ?>>Chester</option>
			<option value="98"<?php if($_SESSION['residence'] ==98) echo 'selected' ?>>Chesterville</option>
			<option value="99"<?php if($_SESSION['residence'] ==99) echo 'selected' ?>>China</option>
			<option value="100"<?php if($_SESSION['residence'] ==100) echo 'selected' ?>>Clifton</option>
			<option value="101"<?php if($_SESSION['residence'] ==101) echo 'selected' ?>>Clinton</option>
			<option value="102"<?php if($_SESSION['residence'] ==102) echo 'selected' ?>>Codyville plantation</option>
			<option value="103"<?php if($_SESSION['residence'] ==103) echo 'selected' ?>>Columbia Falls</option>
			<option value="104"<?php if($_SESSION['residence'] ==104) echo 'selected' ?>>Columbia</option>
			<option value="105"<?php if($_SESSION['residence'] ==105) echo 'selected' ?>>Connor UT</option>
			<option value="106"<?php if($_SESSION['residence'] ==106) echo 'selected' ?>>Cooper</option>
			<option value="107"<?php if($_SESSION['residence'] ==107) echo 'selected' ?>>Coplin plantation</option>
			<option value="108"<?php if($_SESSION['residence'] ==108) echo 'selected' ?>>Corinna</option>
			<option value="109"<?php if($_SESSION['residence'] ==109) echo 'selected' ?>>Corinth</option>
			<option value="110"<?php if($_SESSION['residence'] ==110) echo 'selected' ?>>Cornish</option>
			<option value="111"<?php if($_SESSION['residence'] ==111) echo 'selected' ?>>Cornville</option>
			<option value="112"<?php if($_SESSION['residence'] ==112) echo 'selected' ?>>Cranberry Isles</option>
			<option value="113"<?php if($_SESSION['residence'] ==113) echo 'selected' ?>>Crawford</option>
			<option value="114"<?php if($_SESSION['residence'] ==114) echo 'selected' ?>>Criehaven UT</option>
			<option value="115"<?php if($_SESSION['residence'] ==115) echo 'selected' ?>>Crystal</option>
			<option value="116"<?php if($_SESSION['residence'] ==116) echo 'selected' ?>>Cumberland</option>
			<option value="117"<?php if($_SESSION['residence'] ==117) echo 'selected' ?>>Cushing</option>
			<option value="118"<?php if($_SESSION['residence'] ==118) echo 'selected' ?>>Cutler</option>
			<option value="119"<?php if($_SESSION['residence'] ==119) echo 'selected' ?>>Cyr plantation</option>
			<option value="120"<?php if($_SESSION['residence'] ==120) echo 'selected' ?>>Dallas plantation</option>
			<option value="121"<?php if($_SESSION['residence'] ==121) echo 'selected' ?>>Damariscotta</option>
			<option value="122"<?php if($_SESSION['residence'] ==122) echo 'selected' ?>>Danforth</option>
			<option value="123"<?php if($_SESSION['residence'] ==123) echo 'selected' ?>>Dayton</option>
			<option value="124"<?php if($_SESSION['residence'] ==124) echo 'selected' ?>>Deblois</option>
			<option value="125"<?php if($_SESSION['residence'] ==125) echo 'selected' ?>>Dedham</option>
			<option value="126"<?php if($_SESSION['residence'] ==126) echo 'selected' ?>>Deer Isle</option>
			<option value="127"<?php if($_SESSION['residence'] ==127) echo 'selected' ?>>Denmark</option>
			<option value="128"<?php if($_SESSION['residence'] ==128) echo 'selected' ?>>Dennistown plantation</option>
			<option value="129"<?php if($_SESSION['residence'] ==129) echo 'selected' ?>>Dennysville</option>
			<option value="130"<?php if($_SESSION['residence'] ==130) echo 'selected' ?>>Detroit</option>
			<option value="131"<?php if($_SESSION['residence'] ==131) echo 'selected' ?>>Dexter</option>
			<option value="132"<?php if($_SESSION['residence'] ==132) echo 'selected' ?>>Dixfield</option>
			<option value="133"<?php if($_SESSION['residence'] ==133) echo 'selected' ?>>Dixmont</option>
			<option value="134"<?php if($_SESSION['residence'] ==134) echo 'selected' ?>>Dover-Foxcroft</option>
			<option value="135"<?php if($_SESSION['residence'] ==135) echo 'selected' ?>>Dresden</option>
			<option value="136"<?php if($_SESSION['residence'] ==136) echo 'selected' ?>>Drew plantation</option>
			<option value="137"<?php if($_SESSION['residence'] ==137) echo 'selected' ?>>Durham</option>
			<option value="138"<?php if($_SESSION['residence'] ==138) echo 'selected' ?>>Dyer Brook</option>
			<option value="139"<?php if($_SESSION['residence'] ==139) echo 'selected' ?>>Eagle Lake</option>
			<option value="140"<?php if($_SESSION['residence'] ==140) echo 'selected' ?>>East Central Franklin UT</option>
			<option value="141"<?php if($_SESSION['residence'] ==141) echo 'selected' ?>>East Central Penobscot UT</option>
			<option value="142"<?php if($_SESSION['residence'] ==142) echo 'selected' ?>>East Central Washington UT</option>
			<option value="143"<?php if($_SESSION['residence'] ==143) echo 'selected' ?>>East Hancock UT</option>
			<option value="144"<?php if($_SESSION['residence'] ==144) echo 'selected' ?>>East Machias</option>
			<option value="145"<?php if($_SESSION['residence'] ==145) echo 'selected' ?>>East Millinocket</option>
			<option value="146"<?php if($_SESSION['residence'] ==146) echo 'selected' ?>>Eastbrook</option>
			<option value="147"<?php if($_SESSION['residence'] ==147) echo 'selected' ?>>Easton</option>
			<option value="148"<?php if($_SESSION['residence'] ==148) echo 'selected' ?>>Eastport</option>
			<option value="149"<?php if($_SESSION['residence'] ==149) echo 'selected' ?>>Eddington</option>
			<option value="150"<?php if($_SESSION['residence'] ==150) echo 'selected' ?>>Edgecomb</option>
			<option value="151"<?php if($_SESSION['residence'] ==151) echo 'selected' ?>>Edinburg</option>
			<option value="152"<?php if($_SESSION['residence'] ==152) echo 'selected' ?>>Eliot</option>
			<option value="153"<?php if($_SESSION['residence'] ==153) echo 'selected' ?>>Ellsworth</option>
			<option value="154"<?php if($_SESSION['residence'] ==154) echo 'selected' ?>>Embden</option>
			<option value="155"<?php if($_SESSION['residence'] ==155) echo 'selected' ?>>Enfield</option>
			<option value="156"<?php if($_SESSION['residence'] ==156) echo 'selected' ?>>Etna</option>
			<option value="157"<?php if($_SESSION['residence'] ==157) echo 'selected' ?>>Eustis</option>
			<option value="158"<?php if($_SESSION['residence'] ==158) echo 'selected' ?>>Exeter</option>
			<option value="159"<?php if($_SESSION['residence'] ==159) echo 'selected' ?>>Fairfield</option>
			<option value="160"<?php if($_SESSION['residence'] ==160) echo 'selected' ?>>Falmouth</option>
			<option value="161"<?php if($_SESSION['residence'] ==161) echo 'selected' ?>>Farmingdale</option>
			<option value="162"<?php if($_SESSION['residence'] ==162) echo 'selected' ?>>Farmington</option>
			<option value="163"<?php if($_SESSION['residence'] ==163) echo 'selected' ?>>Fayette</option>
			<option value="164"<?php if($_SESSION['residence'] ==164) echo 'selected' ?>>Fort Fairfield</option>
			<option value="165"<?php if($_SESSION['residence'] ==165) echo 'selected' ?>>Fort Kent</option>
			<option value="166"<?php if($_SESSION['residence'] ==166) echo 'selected' ?>>Frankfort</option>
			<option value="167"<?php if($_SESSION['residence'] ==167) echo 'selected' ?>>Franklin</option>
			<option value="168"<?php if($_SESSION['residence'] ==168) echo 'selected' ?>>Freedom</option>
			<option value="169"<?php if($_SESSION['residence'] ==169) echo 'selected' ?>>Freeport</option>
			<option value="170"<?php if($_SESSION['residence'] ==170) echo 'selected' ?>>Frenchboro</option>
			<option value="171"<?php if($_SESSION['residence'] ==171) echo 'selected' ?>>Frenchville</option>
			<option value="172"<?php if($_SESSION['residence'] ==172) echo 'selected' ?>>Friendship</option>
			<option value="173"<?php if($_SESSION['residence'] ==173) echo 'selected' ?>>Frye Island</option>
			<option value="174"<?php if($_SESSION['residence'] ==174) echo 'selected' ?>>Fryeburg</option>
			<option value="175"<?php if($_SESSION['residence'] ==175) echo 'selected' ?>>Gardiner</option>
			<option value="176"<?php if($_SESSION['residence'] ==176) echo 'selected' ?>>Garfield plantation</option>
			<option value="177"<?php if($_SESSION['residence'] ==177) echo 'selected' ?>>Garland</option>
			<option value="178"<?php if($_SESSION['residence'] ==178) echo 'selected' ?>>Georgetown</option>
			<option value="179"<?php if($_SESSION['residence'] ==179) echo 'selected' ?>>Gilead</option>
			<option value="180"<?php if($_SESSION['residence'] ==180) echo 'selected' ?>>Glenburn</option>
			<option value="181"<?php if($_SESSION['residence'] ==181) echo 'selected' ?>>Glenwood plantation</option>
			<option value="182"<?php if($_SESSION['residence'] ==182) echo 'selected' ?>>Gorham</option>
			<option value="183"<?php if($_SESSION['residence'] ==183) echo 'selected' ?>>Gouldsboro</option>
			<option value="184"<?php if($_SESSION['residence'] ==184) echo 'selected' ?>>Grand Isle</option>
			<option value="185"<?php if($_SESSION['residence'] ==185) echo 'selected' ?>>Grand Lake Stream plantation</option>
			<option value="186"<?php if($_SESSION['residence'] ==186) echo 'selected' ?>>Gray</option>
			<option value="187"<?php if($_SESSION['residence'] ==187) echo 'selected' ?>>Great Pond</option>
			<option value="188"<?php if($_SESSION['residence'] ==188) echo 'selected' ?>>Greenbush</option>
			<option value="189"<?php if($_SESSION['residence'] ==189) echo 'selected' ?>>Greene</option>
			<option value="190"<?php if($_SESSION['residence'] ==190) echo 'selected' ?>>Greenville</option>
			<option value="191"<?php if($_SESSION['residence'] ==191) echo 'selected' ?>>Greenwood</option>
			<option value="192"<?php if($_SESSION['residence'] ==192) echo 'selected' ?>>Guilford</option>
			<option value="193"<?php if($_SESSION['residence'] ==193) echo 'selected' ?>>Hallowell</option>
			<option value="194"<?php if($_SESSION['residence'] ==194) echo 'selected' ?>>Hamlin</option>
			<option value="195"<?php if($_SESSION['residence'] ==195) echo 'selected' ?>>Hammond</option>
			<option value="196"<?php if($_SESSION['residence'] ==196) echo 'selected' ?>>Hampden</option>
			<option value="197"<?php if($_SESSION['residence'] ==197) echo 'selected' ?>>Hancock</option>
			<option value="198"<?php if($_SESSION['residence'] ==198) echo 'selected' ?>>Hanover</option>
			<option value="199"<?php if($_SESSION['residence'] ==199) echo 'selected' ?>>Harmony</option>
			<option value="200"<?php if($_SESSION['residence'] ==200) echo 'selected' ?>>Harpswell</option>
			<option value="201"<?php if($_SESSION['residence'] ==201) echo 'selected' ?>>Harrington</option>
			<option value="202"<?php if($_SESSION['residence'] ==202) echo 'selected' ?>>Harrison</option>
			<option value="203"<?php if($_SESSION['residence'] ==203) echo 'selected' ?>>Hartford</option>
			<option value="204"<?php if($_SESSION['residence'] ==204) echo 'selected' ?>>Hartland</option>
			<option value="205"<?php if($_SESSION['residence'] ==205) echo 'selected' ?>>Haynesville</option>
			<option value="206"<?php if($_SESSION['residence'] ==206) echo 'selected' ?>>Hebron</option>
			<option value="207"<?php if($_SESSION['residence'] ==207) echo 'selected' ?>>Hermon</option>
			<option value="208"<?php if($_SESSION['residence'] ==208) echo 'selected' ?>>Hersey</option>
			<option value="209"<?php if($_SESSION['residence'] ==209) echo 'selected' ?>>Hibberts gore</option>
			<option value="210"<?php if($_SESSION['residence'] ==210) echo 'selected' ?>>Highland plantation</option>
			<option value="211"<?php if($_SESSION['residence'] ==211) echo 'selected' ?>>Hiram</option>
			<option value="212"<?php if($_SESSION['residence'] ==212) echo 'selected' ?>>Hodgdon</option>
			<option value="213"<?php if($_SESSION['residence'] ==213) echo 'selected' ?>>Holden</option>
			<option value="214"<?php if($_SESSION['residence'] ==214) echo 'selected' ?>>Hollis</option>
			<option value="215"<?php if($_SESSION['residence'] ==215) echo 'selected' ?>>Hope</option>
			<option value="216"<?php if($_SESSION['residence'] ==216) echo 'selected' ?>>Houlton</option>
			<option value="217"<?php if($_SESSION['residence'] ==217) echo 'selected' ?>>Howland</option>
			<option value="218"<?php if($_SESSION['residence'] ==218) echo 'selected' ?>>Hudson</option>
			<option value="219"<?php if($_SESSION['residence'] ==219) echo 'selected' ?>>Industry</option>
			<option value="220"<?php if($_SESSION['residence'] ==220) echo 'selected' ?>>Island Falls</option>
			<option value="221"<?php if($_SESSION['residence'] ==221) echo 'selected' ?>>Isle au Haut</option>
			<option value="222"<?php if($_SESSION['residence'] ==222) echo 'selected' ?>>Islesboro</option>
			<option value="223"<?php if($_SESSION['residence'] ==223) echo 'selected' ?>>Jackman</option>
			<option value="224"<?php if($_SESSION['residence'] ==224) echo 'selected' ?>>Jackson</option>
			<option value="225"<?php if($_SESSION['residence'] ==225) echo 'selected' ?>>Jay</option>
			<option value="226"<?php if($_SESSION['residence'] ==226) echo 'selected' ?>>Jefferson</option>
			<option value="227"<?php if($_SESSION['residence'] ==227) echo 'selected' ?>>Jonesboro</option>
			<option value="228"<?php if($_SESSION['residence'] ==228) echo 'selected' ?>>Jonesport</option>
			<option value="229"<?php if($_SESSION['residence'] ==229) echo 'selected' ?>>Kenduskeag</option>
			<option value="230"<?php if($_SESSION['residence'] ==230) echo 'selected' ?>>Kennebunk</option>
			<option value="231"<?php if($_SESSION['residence'] ==231) echo 'selected' ?>>Kennebunkport</option>
			<option value="232"<?php if($_SESSION['residence'] ==232) echo 'selected' ?>>Kingfield</option>
			<option value="233"<?php if($_SESSION['residence'] ==233) echo 'selected' ?>>Kingman UT</option>
			<option value="234"<?php if($_SESSION['residence'] ==234) echo 'selected' ?>>Kingsbury plantation</option>
			<option value="235"<?php if($_SESSION['residence'] ==235) echo 'selected' ?>>Kittery</option>
			<option value="236"<?php if($_SESSION['residence'] ==236) echo 'selected' ?>>Knox</option>
			<option value="237"<?php if($_SESSION['residence'] ==237) echo 'selected' ?>>Lagrange</option>
			<option value="238"<?php if($_SESSION['residence'] ==238) echo 'selected' ?>>Lake View plantation</option>
			<option value="239"<?php if($_SESSION['residence'] ==239) echo 'selected' ?>>Lakeville</option>
			<option value="240"<?php if($_SESSION['residence'] ==240) echo 'selected' ?>>Lamoine</option>
			<option value="241"<?php if($_SESSION['residence'] ==241) echo 'selected' ?>>Lebanon</option>
			<option value="242"<?php if($_SESSION['residence'] ==242) echo 'selected' ?>>Lee</option>
			<option value="243"<?php if($_SESSION['residence'] ==243) echo 'selected' ?>>Leeds</option>
			<option value="244"<?php if($_SESSION['residence'] ==244) echo 'selected' ?>>Levant</option>
			<option value="245"<?php if($_SESSION['residence'] ==245) echo 'selected' ?>>Lewiston</option>
			<option value="246"<?php if($_SESSION['residence'] ==246) echo 'selected' ?>>Liberty</option>
			<option value="247"<?php if($_SESSION['residence'] ==247) echo 'selected' ?>>Limerick</option>
			<option value="248"<?php if($_SESSION['residence'] ==248) echo 'selected' ?>>Limestone</option>
			<option value="249"<?php if($_SESSION['residence'] ==249) echo 'selected' ?>>Limington</option>
			<option value="250"<?php if($_SESSION['residence'] ==250) echo 'selected' ?>>Lincoln plantation</option>
			<option value="251"<?php if($_SESSION['residence'] ==251) echo 'selected' ?>>Lincoln</option>
			<option value="252"<?php if($_SESSION['residence'] ==252) echo 'selected' ?>>Lincolnville</option>
			<option value="253"<?php if($_SESSION['residence'] ==253) echo 'selected' ?>>Linneus</option>
			<option value="254"<?php if($_SESSION['residence'] ==254) echo 'selected' ?>>Lisbon</option>
			<option value="255"<?php if($_SESSION['residence'] ==255) echo 'selected' ?>>Litchfield</option>
			<option value="256"<?php if($_SESSION['residence'] ==256) echo 'selected' ?>>Littleton</option>
			<option value="257"<?php if($_SESSION['residence'] ==257) echo 'selected' ?>>Livermore Falls</option>
			<option value="258"<?php if($_SESSION['residence'] ==258) echo 'selected' ?>>Livermore</option>
			<option value="259"<?php if($_SESSION['residence'] ==259) echo 'selected' ?>>Long Island</option>
			<option value="260"<?php if($_SESSION['residence'] ==260) echo 'selected' ?>>Louds Island UT</option>
			<option value="261"<?php if($_SESSION['residence'] ==261) echo 'selected' ?>>Lovell</option>
			<option value="262"<?php if($_SESSION['residence'] ==262) echo 'selected' ?>>Lowell</option>
			<option value="263"<?php if($_SESSION['residence'] ==263) echo 'selected' ?>>Lubec</option>
			<option value="264"<?php if($_SESSION['residence'] ==264) echo 'selected' ?>>Ludlow</option>
			<option value="265"<?php if($_SESSION['residence'] ==265) echo 'selected' ?>>Lyman</option>
			<option value="266"<?php if($_SESSION['residence'] ==266) echo 'selected' ?>>Machias</option>
			<option value="267"<?php if($_SESSION['residence'] ==267) echo 'selected' ?>>Machiasport</option>
			<option value="268"<?php if($_SESSION['residence'] ==268) echo 'selected' ?>>Macwahoc plantation</option>
			<option value="269"<?php if($_SESSION['residence'] ==269) echo 'selected' ?>>Madawaska</option>
			<option value="270"<?php if($_SESSION['residence'] ==270) echo 'selected' ?>>Madison</option>
			<option value="271"<?php if($_SESSION['residence'] ==271) echo 'selected' ?>>Magalloway plantation</option>
			<option value="272"<?php if($_SESSION['residence'] ==272) echo 'selected' ?>>Manchester</option>
			<option value="273"<?php if($_SESSION['residence'] ==273) echo 'selected' ?>>Mapleton</option>
			<option value="274"<?php if($_SESSION['residence'] ==274) echo 'selected' ?>>Mariaville</option>
			<option value="275"<?php if($_SESSION['residence'] ==275) echo 'selected' ?>>Mars Hill</option>
			<option value="276"<?php if($_SESSION['residence'] ==276) echo 'selected' ?>>Marshall Island UT</option>
			<option value="277"<?php if($_SESSION['residence'] ==277) echo 'selected' ?>>Marshfield</option>
			<option value="278"<?php if($_SESSION['residence'] ==278) echo 'selected' ?>>Masardis</option>
			<option value="279"<?php if($_SESSION['residence'] ==279) echo 'selected' ?>>Matinicus Isle plantation</option>
			<option value="280"<?php if($_SESSION['residence'] ==280) echo 'selected' ?>>Mattawamkeag</option>
			<option value="281"<?php if($_SESSION['residence'] ==281) echo 'selected' ?>>Maxfield</option>
			<option value="282"<?php if($_SESSION['residence'] ==282) echo 'selected' ?>>Mechanic Falls</option>
			<option value="283"<?php if($_SESSION['residence'] ==283) echo 'selected' ?>>Meddybemps</option>
			<option value="284"<?php if($_SESSION['residence'] ==284) echo 'selected' ?>>Medford</option>
			<option value="285"<?php if($_SESSION['residence'] ==285) echo 'selected' ?>>Medway</option>
			<option value="286"<?php if($_SESSION['residence'] ==286) echo 'selected' ?>>Mercer</option>
			<option value="287"<?php if($_SESSION['residence'] ==287) echo 'selected' ?>>Merrill</option>
			<option value="288"<?php if($_SESSION['residence'] ==288) echo 'selected' ?>>Mexico</option>
			<option value="289"<?php if($_SESSION['residence'] ==289) echo 'selected' ?>>Milbridge</option>
			<option value="290"<?php if($_SESSION['residence'] ==290) echo 'selected' ?>>Milford</option>
			<option value="291"<?php if($_SESSION['residence'] ==291) echo 'selected' ?>>Millinocket</option>
			<option value="292"<?php if($_SESSION['residence'] ==292) echo 'selected' ?>>Milo</option>
			<option value="293"<?php if($_SESSION['residence'] ==293) echo 'selected' ?>>Milton UT</option>
			<option value="294"<?php if($_SESSION['residence'] ==294) echo 'selected' ?>>Minot</option>
			<option value="295"<?php if($_SESSION['residence'] ==295) echo 'selected' ?>>Monhegan plantation</option>
			<option value="296"<?php if($_SESSION['residence'] ==296) echo 'selected' ?>>Monmouth</option>
			<option value="297"<?php if($_SESSION['residence'] ==297) echo 'selected' ?>>Monroe</option>
			<option value="298"<?php if($_SESSION['residence'] ==298) echo 'selected' ?>>Monson</option>
			<option value="299"<?php if($_SESSION['residence'] ==299) echo 'selected' ?>>Monticello</option>
			<option value="300"<?php if($_SESSION['residence'] ==300) echo 'selected' ?>>Montville</option>
			<option value="301"<?php if($_SESSION['residence'] ==301) echo 'selected' ?>>Moose River</option>
			<option value="302"<?php if($_SESSION['residence'] ==302) echo 'selected' ?>>Moro plantation</option>
			<option value="303"<?php if($_SESSION['residence'] ==303) echo 'selected' ?>>Morrill</option>
			<option value="304"<?php if($_SESSION['residence'] ==304) echo 'selected' ?>>Moscow</option>
			<option value="305"<?php if($_SESSION['residence'] ==305) echo 'selected' ?>>Mount Chase</option>
			<option value="306"<?php if($_SESSION['residence'] ==306) echo 'selected' ?>>Mount Desert</option>
			<option value="307"<?php if($_SESSION['residence'] ==307) echo 'selected' ?>>Mount Vernon</option>
			<option value="308"<?php if($_SESSION['residence'] ==308) echo 'selected' ?>>Muscle Ridge Island UT</option>
			<option value="309"<?php if($_SESSION['residence'] ==309) echo 'selected' ?>>Naples</option>
			<option value="310"<?php if($_SESSION['residence'] ==310) echo 'selected' ?>>Nashville plantation</option>
			<option value="311"<?php if($_SESSION['residence'] ==311) echo 'selected' ?>>New Canada</option>
			<option value="312"<?php if($_SESSION['residence'] ==312) echo 'selected' ?>>New Gloucester</option>
			<option value="313"<?php if($_SESSION['residence'] ==313) echo 'selected' ?>>New Limerick</option>
			<option value="314"<?php if($_SESSION['residence'] ==314) echo 'selected' ?>>New Portland</option>
			<option value="315"<?php if($_SESSION['residence'] ==315) echo 'selected' ?>>New Sharon</option>
			<option value="316"<?php if($_SESSION['residence'] ==316) echo 'selected' ?>>New Sweden</option>
			<option value="317"<?php if($_SESSION['residence'] ==317) echo 'selected' ?>>New Vineyard</option>
			<option value="318"<?php if($_SESSION['residence'] ==318) echo 'selected' ?>>Newburgh</option>
			<option value="319"<?php if($_SESSION['residence'] ==319) echo 'selected' ?>>Newcastle</option>
			<option value="320"<?php if($_SESSION['residence'] ==320) echo 'selected' ?>>Newfield</option>
			<option value="321"<?php if($_SESSION['residence'] ==321) echo 'selected' ?>>Newport</option>
			<option value="322"<?php if($_SESSION['residence'] ==322) echo 'selected' ?>>Newry</option>
			<option value="323"<?php if($_SESSION['residence'] ==323) echo 'selected' ?>>Nobleboro</option>
			<option value="324"<?php if($_SESSION['residence'] ==324) echo 'selected' ?>>Norridgewock</option>
			<option value="325"<?php if($_SESSION['residence'] ==325) echo 'selected' ?>>North Berwick</option>
			<option value="326"<?php if($_SESSION['residence'] ==326) echo 'selected' ?>>North Franklin UT</option>
			<option value="327"<?php if($_SESSION['residence'] ==327) echo 'selected' ?>>North Haven</option>
			<option value="328"<?php if($_SESSION['residence'] ==328) echo 'selected' ?>>North Oxford UT</option>
			<option value="329"<?php if($_SESSION['residence'] ==329) echo 'selected' ?>>North Penobscot UT</option>
			<option value="330"<?php if($_SESSION['residence'] ==330) echo 'selected' ?>>North Washington UT</option>
			<option value="331"<?php if($_SESSION['residence'] ==331) echo 'selected' ?>>North Yarmouth</option>
			<option value="332"<?php if($_SESSION['residence'] ==332) echo 'selected' ?>>Northeast Piscataquis UT</option>
			<option value="333"<?php if($_SESSION['residence'] ==333) echo 'selected' ?>>Northeast Somerset UT</option>
			<option value="334"<?php if($_SESSION['residence'] ==334) echo 'selected' ?>>Northfield</option>
			<option value="335"<?php if($_SESSION['residence'] ==335) echo 'selected' ?>>Northport</option>
			<option value="336"<?php if($_SESSION['residence'] ==336) echo 'selected' ?>>Northwest Aroostook UT</option>
			<option value="337"<?php if($_SESSION['residence'] ==337) echo 'selected' ?>>Northwest Hancock UT</option>
			<option value="338"<?php if($_SESSION['residence'] ==338) echo 'selected' ?>>Northwest Piscataquis UT</option>
			<option value="339"<?php if($_SESSION['residence'] ==339) echo 'selected' ?>>Northwest Somerset UT</option>
			<option value="340"<?php if($_SESSION['residence'] ==340) echo 'selected' ?>>Norway</option>
			<option value="341"<?php if($_SESSION['residence'] ==341) echo 'selected' ?>>Oakfield</option>
			<option value="342"<?php if($_SESSION['residence'] ==342) echo 'selected' ?>>Oakland</option>
			<option value="343"<?php if($_SESSION['residence'] ==343) echo 'selected' ?>>Ogunquit</option>
			<option value="344"<?php if($_SESSION['residence'] ==344) echo 'selected' ?>>Old Orchard Beach</option>
			<option value="345"<?php if($_SESSION['residence'] ==345) echo 'selected' ?>>Old Town</option>
			<option value="346"<?php if($_SESSION['residence'] ==346) echo 'selected' ?>>Orient</option>
			<option value="347"<?php if($_SESSION['residence'] ==347) echo 'selected' ?>>Orland</option>
			<option value="348"<?php if($_SESSION['residence'] ==348) echo 'selected' ?>>Orono</option>
			<option value="349"<?php if($_SESSION['residence'] ==349) echo 'selected' ?>>Orrington</option>
			<option value="350"<?php if($_SESSION['residence'] ==350) echo 'selected' ?>>Osborn</option>
			<option value="351"<?php if($_SESSION['residence'] ==351) echo 'selected' ?>>Otis</option>
			<option value="352"<?php if($_SESSION['residence'] ==352) echo 'selected' ?>>Otisfield</option>
			<option value="353"<?php if($_SESSION['residence'] ==353) echo 'selected' ?>>Owls Head</option>
			<option value="354"<?php if($_SESSION['residence'] ==354) echo 'selected' ?>>Oxbow plantation</option>
			<option value="355"<?php if($_SESSION['residence'] ==355) echo 'selected' ?>>Oxford</option>
			<option value="356"<?php if($_SESSION['residence'] ==356) echo 'selected' ?>>Palermo</option>
			<option value="357"<?php if($_SESSION['residence'] ==357) echo 'selected' ?>>Palmyra</option>
			<option value="358"<?php if($_SESSION['residence'] ==358) echo 'selected' ?>>Paris</option>
			<option value="359"<?php if($_SESSION['residence'] ==359) echo 'selected' ?>>Parkman</option>
			<option value="360"<?php if($_SESSION['residence'] ==360) echo 'selected' ?>>Parsonsfield</option>
			<option value="361"<?php if($_SESSION['residence'] ==361) echo 'selected' ?>>Passadumkeag</option>
			<option value="362"<?php if($_SESSION['residence'] ==362) echo 'selected' ?>>Passamaquoddy Indian Township Reservation</option>
			<option value="363"<?php if($_SESSION['residence'] ==363) echo 'selected' ?>>Passamaquoddy Pleasant Point Reservation</option>
			<option value="364"<?php if($_SESSION['residence'] ==364) echo 'selected' ?>>Patten</option>
			<option value="365"<?php if($_SESSION['residence'] ==365) echo 'selected' ?>>Pembroke</option>
			<option value="366"<?php if($_SESSION['residence'] ==366) echo 'selected' ?>>Penobscot Indian Island Reservation</option>
			<option value="367"<?php if($_SESSION['residence'] ==367) echo 'selected' ?>>Penobscot Indian Island Reservation</option>
			<option value="368"<?php if($_SESSION['residence'] ==368) echo 'selected' ?>>Penobscot</option>
			<option value="369"<?php if($_SESSION['residence'] ==369) echo 'selected' ?>>Perham</option>
			<option value="370"<?php if($_SESSION['residence'] ==370) echo 'selected' ?>>Perkins UT</option>
			<option value="371"<?php if($_SESSION['residence'] ==371) echo 'selected' ?>>Perry</option>
			<option value="372"<?php if($_SESSION['residence'] ==372) echo 'selected' ?>>Peru</option>
			<option value="373"<?php if($_SESSION['residence'] ==373) echo 'selected' ?>>Phillips</option>
			<option value="374"<?php if($_SESSION['residence'] ==374) echo 'selected' ?>>Phippsburg</option>
			<option value="375"<?php if($_SESSION['residence'] ==375) echo 'selected' ?>>Pittsfield</option>
			<option value="376"<?php if($_SESSION['residence'] ==376) echo 'selected' ?>>Pittston</option>
			<option value="377"<?php if($_SESSION['residence'] ==377) echo 'selected' ?>>Pleasant Ridge plantation</option>
			<option value="378"<?php if($_SESSION['residence'] ==378) echo 'selected' ?>>Plymouth</option>
			<option value="379"<?php if($_SESSION['residence'] ==379) echo 'selected' ?>>Poland</option>
			<option value="380"<?php if($_SESSION['residence'] ==380) echo 'selected' ?>>Portage Lake</option>
			<option value="381"<?php if($_SESSION['residence'] ==381) echo 'selected' ?>>Porter</option>
			<option value="382"<?php if($_SESSION['residence'] ==382) echo 'selected' ?>>Portland</option>
			<option value="383"<?php if($_SESSION['residence'] ==383) echo 'selected' ?>>Pownal</option>
			<option value="384"<?php if($_SESSION['residence'] ==384) echo 'selected' ?>>Prentiss UT</option>
			<option value="385"<?php if($_SESSION['residence'] ==385) echo 'selected' ?>>Presque Isle</option>
			<option value="386"<?php if($_SESSION['residence'] ==386) echo 'selected' ?>>Princeton</option>
			<option value="387"<?php if($_SESSION['residence'] ==387) echo 'selected' ?>>Prospect</option>
			<option value="388"<?php if($_SESSION['residence'] ==388) echo 'selected' ?>>Randolph</option>
			<option value="389"<?php if($_SESSION['residence'] ==389) echo 'selected' ?>>Rangeley plantation</option>
			<option value="390"<?php if($_SESSION['residence'] ==390) echo 'selected' ?>>Rangeley</option>
			<option value="391"<?php if($_SESSION['residence'] ==391) echo 'selected' ?>>Raymond</option>
			<option value="392"<?php if($_SESSION['residence'] ==392) echo 'selected' ?>>Readfield</option>
			<option value="393"<?php if($_SESSION['residence'] ==393) echo 'selected' ?>>Reed plantation</option>
			<option value="394"<?php if($_SESSION['residence'] ==394) echo 'selected' ?>>Richmond</option>
			<option value="395"<?php if($_SESSION['residence'] ==395) echo 'selected' ?>>Ripley</option>
			<option value="396"<?php if($_SESSION['residence'] ==396) echo 'selected' ?>>Robbinston</option>
			<option value="397"<?php if($_SESSION['residence'] ==397) echo 'selected' ?>>Rockland</option>
			<option value="398"<?php if($_SESSION['residence'] ==398) echo 'selected' ?>>Rockport</option>
			<option value="399"<?php if($_SESSION['residence'] ==399) echo 'selected' ?>>Rome</option>
			<option value="400"<?php if($_SESSION['residence'] ==400) echo 'selected' ?>>Roque Bluffs</option>
			<option value="401"<?php if($_SESSION['residence'] ==401) echo 'selected' ?>>Roxbury</option>
			<option value="402"<?php if($_SESSION['residence'] ==402) echo 'selected' ?>>Rumford</option>
			<option value="403"<?php if($_SESSION['residence'] ==403) echo 'selected' ?>>Sabattus</option>
			<option value="404"<?php if($_SESSION['residence'] ==404) echo 'selected' ?>>Saco</option>
			<option value="405"<?php if($_SESSION['residence'] ==405) echo 'selected' ?>>Sandy River plantation</option>
			<option value="406"<?php if($_SESSION['residence'] ==406) echo 'selected' ?>>Sanford</option>
			<option value="407"<?php if($_SESSION['residence'] ==407) echo 'selected' ?>>Sangerville</option>
			<option value="408"<?php if($_SESSION['residence'] ==408) echo 'selected' ?>>Scarborough</option>
			<option value="409"<?php if($_SESSION['residence'] ==409) echo 'selected' ?>>Searsmont</option>
			<option value="410"<?php if($_SESSION['residence'] ==410) echo 'selected' ?>>Searsport</option>
			<option value="411"<?php if($_SESSION['residence'] ==411) echo 'selected' ?>>Sebago</option>
			<option value="412"<?php if($_SESSION['residence'] ==412) echo 'selected' ?>>Sebec</option>
			<option value="413"<?php if($_SESSION['residence'] ==413) echo 'selected' ?>>Seboeis plantation</option>
			<option value="414"<?php if($_SESSION['residence'] ==414) echo 'selected' ?>>Seboomook Lake UT</option>
			<option value="415"<?php if($_SESSION['residence'] ==415) echo 'selected' ?>>Sedgwick</option>
			<option value="416"<?php if($_SESSION['residence'] ==416) echo 'selected' ?>>Shapleigh</option>
			<option value="417"<?php if($_SESSION['residence'] ==417) echo 'selected' ?>>Sherman</option>
			<option value="418"<?php if($_SESSION['residence'] ==418) echo 'selected' ?>>Shirley</option>
			<option value="419"<?php if($_SESSION['residence'] ==419) echo 'selected' ?>>Sidney</option>
			<option value="420"<?php if($_SESSION['residence'] ==420) echo 'selected' ?>>Skowhegan</option>
			<option value="421"<?php if($_SESSION['residence'] ==421) echo 'selected' ?>>Smithfield</option>
			<option value="422"<?php if($_SESSION['residence'] ==422) echo 'selected' ?>>Smyrna</option>
			<option value="423"<?php if($_SESSION['residence'] ==423) echo 'selected' ?>>Solon</option>
			<option value="424"<?php if($_SESSION['residence'] ==424) echo 'selected' ?>>Somerville</option>
			<option value="425"<?php if($_SESSION['residence'] ==425) echo 'selected' ?>>Sorrento</option>
			<option value="426"<?php if($_SESSION['residence'] ==426) echo 'selected' ?>>South Aroostook UT</option>
			<option value="427"<?php if($_SESSION['residence'] ==427) echo 'selected' ?>>South Berwick</option>
			<option value="428"<?php if($_SESSION['residence'] ==428) echo 'selected' ?>>South Bristol</option>
			<option value="429"<?php if($_SESSION['residence'] ==429) echo 'selected' ?>>South Franklin UT</option>
			<option value="430"<?php if($_SESSION['residence'] ==430) echo 'selected' ?>>South Oxford UT</option>
			<option value="431"<?php if($_SESSION['residence'] ==431) echo 'selected' ?>>South Portland</option>
			<option value="432"<?php if($_SESSION['residence'] ==432) echo 'selected' ?>>South Thomaston</option>
			<option value="433"<?php if($_SESSION['residence'] ==433) echo 'selected' ?>>Southeast Piscataquis UT</option>
			<option value="434"<?php if($_SESSION['residence'] ==434) echo 'selected' ?>>Southport</option>
			<option value="435"<?php if($_SESSION['residence'] ==435) echo 'selected' ?>>Southwest Harbor</option>
			<option value="436"<?php if($_SESSION['residence'] ==436) echo 'selected' ?>>Springfield</option>
			<option value="437"<?php if($_SESSION['residence'] ==437) echo 'selected' ?>>Square Lake UT</option>
			<option value="438"<?php if($_SESSION['residence'] ==438) echo 'selected' ?>>St. Agatha</option>
			<option value="439"<?php if($_SESSION['residence'] ==439) echo 'selected' ?>>St. Albans</option>
			<option value="440"<?php if($_SESSION['residence'] ==440) echo 'selected' ?>>St. Francis</option>
			<option value="441"<?php if($_SESSION['residence'] ==441) echo 'selected' ?>>St. George</option>
			<option value="442"<?php if($_SESSION['residence'] ==442) echo 'selected' ?>>St. John plantation</option>
			<option value="443"<?php if($_SESSION['residence'] ==443) echo 'selected' ?>>Stacyville</option>
			<option value="444"<?php if($_SESSION['residence'] ==444) echo 'selected' ?>>Standish</option>
			<option value="445"<?php if($_SESSION['residence'] ==445) echo 'selected' ?>>Starks</option>
			<option value="446"<?php if($_SESSION['residence'] ==446) echo 'selected' ?>>Stetson</option>
			<option value="447"<?php if($_SESSION['residence'] ==447) echo 'selected' ?>>Steuben</option>
			<option value="448"<?php if($_SESSION['residence'] ==448) echo 'selected' ?>>Stockholm</option>
			<option value="449"<?php if($_SESSION['residence'] ==449) echo 'selected' ?>>Stockton Springs</option>
			<option value="450"<?php if($_SESSION['residence'] ==450) echo 'selected' ?>>Stoneham</option>
			<option value="451"<?php if($_SESSION['residence'] ==451) echo 'selected' ?>>Stonington</option>
			<option value="452"<?php if($_SESSION['residence'] ==452) echo 'selected' ?>>Stow</option>
			<option value="453"<?php if($_SESSION['residence'] ==453) echo 'selected' ?>>Strong</option>
			<option value="454"<?php if($_SESSION['residence'] ==454) echo 'selected' ?>>Sullivan</option>
			<option value="455"<?php if($_SESSION['residence'] ==455) echo 'selected' ?>>Sumner</option>
			<option value="456"<?php if($_SESSION['residence'] ==456) echo 'selected' ?>>Surry</option>
			<option value="457"<?php if($_SESSION['residence'] ==457) echo 'selected' ?>>Swans Island</option>
			<option value="458"<?php if($_SESSION['residence'] ==458) echo 'selected' ?>>Swanville</option>
			<option value="459"<?php if($_SESSION['residence'] ==459) echo 'selected' ?>>Sweden</option>
			<option value="460"<?php if($_SESSION['residence'] ==460) echo 'selected' ?>>Talmadge</option>
			<option value="461"<?php if($_SESSION['residence'] ==461) echo 'selected' ?>>Temple</option>
			<option value="462"<?php if($_SESSION['residence'] ==462) echo 'selected' ?>>The Forks plantation</option>
			<option value="463"<?php if($_SESSION['residence'] ==463) echo 'selected' ?>>Thomaston</option>
			<option value="464"<?php if($_SESSION['residence'] ==464) echo 'selected' ?>>Thorndike</option>
			<option value="465"<?php if($_SESSION['residence'] ==465) echo 'selected' ?>>Topsfield</option>
			<option value="466"<?php if($_SESSION['residence'] ==466) echo 'selected' ?>>Topsham</option>
			<option value="467"<?php if($_SESSION['residence'] ==467) echo 'selected' ?>>Tremont</option>
			<option value="468"<?php if($_SESSION['residence'] ==468) echo 'selected' ?>>Trenton</option>
			<option value="469"<?php if($_SESSION['residence'] ==469) echo 'selected' ?>>Troy</option>
			<option value="470"<?php if($_SESSION['residence'] ==470) echo 'selected' ?>>Turner</option>
			<option value="471"<?php if($_SESSION['residence'] ==471) echo 'selected' ?>>Twombly UT</option>
			<option value="472"<?php if($_SESSION['residence'] ==472) echo 'selected' ?>>Union</option>
			<option value="473"<?php if($_SESSION['residence'] ==473) echo 'selected' ?>>Unity</option>
			<option value="474"<?php if($_SESSION['residence'] ==474) echo 'selected' ?>>Unity UT</option>
			<option value="475"<?php if($_SESSION['residence'] ==475) echo 'selected' ?>>Upton</option>
			<option value="476"<?php if($_SESSION['residence'] ==476) echo 'selected' ?>>Van Buren</option>
			<option value="477"<?php if($_SESSION['residence'] ==477) echo 'selected' ?>>Vanceboro</option>
			<option value="478"<?php if($_SESSION['residence'] ==478) echo 'selected' ?>>Vassalboro</option>
			<option value="479"<?php if($_SESSION['residence'] ==479) echo 'selected' ?>>Veazie</option>
			<option value="480"<?php if($_SESSION['residence'] ==480) echo 'selected' ?>>Verona Island</option>
			<option value="481"<?php if($_SESSION['residence'] ==481) echo 'selected' ?>>Vienna</option>
			<option value="482"<?php if($_SESSION['residence'] ==482) echo 'selected' ?>>Vinalhaven</option>
			<option value="483"<?php if($_SESSION['residence'] ==483) echo 'selected' ?>>Wade</option>
			<option value="484"<?php if($_SESSION['residence'] ==484) echo 'selected' ?>>Waite</option>
			<option value="485"<?php if($_SESSION['residence'] ==485) echo 'selected' ?>>Waldo</option>
			<option value="486"<?php if($_SESSION['residence'] ==486) echo 'selected' ?>>Waldoboro</option>
			<option value="487"<?php if($_SESSION['residence'] ==487) echo 'selected' ?>>Wales</option>
			<option value="488"<?php if($_SESSION['residence'] ==488) echo 'selected' ?>>Wallagrass</option>
			<option value="489"<?php if($_SESSION['residence'] ==489) echo 'selected' ?>>Waltham</option>
			<option value="490"<?php if($_SESSION['residence'] ==490) echo 'selected' ?>>Warren</option>
			<option value="491"<?php if($_SESSION['residence'] ==491) echo 'selected' ?>>Washburn</option>
			<option value="492"<?php if($_SESSION['residence'] ==492) echo 'selected' ?>>Washington</option>
			<option value="493"<?php if($_SESSION['residence'] ==493) echo 'selected' ?>>Waterboro</option>
			<option value="494"<?php if($_SESSION['residence'] ==494) echo 'selected' ?>>Waterford</option>
			<option value="495"<?php if($_SESSION['residence'] ==495) echo 'selected' ?>>Waterville</option>
			<option value="496"<?php if($_SESSION['residence'] ==496) echo 'selected' ?>>Wayne</option>
			<option value="497"<?php if($_SESSION['residence'] ==497) echo 'selected' ?>>Webster plantation</option>
			<option value="498"<?php if($_SESSION['residence'] ==498) echo 'selected' ?>>Weld</option>
			<option value="499"<?php if($_SESSION['residence'] ==499) echo 'selected' ?>>Wellington</option>
			<option value="500"<?php if($_SESSION['residence'] ==500) echo 'selected' ?>>Wells</option>
			<option value="501"<?php if($_SESSION['residence'] ==501) echo 'selected' ?>>Wesley</option>
			<option value="502"<?php if($_SESSION['residence'] ==502) echo 'selected' ?>>West Bath</option>
			<option value="503"<?php if($_SESSION['residence'] ==503) echo 'selected' ?>>West Central Franklin UT</option>
			<option value="504"<?php if($_SESSION['residence'] ==504) echo 'selected' ?>>West Forks plantation</option>
			<option value="505"<?php if($_SESSION['residence'] ==505) echo 'selected' ?>>West Gardiner</option>
			<option value="506"<?php if($_SESSION['residence'] ==506) echo 'selected' ?>>West Paris</option>
			<option value="507"<?php if($_SESSION['residence'] ==507) echo 'selected' ?>>Westbrook</option>
			<option value="508"<?php if($_SESSION['residence'] ==508) echo 'selected' ?>>Westfield</option>
			<option value="509"<?php if($_SESSION['residence'] ==509) echo 'selected' ?>>Westmanland</option>
			<option value="510"<?php if($_SESSION['residence'] ==510) echo 'selected' ?>>Weston</option>
			<option value="511"<?php if($_SESSION['residence'] ==511) echo 'selected' ?>>Westport Island</option>
			<option value="512"<?php if($_SESSION['residence'] ==512) echo 'selected' ?>>Whitefield</option>
			<option value="513"<?php if($_SESSION['residence'] ==513) echo 'selected' ?>>Whiting</option>
			<option value="514"<?php if($_SESSION['residence'] ==514) echo 'selected' ?>>Whitney UT</option>
			<option value="515"<?php if($_SESSION['residence'] ==515) echo 'selected' ?>>Whitneyville</option>
			<option value="516"<?php if($_SESSION['residence'] ==516) echo 'selected' ?>>Willimantic</option>
			<option value="517"<?php if($_SESSION['residence'] ==517) echo 'selected' ?>>Wilton</option>
			<option value="518"<?php if($_SESSION['residence'] ==518) echo 'selected' ?>>Windham</option>
			<option value="519"<?php if($_SESSION['residence'] ==519) echo 'selected' ?>>Windsor</option>
			<option value="520"<?php if($_SESSION['residence'] ==520) echo 'selected' ?>>Winn</option>
			<option value="521"<?php if($_SESSION['residence'] ==521) echo 'selected' ?>>Winslow</option>
			<option value="522"<?php if($_SESSION['residence'] ==522) echo 'selected' ?>>Winter Harbor</option>
			<option value="523"<?php if($_SESSION['residence'] ==523) echo 'selected' ?>>Winterport</option>
			<option value="524"<?php if($_SESSION['residence'] ==524) echo 'selected' ?>>Winterville plantation</option>
			<option value="525"<?php if($_SESSION['residence'] ==525) echo 'selected' ?>>Winthrop</option>
			<option value="526"<?php if($_SESSION['residence'] ==526) echo 'selected' ?>>Wiscasset</option>
			<option value="527"<?php if($_SESSION['residence'] ==527) echo 'selected' ?>>Woodland</option>
			<option value="528"<?php if($_SESSION['residence'] ==528) echo 'selected' ?>>Woodstock</option>
			<option value="529"<?php if($_SESSION['residence'] ==529) echo 'selected' ?>>Woodville</option>
			<option value="530"<?php if($_SESSION['residence'] ==530) echo 'selected' ?>>Woolwich</option>
			<option value="531"<?php if($_SESSION['residence'] ==531) echo 'selected' ?>>Wyman UT</option>
			<option value="532"<?php if($_SESSION['residence'] ==532) echo 'selected' ?>>Yarmouth</option>
			<option value="533"<?php if($_SESSION['residence'] ==533) echo 'selected' ?>>York</option>
		<?php } else if ($_SESSION['state'] == 'PA' && $_SESSION['demo'] == 0) { ?>
			<option value="0"<?php if($_SESSION['residence'] ==0) echo 'selected' ?>>--Select Location--</option>
			<option value="15122"<?php if($_SESSION['residence'] ==15122) echo 'selected' ?>>Pittsburgh</option>
			<option value="15003"<?php if($_SESSION['residence'] ==15003) echo 'selected' ?>>Allegheny County (outside of Pittsburgh)</option>
		<?php } else {
			for($i = 1; $i<10; $i++):
			?>
			<option value="<?php echo $i; ?>"<?php if($_SESSION['residence'] == $i) echo 'selected' ?>>Location <?php echo $i; ?></option>
			<?php
			endfor;
			?>
		<?php } ?>
		
			<?php #foreach($simulator->residences2("NH",2021) as $s) { ?>
				<!--<option value="<?php #echo $s['id'] ?>" <?php #if($_SESSION["id"] == $s['id']) echo 'selected' ?>><?php # echo $s['name'] ?></option>
			<?php #} ?>-->
		</select>
		</td>
	  </tr>
	<?php } else {
		$_SESSION['residence'] = 1; #There is only one residence value in DC, 1, for DC.
	} ?>
	
	  <tr> 
		<td><label for="child_number_mtrc">How many people under age 18 are in your household? <?php //echo $notes_table->add_note('page2_family_structure') ?></label></td>
		<td> 
		  <select name="child_number_mtrc" id="child_number_mtrc">
			<option value="0" <?php if($_SESSION['child_number_mtrc'] == 0) echo 'selected' ?>>0</option>
			<option value="1" <?php if($_SESSION['child_number_mtrc'] == 1) echo 'selected' ?>>1</option>
			<option value="2" <?php if($_SESSION['child_number_mtrc'] == 2) echo 'selected' ?>>2</option>
			<option value="3" <?php if($_SESSION['child_number_mtrc'] == 3) echo 'selected' ?>>3</option>
			<option value="4" <?php if($_SESSION['child_number_mtrc'] == 4) echo 'selected' ?>>4</option>
			<option value="5" <?php if($_SESSION['child_number_mtrc'] == 5) echo 'selected' ?>>5</option>
		  </select>
		</td>
	  </tr>
	  <tr> 
		<td><label for="family_structure">How many people age 18 and up are in your household?  <?php //echo $notes_table->add_note('page2_family_structure') ?></label></td>
		<td> 
		  <select name="family_structure" id="family_structure" class="Validate_parent2_age">
			<option value="1" <?php if($_SESSION['family_structure'] == 1) echo 'selected' ?>>1</option>
			<option value="2" <?php if($_SESSION['family_structure'] == 2) echo 'selected' ?>>2</option>
			<option value="3" <?php if($_SESSION['family_structure'] == 3) echo 'selected' ?>>3</option>
			<option value="4" <?php if($_SESSION['family_structure'] == 4) echo 'selected' ?>>4</option>
		  </select>
		</td>
	  </tr>
		<td><label for="adult_student_flag">Is any person age 18 and up a full-time or part-time student? </label></td>
		<td> 
		  <select name="adult_student_flag" id="adult_student_flag">
			<option value="0" <?php if($_SESSION['adult_student_flag'] == 0) echo 'selected' ?>>No</option>
			<option value="1" <?php if($_SESSION['adult_student_flag'] == 1) echo 'selected' ?>>Yes</option>
		  </select>
		</td>
	  </tr>
</table>
<?php 
#090920 note: Hard-coding child ages to -1 for now, to establish defaults on this page indicating "No second child," "No third child," "No fourth child," and "No fifth child."
# NEED TO DELETE LATER, OR DISCUSS DEFAULTS IN MORE DETAIL. COMMENTING OUT FOR NOW AS OF 12/1 TO KEEP AGES INTACT.
#$_SESSION['child1_age'] = -1;
#$_SESSION['child2_age'] = -1;
#$_SESSION['child3_age'] = -1;
#$_SESSION['child4_age'] = -1;
#$_SESSION['child5_age'] = -1;
?>
<?php $_SESSION['user_prototype'] = 1; #We are setting this temporary variable during the prototype stage. There are several ways that this is helpful as we set up the prototype tool before entering state-specific values or variables, such as what programs are offered where (e.g. pre-K in Step 3) and default values of child care entered in our database. ?>

<!--<br class="clearing" /><br/>-->
<input type="hidden" name="mode" value="step" />
<?php if ($_SESSION['demo'] == 1) {

	#<input type="hidden" name="year" value="2021" /> <!--Change to 2021 for NH and other staets-->
	#<input type="hidden" name="state" value="NH" /> <!-- NOTE HARDCODE 082720: coding all as KY for now, but removing references to the state in the title page and subsequent pages. Will need to remove or replace this hardcode later on.--> 
	#<!--<input type="hidden" name="residence" value="56" /> <!-- NOTE HARDCODE 082720: coding all as residence=56, or Jefferson County (Louisvill) for now, but  removing references to the city in the title page and subsequent pages. Will need to remove or replace this hardcode later on.--> 
	#<input type="hidden" name="simulator" value="NH" />
	#<input type="hidden" name="state_name" value="" />
} ?>	
