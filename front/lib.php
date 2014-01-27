<?php
require_once('config.php');
require_once('data.php');

function init() {
	check_parameters();
	conn_db();
}

function conn_db() {
	global $db_server, $db_user, $db_password, $db_name;
	$db_conn = mysql_connect($db_server, $db_user, $db_password);
	mysql_select_db($db_name, $db_conn);
	mysql_query("set names utf8");
	return $db_conn;
}

function check_parameters() {
	$illegal = '[\'"=]';
	foreach ($_GET as $k => $v) {
		if (preg_match($illegal, $v)) {
			header('Location: illegal_parameter.php', 301);
		}
	}
	foreach ($_POST as $k => $v) {
		if (preg_match($illegal, $v)) {
			header('Location: illegal_parameter.php', 301);
		}
	}
}

function execute_scalar($sql) {
	$result = mysql_query($sql);
	while($row = mysql_fetch_array($result)) {
		return $row[0];
	}
}

function execute_vector($sql) {
	$result = mysql_query($sql);
	while($row = mysql_fetch_array($result)) {
		return $row;
	}
	return array();
}

function format_intro($intro) {
	if (strpos($intro, '<') === false && strpos($intro, '&') === false) {
		$intro = str_replace("\n", '<br>', $intro);
		$intro = str_replace('  ', ' &nbsp;', $intro);
	}
	return $intro;
}

function html_to_text($html) {
	$html = str_replace('&nbsp;', '', $html);
	$html = preg_replace('/<.+?>/', '', $html);
	$html = preg_replace('/&.+?;/', '', $html);
	return trim($html);
}

function get_category_nav() {
	$category_ids = array(13, 23, 8, 19, 21, 20, 10, 15);
	$ret = '';
	global $categories;
	for ($i = 0; $i < count($category_ids); ++$i) {
		if ($i != 0) $ret .= ' &nbsp; ';
		$ret .= '<a href="leaderboard.php?category='.$category_ids[$i].'&page=1" target="_blank">'.$categories[$category_ids[$i]].'</a>';
	}
	return $ret;
}

function get_user_info() {
	$user_id = $_COOKIE['user_id'];
	if (!$user_id) return array();
	$user_info = execute_vector("select id, nick, figure_url from user where id = $user_id");
	return $user_info;
}

function get_login_html() {
	$user_info = get_user_info();
	if (!$user_info['id']) {
		return '<a href="#" onclick="window.open(\'qq_connect/login.php\', \''.time().'\',\'width=450,height=320,menubar=0,scrollbars=1, resizable=1,status=1,titlebar=0,toolbar=0,location=1\');"><img src="image/qq_login.png"></a>';
	}
	else {
		return '<img src="'.$user_info['figure_url'].'">'.$user_info['nick'].'，您好';
	}
}

init();

?>
