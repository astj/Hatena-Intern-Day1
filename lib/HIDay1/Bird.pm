package HIDay1::Bird;

use strict;
use warnings;

use Time::HiRes;

use HIDay1::Tweet;

sub new {
    my ($class, %args) = @_;
    return bless { name => '', %args}, $class;
}

sub name {
    my $self = shift;
    return $self->{name};
}

sub tweet {
    # epoch is optional
    my ($self, $tweet_body, $tweet_epoch) = @_;

    # からっぽのTweetはだめ
    if( ! length($tweet_body) ) { return "You need tweet body." }

    # epoch's default is NOW (/w HiRes).
    $tweet_epoch //= Time::HiRes::time();

    my $tweet = HIDay1::Tweet->new(author=> $self->name, body=> $tweet_body, epoch=>$tweet_epoch );

    unshift(@{ $self->{_own_tweets} }, $tweet);

    return $tweet;
}

# Obtain a hashref to my own tweets
sub own_tweets {
    my $self = shift;

    # ソートした上でDeleted TweetをDropして返す
    return $self->{_own_tweets} =  $self->_tidify_tweets($self->{_own_tweets});

}

# Obtain a hashref to friends_timeline
sub friends_timeline {
    my $self = shift;

    # ブロックされてる人をfollowingから消しておく
    $self->_update_following_birds;

    # フォロワーさんのツイートをぐしゃっとひとまとめにしてTidifyする
    # mapの中身は0-Tweetなフォロワーさんがいるときに空要素が混じるのがイヤなので
    return $self->_tidify_tweets(
        [ map { scalar(@{ $_->own_tweets }) ? @{ $_->own_tweets } : () }
              values $self->following_birds ] );

}

# Obtain a hashref to following-birds
sub following_birds {
    my $self = shift;

    return $self->_update_following_birds;

}

# Obtain a hashref to blocking-birds
sub blocking_birds {
    my $self = shift;

    return $self->{_blocking_birds} //= {};

}

# Follow a bird.
sub follow {
    my ($self, $target_bird) = @_;

    # 鳥以外をフォローしようとすると死ぬ
    if( ! $target_bird->isa("HIDay1::Bird") ) { die "$target_bird is not a Bird."; }

    # ブロックされてたらフォローできない
    if( $target_bird->blocking_birds->{$self->name} ) {
        # 既にフォローしてるかもしれないのでフォローを切っておく
        $self->unfollow($target_bird);
        return "Blocked!!";
    }

    # 既にフォローしてるかもしれない
    if( $self->following_birds->{$target_bird->name} ) { return "Already Following"; }

    # 万事OK
    $self->{_following_birds}->{$target_bird->name} = $target_bird;

    return 0;

}

# Unfollow a bird.
sub unfollow {
    my ($self, $target_bird) = @_;

    # 鳥以外をアンフォローしようとすると死ぬ
    if( ! $target_bird->isa("HIDay1::Bird") ) { die "$target_bird is not a Bird."; }

    # 既にフォローしてないかもしれない
    if( ! $self->following_birds->{$target_bird->name} ) { return "Not Following"; }

    # アンフォローする
    delete($self->{_following_birds}->{$target_bird->name} );

    return 0;
}

# Block a bird.
sub block {
    my ($self, $target_bird) = @_;

    # 鳥以外をブロックしようとすると死ぬ
    if( ! $target_bird->isa("HIDay1::Bird") ) { die "$target_bird is not a Bird."; }

    # 既にブロックしてるかもしれない
    if( $self->blocking_birds->{$target_bird->name} ) { return "Already Blocking"; }

    # まずアンフォローする
    $self->unfollow($target_bird);

    # 満を持してブロックする
    $self->{_blocking_birds}->{$target_bird->name} = $target_bird;

    return 0;
}

# Unblock a bird.
sub unblock {
    my ($self, $target_bird) = @_;

    # 鳥以外をブロック解除しようとすると死ぬ
    if( ! $target_bird->isa("HIDay1::Bird") ) { die "$target_bird is not a Bird."; }

    # 既にブロックしてないかもしれない
    if( ! $self->blocking_birds->{$target_bird->name} ) { return "Not Blocking"; }

    # ブロック解除する
    delete($self->{_blocking_birds}->{$target_bird->name} );

    return 0;
}

# internal: Remove 'deleted' tweets and Sort tweets.
sub _tidify_tweets {
    my ($self, $tweets) = @_;

    return [sort {$b->{epoch} cmp $a->{epoch}} grep { ! $_->{deleted} } @$tweets ];

}

sub _update_following_birds {
    my $self = shift;

    # こいつの中で$self->following_birdsを呼ぶと再帰が止まらなくなるぞ

    # BlockされてないかCheckして、Blockされていればfollowingから取り除いている
    # mapの中身の前半は"フォロー先のブロックリストに自分がいるかどうか"
#    return $self->{_following_birds} //= {};

    return $self->{_following_birds} =
        { map{ $self->{_following_birds}->{$_}->blocking_birds->{$self->{name}} ?
                   () : ($_ => $self->{_following_birds}->{$_}) } keys %{$self->{_following_birds}} } ;
}

1;
