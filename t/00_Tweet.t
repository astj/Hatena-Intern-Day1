use strict;
use warnings;

use Test::More;

use_ok 'HIDay1::Tweet';

my $tweet = HIDay1::Tweet->new(
   author => 'astj',
   body => 'てすとついーと',
   epoch => 1376402532.80408,
);

is $tweet->author, 'astj';
is $tweet->body, 'てすとついーと';
is $tweet->message, 'astj: てすとついーと';
is $tweet->epoch, 1376402532.80408;
ok (! $tweet->deleted , 'not deleted before deleted');

is $tweet->delete, 0, "Deleted";

ok ($tweet->deleted, 'properly deleted after deleted');

is $tweet->delete, 'Already deleted.' , "cannot delete after delete";

done_testing();
