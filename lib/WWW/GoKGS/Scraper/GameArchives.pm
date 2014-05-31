package WWW::GoKGS::Scraper::GameArchives;
use strict;
use warnings;
use parent qw/WWW::GoKGS::Scraper/;
use URI;
use Web::Scraper;

sub _build_base_uri {
    URI->new('http://www.gokgs.com/gameArchives.jsp');
}

sub _build_scraper {
    my $self = shift;

    my %player = (
        name => [ 'TEXT', sub { s/ \[[^\]]+\]$// } ],
        rank => [ 'TEXT', sub { m/ \[([^\]]+)\]$/ ? $1 : undef } ],
        link => '@href',
    );

    my $game = scraper {
        process '//a[contains(@href, ".sgf")]', 'kifu_uri' => '@href';
        process '//td[2]//a', 'white[]' => \%player;
        process '//td[3]//a', 'black[]' => \%player;
        process '//td[3]', 'maybe_setup' => 'TEXT';
        process '//td[4]', 'setup' => 'TEXT';
        process '//td[5]', 'start_time' => 'TEXT';
        process '//td[6]', 'type' => 'TEXT';
        process '//td[7]', 'result' => 'TEXT';
        process '//td[8]', 'tag' => 'TEXT';
    };

    my $calendar = scraper {
        process 'td', 'year' => 'TEXT';
        process qq{//following-sibling::td[text()!="\x{a0}"]},
                'month[]' => scraper {
                    process '.', 'name' => 'TEXT';
                    process 'a', 'link' => '@href'; };
    };

    scraper {
        process 'h2', 'summary' => 'TEXT';
        process '//table[tr/th/text()="Viewable?"]//following-sibling::tr',
                'games[]' => $game;
        process '//a[contains(@href, ".zip")]', 'zip_uri' => '@href';
        process '//a[contains(@href, ".tar.gz")]', 'tgz_uri' => '@href';
        process '//table[descendant::tr/th/text()="Year"]//following-sibling::tr',
                'calendar[]' => $calendar;
    };
}

sub date_filter {
    my $self = shift;
    $self->{date_filter} = shift if @_;
    $self->{date_filter} ||= sub { $_[0] };
}

sub scrape {
    my $self     = shift;
    my $result   = $self->SUPER::scrape( @_ );
    my $games    = $result->{games};
    my $calendar = $result->{calendar};

    return $result unless $calendar;

    my @calendar;
    for my $c ( @$calendar ) {
        for my $month ( @{$c->{month}} ) {
            $month->{year}  = $c->{year};
            $month->{month} = delete $month->{name}; # rename
            push @calendar, $month;
        }
    }

    if ( @calendar == 1 and $calendar[0]{year} == 1970 ) { # KGS's bug
        delete $result->{calendar};
    }
    else {
        $result->{calendar} = \@calendar;
    }

    return $result unless $games;

    for my $game ( @$games ) {
        my $maybe_setup = delete $game->{maybe_setup};
        next if exists $game->{black};
        my $users = delete $game->{white}; # <td colspan="2">
        if ( @$users == 1 ) { # Type: Demonstration
            $game->{owner} = $users->[0];
        }
        elsif ( @$users == 3 ) { # Type: Review
            $game->{owner} = $users->[0];
            $game->{white} = [ $users->[1] ];
            $game->{black} = [ $users->[2] ];
        }
        elsif ( @$users == 5 ) { # Type: Rengo Review
            $game->{owner} = $users->[0];
            $game->{white} = [ @{$users}[1,2] ];
            $game->{black} = [ @{$users}[3,4] ];
        }
        $game->{tag}        = delete $game->{result} if exists $game->{result};
        $game->{result}     = delete $game->{type};
        $game->{type}       = delete $game->{start_time};
        $game->{start_time} = delete $game->{setup};
        $game->{setup}      = $maybe_setup;
    }
    continue {
        $game->{setup} =~ /^(\d+)\x{d7}\d+ (?:H(\d+))?$/;
        $game->{board_size} = $1;
        $game->{handicap} = $2;
        $game->{start_time} = $self->date_filter->( $game->{start_time} );
        delete $game->{setup};
    }

    @$games = reverse @$games; # sort by Start Time in descending order

    $result;
}

1;

__END__

=head1 NAME

WWW::KGS::GameArchives - Interface to KGS Go Server Game Archives

=head1 SYNOPSIS

  use WWW::KGS::GameArchives;
  my $archives = WWW::KGS::GameArchives->new;
  my $result = $archives->query( user => 'YourAccount' );

=head1 DESCRIPTION

L<KGS|http://www.gokgs.com/> Game Archives
preserves Go games played by the users. You can search games by filling
in the HTML forms. The search result is provided as an HTML document naturally.

This module provides yet another interface to send a query to the archives,
and also parses the result into a neatly arranged Perl data structure.

=head2 DISCLAIMER

According to KGS's C<robots.txt>, bots are not allowed to crawl 
the Game Archives:

  User-agent: *
  Disallow: /gameArchives.jsp

Although this module can be used to implement crawlers,
the author doesn't intend to violate their policy.
Use at your own risk.

=head2 ATTRIBUTES

=over 4

=item base_uri

Defaults to C<http://www.gokgs.com/gameArchives.jsp>.
The value is used to create a request URI by C<query> method.
The request URI is passed to C<scrape> method.

=item user_agent

This attribute is used to construct a L<Web::Scraper> object
if a value is set.

=back

=head2 METHODS

=over 4

=item $result = $archives->query( user => 'YourAccount', ... )

Given key-value pairs of query parameters, returns a hash reference
which represnets the result.

  my $result = $archives->query(
      user        => 'foo',
      year        => '2013',
      month       => '7',
      oldAccounts => 'y',
      tags        => 't',
  );

The hashref is formatted as follows:

  $result;
  # => {
  #     summary => 'Games of KGS player foo, ...',
  #     games => [ # sorted by "start_time" in descending order
  #         {
  #             white => [
  #                 {
  #                     name => 'foo [4k]',
  #                     link => 'http://...&user=foo...'
  #                 }
  #             ],
  #             black => [
  #                 {
  #                     name => 'bar [6k]',
  #                     link => 'http://...&user=bar...'
  #                 }
  #             ],
  #             setup => '19x19 H2',
  #             start_time => '7/4/13 5:32 AM', # GMT
  #             type => 'Ranked',
  #             result => 'W+Res.'
  #             kifu_uri => 'http://.../games/2013/7/foo-bar.sgf',
  #         },
  #         ...
  #     ],
  #     zip_uri => 'http://.../foo-2013-7.zip',    # contains SGF files
  #     tgz_uri => 'http://.../foo-2013-7.tar.gz', # created in July 2013
  #     calendar => [
  #         {
  #             year  => '2011',
  #             month => 'Jul',
  #             link  => 'http://...&year=2011&month=7...',
  #         },
  #         ...
  #     ]
  # }

The possible parameters are as follows:

=over 4

=item user (required)

Represents a KGS username.

  my $result = $archives->query( user => 'foo' );

=item year, month

Can be used to search games played in the specified month.

  my $result = $archives->query(
      user  => 'foo',
      year  => '2013',
      month => '7',
  );

=item oldAccounts

Can be used to search games played by expired and guest accounts.

  my $result = $archives->query(
      user        => 'foo',
      oldAccounts => 'y'
  );

=item tags

Can be used to search games tagged by the specified C<user>.

  my $result = $archives->query(
      user => 'foo',
      tags => 't'
  );

=back

=item $result = $archives->scrape( $stuff )

The given arguments are passed to L<Web::Scraper>'s C<scrape> method.
C<query> method is just a wrapper of this method. For example,
you can pass URIs included by the return value of C<query> method.

=back

=head1 FILTERING VALUES

This module doesn't modify the values of C<$result> at all.
Use L<Moo>'s or L<Mouse>'s C<coerce> to filter values.
See C<examples/>.

=head1 SEE ALSO

L<Web::Scraper>

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
