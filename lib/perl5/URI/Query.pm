#
# Class providing URI query string manipulation
#

package URI::Query;

use 5.00503;
use strict;

use URI::Escape qw(uri_escape_utf8 uri_unescape);

use overload
  '""'    => \&stringify,
  'eq'  => sub { $_[0]->stringify eq $_[1]->stringify },
  'ne'  => sub { $_[0]->stringify ne $_[1]->stringify };

use vars q($VERSION);
$VERSION = '0.09';

# -------------------------------------------------------------------------
# Remove all occurrences of the given parameters
sub strip
{
    my $self = shift;
    delete $self->{qq}->{$_} foreach @_;
    $self
}

# Remove all parameters except those given
sub strip_except
{
    my $self = shift;
    my %keep = map { $_ => 1 } @_;
    foreach (keys %{$self->{qq}}) {
        delete $self->{qq}->{$_} unless $keep{$_};
    }
    $self
}

# Remove all empty/undefined parameters
sub strip_null
{
    my $self = shift;
    foreach (keys %{$self->{qq}}) {
        delete $self->{qq}->{$_} unless @{$self->{qq}->{$_}};
    }
    $self
}

# Replace all occurrences of the given parameters
sub replace
{
    my $self = shift;
    my %arg = @_;
    for my $key (keys %arg) {
        $self->{qq}->{$key} = [];
        if (ref $arg{$key} eq 'ARRAY') {
            push @{$self->{qq}->{$key}}, $_ foreach @{$arg{$key}};
        }
        else {
            push @{$self->{qq}->{$key}}, $arg{$key};
        }
    }
    $self
}

# Return the stringified qq hash
sub stringify
{
    my $self = shift;
    my $sep = shift || $self->{sep} || '&';
    my @out = ();
    for my $key (sort keys %{$self->{qq}}) {
        for my $value (sort @{$self->{qq}->{$key}}) {
            push @out, sprintf("%s=%s", uri_escape_utf8($key), uri_escape_utf8($value));
        }
    }
    join $sep, @out;
}

sub revert
{
    my $self = shift;
    # Revert qq to the qq_orig hashref
    $self->{qq} = $self->_deepcopy($self->{qq_orig});
    $self
}

# -------------------------------------------------------------------------
# Convenience methods

# Return the current qq hash(ref) with one-elt arrays flattened
sub hash
{
    my $self = shift;
    my %qq = %{$self->{qq}};
    # Flatten one element arrays
    for (sort keys %qq) {
      $qq{$_} = $qq{$_}->[0] if @{$qq{$_}} == 1;
    }
    return wantarray ? %qq : \%qq;
}

# Return the current qq hash(ref) with all elements as arrayrefs
sub hash_arrayref
{
    my $self = shift;
    my %qq = %{$self->{qq}};
    # (Don't flatten one element arrays)
    return wantarray ? %qq : \%qq;
}

# Return the current query as a string of html hidden input tags
sub hidden
{
    my $self = shift;
    my $str = '';
    for my $key (sort keys %{$self->{qq}}) {
        for my $value (@{$self->{qq}->{$key}}) {
            $str .= qq(<input type="hidden" name="$key" value="$value" />\n);
        }
    }
    return $str;
}

# -------------------------------------------------------------------------
# Set the output separator to use by default
sub separator
{
    my $self = shift;
    $self->{sep} = shift;
}

# Deep copy routine, originally swiped from a Randal Schwartz column
sub _deepcopy
{
    my ($self, $this) = @_;
    if (! ref $this) {
        return $this;
    } elsif (ref $this eq "ARRAY") {
        return [map $self->_deepcopy($_), @$this];
    } elsif (ref $this eq "HASH") {
        return {map { $_ => $self->_deepcopy($this->{$_}) } keys %$this};
    } elsif (ref $this eq "CODE") {
        return $this;
    } elsif (sprintf $this) {
        # Object! As a last resort, try copying the stringification value
        return sprintf $this;
    } else {
        die "what type is $_? (" . ref($this) . ")";
    }
}

