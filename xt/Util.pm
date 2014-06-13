package xt::Util;
use strict;
use warnings;
use Exporter qw/import/;
use Scalar::Util qw/blessed/;

our @EXPORT_OK = qw(
    cmp_deeply
    array
    uri
    integer
);

our %EXPORT_TAGS = (
    cmp_deeply => [qw/cmp_deeply array uri integer/],
);

sub cmp_deeply {
    my ( $got, $expected ) = @_;
    
    Test::More::isa_ok( $got, 'HASH' );

    for my $key ( %$got ) {
        if ( ref $expected->{$key} eq 'CODE' ) {
            local $_ = $got->{$key};
            my $bool = $expected->{$key}->( $got->{$key}, $key );
            Test::More::ok( $bool, "$got->{$key} ($key)" ) if defined $bool;
        }
        elsif ( ref $expected->{$key} eq 'ARRAY' ) {
            for my $e ( @{$expected->{$key}} ) {
                local $_ = $got->{$key};
                my $bool = $e->( $got->{$key}, $key );
                Test::More::ok( $bool, "$got->{$key} ($key)" ) if defined $bool;
            }
        }
        elsif ( ref $expected->{$key} eq 'HASH' ) {
            cmp_deeply( $got->{$key}, $expected->{$key} );
        }
    }

    return;
}

sub array {
    my $expected = shift;

    sub {
        my $got = shift;
        Test::More::isa_ok( $got, 'ARRAY' );
        cmp_deeply( $_, $expected ) for @$got;
        return;
    };
}

sub uri {
    sub {
        my ( $got, $key ) = @_;
        Test::More::isa_ok( $got, 'URI', "$got ($key) should be URI" );
        return;
    };
}

sub integer {
    sub {
        my ( $got, $key ) = @_;
        Test::More::like( $got, qr{^?(?:0|\-?[1-9][0-9]*)$}, "$got ($key) should be integer" );
        return;
    };
}

1;
