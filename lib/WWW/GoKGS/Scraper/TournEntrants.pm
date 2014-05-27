package WWW::GoKGS::Scraper::TournEntrants;
use strict;
use warnings;
use parent qw/WWW::GoKGS::Scraper/;
use URI;
use Web::Scraper;
use WWW::GoKGS::Scraper::TournLinks qw/process_links/;

sub _build_base_uri {
    URI->new('http://www.gokgs.com/tournEntrants.jsp');
}

sub date_filter {
    my $self = shift;
    $self->{date_filter} = shift if @_;
    $self->{date_filter} ||= sub { $_[0] };
}

sub _build_scraper {
    my $self = shift;

    scraper {
        process '//h1', 'name' => [ 'TEXT', sub { s/ Players$// } ];
        process '//table[tr/th[1]/text()="Position"]//following-sibling::tr',
                'entrants[]' => scraper {
                    process '//td[1]', 'position' => 'TEXT';
                    process '//td[2]', 'name' => [ 'TEXT', \&_name ];
                    process '//td[2]', 'rank' => [ 'TEXT', \&_rank ];
                    process '//td[3]', 'score' => 'TEXT';
                    process '//td[4]', 'sos' => 'TEXT';
                    process '//td[5]', 'sodos' => 'TEXT';
                    process '//td[6]', 'notes' => 'TEXT'; };
        process '//table[tr/th[1]/text()="Name"]//following-sibling::tr',
                'entrants[]' => scraper {
                    process '//td[1]', 'name' => [ 'TEXT', \&_name ];
                    process '//td[1]', 'rank' => [ 'TEXT', \&_rank ];
                    process '//td[2]', 'standing' => 'TEXT'; };
        process_links date_filter => $self->date_filter;
    };
}

sub scrape {
    my ( $self, @args ) = @_;
    my $result = $self->SUPER::scrape( @args );
    my $entrants = $result->{entrants} || [];

    return $result if @$entrants and !exists $entrants->[0]->{score};

    my $preceding;
    for my $entrant ( @$entrants ) {
        $entrant->{position} =~ s/\(tie\)$//;
        next if !$preceding or exists $entrant->{notes};
        $entrant->{notes} = $entrant->{sodos};
        $entrant->{sodos} = $entrant->{sos};
        $entrant->{sos} = $entrant->{score};
        $entrant->{score} = $entrant->{name};
        $entrant->{position} =~ /^([a-zA-Z0-9]+)(?: \[([^\]]+)\])?$/;
        $entrant->{name} = $1;
        $entrant->{rank} = $2;
        $entrant->{position} = $preceding->{position};
    }
    continue {
        $preceding = $entrant;
    }

    $result;
}

sub _name {
    s/ \[[^\]]+\]$//;
}

sub _rank {
    m/ \[([^\]]+)\]$/ ? $1 : undef;
}

1;
