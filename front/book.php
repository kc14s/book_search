<?php
require_once('lib.php');
require_once('data.php');
$html = '';
$book_id = $_GET['id'];
$book_id = (int)$book_id;
list($book_title, $author, $category, $intro, $status, $tieba_follower) = execute_vector("select title, author, category, intro, status, tieba_follower from book where id = $book_id");
$category = $categories[$category];
$status = $statuses[$status];
$_POST['title'] = $book_title;
$result = mysql_query("select source_id, count(*) as c from chapter where book_id = $book_id group by source_id order by c desc");
$sources = array();
while (list($s_id, $count) = mysql_fetch_array($result)) {
	$sources[] = $s_id;
}
$html = "<div class=\"page-header\" align=\"center\"><h1>$book_title <small>作者：$author</small></h1></div>";
$html .= '<div><ul class="nav nav-pills"><li class="dropdown"><a id="dLabel" role="button" data-toggle="dropdown" data-target="#" href="/page.html">来源<span class="caret"></span></a><ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">';
foreach ($sources as $source) {
	$html .= '<li role="presentation"><a role="menuitem" tabindex="-1" href="book.php?id='.$book_id.'&source='.$source.'" target="_self">'.$g_sources[$source].'</a></li>';
}
$html .= '</ul></li></ul></div>';
$html .= "<div class=\"well\" align=\"center\"><strong>类型</strong>：$category &nbsp; <strong>推荐</strong>：$tieba_follower &nbsp; <strong>状态</strong>：$status &nbsp; ";
$html .= '<div class="row"><div class="col-md-8 col-md-offset-2" align="left">'.format_intro($intro).'</div></div>';
$html .= "</div>";
$current_source = isset($_GET['source']) ? $_GET['source'] : $sources[0];
$result = mysql_query("select id, title, source_id from chapter where book_id = $book_id and source_id = '$current_source' order by id");
$chapters = array();
while(list($chapter_id, $chapter_title, $source_id) = mysql_fetch_array($result)) {
	$chapters[] = array($chapter_id, $chapter_title, $source_id);
}
$col = 0;
$html .= '<div class="panel panel-primary"><div class="panel-heading"><h3 class="panel-title">最新章节</h3></div>';
$html .= '<table class="table table-striped">';
for ($i = count($chapters) - 1; $i >= 0 && $i >= count($chapters) - 6; --$i) {
	list($chapter_id, $chapter_title, $source_id) = $chapters[$i];
	if ($col % 3 == 0) {
		$html .= '<tr>';
	}
	$html .= '<td>';
	$html .= "<a href=\"redirect.php?id=$chapter_id\" ref=\"nofollow\">$chapter_title</a> &nbsp; &nbsp;";
	$html .= '</td>';
	if ($col % 3 == 2) {
		$html .= '</tr>';
	}
	$col = ++$col % 3;
}
$html .= '</table>';
$html .= '</div>';
$col = 0;
$html .= '<div class="panel panel-primary"><div class="panel-heading"><h3 class="panel-title">全文阅读</h3></div>';
$html .= '<table class="table table-striped">';
for ($i = 0; $i < count($chapters); ++$i) {
	list($chapter_id, $chapter_title, $source_id) = $chapters[$i];
	if ($col % 3 == 0) {
		$html .= '<tr>';
	}
	$html .= '<td>';
//	$html .= "<a href=\"$url\" target=\"_blank\">$chapter_title</a> &nbsp; &nbsp;";
	$html .= "<a href=\"redirect.php?id=$chapter_id\" ref=\"nofollow\">$chapter_title</a> &nbsp; &nbsp;";
	$html .= '</td>';
	if ($col % 3 == 2) {
		$html .= '</tr>';
	}
	$col = ++$col % 3;
}
$html .= '</table>';
$html .= '</div></div>';
$html_title = $book_title.' '.$chapter_title;
require_once('header.php');
require_once('query_banner.php');
echo $html;
require_once('footer.php');
?>
