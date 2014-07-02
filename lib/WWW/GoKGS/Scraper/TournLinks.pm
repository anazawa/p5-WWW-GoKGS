package WWW::GoKGS::Scraper::TournLinks;
use strict;
use warnings FATAL => 'all';
use Exporter qw/import/;
use WWW::GoKGS::Scraper::Declare;
use WWW::GoKGS::Scraper::Filters qw/datetime/;

our @EXPORT = qw( _build_tourn_links );

sub _build_tourn_links {
    my $self = shift;

    my $round = sub { m/^Round (\d+) / && $1 };

    my @start_time = (
        sub {
            my $time = m/ will start at (.*)$/ && $1;
            $time ||= m/\(([^\-]+) -/ ? $1 : undef;
            $time =~ tr/\x{a0}/ / if $time;
            $time;
        },
        \&datetime,
    );

    my @end_time = (
        sub {
            my $time = m/- ([^)]+)\)$/ ? $1 : undef;
            $time =~ tr/\x{a0}/ / if $time;
            $time;
        },
        \&datetime,
    );

    scraper {
        process '//ul[1]//li', 'entrants[]' => scraper {
                    process 'a', 'sort_by' => [ 'TEXT', sub { s/^By // } ];
                    process 'a', 'uri' => '@href'; };
        process '//ul[2]//li', 'rounds[]' => scraper {
                    process '.', 'round' => [ 'TEXT', $round ];
                    process '.', 'start_time' => [ 'TEXT', @start_time ];
                    process 'a', 'end_time' => [ 'TEXT', @end_time ];
                    process 'a', 'uri' => '@href'; };
    };
}

1;
