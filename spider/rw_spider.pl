#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');

my $spider_name = 'rw';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://www.ranwen.cc/Book/ShowBookList.aspx?page=$page";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	if ($booklist_html =~ /<font color=blue><b>(\d+)<\/b><\/font>/) {
		$end_page = $1;
	}
	my @arr = split('<ul class="a1">', $booklist_html);
	foreach my $arr (@arr) {
		my ($url, $title, $author);
		$url = $1 if($arr =~ /<div class="storelistbt3b"><a href="([^"]+?)">\[目录\]/);
		$title = $1 if ($arr =~ /class="phb_font2">([^"]+?)<\/a>/);
		$author = $1 if ($arr =~ /<div class="storelistbt3d"><a href="[^"]+?">([^"]+?)<\/a><\/div>/);
		next if (!defined($url) || !defined($title) || !defined($author));
		wlog("http://www.ranwen.cc$url $title $author");
		$books{"$url $title"} = ["http://www.ranwen.cc$url", $title, $author];
	}
	$end_page = 2;	#debug
}

foreach my $book (values %books) {
    my ($book_url, $title, $author) = @$book;
	my @chapters;
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	while ($book_html =~ /<li><a href="([\w\.]+?)"\s+title="[\d\-\s:]+">([^"]+)<\/a>/g) {
		push @chapters, [substr($book_url, 7, rindex($book_url, '/') + 1).$1, $2];
		wlog(substr($book_url, 7, rindex($book_url, '/') + 1).$1." $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name);
}
