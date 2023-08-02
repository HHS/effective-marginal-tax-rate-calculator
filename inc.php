<table border="0" cellspacing="0" cellpadding="4">
  <tr> 
    <td><label for="family_structure">Family structure<?php echo $notes_table->add_note('page2_family_structure') ?></label></td>
    <td> 
      <select name="family_structure" id="family_structure">
        <option value="1" <?php if($_SESSION['family_structure'] == 1) echo 'selected' ?>>Single-parent</option>
        <option value="2" <?php if($_SESSION['family_structure'] == 2) echo 'selected' ?>>Two-parent</option>
      </select>
    </td>
  </tr>
  <tr> 
    <td><label for="child1_age">Age of first child</label><?php echo $notes_table->add_note('page2_child_age'); echo $help_table->add_help('page2_child_age'); ?></td>
    <td> 
      <select name="child1_age" id="child1_age">
			<?php for($i=0; $i<18; $i++) {
				printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child1_age'] == $i ? 'selected' : ''), $i);
			} ?>
      </select>
    </td>
  </tr>
  <tr> 
    <td><label for="child2_age">Age of second child</label></td>
    <td> 
      <select name="child2_age" id="child2_age">
      	<option value="-1">No second child</option>
			<?php for($i=0; $i<18; $i++) {
				printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child2_age'] == $i ? 'selected' : ''), $i);
			} ?>
      </select>
    </td>
  </tr>

  <tr> 
    <td><label for="child3_age">Age of third child</label></td>
    <td> 
      <select name="child3_age" id="child3_age">
      	<option value="-1">No third child</option>
			<?php for($i=0; $i<18; $i++) {
				printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child3_age'] == $i ? 'selected' : ''), $i);
			} ?>
		</select>
    </td>
  </tr>
 <?php if($_SESSION['state'] == 'DISTRCIT OF COLUMBIA' && $_SESSION['year'] == 2017) { ?>
    <tr> 
    <td><label for=" child4_age">Age of fourth child</label></td>
    <td> 
      <select name="child4_age" id="child4_age">
	    	<option value="-1">No fourth child</option>
			<?php for($i=0; $i<18; $i++) {
				printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child4_age'] == $i ? 'selected' : ''), $i);
			} ?>
      </select>
    </td>
  </tr>   
  <tr> 
    <td><label for=" child5_age">Age of fifth child</label></td>
    <td> 
      <select name="child5_age" id="child5_age">
	    	<option value="-1">No fifth child</option>
			<?php for($i=0; $i<18; $i++) {
				printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['child5_age'] == $i ? 'selected' : ''), $i);
			} ?>
      </select>
    </td>
  </tr>
    <tr> 
    <td><label for=" parent1_age">Age of first parent</label></td>
    <td> 
      <select name="parent1_age" id="parent1_age">
			<?php for($i=25; $i<61; $i++) {
				printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['parent1_age'] == $i ? 'selected' : ''), $i);
			} ?>
      </select>
    </td>
  </tr>
  <tr> 
    <td><label for=" parent2_age">Age of second parent</label></td>
    <td> 
      <select name="parent2_age" id="parent2_age">
			<?php for($i=25; $i<61; $i++) {
				printf('<option value="%s" %s>%s</option>', $i, ($_SESSION['parent2_age'] == $i ? 'selected' : ''), $i);
			} ?>
      </select>
    </td>
  </tr>
  
  <input type="checkbox" id="breastfeeding" name="breastfeeding" <?php if($_SESSION['breastfeeding']) echo 'checked' ?>>&nbsp;<label for="breastfeeding" >Does mother breast-feed any infant children?</label><br />
	<td> 
      <select name="disability_parent1" id="disability_parent1">
        <option value="0" <?php if($_SESSION['disability_parent1'] == 1) echo 'selected' ?>>No</option>
        <option value="1" <?php if($_SESSION['disability_parent1'] == 2) echo 'selected' ?>>Yes</option>
      </select>
    </td>
  <td> 
      <select name="disability_parent2" id="disability_parent2">
        <option value="0" <?php if($_SESSION['disability_parent2'] == 1) echo 'selected' ?>>No</option>
        <option value="1" <?php if($_SESSION['disability_parent2'] == 2) echo 'selected' ?>>Yes</option>
      </select>
    </td>
  <script type="text/javascript">
	addLoadEvent(function() { 
		$('disability_parent2').onchange = function()  {
			if($('disability_parent2').option value="1" && ($('family_structure').option value="2")) {
				$('disability_parent2').option value ="0";
				alert('You can only include a disability of second parent in a two-parent family structure.');
			}
			return false;
		}
		}
	)
	</script>
 <?php } ?>
</table>
