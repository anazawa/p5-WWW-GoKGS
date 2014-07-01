use strict;
use warnings;
use Test::More;

eval 'use HTML::TreeBuilder::LibXML';
plan skip_all => 'HTML::TreeBuilder::LibXML is required' if $@;

HTML::TreeBuilder::LibXML->replace_original;
do 'xt/60_tourn_games.t';
