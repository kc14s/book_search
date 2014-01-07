<?php
require_once('lib.php');
init();
$html = '';
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
	$title = $_POST['title'];
	if (strlen($title) < 6) {
		$html = '<div class="alert alert-danger" align="center">抱歉，请至少输入2个汉字或6个字母。</div>';
	}
	else {
		$db_conn = conn_db();
		$result = mysql_query("select id, title, author from book where title like '%".addslashes($title)."%' order by length(title)", $db_conn);
		$num_rows = mysql_num_rows($result);
		if ($num_rows === 0) {
			$html = '<div class="alert alert-warning" align="center">抱歉，没有找到结果。</div>';
		}
		else {
			$html = '<div class="alert alert-success" align="center">共搜索到'.$num_rows.'条结果。</div><div class="list-group">';
			$exact_match_count = 0;
			while($row = mysql_fetch_array($result)) {
				$book_id = $row['id'];
				$book_title = $row['title'];
				$author = $row['author'];
				if ($book_title == $title) {
					++$exact_match_count;
					$exact_match_book_id = $book_id;
				}
				$html .= '<a href="book.php?id='.$book_id.'" class="list-group-item">'.$book_title.' &nbsp; &nbsp; <small>作者：'.$author.' 最新章节：'.execute_scalar("select title from chapter where book_id = $book_id and id = (select max(id) from chapter where book_id = $book_id)").'</small></a>';
			}
			$html .= '</div>';
			if ($exact_match_count == 1) {
				header("Location: book.php?id=$exact_match_book_id", 302);
			}
		}
	}
}
require_once('header.php');
require_once('query_banner.php');
echo $html;
require_once('footer.php');
?>