# Parse query string, storing as hash (qq) of key => arrayref pairs
sub _parse_qs
{
    my $self = shift;
    my $qs = shift;
    for (split /[&;]/, $qs) {
        my ($key, $value) = map { uri_unescape($_) } split /=/, $_, 2;
        $self->{qq}->{$key} ||= [];
        push @{$self->{qq}->{$key}}, $value if defined $value && $value ne '';
    }
    $self
}

# Process arrayref arguments into hash (qq) of key => arrayref pairs
sub _init_from_arrayref
{
    my ($self, $arrayref) = @_;
    while (@$arrayref) {
        my $key   = shift @$arrayref;
        my $value = shift @$arrayref;
        my $key_unesc = uri_unescape($key);

        $self->{qq}->{$key_unesc} ||= [];
        if (defined $value && $value ne '') {
            my @values;
            if (! ref $value) {
                @values = split "\0", $value;
            }
            elsif (ref $value eq 'ARRAY') {
                @values = @$value;
            }
            else {
                die "Invalid value found: $value. Not string or arrayref!";
            }
            push @{$self->{qq}->{$key_unesc}}, map { uri_unescape($_) } @values;
        }
    }
}

# Constructor - either new($qs) where $qs is a scalar query string or a
#   a hashref of key => value pairs, or new(key => val, key => val);
#   In the array form, keys can repeat, and/or values can be arrayrefs.
sub new
{
    my $class = shift;
    my $self = bless { qq => {} }, $class;
    if (@_ == 1 && ! ref $_[0] && $_[0]) {
        $self->_parse_qs($_[0]);
    }
    elsif (@_ == 1 && ref $_[0] eq 'HASH') {
        $self->_init_from_arrayref([ %{$_[0]} ]);
    }
    elsif (scalar(@_) % 2 == 0) {
        $self->_init_from_arrayref(\@_);
    }

    # Clone the qq hashref to allow reversion
    $self->{qq_orig} = $self->_deepcopy($self->{qq});

    return $self;
}
# -------------------------------------------------------------------------

1;

=head1 NAME

URI::Query - class providing URI query string manipulation

=head1 SYNOPSIS

    # Constructor - using a GET query string
    $qq = URI::Query->new($query_string);
    # OR Constructor - using a hashref of key => value parameters
    $qq = URI::Query->new($cgi->Vars);
    # OR Constructor - using an array of successive keys and values
    $qq = URI::Query->new(@params);

    # Revert back to the initial constructor state (to do it all again)
    $qq->revert;

    # Remove all occurrences of the given parameters
    $qq->strip('page', 'next');

    # Remove all parameters except the given ones
    $qq->strip_except('pagesize', 'order');

    # Remove all empty/undefined parameters
    $qq->strip_null;

    # Replace all occurrences of the given parameters
    $qq->replace(page => $page, foo => 'bar');

    # Set the argument separator to use for output (default: unescaped '&')
    $qq->separator(';');

    # Output the current query string
    print "$qq";           # OR $qq->stringify;
    # Stringify with explicit argument separator
    $qq->stringify(';');

    # Get a flattened hash/hashref of the current parameters
    #   (single item parameters as scalars, multiples as an arrayref)
    my %qq = $qq->hash;

    # Get a non-flattened hash/hashref of the current parameters
    #   (parameter => arrayref of values)
    my %qq = $qq->hash_arrayref;

    # Get the current query string as a set of hidden input tags
    print $qq->hidden;


=head1 DESCRIPTION

URI::Query provides simple URI query string manipulation, allowing you
to create and manipulate URI query strings from GET and POST requests in
web applications. This is primarily useful for creating links where you
wish to preserve some subset of the parameters to the current request,
and potentially add or replace others. Given a query string this is
doable with regexes, of course, but making sure you get the anchoring
and escaping right is tedious and error-prone - this module is simpler.

=head2 CONSTRUCTOR

URI::Query objects can be constructed from scalar query strings
('foo=1&bar=2&bar=3'), from a hashref which has parameters as keys, and
values either as scalars or arrayrefs of scalars (to handle the case of
parameters with multiple values e.g. { foo => '1', bar => [ '2', '3' ] }),
or arrays composed of successive parameters-value pairs 
e.g. ('foo', '1', 'bar', '2', 'bar', '3'). For instance:

    # Constructor - using a GET query string
    $qq = URI::Query->new($query_string);

    # Constructor - using an array of successive keys and values
    $qq = URI::Query->new(@params);

    # Constructor - using a hashref of key => value parameters,
    # where values are either scalars or arrayrefs of scalars
    $qq = URI::Query->new($cgi->Vars);

