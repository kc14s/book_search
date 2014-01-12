<?php header("Content-type: text/html; charset=utf-8");?>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
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
<script src="http://cdn.bootcss.com/jquery/1.10.2/jquery.min.js"></script>
<script src="http://cdn.bootcss.com/twitter-bootstrap/3.0.3/js/bootstrap.min.js"></script>
<base target="_blank">
</head>
<body>
<div class="row"><div class="col-md-8 col-md-offset-2 col-xs-12">
