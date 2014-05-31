package WWW::GoKGS::Scraper::TournLinks;
use strict;
use warnings;
use Exporter qw/import/;
use Web::Scraper;

our @EXPORT_OK = qw( process_links );

sub process_links {
    my %args = @_ == 1 ? %{$_[0]} : @_;
    my @date = exists $args{date_filter} ? ( $args{date_filter} ) : ();
    my $sort_by = sub { s/^By // };
    my $round_number = sub { m/^Round (\d+) / ? $1 : q{} };

    my $start_time = sub {
        my $time = m/ will start at (.*)$/ && $1;
        $time ||= m/\(([^\-]+) -/ ? $1 : undef;
        $time =~ tr/\x{a0}/ / if $time;
        $time;
    };

    my $end_time = sub {
        my $time = m/- ([^)]+)\)$/ ? $1 : undef;
        $time =~ tr/\x{a0}/ / if $time;
        $time;
    };

    my $round = scraper {
        process '.', 'round' => [ 'TEXT', $round_number ];
        process '.', 'start_time' => [ 'TEXT', $start_time, @date ];
        process 'a', 'end_time' => [ 'TEXT', $end_time, @date ];
        process 'a', 'link' => '@href';
    };

    process '//div[@class="tournData"]', 'links' => scraper {
        process '//a[@href="tzList.jsp"]', 'time_zone' => 'TEXT';
        process '//ul[starts-with(preceding-sibling::p/text(), "Entrants")]//li',
                'entrants[]' => scraper {
                    process 'a', 'sort_by' => [ 'TEXT', $sort_by ];
                    process 'a', 'link' => '@href'; };
        process '//ul[starts-with(preceding-sibling::p/text(), "Games")]//li',
                'rounds[]' => $round;
    };
}

1;
