<?php
require_once('lib.php');
require_once('data.php');
$chapter_id = $_GET['id'];
$chapter_id = (int)$chapter_id;
list($url, $source_id, $book_id) = execute_vector("select url, source_id, book_id from chapter where id = $chapter_id");
if (isset($baidu_transcode[$source_id])) {
	$url = "http://$url";
}
else {
	$url = "http://gate.baidu.com/tc?from=opentc&src=$url";
}
$user_info = get_user_info();
if (!isset($user_info['id'])) {
	$user_info['id'] = gen_user_id();
	setcookie('user_id', $user_info['id'], time() + 3600 * 365 * 10, '/');
}
$user_id = $user_info['id'];
mysql_query("replace into user_record(user_id, book_id, source_id, chapter_id) values($user_id, $book_id, '$source_id', $chapter_id)");
header("Location: $url", 301);
?>