URI::Query also handles L<CGI.pm>-style hashrefs, where multiple
values are packed into a single string, separated by the "\0" (null)
character.

All keys and values are URI unescaped at construction time, and are
stored and referenced unescaped. So a query string like:

    group=prod%2Cinfra%2Ctest&op%3Aset=x%3Dy

is stored as:

    'group'     => 'prod,infra,test'
    'op:set'    => 'x=y'

You should always use the unescaped/normal variants in methods i.e.

     $qq->replace('op:set'  => 'x=z');

NOT:

     $qq->replace('op%3Aset'  => 'x%3Dz');


=head2 MODIFIER METHODS

All modifier methods change the state of the URI::Query object in some
way, and return $self, so they can be used in chained style e.g.

    $qq->revert->strip('foo')->replace(bar => 123);

Note that URI::Query stashes a copy of the parameter set that existed
at construction time, so that any changes made by these methods can be 
rolled back using 'revert()'. So you don't (usually) need to keep 
multiple copies around to handle incompatible changes.

=over 4

=item revert()

Revert the current parameter set back to that originally given at
construction time i.e. discard all changes made since construction.

=item strip($param1, $param2, ...)

Remove all occurrences of the given parameters and their values from
the current parameter set.

=item strip_except($param1, $param2, ...)

Remove all parameters EXCEPT those given from the current parameter
set.

=item strip_null()

Remove all parameters that have a value of undef from the current
parameter set.

=item replace($param1 => $value1, $param2, $value2, ...)

Replace the values of the given parameters in the current parameter set
with these new ones. Parameter names must be scalars, but values can be
either scalars or arrayrefs of scalars, when multiple values are desired.

Note that 'replace' can also be used to add or append, since there's
no requirement that the parameters already exist in the current parameter
set.

=item separator($separator)

Set the argument separator to use for output. Default: '&'.

=back

=head2 OUTPUT METHODS

=over 4

=item "$qq", stringify(), stringify($separator)

Return the current parameter set as a conventional param=value query
string, using $separator as the separator if given. e.g.

    foo=1&bar=2&bar=3

Note that all parameters and values are URI escaped by stringify(), so
that query-string reserved characters do not occur within elements. For 
instance, a parameter set of:

    'group'     => 'prod,infra,test'
    'op:set'    => 'x=y'

will be stringified as:

    group=prod%2Cinfra%2Ctest&op%3Aset=x%3Dy

=item hash()

Return a hash (in list context) or hashref (in scalar context) of the
current parameter set. Single-item parameters have scalar values, while
while multiple-item parameters have arrayref values e.g.

    {
        foo => 1,
        bar => [ 2, 3 ],
    }

=item hash_arrayref()

Return a hash (in list context) or hashref (in scalar context) of the
current parameter set. All values are returned as arrayrefs, including
those with single values e.g.

    {
        foo => [ 1 ],
        bar => [ 2, 3 ],
    }

=item hidden()

Returns the current parameter set as a concatenated string of hidden
input tags, one per parameter-value e.g.

    <input type="hidden" name="foo" value="1" />
    <input type="hidden" name="bar" value="2" />
    <input type="hidden" name="bar" value="3" />

=back

=head1 BUGS AND CAVEATS

Please report bugs and/or feature requests to 
C<bug-uri-query at rt.cpan.org>, or through
the web interface at 
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=URI-Query>.

Should allow unescaping of input to be turned off, for situations in 
which it's already been done. Please let me know if you find you
actually need this.

I don't think it makes sense on the output side though, since you need
to understand the structure of the query to escape elements correctly.


=head1 PATCHES

URI::Query code lives at L<https://github.com/gavincarr/URI-Query>.
Patches / pull requests welcome!


=head1 AUTHOR

Gavin Carr <gavin@openfusion.com.au>


=head1 COPYRIGHT

Copyright 2004-2011, Gavin Carr. All Rights Reserved.

This program is free software. You may copy or redistribute it under the
same terms as perl itself.

=cut

# vim:sw=4:et
