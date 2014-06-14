use strict;
use warnings;
use xt::Util qw/:cmp_deeply/;
use Test::More tests => 1;
use WWW::GoKGS::Scraper::TournList;

plan skip_all => 'AUTHOR_TESTING is required' unless $ENV{AUTHOR_TESTING};

my $tourn_list = WWW::GoKGS::Scraper::TournList->new;
my $got = $tourn_list->query;

cmp_deeply $got, hash(
    tournaments => array(hash(
        name => sub { defined },
        uri => [ uri(), sub { $_[0]->path eq '/tournInfo.jsp' } ],
    )),
    year_index => array(hash(
        year => [ integer(), sub { $_[0] >= 2001 } ],
        uri => [ uri(), sub { $_[0]->path eq '/tournList.jsp' } ],
    )),
);
