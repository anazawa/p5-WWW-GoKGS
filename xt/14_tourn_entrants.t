use strict;
use warnings;
use xt::Util qw/:cmp_deeply/;
use Encode qw/decode_utf8/;
use Test::Base;
use WWW::GoKGS;

spec_file 'xt/14_tourn_entrants.spec';

plan skip_all => 'AUTHOR_TESTING is required' unless $ENV{AUTHOR_TESTING};
plan tests => 1 * blocks;

my $gokgs = WWW::GoKGS->new( from => 'anazawa@cpan.org' );
   $gokgs->user_agent->delay( 1/60 );

my $expected = hash(
    name => sub { defined },
    entrants => array_of_hashes(
        position => [ integer(), sub { $_[0] >= 1 } ],
        name => user_name(),
        rank => user_rank(),
        standing => sub { defined },
        score => [ real(), sub { $_[0] >= 0 } ],
        sos => [ real(), sub { $_[0] >= 0 } ],
        sodos => [ real(), sub { $_[0] >= 0 } ],
        notes => sub { defined },
    ),
    links => hash(
        rounds => array_of_hashes(
            round => [ integer(), sub { $_[0] >= 1 } ],
            start_time => datetime( '%Y-%m-%dT%H:%MZ' ),
            end_time => datetime( '%Y-%m-%dT%H:%MZ' ),
            uri => [ uri(), sub { $_[0]->path eq '/tournGames.jsp' } ],
        ),
    ),
);

run {
    my $block = shift;
    my $got = $gokgs->tourn_entrants->scrape( $block->input );
    is_deeply $got, $block->expected if defined $block->expected;
    cmp_deeply $got, $expected unless defined $block->expected;
};

sub build_uri {
    $gokgs->tourn_entrants->build_uri( @_ );
}

sub html {
    ( @_, $gokgs->tourn_entrants->build_uri );
}
