
package DateTime::Format::Atom;

use strict;
use warnings;

use version; our $VERSION = qv('v1.0.2');

use DateTime::Format::RFC3339 qw( );


use constant FIRST_IDX  => 0;
use constant IDX_HELPER => FIRST_IDX + 0;
use constant NEXT_IDX   => FIRST_IDX + 1;


sub new {
   my ($class, %opts) = @_;
   my $helper = DateTime::Format::RFC3339->new( uc_only => 1 );
   return bless([
      $helper,  # IDX_HELPER
   ], $class);
}


sub parse_datetime {
   my ($self, $str) = @_;

   $self = $self->new()
      if !ref($self);

   return $self->[IDX_HELPER]->parse_datetime($str);
}


sub format_datetime {
   my ($self, $dt) = @_;

#   $self = $self->new()
#      if !ref($self);
#
#   return $self->[IDX_HELPER]->format_datetime($dt);
   return DateTime::Format::RFC3339->format_datetime($dt);
}


1;


__END__

=head1 NAME

DateTime::Format::Atom - Parse and format Atom datetime strings


=head1 VERSION

Version 1.0.2


=head1 SYNOPSIS

    use DateTime::Format::Atom;

    my $f = DateTime::Format::Atom->new();
    my $dt = $f->parse_datetime( '2002-07-01T13:50:05Z' );

    # 2002-07-01T13:50:05Z
    print $f->format_datetime($dt);


=head1 DESCRIPTION

This module understands the Atom date/time format, an ISO 8601 profile, defined
at L<http://tools.ietf.org/html/rfc4287>

It can be used to parse these formats in order to create the appropriate 
objects.

All the work is actually done by L<DateTime::Format::RFC3339>.

=head1 METHODS

=over

=item C<parse_datetime($string)>

Given a Atom datetime string, this method will return a new
L<DateTime> object.

If given an improperly formatted string, this method will croak.

For a more flexible parser, see L<DateTime::Format::ISO8601>.

=item C<format_datetime($datetime)>

Given a L<DateTime> object, this methods returns a Atom datetime
string.

For simplicity, the datetime will be converted to UTC first.

=back

=head1 SEE ALSO

=over 4

=item * L<DateTime>

=item * L<DateTime::Format::RFC3339>

=item * L<DateTime::Format::ISO8601>

=item * L<http://tools.ietf.org/html/rfc3339>, "Date and Time on the Internet: Timestamps"


=item * L<http://tools.ietf.org/html/rfc4287>, "The Atom Syndication Format"


=back


=head1 BUGS

Please report any bugs or feature requests to C<bug-datetime-format-atom at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DateTime-Format-Atom>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DateTime::Format::Atom

You can also look for information at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/DateTime-Format-Atom>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DateTime-Format-Atom>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DateTime-Format-Atom>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DateTime-Format-Atom>

=back


=head1 AUTHOR

Eric Brine, C<< <ikegami@adaelis.com> >>


=head1 COPYRIGHT & LICENSE

No rights reserved.

The author has dedicated the work to the Commons by waiving all of his
or her rights to the work worldwide under copyright law and all related or
neighboring legal rights he or she had in the work, to the extent allowable by
law.

Works under CC0 do not require attribution. When citing the work, you should
not imply endorsement by the author.


=cut
