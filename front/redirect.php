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
if (execute_scalar("select count(*) from user_record where user_id = $user_id") > $book_shelf_size) {
	mysql_query("delete from user_record where user_id = $user_id and book_id not in (select * from (select book_id from user_record where user_id = $user_id order by update_time desc limit $book_shelf_size) as t)");
}
header("Location: $url", 301);

?>
