#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'wd';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://www.wandoou.com/top/lastupdate_$page.html";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	if ($booklist_html =~ /class="last">(\d+)<\/a>/) {
		$end_page = $1;
	}
	my @arr = split('<tr ', $booklist_html);
	foreach my $arr (@arr) {
		my ($url, $title, $author, $status);
		if ($arr =~ /<td class="tdLeft"><a href="(http:\/\/www\.wandoou\.com\/book\/\d+\.html)">([^<]+?)<\/a><\/td>/) {
			$url = $1;
			$title = $2;
		}
		if ($arr =~ /<td><a href="http:\/\/www\.wandoou\.com\/modules\/article\/authorarticle\.php\?author=[\w%]+?">([^<]+?)<\/a><\/td>\s*<td>[\d\-]+<\/td>\s*<td>([^<]+?)<\/td>/) {
			$author = $1;
			$status = $2;
		}
		next if (!defined($url) || !defined($title) || !defined($author));
		my $category = $1 if ($arr =~ /<td class="tdLeft">【([^<]+?)】<\/td>/);
		$status = get_status($status);
		wlog("$url $title $author $status $category");
		$books{"$url $title"} = [$url, $title, $author, $status, $category] if (!defined($books{"$url $title"}));
	}
#	last;	#debug
}

foreach my $book (values %books) {
    my ($book_intro_url, $title, $author, $status, $category) = @$book;
	my @chapters;
	my $book_intro_html = fetch_url($book_intro_url, $spider_name);
	$book_intro_html = gbk_to_utf8($book_intro_html);
	my $intro = $1 if ($book_intro_html =~ /<dd id="wrap">\s*([\d\D]+?)\s*<\/dd>/);
	my $book_url = substr($book_intro_url, 0, length($book_intro_url) - 5).'/index.html';
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	wlog($intro);
	while ($book_html =~ /<a href="(\/book\/\d+\/\d+\.html)" target="_blank" titile="([^"]+?)">/g) {
		my $chapter_url = "www.wandoou.com$1";
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, $category);
}

