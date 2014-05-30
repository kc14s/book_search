<?php
require_once('lib.php');
require_once('header.php');
?>
<nav class="navbar navbar-default" role="navigation">
<div class="navbar-header">
<ul class="nav navbar-nav navbar-left">
<li><a href="/" target="_self">追书宝</a></li>
</ul>
</div>
<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
<ul class="nav navbar-nav navbar-right">
<li><?php echo get_login_html();?></li>
</ul>
</div>
</nav>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>
<form class="form-inline" role="form" align="center" action="query.php" method="post" target="_self">
<h1 align="center"><?php echo $site_name;?></h1>
<p>&nbsp; </p>
<div class="row"><div class="col-md-8 col-md-offset-2"><?php echo get_category_nav();?><br />
<div class="form-group">
<input type="text" class="form-control" id="book_title" name="title" placeholder="凡人修仙传" size="75" />
</div>
<button type="submit" class="btn btn-default">搜索</button>
</div></div>
</form>
<div class="row"><div class="col-md-6 col-md-offset-3">
<?php
$user_info = get_user_info();
if (count($user_info) > 0) {
	$user_id = $user_info['id'];
	$result = mysql_query("select book.id, book.title, chapter.title, chapter.source_id from book, chapter, user_record where user_id = $user_id and book.id = chapter.book_id and chapter_id = chapter.id order by update_time desc");
	$record_num = mysql_num_rows($result);
	if ($record_num > 0) {
		echo '<p>&nbsp;</p><p>&nbsp;</p><table class="table "><tr class="success"><th>我的书架</th></tr>';
		while (list($book_id, $book_title, $chapter_title, $source_id) = mysql_fetch_array($result)) {
			echo "<tr><td><a href=\"book/$book_id/$source_id\">《${book_title}》 &nbsp; $chapter_title</a></td></tr>";
		}
		echo '</table>';
	}
}
?>
</div></div>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>
<p>&nbsp; </p>
<?php
require_once('footer.php');
?>
