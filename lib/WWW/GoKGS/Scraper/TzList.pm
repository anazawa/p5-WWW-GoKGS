package WWW::GoKGS::Scraper::TzList;
use strict;
use warnings;
use parent qw/WWW::GoKGS::Scraper/;
use WWW::GoKGS::Scraper::Declare;

sub base_uri { 'http://www.gokgs.com/tzList.jsp' }

sub __build_scraper {
    my $self = shift;

    scraper {
        process '//p[1]/strong', 'current_time_zone' => 'TEXT';
        process '//option', 'time_zones[]' => {
                    name => sub { $_[0]->attr('value') },
                    display_name => [ 'TEXT', sub { s/ \([^\)]+\)$// } ] };
    };
}

1;
