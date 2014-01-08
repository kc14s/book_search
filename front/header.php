<?php header("Content-type: text/html; charset=utf-8");?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<title>
<?php
if (isset($html_title)) {
	echo "$html_title ";
}
echo $site_name;
?>
</title>
<link rel="stylesheet" href="http://cdn.bootcss.com/twitter-bootstrap/3.0.3/css/bootstrap.min.css">
</head>
<body>
<div class="row"><div class="col-md-8 col-md-offset-2 col-xs-8 col-xs-offset-2">
