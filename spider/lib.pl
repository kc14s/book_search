#!/usr/bin/perl -w
use strict;
use DBI;
use Encode;

my $db_conn;
sub conn_db {
	$db_conn = DBI->connect("DBI:mysql:database=$ENV{'db_name'};host=$ENV{'db_server'}", $ENV{'db_user'}, $ENV{'db_password'});
	$db_conn->do('set names utf8');
	return $db_conn;
}

sub fetch_url {
	my $proxy = '';
	if (defined($_[1]) && defined($ENV{'use_proxy'}->{$_[1]})) {
#		$proxy = "-x ";
	}
	if (defined($_[1]) && defined($ENV{'slow'}->{$_[1]})) {
		sleep(3);
	}
	my $html = `curl -A 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1' -s -i --speed-time 5 --speed-limit 50000 --connect-timeout 60 -m 300 '$_[0]'`;
	return $html;
}

sub execute_scalar {
	my ($sql, $conn) = @_;
	my $request = $conn->prepare($sql);
	$request->execute();
	my ($result) = $request->fetchrow_array;
	return $result;
}

sub gbk_to_utf8 {
	return encode('utf8', decode('gbk', $_[0]));
}

sub save_to_db {
	my ($title, $author, $chapters, $source_id) = @_;
	$title = $db_conn->quote($title);
	$author = $db_conn->quote($author);
	if (execute_scalar("select count(*) from book where title = $title and author = $author", $db_conn) == 0) {
		$db_conn->do("insert into book(title, author, source_id) values($title, $author, '$source_id')");
	}
	my $book_id = execute_scalar("select id from book where title = $title and author = $author", $db_conn);
	foreach my $pa (@$chapters) {
		my ($chapter_url, $chapter_title) = @$pa;
		$chapter_title = $db_conn->quote($chapter_title);
		my $chapter_id = execute_scalar("select id from chapter where book_id = $book_id and (instr(title, $chapter_title) > 0 or instr($chapter_title, title) > 0)", $db_conn);
		if (!defined($chapter_id)) {
			$db_conn->do("insert into chapter(book_id, title, source_id) values($book_id, $chapter_title, '$source_id')");
			$chapter_id = execute_scalar("select id from chapter where book_id = $book_id and title = $chapter_title", $db_conn);
		}
		if (execute_scalar("select count(*) from link where chapter_id = $chapter_id and source_id = '$source_id'", $db_conn) == 0) {
			$db_conn->do("insert into link(chapter_id, url, source_id) values($chapter_id, '$chapter_url', '$source_id')");
		}
	}
}

sub wlog {
	my $date_time = `date '+%F %T'`;
	chop $date_time;
	print "$date_time $_[0]\n";
}

1;
