#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'xxsy';
my $db_conn = conn_db();

my %books;
my $end_page = 7981;
for (my $page = 1; $page < $end_page; ++$page) {
	wlog("page $page");
	my $booklist_url = "http://www.xxsy.net/search.aspx?q=&sort=5&rn=22&pn=$page&rand=1389547";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
#	if ($booklist_html =~ /\/(\d+)<\/span> 页,共/) {
#		$end_page = $1;
#	}
	my ($title, $author, $status, $book_url, $intro_url, $book_id, $category);
	my $match = 0;
	while ($booklist_html =~ /"authorname":"([^"]+?)","banquan":"[^"]+?","bookid":(\d+),"booklength":\d+,"bookname":"([^"]+?)","booktype":"([^"]+?)"[\d\D]+?"lianzai":"([^"]+?)"/g) {
		$intro_url = "http://www.xxsy.net/info/$2.html";
		$book_url = "http://www.xxsy.net/books/$2/default.html";
		$book_id = $2;
		$title = $3;
		$author = $1;
		$category = $4;
		$status = get_status($5);
		next if (!defined($book_url) || !defined($title) || !defined($author));
		wlog("$book_url $title $author $status $category");
		$books{"$book_url $title"} = [$book_url, $intro_url, $title, $author, $status, $book_id, $category] if (!defined($books{"$book_url $title"}));
		++$match;
	}
	wlog($booklist_html) if ($match == 0);
#	last;	#debug
}

foreach my $book (values %books) {
    my ($book_url, $intro_url, $title, $author, $status, $book_id, $category) = @$book;
	my @chapters;
	my $intro = '';
	if (!book_exist($title, $author)) {
		my $intro_html = fetch_url($intro_url, $spider_name);
		$intro = $1 if ($intro_html =~ /<b>内容介绍：<\/b><br \/>\s*([\d\D]+?)\s*<\/div>/);
		wlog($intro);
	}
	my $book_html = fetch_url($book_url, $spider_name);
	while ($book_html =~ /<li><a href="(\d+)\.html" title="[^"]+?">([^<]+?)<\/a><\/li>/g) {
		my $chapter_url = "http://www.xxsy.net/books/$book_id/$1.html";
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, $category);
}

