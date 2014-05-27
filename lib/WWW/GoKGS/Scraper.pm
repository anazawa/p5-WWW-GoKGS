package WWW::GoKGS::Scraper;
use strict;
use warnings;
use Carp qw/croak/;

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{$_[0]} : @_;
    bless \%args, $class;
}

sub base_uri {
    my $self = shift;
    return $self->{base_uri} if exists $self->{base_uri};
    $self->{base_uri} = $self->_build_base_uri;
}

sub _build_base_uri {
    croak 'call to abstract method ', __PACKAGE__, '::base_uri';
}

sub _scraper {
    my $self = shift;
    $self->{scraper} ||= $self->_build_scraper;
}

sub _build_scraper {
    croak 'call to abstract method ', __PACKAGE__, '::_build_scraper';
}

sub user_agent {
    my ( $self, @args ) = @_;
    $self->_scraper->user_agent( @args );
}

sub scrape {
    my ( $self, @args ) = @_;
    $self->_scraper->scrape( @args );
}

sub query {
    my ( $self, @args ) = @_;
    my $url = $self->base_uri->clone;
    $url->query_form( @args );
    $self->scrape( $url );
}

1;
