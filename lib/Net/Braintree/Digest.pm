package Net::Braintree::Digest;
use strict;

use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use Digest::SHA1;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(hexdigest);
our @EXPORT_OK = qw();

sub hexdigest {
  my($key, $data) = @_;
  my $hmac = Digest::HMAC_SHA1->new(key_digest($key));
  $hmac->add($data);
  return $hmac->hexdigest;
}

sub key_digest {
  my ($key) = @_;
  my $sha1 = Digest::SHA1->new;
  $sha1->add($key);
  return $sha1->digest;
}

1;
