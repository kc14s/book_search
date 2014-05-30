<form class="well form-inline" role="form" align="center" action="query.php" method="post" target="_self">
<div class="row"><div class="col-md-2"><h4><a href="/" target="_self"><?php echo $site_name;?></a></h4></div>
<div class="col-md-7"><div class="form-group">
<input type="text" class="form-control" id="book_title" name="title" placeholder="凡人修仙传" size="60" value="<?php if (isset($_POST['title'])) echo $_POST['title']?>">
</div>
<button type="submit" class="btn btn-default">搜索</button>
</div>
<div class="col-md-3"><?php echo get_login_html();?></div>
</div>
</form>
