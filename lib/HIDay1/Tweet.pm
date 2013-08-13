package HIDay1::Tweet;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;

    # authorはHIDay1::BirdオブジェクトではなくただのStr
    # epochはHiResだと嬉しいけどTweetレベルでは関知していない
    return bless {
        author => '',
        body => '',
        epoch => '',
        deleted => 0,
        %args
    }, $class;
}

sub message {
    my $self = shift;

    # deletedなら本文が帰ってこない
    return $self->{deleted} ? '' : ( $self->{_message} //= $self->{author}.': '.$self->{body} );
}

sub author {
    my $self = shift;

    return $self->{author};
}

sub body {
    my $self = shift;

    return $self->{body};
}

sub epoch {
    my $self = shift;

    return $self->{epoch};
}

sub deleted {
    my $self = shift;

    return $self->{deleted};
}

# Setter
sub delete {
    my $self = shift;

    if( $self->{deleted} ) { return 'Already deleted.'; }
    else { $self->{deleted} = 1; return 0; }

}

1;
