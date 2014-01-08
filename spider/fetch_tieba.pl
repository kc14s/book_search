#!/usr/bin/perl -w
use strict;
require('config.pl');
require('data.pl');
require('lib.pl');

my $spider_name = 'tieba';
my $db_conn = conn_db();

my $request = $db_conn->prepare("select id, title from book");
$request->execute;
while (my ($book_id, $book_title) = $request->fetchrow_array) {
	my ($tieba_follower, $category) = get_tieba_info($book_title);
	$db_conn->do("update book set category = $category, tieba_follower = $tieba_follower where id = $book_id");
#	$db_conn->do("insert into follower(book_id, follower_num) values($book_id, $tieba_follower)") if ($tieba_follower > 0);
	wlog("$book_title $category $tieba_follower");
}
