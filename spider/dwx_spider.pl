#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'dwx';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://www.dawenxue.net/xiaoshuotoplastupdate/0/$page.html";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	if ($booklist_html =~ /class="last">(\d+)<\/a>/) {
		$end_page = $1;
	}
	my @arr = split('<tr>', $booklist_html);
	foreach my $arr (@arr) {
		my ($url, $title, $author, $status);
		if ($arr =~ /<td class="odd"><a href="(http:\/\/www\.dawenxue\.net\/html\/\d+\/\d+\/)">([^<]+?)<\/a><\/td>/) {
			$url = $1;
			$title = $2;
		}
		$author = $1 if ($arr =~ /<td class="odd">([^"]+?)<\/td>/);
		next if (!defined($url) || !defined($title) || !defined($author));
		$status = get_status($1) if ($arr =~ /<td class="even" align="center">([^<]+?)<\/td>/);
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
	my $intro = $1 if ($book_html =~ /\/著,\s*([\d\D]+?)\s*<br><center><font color=red>/);
	wlog($intro);
	while ($book_html =~ /<a href="(\d+\.html)">([\d\D]+?)<\/a>/g) {
		my $chapter_url = "$book_url$1";
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro);
}

