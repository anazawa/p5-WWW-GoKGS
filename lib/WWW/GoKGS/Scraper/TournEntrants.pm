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

sub _build_scraper {
    my $self = shift;
    my $name = sub { s/ \[[^\]]+\]$// };
    my $rank = sub { m/ \[([^\]]+)\]$/ ? $1 : undef };

    scraper {
        process '//h1', 'name' => [ 'TEXT', sub { s/ Players$// } ];
        process '//table[tr/th[3]/text()="Score"]//following-sibling::tr',
                'entrants[]' => scraper { # Swiss, McMahon
                    process '//td[1]', 'position' => 'TEXT';
                    process '//td[2]', 'name' => [ 'TEXT', $name ];
                    process '//td[2]', 'rank' => [ 'TEXT', $rank ];
                    process '//td[3]', 'score' => 'TEXT';
                    process '//td[4]', 'sos' => 'TEXT';
                    process '//td[5]', 'sodos' => 'TEXT';
                    process '//td[6]', 'notes' => 'TEXT'; };
        process '//table[tr/th[1]/text()="Name"]//following-sibling::tr',
                'entrants[]' => scraper { # Double Elimination
                    process '//td[1]', 'name' => [ 'TEXT', $name ];
                    process '//td[1]', 'rank' => [ 'TEXT', $rank ];
                    process '//td[2]', 'standing' => 'TEXT'; };
        process '//table[tr/th[3]/text()="#"]//following-sibling::tr',
                'entrants[]' => scraper { # Round Robin
                    process '//td', 'columns[]' => 'TEXT';
                    result 'columns'; };
        process_links date_filter => $self->date_filter;
    };
}

sub date_filter {
    my $self = shift;
    $self->{date_filter} = shift if @_;
    $self->{date_filter} ||= sub { $_[0] };
}

sub scrape {
    my ( $self, @args ) = @_;
    my $result = $self->SUPER::scrape( @args );

    for my $key (qw/name entrants results links/) {
        undef $result->{$key} unless exists $result->{$key};
    }

    return $result unless $result->{entrants};

    if ( $result->{entrants}->[0] ) { # Swiss, McMahon, Double Elimination
        my $preceding;
        for my $entrant ( @{$result->{entrants}} ) {
            $entrant->{position} =~ s/\(tie\)$//;
            next unless exists $entrant->{score};
            next if !$preceding or exists $entrant->{notes};
            $entrant->{notes}    = $entrant->{sodos};
            $entrant->{sodos}    = $entrant->{sos};
            $entrant->{sos}      = $entrant->{score};
            $entrant->{score}    = $entrant->{name};
            $entrant->{position} =~ /^([a-zA-Z0-9]+)(?: \[([^\]]+)\])?$/;
            $entrant->{name}     = $1;
            $entrant->{rank}     = $2;
            $entrant->{position} = $preceding->{position};
        }
        continue {
            $preceding = $entrant;
        }
    }
    else { # Round Robin
        shift @{$result->{entrants}};

        my @entrants;
        my $size = @{$result->{entrants}->[0]};
        for my $entrant ( @{$result->{entrants}} ) {
            $entrant->[0] =~ s/\(tie\)$//;

            push @entrants, {
                position => @$entrant == $size ? shift @$entrant : $entrants[-1]{position},
                name     => shift @$entrant,
                number   => shift @$entrant,
                notes    => pop @$entrant,
                score    => pop @$entrant,
                results  => $entrant,
            };
        }

        for my $entrant ( @entrants ) {
            $entrant->{results} = undef unless $entrant->{number};
            $entrant->{name} =~ /^([a-zA-Z0-9]+)(?: \[([^\]]+)\])?$/;
            $entrant->{name} = $1;
            $entrant->{rank} = $2;
        }

        my %results;
        for my $a ( @entrants ) {
            next unless $a->{number};
            for my $b ( @entrants ) {
                next unless $b->{number};
                next if $b == $a;
                $results{$a->{name}}{$b->{name}}
                    = $a->{results}->[$b->{number}-1];
            }
        }

        delete @{$_}{qw/number results/} for @entrants;

        $result->{results} = \%results;
        @{$result->{entrants}} = @entrants;
    }

    $result;
}

1;
