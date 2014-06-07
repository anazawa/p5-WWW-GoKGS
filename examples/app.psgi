use strict;
use warnings;
use HTML::WikiConverter;
use JSON;
use Plack::Request;
use Plack::Response;
use Try::Tiny;
use WWW::GoKGS;

my $JSON = JSON->new->ascii->convert_blessed;

my $WikiConverter = HTML::WikiConverter->new(
    dialect    => 'Markdown',
    link_style => 'inline',
);

my $GoKGS = WWW::GoKGS->new(
    html_filter => sub {
        my $html = shift;
        $WikiConverter->html2wiki( $html );
    },
);

my $app = sub {
    my $env = shift;
    my $request = Plack::Request->new( $env );

    my $response = try {
        my $resource = $GoKGS->scrape(do {
            my $uri = $request->uri;
            $uri->authority( 'www.gokgs.com' );
            $uri;
        });

        my $json = do {
            local *URI::TO_JSON = sub {
                my $self = shift;

                if ( $self->host eq 'www.gokgs.com' ) {
                    my $uri = $request->base;
                    $uri->path( $self->path );
                    $uri->query_form( $self->query_form );
                    $uri->as_string;
                }
                else {
                    $self->as_string;
                }
            };

            $JSON->encode( $resource );
        };

        Plack::Response->new(
            200,
            [
                'Content-Length' => length $json,
                'Content-Type'   => 'application/json; charset=utf-8',
            ],
            $json
        );
    }
    catch {
        if ( /^Don't know how to scrape / ) {
            Plack::Response->new(
                404,
                [
                    'Content-Length' => 9,
                    'Content-Type'   => 'text/plain',
                ],
                'Not Found'
            );
        }
        else {
            Plack::Response->new(
                500,
                [
                    'Content-Length' => length,
                    'Content-Type'   => 'text/plain',
                ],
                $_
            );
        }
    };

    $response->finalize;
};
