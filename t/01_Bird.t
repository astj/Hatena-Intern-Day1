use strict;
use warnings;

use Test::More;

use_ok 'HIDay1::Bird';
use_ok 'HIDay1::Tweet';

my $bird_astj = HIDay1::Bird->new(
   name => 'astj',
);

is $bird_astj->name, 'astj', "astj's name is 'astj'";

my $bird_jtsa = HIDay1::Bird->new(
   name => 'jtsa',
);

my $bird_3rdman = HIDay1::Bird->new(
   name => '3rdman',
);

## Tweetできてる？
# epochはnow
my $tweet1 = $bird_astj->tweet('Hello, World!');
is $tweet1->message, 'astj: Hello, World!', 'Tweeting without epoch';

# こっちのepochの1176~はnowより十分古いはず
my $tweet2 = $bird_jtsa->tweet('Hello, World!', 1176402532.80408);
is $tweet2->epoch, 1176402532.80408, 'Tweeting with epoch';

my $tweet3 = $bird_3rdman->tweet('Hello, World!'); # 後で使う
my $tweet4 = $bird_jtsa->tweet('Hello, World!',10000); # 後で使う

## 自分のTweet
my $self_tweets = $bird_jtsa->own_tweets;
is scalar(@$self_tweets), 2, "jtsa's can see 2 his own tweets.";

## みえてる？
is $bird_3rdman->follow($bird_astj) , 0, 'Follow 3rdman -> astj';
   $bird_3rdman->follow($bird_jtsa); # 後で使う

my $timeline = $bird_3rdman->friends_timeline;
is_deeply $timeline->[0], $tweet1, "3rdman can see astj's tweets";
#is_deeply $timeline->[1], $tweet2, "3rdman can see jtsa's tweets";
is scalar(@$timeline), 3, "3rdman can see 3 tweets";
   $timeline->[2]->delete;
$timeline = $bird_3rdman->friends_timeline;
is scalar(@$timeline), 2, "3rdman can see 2 tweets after deleted 1.";

## 自分のTweet 2
my $self_tweets2 = $bird_jtsa->own_tweets;
is scalar(@$self_tweets2), 1, "now jtsa's can see only 1  his own tweets.";


## Unfollowしたら見えなくなってる？
is $bird_3rdman->unfollow($bird_astj), 0, 'Unfollow 3rdman -> astj';
my $timeline2 = $bird_3rdman->friends_timeline;
is scalar(@$timeline2), 1, "3rdman can see only 1 tweets";
is_deeply $timeline2->[0], $tweet2, "3rdman's 1st tweet is now jtsa's tweets";
is $bird_3rdman->follow($bird_astj), 0, 'Refollow 3rdman -> astj';

## Blockされたら見えなくなってる？
is $bird_jtsa->block($bird_3rdman), 0, 'Block jtsa -> 3rdman';
my $timeline3 = $bird_3rdman->friends_timeline;
is scalar(@$timeline3), 1, "3rdman can see only 1 tweets";
is_deeply $timeline3->[0], $tweet1, "3rdman's 1st tweet is now astj's tweets";
is $bird_jtsa->unblock($bird_3rdman),0,'Unblock jtsa -> 3rdman';
my $timeline4 = $bird_3rdman->friends_timeline;
is scalar(@$timeline4), 1, "3rdman still can see only 1 tweets";
is $bird_3rdman->follow($bird_jtsa), 0, 'Refollow 3rdman -> jtsa';
my $timeline5 = $bird_3rdman->friends_timeline;
is scalar(@$timeline5), 2, "3rdman can see now 2 tweets";

## Blockしたら見えなくなってる？
is $bird_3rdman->block($bird_jtsa), 0, 'Block 3rdman -> jtsa';
my $timeline6 = $bird_3rdman->friends_timeline;
is scalar(@$timeline6), 1, "3rdman can see only 1 tweets";
is $bird_3rdman->unblock($bird_jtsa), 0, 'Unblock 3rdman -> jtsa';

### C1?C2?

## 空文字列でのTweet
is $bird_3rdman->tweet(''),'You need tweet body.', "Tweet with blank body NOT succeeds";

###  C2

## フォローしてる人をフォロー
   $bird_3rdman->follow($bird_jtsa);
is $bird_3rdman->follow($bird_jtsa),'Already Following',"Can't follow a bird twice.";

## フォローしてない人をアンフォロー
   $bird_3rdman->unfollow($bird_jtsa);
is $bird_3rdman->unfollow($bird_jtsa),'Not Following',"Can't unfollow a bird not following.";

## ブロックしてる人をブロック
   $bird_3rdman->block($bird_jtsa);
is $bird_3rdman->block($bird_jtsa), 'Already Blocking', "Can't block a bird already blocking";

## ブロックしてない人をブロック解除
   $bird_3rdman->unblock($bird_jtsa);
is $bird_3rdman->unblock($bird_jtsa), 'Not Blocking', "Can't unblock a bird not blocking";


done_testing();
