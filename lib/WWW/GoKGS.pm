package WWW::GoKGS;
use 5.008_009;
use strict;
use warnings;
use Carp qw/croak/;
use LWP::UserAgent;
use URI;
use WWW::GoKGS::Scraper::GameArchives;
use WWW::GoKGS::Scraper::Top100;
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
        WWW::GoKGS::Scraper::GameArchives->new(
            user_agent  => $self->user_agent,
            date_filter => $self->date_filter,
        ),
        WWW::GoKGS::Scraper::Top100->new(
            user_agent => $self->user_agent,
        ),
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

sub game_archives {
    $_[0]->_scraper->{'/gameArchives.jsp'};
}

sub top_100 {
    $_[0]->_scraper->{'/top100.jsp'};
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

__END__

=head1 NAME

WWW::GoKGS - KGS Go Server (http://www.gokgs.com/) Scraper

=head1 SYNOPSIS

  use WWW::GoKGS;

  my $gokgs = WWW::GoKGS->new;

  # Game archives
  my $gameArchives1 = $gokgs->scrape( '/gameArchives.jsp?user=foo' );
  my $gameArchives2 = $gokgs->game_archives->query( user => 'foo' );

  # Top 100 players
  my $top100Players1 = $gokgs->scrape( '/top100.jsp' );
  my $top100Players2 = $gokgs->top_100->query;

  # List of tournaments 
  my $tournList1 = $gokgs->scrape( '/tournList.jsp?year=2014' );
  my $tournList2 = $gokgs->tourn_list->query( year => 2014 );

  # Information for the tournament
  my $tournInfo1 = $gokgs->scrape( '/tournInfo.jsp?id=123' );
  my $tournInfo2 = $gokgs->tourn_info->query( id => 123 );

  # Tournament entrants
  my $tournEntrants1 = $gokgs->scrape( '/tournEntrans.jsp?id=123&sort=n' );
  my $tournEntrants2 = $gokgs->tourn_entrants->query( id => 123, sort => 'n' );

  # Tournament games
  my $tournGames1 = $gokgs->scrape( '/tournGames.jsp?id=123&round=1' );
  my $tournGames2 = $gokgs->tourn_games->query( id => 123, round => 1 );

=head1 DESCRIPTION

This module is a KGS Go Server (C<http://www.gokgs.com/>) scraper.

This class maps a URI preceded by C<http://www.gokgs.com/>
to a proper scraper.
The supported resources on KGS are as follows:

=over 4

=item KGS Game Archives (http://www.gokgs.com/archives.jsp)

Handled by L<WWW::GoKGS::Scraper::GameArchives>.

=item Top 100 KGS Players (http://www.gokgs.com/top100.jsp)

Handled by L<WWW::GoKGS::Scraper::Top100>.

=item KGS Tournaments (http://www.gokgs.com/tournList.jsp)

Handled by L<WWW::GoKGS::Scraper::TournList>,
L<WWW::GoKGS::Scraper::TournInfo>,
L<WWW::GoKGS::Scraper::TournEntrants> and
L<WWW::GoKGS::Scraper::TournGames>.

=back

=head2 ATTRIBUTES

=over 4

=item $gokgs->user_agent

Returns an L<LWP::UserAgent> object which is used to C<GET> the requested
resource. This attribute is read-only.

  use LWP::UserAgent;

  my $user_agent = LWP::UserAgent->new(
      agent => 'MyAgent/1.00',
  );

  my $gokgs = WWW::GoKGS->new(
      user_agent => $user_agent,
  );

=item $gokgs->html_filter

Returns an HTML filter. Defaults to an anonymous subref which just returns
the given argument (C<sub { $_[0] }>). The callback is called with
an HTML string. The return value is used as the filtered value.
This attribute is read-only.

  my $gokgs = WWW::GoKGS->new(
      html_filter => sub {
          my $html = shift;
          $html =~ s/<.*?>//g; # strip HTML tags
          $html;
      },
  );

=item $gokgs->date_filter

Returns a date filter. Defaults to an anonymous subref which just returns
the given argument (C<sub { $_[0] }>). The callback is called with
a date string such as C<5/17/14 7:05 PM>. The return value is used as
the filtered value. This attribute is read-only.

  use Time::Piece qw/gmtime/;

  my $gokgs = WWW::GoKGS->new(
      date_filter => sub {
          my $date = shift; # => "5/17/14 7:05 PM"
          gmtime->strptime( $date, '%D %I:%M %p' );
      },
  );

=item $gokgs->game_archives

Returns a L<WWW::GoKGS::Scraper::GameArchives> object.
This attribute is read-only.

=item $gokgs->top_100

Returns a L<WWW::GoKGS::Scraper::Top100> object.
This attribute is read-only.

=item $gokgs->tourn_list

Returns a L<WWW::GoKGS::Scraper::TournList> object.
This attribute is read-only.

=item $gokgs->tourn_info

Returns a L<WWW::GoKGS::Scraper::TournInfo> object.
This attribute is read-only.

=item $gokgs->tourn_entrants

Returns a L<WWW::GoKGS::Scraper::TournEntrants> object.
This attribute is read-only.

=item $gokgs->tourn_games

Returns a L<WWW::GoKGS::Scraper::TournGames> object.
This attribute is read-only.

=back

=head2 METHODS

=over 4

=item $gokgs->scrape( '/gameArchives.jsp?user=foo' )

=item $gokgs->scrape( 'http://www.gokgs.com/gameArchives.jsp?user=foo' )

A shortcut for:

  my $uri = URI->new( 'http://www.gokgs.com/gameArchives.jsp?user=foo' );
  my $gameArchives = $gokgs->game_archives->scrape( $uri );

See L<WWW::GoKGS::Scraper::GameArchives> for details.

=item $gokgs->scrape( '/top100.jsp' )

=item $gokgs->scrape( 'http://www.gokgs.com/top100.jsp' )

A shortcut for:

  my $uri = URI->new( 'http://www.gokgs.com/top100.jsp' );
  my $top100 = $gokgs->top_100->scrape( $uri );

See L<WWW::GoKGS::Scraper::Top100> for details.

=item $gokgs->scrape( '/tournList.jsp?year=2014' )

=item $gokgs->scrape( 'http://www.gokgs.com/tournList.jsp?year=2014' )

A shortcut for:

  my $uri = URI->new( 'http://www.gokgs.com/tournList.jsp?year=2014' );
  my $tournList = $gokgs->tourn_list->scrape( $uri );

See L<WWW::GoKGS::Scraper::TournList> for details.

=item $gokgs->scrape( '/tournInfo.jsp?id=123' )

=item $gokgs->scrape( 'http://www.gokgs.com/tournInfo.jsp?id=123' )

A shortcut for:

  my $uri = URI->new( 'http://www.gokgs.com/tournInfo.jsp?id=123' );
  my $tournInfo = $gokgs->tourn_info->scrape( $uri );

See L<WWW::GoKGS::Scraper::TournInfo> for details.

=item $gokgs->scrape( '/tournEntrants.jsp?id=123&s=n' )

=item $gokgs->scrape( 'http://www.gokgs.com/tournEntrants.jsp?id=123&s=n' )

A shortcut for:

  my $uri = URI->new( 'http://www.gokgs.com/tournEntrants.jsp?id=123&s=n' );
  my $tournEntrants = $gokgs->tourn_entrants->scrape( $uri );

See L<WWW::GoKGS::Scraper::TournEntrants> for details.

=item $gokgs->scrape( '/tournGames.jsp?id=123&round=1' )

=item $gokgs->scrape( 'http://www.gokgs.com/tournGames.jsp?id=123&round=1' )

A shortcut for:

  my $uri = URI->new( 'http://www.gokgs.com/tournGames.jsp?id=123&round=1' );
  my $tournGames = $gokgs->tourn_games->scrape( $uri );

See L<WWW::GoKGS::Scraper::TournGames> for details.

=back

=head1 SEE ALSO

L<Web::Scraper>

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
