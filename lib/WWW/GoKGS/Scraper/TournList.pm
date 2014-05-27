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

    scraper {
        process '//p[starts-with(a/@href, "tournInfo.jsp")]',
                'tournaments[]' => scraper {
                    process '.', name => [ 'TEXT', \&_name ];
                    process '.', winners => [ 'TEXT', \&_winners ];
                    process '.', state => [ 'TEXT', \&_state ];
                    process 'a', link => '@href'; };
        process '//a[starts-with(@href, "tournList.jsp")]',
                'year_index[]' => { year => 'TEXT', link => '@href' };
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
        splice @$year_index, $i, 0, { year => $years[$i] };
        last;
    }

    $result;
}

sub _name {
    s/ \([^)]+\)$//;
}

sub _winners {
    m/ \((?:Winner|Tie; winners): ([^)]+)\)$/ ? [ split /, /, $1 ] : undef;
}

sub _state {
    m/ \((Not started yet|Aborted)\)$/ ? $1 : undef;
}

1;

__END__

=head1 NAME

WWW::KGS::Tournaments::List - List of tournaments

=head1 SYNOPSIS

  use WWW::KGS::Tournaments::List;

  my $list = WWW::KGS::Tournaments::List->new;

  my $result = $list->query(
      year => 2012,
  );
  # => {
  #     tournaments => [
  #         ...
  #         {
  #             name => 'KGS Meijin Qualifier October 2012',
  #             link => 'tournInfo.jsp?id=762',
  #             ...
  #         },
  #         ...
  #     ],
  #     year_index => [
  #         {
  #             year => 2001,
  #             link => 'tournList.jsp?year=2001',
  #         },
  #         ...
  #     ],
  # }

=head1 DESCRIPTION

This class inherits from L<WWW::KGS::Tournaments>.

=head2 ATTRIBUTES

=over 4

=item base_uri

Defaults to C<http://www.gokgs.com/tournList.jsp>.

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
