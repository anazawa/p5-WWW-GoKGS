package WWW::GoKGS::Scraper::TournInfo;
use strict;
use warnings;
use parent qw/WWW::GoKGS::Scraper/;
use URI;
use Web::Scraper;
use WWW::GoKGS::Scraper::TournLinks qw/process_links/;

sub _build_base_uri {
    URI->new('http://www.gokgs.com/tournInfo.jsp');
}

sub _build_scraper {
    my $self = shift;
    my $name = sub { s/ \([^)]+\)$// };
    my $state = sub { m/ \((Not started yet|Aborted)\)$/ ? $1 : q{} };

    my $winners = sub {
        m/ \((?:Winner|Tie; winners): ([^)]+)\)$/
            ? [ split /, /, $1 ]
            : undef;
    };

    scraper {
        process '//h1', 'name' => [ 'TEXT', $name ];
        process '//h1', 'winners' => [ 'TEXT', $winners ];
        process '//h1', 'state' => [ 'TEXT', $state ];
        process '//node()[preceding-sibling::h1 and following-sibling::div]',
                'description[]' => sub { $_[0]->as_XML };
        process_links date_filter => $self->date_filter;
    };
}

sub html_filter {
    my $self = shift;
    $self->{html_filter} = shift if @_;
    $self->{html_filter} ||= sub { $_[0] };
}

sub date_filter {
    my $self = shift;
    $self->{date_filter} = shift if @_;
    $self->{date_filter} ||= sub { $_[0] };
}

sub scrape {
    my ( $self, @args ) = @_;
    my $result = $self->SUPER::scrape( @args );

    $result->{description} = $self->html_filter->(do {
        join q{}, @{ $result->{description} || [] };
    });

    $result;
}

1;

__END__

=head1 NAME

WWW::KGS::Tournaments::Info - Information for the tournament

=head1 SYNOPSIS

  use WWW::KGS::Tournaments::Info;

  my $info = WWW::KGS::Tournaments::Info->new;

  my $result = $info->query(
      id => 762,
  );
  # => {
  #     name => 'KGS Meijin Qualifier October 2012',
  #     description => 'Welcome to the KGS Meijin October Qualifier! ...',
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

Defaults to C<http://www.gokgs.com/tournInfo.jsp>.

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
