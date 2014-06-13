use strict;
use warnings;
use xt::Util qw/:cmp_deeply/;
use Test::More;
use WWW::GoKGS::Scraper::GameArchives;

plan skip_all => 'AUTHOR_TESTING is required' unless $ENV{AUTHOR_TESTING};

my $game_archives = WWW::GoKGS::Scraper::GameArchives->new;

my $got = $game_archives->query(
    user  => 'anazawa',
    year  => '2014',
    month => '5',
    oldAccounts => 'y',
);

my %user = (
    name => sub { /^[a-zA-Z][a-zA-Z0-9]{0,9}$/ },
    rank => sub { /^(?:[1-9](?:p|d\??|k\??)|[12][0-9]k\??|30k\??)$/ },
    uri => [ uri(), sub { $_[0]->path eq '/gameArchives.jsp' } ],
);

cmp_deeply($got, {
    games => array({
        sgf_uri => [ uri(), sub { $_[0]->path =~ /\.sgf$/ } ],
        owner => \%user,
        white => array( \%user ),
        black => array( \%user ),
        start_time => sub { /^\d\d\d\d-\d\d-\d\dT\d\d:\d\dZ$/ },
        result => sub { /^(?:Unfinished|(?:B|W)\+(?:\d+(?:\.5)?|Resign|Forfeit|Time)|Draw)$/ },
        handicap => [ integer(), sub { $_[0] >= 2 } ],
    }),
    tgz_uri => [ uri(), sub { $_[0]->path =~ /\.tar\.gz$/ } ],
    zip_uri => [ uri(), sub { $_[0]->path =~ /\.zip$/ } ],
});

done_testing;

