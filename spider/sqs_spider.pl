#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'sqs';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://www.sqsxs.com/fl/-$page.html";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	if ($booklist_html =~ /class="last">(\d+)<\/a>/) {
		$end_page = $1;
	}
	my @arr = split('</tr>', $booklist_html);
	foreach my $arr (@arr) {
		my ($url, $title, $author, $category);
		if ($arr =~ /<td class="tdLeft"><a href="(http:\/\/www\.sqsxs\.com\/[\w\/\.]+?)">([^"]+?)<\/a><\/td>/) {
			$url = $1;
			$title = $2;
		}
		$author = $1 if ($arr =~ /<td><a href="http:\/\/www\.sqsxs\.com\/modules\/article\/authorarticle\.php\?author=[\w%]+?">([^"]+?)<\/a><\/td>/);
		next if (!defined($url) || !defined($title) || !defined($author));
		$category = $1 if ($arr =~ /<td class="tdLeft">【([^<]*?)】<\/td>/);
		wlog("$url $title $author");
		$books{"$url $title"} = [$url, $title, $author, $category];
	}
#	$end_page = 2;	#debug
}

foreach my $book (values %books) {
    my ($book_url, $title, $author, $category) = @$book;
	my @chapters;
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	my $status = 0;
	$title = $1 if ($book_html =~ /<h1>([^<]+?)<span class="zuixin">/);
	my $intro = $1 if ($book_html =~ /简介：<\/b><br \/>\s*([\d\D]*?)\s*<\/div>/);
	wlog($intro);
	while ($book_html =~ /<a href="(\d+.html)">([^"]+?)<\/a>/g) {
		my $chapter_url = substr($book_url, 7, length($book_url) - 7 - 10).$1;
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, $category);
}

