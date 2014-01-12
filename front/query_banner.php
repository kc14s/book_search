<form class="well form-inline" role="form" align="center" action="query.php" method="post" target="_self">
<div class="row"><div class="col-md-1"><h4><?php echo $site_name;?></h4></div>
<div class="col-md-11"><div class="form-group">
<input type="text" class="form-control" id="book_title" name="title" placeholder="凡人修仙传" size="60" value="<?php if (isset($_POST['title'])) echo $_POST['title']?>">
</div>
<button type="submit" class="btn btn-default">搜索</button>
</div></div>
</form>
