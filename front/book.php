<?php
require_once('lib.php');
require_once('data.php');
$html = '';
$book_id = $_GET['id'];
$book_id = (int)$book_id;
$is_spider = is_spider();
list($book_title, $author, $category, $intro, $status, $tieba_follower) = execute_vector("select title, author, category, intro, status, tieba_follower from book where id = $book_id");
$category = $categories[$category];
$status = $statuses[$status];
list($tieba_follower, $sogou_click) = execute_vector("select tieba_fans, sogou_click from quality where title = '$book_title'");
$tieba_follower = isset($tieba_follower) ? $tieba_follower : 0;
$sogou_click = isset($sogou_click) ? $sogou_click : 0;
$_POST['title'] = $book_title;
$result = mysql_query("select source_id, count(*) as c from chapter where book_id = $book_id group by source_id order by c desc");
$sources = array();
while (list($s_id, $count) = mysql_fetch_array($result)) {
	$sources[] = $s_id;
}

$recommended_books = array();
/*
$result = mysql_query("select id, category, title from book where id > ".rand(1, 366952)." order by id limit 10");
while (list($recommended_book_id, $recommended_category, $recommended_title) = mysql_fetch_array($result)) {
	$recommended_books[] = array($recommended_book_id, $recommended_category, $recommended_title);
}
*/
$html = "<div class=\"page-header\" align=\"center\"><h1>$book_title <small>作者：$author</small></h1></div>";
if (!$is_spider) {
	$html .= '<div><ul class="nav nav-pills"><li class="dropdown"><a id="dLabel" role="button" data-toggle="dropdown" data-target="#" href="/page.html">来源<span class="caret"></span></a><ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">';
	foreach ($sources as $source) {
		$html .= '<li role="presentation"><a role="menuitem" rel="nofollow" tabindex="-1" href="/book/'.$book_id.'/'.$source.'" target="_self">'.$g_sources[$source].'</a></li>';
	}
	$html .= '</ul></li></ul></div>';
}
$html .= "<div class=\"well\" align=\"center\"><strong>类型</strong>：$category &nbsp; <strong>推荐</strong>：$tieba_follower &nbsp; <strong>粉丝</strong>：$sogou_click &nbsp; <strong>状态</strong>：$status &nbsp; ";
$html .= '<div class="row"><div class="col-md-8 col-md-offset-2" align="left">'.format_intro($intro).'</div></div>';
$html .= "</div>";
$current_source = $_GET['source'];
$user_info = get_user_info();
if (count($user_info) > 0) {
	$user_id = $user_info['id'];
	$source_condition = isset($_GET['source']) ? 'and chapter.source_id = "'.$_GET['source'].'"' : '';
	list($user_source_id, $user_chapter_id) = execute_vector("select chapter.source_id, chapter.id from book, chapter, user_record where user_id = $user_id and book.id = chapter.book_id and chapter_id = chapter.id and book.id = $book_id $source_condition");
	if (isset($user_source_id)) {
		$current_source = $user_source_id;
	}
}
if (!isset($current_source)) {
	$current_source = $sources[0];
}
$result = mysql_query("select id, title, source_id from chapter where book_id = $book_id and source_id = '$current_source' order by id");
$chapters = array();
while(list($chapter_id, $chapter_title, $source_id) = mysql_fetch_array($result)) {
	$chapters[] = array($chapter_id, $chapter_title, $source_id);
}
if (isset($user_chapter_id)) {
	$col = 0;
	$html .= '<div class="panel panel-primary"><div class="panel-heading"><h3 class="panel-title">继续阅读</h3></div>';
	$html .= '<table class="table table-striped">';
	$flag = 0;
	for ($i = 0; $i < count($chapters); ++$i) {
		list($chapter_id, $chapter_title, $source_id) = $chapters[$i];
		if ($chapter_id == $user_chapter_id || ($flag > 0 && $flag < 9)) {
			++$flag;
		}
		else {
			continue;
		}
		if ($col % 3 == 0) {
			$html .= '<tr>';
		}
		$html .= '<td>';
		if ($is_spider) {
			$html .= "$chapter_title &nbsp; &nbsp;";
		}
		else {
			$html .= "<a href=\"/redirect/$chapter_id\" ref=\"nofollow\">$chapter_title</a> &nbsp; &nbsp;";
		}
		$html .= '</td>';
		if ($col % 3 == 2) {
			$html .= '</tr>';
		}
		$col = ++$col % 3;
	}
	$html .= '</table>';
	$html .= '</div>';
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
	if ($is_spider) {
		$html .= "$chapter_title &nbsp; &nbsp;";
	}
	else {
		$html .= "<a href=\"/redirect/$chapter_id\" ref=\"nofollow\">$chapter_title</a> &nbsp; &nbsp;";
	}
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
	if ($is_spider) {
		$html .= "$chapter_title &nbsp; &nbsp;";
	}
	else {
		$html .= "<a href=\"/redirect/$chapter_id\" ref=\"nofollow\">$chapter_title</a> &nbsp; &nbsp;";
	}
	$html .= '</td>';
	if ($col % 3 == 2) {
		$html .= '</tr>';
	}
	$col = ++$col % 3;
}
$html .= '</table>';
$html .= '</div>';

if (false || $is_spider) {
	$html .= get_rand_tianya_topic_html();
}
if (count($recommended_books) > 0) {
	$html .= '<div class="panel panel-primary"><div class="panel-heading"><h3 class="panel-title">推荐阅读</h3></div>';
	$html .= '<div class="list-group">';
	foreach ($recommended_books as $book) {
		list($book_id, $category, $title) = $book;
		$category = $categories[$category];
		$html .= "<a href=\"/book/$book_id\" class=\"list-group-item\">$title</a>";
	}
	$html .= '</div></div>';
}
$html .= $baidu_960_90;
$html_title = $book_title.'最新章节全文免费阅读 '.$chapter_title;
require_once('header.php');
require_once('query_banner.php');
echo $html;
require_once('footer.php');
?>
