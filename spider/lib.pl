#!/usr/bin/perl -w
use strict;
use DBI;
use Encode;
use URI::Escape;

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
	my ($title, $author, $chapters, $source_id, $status, $intro) = @_;
	$title = $db_conn->quote($title);
	$author = $db_conn->quote($author);
	$intro = $db_conn->quote($intro);
	if (execute_scalar("select count(*) from book where title = $title and author = $author", $db_conn) == 0) {
		$db_conn->do("insert into book(title, author, source_id, status, intro) values($title, $author, '$source_id', $status, $intro)");
	}
	else {
		if ($source_id ne 'lyzw' || $source_id ne 'jamw' || $source_id ne 'qd') {
			$db_conn->do("update book set status = $status where title = $title and author = $author");
		}
	}
	my $book_id = execute_scalar("select id from book where title = $title and author = $author", $db_conn);
	foreach my $pa (@$chapters) {
		my ($chapter_url, $chapter_title) = @$pa;
		$chapter_title = $db_conn->quote($chapter_title);
		my $chapter_id = execute_scalar("select id from chapter where book_id = $book_id and title = $chapter_title and source_id = '$source_id'", $db_conn);
		if (!defined($chapter_id)) {
			$db_conn->do("insert into chapter(book_id, title, source_id, url) values($book_id, $chapter_title, '$source_id', '$chapter_url')");
		}
	}
}

sub get_tieba_info {
	sleep(3);
	my $book_title = $_[0];
	my $encoded_book_title = uri_escape($book_title);
	my $tieba_html = fetch_url("http://tieba.baidu.com/f?kw=$encoded_book_title", 'baidu');
	$tieba_html = gbk_to_utf8($tieba_html);
	my ($tieba_follower, $category) = (0, 0);
	if (index($tieba_html, "<title>${book_title}吧_百度贴吧<\/title>") > 0) {
		$tieba_follower = $1 if ($tieba_html =~ /<span class="card_menNum"\s*>([\d,]+)<\/span>/);
		$tieba_follower =~ s/,//g;
		$category = $1 if ($tieba_html =~ /<span class="dir_text">目录：<\/span><\/li><li><a target="_blank" href="[^"]+">([^<]+?)<\/a>/);
		$category = get_category($category);
	}
	return ($tieba_follower, $category);
}

sub get_date_time_str {
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst)=localtime(time());
	$year += 1900;
	++$mon;
	$mon = "0$mon" if ($mon < 10);
	$day = "0$day" if ($day < 10);
	$hour = "0$hour" if ($hour < 10);
	$min = "0$min" if ($min < 10);
	$sec = "0$sec" if ($sec < 10);
	return "$year-$mon-$day $hour:$min:$sec";
}

sub wlog {
#	my $date_time = `date '+%F %T'`;
#	chop $date_time;
#	print "$date_time $_[0]\n";
	print get_date_time_str().' '.$_[0]."\n";
}

1;
