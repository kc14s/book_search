<?php
require_once('lib.php');
init();
$category_id = $_GET['category'];
$category_id = (int)$category_id;
$page = $_GET['page'];
$page = (int)$page;
$html = '';
$db_conn = conn_db();
$book_num = execute_scalar("select count(*) from book where category = $category_id");
$result = mysql_query("select id, title, author, tieba_follower, intro from book where category = $category_id order by tieba_follower desc limit ".(($page - 1) * $page_size).", $page_size", $db_conn);
$num_rows = mysql_num_rows($result);
$html = '<div class="panel panel-info"><div class="panel-heading"><h3 class="panel-title">'.$categories[$category_id].' &nbsp; 共'.$book_num.'部作品</h3></div>';
$html .= '<div class="panel-body">';
$html .= '<table class="table table-striped"><tr><th>名次</th><th>标题</th><th>作者</th><th>推荐</th><th>简介</th></tr>';
$rank = ($page - 1) * $page_size + 1;
while($row = mysql_fetch_array($result)) {
	$book_id = $row['id'];
	$book_title = $row['title'];
	$author = $row['author'];
	$tieba_follower = $row['tieba_follower'];
	$intro = $row['intro'];
	$intro = html_to_text($intro);
	for ($pos = 1; $pos <= 100; ++$pos) {
		$char = mb_substr($intro, $pos, 1, 'utf-8');
		if ($char === '') {
			break;
		}
		if ($char == '。' || $char == '！') {
			if ($pos > 10) {
				$intro = mb_substr($intro, 0, $pos + 1, 'utf-8');
				break;
			}
		}
	}
	if (strlen($intro) > 50) {
		$intro = mb_substr($intro, 0, 30, 'utf-8');
	}
	$html .= "<tr><td>$rank</td><td><a href=\"book.php?id=$book_id\">$book_title</a></td><td>$author</td><td>$tieba_follower</td><td>$intro</td></tr>";
	++$rank;
}
$html .= '</table></div></div>';
$html .= '<ul class="pagination">';
if ($page <= 1) {
	$html .= '<li class="disabled"><a href="#">&laquo;</a></li>';
}
else {
	$html .= '<li><a href="leaderboard.php?category='.$category_id.'&page='.($page - 1).'">&laquo;</a></li>';
}
$total_page = $book_num / $page_size;
$start_page = $page >= 3 ? $page - 2 : 1;
$end_page = $total_page - $page > 2 ? $page + 2 : $total_page;
for ($p = $start_page; $p <= $end_page; ++$p) {
	if ($p == $page) {
		$html .= '<li class="disabled"><a href="#">'.$p.'</a></li>';
	}
	else {
		$html .= '<li><a href="leaderboard.php?category='.$category_id.'&page='.$p.'">'.$p.'</a></li>';
	}
}
if ($num_rows < $page_size) {
	$html .= '<li class="disabled"><a href="#">&raquo;</a></li>';
}
else {
	$html .= '<li><a href="leaderboard.php?category='.$category_id.'&page='.($page + 1).'">&raquo;</a></li>';
}
$html .= '</ul>';
require_once('header.php');
require_once('query_banner.php');
echo $html;
require_once('footer.php');
?>
