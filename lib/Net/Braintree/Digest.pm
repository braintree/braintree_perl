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

sub secure_compare {
  my ($left, $right) = @_;

  if ((not defined($left)) || (not defined($right))) {
    return 0;
  }

  my @left_bytes = unpack("C*", $left);
  my @right_bytes = unpack("C*", $right);

  if (length(@left_bytes) != length(@right_bytes)) {
    return 0;
  }

  my $result = 0;
  for (my $i = 0; $i < length(@left_bytes); $i++) {
    $result |= $left_bytes[$i] ^ $right_bytes[$i];
  }
  return $result == 0;
}

1;
