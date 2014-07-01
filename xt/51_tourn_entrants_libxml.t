use strict;
use warnings;
use Test::More;

eval 'use HTML::TreeBuilder::LibXML';
plan skip_all => 'HTML::TreeBuilder::LibXML is required' if $@;

HTML::TreeBuilder::LibXML->replace_original;
do 'xt/50_tourn_entrants.t';
