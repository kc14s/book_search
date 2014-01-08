#!/usr/bin/perl -w
use strict;
require('config.pl');
require('data.pl');
require('lib.pl');

my $spider_name = 'bqg';
my $db_conn = conn_db();

my %books;
my $category_url = 'http://www.biquge.com/xiaoshuodaquan/';
my $category_html = fetch_url($category_url, $spider_name);
$category_html = gbk_to_utf8($category_html);
while ($category_html =~ /<li><a href="(http:\/\/www\.biquge\.com\/\d+_\d+\/)">([^<]+?)<\/a>\/([^<]+?)<\/li>/g) {
	wlog("$1 $2 $3");
	$books{"$2 $3"} = [$1, $2, $3] if (!defined($books{"$2 $3"}));
}

foreach my $book (values %books) {
	my ($book_url, $title, $author) = @$book;
	my @chapters;
	wlog($book_url);
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	my $intro = ($book_html =~ /<div id="intro">\s*([\d\D]+?)\s*<p>各位书友/) ? $1 : '';
	wlog("$intro");
	my $status = 0;
	my @arr = split('<dt>', $book_html);
	for (my $i = 2; $i < @arr; ++$i) {
		while ($book_html =~ /<dd><a href="(\/\d+_\d+\/\d+\.html)">([^<]+?)<\/a><\/dd>/g) {
			my $chapter_url = "http://www.biquge.com$1";
			push @chapters, [$chapter_url, $2];
			wlog("$chapter_url $2");
		}
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro);
}
