<ul>
	<li>
	  <?php if($_SESSION['family_structure'] == 1) { ?>Single-adult family
		<li> Adult is <?php echo $_SESSION['parent1_age'] ?> years old </li>
	  
	  <?php } else { echo $_SESSION['family_structure']?>-adult family 
		<?php for($i=1; $i<=$_SESSION['family_structure']; $i++) { ?>
	  		<li> Adult <?php echo $i ?>: age <?php echo $_SESSION['parent'.$i.'_age'] ?> </li>	
		<?php } ?>
	  <?php } ?>
	  
	</li>
	
	<li>
	  <?php if($_SESSION['child_number'] == 0) { ?>No children	  
	  <?php } else { ?>
		  <?php if($_SESSION['child_number'] == 1) { ?>One child:	  
		  <?php } else { ?>
		  <?php echo $_SESSION['child_number'] ?> children: 
		  <?php } ?>
		  <?php  echo ' Child 1 (age ' .$_SESSION['child1_age']. ')' ?><?php if($_SESSION['child2_age'] != -1) { echo ', Child 2 (age '.$_SESSION['child2_age'].')'; } ?><?php if($_SESSION['child3_age'] != -1) { echo ', Child 3 (age '.$_SESSION['child3_age']. ')'; } ?> <?php if($_SESSION['child4_age'] != -1 && $_SESSION['year'] >= 2017) { echo ', Child 4 (age '.$_SESSION['child4_age']. ')'; } ?> <?php if($_SESSION['child5_age'] != -1 && $_SESSION['year'] >= 2017) { echo ', Child 5 (age '.$_SESSION['child5_age']. ')'; } ?> 
	  <?php } ?>
	</li>

<?php if ($_SESSION['year'] >= 2017) { ?>	
	<li>
	<?php if($_SESSION['disability_parent1'] + $_SESSION['disability_parent2'] + $_SESSION['disability_parent3'] + $_SESSION['disability_parent4'] == 1) { ?>
		One adult has a disability
	
	<?php } elseif($_SESSION['disability_parent1'] + $_SESSION['disability_parent2'] + $_SESSION['disability_parent3'] + $_SESSION['disability_parent4'] == 2) { ?>
		Two adults have a disability
		
	<?php } elseif($_SESSION['disability_parent1'] + $_SESSION['disability_parent2'] + $_SESSION['disability_parent3'] + $_SESSION['disability_parent4'] == 3) { ?>
		Three adults have a disability
		
	<?php } elseif($_SESSION['disability_parent1'] + $_SESSION['disability_parent2'] + $_SESSION['disability_parent3'] + $_SESSION['disability_parent4'] == 4) { ?>
		Four adults have a disability
		
	 <?php } else { ?>
		No disability selected
		
	 <?php } ?>
	</li>
	 
<?php } ?>
	
</ul>