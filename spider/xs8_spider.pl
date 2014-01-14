#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'xs8';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://www.xs8.cn/shuku/c0-t0-f0-w0-u0-o0-2-$page.html";
	$booklist_url = 'http://www.xs8.cn/shuku/c0-t0-f0-w0-u0-o0-2-.html' if ($page == 1);
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	if ($booklist_html =~ /\/(\d+)<\/span> 页,共/) {
		$end_page = $1;
	}
	my @arr = split('<div class="li_body">', $booklist_html);
	foreach my $arr (@arr) {
		my ($title, $author, $status, $book_url, $intro_url, @categories);
		if ($arr =~ /<h3><a href="http:\/\/www\.xs8\.cn\/book\/(\d+)\/index\.html"\s*target="_blank">《([^<]+?)》<\/a><\/h3>/) {
			$intro_url = "http://www.xs8.cn/book/$1/index.html";
			$book_url = "http://www.xs8.cn/book/$1/readbook.html";
			$title = $2;
		}
		$author = $1 if ($arr =~ /<span class="author">作者：<a href="http:\/\/www\.xs8\.cn\/author\/\d+\.html"\s+target="_blank">([^<]+?)<\/a><\/span>/);
		next if (!defined($book_url) || !defined($title) || !defined($author));
		while ($arr =~ /<span class="tag">([^<]+?)<\/span>/g) {
			push @categories, $1;
		}
		$status = get_status($1) if ($arr =~ /<span class="status">([^<]+?)<\/span>/);
		wlog("$book_url $title $author $status");
		$books{"$book_url $title"} = [$book_url, $intro_url, $title, $author, $status, @categories] if (!defined($books{"$book_url $title"}));
	}
#	last;	#debug
}

foreach my $book (values %books) {
    my ($book_url, $intro_url, $title, $author, $status, @categories) = @$book;
	my @chapters;
	my $intro = '';
	if (!book_exist($title, $author)) {
		my $intro_html = fetch_url($intro_url, $spider_name);
		$intro = $1 if ($intro_html =~ /<div class="bookintro cont c_show" id="BookIntro">\s*([\d\D]*?)\s*<span class="bibtn">/);
		wlog($intro);
	}
	my $book_html = fetch_url($book_url, $spider_name);
	while ($book_html =~ /href="(http:\/\/www\.xs8\.cn\/book\/\d+\/\d+\.html)">([^<]+?)<\/a>/g) {
		my $chapter_url = $1;
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, @categories);
}

