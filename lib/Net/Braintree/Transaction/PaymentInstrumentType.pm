package Net::Braintree::Transaction::PaymentInstrumentType;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(PAYPAL_ACCOUNT SEPA_BANK_ACCOUNT CREDIT_CARD ANY UNKNOWN);
our @EXPORT_OK = qw();

use constant PAYPAL_ACCOUNT     => "paypal_account";
use constant SEPA_BANK_ACCOUNT  => "sepa_bank_account";
use constant CREDIT_CARD        => "credit_card";
use constant ANY                => "any";
use constant UNKNOWN            => "unknown";

1;
