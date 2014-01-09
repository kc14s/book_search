#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'bh';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://www.binhuo.com/sort_$page.html";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	if ($booklist_html =~ /class="last">(\d+)<\/a>/) {
		$end_page = $1;
	}
	my @arr = split('<li>', $booklist_html);
	foreach my $arr (@arr) {
		my ($url, $title, $author, $status);
		if ($arr =~ /<div class="c1"><a href="http:\/\/www\.binhuo\.com\/info_(\d+)\.html" target="_blank">([^<]+?)<\/a>/) {
			$url = "http://www.binhuo.com/html/".int($1 / 1000)."/$1/index.html";
			$title = $2;
		}
		$author = $1 if ($arr =~ /<div class="c2"><a href="http:\/\/www\.binhuo\.com\/modules\/article\/authorarticle\.php\?author=([^"]+?)" target="_blank">/);
		next if (!defined($url) || !defined($title) || !defined($author));
		$status = get_status($1) if ($arr =~ /<div class="c6">([^<]+?)<\/div>/);
		wlog("$url $title $author $status");
		$books{"$url $title"} = [$url, $title, $author, $status] if (!defined($books{"$url $title"}));
	}
#	last;	#debug
}

foreach my $book (values %books) {
    my ($book_url, $title, $author, $status) = @$book;
	my @chapters;
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	my $intro = $1 if ($book_html =~ /简介：<\/font>\s*([\d\D]*?)\s*<\/div>/);
	wlog($intro);
	while ($book_html =~ /<span><a href="(\d+\.html)">([^<]+?)<\/a><\/span>/g) {
		my $chapter_url = substr($book_url, 0, length($book_url) - 10).$1;
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro);
}

