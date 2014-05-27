package WWW::GoKGS;
use 5.008_009;
use strict;
use warnings;
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
    my $self = shift;
    $self->{date_filter} = shift if @_;
    $self->{date_filter} ||= sub { $_[0] };
}

sub html_filter {
    my $self = shift;
    $self->{html_filter} = shift if @_;
    $self->{html_filter} ||= sub { $_[0] };
}

sub tourn_list {
    my $self = shift;
    $self->{tourn_list} ||= WWW::GoKGS::Scraper::TournList->new;
}

sub tourn_info {
    my $self = shift;
    $self->{tourn_info} ||= $self->_build_tourn_info;
}

sub _build_tourn_info {
    my $self = shift;

    WWW::GoKGS::Scraper::TournInfo->new(
        date_filter => sub { $self->date_filter->(@_) },
        html_filter => sub { $self->html_filter->(@_) },
    );
}

sub tourn_entrants {
    my $self = shift;
    $self->{tourn_entrants} ||= $self->_build_tourn_entrants;
}

sub _build_tourn_entrants {
    my $self = shift;

    WWW::GoKGS::Scraper::TournEntrants->new(
        date_filter => sub { $self->date_filter->(@_) },
    );
}

sub tourn_games {
    my $self = shift;
    $self->{tourn_games} ||= $self->_build_tourn_games;
}

sub _build_tourn_games {
    my $self = shift;

    WWW::GoKGS::Scraper::TournGames->new(
        date_filter => sub { $self->date_filter->(@_) },
    );
}

1;
