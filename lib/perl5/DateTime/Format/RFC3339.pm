
package DateTime::Format::RFC3339;

use strict;
use warnings;

use version; our $VERSION = qv('v1.0.5');

use Carp     qw( croak );
use DateTime qw( );


use constant FIRST_IDX   => 0;
use constant IDX_UC_ONLY => FIRST_IDX + 0;
use constant NEXT_IDX    => FIRST_IDX + 1;


sub new {
   my ($class, %opts) = @_;

   my $uc_only = delete( $opts{uc_only} );

   return bless([
      $uc_only,  # IDX_UC_ONLY
   ], $class);
}


sub parse_datetime {
   my ($self, $str) = @_;

   $self = $self->new()
      if !ref($self);

   $str = uc($str)
      if !$self->[IDX_UC_ONLY];
   
   my ($Y,$M,$D) = $str =~ s/^(\d{4})-(\d{2})-(\d{2})// && (0+$1,0+$2,0+$3)
       or croak("Incorrectly formatted date");

   $str =~ s/^T//
      or croak("Incorrectly formatted datetime");

   my ($h,$m,$s) = $str =~ s/^(\d{2}):(\d{2}):(\d{2})// && (0+$1,0+$2,0+$3)
       or croak("Incorrectly formatted time");

   my $ns = $str =~ s/^\.(\d{1,9})\d*// ? 0+substr($1.('0'x8),0,9) : 0;

   my $tz;
   if    ( $str =~ s/^Z//                     ) { $tz = 'UTC';    }
   elsif ( $str =~ s/^([+-])(\d{2}):(\d{2})// ) { $tz = "$1$2$3"; }
   else { croak("Missing time zone"); }

   $str =~ /^\z/ or croak("Incorrectly formatted datetime");

   return DateTime->new(
      year       => $Y,
      month      => $M,
      day        => $D,
      hour       => $h,
      minute     => $m,
      second     => $s,
      nanosecond => $ns,
      time_zone  => $tz,
      formatter  => $self,
   );
}


sub format_datetime {
   my ($self, $dt) = @_;

   my $tz;
   if ($dt->time_zone()->is_utc()) {
      $tz = 'Z';
   } else {
      my $secs  = $dt->offset();
      my $sign = $secs < 0 ? '-' : '+';  $secs = abs($secs);
      my $mins  = int($secs / 60);       $secs %= 60;
      my $hours = int($mins / 60);       $mins %= 60;
      if ($secs) {
         ( $dt = $dt->clone() )
            ->set_time_zone('UTC');
         $tz = 'Z';
      } else {
         $tz = sprintf('%s%02d:%02d', $sign, $hours, $mins);
      }
   }

   return
      $dt->strftime(
         ($dt->nanosecond()
            ? '%Y-%m-%dT%H:%M:%S.%9N'
            : '%Y-%m-%dT%H:%M:%S'
         )
      ).$tz;
}


1;


__END__

=head1 NAME

DateTime::Format::RFC3339 - Parse and format RFC3339 datetime strings


=head1 VERSION

Version 1.0.5


=head1 SYNOPSIS

    use DateTime::Format::RFC3339;

    my $f = DateTime::Format::RFC3339->new();
    my $dt = $f->parse_datetime( '2002-07-01T13:50:05Z' );

    # 2002-07-01T13:50:05Z
    print $f->format_datetime($dt);


=head1 DESCRIPTION

This module understands the RFC3339 date/time format, an ISO 8601 profile,
defined at L<http://tools.ietf.org/html/rfc3339>.

It can be used to parse these formats in order to create the appropriate 
objects.


=head1 METHODS

=over

=item C<parse_datetime($string)>

Given a RFC3339 datetime string, this method will return a new
L<DateTime> object.

If given an improperly formatted string, this method will croak.

For a more flexible parser, see L<DateTime::Format::ISO8601>.

=item C<format_datetime($datetime)>

Given a L<DateTime> object, this methods returns a RFC3339 datetime
string.

=back

=head1 SEE ALSO

=over 4

=item * L<DateTime>

=item * L<DateTime::Format::ISO8601>

=item * L<http://tools.ietf.org/html/rfc3339>, "Date and Time on the Internet: Timestamps"


=back


=head1 BUGS

Please report any bugs or feature requests to C<bug-datetime-format-rfc3339 at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DateTime-Format-RFC3339>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DateTime::Format::RFC3339

You can also look for information at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/DateTime-Format-RFC3339>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DateTime-Format-RFC3339>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DateTime-Format-RFC3339>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DateTime-Format-RFC3339>

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
