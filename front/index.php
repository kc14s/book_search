<?php
require_once('lib.php');
require_once('header.php');
?>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>
<form class="well form-inline" role="form" align="center" action="query.php" method="post" target="_self">
<h1 align="center"><?php echo $site_name;?></h1>
<p>&nbsp; </p>
<div class="row"><div class="col-md-8 col-md-offset-3"><?php echo get_category_nav();?><br>
<div class="form-group">
<input type="text" class="form-control" id="book_title" name="title" placeholder="凡人修仙传" size="75">
</div>
<button type="submit" class="btn btn-default">搜索</button>
</div>
</form>
<?php
require_once('footer.php');
?>
