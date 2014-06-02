package WWW::GoKGS::Scraper::TournList;
use strict;
use warnings;
use parent qw/WWW::GoKGS::Scraper/;
use URI;
use Web::Scraper;

sub _build_base_uri {
    URI->new('http://www.gokgs.com/tournList.jsp');
}

sub _build_scraper {
    my $self = shift;

    my %tournament = (
        name => 'TEXT',
        uri  => '@href',
    );

    my %year_index = (
        year => 'TEXT',
        uri  => '@href',
    );

    scraper {
        process '//a[starts-with(@href, "tournInfo.jsp")]',
                'tournaments[]' => \%tournament;
        process '//a[starts-with(@href, "tournList.jsp")]',
                'year_index[]' => \%year_index;
        process '//p[preceding-sibling::h2/text()="Year Index"]',
                '_years' => 'TEXT';
    };
}

sub scrape {
    my ( $self, @args ) = @_;
    my $result = $self->SUPER::scrape( @args );
    my $year_index = $result->{year_index};

    my @years = do {
       my $_years = delete $result->{_years};
       $_years =~ s/ $//;
       split / /, $_years;
    };

    for my $i ( 0 .. @years-1 ) {
        next if $year_index->[$i] and $year_index->[$i]->{year} eq $years[$i];
        splice @$year_index, $i, 0, { year => $years[$i], uri => undef };
        last;
    }

    $result;
}

1;

__END__

=head1 NAME

WWW::GoKGS::Scraper::TournList - List of KGS tournaments

=head1 SYNOPSIS

  use WWW::GoKGS::Scraper::TournList;

  my $tourn_list = WWW::GoKGS::Scraper::TournList->new;

  my $result = $tourn_list->query(
      year => 2012,
  );
  # => {
  #     tournaments => [
  #         {
  #             name => 'KGS Meijin Qualifier October 2012',
  #             uri  => 'http://www.gokgs.com/tournInfo.jsp?id=762',
  #         },
  #         ...
  #     ],
  #     year_index => [
  #         {
  #             year => '2001',
  #             uri  => 'http://www.gokgs.com/tournList.jsp?year=2001',
  #         },
  #         ...
  #     ]
  # }

=head1 DESCRIPTION

This class inherits from L<WWW::GoKGS::Scraper>.

=head2 ATTRIBUTES

=over 4

=item $URI = $tourn_list->base_uri

Defaults to C<http://www.gokgs.com/tournList.jsp>.
This attribute is read-only.

=item $UserAgent = $tourn_list->user_agent

=item $tourn_list->user_agent( LWP::UserAgent->new(...) )

Can be used to get or set an L<LWP::UserAgent> object which is used to
C<GET> the requested resource. Defaults to the C<LWP::UserAgent> object
shared by L<Web::Scraper> users (C<$Web::Scraper::UserAgent>).

=back

=head2 METHODS

=over 4

=item $tourn_list->scrape

=item $tourn_list->query

=back

=head1 SEE ALSO

L<WWW::GoKGS>

=head1 AUTHOR

Ryo Anazawa (anazawa@cpan.org)

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
