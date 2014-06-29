=== static
--- input read_file decode_utf8 add_base_uri
xt/data/GameArchives/20140630-user-anazawa-year-2014-month-5/input.html
--- expected read_file strict eval
xt/data/GameArchives/20140630-user-anazawa-year-2014-month-5/expected.pl

=== dynamic
--- input yaml query
user: anazawa

=== random
--- input strict eval query
use WWW::GoKGS::Scraper::Top100;
my $players = WWW::GoKGS::Scraper::Top100->new->query->{players};
{ user => $players->[int(rand(@$players))]->{name} };

