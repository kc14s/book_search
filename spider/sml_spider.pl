#!/usr/bin/perl -w
use strict;
require('config.pl');
require('data.pl');
require('lib.pl');

my $spider_name = 'sml';
my $db_conn = conn_db();

my %books;
foreach my $category (1...10) {
	my $category_url = "http://www.shumilou.com/list-$category.html";
	my $category_html = fetch_url($category_url, $spider_name);
	while ($category_html =~ /<li><a href="http:\/\/([^"]+?)">([^"]+?)<\/a>\/([^"]+?)<\/li>/g) {
		wlog("$1 $2 $3");
		$books{"$2 $3"} = [$1, $2, $3] if (!defined($books{"$2 $3"}));
	}
#	last;	#debug
}

foreach my $book (values %books) {
	my ($book_url, $title, $author) = @$book;
	my @chapters;
	wlog($book_url);
	my $book_html = fetch_url($book_url, $spider_name);
	my $intro = ($book_html =~ /<br\/>\s*简介:\s*([^<]+?)\s*<br\/>/) ? $1 : '';
	my $status = 0;
	if ($book_html =~ /<br\/>\s*状态:([^<]+?)<br\/>/) {
		$status = get_status($1);
	}
	wlog("$status $intro");
	while ($book_html =~ /<li class="zl"><a href="http:\/\/([^"]+?)">([^"]+?)<\/a><\/li>/g) {
		push @chapters, [$1, $2];
		wlog("$1 $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro);
}
