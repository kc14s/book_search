<?php
require_once('lib.php');
require_once('data.php');
init();
$chapter_id = $_GET['id'];
$chapter_id = (int)$chapter_id;
$db_conn = conn_db();
list($url, $source_id) = execute_vector("select url, source_id from chapter where id = $chapter_id");
if (isset($baidu_transcode[$source_id])) {
	$url = "http://$url";
}
else {
	$url = "http://gate.baidu.com/tc?from=opentc&src=$url";
}
header("Location: $url", 301);
?>
