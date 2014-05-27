package WWW::GoKGS::Scraper::TournLinks;
use strict;
use warnings;
use Exporter qw/import/;
use Web::Scraper;

our @EXPORT_OK = qw( process_links );

sub process_links {
    my %args = @_ == 1 ? %{$_[0]} : @_;
    my @date_filter = exists $args{date_filter} ? ( $args{date_filter} ) : ();

    my $round = scraper {
        process '.', 'round' => [ 'TEXT', \&_round ];
        process '.', 'start_time' => [ 'TEXT', \&_start_time, @date_filter ];
        process 'a', 'end_time' => [ 'TEXT', \&_end_time, @date_filter ];
        process 'a', 'link' => '@href';
    };

    process '//div[@class="tournData"]', 'links' => scraper {
        process '//a[@href="tzList.jsp"]', 'time_zone' => 'TEXT';
        process '//ul[starts-with(preceding-sibling::p/text(), "Entrants")]//li',
                'entrants[]' => scraper {
                    process 'a', 'sort_by' => [ 'TEXT', \&_sort_by ];
                    process 'a', 'link' => '@href'; };
        process '//ul[starts-with(preceding-sibling::p/text(), "Games")]//li',
                'rounds[]' => $round;
    };
}

sub _sort_by {
    s/^By //;
}

sub _round {
    m/^Round (\d+) / && $1;
}

sub _start_time {
    my $time = m/ will start at (.*)$/ && $1;
    $time ||= m/\(([^\-]+) -/ && $1;
    $time =~ tr/\x{a0}/ /;
    $time;
}

sub _end_time {
    my $time = m/- ([^)]+)\)$/ && $1;
    $time =~ tr/\x{a0}/ /;
    $time;
}

1;
