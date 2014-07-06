package WWW::GoKGS::Scraper::Declare;
use strict;
use warnings;
use parent qw/Web::Scraper/;
use HTML::TreeBuilder::XPath;

sub tree_builder_class {
    my $self = shift;
    $self->{tree_builder_class} = shift if @_;
    $self->{tree_builder_class} ||= 'HTML::TreeBuilder::XPath';
}

sub build_tree {
    my ( $self, $html ) = @_;
    my $tree = $self->tree_builder_class->new;
    $tree->store_comments(1);
    $tree->ignore_unknown(0);
    $tree->parse($html);
    $tree->eof;
    $tree;
}

1;
