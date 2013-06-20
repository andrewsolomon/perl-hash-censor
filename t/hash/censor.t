#!perl
use strict;
use warnings;
use Data::Dumper;
use Test::More;
use Test::Exception;

use Hash::Censor qw/censor_keys_modify_hash/;

{
    my %single_layer = (
        name     => 'Foo',
        password => 'Bar',        
    );

    my @deletions = censor_keys_modify_hash(\%single_layer, {
        delete_keys => [ 'password' ],
    });


    is_deeply(\%single_layer, { name  => 'Foo' }, 'removed key at the top level');
}



{
    my %multi_layer = (
        deep_info => {
            name => 'Foo',
            another_deep => {
                password => 'Bar',
            },
            password => {
                this => 'should go'
            }
        },
        stop_right_here => [qw/this is an array/],
        password => 'Bar',        
    );

    my @deletions = censor_keys_modify_hash(\%multi_layer, {
        delete_keys => [ 'password' ]
    });

    is_deeply(
        \%multi_layer, 
        {
            deep_info => {
                name => 'Foo',
                another_deep => {
                },
            },
            stop_right_here => [qw/this is an array/],
        }, 'removed key at the top level'
    );
}


{
    my %multi_layer = (
        deep_info => {
            name => 'Foo',
            another_deep => {
                password => 'Bar',
            },
            password => {
                this => 'should still be here'
            }
        },
        stop_right_here => [qw/this is an array/],
        password => 'Bar',        
    );

    dies_ok {
        censor_keys_modify_hash(\%multi_layer, {
            keys => [ 'password' ] ,
            leaf_only => 1,
        });
    } 'dies with invalid option "keys"';

    my @deletions = censor_keys_modify_hash(\%multi_layer, {
        delete_keys => [ 'password' ] ,
        leaf_only => 1,
    });

    note 'deleted '.join(', ', @deletions);

    is_deeply(
        \%multi_layer,
        {
            deep_info => {
                name => 'Foo',
                another_deep => {
                },
                password => {
                    this => 'should still be here'
                }
            },
            stop_right_here => [qw/this is an array/],
        },
        'removed leaf only key'
    );
}

done_testing;

