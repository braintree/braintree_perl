package Net::Braintree::Test::VenmoSdk;
use strict;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(generate_test_payment_method_code);

sub generate_test_payment_method_code {
  my($number) = @_;
  return "stub-" . $number;
};

use constant InvalidPaymentMethodCode => "stub-invalid-payment-method-code";
use constant VisaPaymentMethodCode => generate_test_payment_method_code("4111111111111111");

use constant InvalidSession => "stub-invalid-session";
use constant Session => "stub-session";

1;
