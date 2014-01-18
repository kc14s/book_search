#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'zh';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
my $retry = 10;
for (my $page = 1; $page < $end_page; ++$page) {
	wlog("page $page");
	my $booklist_url = "http://book.zongheng.com/store/c0/c0/b9/u0/p$page/v9/s9/t0/ALL.html";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$end_page = $1 if ($booklist_html =~ /<div class="pagenumber pagebar" page="\d+" count="(\d+)" total="\d+">/);
	my @arr = split(/<span class="kind">/, $booklist_html);
	my $match = 0;
	wlog("split fail $booklist_html") if (@arr <= 1);
	foreach my $arr (@arr) {
		my ($url, $title, $author, $status, $intro);
		if ($arr =~ /<span class="chap">\s*<a href="(http:\/\/book\.zongheng\.com\/book\/\d+\.html)" class="fs14" title="([^"]+?)" target="_blank">/) {
			$url = $1;
			$title = $2;
		}
		$author = $1 if ($arr =~ /userInfo\/\d+\.html" title="([^"]+?)"/);
		next if (!defined($url) || !defined($title) || !defined($author));
		my $category = $1 if ($arr =~ /\[([\d\D]+?)\]<\/a><\/span>/);
		wlog("$url $title $author $category");
		$books{"$url $title"} = [$url, $title, $author, $category] if (!defined($books{"$url $title"}));
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
#	last;	#debug
}

foreach my $book (values %books) {
    my ($book_intro_url, $title, $author, $category) = @$book;
	my @chapters;
	my $book_intro_html = fetch_url($book_intro_url, $spider_name);
	my ($status, $intro);
	$status = get_status($1) if ($book_intro_html =~ /itemprop="updataStatus">([^<]+?)<\/span>/);
	$intro = $1 if ($book_intro_html =~ /<p itemprop="description">([\d\D]+?)<\/p>/);
	my @categories = ($category);
	if ($book_intro_html =~ /<div class="keyword">\s*小说关键词：\s*([\d\D]+?)<\/div>/g) {
		my $div = $1;
		while ($div =~ /keyword\/([\d\D]+?)\/1\.html/g) {
			push @categories, $1;
		}
	}
	wlog($intro, $status, @categories);
	my $book_url = $1 if ($book_intro_html =~ /<a class="button read" href="(http:\/\/book\.zongheng\.com\/showchapter\/\d+\.html)">点击阅读<\/a>/);
	my $book_html = fetch_url($book_url, $spider_name);
	while ($book_html =~ /<td><a href="http:\/\/(book\.zongheng\.com\/chapter\/\d+\/\d+\.html)" title="[\d\D]+?">([^<]+?)<\/a><\/td>/g) {
		my ($chapter_url, $chapter_title) = ($1, $2);
		next if (!defined($chapter_url));
		push @chapters, [$chapter_url, $chapter_title];
		wlog("$chapter_url $chapter_title");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, @categories);
}

