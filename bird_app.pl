#!/usr/bin/env perl

use strict;
use warnings;

use Encode;
use utf8;

use Data::Dumper;

#Encoding
my $utf8 = find_encoding('utf-8');
binmode STDOUT, ":encoding(utf-8)";

use HIDay1::Bird;

# この辺そのまんま
my $b1 = HIDay1::Bird->new( name => 'jkondo');
my $b2 = HIDay1::Bird->new( name => 'reikon');
my $b3 = HIDay1::Bird->new( name => 'onishi');

# フォローできますね
$b1->follow($b2);
$b1->follow($b3);

$b3->follow($b1);

$b1->tweet('きょうはあついですね！');
$b2->tweet('しなもんのお散歩中です');
$b3->tweet('烏丸御池なう！');

my $b1_timelines = $b1->friends_timeline;
print $b1_timelines->[0]->message."\n"; # onishi: 烏丸御池なう!
print $b1_timelines->[1]->message."\n"; # reikon: しなもんのお散歩中です

my $b3_timelines = $b3->friends_timeline;
print $b3_timelines->[0]->message."\n"; # jkondo: 今日はあついですね！

print "* 自分のツイートも出せるようにしました\n";
$b1->tweet('jkondoです');
my $b1_own_tweets = $b1->own_tweets;
foreach ( @{ $b1_own_tweets } ) { print $_->message."\n"; }
print "* ツイートも消せます。一応。\n";
$b1_own_tweets->[0]->delete;
my $b1_own_tweets_new = $b1->own_tweets;
foreach ( @{ $b1_own_tweets_new } ) { print $_->message."\n"; }


print "* なんか実在人物だとやりにくいですけどフォロー解除もできます\n";
print "* Before id:jkondo unfollows id:onishi ...\n";
foreach ( @{ $b1_timelines } ) { print $_->message."\n"; }
print "* After id:jkondo unfollows id:onishi ...\n";
$b1->unfollow($b3);
my $b1_timelines_new = $b1->friends_timeline;
foreach ( @{ $b1_timelines } ) { print $_->message."\n"; }
$b1->follow($b3);

print "* ブロックもできたりします\n";
print "* Before id:onishi blocks id:jkondo ...\n";
foreach ( @{ $b1_timelines } ) { print $_->message."\n"; }
print "* After id:onishi blocks id:jkondo ...\n";
$b3->block($b1);
$b1_timelines_new = $b1->friends_timeline;
foreach ( @{ $b1_timelines_new } ) { print $_->message."\n"; }
