#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'bxs';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://www.bxs.cc/type/0_0_0_0_$page.html";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	if ($booklist_html =~ /class="last">(\d+)<\/a>/) {
		$end_page = $1;
	}
	my @arr = split('<div id="zhlistbox">', $booklist_html);
	foreach my $arr (@arr) {
		my ($url, $title, $author);
		if ($arr =~ /<div class="title"><h2><a target="_blank" href="(\/\d+\/)" title="[^"]+?">《([^"]+?)》<\/a><\/h2><\/div>/) {
			$url = "http://www.bxs.cc$1";
			$title = $2;
		}
		$author = $1 if ($arr =~ /<div class="intro"><span>作者:([^\s]*?)[著]* /);
		next if (!defined($url) || !defined($title) || !defined($author));
		wlog("$url $title $author");
		$books{"$url $title"} = [$url, $title, $author];
	}
	last if (!next_page($spider_name, $page));
#	$end_page = 2;	#debug
}

foreach my $book (values %books) {
    my ($book_url, $title, $author) = @$book;
	my @chapters;
	my $status = 0;
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	my $category = $1 if ($book_html =~ /类别：([^<]+?)<br>/);
	my $intro = $1 if ($book_html =~ /&nbsp;类别：[^<]+?<br>\s*([\d\D]*?)\s*<\/div>/);
	wlog($intro);
	while ($book_html =~ /<li><a href="(\/\d+\/\d+\.html)" title="([^"]+?)">/g) {
		my $chapter_url = "http://www.bxs.cc".$1;
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, $category);
}

