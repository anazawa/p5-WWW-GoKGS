use strict;
use warnings;
use Path::Class qw/dir/;
use Test::More tests => 8;
use WWW::GoKGS::Scraper::GameArchives;
use WWW::GoKGS::Scraper::Top100;
use WWW::GoKGS::Scraper::TournList;
use WWW::GoKGS::Scraper::TournInfo;
use WWW::GoKGS::Scraper::TournGames;
use WWW::GoKGS::Scraper::TournEntrants;

for my $dir ( dir('t', 'data')->children ) {
    next unless $dir->is_dir;

    my $class = 'WWW::GoKGS::Scraper::' . $dir->basename;
    my $scraper = $class->new;

    for my $d ( $dir->children ) {
        next unless $d->is_dir;

        my $name = $d->basename . " ($class)";
        my $expected = do $d->file( 'expected.pl' );

        my $input = $d->file( 'input.html' );
           $input = $input->slurp( iomode => '<:encoding(UTF-8)' );

        my $got = $scraper->scrape( \$input, $scraper->base_uri );

        is_deeply $got, $expected, $name;
    }
}
