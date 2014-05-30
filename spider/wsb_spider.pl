#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'wsb';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
my $retry = 10;
for (my $page = 1; $page < $end_page; ++$page) {
	wlog("page $page");
	my $booklist_url = "http://www.wanshuba.com/Book/ShowBookList.aspx?page=$page";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	$end_page = $1 if ($booklist_html =~ /page=(\d+)">尾页<\/a>/);
	my @arr = split(/<ul class="titlelist">/, $booklist_html);
	my $match = 0;
	wlog("split fail $booklist_html") if (@arr <= 1);
	foreach my $arr (@arr) {
		my ($url, $title, $author, $status, $intro, $book_id);
		if ($arr =~ /<li class="zp"><a class="name"\s*href="\/Book\/(\d+)\/Index\.shtml" target="_blank">([^<]+?)<\/a>/) {
			$book_id = $1;
			$url = "http://www.wanshuba.com/Book/$1/Index.shtml";
			$title = $2;
		}
		$author = $1 if ($arr =~ /<li class="zz">([^<]+?)<\/li>/);
		next if (!defined($url) || !defined($title) || !defined($author));
		my $category = $1 if ($arr =~ /<li class="lb"><a class="cat" href="\/Book\/LN\/\d+\.shtml">([^<]+?)<\/a><\/li>/);
		wlog("$url $title $author $category");
		$books{"$url $title"} = [$url, $title, $author, $category, $book_id] if (!defined($books{"$url $title"}));
		$match = 1;
	}
	if (!$match) {
		--$page;
		wlog("page $page, no match. $booklist_html");
		if (--$retry > 0) {
			sleep(60);
		}
		else {
			last;
		}
	}
	last if (!next_page($spider_name, $page));
#	last;	#debug
}

foreach my $book (values %books) {
    my ($book_intro_url, $title, $author, $category, $book_id) = @$book;
	my @chapters;
	my $book_intro_html = fetch_url($book_intro_url, $spider_name);
	$book_intro_html = gbk_to_utf8($book_intro_html);
	my ($status, $intro);
	$status = get_status($1) if ($book_intro_html =~ /\/ 状态：([^\s]+?) <\/span>/);
	$intro = $1 if ($book_intro_html =~ /更新日期：[\d \-:]+?<\/span><\/div>\s*([\d\D]+?)\s*<\/div>/);
	wlog($intro, $status, $category);
	my $book_url = "http://www.wanshuba.com$1" if ($book_intro_html =~ /<a href="(\/Html\/\d+\/\d+\/List\.html)" title="阅读：/);
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	while ($book_html =~ /<li><a href="(\d+\.html)" title="更新时间:[\d \-:]+?">([^<]+?)<\/a><\/li>/g) {
		my ($chapter_url, $chapter_title) = (substr($book_url, 7, length($book_url) - 7 - 9).$1, $2);
		next if (!defined($chapter_url));
		push @chapters, [$chapter_url, $chapter_title];
		wlog("$chapter_url $chapter_title");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, $category);
}

