package Hash::Censor;
use strict;
use warnings;
use feature 'say';
use Data::Dumper;

use Exporter qw/import/;

our @EXPORT_OK = qw/
    censor_keys_modify_hash
/;

=head2 censor_keys_modify_hash

Takes a hashref of hashrefs and modifies it by removing
any key-value pair where key is in the list.

Returns the list of deleted paths.


=cut

sub censor_keys_modify_hash {
    my ($rh_data, $rh_params) = @_;

    my %valid_params = (
        delete_keys => 1,
        leaf_only   => 1,
    );
    my @pkeys = keys(%$rh_params);
    foreach my $pkey (@pkeys) {
        die "invalid parameter $pkey" unless $valid_params{$pkey};
    }

    

    return unless $rh_data && (ref($rh_data) eq 'HASH');

    if (defined($rh_params) && !(ref($rh_params) eq 'HASH')) {
        die 'Second parameter must be a hash reference';
    }

    my %params = (
        delete_keys => [],
        leaf_only   => 0,
        defined($rh_params) ? %$rh_params : ()
    );

    my %delkeys = map { $_ => 1 } @{$params{delete_keys}};

    my @deletions;
    foreach my $key (keys ($rh_data) ) {
        if (ref($rh_data->{$key}) ne 'HASH')  { # it's a leaf node
            if (exists($delkeys{$key})) {
                delete $rh_data->{$key};
                push @deletions, $key;
            }
            next;
        }

        # if it's a match and we can delete non-leaves
        if ((!$params{leaf_only}) && exists($delkeys{$key})) {
            delete $rh_data->{$key};
            push @deletions, $key;
        }
        else { # it's a hash and we're deleting leaf_only
            my @inner_deletions = censor_keys_modify_hash($rh_data->{$key}, \%params);
            push @deletions,  (map { $key.'->'.$_ } @inner_deletions );
        }
    }

    return @deletions;
}


1;
