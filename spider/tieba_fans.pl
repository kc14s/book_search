#!/usr/bin/perl -w
use strict;
require('config.pl');
require('data.pl');
require('lib.pl');

my $spider_name = 'tieba';
my $db_conn = conn_db();

my %categories;
open IN, 'data/tieba_content';
while (<IN>) {
	chomp;
	$categories{$1} = $2 if (/(.+?)\t([\d\D]+)/);
}
close IN;

while (my ($url, $useless) = each %categories) {
	my $end_page = 10000;
	for (my $page = 1; $page <= $end_page; ++$page) {
		print "$useless $page/$end_page http://tieba.baidu.com$url&pn=$page\n";
		my $html = `curl -s 'http://tieba.baidu.com$url&pn=$page'`;
		$html = gbk_to_utf8($html);
#		print $html;
		$end_page = $1 if ($html =~ /pn=(\d+)">尾页<\/a>/);
		while ($html =~ /<a href='http:\/\/tieba\.baidu\.com\/f\?kw=[%\w]+' target='_blank'>([\d\D]+?)<\/a>/g) {
			my $title = $1;
			my ($fan_num, $category) = get_tieba_info($title);
			if (execute_scalar("select count(*) from quality where title = '$title'", $db_conn) == 0) {
				$db_conn->do("insert into quality(title, tieba_category, tieba_fans) values('$title', $category, $fan_num)");
			}
			else {
				$db_conn->do("update quality set tieba_category = $category, tieba_fans = $fan_num where title = '$title'");
			}
			$db_conn->do("update book set category = $category, tieba_follower = $fan_num where title = '$title'");
			print "$title\t$category\t$fan_num\n";
		}
	}
}
