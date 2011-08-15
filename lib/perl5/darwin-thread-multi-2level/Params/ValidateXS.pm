package Params::Validate;

use strict;
use warnings;

my $default_fail = sub {
    require Carp;
    Carp::confess( $_[0] );
};

{
    my %defaults = (
        ignore_case    => 0,
        strip_leading  => 0,
        allow_extra    => 0,
        on_fail        => $default_fail,
        stack_skip     => 1,
        normalize_keys => undef,
    );

    *set_options = \&validation_options;

    sub validation_options {
        my %opts = @_;

        my $caller = caller;

        foreach ( keys %defaults ) {
            $opts{$_} = $defaults{$_} unless exists $opts{$_};
        }

        $OPTIONS{$caller} = \%opts;
    }

    require XSLoader;
    XSLoader::load(
        'Params::Validate',
        exists $Params::Validate::{VERSION}
        ? do { ${ $Params::Validate::{VERSION} } }
        : 42
    );
}

BEGIN {
    *validate      = \&_validate;
    *validate_pos  = \&_validate_pos;
    *validate_with = \&_validate_with;
}

sub _check_regex_from_xs {
    return ( defined $_[0] ? $_[0] : '' ) =~ /$_[1]/ ? 1 : 0;
}

1;
