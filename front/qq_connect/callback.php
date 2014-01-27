<?php
ob_start();
require_once('qqConnectAPI.php');
require_once('../lib.php');
init();
$qc = new QC();
if ($qc->qq_callback()) {
	$open_id = $qc->get_openid();
	$user_info = $qc->get_user_info();
	list($nick, $figure_url) = array($user_info['nickname'], $user_info['figureurl_qq_1']);
	$user_id = execute_scalar("select id from user where open_id = '$open_id'");
	if ($user_id) {
		mysql_query("update user set nick = '$nick', figure_url = '$figure_url' where id = $user_id");
	}
	else {
		$user_id = $_COOKIE['user_id'];
		if ($user_id) {
			mysql_query("update user set open_id = '$open_id', nick = '$nick', figure_url = '$figure_url' where id = $user_id");
		}
		else {
			mysql_query('set names utf8;');
			mysql_query("insert into user(open_id, nick, figure_url) values('$open_id', '$nick', '$figure_url')");
			$user_id = execute_scalar("select last_insert_id()");
		}
	}
	setcookie('user_id', $user_id, time() + 3600 * 365 * 10, '/');
	echo '<html><script>window.opener.location.reload(); window.close();</script></html>';
}
else {
}
ob_end_flush();
?>
