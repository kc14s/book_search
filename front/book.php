<?php
require_once('lib.php');
require_once('data.php');
init();
$html = '';
$book_id = $_GET['id'];
$book_id = (int)$book_id;
$db_conn = conn_db();
list($book_title, $author, $category, $intro, $status, $tieba_follower) = execute_vector("select title, author, category, intro, status, tieba_follower from book where id = $book_id", $db_conn);
$category = $categories[$category];
$status = $statuses[$status];
$_POST['title'] = $book_title;
$html = "<div class=\"page-header\" align=\"center\"><h1>$book_title <small>作者：$author</small></h1></div>";
$html .= "<div class=\"well\" align=\"center\"><strong>类型</strong>：$category &nbsp; <strong>推荐</strong>：$tieba_follower &nbsp; <strong>状态</strong>：$status";
$html .= '<div class="row"><div class="col-md-8 col-md-offset-2" align="left">'.format_intro($intro).'</div></div>';
$html .= "</div>";
$result = mysql_query("select id, title from chapter where book_id = $book_id order by id");
$col = 0;
$html .= '<table class="table table-striped">';
while($row = mysql_fetch_array($result)) {
	$chapter_id = $row['id'];
	$chapter_title = $row['title'];
	if ($col % 3 == 0) {
		$html .= '<tr>';
	}
	$html .= '<td>';
	$link_id = 0;
	$query = mysql_query("select source_id, url from link where chapter_id = $chapter_id");
	while ($record = mysql_fetch_array($query)) {
		$source_id = $record['source_id'];
		$url = $record['url'];
		if (isset($baidu_transcode[$source_id])) {}
		else {
			$url = "http://gate.baidu.com/tc?from=opentc&src=$url";
		}
		if ($link_id == 0) {
			$html .= "<a href=\"$url\" target=\"_blank\">$chapter_title</a> &nbsp; &nbsp;";
		}
		else {
			$html .= " <small><a href=\"$url\" target=\"_blank\">镜像$link_id</a></small>";
		}
		++$link_id;
	}
	$html .= '</td>';
	if ($col % 3 == 2) {
		$html .= '</tr>';
	}
	$col = ++$col % 3;
}
$html .= '</table>';
$html_title = $book_title.' '.$chapter_title;
require_once('header.php');
require_once('query_banner.php');
echo $html;
require_once('footer.php');
?>
