=== static
--- input read_file add_base_uri
xt/data/Top100/20140630/input.html
--- expected read_file strict eval
xt/data/Top100/20140630/expected.pl

=== dynamic
--- input strict eval
WWW::GoKGS::Scraper::Top100->build_uri;

