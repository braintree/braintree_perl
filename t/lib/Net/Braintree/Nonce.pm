package Net::Braintree::Nonce;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(transactable consumed paypal_one_time_payment paypal_future_payment);
our @EXPORT_OK = qw();

sub transactable {
  "fake-valid-nonce";
}

sub consumed {
  "fake-consumed-nonce";
}

sub paypal_one_time_payment {
  "fake-paypal-one-time-nonce";
}

sub paypal_future_payment {
  "fake-paypal-future-nonce";
}

1;
