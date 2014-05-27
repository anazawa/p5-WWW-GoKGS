use strict;
use warnings;
use Test::More tests => 5;
use WWW::GoKGS;
use WWW::GoKGS::Scraper::TournList;
use WWW::GoKGS::Scraper::TournInfo;
use WWW::GoKGS::Scraper::TournEntrants;
use WWW::GoKGS::Scraper::TournGames;

subtest 'WWW::GoKGS::Scraper::TournList' => sub {
    my $tourn_list = WWW::GoKGS::Scraper::TournList->new;
    isa_ok $tourn_list, 'WWW::GoKGS::Scraper::TournList';
    is $tourn_list->base_uri, 'http://www.gokgs.com/tournList.jsp';
};

subtest 'WWW::GoKGS::Scraper::TournInfo' => sub {
    my $tourn_info = WWW::GoKGS::Scraper::TournInfo->new;
    isa_ok $tourn_info, 'WWW::GoKGS::Scraper::TournInfo';
    is $tourn_info->base_uri, 'http://www.gokgs.com/tournInfo.jsp';
    isa_ok $tourn_info->date_filter, 'CODE';
    isa_ok $tourn_info->html_filter, 'CODE';
};

subtest 'WWW::GoKGS::Scraper::TournEntrants' => sub {
    my $tourn_entrants = WWW::GoKGS::Scraper::TournEntrants->new;
    isa_ok $tourn_entrants, 'WWW::GoKGS::Scraper::TournEntrants';
    is $tourn_entrants->base_uri, 'http://www.gokgs.com/tournEntrants.jsp';
    isa_ok $tourn_entrants->date_filter, 'CODE';
};

subtest 'WWW::GoKGS::Scraper::TournGames' => sub {
    my $tourn_games = WWW::GoKGS::Scraper::TournGames->new;
    isa_ok $tourn_games, 'WWW::GoKGS::Scraper::TournGames';
    is $tourn_games->base_uri, 'http://www.gokgs.com/tournGames.jsp';
    isa_ok $tourn_games->date_filter, 'CODE';
};

subtest 'WWW::GoKGS' => sub {
    my $gokgs = WWW::GoKGS->new;
    isa_ok $gokgs, 'WWW::GoKGS';
    isa_ok $gokgs->date_filter, 'CODE';
    isa_ok $gokgs->html_filter, 'CODE';
    isa_ok $gokgs->tourn_list, 'WWW::GoKGS::Scraper::TournList';
    isa_ok $gokgs->tourn_info, 'WWW::GoKGS::Scraper::TournInfo';
    isa_ok $gokgs->tourn_entrants, 'WWW::GoKGS::Scraper::TournEntrants';
    isa_ok $gokgs->tourn_games, 'WWW::GoKGS::Scraper::TournGames';
};
