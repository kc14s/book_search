#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $spider_name = 'jj';
my $db_conn = conn_db();

my %books;
my $end_page = 10000;
for (my $page = 1; $page < $end_page; ++$page) {
	wlog("page $page");
	my $booklist_url = "http://www.jjwxc.net/bookbase_slave.php?submit=&booktype=&opt=&orderstr=1&endstr=&page=$page";
	my $booklist_html = fetch_url($booklist_url, $spider_name);
	$booklist_html = gbk_to_utf8($booklist_html);
	$end_page = $1 if ($booklist_html =~ /page=(\d+)>末页<\/a>/);
	my @arr = split('<tr onMouseOver="this.bgColor = \'#ffffff\';" onMouseOut="this.bgColor = \'#eefaee\';">', $booklist_html);
	my $match = 0;
	if (@arr == 1) {
		wlog($booklist_html);
	}
	foreach my $arr (@arr) {
		my ($url, $title, $author, $status);
		$author = $1 if ($arr =~ /authorid=\d+" target="_blank">([^<]+?)<\/a>/);
		$title = $1 if ($arr =~ /" class="tooltip">([^<]+?)<\/a>/);
		$url = "http://www.jjwxc.net/$1" if ($arr =~ /<a href="(onebook.php\?novelid=\d+)"/);
		next if (!defined($url) || !defined($title) || !defined($author));
		if ($arr =~ /<td align="center">\s*([^\-]+?)\s*<\/td>\s*<td  align="right">/) {
			$status = $1;
			$status = get_status($1) if ($status =~ /(连载中|已完成|暂停)/);
#			$status =~ s/<.+?>//g;
#			$status = get_status($status);
		}
		wlog("$url $title $author $status");
		my @categories;
		if ($arr =~ /<td align="center">\s*([\d\D]+?)\-([\d\D]+?)\-([\d\D]+?)\-([\d\D]+?)\s*<\/td>/) {
			@categories = ($1, $2, $3, $4);
		}
		$books{"$url $title"} = [$url, $title, $author, $status, @categories] if (!defined($books{"$url $title"}));
		$match = 1;
	}
#	last;	#debug
	if (!$match) {
		--$page;
		wlog("page $page, no match");
		sleep(600);
	}
}

foreach my $book (values %books) {
    my ($book_url, $title, $author, $status, @categories) = @$book;
	my @chapters;
	my $book_html = fetch_url($book_url, $spider_name);
	$book_html = gbk_to_utf8($book_html);
	my $intro = $1 if ($book_html =~ /<div id="novelintro" itemprop="description">([\d\D]+?)<\/div>/);
	wlog($intro);
	while ($book_html =~ /<a itemprop="url" href="http:\/\/(www\.jjwxc\.net\/onebook\.php\?novelid=\d+&chapterid=\d+)">([^<]+?)<\/a>/g) {
		my $chapter_url = $1;
		push @chapters, [$chapter_url, $2];
		wlog("$chapter_url $2");
	}
	save_to_db($title, $author, \@chapters, $spider_name, $status, $intro, @categories);
}

