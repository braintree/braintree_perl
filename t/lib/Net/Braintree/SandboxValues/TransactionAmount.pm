package Net::Braintree::SandboxValues::TransactionAmount;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(AUTHORIZE DECLINE FAILED);
our @EXPORT_OK = qw();

sub AUTHORIZE {
  1000;
}

sub DECLINE {
  2000;
}

sub FAILED {
  3000;
}

1;
