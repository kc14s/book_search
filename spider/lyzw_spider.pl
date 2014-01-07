#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');

my $spider_name = 'lyzw';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://www.6yzw.org/lastupdate_$page/";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	if ($booklist_html =~ /class="last">(\d+)<\/a>/) {
		$end_page = $1;
	}
	my @arr = split('<tr>', $booklist_html);
	foreach my $arr (@arr) {
		my ($url, $title, $author);
		if ($arr =~ /<td class="odd"><a href="(http:\/\/www\.6yzw\.org\/[\d_]+?\/)">([^"]+?)<\/a><\/td>/) {
			$url = $1;
			$title = $2;
		}
		$author = $1 if ($arr =~ /<td class="odd">([^"]+?)<\/td>/);
		next if (!defined($url) || !defined($title) || !defined($author));
		wlog("$url $title $author");
		$books{"$url $title"} = [$url, $title, $author];
	}
#	$end_page = 2;	#debug
}

foreach my $book (values %books) {
    my ($book_url, $title, $author) = @$book;
	my @chapters;
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	while ($book_html =~ /<dd><a href="([\/_\.\w]+)" title="([^"]+?)">/g) {
		my $chapter_url = "www.6yzw.org$1";
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name);
}

