package Class::Load;
use strict;
use warnings;
use base 'Exporter';
use File::Spec;
use Scalar::Util 'reftype';

our $VERSION = '0.06';

our @EXPORT_OK = qw/load_class load_optional_class try_load_class is_class_loaded/;
our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
);

our $ERROR;

BEGIN {
    *IS_RUNNING_ON_5_10 = ($] < 5.009_005)
        ? sub () { 0 }
        : sub () { 1 };
}

sub load_class {
    my $class = shift;

    my ($res, $e) = try_load_class($class);
    return 1 if $res;

    require Carp;
    Carp::croak $e;
}

sub load_optional_class {
    my $class = shift;
    # If success, then we report "Its there"
    return 1 if try_load_class($class);

    # My testing says that if its in INC, the file definately exists
    # on disk. In all versions of Perl. The value isn't reliable,
    # but it existing is.
    my $file = _mod2pm( $class );
    return 0 unless exists $INC{$file};

    require Carp;
    Carp::croak $ERROR;
}

sub _mod2pm {
    my $class = shift;
    # see rt.perl.org #19213
    my @parts = split '::', $class;
    my $file = $^O eq 'MSWin32'
             ? join '/', @parts
             : File::Spec->catfile(@parts);
    $file .= '.pm';
    return $file;
}

sub try_load_class {
    my $class = shift;

    local $@;
    undef $ERROR;

    return 1 if is_class_loaded($class);

    my $file = _mod2pm($class);
    # This says "our diagnostics of the package
    # say perl's INC status about the file being loaded are
    # wrong", so we delete it from %INC, so when we call require(),
    # perl will *actually* try reloading the file.
    #
    # If the file is already in %INC, it won't retry,
    # And on 5.8, it won't fail either!
    #
    # The extra benefit of this trick, is it helps even on
    # 5.10, as instead of dying with "Compilation failed",
    # it will die with the actual error, and thats a win-win.
    delete $INC{$file};
    return 1 if eval {
        local $SIG{__DIE__} = 'DEFAULT';
        require $file;
        1;
    };

    $ERROR = $@;
    return 0 unless wantarray;
    return 0, $@;
}

sub _is_valid_class_name {
    my $class = shift;

    return 0 if ref($class);
    return 0 unless defined($class);
    return 0 unless length($class);

    return 1 if $class =~ /^\w+(?:::\w+)*$/;

    return 0;
}

sub is_class_loaded {
    my $class = shift;

    return 0 unless _is_valid_class_name($class);

    # walk the symbol table tree to avoid autovififying
    # \*{${main::}{"Foo::"}} == \*main::Foo::

    my $pack = \*::;
    foreach my $part (split('::', $class)) {
        return 0 unless exists ${$$pack}{"${part}::"};
        $pack = \*{${$$pack}{"${part}::"}};
    }

    # We used to check in the package stash, but it turns out that
    # *{${$$package}{VERSION}{SCALAR}} can end up pointing to a
    # reference to undef. It looks

    my $version = do {
        no strict 'refs';
        ${$class . '::VERSION'};
    };

    return 1 if ! ref $version && defined $version;
    # Sometimes $VERSION ends up as a reference to undef (weird)
    return 1 if ref $version && reftype $version eq 'SCALAR' && defined ${$version};

    return 1 if exists ${$$pack}{ISA}
             && defined *{${$$pack}{ISA}}{ARRAY};

    # check for any method
    foreach ( keys %{$$pack} ) {
        next if substr($_, -2, 2) eq '::';

        my $glob = ${$$pack}{$_} || next;

        # constant subs
        if ( IS_RUNNING_ON_5_10 ) {
            my $ref = ref($glob);
            return 1 if $ref eq 'SCALAR' || $ref eq 'REF';
        }

        # stubs
        my $refref = ref(\$glob);
        return 1 if $refref eq 'SCALAR';

        return 1 if defined *{$glob}{CODE};
    }

    # fail
    return 0;
}

1;

__END__

=head1 NAME

Class::Load - a working (require "Class::Name") and more

=head1 SYNOPSIS

    use Class::Load ':all';

    try_load_class('Class::Name')
        or plan skip_all => "Class::Name required to run these tests";

    load_class('Class::Name');

    is_class_loaded('Class::Name');

    my $baseclass = load_optional_class('Class::Name::MightExist')
        ? 'Class::Name::MightExist'
        : 'Class::Name::Default';

=head1 DESCRIPTION

C<require EXPR> only accepts C<Class/Name.pm> style module names, not
C<Class::Name>. How frustrating! For that, we provide
C<load_class 'Class::Name'>.

It's often useful to test whether a module can be loaded, instead of throwing
an error when it's not available. For that, we provide
C<try_load_class 'Class::Name'>.

Finally, sometimes we need to know whether a particular class has been loaded.
Asking C<%INC> is an option, but that will miss inner packages and any class
for which the filename does not correspond to the package name. For that, we
provide C<is_class_loaded 'Class::Name'>.

=head1 FUNCTIONS

=head2 load_class Class::Name

C<load_class> will load C<Class::Name> or throw an error, much like C<require>.

If C<Class::Name> is already loaded (checked with C<is_class_loaded>) then it
will not try to load the class. This is useful when you have inner packages
which C<require> does not check.

=head2 try_load_class Class::Name -> 0|1
=head2 try_load_class Class::Name -> (0|1, error message)

Returns 1 if the class was loaded, 0 if it was not. If the class was not
loaded, the error will be returned as a second return value in list context.

Again, if C<Class::Name> is already loaded (checked with C<is_class_loaded>)
then it will not try to load the class. This is useful when you have inner
packages which C<require> does not check.

=head2 is_class_loaded Class::Name -> 0|1

This uses a number of heuristics to determine if the class C<Class::Name> is
loaded. There heuristics were taken from L<Class::MOP>'s old pure-perl
implementation.

=head2 load_optional_class Class::Name -> 0|1

C<load_optional_class> is a lot like C<try_load_class>, but also a lot like
C<load_class>.

If the class exists, and it works, then it will return 1.

If the class doesn't exist, and it appears to not exist on disk either, it
will return 0.

If the class exists on disk, but loading from disk results in an error
( ie: a syntax error ), then it will C<croak> with that error.

This is useful for using if you want a fallback module system, ie:

    my $class = load_optional_class($foo) ? $foo : $default;

That way, if $foo does exist, but can't be loaded due to error, you won't
get the behaviour of it simply not existing.

=head1 SEE ALSO

=over 4

=item L<UNIVERSAL::require>

Adds a C<require> method to C<UNIVERSAL> so that you can say
C<< Class::Name->require >>. I personally dislike the pollution.

=item L<Module::Load>

Supports C<Class::Name> and C<< Class/Name.pm >> formats, no C<try_to_load> or
C<is_class_loaded>.

=item L<Moose>, L<Jifty>, L<Prophet>, etc

This module was designed to be used anywhere you have
C<if (eval "require $module"; 1)>, which occurs in many large projects.

=back

=head1 AUTHOR

Shawn M Moore, C<< <sartak at bestpractical.com> >>

The implementation of C<is_class_loaded> has been taken from L<Class::MOP>.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-class-load at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Class-Load>.

=head1 COPYRIGHT & LICENSE

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

