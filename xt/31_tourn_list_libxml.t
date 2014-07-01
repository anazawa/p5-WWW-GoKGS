use strict;
use warnings;
use Test::More;

eval 'use HTML::TreeBuilder::LibXML';
plan skip_all => 'HTML::TreeBuilder::LibXML is required' if $@;

HTML::TreeBuilder::LibXML->replace_original;
do 'xt/30_tourn_list.t';
