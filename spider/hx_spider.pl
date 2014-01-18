#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'hx';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	wlog("page $page");
	my $booklist_url = "http://www.hongxiu.com/novel/s/1_${page}_order9.html";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	my @arr = split(/<li id="li\d+">/, $booklist_html);
	my $match = 0;
	wlog("split fail $booklist_html") if (@arr == 1);
	foreach my $arr (@arr) {
		my ($url, $title, $author, $status, $intro);
		if ($arr =~ /<a href="(http:\/\/novel\.hongxiu\.com\/a\/\d+\/)" title="([^"]+?)" target="_blank">/) {
			$url = "${1}list.html";
			$title = $2;
		}
		$author = $1 if ($arr =~ /novelinfo\.html" title="([^"]+?)"/);
		next if (!defined($url) || !defined($title) || !defined($author));
		$status = get_status($1) if ($arr =~ /<dt style="display:"><i>([^<]+?)<\/i>/);
		$intro = $1 if ($arr =~ /<p style="display:">([^<]*?)<\/p>/);
		wlog("$url $title $author $status $intro");
		$books{"$url $title"} = [$url, $title, $author, $status, $intro] if (!defined($books{"$url $title"}));
		$match = 1;
	}
#	last;	#debug
	if (!$match) {
		wlog("page $page, no match. $booklist_html");
		last;
	}
}

foreach my $book (values %books) {
    my ($book_url, $title, $author, $status, $intro) = @$book;
	my @chapters;
	my $book_html = fetch_url($book_url, $spider_name);
#	$book_html = gbk_to_utf8($book_html);
	my @categories;
	while ($book_html =~ />([^<]+?)<\/a> &gt; <a /g) {
		push @categories, $1 if (index($1, '首页') < 0);
	}
	push @categories, $1 if ($book_html =~ />([^<]+?)<\/a><\/span> &gt; /);
	wlog(@categories);
	my @arr = split('<li><strong', $book_html);
	foreach my $arr (@arr) {
		my ($chapter_url, $chapter_title);
		if ($arr =~ /<a href='(\/a\/\d+\/\d+\.html)' title='([^']+?)'/) {
			$chapter_url = "novel.hongxiu.com$1";
			$chapter_title = $2;
		}
		elsif ($arr =~ /<a title="([^"]+?)" target="_blank" href='http:\/\/(vip\.hongxiu\.com\/vipread\d+\/\d+\.aspx)'>/) {
			$chapter_url = $2;
			$chapter_title = $1
		}
		next if (!defined($chapter_url));
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, @categories);
}

