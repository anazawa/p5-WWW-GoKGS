package WWW::GoKGS;
use 5.008_009;
use strict;
use warnings;
use Carp qw/croak/;
use LWP::UserAgent;
use URI;
use WWW::GoKGS::Scraper::TournEntrants;
use WWW::GoKGS::Scraper::TournGames;
use WWW::GoKGS::Scraper::TournInfo;
use WWW::GoKGS::Scraper::TournList;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{$_[0]} : @_;
    bless \%args, $class;
}

sub date_filter {
    $_[0]->{date_filter} ||= sub { $_[0] };
}

sub html_filter {
    $_[0]->{html_filter} ||= sub { $_[0] };
}

sub user_agent {
    my $self = shift;
    $self->{user_agent} ||= $self->_build_user_agent;
}

sub _build_user_agent {
    my $self = shift;

    LWP::UserAgent->new(
        agent => ref $self . '/' . $self->VERSION,
    );
}

sub _scraper {
    my $self = shift;
    $self->{scraper} ||= $self->_build_scraper;
}

sub _build_scraper {
    my $self = shift;

    +{ map { $_->base_uri->path => $_ } (
        WWW::GoKGS::Scraper::TournList->new(
            user_agent => $self->user_agent,
        ),
        WWW::GoKGS::Scraper::TournInfo->new(
            user_agent  => $self->user_agent,
            date_filter => $self->date_filter,
            html_filter => $self->html_filter,
        ),
        WWW::GoKGS::Scraper::TournEntrants->new(
            user_agent  => $self->user_agent,
            date_filter => $self->date_filter,
        ),
        WWW::GoKGS::Scraper::TournGames->new(
            user_agent  => $self->user_agent,
            date_filter => $self->date_filter,
        ),
    )};
}

sub tourn_list {
    $_[0]->_scraper->{'/tournList.jsp'};
}

sub tourn_info {
    $_[0]->_scraper->{'/tournInfo.jsp'};
}

sub tourn_entrants {
    $_[0]->_scraper->{'/tournEntrants.jsp'};
}

sub tourn_games {
    $_[0]->_scraper->{'/tournGames.jsp'};
}

sub scrape {
    my $self = shift;
    my $stuff = defined $_[0] ? shift : q{};

    my $url = URI->new( $stuff );
       $url->authority( 'www.gokgs.com' ) unless $url->authority;
       $url->scheme( 'http' ) unless $url->scheme;

    my $scraper = $url =~ m{^https?://www\.gokgs\.com/} && $url->path;
       $scraper = $self->_scraper->{$scraper} if $scraper;

    croak "Don't know how to scrape '$stuff'" unless $scraper;

    $scraper->scrape( $url );
}

1;
