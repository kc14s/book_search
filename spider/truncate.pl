#!/usr/bin/perl -w
use strict;
require('config.pl');
require('lib.pl');
require('data.pl');

my $db_conn = conn_db();
$db_conn->do('truncate book');
$db_conn->do('truncate chapter');
$db_conn->do('truncate link');
