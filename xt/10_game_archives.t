use strict;
use warnings;
use xt::Util qw/:cmp_deeply/;
use Path::Class qw/file/;
use Test::More;
use WWW::GoKGS::Scraper::GameArchives;

if ( $ENV{AUTHOR_TESTING} ) {
    plan tests => 2;
}
else {
    plan skip_all => 'AUTHOR_TESTING is required';
}

subtest 'relaxed' => sub {
    my $game_archives = WWW::GoKGS::Scraper::GameArchives->new;
    my $got = $game_archives->query( user => 'anazawa' );

    my $user = hash(
        name => user_name(),
        rank => user_rank(),
        uri => [ uri(), sub { $_[0]->path eq '/gameArchives.jsp' } ],
    );

    my $type = sub {
        +{ map {( $_ => 1 )} (
            'Ranked',
            'Teaching',
            'Simul',
            'Rengo',
            'Rengo Review',
            'Review',
            'Demonstration',
            'Tournament',
            'Free',
        )}->{$_[0]};
    };

    my $expected = hash(
        games => array(hash(
            sgf_uri => [ uri(), sub { $_[0]->path =~ /\.sgf$/ } ],
            owner => $user,
            white => array( $user ),
            black => array( $user ),
            board_size => [ integer(), sub { $_[0] >= 2 && $_[0] <= 38 } ],
            handicap => [ integer(), sub { $_[0] >= 2 } ],
            start_time => datetime( '%Y-%m-%dT%H:%MZ' ),
            type => $type,
            result => game_result(),
        )),
        tgz_uri => [ uri(), sub { $_[0]->path =~ /\.tar\.gz$/ } ],
        zip_uri => [ uri(), sub { $_[0]->path =~ /\.zip$/ } ],
        calendar => array(hash(
            year => [ integer(), sub { $_[0] >= 1999 } ],
            month => [ integer(), sub { $_[0] >= 1 && $_[0] <= 12 } ],
            uri => [ uri(), sub { $_[0]->path eq '/gameArchives.jsp' } ],
        )),
    );

    cmp_deeply $got, $expected, 'user=anazawa';
};

subtest 'paranoid' => sub {
    my $game_archives = WWW::GoKGS::Scraper::GameArchives->new;

    my $got = $game_archives->query(
        user => 'anazawa',
        year => 2014,
        month => 5,
    );

    {
        my $expected = do +file(
            'xt',
            'data',
            'GameArchives',
            '20140615-user-anazawa-year-2014-month-5.pl',
        );

        is_deeply $got->{games}, $expected->{games}, '$hash->{games}';
        is $got->{tgz_uri}, $expected->{tgz_uri}, '$hash->{tgz_uri}';
        is $got->{zip_uri}, $expected->{zip_uri}, '$hash->{zip_uri}';
    }

    isa_ok $got->{calendar}, 'ARRAY', '$hash->{calendar}';

    my $i = 0;
    for my $calendar ( @{$got->{calendar}} ) {
        my $name = "\$hash->{calendar}->[$i]";

        isa_ok $calendar, 'HASH', $name;

        if ( exists $calendar->{uri} ) {
            isa_ok $calendar->{uri}, 'URI', "$name\->{uri}";
        }
        else {
            is $calendar->{year}, 2014, "$name\->{year}";
            is $calendar->{month}, 5, "$name\->{month}";
            next;
        }

        my %got = $calendar->{uri}->query_form;

        my %expected = (
            user => 'anazawa',
            year => $calendar->{year},
            month => $calendar->{month},
        );

        is_deeply \%got, \%expected, "$name\->{uri}->query_form";
    }
    continue {
        $i++;
    }
};
