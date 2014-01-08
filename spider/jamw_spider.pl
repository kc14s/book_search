#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'jamw';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://www.9imw.com/shuku/0/2/0/0/0/0/1-$page.html";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	if ($booklist_html =~ /<a href="shuku\/0\/2\/0\/0\/0\/0\/1\-(\d+)\.html">末页<\/a>/) {
		$end_page = $1;
	}
	my @arr = split('<div class="swa">', $booklist_html);
	foreach my $arr (@arr) {
		my ($url, $title, $author, $status);
		if ($arr =~ /<span class="swbt"><a href="\/xiaoshuo\/(\d+)\/index\.html" target="_blank">([^<]+?)<\/a>/) {
			$url = "http://www.9imw.com/xiaoshuo/$1/mulu.html";
			$title = $2;
		}
		$author = $1 if ($arr =~ /searchsubmit=yes" class="black" target="_blank">([^<]+?)<\/a><\/div>/);
		next if (!defined($url) || !defined($title) || !defined($author));
		wlog("$url $title $author");
		$books{"$url $title"} = [$url, $title, $author] if (!defined($books{"$url $title"}));
	}
#	last;	#debug
}

foreach my $book (values %books) {
    my ($book_url, $title, $author) = @$book;
	my @chapters;
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	my $intro = $1 if ($book_html =~ /<\/p>小说简介：\s*([\d\D]*?)\s*<\/div>/);
	my $status = 0;
	wlog($intro);
	while ($book_html =~ /<a rel="nofollow" href="(\/xiaoshuo\/\d+\/\d+\.html)" title="([^"]+?)" target="_blank">/g) {
		my $chapter_url = "http://www.9imw.com$1";
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro);
}

