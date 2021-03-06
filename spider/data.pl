#!/usr/bin/perl -w
use strict;

my %status = (
#'' => 0
  '完结' => 1,
  '完成' => 1,
  '已完成' => 1,
  '已出版' => 1,
  '出版中' => 1,
  '全本' => 1,
  '连载' => 2,
  '连载中' => 2,
  '暂停' => 3,
  '封笔' => 4
#, '' => ,
);

my %categories = (
'严肃小说' => 1,
'中国古代作家' => 2,
'中国当代作家' => 3,
'中国近现代作家' => 4,
'传统武侠小说' => 5,
'儿童文学' => 6,
'其他小说作品' => 7,
'军事·历史小说' => 8,
'古典文学' => 9,
'古言小说' => 10,
'外国作家' => 11,
'外国文学' => 12,
'奇幻·玄幻小说' => 13,
'当代其他文学作品' => 14,
'悬疑·推理小说' => 15,
'文学人物' => 16,
'文学期刊' => 17,
'文学话题' => 18,
'游戏小说' => 19,
'灵异·超能力小说' => 20,
'科幻小说' => 21,
'近现代文学作品' => 22,
'都市·言情小说' => 23,
#'' => ,
);

sub get_status {
	my $status = $_[0];
	$status =~ s/\s//g;
	$status =~ s/　//g;
	if (!defined($status{$status})) {
		wlog("invalid status $status");
		exit;
	}
	return $status{$status};
}

sub get_category {
	if (!defined($categories{$_[0]})) {
		wlog("invalid category $_[0]");
		return 0;
	}
	return $categories{$_[0]};
}

1;
