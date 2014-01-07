<?php
require_once('config.php');

function init() {
	check_parameters();
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
}
?>
