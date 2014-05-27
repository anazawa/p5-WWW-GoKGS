package WWW::GoKGS::Scraper::TournGames;
use strict;
use warnings;
use parent qw/WWW::GoKGS::Scraper/;
use URI;
use Web::Scraper;
use WWW::GoKGS::Scraper::TournLinks qw/process_links/;

sub _build_base_uri {
    URI->new('http://www.gokgs.com/tournGames.jsp');
}

sub date_filter {
    my $self = shift;
    $self->{date_filter} = shift if @_;
    $self->{date_filter} ||= sub { $_[0] };
}

sub _build_scraper {
    my $self = shift;

    my $game = scraper {
        process '//td[1]/a', 'kifu_uri' => '@href';
        process '//td[2]', 'white' => [ 'TEXT', \&_player ];
        process '//td[3]', 'black' => [ 'TEXT', \&_player ];
        process '//td[3]', 'maybe_result' => 'TEXT';
        process '//td[4]', 'board_size' => [ 'TEXT', \&_board_size ];
        process '//td[4]', 'handicap' => [ 'TEXT', \&_handicap ];
        process '//td[5]', 'start_time' => [ 'TEXT', $self->date_filter ];
        process '//td[6]', 'result' => 'TEXT';
    };

    scraper {
        process '//h1', 'name' => [ 'TEXT', \&_name ];
        process '//h1', 'round' => [ 'TEXT', \&_round ];
        process '//table[@class="grid"]//a[@href="tzList.jsp"]',
                'time_zone' => 'TEXT';
        process '//table[@class="grid"]//following-sibling::tr',
                'games[]' => $game;
        process '//a[text()="Previous round"]', 'previous_round' => '@href';
        process '//a[text()="Next round"]', 'next_round' => '@href';
        process_links date_filter => $self->date_filter;
    };
}

sub scrape {
    my ( $self, @args ) = @_;
    my $result = $self->SUPER::scrape( @args );

    for my $game ( @{ $result->{games} || [] } ) {
        my $maybe_result = delete $game->{maybe_result};
        next if $game->{start_time};
        next unless $maybe_result =~ /^Bye(?: \((?:No show|Requested)\))?$/;
        $game->{result} = $maybe_result;
        $game->{black} = [];
    }

    $result;
}

sub _name {
    s/ Round \d+ Games$//;
}

sub _round {
    m/ Round (\d+) Games$/ && $1;
}

sub _player {
    m/^([a-zA-Z0-9]+)(?: \[([^\]]+)\])?$/ && [{ name => $1, rank => $2 }];
}

sub _board_size {
    m/^(\d+)\x{d7}\d+ / && $1;
}

sub _handicap {
    m/ H(\d+)$/ ? $1 : undef;
}

1;

__END__

=head1 NAME

WWW::KGS::Tournaments::Games - Games of the tournament

=head1 SYNOPSIS

  use WWW::KGS::Tournaments::Games;

  my $games = WWW::KGS::Tournaments::Games->new;

  my $result = $games->query(
      id    => 762,
      round => 1,
  );
  # => {
  #     name => 'KGS Meijin Qualifier October 2012',
  #     round => 1,
  #     time_zone => 'GMT',
  #     games => [
  #         {
  #             kifu_uri => 'http://files.gokgs.com/.../foo-bar.sgf',
  #             board_size => 19,
  #             white => [{
  #                 name => 'foo',
  #                 rank => '2k',
  #             }],
  #             black => [{
  #                 name => 'bar',
  #                 rank => '2k',
  #             }],
  #         },
  #     ],
  #     links => {
  #         time_zone => 'GMT',
  #         entrants => [
  #             {
  #                 sort_by => 'name',
  #                 link => 'tournEntrants.jsp?id=762&sort=n',
  #             },
  #             ...
  #         ],
  #         rounds => [
  #             {
  #                 round => 1,
  #                 start_time => '10/27/12 4:05 PM',
  #                 end_time => '10/27/12 6:35 PM',
  #                 link => 'tournGames.jsp?id=762&round=1',
  #             },
  #             ...
  #         ],
  #     },
  # }

=head1 DESCRIPTION

This class inherits from L<WWW::KGS::Tournaments>.

=head2 ATTRIBUTES

=over 4

=item base_uri

Defaults to C<http://www.gokgs.com/tournGames.jsp>.

=item user_agent

=back

=head2 METHODS

=over 4

=item scrape

=item query

=back

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
