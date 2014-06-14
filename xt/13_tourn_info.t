use strict;
use warnings;
use xt::Util qw/:cmp_deeply/;
use Test::More;
use WWW::GoKGS::Scraper::TournInfo;

plan skip_all => 'AUTHOR_TESTING is required' unless $ENV{AUTHOR_TESTING};

my $tourn_info = WWW::GoKGS::Scraper::TournInfo->new;
my $got = $tourn_info->query( id => 885 );

cmp_deeply $got, hash(
    name => sub { defined },
    description => sub { defined },
    links => hash(
        rounds => array(hash(
            round => [ integer(), sub { $_[0] >= 1 } ],
            start_time => datetime( '%Y-%m-%dT%H:%MZ' ),
            end_time => datetime( '%Y-%m-%dT%H:%MZ' ),
            uri => [ uri(), sub { $_[0]->path eq '/tournGames.jsp' } ],
        )),
    ),
);

done_testing;
