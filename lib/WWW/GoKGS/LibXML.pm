package WWW::GoKGS::LibXML;
use strict;
use warnings;
use parent qw/WWW::GoKGS/;
use HTML::TreeBuilder::LibXML;

our $VERSION = '0.18';

sub tree_builder_class { 'HTML::TreeBuilder::LibXML' }

1;
