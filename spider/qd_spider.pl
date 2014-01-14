#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'qd';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	my $booklist_url = "http://all.qidian.com/book/bookstore.aspx?ChannelId=-1&SubCategoryId=-1&Tag=all&Size=-1&Action=-1&OrderId=6&P=all&PageIndex=$page&update=-1&Vip=-1&Boutique=-1&SignStatus=-1";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	if ($booklist_html =~ /PageIndex=(\d+)&update=\-1&Vip=-1&Boutique=\-1&SignStatus=\-1'>末页<\/a>/) {
		$end_page = $1;
	}
	my @arr = split('<div class="swa">', $booklist_html);
	foreach my $arr (@arr) {
		my ($book_url, $intro_url, $title, $author, $status, @categories);
		if ($arr =~ /<span class="swbt"><a href="\/Book\/(\d+)\.aspx" target="_blank">([^<]+?)<\/a>/) {
			$intro_url = "http://www.qidian.com/Book/$1.aspx";
			$book_url = "http://readbook.qidian.com/bookreader/$1.html";
			$title = $2;
		}
		$author = $1 if ($arr =~ /authorIndex\.aspx\?id=\d+" target="_blank" class="black">([^<]+?)<\/a><\/div>/);
		next if (!defined($book_url) || !defined($title) || !defined($author));
		push @categories, $1 if ($arr =~ /bookstore\.aspx\?ChannelId=\d+" class="hui2">([^<]+?)<\/a>\//);
		push @categories, $1 if ($arr =~ /bookstore\.aspx\?ChannelId=\d+&SubCategoryId=\d+"\s*class="hui2">([^<]+?)<\/a>\]/);
		wlog("$book_url $title $author $intro_url");
		$books{"$book_url $title"} = [$book_url, $title, $author, $intro_url, @categories] if (!defined($books{"$book_url $title"}));
	}
#	last;	#debug
}

foreach my $book (values %books) {
    my ($book_url, $title, $author, $intro_url, @categories) = @$book;
	my @chapters;
	my $intro = '';
	if (!book_exist($title, $author)) {
		my $intro_html = fetch_url($intro_url, $spider_name);
		$intro = $1 if ($intro_html =~ /<span itemprop="description">\s*([\d\D]*?)\s*<\/span>/);
	}
	my $book_html = fetch_url($book_url, $spider_name);
	my $status = 0;
	while ($book_html =~ /<a itemprop='url' href="(http:\/\/read\.qidian\.com\/BookReader\/\d+,\d+\.aspx)" title='字数：[\d,]+\s*更新时间：[\d\- :]+'><span itemprop='headline'>([^<]+?)<\/span><\/a>/g) {
		my $chapter_url = $1;
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, @categories);
}

