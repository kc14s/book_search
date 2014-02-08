#!/usr/bin/perl -w
use strict;
require('config.pl');
require('data.pl');
require('lib.pl');

my $spider_name = 'tieba';
my $db_conn = conn_db();

while (<>) {
	my @arr = split("\t");
	my $title = gbk_to_utf8($arr[0]);
	my $count = $arr[5];
	print "$title\t$count\n";
	next if ($count == 0);
	if (execute_scalar("select count(*) from quality where title = '$title'", $db_conn) == 0) {
		$db_conn->do("insert into quality(title, sogou_click) values('$title', $count)");
	}
	else {
		$db_conn->do("update quality set sogou_click = $count where title = '$title'");
	}
}
